@isTest
private class BatchGAUAllocationUpdateTest {
    @isTest
    static void BatchGAUAllocationUpdateUnitTest() {
        /*** SETUP TEST DATA ***/
        npsp__General_Accounting_Unit__c GAU1 = TestData.createGAU();
        GAU1.Name = 'This financial year';
        Insert GAU1;
        
        npsp__General_Accounting_Unit__c GAU = TestData.createGAU();
        GAU.Name = 'Next financial year';
        Insert GAU;
        
        npsp__General_Accounting_Unit__c GAU2 = TestData.createGAU();
        GAU2.Name = 'Joining fee member';
        Insert GAU2;
        
        Campaign Campaign= testData.createCampaign();
        Campaign.Name = 'Renewal Members – Full Member';
        Insert Campaign;

        npsp__Allocation__c GAUAllocation = TestData.CreateGAUAllocation(GAU.id);
        GAUAllocation.npsp__Campaign__c = Campaign.id;
        insert GAUAllocation;
        
        npsp__Allocation__c GAUAllocation1 = TestData.CreateGAUAllocation(GAU1.id);
        GAUAllocation1.npsp__Campaign__c = Campaign.id;
        insert GAUAllocation1;
        
        Campaign Campaign1= testData.createCampaign();
        Campaign1.Name = 'Renewal Members – Concession';
        Insert Campaign1;
        
        npsp__Allocation__c GAUAllocation2 = TestData.CreateGAUAllocation(GAU.id);
        GAUAllocation2.npsp__Campaign__c = Campaign1.id;
        insert GAUAllocation2;
        
        npsp__Allocation__c GAUAllocation3 = TestData.CreateGAUAllocation(GAU1.id);
        GAUAllocation3.npsp__Campaign__c = Campaign1.id;
        insert GAUAllocation3;
        
        Campaign Campaign2= testData.createCampaign();
        Campaign2.Name = 'New Members – Full Member';
        Insert Campaign2;
        
        npsp__Allocation__c GAUAllocation4 = TestData.CreateGAUAllocation(GAU.id);
        GAUAllocation4.npsp__Campaign__c = Campaign2.id;
        insert GAUAllocation4;
        
        npsp__Allocation__c GAUAllocation5 = TestData.CreateGAUAllocation(GAU1.id);
        GAUAllocation5.npsp__Campaign__c = Campaign2.id;
        insert GAUAllocation5;
        
        npsp__Allocation__c GAUAllocation6 = TestData.CreateGAUAllocation(GAU2.id);
        GAUAllocation6.npsp__Campaign__c = Campaign2.id;
        insert GAUAllocation6;
        
        Campaign Campaign3= testData.createCampaign();
        Campaign3.Name = 'New Members – Concession';
        Insert Campaign3;
        
        npsp__Allocation__c GAUAllocation7 = TestData.CreateGAUAllocation(GAU.id);
        GAUAllocation7.npsp__Campaign__c = Campaign3.id;
        insert GAUAllocation7;
        
        npsp__Allocation__c GAUAllocation8 = TestData.CreateGAUAllocation(GAU1.id);
        GAUAllocation8.npsp__Campaign__c = Campaign3.id;
        insert GAUAllocation8;
        
        npsp__Allocation__c GAUAllocation9 = TestData.CreateGAUAllocation(GAU2.id);
        GAUAllocation9.npsp__Campaign__c = Campaign3.id;
        insert GAUAllocation9;
        
        Test.startTest();
        // Exceute batch
            BatchGAUAllocationUpdate batchProcessor = new BatchGAUAllocationUpdate();
            ID batchprocessid = Database.executeBatch(batchProcessor,200);

        Test.stopTest();
    }
}