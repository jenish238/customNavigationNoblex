@isTest 
      public class TestAssignCasesUsingAssignmentRules{
      static testMethod void createnewcase() {
      User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      
      Test.startTest();    
      Case caseToCreate =new Case();
      List<id> Ids= New List<Id>();
      caseToCreate.ownerid= userToCreate.id;
      caseToCreate.Status='New';
      caseToCreate.Origin='Web';
      insert caseToCreate; 
      
      Ids.add(caseToCreate.id);
      AssignCasesUsingAssignmentRules.caseAssign(Ids);
      
      Test.stopTest();
   }
}