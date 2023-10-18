/**
 * https://gaeasys.plan.io/issues/15705
 * Test Classes: Receipts_ControllerTest
 */
public with sharing class Receipts_SearchPaymentController {

    @AuraEnabled
    public static List<AAkPay__Payment_Txn__c> updateReceiptPrinted( List<String> paymentIds ) {
        List<AAkPay__Payment_Txn__c> payments = new List<AAkPay__Payment_Txn__c>();
        System.debug('Spd: paymentIds: ' + paymentIds);

        for( String paymentId : paymentIds ) {
            payments.add( new AAkPay__Payment_Txn__c(Id = paymentId, Receipt_Printed__c = true) );
        }
        if( !payments.isEmpty() ) {
            update payments;
        }

        return payments;
    }

    @AuraEnabled
    public static Receipts_Settings__c getSettings() {
        return Receipts_Settings__c.getInstance();
    }

    @AuraEnabled
    public static List<AAkPay__Payment_Type__c> getAllPaymentForms() {
        Receipts_Settings__c settings = Receipts_Settings__c.getInstance();
        Set<String> excludedPaymentForms = new Set<String>();
        if( String.isNotBlank(settings.Payment_Form_Excluded__c) ) {
            for( String nameOrId : settings.Payment_Form_Excluded__c.split(',|\\\n') ) {
                if( String.isNotBlank(nameOrId) ) {
                    excludedPaymentForms.add( nameOrId.trim() );
                }
            }
        }
        
        return [SELECT Id, Name FROM AAkPay__Payment_Type__c WHERE Id NOT IN :excludedPaymentForms AND Name NOT IN :excludedPaymentForms ORDER BY Name];
    }


    @AuraEnabled
    public static List<AAkPay__Payment_Txn__c> searchPayments( String jsonParam ) {
        SearchPaymentParameter param = new SearchPaymentParameter();

        try {
            param = (SearchPaymentParameter) JSON.deserialize(jsonParam, SearchPaymentParameter.class);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        if( String.isBlank(param.fromDate) || String.isBlank(param.toDate) ){
           throw new AuraHandledException('Search FROM Date or TO Date cannot be empty.');
        }

        // srong changed : The Receipt Email field should not be mandatory anymore.
        //if( String.isBlank(accId) && String.isBlank(conId) && String.isBlank(email)){
        //    throw new AuraHandledException('Account and Contact are blanked. Please fill the receipt email instead.');
        //}

        List<AAkPay__Payment_Txn__c> lstPaymentTx = new List<AAkPay__Payment_Txn__c>();
        Receipts_Settings__c settings = Receipts_Settings__c.getInstance();
        List<String> excludedRecordTypeIds = new List<String>();

        System.debug('Spd: settings: ' + settings.Payment_Txn_Record_Type_Excluded__c);
        if( String.isNotBlank(settings.Payment_Txn_Record_Type_Excluded__c) ) {
            for( String devName : settings.Payment_Txn_Record_Type_Excluded__c.split(',|\\\n') ) {
                System.debug('Spd: settings devName ' + devName);
                if( String.isNotBlank(devName) ) {
                    excludedRecordTypeIds.add( devName.trim() );
                }
            }
        }
        
        Set<String> excludedPaymentForms = new Set<String>();
        if( String.isNotBlank(settings.Payment_Form_Excluded__c) ) {
            for( String nameOrId : settings.Payment_Form_Excluded__c.split(',|\\\n') ) {
                if( String.isNotBlank(nameOrId) ) {
                    excludedPaymentForms.add( nameOrId.trim() );
                }
            }
        }

        String query = 'SELECT Id, Name, AAkPay__Status__c, AAkPay__Bank_Deposit_Date__c , AAkPay__Donation_Amount__c, AAkPay__Amount__c, AAkPay__FirstName__c, AAkPay__LastName__c, AAkPay__Contact__c, AAkPay__Contact__r.Name, AAkPay__Banked_Amount__c, AAkPay__Account__c, AAkPay__Account__r.Name,AAkPay__Email__c, AAkPay__Campaign__c, AAkPay__Campaign__r.Name, AAkPay__Contact__r.OwnerId, AAkPay__Contact__r.Owner.Name, Receipt_Printed__c FROM  AAkPay__Payment_Txn__c WHERE (AAkPay__Bank_Deposit_Date__c >= '+ String.escapeSingleQuotes(param.fromDate) + ' AND AAkPay__Bank_Deposit_Date__c <= ' + String.escapeSingleQuotes(param.toDate) + ') ' ;

        query += ' AND AAkPay__Status__c = \'Matching Complete\' ';

        // #17163
        query += ' AND AAkPay__Banked_Payment__c != \'NO\' ';
        
        // #19151#note-2
        //query += ' AND Transaction_Refunded__c != TRUE ';

        if( String.isNotBlank(param.receiptEmail) ) {
            query += ' AND AAkPay__Receipt_Email__c = \''+ String.escapeSingleQuotes(param.receiptEmail) + '\'';
        }

        if( String.isNotBlank(param.contactId) ) {
            query += ' AND AAkPay__Contact__c = \'' + String.escapeSingleQuotes(param.contactId) + '\'';
        }

        if( String.isNotBlank(param.accountId) ) {
            query += ' AND AAkPay__Account__c = \'' + String.escapeSingleQuotes(param.accountId) + '\'';
        }

        if( !excludedRecordTypeIds.isEmpty() ) {
            query += ' AND RecordType.DeveloperName NOT IN :excludedRecordTypeIds ';
        }
        
        if( !excludedPaymentForms.isEmpty() ) {
            query += ' AND AAkPay__Payment_Type__c NOT IN :excludedPaymentForms AND AAkPay__Payment_Type__r.Name NOT IN :excludedPaymentForms ';
        }

        if ( param.receiptPrintedOption == 'NotPrinted' ) {
            query += ' AND Receipt_Printed__c = false ';
        } else if ( param.receiptPrintedOption == 'Printed' ) {
            query += ' AND Receipt_Printed__c = true ';
        }

        System.debug('Spd: isRecurringPayment ' + param.isRecurringPayment);
        if( param.isRecurringPayment == true ) {
            query += ' AND AAkPay__Recurring_Payment__c != null ';
        } else {
            query += ' AND AAkPay__Recurring_Payment__c = null ';
        }

        // Task #16664
        if( String.isNotBlank(param.campaignId) ) {
            query += ' AND AAkPay__Campaign__c = \'' + String.escapeSingleQuotes(param.campaignId) + '\'';
        }

        if( String.isNotBlank(param.paymentTypeId) ) {
            query += ' AND AAkPay__Payment_Type__c = \'' + String.escapeSingleQuotes(param.paymentTypeId) + '\'';
        }

        if( param.amountCharged != null && param.amountCharged > 0 ) {
            query += ' AND AAkPay__Card_Charged_Amount__c > ' + param.amountCharged + '';
        }

        if( String.isNotBlank(param.ownerId) ) {
            query += ' AND AAkPay__Contact__r.OwnerId = \'' + String.escapeSingleQuotes(param.ownerId) + '\'';
        }

        query += ' ORDER BY Name';
        System.debug('Spd:Receipts query ' + query);

        lstPaymentTx = Database.query(query);
        return lstPaymentTx;
    }


    public class SearchPaymentParameter {
        public String accountId;
        
        public String contactId;

        public String campaignId;
        
        public String paymentTypeId;
        
        public Decimal amountCharged;
        
        public String ownerId;
        
        public String receiptEmail;

        public String fromDate; 
        
        public String toDate;

        public String receiptPrintedOption;

        public Boolean isRecurringPayment;
    }
}