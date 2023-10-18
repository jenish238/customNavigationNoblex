import { LightningElement, api } from 'lwc';
import BRAND_LOGOS from '@salesforce/contentAssetUrl/EndorsedLogos';

export default class ProductTile extends LightningElement {
   @api item
   brandUrl = BRAND_LOGOS + 'pathinarchive=EndorsedLogos/images/SpringHillFarm.png';
   
   @api
   get url() {
      return '/s/ca-endorsed-product/' + this.item.Id;
   }
   @api
   get imageUrl() {
      return BRAND_LOGOS + 'pathinarchive=EndorsedLogos' + this.item.Image_URL__c;
   }

   get hasImage(){
      return (this.item.Image_URL__c==='/images/' || this.item.Image_URL__c===null)  ? false: true
  }
}