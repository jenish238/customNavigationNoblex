/**
 * Test class of controllers :  Receipts_SearchPaymentController && Receipts_PdfController
 *
 */
@isTest
private class Receipts_ControllerTest {
    private static Account acc;
    private static Contact con;
    private static AAkPay__Payment_Txn__c payment ;
    
    private static List<AAkPay__Payment_Txn__c> paymentList;
    
    static void setup(){
    	
    		// Fixed by Noble CX [15/07/2018]
    	
        Receipts_Settings__c newSettings = new Receipts_Settings__c( Payment_Txn_Record_Type_Excluded__c = 'Testing1,2' );
        insert newSettings;
        
        acc = new Account();
        acc.Name = 'Test Account 001';
        acc.BillingStreet = '007';
        acc.BillingCity = 'Sydney';
        acc.BillingCountry = 'Australia';
        insert acc;
        
        con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact 001';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        con.email = 'test@test.com';// Fixed by Noble CX [15/07/2018]
        insert con;
        
        
        AAkPay__Letter__c  letter = new AAkPay__Letter__c ();
        letter.Name = 'Test Letter';
        letter.AAkPay__Letter_Text__c  = 'Hello {!AAkPay__FirstName__c}  Thank you for making your payment of {!AAkPay__Payment_Txn__c.AAkPay__Transaction_Amount__c} and {!AAkPay__Recurring_Payment__c.AAkPay__Donation_Amount__c}, your support is very much appreciated.';
        insert letter;
        
        payment = new AAkPay__Payment_Txn__c();
        payment.AAkPay__Account__c = acc.Id;
        payment.AAkPay__Contact__c = con.Id;
        payment.AAkPay__Receipt_Email__c = con.Email;
        payment.AAkPay__Bank_Deposit_Date__c = System.today().addMonths(-2);
        payment.AAkPay__Receipt_Letter__c = letter.id;
        payment.AAkPay__Status__c = 'Matching Complete';
        payment.AAkPay__Method_of_Payment__c = 'Cash';// Fixed by Noble CX [15/07/2018]
        insert payment;
        
    }
    
    static testMethod void SearchPaymentSuccessTest() {
        
        setup();
        Datetime fromDate = System.today().addMonths(-3);
        String searchFD = fromDate.format('yyyy-MM-dd');
        
        Datetime toDate = System.today();
        String searchTD = toDate.format('yyyy-MM-dd');
        
        Test.startTest();
            try
            {
                Receipts_SearchPaymentController.SearchPaymentParameter param = new Receipts_SearchPaymentController.SearchPaymentParameter();
                param.accountId = acc.Id;
                param.contactId = con.Id;
                param.fromDate = searchFD;
                param.toDate = searchTD;
                param.receiptPrintedOption = 'All';
                List<AAkPay__Payment_Txn__c> paymentList = Receipts_SearchPaymentController.searchPayments(JSON.serialize(param));
                System.assertEquals(1, paymentList.size());

                Receipts_SearchPaymentController.updateReceiptPrinted( new List<String> { String.valueOf(paymentList[0].Id) } );
                
                Receipts_SearchPaymentController.getSettings();
                Receipts_SearchPaymentController.getAllPaymentForms();
            }
            catch(Exception e) 
            {
                System.debug('dsc::error ' + e.getMessage());
            }
        Test.stopTest();
        
    }
    
    static testMethod void SearchPaymentWithNullDateTest() {
        setup();
        
        Test.startTest();
            try
            {
                Receipts_SearchPaymentController.SearchPaymentParameter param = new Receipts_SearchPaymentController.SearchPaymentParameter();
                param.accountId = acc.Id;
                param.contactId = con.Id;
                param.receiptEmail = con.Email;
                param.receiptPrintedOption = 'NotPrinted';
                paymentList = Receipts_SearchPaymentController.searchPayments(JSON.serialize(param));
                System.assertEquals(0, paymentList.size());
            }
            catch(Exception e) 
            {
                System.debug('dsc::error ' + e.getMessage());
            }
        Test.stopTest();
    }
    
    static testMethod void SearchPaymentWithNullAccountContactEmailTest() {
        setup();
        Datetime fromDate = System.today().addMonths(-3);
        String searchFD = fromDate.format('yyyy-MM-dd');
        
        Datetime toDate = System.today();
        String searchTD = toDate.format('yyyy-MM-dd');
        
        Test.startTest();
            try {
                Receipts_SearchPaymentController.SearchPaymentParameter param = new Receipts_SearchPaymentController.SearchPaymentParameter();
                param.fromDate = searchFD;
                param.toDate = searchTD;
                param.receiptPrintedOption = 'Printed';
                paymentList = Receipts_SearchPaymentController.searchPayments(JSON.serialize(param));
                System.assertEquals(0, paymentList.size());
            }
            catch(Exception e) 
            {
                System.debug('dsc::error ' + e.getMessage());
            }
            
        Test.stopTest();
    }
    
    static testMethod void paymentPDFTest() {
        
        setup();
        Test.startTest();
            
            ApexPages.currentPage().getParameters().put('paymentIds', String.valueOf(payment.Id));
            
            Receipts_PdfController pdfController = new Receipts_PdfController();
            Date dt = pdfController.today; 
            
        	pdfController.init();
            Receipts_PdfController.PaymentWrapper[] paymentWrap = pdfController.paymentData;
            
            Receipts_PdfController.getFormulaToFieldSoqlMap('AAkPay__Payment_Txn__c');
            
        Test.stopTest();
        
    }
    
    
}