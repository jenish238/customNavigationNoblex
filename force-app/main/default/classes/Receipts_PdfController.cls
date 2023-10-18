/**
 * https://gaeasys.plan.io/issues/15705
 * Test Classes: Receipts_ControllerTest
 */
public with sharing class Receipts_PdfController {
    public List<PaymentWrapper> paymentData {get; private set;} { paymentData = new List<PaymentWrapper>(); }
    public Date today {get; set;} { today = System.today(); }
    public Receipts_PdfController() {
        String paymentIdsCsv = ApexPages.currentPage().getParameters().get('paymentIds');
        // System.debug('Spd init paymentIdsCsv ' + paymentIdsCsv);
        paymentIdsCsv = String.escapeSingleQuotes(paymentIdsCsv);
        Map<String, String> fieldMap = getFormulaToFieldSoqlMap('AAkPay__Payment_Txn__c');
        // for( String fomula : fieldMap.keySet() ) {
            // System.debug('Spd fomula ' + fomula + ' => ' + fieldMap.get(fomula) );
        // }
        String soqlString = 'SELECT ' + String.join(fieldMap.values(), ', ') + ' FROM AAkPay__Payment_Txn__c WHERE Id IN (\'' + String.join( paymentIdsCsv.split(','), '\', \'' ) + '\') ORDER BY Name ';
        //System.debug('Spd soqlString ' + soqlString);
        this.mDebugUntruncated('Spd soqlString ' + soqlString);
        List<AAkPay__Payment_Txn__c> payments = Database.query(soqlString);
        System.debug('Spd: payments ' + payments.size());
        List<Id> paymentFormIds = new List<Id>();
        List<Id> merchantFacilityIds = new List<Id>();
        List<Id> LetterIds = new List<Id>();
        for( AAkPay__Payment_Txn__c onePayment : payments ) {
            if( onePayment.AAkPay__Payment_Type__c != null) {
                paymentFormIds.add( onePayment.AAkPay__Payment_Type__c );
            }
            if( onePayment.AAkPay__Payment_Setting__c != null ) {
                merchantFacilityIds.add( onePayment.AAkPay__Payment_Setting__c );
            }
            if( onePayment.AAkPay__Receipt_Letter__c != null ) {
                letterIds.add( onePayment.AAkPay__Receipt_Letter__c );
            }
        }
        Map<Id, ContentDocumentLink> paymentFormIdMapToContentDocumentLink = new Map<Id, ContentDocumentLink>();
        System.debug('Spd: paymentFormIds ' + paymentFormIds);
        if( !paymentFormIds.isEmpty() ) {
            for( ContentDocumentLink link : [SELECT Id, 
                    LinkedEntityId, 
                    ContentDocumentId, 
                    ContentDocument.LatestPublishedVersionId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :paymentFormIds AND ContentDocument.Title LIKE '%letterhead%'] ) {
                paymentFormIdMapToContentDocumentLink.put( link.LinkedEntityId, link );
            }
        }
        Map<Id, ContentDocumentLink> merchantFacilityIdMapToContentDocumentLink = new Map<Id, ContentDocumentLink>();
        System.debug('Spd: merchantFacilityIds ' + merchantFacilityIds);
        if( !merchantFacilityIds.isEmpty() ) {
            for( ContentDocumentLink link : [SELECT Id, 
                    LinkedEntityId, 
                    ContentDocumentId, 
                    ContentDocument.LatestPublishedVersionId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :merchantFacilityIds AND ContentDocument.Title LIKE '%letterhead%'] ) {
                merchantFacilityIdMapToContentDocumentLink.put( link.LinkedEntityId, link );
            }
        }
        
        Map<Id, ContentDocumentLink> letterIdMapToContentDocumentLink = new Map<Id, ContentDocumentLink>();
        System.debug('Spd: letterIds ' + letterIds);
        if( !letterIds.isEmpty() ) {
            for( ContentDocumentLink link : [SELECT Id, 
                    LinkedEntityId, 
                    ContentDocumentId, 
                    ContentDocument.LatestPublishedVersionId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :letterIds AND ContentDocument.Title LIKE '%letterhead%'] ) {
                letterIdMapToContentDocumentLink.put( link.LinkedEntityId, link ); 
            }
        }
        for( AAkPay__Payment_Txn__c onePayment : payments ) {
            // paymentForm letterhead will replace the merchantFacility letterhead
            paymentData.add( new PaymentWrapper(onePayment)
                .setLetterheadUrlWithCorrectLink( merchantFacilityIdMapToContentDocumentLink.get(onePayment.AAkPay__Payment_Setting__c) )
                .setLetterheadUrlWithCorrectLink( paymentFormIdMapToContentDocumentLink.get(onePayment.AAkPay__Payment_Type__c) )
                .setLetterheadUrlWithCorrectLink( letterIdMapToContentDocumentLink.get(onePayment.AAkPay__Receipt_Letter__c) )
                .replaceLetterTextWithFieldMapping(fieldMap) );
        }
        System.debug('Spd: URL.getSalesforceBaseUrl() ' + URL.getSalesforceBaseUrl().getHost() );
    }
    public PageReference init() {
        String paymentIdsCsv = String.escapeSingleQuotes( ApexPages.currentPage().getParameters().get('paymentIds') );
        // update to printed
        List<AAkPay__Payment_Txn__c> paymentsToUpdate = new List<AAkPay__Payment_Txn__c>();
        for( String paymentId : paymentIdsCsv.split(',') ) {
            paymentsToUpdate.add( new AAkPay__Payment_Txn__c(Id = paymentId, Receipt_Printed__c = true) );
        }
        if( !paymentsToUpdate.isEmpty() ) {
            // // previously 
            // update paymentsToUpdate;
            Database.update(paymentsToUpdate, false);
        }
        return null;
    }
    public static Map<String, String> getFormulaToFieldSoqlMap(String sObjectTypeName) {
        Map<String, String> fieldMap = new Map<String, String>();
        SObjectType type = Schema.getGlobalDescribe().get(sObjectTypeName);
        Map<String, Schema.SObjectField> fieldsMap = type.getDescribe().fields.getMap();
        Map<String, String> fieldNameMapToSobjectType = new Map<String, String>();
        Map<String, String> fieldNameMapToRelationshipName = new Map<String, String>();
        for( String key : fieldsMap.keySet() ) {
            Schema.DescribeFieldResult field = fieldsMap.get(key).getDescribe();
            if( field.getReferenceTo().size() == 1 ) {
                fieldNameMapToSobjectType.put(field.getName(), field.getReferenceTo().get(0).getDescribe().getName());
            }
            if( String.isNotBlank(field.getRelationshipName()) ) {
                fieldNameMapToRelationshipName.put(field.getName(), field.getRelationshipName());
            }
        }
        for( String fieldName : fieldNameMapToSobjectType.keySet() ) {
            SObjectType refSObjectType = Schema.getGlobalDescribe().get( fieldNameMapToSobjectType.get(fieldName) );
            Map<String, Schema.SObjectField> fieldsMap2 = refSObjectType.getDescribe().fields.getMap();
            for( String field2Name : fieldsMap2.keySet() ) {
                Schema.DescribeFieldResult field2 = fieldsMap2.get(field2Name).getDescribe();
                fieldMap.put(fieldNameMapToSobjectType.get(fieldName) + '.' + field2.getName(), fieldNameMapToRelationshipName.get(fieldName) + '.' + field2.getName() );
            }
        }
        for( String key : fieldsMap.keySet() ) {
            Schema.DescribeFieldResult field = fieldsMap.get(key).getDescribe();
            fieldMap.put(sObjectTypeName + '.' + field.getName() , field.getName() );
        }
        return fieldMap;
    }
    public class PaymentWrapper {
        public AAkPay__Payment_Txn__c payment {get; private set;}
        public String letterText {get; private set;}
        public String letterheadUrl {get; private set;}
        public PaymentWrapper(AAkPay__Payment_Txn__c payment) {
            this.payment = payment;
            letterText = payment.AAkPay__Receipt_Letter__r.AAkPay__Letter_Text__c;
        }
        public PaymentWrapper setLetterheadUrlWithCorrectLink(ContentDocumentLink link) {
            if( link == null ) { return this; }
            letterheadUrl = URL.getSalesforceBaseUrl().getProtocol() + '://' + URL.getSalesforceBaseUrl().getHost() + '/sfc/servlet.shepherd/version/download/' + link.ContentDocument.LatestPublishedVersionId ;
            System.debug('Spd: letterheadUrl ' + letterheadUrl);
            return this;
        }
        public PaymentWrapper replaceLetterTextWithFieldMapping(Map<String, String> fieldMap) {
            if( String.isBlank(letterText) ) {
                return this;
            }
            List<String> formulaToBeReplaced = new List<String>();
            Integer startIndex = null;
            Integer endIndex = null;
            for( Integer index = 0; index < letterText.length(); index++ ) {
                // System.debug('Spd charAt ' + index + ' ' + letterText.charAt(index) );
                if( startIndex != null ) {
                    // look for the end
                    if( letterText.charAt(index) == 125 ) {
                        endIndex = index;
                        formulaToBeReplaced.add( letterText.substring(startIndex, endIndex) );
                        startIndex = null;
                        endIndex = null;
                        // reset
                        continue;
                    }
                }
                // is '{'
                if( letterText.charAt(index) == 123 ) {
                    // not the end yet and is '!'
                    if( (index+1) < letterText.length() && letterText.charAt(index+1) == 33 ) {
                        // +2 to remove '{!'
                        startIndex = index + 2;
                    }
                }
            }
            // System.debug('Spd formulaToBeReplaced.size() ' + formulaToBeReplaced.size() );
            // System.debug('Spd formulaToBeReplaced ' + formulaToBeReplaced);
            Map<String, Schema.SObjectField> FIELD_MAP = Schema.SObjectType.AAkPay__Payment_Txn__c.fields.getMap();
            for( String formula : formulaToBeReplaced ) {
                String fieldName = fieldMap.get(formula);
                if( String.isBlank(fieldName) ) { continue; }
                String value = null;
                if( fieldName.contains('.') ) {
                    List<String> objectDotField = fieldName.split('\\.');
                    if( payment.getSobject(objectDotField[0]) != null ) {
                        value = String.valueOf(payment.getSobject(objectDotField[0]).get(objectDotField[1]));
                        if( FIELD_MAP.get(objectDotField[1]) != null ) {
                            Schema.DisplayType fieldType = FIELD_MAP.get(objectDotField[1]).getDescribe().getType();
                            System.debug('Spd: fieldType ' + fieldType);
                            if( 'CURRENCY' == String.valueOf(fieldType) ) {
                                List<String> args = new String[]{'0','currency','###,###,##0.00'};
                                Decimal dValue = Decimal.valueOf(String.valueOf(payment.getSobject(objectDotField[0]).get(objectDotField[1])));
                                String trailingZero = '';
                                if( (dValue - dValue.intValue()) == 0 ) {
                                    trailingZero = '.00';
                                }
                                value = '\\$' + String.format(dValue.format(), args) + trailingZero;
                            }
                        }
                    }
                } else {
                    value = String.valueOf(payment.get(fieldName));
                    if( FIELD_MAP.get(fieldName) != null ) {
                        Schema.DisplayType fieldType = FIELD_MAP.get(fieldName).getDescribe().getType();
                        System.debug('Spd: fieldType ' + fieldType);
                        if( 'CURRENCY' == String.valueOf(fieldType) ) {
                            List<String> args = new String[]{'0','currency','###,###,##0.00'};
                            Decimal dValue = Decimal.valueOf(String.valueOf(payment.get(fieldName)));
                            String trailingZero = '';
                            if( (dValue - dValue.intValue()) == 0 ) {
                                trailingZero = '.00';
                            }
                            value = '\\$' + String.format(dValue.format(), args) + trailingZero;
                        }
                    }
                }
                if( String.isNotBlank(value) ) {
                    letterText = letterText.replaceAll('\\{!\\s*' + formula + '\\s*\\}', value );
                } else {
                    letterText = letterText.replaceAll('\\{!\\s*' + formula + '\\s*\\}', '' );
                }
            }
            return this;
        }
    }
    public void mDebugUntruncated(String sMsg) { //Only for debugging
        for (Integer i = 0; i < sMsg.length(); i=i+300) {
            Integer iEffectiveEnd = (i+300 > (sMsg.length()-1) ? sMsg.length()-1 : i+300);
            System.debug(sMsg.substring(i,iEffectiveEnd));
        }
    }
}