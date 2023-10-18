public without sharing class EndorsedProductHandler {

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBrandList() {
        return [SELECT Brand__c 
                FROM CA_Endorsed_Product__c
                WHERE Publish_to_Web__c = True
                GROUP BY Brand__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getCategory(string productType) {
       
        return [SELECT Category__c
                FROM CA_Endorsed_Product__c
                WHERE Product_Type__c =: productType
                GROUP BY Category__c
                ORDER BY Category__c
        ];
       
    } 


    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSubCategory(String category) {
        
        return [SELECT Sub_Category__c
                FROM CA_Endorsed_Product__c
                WHERE Category__c =: category 
                GROUP BY Sub_Category__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getNewProducts(){
        return [SELECT Brand__c
                FROM CA_Endorsed_Product__c
                WHERE What_s_New__c = True
                GROUP BY Brand__c
        ];

        
    }

    //get new products by brand  
    @AuraEnabled(cacheable=true)
    public static List<CA_Endorsed_Product__c> getNewProductsByBrand(string brandName){
        return [SELECT id, Name, Brand__c, Image_URL__c 
                FROM CA_Endorsed_Product__c
                WHERE What_s_New__c = True 
                AND Brand__c=:brandName    
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBrandImage(String brandName){
        try {
            return [SELECT  Image_Name__c
            FROM CA_Endorsed_Product__c
            WHERE What_s_New__c = True and Brand__c=:brandName
            Group By  Image_Name__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    

    @AuraEnabled(cacheable=true)
    public static List<CA_Endorsed_Product__c> searchFiltered(SearchWrapper wrapper){ //SearchWrapper wrapper
        System.Debug('called search filtered');
        System.debug(wrapper.brand);
        System.debug(wrapper.type);
        System.debug(wrapper.category);
        System.debug(wrapper.subcategory);
        System.debug(wrapper.retail);
        System.debug(wrapper.foodservice);
        System.debug(wrapper.name);

        String whereClause = '';
        String brand, type, category, subcategory, filter;
        Boolean retail, foodService;
        String[] criteria = new List<String>{};
        if (wrapper != null) {
            brand = wrapper.brand; 
            type = wrapper.type; 
            category = wrapper.category; 
            subcategory = wrapper.subcategory; 
            retail = wrapper.retail;
            foodService = wrapper.foodservice;
            filter = wrapper.name;
            if (wrapper.brand != null && wrapper.brand != '--') {
                criteria.add('Brand__c = \''+brand+'\'');
            }
            if (wrapper.type != null && wrapper.type != '--') {
                criteria.add('Product_Type__c = \'' +type+'\'');
            }
            if (wrapper.category != null && wrapper.category != '--') {
                criteria.add('Category__c = \'' +category+'\'');
            }
            if (wrapper.subcategory != null && wrapper.subcategory != '--') {
                criteria.add('Sub_Category__c = \'' +subcategory+'\'');
            }
            if (wrapper.retail == true) {
                criteria.add('Retail__c = ' +retail+'');
            }
            if (wrapper.foodservice == true) {
                criteria.add('Food_Service__c = ' +foodService+'');
            }
            if (wrapper.name != null) {
                //filter = '%'+filter+'%';
                criteria.add('Name LIKE \'%' +filter+'%\'');
            }
            if(criteria.size()>0){
                whereClause =  String.join(criteria, ' AND ');
                whereClause += ' AND ';
            }
        }
        
        String query = 'SELECT Id, Name, Brand__c, Product_Size__c, Retail__c, Food_Service__c, Image_URL__c ' + 
                       'FROM CA_Endorsed_Product__c ' + 
                       'WHERE ' + whereClause + 'Product_Status__c = \'Current\' AND Publish_to_Web__c = True order by Brand__c'; 

        System.Debug('Query: ' + query);

        List<CA_Endorsed_Product__c> products = Database.query(query);

        
        System.Debug('Results: ' + products);
        
        return products;
        
    }

}