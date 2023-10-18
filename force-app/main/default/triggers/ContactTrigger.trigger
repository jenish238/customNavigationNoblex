trigger ContactTrigger on Contact (after update) {
    ContactTriggerMethods contactController = new ContactTriggerMethods();
	if(trigger.isAfter){
        if(trigger.isUpdate){
            contactController.populateUserDetailFromContactFields(trigger.new, trigger.oldMap);
        }    
    }
}