trigger RecurringPaymentTxnTrigger on AAkPay__Recurring_Payment_Txn__c (after insert) {
    if(trigger.isInsert){
        if(trigger.isAfter){
            RecurringPaymentTriggerHandler.linkForecastingToRPT(trigger.new);
        }
    }
}