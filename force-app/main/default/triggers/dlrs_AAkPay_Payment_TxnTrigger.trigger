/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AAkPay_Payment_TxnTrigger on AAkPay__Payment_Txn__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(AAkPay__Payment_Txn__c.SObjectType);
}