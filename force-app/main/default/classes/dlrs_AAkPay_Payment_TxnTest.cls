/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AAkPay_Payment_TxnTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AAkPay_Payment_TxnTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AAkPay__Payment_Txn__c());
    }
}