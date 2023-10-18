global class CommunityUserBatch implements Database.Batchable<sObject>, schedulable {  
    global CommunityUserBatch() {
    }
    
    global void execute(SchedulableContext SC) {
 		Database.executebatch(new CommunityUserBatch(), 200);
    }
    
    //CommunityUserBatch.start(1); in the execute anonymous window will start the batch at 1am and run it daily
    
    global static void start(integer hour){
        string jobName = 'CommunityUserBatch';
        if (hour == 0) Database.executebatch(new CommunityUserBatch(), 200);
		else {
	    	jobName = jobName += ' - Hourly - ' + datetime.now().format();
	    	string cron = '0 0 ' + string.valueof(hour) + ' * * ?';
	    	//string cron = '0 0 * * * ?';
	    	system.schedule(jobName, cron, new CommunityUserBatch());
     	}
    }
    
    ID caCommunityLogin = [SELECT ID FROM PROFILE WHERE NAME LIKE '%CA Community Login%'][0].ID;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT ID,Name,Email,FirstName,LastName,MailingCity,MailingCountry,MailingPostalCode,MobilePhone,Phone,MailingState,MailingStreet FROM CONTACT WHERE (Community_User__c = NULL AND
                                                                    Current_Member__c = TRUE AND
                                                                    Email != NULL AND
                                                                    FirstName != NULL AND
																	(NOT( EMAIL LIKE '%.uat')))]);
    }

    global void execute(Database.BatchableContext BC, List<Contact> contactList) {
        List<User> userList = new List<User>();
		for(Contact c : contactList) {
            System.debug(c.Name);
            User user = new User();
            if(c.LastName.length() >= 8) {
                user.Alias = c.FirstName.subString(0,1)+c.LastName.subString(0,7);
            }
            else {
                user.Alias = c.LastName;
            }            
            user.City = c.MailingCity;
            if(c.Email.length() >= 40) {
                //user.CommunityNickname = c.Email.subString(0,40);
                user.Username = c.Email.subString(0,40);
            }
            else {
                //user.CommunityNickname = c.Email;
                user.Username = c.Email;
            }
            user.ContactID = c.Id;
            user.Country = c.MailingCountry;
            user.Email = c.Email;
            user.EmailEncodingKey = 'UTF-8';
            user.FirstName = c.FirstName;
            user.LastName = c.LastName;
            user.IsActive = true;
            user.LanguageLocaleKey = 'en_US';
            user.LastName = c.LastName;
            user.LocaleSidKey = 'en_AU';
            user.MobilePhone = c.MobilePhone;
            user.Phone = c.Phone;
            user.State = c.MailingState;
            user.Street = c.MailingStreet;
            user.TimeZoneSidKey = 'Australia/Sydney';
            user.ProfileId = caCommunityLogin;
            user.PostalCode = c.MailingPostalCode;
            user.City = c.MailingCity;
            userList.add(user);
        }
        try{
        	//Database.insert(userList, false);
        	//insert userList;
        	
            Database.SaveResult[] srList = Database.insert(userList, false);
 
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        //System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
               
    }
    
    global void finish(Database.BatchableContext BC) {
		Database.executebatch(new CommunityPermissionSetBatchHealthPro(), 200);
        Database.executebatch(new CommunityPermissionSetBatchMembers(), 200);
  	}
	
}