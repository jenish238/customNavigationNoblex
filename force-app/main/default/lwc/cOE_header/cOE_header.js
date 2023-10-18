import { LightningElement, track } from 'lwc';
import coeliacimg from '@salesforce/resourceUrl/cOE_logo';
import cOE_phone from '@salesforce/resourceUrl/cOE_phone';
import cOE_membericon from '@salesforce/resourceUrl/cOE_membericon';
import cOE_collapse from '@salesforce/resourceUrl/cOE_collapse';
import communityPath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
// import checkTheUser from '@salesforce/apex/CustomNavigationController.checkTheUser';

import getHeaderItems from '@salesforce/apex/CustomNavigationController.getHeaderItems';
import URl from '@salesforce/label/c.websiteUrl';



import UserData from '@salesforce/apex/CustomNavigationController.UserData';


export default class COE_header extends NavigationMixin(LightningElement) {

    coeliacimg = coeliacimg;
    phoneimg = cOE_phone;
    memberimg = cOE_membericon;
    collapseimg = cOE_collapse;


    @track userinfo;

    @track headerdata = [];
    @track othessss = [];

    @track showvisibility = false;

    @track moreOptionValue;
    @track url;

    connectedCallback() {

        this.checkCurrentTheUser();
        this.getHeaderItem();
        window.addEventListener('click', this.handleWindowClick);


    }


    disconnectedCallback() {
        // Remove the click event listener when the component is disconnected
        window.removeEventListener('click', this.handleWindowClick);
    }

    checkCurrentTheUser() {


        UserData()
            .then(result => {


                this.userinfo = result;

            })
            .catch(error => {
                // Handle error
                console.error('Error inserting data: ', error);

            });
    }
    redirecttohome() {
        location.href = '/s';
    }
    getHeaderItem() {

        getHeaderItems()
            .then((data) => {
                if (data) {

                    let sixValue = [];
                    let otherValue = [];
                    for (var key in data.headerList) {
                        if (sixValue.length < 6) {
                            if (data.headerList[key]['IsActive__c']) {
                                sixValue.push(data.headerList[key]);
                            }
                        } else {
                            otherValue.push(data.headerList[key]);
                        }
                    }




                    this.headerdata = this.headerDatavisible(sixValue, this.userinfo);
                    this.othessss = this.headerDatavisible(otherValue, this.userinfo);

                    // this.headerdata = data.headerList;



                    if (this.othessss.length > 0) {
                        this.showvisibility = true;
                    }
                    // 
                    // 
                }
            }).catch((error) => {

            });
    }


    headerDatavisible(data, user) {

        try {
            const filteredData = [];

            // let data = this.headerdata;
            // let user = this.userinfo;





            for (const item of data) {



                const IsActive = item['IsActive__c'];

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

                    // 
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
                        if (filteredMetadataObjects.length > 0) {
                            item['icon_visible'] = true;
                        } else {
                            item['icon_visible'] = false;
                        }
                        item['Metadata_Objects__r'] = filteredMetadataObjects;

                    }

                    // Add the parent record to filteredData

                    // filteredData.push(item);
                    if (showVisibility != undefined && IsActive) {
                        filteredData.push(item);

                    }
                }
            }

            return filteredData;
            // this.headerdata = filteredData;
        } catch (error) {

        }

    }

    openmenu(event) {
        try {

            if (event.currentTarget.dataset.type == 'Button') {
                let dataname = event.currentTarget.dataset.name;
                const datacls = this.template.querySelector('[data-key=\'' + dataname + '\']');
                datacls.classList.add('showcls');
                datacls.classList.remove('hidecls');
            } else {
                location.href = event.currentTarget.dataset.url;
            }
        } catch (error) {

        }

    }


    blurmenu(event) {
        try {
            let dataname = event.currentTarget.dataset.name;
            window.setTimeout(() => {
                const datacls = this.template.querySelector('[data-key=\'' + dataname + '\']');
                datacls.classList.remove('showcls');
                datacls.classList.add('hidecls');
            }, 100);


        } catch (error) {

        }
    }


    donation() {
        try {
            window.open('https://www.coeliac.org.au/s/donate', '_blank').focus();
        } catch (error) {

        }

    }

    logout(event) {
        try {
            this.url = URl;
            window.location.replace(this.url);
        } catch (error) {

        }
    }



    openMoreMenu(event) {
        try {

            this.moreOptionValue = '';


            let style = window.getComputedStyle(this.template.querySelector('.htmlCss-sub-menu'));


            if (style.display == 'none') {
                this.template.querySelector('.htmlCss-sub-menu').classList.add('testclass1');
                this.template.querySelector('.htmlCss-sub-menu').classList.remove('testclass');
            } else {
                this.template.querySelector('.htmlCss-sub-menu').classList.remove('testclass1');
                this.template.querySelector('.htmlCss-sub-menu').classList.add('testclass');
            }
        } catch {

        }
    }


    handleWindowClick = (event) => {
        try {




            let style = window.getComputedStyle(this.template.querySelector('.htmlCss-sub-menu'));




            if (this.moreOptionValue == 'openMoreMenu') {
                if (style.display == 'block') {

                    this.template.querySelector('.htmlCss-sub-menu').classList.add('testclass');
                    this.template.querySelector('.htmlCss-sub-menu').classList.remove('testclass1');

                }
            } else {
                this.moreOptionValue = 'openMoreMenu';
            }
        } catch {

        }
    };


}