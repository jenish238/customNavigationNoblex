trigger RecurringPaymentTrigger on AAkPay__Recurring_Payment__c (after insert, after update) {
    if(trigger.isInsert){
        if(trigger.isAfter){
            RecurringPaymentTriggerHandler.createForecast(trigger.new);
            
        }
    }else if(trigger.isUpdate){
        if(trigger.isAfter){
            RecurringPaymentTriggerHandler.updateRecurringPayment(trigger.oldMap,trigger.newMap);
            
        }
    }
}