public class PermissionSetCommunityActionMember {
    @InvocableMethod(label='Give Member Permissions' description='')
    public static void healthAssignment(List<String> params) {
    	Set<String> userIDs = new Set<String>();
        for (String s : params) {
        	userIDs.add(s);
        }
        if (system.isBatch()) { //Assume P2U batch
            doAssignmentNow(userIDs);
        }
        else if (!system.isBatch() && !system.isfuture() && !system.isqueueable() && !system.isScheduled()) {
            doAssignment(userIDs); 
        }   
    }
  	@future
    public static void doAssignment(Set<String> stringUserIDs) {
        Set<ID> userIDs = new Set<ID>();
        for(String s : stringUserIDs) {
            userIDs.add(ID.valueOf(s));
        }
        
        List<User> userList = [SELECT ID, Contact.Health_Professional__c FROM User WHERE Contact.Health_Professional__c = TRUE AND ID IN :userIDs];
        for(User u : userList) {
            userIDs.remove(u.ID);
        }
        
        PermissionSet ps = [SELECT ID FROM PERMISSIONSET WHERE Name LIKE '%COMMUNITY_MEMBER%'][0];
        
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
    }
    public static void doAssignmentNow(Set<String> stringUserIDs) {
        Set<ID> userIDs = new Set<ID>();
        for(String s : stringUserIDs) {
            userIDs.add(ID.valueOf(s));
        }
        
        List<User> userList = [SELECT ID, Contact.Health_Professional__c FROM User WHERE Contact.Health_Professional__c = TRUE AND ID IN :userIDs];
        for(User u : userList) {
            userIDs.remove(u.ID);
        }
        
        PermissionSet ps = [SELECT ID FROM PERMISSIONSET WHERE Name LIKE '%COMMUNITY_MEMBER%'][0];
        
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
    }
}