import { LightningElement, track } from 'lwc';
import navigationcss from '@salesforce/resourceUrl/navigationcss';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getHeaderItems from '@salesforce/apex/CustomNavigationController.getHeaderItems';
import saveSelectedValues from '@salesforce/apex/CustomNavigationController.saveSelectedValues';
import insertMenuItems from '@salesforce/apex/CustomNavigationController.insertMenuItems';
import insertMainMenuItems from '@salesforce/apex/CustomNavigationController.insertMainMenuItems';
import searchUsersName from '@salesforce/apex/CustomNavigationController.searchUsersName';
import getsubmenuItems from '@salesforce/apex/CustomNavigationController.getsubmenuItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';


export default class SideNavigationLWC extends LightningElement {
    @track selectedNav = 'Header Menu';
    isShowModal = false;

    @track menuItemValues = [];
    @track maindata = [];
    @track jsonString = '';

    @track childMetaRecords = [];
    @track menuId = '';
    @track deleteConatctIds = '';
    @track isLoading = true;
    @track childExist = false;
    @track metaname = '';


    @track dragStart;
    @track dragStartChild;
    @track selectedsearchvalue;


    @track changeStatus = false;
    @track showvisibility = false;
    @track searchResults = [];
    @track recipients = [];
    @track searchLookup = '';
    @track showSearchResults = false;
    @track searchResultsProfiles = [];
    @track searchResultsUsers = [];


    @track idOfpersvisibility;
    @track PersonalizeName;
    @track checkwhichcompontUse;

    @track actionButtonTrack = false;


    connectedCallback() {
        loadStyle(this, navigationcss);
        this.getHeaderItem();
        this.searchUsernamelist();
    }


    addRow() {
        this.childExist = true;
        let randomId = Math.random() * 16;
        let myNewElement = { Name: "", URL__c: "", Id: randomId, Order__c: this.childMetaRecords.length + 1, IsActive__c: false, HeaderItem__c: "", buttonShow__c: true };
        this.childMetaRecords = [...this.childMetaRecords, myNewElement];

    }

    addRowmain() {
        let randomId = Math.random() * 16;
        let mymainNewElement = { Name: "", URL__c: "", Id: randomId, Order__c: this.menuItemValues.length + 1, IsActive__c: false, buttonShow__c: true };
        this.menuItemValues = [...this.menuItemValues, mymainNewElement];
    }

    openpopup(event) {

        try {
            this.isLoading = true;
            this.metaname = event.currentTarget.dataset.name;
            let metaid = event.currentTarget.dataset.id;
            this.menuId = metaid;

            getsubmenuItems({ headerId: metaid })
                .then(result => {


                    this.childMetaRecords = result;
                    if (this.childMetaRecords.length > 0) {
                        this.childExist = true;
                    }
                    // Handle success

                    this.isLoading = false;
                })
                .catch(error => {
                    // Handle error
                    console.error('Error inserting data: ', error);
                    this.isLoading = false;
                });
            this.isShowModal = true;

        } catch (error) {


            this.isLoading = false;
        }
    }


    hideModalBox(event) {
        this.isShowModal = false;
    }

    getHeaderItem() {

        this.isLoading = true;

        getHeaderItems()
            .then((data) => {

                if (data) {

                    this.isLoading = true;
                    this.maindata = data;

                    for (let i = 0; i < data.headerList.length; i++) {


                        if (data.headerList[i].Metadata_Objects__r != null && data.headerList[i].Metadata_Objects__r != undefined) {
                            for (let j = 0; j < data.headerList[i].Metadata_Objects__r.length; j++) {
                                // 
                                this.childMetaRecords.push(data.headerList[i].Metadata_Objects__r[j]);
                            }
                        }
                    }


                    this.dataload();
                    this.isLoading = false;
                }
            }).catch((error) => {
                this.isLoading = false;

            });
    }


    handleSelect(event) {

        this.isLoading = true;
        const selected = event.detail.name;
        this.selectedNav = selected;

        if (this.selectedNav != 'Header Menu') {
            this.actionButtonTrack = true;
        } else {
            this.actionButtonTrack = false;
        }
        this.recipients = [];
        this.getHeaderItem();
        this.dataload();
        this.isLoading = false;
    }

    dataload() {
        try {


            this.isLoading = true;
            if (this.maindata) {
                if (this.selectedNav == 'Header Menu' && this.maindata.headerList != undefined && this.maindata.headerList != null) {
                    this.menuItemValues = this.maindata.headerList;

                }
                else if (this.selectedNav == 'Footer Resources Menu') {
                    this.menuItemValues = this.maindata.footerList;

                }
                else if (this.selectedNav == 'Footer Policy Menu') {
                    this.menuItemValues = this.maindata.detailList;
                }

            }
            this.isLoading = false;
        } catch (e) {


        }
    }

