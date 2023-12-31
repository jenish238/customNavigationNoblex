@isTest 
      public class TestAssignLeadsUsingAssignmentRules{
      static testMethod void createnewlead() {
      User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      
      Test.startTest();    
      Lead leadToCreate =new Lead();
      List<id> Ids= New List<Id>();
      leadToCreate.ownerid= userToCreate.id;
      leadToCreate.LastName ='Gupta';
      leadToCreate.Company='Salesforce';
      leadToCreate.LeadSource='Partner Referral';
      leadToCreate.Rating='';
      leadToCreate.Status='';
      insert leadToCreate; 
      
      Ids.add(leadToCreate.id);
      AssignLeadsUsingAssignmentRules.leadAssign(Ids);
      
      Test.stopTest();
   }
}