public with sharing class CustomNavigationController {

    public List<Submenu__mdt> submenulist = new List<Submenu__mdt>();
    @AuraEnabled
    public static MetadataWrapper getHeaderItems(String recordId){
        try {

            System.debug('recordId>>'+recordId);
            List<Metadata_Object__c> headeritems = new List<Metadata_Object__c>();
            List<Metadata_Object__c> footeritems = new List<Metadata_Object__c>();
            List<Metadata_Object__c> detailitems = new List<Metadata_Object__c>();

            if (recordId != null) {
                headeritems = [SELECT Id, Name,Show_Visibility__c, Metadata_Object__c, URL__c, Order__c,isactive__c,(SELECT id,Name,Show_Visibility__c,URL__c,isactive__c,order__c FROM Metadata_Objects__r ORDER BY Order__c ASC) FROM Metadata_Object__c WHERE  recordtype.name = 'Header Item' AND id =: recordId ORDER BY Order__c ASC];
                System.debug('headeritems----->'+ headeritems);
                footeritems = [SELECT Id, Name, Show_Visibility__c,Metadata_Object__c, URL__c, Order__c,isactive__c FROM Metadata_Object__c WHERE recordtype.name = 'Footer Item' AND id =: recordId ORDER BY Order__c ASC];
                System.debug('footeritems----->'+footeritems);
                detailitems = [SELECT Id, Name,Show_Visibility__c, Metadata_Object__c, URL__c, Order__c,isactive__c FROM Metadata_Object__c WHERE recordtype.name = 'Footer Detail Item' AND id =: recordId ORDER BY Order__c ASC];
                System.debug('detailitems------->'+detailitems);
            }else{
                headeritems = [SELECT Id, Name,Show_Visibility__c, Metadata_Object__c, URL__c, Order__c,isactive__c,(SELECT id,Name,Show_Visibility__c,URL__c,isactive__c,order__c FROM Metadata_Objects__r ORDER BY Order__c ASC) FROM Metadata_Object__c WHERE Metadata_Object__c = null AND recordtype.name = 'Header Item' ORDER BY Order__c ASC];
                footeritems = [SELECT Id, Name, Show_Visibility__c,Metadata_Object__c, URL__c, Order__c,isactive__c FROM Metadata_Object__c WHERE Metadata_Object__c = null AND recordtype.name = 'Footer Item' ORDER BY Order__c ASC];
                detailitems = [SELECT Id, Name,Show_Visibility__c, Metadata_Object__c, URL__c, Order__c,isactive__c FROM Metadata_Object__c WHERE Metadata_Object__c = null AND recordtype.name = 'Footer Detail Item' ORDER BY Order__c ASC];
            }
            
            
            

            Map<String,String> usrMap = new Map<String,String>();
            Map<String,String> usrfooterMap = new Map<String,String>();
            Map<String,String> usrfooterdetailMap = new Map<String,String>();
            List<User> usrlst = new List<User>();
            List<User> usrfooterlst = new List<User>();
            List<User> usrfooterdetaillst = new List<User>();
            List<String> names = new List<String>();
            List<String> footernames = new List<String>();
            List<String> footerdetailnames = new List<String>();
            if(headeritems != null && headeritems.size() > 0 && String.isNotBlank(headeritems[0].Show_Visibility__c))
            names = (headeritems[0].Show_Visibility__c).split(',\\s*');


            System.debug('names----->'+names);

            if(footeritems != null && footeritems.size() > 0 && String.isNotBlank(footeritems[0].Show_Visibility__c))
            footernames = (footeritems[0].Show_Visibility__c).split(',\\s*');
            if(detailitems != null && detailitems.size() > 0 && String.isNotBlank(detailitems[0].Show_Visibility__c))
            footerdetailnames = (detailitems[0].Show_Visibility__c).split(',\\s*');
            // System.debug('names<<<'+names);
            usrlst = [SELECT ID,NAME,username FROM USER WHERE username IN: names];    
            System.debug('usrlst<?????'+usrlst);        
            usrfooterlst = [SELECT ID,NAME,username FROM USER WHERE username IN: footernames];            
            System.debug('usrfooterlst<?????'+usrfooterlst);
            usrfooterdetaillst = [SELECT ID,NAME,username FROM USER WHERE username IN: footerdetailnames];            
            System.debug('usrfooterdetaillst<?????'+usrfooterdetaillst);
            for(User u : usrlst){
                if(!usrMap.containsKey(u.username)){
                    usrMap.put(u.username,u.name);
                }                
            }         
            for(User u : usrfooterlst){
                if(!usrfooterMap.containsKey(u.username)){
                    usrfooterMap.put(u.username,u.name);
                }                
            }         
            for(User u : usrfooterdetaillst){
                if(!usrfooterdetailMap.containsKey(u.username)){
                    usrfooterdetailMap.put(u.username,u.name);
                }                
            }         
            System.debug('usrMap 111>>>'+usrMap);                                                            
            String replacedString = '';            
            String replacedfooterString = '';            
            String replacedfooterdetailString = '';            

            for(String s : names){
                System.debug('s>>'+s);                                                
                String username = usrMap.get(s);
                System.debug('username>>>>,<<<'+username);
                if (username != null) {
                    if (String.isNotBlank(replacedString)) {
                        replacedString += ',';
                    }
                    replacedString += username;                            
                }
                else{
                    if(String.isNotBlank(s)){
                        replacedString += ',';
                    }
                    replacedString += s;
                }
                System.debug('replacedString>>'+replacedString);
                replacedString = replacedString.trim();
                if(replacedString.startsWith(',')){
                    replacedString = replacedString.substring(1);
                }
                else if(replacedString.endsWith(',')) {
                    replacedString = replacedString.substring(0, replacedString.length() - 1);
                }                    
            }


            //For Footer
            for(String s : footernames){
                System.debug('s>>'+s);                                                
                String username = usrfooterMap.get(s);
                if (username != null) {
                    if (String.isNotBlank(replacedfooterString)) {
                        replacedfooterString += ',';
                    }
                    replacedfooterString += username;                            
                }
                else{
                    if(String.isNotBlank(s)){
                        replacedfooterString += ',';
                    }
                    replacedfooterString += s;
                }
                System.debug('replacedfooterString>>'+replacedfooterString);
                replacedfooterString = replacedfooterString.trim();
                if(replacedfooterString.startsWith(',')){
                    replacedfooterString = replacedfooterString.substring(1);
                }
                else if(replacedfooterString.endsWith(',')) {
                    replacedfooterString = replacedfooterString.substring(0, replacedfooterString.length() - 1);
                }                    
            }



            //For footer detail

            for(String s : footerdetailnames){
                System.debug('s>>'+s);                                                
                String username = usrfooterdetailMap.get(s);
                if (username != null) {
                    if (String.isNotBlank(replacedfooterdetailString)) {
                        replacedfooterdetailString += ',';
                    }
                    replacedfooterdetailString += username;                            
                }
                else{
                    if(String.isNotBlank(s)){
                        replacedfooterdetailString += ',';
                    }
                    replacedfooterdetailString += s;
                }
                System.debug('replacedfooterdetailString>>'+replacedfooterdetailString);
                replacedfooterdetailString = replacedfooterdetailString.trim();
                if(replacedfooterdetailString.startsWith(',')){
                    replacedfooterdetailString = replacedfooterdetailString.substring(1);
                }
                else if(replacedfooterdetailString.endsWith(',')) {
                    replacedfooterdetailString = replacedfooterdetailString.substring(0, replacedfooterdetailString.length() - 1);
                }                    
            }

            MetadataWrapper wrapper = new MetadataWrapper();
            wrapper.headerList = headeritems;
            wrapper.footerList = footeritems;
            wrapper.detailList = detailitems;
            wrapper.headerstr = replacedString;
            wrapper.footerstr = replacedfooterString;
            wrapper.footerdetailstr = replacedfooterdetailString;
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Metadata_Object__c> getsubmenuItems(String headerId){
        try {
            System.debug('headerId>>'+headerId);
            List<Metadata_Object__c> submenuitems = new List<Metadata_Object__c>();                                                
            submenuitems = [SELECT Id, Name, Metadata_Object__c, URL__c, Order__c,isactive__c FROM Metadata_Object__c WHERE Metadata_Object__c =:headerId ORDER BY Order__c ASC];
            return submenuitems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Metadata_Object__c> getHeaderItemsMenu(String headerId){
        try {
            System.debug('headerId>>'+headerId);
            List<Metadata_Object__c> headeritems = new List<Metadata_Object__c>();                                                
            headeritems = [SELECT Id, Name, Metadata_Object__c, URL__c, Order__c,isactive__c,(SELECT id,Name,URL__c,isactive__c,order__c FROM Metadata_Objects__r ORDER BY Order__c ASC) FROM Metadata_Object__c WHERE Metadata_Object__c = null AND recordtype.name = 'Header Item' ORDER BY Order__c ASC];
            return headeritems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Metadata_Object__c> getFooterItemsMenu(String headerId){
        try {
            System.debug('headerId>>'+headerId);
            List<Metadata_Object__c> footeritems = new List<Metadata_Object__c>();                                                
            footeritems = [SELECT Id, Name, Metadata_Object__c, URL__c, Order__c,isactive__c FROM Metadata_Object__c WHERE Metadata_Object__c = null AND recordtype.name = 'Footer Item' ORDER BY Order__c ASC];
            return footeritems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Metadata_Object__c> getFooterItemsPolicyMenu(String headerId){
        try {
            System.debug('headerId>>'+headerId);
            List<Metadata_Object__c> detailitems = new List<Metadata_Object__c>();                                                
            detailitems = [SELECT Id, Name, Metadata_Object__c, URL__c, Order__c,isactive__c FROM Metadata_Object__c WHERE Metadata_Object__c = null AND recordtype.name = 'Footer Detail Item' ORDER BY Order__c ASC];
            return detailitems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    // public static String insertMenuItems(List<Metadata_Object__c> newLst,String menuId,String removeMetaIds) {
        public static List<Metadata_Object__c> insertMenuItems(Object newLst,String menuId,String removeMetaIds) {

        try{    
            System.debug('removeMetaIds>>'+removeMetaIds);
            System.debug('size>>'+newLst);
            List<Metadata_Object__c> updateRecords = (List<Metadata_Object__c>) JSON.deserialize(JSON.serialize(newLst), List<Metadata_Object__c>.class);            

            System.debug('updateRecords>>'+updateRecords);
            List<Metadata_Object__c> deleteMetadata = new List<Metadata_Object__c>();
            List<Metadata_Object__c> newMetadata = new List<Metadata_Object__c>();
            if(String.isNotBlank(removeMetaIds)){
                List<Id> metaIds = removeMetaIds.split(',');
                deleteMetadata = [SELECT Id FROM Metadata_Object__c WHERE Id IN :metaIds];
            }
            

            if(updateRecords != null && !updateRecords.isEmpty()){
                System.debug('in if>>');
                for(Metadata_Object__c meta : updateRecords){
                    System.debug('meta>>'+meta);
                    for(Metadata_Object__c submeta : meta.Metadata_Objects__r){
                        continue;
                    }
                    if(String.isNotBlank(menuId)){

                        meta.Metadata_Object__c = menuId;
                    }
                }
                upsert updateRecords;


            }
 
            if(deleteMetadata != null && !deleteMetadata.isEmpty()){    
                delete deleteMetadata;
            }


            System.debug('newLst>>'+newLst);
            
            return updateRecords;

        }catch(Exception e){
            System.debug('e>>>'+e);
            System.debug('e line>>>'+e.getLineNumber());
            return null;

        }

    }

    @AuraEnabled 
    public static String insertMainMenuItems(String newLst,String menuId,String removeMetaIds,String selectednav) {
        
        try{        
                    
            Id clinicRecordTypeId;

            if(selectednav == 'Header Menu'){
                clinicRecordTypeId = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Header Item').getRecordTypeId();
            }
            else if(selectednav == 'Footer Resources Menu'){
                clinicRecordTypeId = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Footer Item').getRecordTypeId();
            }
            else if(selectednav == 'Footer Policy Menu'){
                clinicRecordTypeId = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Footer Detail Item').getRecordTypeId();
            }
            List<Metadata_Object__c> updateRecords = new List<Metadata_Object__c>();            

            List<Object> items = (List<Object>) JSON.deserializeUntyped(newLst);
            for (Object itemObj : items) {
                Map<String, Object> item = (Map<String, Object>) itemObj;                
                Metadata_Object__c obj = new Metadata_Object__c();
                obj.Id = (String)item.get('Id');
                obj.Name = (String)item.get('Name');                    
                obj.IsActive__c  =  (Boolean)item.get('IsActive__c');            
                obj.Order__c = Double.valueOf(item.get('Order__c'));
                obj.URL__c = (String)item.get('URL__c');                            
                obj.RecordTypeId = clinicRecordTypeId;                            
                updateRecords.add(obj);                
            }
            
            List<Metadata_Object__c> deleteMetadata = new List<Metadata_Object__c>();            
            if(String.isNotBlank(removeMetaIds)){
                List<Id> metaIds = removeMetaIds.split(',');
                deleteMetadata = [SELECT Id FROM Metadata_Object__c WHERE Id IN :metaIds];
            }
            

            if(updateRecords != null && !updateRecords.isEmpty()){            
                System.debug('updateRecords>>'+updateRecords);
                upsert updateRecords;
            }
   
            if(deleteMetadata != null && !deleteMetadata.isEmpty()){    
                delete deleteMetadata;
            }
                                 
            return selectednav;

        }catch(Exception e){
            System.debug('e>>>'+e);
            System.debug('e line>>>'+e.getLineNumber());
            return e.getMessage() +'---'+e.getLineNumber();

        }

    }

    @AuraEnabled
    public static ResultWrapper searchUsersName(String selected , String key){

        ResultWrapper reswrp = new ResultWrapper();
        // if(selected == 'Profile'){
            // key = '%' + key + '%';        
            List<Profile> getProfileList = [SELECT Id, Name FROM Profile];
            reswrp.Profilelst = getProfileList;
            // return reswrp;
        // }
        // else{

            // key = '%' + key + '%';        
            List<User> getUserList = [SELECT Id, Name,Username, Email FROM USER WHERE isActive=TRUE];            
            reswrp.Userlst = getUserList;
            return reswrp;
        // }
    }
        @AuraEnabled
            public static User UserData(String selectednav){
                    List<User> userInformation = [SELECT id,Username,profile.name FROM user WHERE id =: UserInfo.getUserId()];
                    return userInformation[0];
            }




        @AuraEnabled
        public static List<ResultWrapper> saveSelectedValues(String selectedvalues , String selectednav, String recordid){


            try {
                            List<ResultWrapper> resWrplst = new List<ResultWrapper>();
                        Id clinicRecordTypeId;
                        System.debug('selectedvalues>>'+selectedvalues);
                        System.debug('selectednav>>'+selectednav);
                        System.debug('recordid---->'+ recordid);
                                
                        List<String> names = selectedvalues.split(',\\s*');

                        System.debug('names----->'+ names);
                
                        String query = 'SELECT Id,Name,Metadata_Object__c,Show_Visibility__c FROM Metadata_Object__c WHERE ';
                        if(selectednav == 'Header Menu'){
                            clinicRecordTypeId = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Header Item').getRecordTypeId();            
                            query += 'RecordTypeId=:clinicRecordTypeId';
                        }
                        else if(selectednav == 'Footer Resources Menu'){
                            clinicRecordTypeId = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Footer Item').getRecordTypeId();            
                            query += 'RecordTypeId=:clinicRecordTypeId';
                        }
                        else if(selectednav == 'Footer Policy Menu'){
                            clinicRecordTypeId = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Footer Detail Item').getRecordTypeId();            
                            query += 'RecordTypeId=:clinicRecordTypeId';
                        }

                        query += ' AND Id=:recordid';
                        System.debug('query----->'+query);
                        Map<String,String> usrMap = new Map<String,String>();
                        List<User> usrlst = new List<User>();
                        usrlst = [SELECT ID,NAME,username FROM USER WHERE Name IN: names];

                        System.debug('usrlst--->'+usrlst);
                        for(User u : usrlst){
                            if(!usrMap.containsKey(u.Name)){
                                usrMap.put(u.name,u.username);
                            }
                            // usrMap.get(u.name);
                        }
                        List<Metadata_Object__c> metalst = Database.query(query);

                        System.debug('metalst-------->'+metalst);
                        String str = '';
                        
                        for(Metadata_Object__c meta : metalst){
                            // meta.Show_Visibility__c = selectedvalues;
                            List<String> lststr = new List<String>();
                            System.debug('String.isNotBlank(selectedvalues)----->'+String.isNotBlank(selectedvalues));
                            if(String.isNotBlank(selectedvalues)){
                                lststr = selectedvalues.split(',');
                            }else if (lststr.size() == 0 && !String.isNotBlank(selectedvalues)) {
                                meta.Show_Visibility__c = '';
                            }
                            String replacedString = '';

                            System.debug('lststr----->'+lststr);
                            for(String s : lststr){

                                System.debug('s>>'+s);
                                ResultWrapper reswrap = new ResultWrapper();
                                reswrap.Name = s;
                                resWrplst.add(reswrap);
                                String username = usrMap.get(s);
                                if (username != null) {
                                    if (String.isNotBlank(replacedString)) {
                                        replacedString += ',';
                                    }
                                    replacedString += username;                            
                                }
                                else{
                                    if(String.isNotBlank(s)){
                                        replacedString += ',';
                                    }
                                    replacedString += s;
                                }
                                System.debug('replacedString>>'+replacedString);
                                replacedString = replacedString.trim();
                                if(replacedString.startsWith(',')){
                                    replacedString = replacedString.substring(1);
                                }
                                else if(replacedString.endsWith(',')) {
                                    replacedString = replacedString.substring(0, replacedString.length() - 1);
                                }
                            meta.Show_Visibility__c = replacedString;
                        }
                    }


                    System.debug('metalst---->'+metalst);
                    update metalst;                
                    System.debug('metalst Updatre --->'+metalst);
                    return resWrplst;   
            } catch (Exception e) {
                System.debug('e------>'+e.getMessage());
                return null;
            }
        
    
    }

 


    public class MetadataWrapper {
        @AuraEnabled
        public List<Metadata_Object__c> headerList { get; set; }
        
        @AuraEnabled
        public List<Metadata_Object__c> footerList { get; set; }

        @AuraEnabled
        public List<Metadata_Object__c> detailList { get; set; }

        @AuraEnabled
        public String headerstr { get; set; }

        @AuraEnabled
        public String footerstr { get; set; }

        @AuraEnabled
        public String footerdetailstr { get; set; }
    }

    public class ResultWrapper {        

        @AuraEnabled
        public List<Profile> Profilelst { get; set; }

        @AuraEnabled
        public List<User> Userlst { get; set; }

        @AuraEnabled
        public List<String> recipientslst { get; set; }

        @AuraEnabled
        public String Name { get; set; }
    }

    public class UserWrapper {        

        @AuraEnabled
        public Boolean headerbool { get; set; }

        @AuraEnabled
        public Boolean footerbool { get; set; }

        @AuraEnabled
        public Boolean footerdetailbool { get; set; }

         @AuraEnabled
        public User UserInfo { get; set; }

    }
}