    handleInputChange(event) {

        const index = parseInt(event.currentTarget.dataset.index);

        const property = event.currentTarget.dataset.property;


        var foundelement = this.childMetaRecords.find(ele => ele.Id == event.currentTarget.dataset.id);
        if (property === 'Name') {
            foundelement.Name = event.currentTarget.value;
        } else if (property === 'URL__c') {
            foundelement.URL__c = event.currentTarget.value;
        }
        else if (property === 'IsActive__c') {
            foundelement.IsActive__c = event.currentTarget.checked;
        }


    }

    handleInputChangeMain(event) {

        const property = event.currentTarget.dataset.property;

        var foundelementmain = this.menuItemValues.find(ele => ele.Id == event.currentTarget.dataset.id);
        if (property === 'Name') {
            foundelementmain.Name = event.currentTarget.value;
        } else if (property === 'URL__c') {
            foundelementmain.URL__c = event.currentTarget.value;
        }
        else if (property === 'IsActive__c') {
            foundelementmain.IsActive__c = event.currentTarget.checked;
        }


    }


    saveData(event) {
        try {
            this.isLoading = true;
            if (this.deleteConatctIds !== '') {
                this.deleteConatctIds = this.deleteConatctIds.substring(1);
            }

            this.childMetaRecords.forEach(res => {
                console.log('res', res);
                if (!isNaN(res.Id)) {
                    res.Id = null;
                }
            });

            this.childMetaRecords = this.childMetaRecords.filter(res => {
                return res.Name != '';
            });

            insertMenuItems({ newLst: this.childMetaRecords, menuId: this.menuId, removeMetaIds: this.deleteConatctIds })
                .then(result => {
                    // Handle success

                    refreshApex(this.menuItemValues);
                    this.updateRecordView();
                    this.showToast('Success', 'Changes Saved Successfully', 'Success', 'dismissable');
                    this.isLoading = false;
                })
                .catch(error => {
                    // Handle error
                    console.error('Error inserting data: ', error);
                    this.showToast('Error inserting/updating records', 'Someting Went Wrong!!', 'Error', 'dismissable');
                    this.isLoading = false;
                });

        } catch (error) {


        }
    }


    saveMainData() {
        try {
            this.isLoading = true;
            if (this.deleteConatctIds !== '') {
                this.deleteConatctIds = this.deleteConatctIds.substring(1);
            }
            const newlst2 = [];

            this.menuItemValues = this.menuItemValues.filter(res => {
                return res.Name != '' // Keep elements with names different from the specified name
            });

            this.menuItemValues.forEach(res => {


                if (!isNaN(res.Id)) {
                    res.Id = null;
                }
                newlst2.push(res);

            });



            insertMainMenuItems({ newLst: JSON.stringify(newlst2), menuId: '', removeMetaIds: this.deleteConatctIds, selectednav: this.selectedNav })
                .then(result => {
                    // Handle success
                    refreshApex(this.menuItemValues);
                    this.showToast('Success', 'Changes Saved Successfully', 'Success', 'dismissable');
                    this.updateRecordView();
                    this.isLoading = false;
                    this.selectedNav = result;

                })
                .catch(error => {
                    // Handle error
                    console.error('Error inserting data main: ', error);
                    this.showToast('Error inserting/updating records', 'Someting Went Wrong!!', 'Error', 'dismissable');
                    this.isLoading = false;
                });


        } catch (error) {
            console.log('error', error);

            this.isLoading = false;
        }
    }

    handleDeleteAction(event) {

        if (isNaN(event.currentTarget.dataset.id)) {
            this.deleteConatctIds = this.deleteConatctIds + ',' + event.currentTarget.dataset.id;

        }
        this.childMetaRecords.splice(this.childMetaRecords.findIndex(row => row.Id === event.currentTarget.dataset.id), 1);
    }

