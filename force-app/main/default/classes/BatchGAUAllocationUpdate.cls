global with sharing class BatchGAUAllocationUpdate implements Database.stateful, Database.Batchable<sObject>, schedulable, Database.RaisesPlatformEvents  {

    global static final integer MAX_PER_BATCH = 200;
    global decimal joiningfee = decimal.valueOf(Label.GAU_Joining_Fee);
    global decimal Stdfee = decimal.valueOf(Label.GAU_Standard_Fee);
    global decimal Concessionfee = decimal.valueOf(Label.GAU_Concession_Fee);
    global map<string,GAU_New_Members__mdt> GAUNewMemberMap = new map<string,GAU_New_Members__mdt>();
    global map<string,GAU_Renewal_Members__mdt> GAURenewalMemberMap = new map<string,GAU_Renewal_Members__mdt>();

    global Database.querylocator start(Database.BatchableContext BC){
        list<string> GAUList = new list<string>();
        GAUList.add('Next financial year');
        GAUList.add('This financial year');
        GAUList.add('Joining fee member');
        
        list<string> CamList = new list<string>();
        CamList.add('New Members – Full Member');
        CamList.add('New Members – Concession');
        CamList.add('Renewal Members – Full Member');
        CamList.add('Renewal Members – Concession'); 
        string gauid = 'a0b1m000002qxevAAA';
        string query = 'select id,name,npsp__Campaign__r.name,npsp__Amount__c,npsp__Opportunity__r.Payment_Option_Type__c,npsp__Opportunity__r.Pricing__c,npsp__General_Accounting_Unit__r.name from npsp__Allocation__c where  npsp__General_Accounting_Unit__c in (select id from npsp__General_Accounting_Unit__c where name in :GAUList) and npsp__Campaign__c in (select id from Campaign where name in :CamList)';
//        string query = 'select id,name,npsp__Campaign__r.name,npsp__Opportunity__r.Payment_Option_Type__c,npsp__Opportunity__r.Pricing__c,npsp__Amount__c,npsp__General_Accounting_Unit__r.name from npsp__Allocation__c where npsp__Opportunity__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext SC) {
        BatchGAUAllocationUpdate batchProcessor = new BatchGAUAllocationUpdate();
        ID batchprocessid = Database.executeBatch(batchProcessor,5);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        // Update GTL_Order_Product__c        
        List<npsp__Allocation__c> GAUList = (List<npsp__Allocation__c>)scope;
        List<npsp__Allocation__c> GAUUpdateList = (List<npsp__Allocation__c>)scope;

        GAU_New_Members__mdt[] GAUNewMemberMappings = [SELECT MasterLabel, Concession__c, Standard__c FROM GAU_New_Members__mdt];
        for(GAU_New_Members__mdt newmem : GAUNewMemberMappings ){
            GAUNewMemberMap.put(newmem.MasterLabel,newmem);
        }

        GAU_Renewal_Members__mdt[] GAURenewalMemberMappings = [SELECT MasterLabel, Concession__c, Standard__c FROM GAU_Renewal_Members__mdt];
        for(GAU_Renewal_Members__mdt Renewalmem : GAURenewalMemberMappings ){
            GAURenewalMemberMap.put(Renewalmem.MasterLabel,Renewalmem);
        }

        for (npsp__Allocation__c GAU: GAUList) {
            decimal newamount = CalculateAmount(GAU.npsp__Campaign__r.name,GAU.npsp__General_Accounting_Unit__r.name,GAU.npsp__Opportunity__r.Payment_Option_Type__c,GAU.npsp__Opportunity__r.Pricing__c);
//            decimal GAUAmount = CalculateGAUAmount(GAU.npsp__General_Accounting_Unit__r.name,GAU.npsp__Opportunity__r.Payment_Option_Type__c);

            if(newamount >= 0){
                GAU.npsp__Amount__c = newamount;
//            } else {
//                GAU.npsp__Amount__c = 0;
            }

        }      
        system.debug('GAUList'+GAUList);
        if (GAUList != null && !GAUList.IsEmpty() ) {
            string errMsg = '';
            try {
                Database.UpsertResult[] UpsertResult = Database.upsert(GAUList,false); 
                integer i = -1;
                for (Database.UpsertResult DBSaveRes : UpsertResult) {
                    i++;
                    if (!DBSaveRes.isSuccess()) {
                        errMsg += 'Update GAU Amount - BatchGAUAllocationUpdate ,id= '+ GAUList[i].id +', Error: '+ DBSaveRes.getErrors()[0].getMessage()+'\r\n';
                    }        
                }
            } catch (Exception e) {
                errMsg += ' try/catch errror: '+e.getMessage();
            }
                    
        } 
    }

    global void finish(Database.BatchableContext BC){
//        BatchGAUAllocationUpdate batchProcessor = new BatchGAUAllocationUpdate();
//        ID batchprocessid = Database.executeBatch(batchProcessor,200);

    }

    public decimal CalculateAmount(string Campaignname,String GAUname,String Membershiptype,String Pricing) {
        string NewFullMember = 'New Members – Full Member';
        string NewConcessionMember = 'New Members – Concession';
        string RenewalFullMember = 'Renewal Members – Full Member';
        string RenewalConcessionMember = 'Renewal Members – Concession'; 
        // Pricing can be Full Price or Concession
        //Membershiptype can be New Sign Up or Renewal
        integer intMonth = Date.Today().Month();
        string Currentmonth = Checkmonth(intmonth);
        integer fiscalmonth;
        decimal newamount;

        //New Full member
    //    if (Membershiptype == 'New Sign Up' && Pricing == 'Full Price' ) {
        if(Campaignname == NewFullMember) {
            switch on GAUname {
                when  'Joining fee member' {
                    newamount = joiningfee;
                }
                when  'This financial year' {                
                    newamount = ((GAUNewMemberMap!= null && GAUNewMemberMap.containsKey(Currentmonth))? GAUNewMemberMap.get(Currentmonth).Standard__c:0);
                }
                when  'Next financial year' {
                    newamount = Stdfee - ((GAUNewMemberMap!= null && GAUNewMemberMap.containsKey(Currentmonth))? GAUNewMemberMap.get(Currentmonth).Standard__c:0);
                }
                when else {
                }
            }
        
        // Renewal Full Member
//        } else if (Membershiptype == 'Renewal' && Pricing == 'Full Price') {
        } else if(Campaignname == RenewalFullMember) {
            switch on GAUname {
                when  'This financial year' {                  
                    newamount = (GAURenewalMemberMap!= null && GAURenewalMemberMap.containsKey(Currentmonth)? GAURenewalMemberMap.get(Currentmonth).Standard__c:0);
                }
                when  'Next financial year' {
                    newamount = stdfee - ((GAURenewalMemberMap!= null &&GAURenewalMemberMap.containsKey(Currentmonth)? GAURenewalMemberMap.get(Currentmonth).Standard__c:0));
                }
                when else {
                }
            } 

        // Renewal concession member
//        } else if(Membershiptype == 'Renewal' && Pricing == 'Concession') {
        } else if(Campaignname == RenewalConcessionMember) {
            switch on GAUname {
                when  'This financial year' {                       
                    newamount = (GAURenewalMemberMap!= null &&GAURenewalMemberMap.containsKey(Currentmonth)? GAURenewalMemberMap.get(Currentmonth).Concession__c:0);
                }
                when  'Next financial year' {
                    newamount = Concessionfee - ((GAURenewalMemberMap!= null &&GAURenewalMemberMap.containsKey(Currentmonth)? GAURenewalMemberMap.get(Currentmonth).Concession__c:0));
                }
                when else {
                }
            } 

        // New Consession Member
//        } else if(Membershiptype == 'New Sign Up' && Pricing == 'Concession') {
        } else if(Campaignname == NewConcessionMember) {
            switch on GAUname {
                when  'Joining fee member' {
                    newamount = joiningfee;
                }
                when  'This financial year' {                
                    newamount = (GAUNewMemberMap!= null &&GAUNewMemberMap.containsKey(Currentmonth)? GAUNewMemberMap.get(Currentmonth).Concession__c:0);
                }
                when  'Next financial year' {
                    newamount = Concessionfee - ((GAUNewMemberMap!= null &&GAUNewMemberMap.containsKey(Currentmonth)? GAUNewMemberMap.get(Currentmonth).Concession__c:0));
                }
                when else {
                }
            }
        }
        return newamount;
    }

/*    public decimal CalculateGAUAmount(String GAUname,String Membershiptype){
        system.debug('GAUname '+GAUname + ' '+ Membershiptype);
        integer GAUMonth =0;
        decimal newamount;
        if(GAUname != '' && GAUname != null){
            string Monthname = GAUname.substringbefore('-');
            Monthname = Monthname.replaceAll(' ','');
            GAUMonth = Checkmonthnum(Monthname);
        } 

        integer CurrentMonthnum = Date.Today().Month();
        
        if(CurrentMonthnum >= 7) {
            CurrentMonthnum = CurrentMonthnum - 6;
        } else {
            CurrentMonthnum = CurrentMonthnum + 6;
        }

        string GAUMonthName = GAUname.left(3);
        if(Membershiptype == 'Renewal'){
            newamount = ((GAUNewMemberMap!= null && GAUNewMemberMap.containsKey(GAUMonthName))? GAUNewMemberMap.get(GAUMonthName).Standard__c:0);
            if(GAUMonth < CurrentMonthnum){
                newamount = 60 - newamount;
            }
        } else if(Membershiptype == 'New Sign Up') {
            newamount = ((GAURenewalMemberMap!= null && GAURenewalMemberMap.containsKey(GAUMonthName))? GAURenewalMemberMap.get(GAUMonthName).Standard__c:0);
            if(GAUMonth < CurrentMonthnum){
                newamount = 60 - newamount;
            }
        }
        system.debug('Newamount '+newamount);
        
        
        return newamount;
    } */

    public string Checkmonth(integer intmonth) {
        string currentmonth;

        switch on intmonth {
            when 1 { Currentmonth = 'Jan'; }
            when 2 { Currentmonth = 'Feb'; }
            when 3 { Currentmonth = 'Mar'; }
            when 4 { Currentmonth = 'Apr'; }
            when 5 { Currentmonth = 'May'; }
            when 6 { Currentmonth = 'Jun'; }
            when 7 { Currentmonth = 'Jul'; }
            when 8 { Currentmonth = 'Aug'; }
            when 9 { Currentmonth = 'Sep'; }
            when 10 { Currentmonth = 'Oct'; }
            when 11 { Currentmonth = 'Nov'; }
            when 12 { Currentmonth = 'Dec'; }
            when else {}
        }
        return currentmonth;
    }

/*    public integer Checkmonthnum(string monthname) {
        integer monthnum;

        switch on monthname {
            when 'January' {monthnum = 7; }
            when 'February' {monthnum = 8; }
            when 'March' {monthnum = 9; }
            when 'April' {monthnum = 10; }
            when 'May' {monthnum = 11; }
            when 'June' {monthnum = 12; }
            when 'July' {monthnum = 1; }
            when 'August' {monthnum = 2; }
            when 'September' {monthnum = 3; }
            when 'October' {monthnum = 4; }
            when 'November' { monthnum = 5; }
            when 'December' {monthnum = 6; }
            when else {}
        }
        return monthnum;
    } */
    
}