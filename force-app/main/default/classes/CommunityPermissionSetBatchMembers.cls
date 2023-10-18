global class CommunityPermissionSetBatchMembers implements Database.Batchable<sObject>, schedulable {  
    global CommunityPermissionSetBatchMembers() {
    }
    
    global void execute(SchedulableContext SC) {
 		Database.executebatch(new CommunityPermissionSetBatchMembers(), 200);
    }
    
    //CommunityPermissionSetBatchMembers.start(1); in the execute anonymous window will start the batch at 1am and run it daily
    
    global static void start(integer hour){
        string jobName = 'Batch Daily Summary';
        if (hour == 0) Database.executebatch(new CommunityPermissionSetBatchMembers(), 200);
		else {
	    	jobName = jobName += ' - Hourly - ' + datetime.now().format();
	    	string cron = '0 0 ' + string.valueof(hour) + ' * * ?';
	    	//string cron = '0 0 * * * ?';
	    	system.schedule(jobName, cron, new CommunityPermissionSetBatchMembers());
     	}
    }
    
    ID communityPermissionSetHealthPro = [SELECT ID FROM PERMISSIONSET WHERE NAME LIKE '%COMMUNITY_HEALTH%'][0].ID;
    ID communityPermissionSetMember = [SELECT ID FROM PERMISSIONSET WHERE NAME LIKE '%COMMUNITY_MEMBER%'][0].ID;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<ID> psaList = new List<ID>();
        psaList.add(communityPermissionSetHealthPro);
        psaList.add(communityPermissionSetMember);
        return Database.getQueryLocator([SELECT ID FROM user WHERE (UserType = 'PowerPartner' OR UserType = 'CSPLitePortal' OR UserType = 'CustomerSuccess' OR UserType = 'PowerCustomerSuccess') AND
                                                                    Contact.AAkPay__Current_Member__c = 'YES' AND
                                                                    Contact.Health_Professional__c = FALSE AND
                                         							ID NOT IN (SELECT ASSIGNEEID FROM PERMISSIONSETASSIGNMENT WHERE PERMISSIONSETID =: communityPermissionSetMember)]);
    }

    global void execute(Database.BatchableContext BC, List<User> userList) {
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
		for(User u : userList) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = communityPermissionSetMember;
            psa.AssigneeId = u.Id;
            psaList.add(psa);
        }
        Database.insert(psaList, false);
    }
    
    global void finish(Database.BatchableContext BC) {
		
  	}
	
}