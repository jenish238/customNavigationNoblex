public with sharing class SearchWrapper {
    public SearchWrapper() {

    }

    public SearchWrapper(String brand, String type, String category, String subcategory, Boolean retail, Boolean foodservice, String name) {
        this.brand = brand;
        this.type = type;
        this.category = category;
        this.subcategory = subcategory;
        this.retail = retail;
        this.foodservice = foodservice;
        this.name = name;
    }

    @AuraEnabled
    public String brand { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String category { get; set; }
    @AuraEnabled
    public String subcategory { get; set; }
    @AuraEnabled
    public Boolean retail { get; set; }
    @AuraEnabled
    public Boolean foodservice { get; set; }
    @AuraEnabled
    public String name { get; set; }
}