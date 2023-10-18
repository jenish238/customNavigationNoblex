import { LightningElement, wire } from 'lwc';
import { getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi'
import CATEGORY_FIELD from '@salesforce/schema/CA_Endorsed_Product__c.Category__c'
import ENDORSED_PRODUCT from '@salesforce/schema/CA_Endorsed_Product__c'
import PRODUCT_TYPE_FIELD from '@salesforce/schema/CA_Endorsed_Product__c.Product_Type__c'
import getBrandList from '@salesforce/apex/EndorsedProductHandler.getBrandList';
import getSubCategory from '@salesforce/apex/EndorsedProductHandler.getSubCategory';
import getCategory from '@salesforce/apex/EndorsedProductHandler.getCategory'


export default class Search extends LightningElement {
    selectedType=''
    typeOptions=[]
    categoryOptions=[]
    selectedCategory=null
    productTypeOptions=[]
    selectedProductType=null
    subCategories=[]
    selectedSubCategory=null
    brands=[]
    selectedBrand=null
    filterString=null
    retail=null
    foodService=null
    Categories=[] 

    get CategoryOptions() {
        console.log('get category options: ' + this.Categories)
        return this.Categories
    
    }  
    get subCategoryOptions() {
        return this.subCategories;
    }
    

    @wire(getBrandList)
    wiredBrands({error, data}) {
        
        if (data) {
            this.brands = [{value: '--', label: '--'}];
            for(let i=0; i<data.length; i++)  {
              this.brands = [...this.brands ,{value: data[i].Brand__c , label: data[i].Brand__c} ];                           
            }               
            this.error = undefined;
        } else if (error) {
            console.log("Error occured");
            this.error = error;
            this.brands = undefined;
        }
    }

    get brandOptions() {
        return this.brands;
    }

    handleBrandFilterChange(event) {
        this.selectedBrand = event.detail.value.replace(/'/g, '\\\'');
    }

    // end of Brands

    generatePicklist(data){
         return data.values.map(item=>({ label: item.label, value: item.value }))// Product type food, beverage,..
    } 

    @wire(getObjectInfo, {objectApiName:ENDORSED_PRODUCT})
    productInfo

    // Get Product Type Picklist
    @wire(getPicklistValues, {recordTypeId:'$productInfo.data.defaultRecordTypeId', fieldApiName:PRODUCT_TYPE_FIELD})
    productTypePicklist({data, error}){      
        if (data){
            this.productTypeOptions=[...this.generatePicklist(data)];
            this.productTypeOptions.unshift({value: '--', label: '--'});            
        } else if(error){
            console.log(error)
        }
      
    } 


@wire(getCategory, {productType: '$selectedProductType'})
 wiredCategory({error, data}) {
    if (data) {
        this.Categories = [{value: '--', label: '--'}];
        for(let i=0; i<data.length; i++)  {
            this.Categories = [...this.Categories ,{value: data[i].Category__c , label: data[i].Category__c} ];                                   
        }  
        this.error = undefined;
    } else if (error) {
        console.log("Error occured");
        this.error = error;
    }
}

      handleProductTypeChange(event) {
        this.selectedProductType = event.detail.value;
        this.Categories=[]
        this.subCategories=[]
        this.template.querySelector('c-search-results').updateScreen();
    }
    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.subCategories=[];
    }

    // Get Sub Category
    @wire(getSubCategory, {category: '$selectedCategory'})
    wiredSubCategory({error, data}) {

        if (data) {
            this.subCategories = [{value: '--', label: '--'}];
            for(let i=0; i<data.length; i++)  {
                this.subCategories = [...this.subCategories ,{value: data[i].Sub_Category__c , label: data[i].Sub_Category__c} ];                                   
            }       
            this.error = undefined;
        } else if (error) {
            console.log("Error occured");
            this.error = error;
        }
    }






    handleSubCategoryChange(event) {
        this.selectedSubCategory = event.detail.value;
        this.template.querySelector('c-search-results').updateScreen();
    }

    handlefilterChange(event) {
        this.filterString = event.detail.value;
        this.template.querySelector('c-search-results').updateScreen();
    }

    handleClick() {
        this.template.querySelector('c-search-results').updateScreen(); 
    }

    handleRetailSelect() {
        if (this.retail === true) {
            this.retail = false;
        } else {
            this.retail = true;
        }
    }

    handleFoodServiceSelect() {
        if (this.foodService === true) {
            this.foodService = false;
        } else {
            this.foodService = true;
        }
    }
}