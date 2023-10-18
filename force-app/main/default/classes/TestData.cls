public with sharing class TestData {

    public static Account createAccount() {
        Account account = new Account(
            Name='Test Account',
            AccountNumber='12345678',
            BillingStreet='100 somewhere st',
            BillingCity='Melbourne',
            BillingState='VIC',
            BillingPostalCode='3000',
            BillingCountry='Australia',
            Fax='+61 (3) 9999 1111',
            Phone='+61 (3) 9999 1112'  
        );
        return account;
    }

    public static Contact createContact(Id AccountId) {
        Contact contact = new Contact(
            AccountId=AccountId,
            firstName='FirstNa',
            lastName='lastNa',
            email='test@test.com.au',
            MobilePhone='+61 411 111 111'
        );
        return contact;
    }

    public static Lead createLead() {
        Lead lead = new Lead();
        lead.FirstName = 'FirstName';
        lead.LastName = 'LastName';
        lead.Email = 'lead@test.com';
        lead.Phone = '+61 (3) 9999 1112';
        lead.Company = 'The company'; 
        return lead;
    }

    public static Case createCase(Id contactId, Id accountId) {
        Case cse = new Case();
        cse.Priority = 'Low';
        cse.ContactId = contactId;
        cse.AccountId = accountId;
        cse.Description = 'What went wrong';
        return cse;
    }

    public static Opportunity createOpportunity(Id accId) {
        Opportunity o = new Opportunity(
            Name = 'Test Opp'
            , CloseDate = Date.today()
            , StageName = 'Closed/Won'
            , AccountId = accId
        );
        return o;
    }

    public static OpportunityLineItem createOpportunityLineItem(Id oppId, Id pbeId) {
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppId
            , PricebookEntryId = pbeId
            , Quantity = 1
            , UnitPrice = 5
        );
        return oli;
    }

    public static Product2 createProduct() {
        Product2 product = new Product2();
        product.Name = 'TestName';
        product.Family = 'TestFam';
        product.IsActive = true;

        return product;
    }

    public static PricebookEntry createPricebookEntry(Id prodId) {
        PricebookEntry pbe = new PricebookEntry();
        Id stdPBId = Test.getStandardPricebookId();
        pbe.pricebook2Id = stdPBId;
        pbe.Product2Id = prodId;
        pbe.unitprice = 50;
        pbe.isactive = true;

        return pbe;
    }

    public static Campaign createCampaign() {
        Campaign campaign = new Campaign(
            Name='Test Campaign',
            IsActive=true,
            startDate=System.today()-30,
            endDate=system.today()+45
        );
        return campaign;
    }

    public static CampaignMember createCampaignMember(Id contactId, Id campaignId) {
        CampaignMember campaignMember = new CampaignMember(CampaignId=campaignId,contactId=contactId,Status='Sent');
        return campaignMember;
    }
  
    public static list<CampaignMemberStatus> createCampaignMemberStatus(Id campaignId) {
        list<CampaignMemberStatus> campaignMemberStatusList = new list<CampaignMemberStatus>();
        campaignMemberStatusList.add(new CampaignMemberStatus(campaignId = campaignId,Label='Sent',sortOrder=1));
        campaignMemberStatusList.add(new CampaignMemberStatus(campaignId = campaignId,Label='Responded',sortOrder=2));
        return campaignMemberStatusList;
    }
    
    public static npsp__General_Accounting_Unit__c createGAU() {
        npsp__General_Accounting_Unit__c GAU = new npsp__General_Accounting_Unit__c(
            Name='Test GAU',
            npsp__Active__c=true
        );
        return GAU;
    }
    
    public static npsp__Allocation__c createGAUAllocation(id GAUid) {
        npsp__Allocation__c GAUAllocation = new npsp__Allocation__c(
            npsp__Amount__c=10,
            npsp__General_Accounting_Unit__c = GAUId
        );
        return GAUAllocation;
    }
}