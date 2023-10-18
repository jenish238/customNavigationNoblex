import { LightningElement, api, track, wire } from 'lwc';
import getBrandImage from '@salesforce/apex/EndorsedProductHandler.getBrandImage';
import BRAND_LOGOS from '@salesforce/contentAssetUrl/EndorsedLogos';
const TILE_WRAPPER_SELECTED_CLASS = "tile-wrapper selected";
const TILE_WRAPPER_UNSELECTED_CLASS = "tile-wrapper";

export default class ProductTile extends LightningElement {

@api newProduct;
@api selectedBrandName;
brandName
brandImage;

   connectedCallback(){
       this.brandName=this.newProduct.Brand__c
       this.findImageName()       
   }
  
   get tileClass() {
      return  this.selectedBrandName ===this.newProduct.Brand__c ? TILE_WRAPPER_SELECTED_CLASS : TILE_WRAPPER_UNSELECTED_CLASS;
   }

   selectProductBrand() { 
      const newproductbrandselect = new CustomEvent('newproductbrandselect', {
         detail: {
            brandName: this.newProduct.Brand__c  
         }
      });
      this.dispatchEvent(newproductbrandselect); 
   }

   findImageName(){
      getBrandImage({brandName: this.brandName}).then(result=>{     
         if(result[0].Image_Name__c!==undefined){
            this.brandImage=BRAND_LOGOS+'pathinarchive=EndorsedLogos/images/'+result[0].Image_Name__c          
            return
         } 
      }).catch(error=>{
         console.error(error)
      })
      return
   }
        
}