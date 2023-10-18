public with sharing class BatchCheckForecasting implements Database.Batchable<sObject>, Schedulable {
     public Database.QueryLocator start(Database.BatchableContext bc) {
    	//read all AAkPay__Recurring_Payment__c for create forecast
    	return Database.getQueryLocator([Select a.Id,a.AAkPay__Recurring_Payment_Status__c, a.AAkPay__Next_Payment_Date__c, a.AAkPay__Last_Payment_Date__c, a.AAkPay__Frequency__c, a.AAkPay__Donation_Amount__c, (Select Id, Paid__c, Date__c, Corresponding_Payment_Transaction__c, Recurring_Payment__c, Amount__c From Forecasting__r order by Date__c desc) From AAkPay__Recurring_Payment__c a where a.AAkPay__Recurring_Payment_Status__c='Active']);
    }
    
   public void execute(Database.BatchableContext bc, List<sObject> objs){
   		List<Forecasting__c> newForecastings = new List<Forecasting__c>();
   		for(sObject obj:objs){
   			AAkPay__Recurring_Payment__c rp =(AAkPay__Recurring_Payment__c)obj;
   			//12months future for create forecasting
			Date maxDate = System.today().addYears(1);  			
   			Date startDate = getStartDate(rp);
   			if(startDate<=maxDate){
   				newForecastings.addAll(RecurringPaymentTriggerHandler.createForecastingByDate(rp,startDate,maxDate));
   			}
   		}
   		
   		if(!newForecastings.isEmpty()){
   			insert newForecastings;
   		}
   }
   
   private Date getStartDate(AAkPay__Recurring_Payment__c rp){
   		Date startDate = null;
   		if(rp.Forecasting__r!=null){
   			List<Forecasting__c> forecasts = rp.Forecasting__r;
   			if(!forecasts.isEmpty()){
   				RecurringPaymentTriggerHandler.FrequencyInterval interval =RecurringPaymentTriggerHandler.FREQUENCY_MAP.get(rp.AAkPay__Frequency__c);
   				//first row is the latest forecast
   				startDate = interval.nextPayDate(forecasts[0].Date__c);   				
   				
   			
   			}
   		}
   		
   		if(startDate==null){
   			startDate= rp.AAkPay__Next_Payment_Date__c;
   		}
   		
   		return startDate;
   }
   
   public void execute(SchedulableContext sc) {
  
   		Database.executeBatch(new BatchCheckForecasting(), 200);
   }
   public void finish(Database.BatchableContext bc){
    	//nothing to do for now
   }
}