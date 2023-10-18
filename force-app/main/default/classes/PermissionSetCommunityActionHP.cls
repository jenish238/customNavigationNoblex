public class PermissionSetCommunityActionHP implements Queueable {
    @InvocableMethod(label='Give Health Professional Permissions' description='')
    public static void healthAssignment(List<String> params) {
    	Set<String> userIDs = new Set<String>();
        for (String s : params) {
        	userIDs.add(s);
        }
        System.enqueueJob(new PermissionSetCommunityActionHP(userIDs));
        //if (system.isBatch()) { //Assume P2U batch
        //    doAssignmentNow(userIDs);
        //}
        //else if (!system.isBatch() && !system.isfuture() && !system.isqueueable() && !system.isScheduled()) {
        //    doAssignment(userIDs); //
        //}  
    }
    private Set<String> userIDs;
    public PermissionSetCommunityActionHP(Set<String> userIDs) {
        this.userIDs = userIDs;
    }
    public void execute(QueueableContext context) {
        doAssignmentNow(userIDs);
    }
  	@future
    public static void doAssignment(Set<String> stringUserIDs) {
        Set<ID> userIDs = new Set<ID>();
        for(String s : stringUserIDs) {
            userIDs.add(ID.valueOf(s));
        }
        PermissionSet ps = [SELECT ID FROM PERMISSIONSET WHERE Name LIKE '%COMMUNITY_HEALTH_PROFESSIONAL%'][0];
        PermissionSet psMember = [SELECT ID FROM PERMISSIONSET WHERE Name LIKE '%COMMUNITY_MEMBER%'][0];
        List<PermissionSetAssignment> psaCurrentList = [SELECT ID, AssigneeID, PermissionSetID FROM PermissionSetAssignment WHERE PermissionSetID =: ps.Id AND AssigneeID IN :userIDs];
        for(PermissionSetAssignment psa : psaCurrentList) {
            userIDs.remove(psa.assigneeID+'');
        }
        List<PermissionSetAssignment> psaNewList = new List<PermissionSetAssignment>();
        for(ID s : userIDs) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = s;
            psa.PermissionSetID = ps.Id;
            psaNewList.add(psa);
        }
        insert psaNewList;
        //List<PermissionSetAssignment> psaMemberCurrentList = [SELECT ID, AssigneeID, PermissionSetID FROM PermissionSetAssignment WHERE PermissionSetID =: psMember.Id AND AssigneeID IN :userIDs];
        //delete psaMemberCurrentList;
    }
    public static void doAssignmentNow(Set<String> stringUserIDs) {
        Set<ID> userIDs = new Set<ID>();
        for(String s : stringUserIDs) {
            userIDs.add(ID.valueOf(s));
        }
        PermissionSet ps = [SELECT ID FROM PERMISSIONSET WHERE Name LIKE '%COMMUNITY_HEALTH_PROFESSIONAL%'][0];
        PermissionSet psMember = [SELECT ID FROM PERMISSIONSET WHERE Name LIKE '%COMMUNITY_MEMBER%'][0];
        List<PermissionSetAssignment> psaCurrentList = [SELECT ID, AssigneeID, PermissionSetID FROM PermissionSetAssignment WHERE PermissionSetID =: ps.Id AND AssigneeID IN :userIDs];
        for(PermissionSetAssignment psa : psaCurrentList) {
            userIDs.remove(psa.assigneeID+'');
        }
        List<PermissionSetAssignment> psaNewList = new List<PermissionSetAssignment>();
        for(ID s : userIDs) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = s;
            psa.PermissionSetID = ps.Id;
            psaNewList.add(psa);
        }
        //Database.insert(psaNewList, false);
        insert psaNewList;
        //List<PermissionSetAssignment> psaMemberCurrentList = [SELECT ID, AssigneeID, PermissionSetID FROM PermissionSetAssignment WHERE PermissionSetID =: psMember.Id AND AssigneeID IN :userIDs];
        //delete psaMemberCurrentList;
    }
}