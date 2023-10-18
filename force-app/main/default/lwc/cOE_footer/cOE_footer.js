import { LightningElement, track } from 'lwc';
import comLogo from '@salesforce/resourceUrl/cOE_logo';
import FB from '@salesforce/resourceUrl/cOE_faceBook';
import iG from '@salesforce/resourceUrl/cOE_Instagram';
import iD from '@salesforce/resourceUrl/cOE_linkDin';
import fl from '@salesforce/resourceUrl/COE_footerlogo';
import getFooteritems from '@salesforce/apex/CustomNavigationController.getHeaderItems';
import UserData from '@salesforce/apex/CustomNavigationController.UserData';


export default class COE_footer extends LightningElement {
    compLogo = comLogo;
    faceBook = FB;
    instagram = iG;
    linkDin = iD;
    footerLogo = fl;

    @track footer1;
    @track footer2;

    @track footer1bool = false;
    @track footer2bool = false;

    @track userinfo;

    connectedCallback() {

        this.getFooter();
    }

    getFooter() {

        UserData()
            .then(result => {


                this.userinfo = result;
            })
            .catch(error => {
                // Handle error
                console.error('Error inserting data: ', error);

            });

        getFooteritems()
            .then((data) => {
                if (data) {



                    this.footer1 = this.footerDatavisible(data.footerList, this.userinfo);
                    this.footer2 = this.footerDatavisible(data.detailList, this.userinfo);
                }



            }).catch((error) => {

            });
    }




    footerDatavisible(data, user) {

        try {
            const filteredData = [];



            for (const item of data) {
                const showVisibility = item['Show_Visibility__c'];
                const metadataObjects = item['Metadata_Objects__r'];

                // Check if the Username or Profile.Name exists in Show_Visibility__c of the parent record
                if (
                    (!showVisibility ||  // Remove parent if Show_Visibility__c is not defined
                        (user.Username && showVisibility.includes(user.Username)) ||
                        (user.Profile && user.Profile.Name && showVisibility.includes(user.Profile.Name))
                    )
                ) {
                    // Check and filter child records if they exist
                    if (metadataObjects && metadataObjects.length > 0) {
                        const filteredMetadataObjects = metadataObjects.filter(metadata => {
                            const childShowVisibility = metadata['Show_Visibility__c'];



                            // Check if childShowVisibility is not defined or if it includes user info
                            return (
                                (  // Remove child if Show_Visibility__c is not defined
                                    (user.Username && (childShowVisibility != undefined) && childShowVisibility.includes(user.Username)) ||
                                    (user.Profile && user.Profile.Name && (childShowVisibility != undefined) && childShowVisibility.includes(user.Profile.Name))
                                )
                            );
                        });

                        // Update the parent record with the filtered child records
                        item['Metadata_Objects__r'] = filteredMetadataObjects;
                    }

                    // Add the parent record to filteredData
                    // filteredData.push(item);
                    if (showVisibility != undefined) { filteredData.push(item); }
                }
            }

            return filteredData;
        } catch (error) {

        }

    }


    DONATENOW() {
        window.open('https://www.coeliac.org.au/s/donate', '_blank').focus();
    }

    CoeAus() {
        window.open('https://www.coeliac.org.au/s/', '_blank').focus();
    }

    GFL() {
        window.open('https://glutenfreeliving.com.au/', '_blank').focus();
    }

}