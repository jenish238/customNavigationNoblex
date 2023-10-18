trigger CaseTrigger on Case (after insert) {
    List<ID> cases = new List<ID>();
    for(Case c : Trigger.New) {
        cases.add(c.ID);
    }
    AssignCasesUsingAssignmentRules.CaseAssign(cases);
}