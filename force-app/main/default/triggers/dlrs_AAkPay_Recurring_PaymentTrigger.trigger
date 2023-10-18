/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AAkPay_Recurring_PaymentTrigger on AAkPay__Recurring_Payment__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(AAkPay__Recurring_Payment__c.SObjectType);
}