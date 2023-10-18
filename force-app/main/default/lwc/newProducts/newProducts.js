import { LightningElement, wire, track } from 'lwc';
import getNewProducts from '@salesforce/apex/EndorsedProductHandler.getNewProducts';
import getNewProductsByBrand from '@salesforce/apex/EndorsedProductHandler.getNewProductsByBrand';

export default class EndorsedProducts2 extends LightningElement {

@track brandName='';
selectedBrandName;
selectedBrandId='';

@track newProducts;//brands
@track products;
brandError = undefined;
productError=undefined;

@wire(getNewProducts)
wiredNewProducts(result)
 {
    this.newProducts=result;
    
    if(result.error)
    {
        this.brandError=result.error;
        this.newProducts=undefined;
    }  
}
// event 
displayBrandProduct(event){    
    this.selectedBrandName=event.detail.brandName;
    this.brandName=event.detail.brandName; 
}

@wire(getNewProductsByBrand, {brandName: '$brandName'})
wiredNewProductsByBrand(results){
    this.products=results;
    if(results.error)
    {
        this.productError=results.error;
       this.products= undefined;
    }
}

}