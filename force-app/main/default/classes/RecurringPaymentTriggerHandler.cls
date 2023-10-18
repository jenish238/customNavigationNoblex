public with sharing class RecurringPaymentTriggerHandler {
    
    public static final Integer FREQUENCY_DAY_TYPE =0;
    public static final Integer FREQUENCY_MONTH_TYPE =1;
    public static final Integer FREQUENCY_YEAR_TYPE =2;
    //public static final Set<String> RECURRINGPAYMENT_STATUS = new Set<String>{''};
    public static final String RECURRINGPAYPEMT_ACTIVE_STATUS = 'Active';
    
    public static final Map<String,FrequencyInterval> FREQUENCY_MAP = new Map<String,FrequencyInterval>{
        'Daily'=>new FrequencyInterval(FREQUENCY_DAY_TYPE,1),
        'Weekly'=>new FrequencyInterval(FREQUENCY_DAY_TYPE,7),
        'Fortnightly'=>new FrequencyInterval(FREQUENCY_DAY_TYPE,14),
        'Monthly'=>new FrequencyInterval(FREQUENCY_MONTH_TYPE,1),
        'Bi-Monthly'=>new FrequencyInterval(FREQUENCY_MONTH_TYPE,2),
        'Quarterly'=>new FrequencyInterval(FREQUENCY_MONTH_TYPE,3),
        'Six Monthly'=>new FrequencyInterval(FREQUENCY_MONTH_TYPE,6),
        'Annually'=>new FrequencyInterval(FREQUENCY_YEAR_TYPE,1),
        'Two Yearly'=>new FrequencyInterval(FREQUENCY_YEAR_TYPE,2)
    
    };
    
    public static void createForecast(List<AAkPay__Recurring_Payment__c> newRegPayments){
        if(newRegPayments!=null && !newRegPayments.isEmpty()){
            List<Forecasting__c> newForecasts = doCreateForeCastObject(newRegPayments);
            
            if(!newForecasts.isEmpty()){
                insert newForecasts;
            }
            
        }
    }
    
    
    
    
    public static List<Forecasting__c> doCreateForeCastObject(List<AAkPay__Recurring_Payment__c> recurringPayments){
        List<Forecasting__c> newForecasts = new List<Forecasting__c>();
        if(recurringPayments!=null && !recurringPayments.isEmpty()){
            
            //12months future for create forecasting
            Date maxDate = System.today().addYears(1);
            for(AAkPay__Recurring_Payment__c rp:recurringPayments){             
                if(rp.AAkPay__Recurring_Payment_Status__c=='Active'){
                    //only status=active then create forecasting                    
                    newForecasts.addAll(createForecastingByDate(rp,rp.AAkPay__Next_Payment_Date__c,maxDate));
                }
            }
            
            
            
        }
        return newForecasts;
    }
    
    public static List<Forecasting__c> createForecastingByDate(AAkPay__Recurring_Payment__c rp,Date startDate,Date endDate){
        List<Forecasting__c> newForecasts = new List<Forecasting__c>();
        if(rp!=null && startDate!=null && endDate!=null){
            if(rp.AAkPay__Recurring_Payment_Status__c=='Active' && String.isNotBlank(rp.AAkPay__Frequency__c)){
                String freqName = rp.AAkPay__Frequency__c;
                FrequencyInterval freqInterval= FREQUENCY_MAP.get(freqName);
                if(freqInterval!=null){
                    Date nextPayDate = startDate;
                    while(nextPayDate<=endDate){
                        newForecasts.add(createForecasting(nextPayDate,rp));
                        nextPayDate = freqInterval.nextPayDate(nextPayDate);
                    }
                }
            }
        }
        return newForecasts;
    }
    
    public static Forecasting__c createForecasting(Date payDate,AAkPay__Recurring_Payment__c rp){
        Forecasting__c fc = new Forecasting__c();
        fc.Date__c=payDate;
        fc.Recurring_Payment__c = rp.Id;
        if(rp.AAkPay__Donation_Amount__c==null){
            fc.Amount__c =0;
        }else{
            fc.Amount__c =rp.AAkPay__Donation_Amount__c;
        }
        //Paid will update to true when recuring payment txn is created
        fc.Paid__c=false;
        return fc;
    }
    
    public static void linkForecastingToRPT(List<AAkPay__Recurring_Payment_Txn__c> lst){
        List<Date> paymentDates = new List<Date>();
        List<Id> rpIds = new List<Id>();
        Map<String, AAkPay__Recurring_Payment_Txn__c> mapRPT = new Map<String,AAkPay__Recurring_Payment_Txn__c>();
        for(AAkPay__Recurring_Payment_Txn__c rpt:lst){
            rpIds.add(rpt.AAkPay__Recurring_Payment__c);
            paymentDates.add(rpt.AAkPay__Transaction_Date__c);
            String key= rpt.AAkPay__Recurring_Payment__c+rpt.AAkPay__Transaction_Date__c.format();
            mapRPT.put(key,rpt);
        }
        
        List<Forecasting__c> updateForecasts = new List<Forecasting__c>();      
        for(Forecasting__c forecast:[select Id,Recurring_Payment__c,Date__c from Forecasting__c where Recurring_Payment__c in :rpIds and Date__c in :paymentDates ]){
            
            String key= forecast.Recurring_Payment__c+forecast.Date__c.format();
            AAkPay__Recurring_Payment_Txn__c rpt = mapRPT.get(key);
            forecast.Corresponding_Payment_Transaction__c=rpt.Id;
            forecast.Paid__c=true;
            updateForecasts.add(forecast);
        }
        if(!updateForecasts.isEmpty()){
            update updateForecasts;
        }
        
    }
    
    public static void updateRecurringPayment(Map<Id,AAkPay__Recurring_Payment__c> mapOld,Map<Id,AAkPay__Recurring_Payment__c> mapNew) {
        if(mapOld!=null && !mapOld.isEmpty()){
            
            List<Id> rpIds = new List<Id>(mapNew.keySet());
            
            Map<Id,List<Forecasting__c>> rpId2Forecasts = new Map<Id,List<Forecasting__c>>();
            for(Forecasting__c forec:  [Select Id,Date__c,Recurring_Payment__c from Forecasting__c where Recurring_Payment__c in :rpIds] ){
                //add only future forecasting
                AAkPay__Recurring_Payment__c rp = mapNew.get(forec.Recurring_Payment__c);
                if(rp.AAkPay__Last_Payment_Date__c<forec.Date__c){
                    List<Forecasting__c> forecs = rpId2Forecasts.get(rp.Id);
                    if(forecs==null){
                        forecs=new List<Forecasting__c>();
                        rpId2Forecasts.put(forec.Recurring_Payment__c,forecs);
                    }
                    forecs.add(forec);
                }
            }
            
            
            List<Forecasting__c> deleteForecasts = new List<Forecasting__c>();
            List<Forecasting__c> updateForecasts = new List<Forecasting__c>();
            List<AAkPay__Recurring_Payment__c> createNewForcasts = new List<AAkPay__Recurring_Payment__c>();
            for(Id rpId:mapNew.keySet()){
                List<Forecasting__c> forecasts = rpId2Forecasts.get(rpId);
                AAkPay__Recurring_Payment__c  rp = mapNew.get(rpId);
                if(forecasts!=null && !forecasts.isEmpty()){                    
                    if(rp.AAkPay__Recurring_Payment_Status__c!='Active'){
                        deleteForecasts.addAll(forecasts);
                    }else{
                        AAkPay__Recurring_Payment__c  oldRp = mapOld.get(rpId);
                        //update future forecast amount
                        if(isChangeAmount(rp,oldRp)){
                            for(Forecasting__c fc:forecasts){
                                fc.Amount__c=rp.AAkPay__Donation_Amount__c;
                            }
                            updateForecasts.addAll(forecasts);
                        }else if(isChangePaymentDate(rp,oldRP)){
                            //delete future forecast when user change payment date
                            deleteForecasts.addAll(forecasts);
                            //re-calculate forecasting again
                            createNewForcasts.add(rp);
                        }
                        
                    }
                }else{
                    //only active recurring payment can create forecast
                    if(rp.AAkPay__Recurring_Payment_Status__c=='Active'){
                        createNewForcasts.add(rp);
                    }
                    
                }
            }
            
            List<Forecasting__c> newForecasts = doCreateForeCastObject(createNewForcasts);
            if(!updateForecasts.isEmpty()){
                update updateForecasts;
            }
            if(!deleteForecasts.isEmpty()){
                delete deleteForecasts;
            }
            if(!newForecasts.isEmpty()){
                insert newForecasts;
            }
            
                
        }
    }

  

    private static boolean isChangeAmount(AAkPay__Recurring_Payment__c newRP,AAkPay__Recurring_Payment__c oldRP){
        
        return oldRP.AAkPay__Donation_Amount__c!=newRP.AAkPay__Donation_Amount__c;
    }
    private static boolean isChangePaymentDate(AAkPay__Recurring_Payment__c newRP,AAkPay__Recurring_Payment__c oldRP){
        
        return (newRP.AAkPay__Frequency__c != oldRP.AAkPay__Frequency__c)||(newRP.AAkPay__Next_Payment_Date__c != oldRP.AAkPay__Next_Payment_Date__c);
    }   
    
    
    
    

 public class FrequencyInterval{
    //0 is day, 1 is Month,2 is Year
    private Integer freqType;
    private Integer freqInterval;
    public FrequencyInterval(Integer freqType,Integer freqInterval){
        this.freqType = freqType;
        this.freqInterval = freqInterval;
    }
    
    public Date nextPayDate(Date currentDate){
        if(this.freqType==FREQUENCY_DAY_TYPE){
            return currentDate.addDays(freqInterval);
        }else if(this.freqType==FREQUENCY_MONTH_TYPE){
            return currentDate.addMonths(freqInterval);
        }       
        return currentDate.addYears(freqInterval);
    }
    
    
 }
 
    
}