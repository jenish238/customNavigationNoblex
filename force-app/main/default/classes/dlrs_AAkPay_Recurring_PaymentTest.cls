/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AAkPay_Recurring_PaymentTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AAkPay_Recurring_PaymentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AAkPay__Recurring_Payment__c());
    }
}