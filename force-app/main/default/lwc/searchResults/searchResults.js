import { LightningElement, api } from 'lwc';
import getFilteredResults from '@salesforce/apex/EndorsedProductHandler.searchFiltered';

export default class SearchResults extends LightningElement {

   //@api brand;
   brand;
   @api get selectedBrand() {
      return this.brand;
   }
   set selectedBrand(value) {
      this.setAttribute('selectedBrand', value);
      this.brand = value;
      this.updateScreen();
   }
   //@api type;
   type;
   @api get productType() {
      return this.type;
   }
   set productType(value) {
      this.setAttribute('productType', value);
      this.type = value;
      this.updateScreen();
   }

   //@api category;
   category;
   @api get categoryChoice() {
      return this.category;
   }
   set categoryChoice(value) {
      this.setAttribute('categoryChoice', value);
      this.category = value;
      this.updateScreen();
   }

   //@api subcategory;
   @api get subcategoryChoice() {
      return this.subcategory;
   }
   set subcategoryChoice(value) {
      this.setAttribute('subcategoryChoice', value);
      this.subcategory = value;
      this.updateScreen();
   }

   //@api retail;
   retail;
   @api get retailOption() {
      return this.retail;
   }
   set retailOption(value) {
      this.setAttribute('retailOption', value);
      this.retail = value;
      this.updateScreen();
   }

   //@api foodservice;
   foodservice;
   @api get foodServiceOption() {
      return this.foodservice;
   }
   set foodServiceOption(value) {
      this.setAttribute('foodServiceOption', value);
      this.foodservice = value;
      this.updateScreen();
   }

   //@api filter;
   filter;
   @api get filterString() {
      return this.filter;
   }
   set filterString(value) {
      this.setAttribute('filterString', value);
      this.filter = value;
      this.updateScreen();
   }

   @api searchResult;

   @api updateScreen() {

      let parameterObject = {
         brand: this.brand,
         type: this.type,
         category: this.category,
         subCategory: this.subcategory,
         retail: this.retail,
         foodservice: this.foodservice,
         name: this.filter
      };

      getFilteredResults({ wrapper: parameterObject})
         .then((result) => {
            this.searchResult = result;
         })
         .catch(() => {
            console.log("error");
         });

   }

}