    handleMainDeleteAction(event) {

        if (isNaN(event.currentTarget.dataset.id)) {
            this.deleteConatctIds = this.deleteConatctIds + ',' + event.currentTarget.dataset.id;

        }
        this.menuItemValues.splice(this.menuItemValues.findIndex(row => row.Id === event.currentTarget.dataset.id), 1);
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    updateRecordView() {
        this.isLoading = true;
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
            this.isLoading = false;
        }, 500);
    }


    DragStart(event) {
        try {


            if (event.currentTarget.dataset.name === 'parents') {
                this.dragStart = event.target.title;
            } else if (event.currentTarget.dataset.name === 'childs') {
                this.dragStartChild = event.target.title;
            }
            event.target.classList.add("drag");
        } catch (error) {

        }

    }

    DragOver(event) {
        try {
            event.preventDefault();
            return false;
        } catch (error) {

        }

    }

    Drop(event) {
        try {



            event.stopPropagation();

            if (event.currentTarget.dataset.name === 'parents') {
                if (this.dragStart === event.currentTarget.title) {
                    return false;
                }
                Array.prototype.move = function (from, to) {
                    this.splice(to, 0, this.splice(from, 1)[0]);
                };
                this.menuItemValues.move(this.dragStart, event.currentTarget.title);
                let counts = 1;
                for (var key in this.menuItemValues) {
                    this.menuItemValues[key].Order__c = counts;

                    counts++;


                }


            } else if (event.currentTarget.dataset.name === 'childs') {
                if (this.dragStartChild === event.currentTarget.title) {
                    return false;
                }
                Array.prototype.move = function (from, to) {
                    this.splice(to, 0, this.splice(from, 1)[0]);
                };
                this.childMetaRecords.move(this.dragStartChild, event.currentTarget.title);
                let counts = 1;
                for (var key in this.childMetaRecords) {
                    this.childMetaRecords[key].Order__c = counts;

                    counts++;

                }
            }
        } catch (error) {

        }

    }

    searchUsernamelist() {
        searchUsersName()
            .then((data) => {
                if (data) {
                    this.searchResultsProfiles = data.Profilelst;
                    this.searchResultsUsers = data.Userlst;
                }
            }).catch((error) => {
                this.isLoading = false;

            });
    }




    errorClass = 'slds-hide';
    addItemBtnClass = 'slds-hide';

    search(event) {


        let thisObjVal = event.currentTarget.value;

        let thisObjValLnth = thisObjVal.length;


        if (thisObjVal && thisObjValLnth > 2) {

            if (this.selectedsearchvalue == 'Profile') {
                const searchTerm = thisObjVal.toLowerCase();
                this.searchResults = this.searchResultsProfiles.filter(record => {

                    if (record.Name) {
                        this.showSearchResults = true;
                        this.searchLookup = thisObjVal;
                        return record.Name.toLowerCase().includes(searchTerm);
                    }
                    return false;
                });
            }
            else if (this.selectedsearchvalue == 'User') {
                const searchTerm = thisObjVal.toLowerCase();
                this.searchResults = this.searchResultsUsers.filter(record => {

                    if (record.Name) {
                        this.showSearchResults = true;
                        this.searchLookup = thisObjVal;
                        return record.Name.toLowerCase().includes(searchTerm);
                    }
                    return false;
                });
            }

        }
        else {
            this.showSearchResults = false;
        }
    }

    searchSelect(event) {
        try {


            let thisObjVal = event.target.innerText;
            this.recipients.push(thisObjVal);

            let recipientsNoDupes = Array.from(new Set(this.recipients));

            this.recipients = recipientsNoDupes;
            // this.pillSearch = false;
            this.showSearchResults = false;
            this.searchLookup = '';
        } catch (error) {

        }
    }

    removeRecipient(event) {
        let eventDataSet = event.target.dataset.index;
        this.recipients.splice(Number(eventDataSet), 1);
        this.recipients = [...this.recipients];


    }

    addToRecipients(event) {

        let recipientsNoDupes = Array.from(new Set(this.recipients));

        this.recipients = recipientsNoDupes;



        saveSelectedValues({
            selectedvalues: this.recipients.toString(), selectednav: this.selectedNav, recordid: this.idOfpersvisibility
        })
            .then((data) => {
                if (data) {


                    this.updateRecordView();
                    this.showToast('Success', 'Changes Saved Successfully', 'Success', 'dismissable');
                    this.changeStatus = false;
                }
            }).catch((error) => {
                this.isLoading = false;

                this.changeStatus = false;
                this.showToast('Error on Add Item', 'Someting Went Wrong!!', 'Error', 'dismissable');
            });


    }

    get options() {
        return [
            { label: 'Profile', value: 'Profile' },
            { label: 'User', value: 'User' },
        ];
    }

    handleComboChange(event) {
        this.selectedsearchvalue = event.detail.value;
    }


    openFieldScu(event) {
        this.changeStatus = !this.changeStatus;

        this.idOfpersvisibility = event.currentTarget.dataset.id;
        this.PersonalizeName = event.currentTarget.dataset.name;


        this.checkwhichcompontUse = event.currentTarget.dataset.label;
        if (this.checkwhichcompontUse == 'child') {
            this.isShowModal = !this.isShowModal;
        }
        this.getselectlistInVisi();
    }

    closepermisspopup() {
        this.changeStatus = !this.changeStatus;

        if (this.checkwhichcompontUse == 'child') {
            this.isShowModal = !this.isShowModal;
        }

    }

    getselectlistInVisi() {
        this.isLoading = true
        getHeaderItems({ recordId: this.idOfpersvisibility })
            .then((data) => {
                if (data) {
                    let visstr;
                    if (data.headerstr != null && data.headerstr != '' && data.headerstr != undefined && this.selectedNav == 'Header Menu') {
                        visstr = data.headerstr.split(',');
                    } else if (data.footerstr != null && data.footerstr != '' && data.footerstr != undefined && this.selectedNav == 'Footer Resources Menu') {
                        visstr = data.footerstr.split(',');
                    } else if (data.footerdetailstr != null && data.footerdetailstr != '' && data.footerdetailstr != undefined && this.selectedNav == 'Footer Policy Menu') {
                        visstr = data.footerdetailstr.split(',');
                    }
                    this.changeThevisi(visstr);

                }
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;

            });
    }


    changeThevisi(visstr) {

        let namelst = [];

        if (visstr != undefined && visstr != null && visstr != '') {
            for (let i = 0; i < visstr.length; i++) {
                namelst.push(visstr[i]);
            }
        }
        this.recipients = namelst;
        this.isLoading = false;
    }

}