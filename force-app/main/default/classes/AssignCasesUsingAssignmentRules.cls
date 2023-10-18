public without sharing class AssignCasesUsingAssignmentRules {
    @InvocableMethod
    public static void CaseAssign(List<Id> CaseIds)
    {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;    
            dmo.EmailHeader.triggerAutoResponseEmail = true;
        	dmo.EmailHeader.triggerUserEmail = true;
            Case cases=[select id from case where case.id in :CaseIds];
            Cases.setOptions(dmo);
            update Cases;
   }
}