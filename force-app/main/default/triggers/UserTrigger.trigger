trigger UserTrigger on User (after update) {
    UserTriggerMethods userController = new UserTriggerMethods();
    if(Trigger.isAfter && Trigger.isUpdate){
        userController.populateContactDetailFromUserFields(Trigger.New, Trigger.oldMap);
    } 
}