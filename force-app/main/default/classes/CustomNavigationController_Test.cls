    @isTest
public with sharing class CustomNavigationController_Test {
    

    @isTest
    public static void makeData(){

                Id clinicRecordTypeIdH = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Header Item').getRecordTypeId();
                Id clinicRecordTypeIdFI = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Footer Item').getRecordTypeId();
                Id clinicRecordTypeIdFD = Schema.SObjectType.Metadata_Object__c.getRecordTypeInfosByName().get('Footer Detail Item').getRecordTypeId();


                Metadata_Object__c metadata_objectObjp = new Metadata_Object__c(
                    Name = 'My Membership',
                    RecordTypeId = clinicRecordTypeIdH,
                    URL__c = 'test.com',
                    Order__c = 1,
                    IsActive__c = true);
                insert metadata_objectObjp;


                Metadata_Object__c metadata_objectObj = new Metadata_Object__c(
                    Name = 'My memberships',
                    RecordTypeId = clinicRecordTypeIdH,
                    Metadata_Object__c = metadata_objectObjp.Id,
                    Order__c = 1,
                    IsActive__c = true,
                    Show_Visibility__c = 'nb250asdssasa82002@gmail.com,System Administrator');
                insert metadata_objectObj;

                Metadata_Object__c metadata_objectObjFI = new Metadata_Object__c(
                    Name = 'News',
                    RecordTypeId = clinicRecordTypeIdFI,
                    URL__c = '/s/member-area-/ca-member-news',
                    Order__c = 1,
                    IsActive__c = true,
                    Show_Visibility__c = 'nb250asdssasa82002@gmail.com,webtopc2021@gmail.com,System Administrator');
                insert metadata_objectObjFI;


                Metadata_Object__c metadata_objectObjFD = new Metadata_Object__c(
                    Name = 'Refund Policy',
                    RecordTypeId = clinicRecordTypeIdFD,
                    URL__c = 'https://www.coeliac.org.au/s/refund-policy',
                    Order__c = 2,
                    IsActive__c = true,
                    Show_Visibility__c = 'nb250asdssasa82002@gmail.com,webtopc2021@gmail.com,System Administrator');
                insert metadata_objectObjFD;

                 Profile profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];


                Metadata_Object__c metadata_objectObjFDD = new Metadata_Object__c(
                    Name = 'Refund Policy',
                    RecordTypeId = clinicRecordTypeIdFD,
                    URL__c = 'https://www.coeliac.org.au/s/refund-policy',
                    Order__c = 2,
                    IsActive__c = true,
                    Show_Visibility__c = 'nb250asdssasa82002@gmail.com,webtopc2021@gmail.com,System Administrator');
                insert metadata_objectObjFDD;

                String jsonSting = '[{"Id":"'+metadata_objectObjp.Id+'","Name":"My Membership","URL__c":"test.com","Order__c":1,"IsActive__c":true,"Metadata_Objects__r":[{"Metadata_Object__c":"'+metadata_objectObjp.Id+'","Id":"'+metadata_objectObj.ID+'","Name":"My membership","Show_Visibility__c":"System Administrator","IsActive__c":true,"Order__c":1}]}]';
                Object subItem = ('({Id='+metadata_objectObj.Id+', IsActive__c=true, Metadata_Object__c='+metadata_objectObjp.Id+', Name=My membershipsss, Order__c=1},{Id='+metadata_objectObjFI.Id+', IsActive__c=true, Metadata_Object__c='+metadata_objectObjp.Id+', Name=My membership, Order__c=2})');

        
        Test.startTest();
        CustomNavigationController.MetadataWrapper result =  CustomNavigationController.getHeaderItems(null);
        CustomNavigationController.getHeaderItems(metadata_objectObj.Id);
        CustomNavigationController.getsubmenuItems(metadata_objectObj.Id);
        CustomNavigationController.insertMenuItems(subItem, metadata_objectObjp.Id ,metadata_objectObjFDD.Id);
        CustomNavigationController.insertMainMenuItems(jsonSting,metadata_objectObjp.Id ,metadata_objectObjFD.Id,'Header Menu');
        CustomNavigationController.insertMainMenuItems(jsonSting,metadata_objectObjp.Id ,metadata_objectObjFD.Id,'Footer Item');
        CustomNavigationController.insertMainMenuItems(jsonSting,metadata_objectObjp.Id ,metadata_objectObjFD.Id,'Footer Detail Item');
        CustomNavigationController.searchUsersName();
        CustomNavigationController.UserData();
        List<CustomNavigationController.ResultWrapper> result1 =  CustomNavigationController.saveSelectedValues('Bsadsaansal','Header Menu',metadata_objectObj.Id);
        List<CustomNavigationController.ResultWrapper> result2 =  CustomNavigationController.saveSelectedValues('Bsadsaansal','Footer Item',metadata_objectObj.Id);
        List<CustomNavigationController.ResultWrapper> result3 =  CustomNavigationController.saveSelectedValues('Bsadsaansal','Footer Detail Item',metadata_objectObj.Id);    
        Test.stopTest();    
    }

}