@isTest
private class ContactTriggerMethods_Tests {
    static testMethod void testPopulateUserDetailFromContactFields(){
        Contact con = new Contact();
        con.Salutation = 'Mr.';
        con.FirstName = 'fnTest';
        con.LastName = 'lnTest';
        con.Phone = '0123456789';
        con.MobilePhone = '0987654321';
        con.Email = 'emailtest@example.com';
        con.MailingStreet = '271';
        con.MailingCity = 'T';
        con.MailingCountry = 'Australia';

        insert con;
         
        User adminProfileIds =[SELECT Id FROM User where Id =: userInfo.getUserId()
                              LIMIT 1];
        System.runAs(adminProfileIds){
			List<Profile> profileIds = new ContactTriggerMethods().getUserProfileCommunities('CA Community Login').values();
            
            User userTest =new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email ='user@example.com', 
                             Username = 'user@example.com', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias ='test123', 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US',
                             ProfileId = profileIds[0].Id,
                             ContactId = con.Id
                            );         
            insert userTest;
            
            Test.startTest();
           		 	
                userTest.FirstName = 'dscTest';
                userTest.email ='user1@example.com';
            	update userTest;
            	
                con.FirstName = 'dscTest';
                con.Email = 'dsctest@example.com';
            	con.MailingStreet = '371';
        		con.MailingCity = 'T';
        		con.MailingCountry = 'Australia';
                update con;
            	
            Test.stopTest();
            
            List<User> lstUser = [SELECT Id, FirstName FROM User WHERE ContactId = :con.Id];
            System.assertEquals(con.FirstName, lstUser[0].FirstName);  
        }
    }
    
}