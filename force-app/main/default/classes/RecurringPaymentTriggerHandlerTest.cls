@isTest
public  class RecurringPaymentTriggerHandlerTest {
	
	@isTest static void createRecurringPayment(){
		Account acc = new Account();
        acc.Name = 'Test Account 001';
        acc.BillingStreet = '007';
        acc.BillingCity = 'Sydney';
        acc.BillingCountry = 'Australia';
        insert acc;
    	Contact c = new Contact();
    	c.FirstName='testF';
    	c.LastName ='testL';
    	c.Email ='test@test.com';
    	c.AccountId=acc.Id;

    	insert c;
    	//Merchant Facility 
    	AAkPay__Payment_Setting__c ps = new AAkPay__Payment_Setting__c();
    	ps.Name ='Test';
    	ps.AAkPay__PayPal_Environment__c='Sandbox';
    	ps.AAkPay__Account_Matching_Method__c='Nonprofit Starter Pack 3+';
    	ps.AAkPay__Automatic_Matching__c='Match and Create New If No Match Found';
    	ps.AAkPay__Currency__c='AUD';
    	ps.AAkPay__Theme__c='redmond';
    	ps.AAkPay__Swatch__c='f';
    	ps.AAkPay__Captcha_Type__c='Im Not a Robot';
    	ps.AAkPay__Captcha_Language__c='English (US) [en]';
    	ps.AAkPay__CAPTCHA_Theme__c='light';
    	ps.AAkPay__Matching_Rules__c='Account + First Name + Last Name;First Name + Last Name + Email;First Name + Last Name + Fundraiser ID;First Name + Last Name + Mobile;First Name + Last Name + Phone;Last Name + Street + Suburb;Membership Id + Last Name;Membership Id + Last Name + Email';
    	ps.AAkPay__Payment_Method__c='Credit Card;Cheque;Bank Transfer;PayPal;Manual;Direct Debit';
    	insert ps;
    	//Payment Form
    	AAkPay__Payment_Type__c pt = new AAkPay__Payment_Type__c();
    	pt.Name ='General Online Donations';
    	pt.AAkPay__Payment_Setting__c=ps.Id;
    	pt.AAkPay__Payment_Type__c='Donation';
    	pt.AAkPay__Payment_Form_Modes__c='External Form';
    	pt.AAkPay__Opportunity_Record_Type__c='Donation';
    	pt.AAkPay__Form_Processing_Actions__c='Contact and Credit Card Update';
    	pt.AAkPay__Enable_CAPTCHA__c=true;
    	pt.AAkPay__Active_Card_Types__c='Visa;MasterCard;American Express';
    	pt.AAkPay__Suggested_Donation_Amt_1__c=20;
    	pt.AAkPay__Suggested_Donation_Amt_2__c=50;
    	pt.AAkPay__Suggested_Donation_Amt_3__c=100;
    	insert pt;
    	
    	AAkPay__Letter__c  letter = new AAkPay__Letter__c ();
        letter.Name = 'Test Letter';
        letter.AAkPay__Letter_Text__c  = 'Hello {!AAkPay__FirstName__c} Thank you for making your payment, your support is very much appreciated.';
        insert letter;
        
        AAkPay__Payment_Txn__c  payment = new AAkPay__Payment_Txn__c();
        payment.AAkPay__Account__c = acc.Id;
        payment.AAkPay__Contact__c = c.Id;
        payment.AAkPay__Receipt_Email__c = c.Email;
        payment.AAkPay__Bank_Deposit_Date__c = System.today().addMonths(-2);
        payment.AAkPay__Receipt_Letter__c = letter.id;
        payment.AAkPay__Status__c = 'Matching Complete';
        payment.AAkPay__Method_of_Payment__c = 'Cash';
        insert payment;
    	
    	AAkPay__Recurring_Payment__c rp = new AAkPay__Recurring_Payment__c();
    	rp.Name='test001';
    	rp.AAkPay__Contact__c = c.Id;
    	rp.AAkPay__Payment_Setting__c=ps.Id;
    	rp.AAkPay__Payment_Type__c=pt.Id;
    	rp.AAkPay__Frequency__c='Monthly';
    	rp.AAkPay__Donation_Amount__c=50;
    	rp.AAkPay__Currency__c='AUD';
    	rp.AAkPay__Recurring_Payment_Status__c='Active';
    	insert rp;
    	rp =[select Id,AAkPay__Next_Payment_Date__c,AAkPay__Frequency__c,AAkPay__Donation_Amount__c from AAkPay__Recurring_Payment__c where Id=:rp.Id];
       	
    	List<Forecasting__c> forcasts = [select Id,Amount__c,Date__c,Recurring_Payment__c,Paid__c from Forecasting__c where Recurring_Payment__c=:rp.Id order by Date__c asc];
    	System.assertEquals(12,forcasts.size());
    	RecurringPaymentTriggerHandler.FrequencyInterval freQ = RecurringPaymentTriggerHandler.FREQUENCY_MAP.get(rp.AAkPay__Frequency__c);
    	Date d = rp.AAkPay__Next_Payment_Date__c;
    	for(Forecasting__c fc:forcasts ){
    		System.assertEquals(fc.Paid__c,false);
    		System.assertEquals(fc.Amount__c,rp.AAkPay__Donation_Amount__c);
    		System.assertEquals(fc.Date__c,d);
    		d = freQ.nextPayDate(d);
    	}
    	//update amount
    	rp.AAkPay__Donation_Amount__c=40;
    	update rp;    	
    	forcasts = [select Id,Amount__c,Date__c,Recurring_Payment__c,Paid__c from Forecasting__c where Recurring_Payment__c=:rp.Id order by Date__c asc];
    	System.assertEquals(12,forcasts.size());
    	freQ = RecurringPaymentTriggerHandler.FREQUENCY_MAP.get(rp.AAkPay__Frequency__c);
    	d = rp.AAkPay__Next_Payment_Date__c;
    	for(Forecasting__c fc:forcasts ){
    		System.assertEquals(fc.Paid__c,false);
    		System.assertEquals(fc.Amount__c,rp.AAkPay__Donation_Amount__c);
    		System.assertEquals(fc.Date__c,d);
    		d = freQ.nextPayDate(d);
    	}
    	
    	//update frequency
    	rp.AAkPay__Frequency__c='Bi-Monthly';
    	update rp;    	
    	forcasts = [select Id,Amount__c,Date__c,Recurring_Payment__c,Paid__c from Forecasting__c where Recurring_Payment__c=:rp.Id order by Date__c asc];
    	System.assertEquals(6,forcasts.size());
    	freQ = RecurringPaymentTriggerHandler.FREQUENCY_MAP.get(rp.AAkPay__Frequency__c);
    	d = rp.AAkPay__Next_Payment_Date__c;
    	for(Forecasting__c fc:forcasts ){
    		System.assertEquals(fc.Paid__c,false);
    		System.assertEquals(fc.Amount__c,rp.AAkPay__Donation_Amount__c);
    		System.assertEquals(fc.Date__c,d);
    		d = freQ.nextPayDate(d);
    	}
    	
    	rp.AAkPay__Frequency__c='Annually';
    	update rp;    	
    	
    	rp.AAkPay__Frequency__c='Fortnightly';
    	update rp;  
    	//update status    	
    	rp.AAkPay__Recurring_Payment_Status__c='Inactive';
    	update rp;  
    	forcasts = [select Id,Amount__c,Date__c,Recurring_Payment__c,Paid__c from Forecasting__c where Recurring_Payment__c=:rp.Id order by Date__c asc];
    	System.assertEquals(0,forcasts.size());
    	
    	rp.AAkPay__Recurring_Payment_Status__c='Active';
    	rp.AAkPay__Frequency__c='Monthly';
    	update rp;  
    	forcasts = [select Id,Amount__c,Date__c,Recurring_Payment__c,Paid__c from Forecasting__c where Recurring_Payment__c=:rp.Id order by Date__c asc];
    	System.assertEquals(12,forcasts.size());
    	
    	delete forcasts;
    	//test batch
    	Test.startTest();    	
	    	BatchCheckForecasting batch=new BatchCheckForecasting();
	    	batch.execute(null);    	
    	Test.stopTest();
    	forcasts = [select Id,Amount__c,Date__c,Recurring_Payment__c,Paid__c from Forecasting__c where Recurring_Payment__c=:rp.Id order by Date__c asc];
    	System.assertEquals(12,forcasts.size());
    	//test create AAkPay__Recurring_Payment_Txn__c link to forecasting
    	AAkPay__Recurring_Payment_Txn__c rpt = new AAkPay__Recurring_Payment_Txn__c();
    	rpt.AAkPay__Donation_Amount__c=40;
    	rpt.AAkPay__Payment_Amount__c=40;
    	rpt.AAkPay__Payment_Txn__c=payment.Id;
    	rpt.AAkPay__Transaction_Date__c=rp.AAkPay__Next_Payment_Date__c;
    	rpt.AAkPay__Recurring_Payment__c=rp.Id;
    	insert rpt;
    	
    	Forecasting__c forcast = [select Id,Corresponding_Payment_Transaction__c,Amount__c,Date__c,Recurring_Payment__c,Paid__c from Forecasting__c where Recurring_Payment__c=:rp.Id and Corresponding_Payment_Transaction__c=:rpt.Id];
    	System.assertEquals(forcast.Paid__c,true);
		System.assertEquals(forcast.Corresponding_Payment_Transaction__c,rpt.Id);	
	}   
}