@isTest
private class UserTriggerMethods_Tests {
	static testMethod void testPopulateContactDetailFromUserFields(){
        Contact con = new Contact();
        con.Salutation = 'Mr.';
        con.FirstName = 'fnTest';
        con.LastName = 'lnTest';
        con.Phone = '0123456789';
        con.MobilePhone = '0477777777';
        con.Email = 'test1000@example.com';
        con.MailingStreet = '1 Street';
        con.MailingCity = 'Sydney';
        con.MailingCountry = 'Australia';
        insert con;
 
        User adminProfileIds =[SELECT Id FROM User where Id =: userInfo.getUserId()
                              LIMIT 1];
      	User userTest;
        System.runAs(adminProfileIds){
            Profile profileIds =[SELECT Id,Name, UserLicenseId FROM Profile where 
                                 Name = 'CA Community Login'
                                 AND UserLicenseId  in 
                             (SELECT Id FROM UserLicense where name ='Customer Community Login') 
                             LIMIT 1];

           userTest =new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email ='user@example.com', 
                             Username = 'user@example.com', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias ='test123', 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US',
                             ProfileId = profileIds.Id,
                             ContactId = con.Id
                            );         
       
            insert userTest;
            
            Test.startTest();
            userTest.City = 'TestTest';
            update userTest;
          	  Contact con1 = new contact();
            	con1.id = con.Id;
                con1.Salutation = 'Mr1';
                con1.FirstName = 'ABC';
                con1.LastName = 'lnTest1';
                con1.Phone = '01234567891';
                con1.MobilePhone = '09876543211';
                con1.Email = 'emailtest@example.com';
                con1.MailingStreet = '2711';
                con1.MailingCity = 'TestTest';
                con1.MailingCountry = 'Australia';
            update con1;
        		
            Test.stopTest();
            
            List<Contact> lstContact = [SELECT Id, FirstName FROM Contact WHERE Id = :userTest.ContactId];
            System.assertEquals(userTest.FirstName, lstContact[0].FirstName);  
        }
   }  
}