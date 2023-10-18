@isTest
private class TestEndorsedProductHandler {
    
    @isTest static void testGetBrandList() {
        List<AggregateResult> brands = [SELECT Brand__c 
                FROM CA_Endorsed_Product__c
                WHERE Publish_to_Web__c = True
                GROUP BY Brand__c
        ];
        List<AggregateResult> resultList = EndorsedProductHandler.getBrandList();

        //System.assertEquals(2, 2, 'Match');
        //System.assert(2 == 2, 'something');
        System.assertEquals(resultList.size(),brands.size(),'Brand List not expected size');
    }

    // getSubCategory
    @isTest static void testGetSubCategory() {
        List<AggregateResult> subCategoryList = [
                SELECT Sub_Category__c
                FROM CA_Endorsed_Product__c
                WHERE Category__c = 'Bread' 
                GROUP BY Sub_Category__c
        ];

        List<AggregateResult> resultList = EndorsedProductHandler.getSubCategory('Bread');

        System.assertEquals(resultList.size(),subCategoryList.size(),'Sub Category List not expected size');
    }
    
    // getNewProducts
    @isTest static void testGetNewProducts() {
        List<CA_Endorsed_Product__c> newProductList = [
                SELECT Name, Brand__c, Product_Size__c, Food_Service__c 
                FROM CA_Endorsed_Product__c
                WHERE What_s_New__c = True
        ];

        List<AggregateResult> resultList = EndorsedProductHandler.getNewProducts();

        System.assertEquals(resultList.size(),newProductList.size(),'New Product List not expected size');
    }

    // searchFiltered(SearchWrapper wrapper)
    @isTest static void testSearchFilterBrand() {
        List<CA_Endorsed_Product__c> productList = [
                SELECT Id, Name, Brand__c, Product_Size__c, Retail__c, Food_Service__c 
                FROM CA_Endorsed_Product__c 
                WHERE Brand__c = 'Kikkoman' AND Product_Status__c = 'Current' AND Publish_to_Web__c = True 
        ];

        SearchWrapper wrapper = new SearchWrapper('Kikkoman', null, null, null, null, null, null);
        List<CA_Endorsed_Product__c> products = EndorsedProductHandler.searchFiltered(wrapper);

        System.assertEquals(productList.size(),products.size(),'Filtered Product List not expected size');
    }
    
    // Test getBrandImages
    @isTest static void testGetBrandImages() {
        List<AggregateResult> imageQuery = [
            SELECT  Image_Name__c
            FROM CA_Endorsed_Product__c
            WHERE What_s_New__c = True and Brand__c = 'Bondi Organics'
            Group By  Image_Name__c
        ];
        List<AggregateResult> images = EndorsedProductHandler.getBrandImage('Bondi Organics');
        
        System.assertEquals(imageQuery.size(),images.size(),'Unexpected number of results');
       
    }
}