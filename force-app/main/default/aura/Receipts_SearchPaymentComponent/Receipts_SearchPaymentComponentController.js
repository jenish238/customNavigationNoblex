({
    doInit : function(cmp, evt, helper) {
        cmp.set('v.removedPaymentIdsMap', {});
        cmp.set('v.pageList', []);
        cmp.set('v.pageListIndex', []);
        cmp.set('v.paymentRecordsPerPage', []);
        cmp.set('v.printChucks', []);
        cmp.set('v.currentPage', 1);
        cmp.set('v.settings', {
            Pagination_Size__c: 10,
            Printable_Max_Page__c: 10,
        });

        helper.requestEnqueueAction(cmp.get('c.getAllPaymentForms'), {}, function(error, allPaymentForms) {
            allPaymentForms.unshift({
                Id: '',
                Name: '-- select --'
            });
            cmp.set('v.allPaymentForms', allPaymentForms);
        });

        helper.requestEnqueueAction(cmp.get('c.getSettings'), {}, function(error, settings) {
            console.log('Spd: settings ', settings);
            cmp.set('v.settings', settings);
        });


    },



    doSearchPayments: function(cmp, evt, helper) {
        console.log('Spd searchPayments');
        cmp.set('v.isLoading', true);

        var paymentTnx = cmp.get('v.paymentTnx');
        var contact = cmp.get('v.contact');
        var emailPayment = cmp.get('v.emailPayment'); 
        var fromDate = cmp.get('v.fromDate'); 
        var untilDate = cmp.get('v.untilDate');
        var receiptPrintedOption = cmp.get('v.receiptPrintedOption');
        var isRecurringPayment = cmp.find('isRecurringPaymentCheckbox').get('v.checked');

        console.log('Spd: receiptPrintedOption ' + receiptPrintedOption);

        // reset remove Ids
        cmp.set('v.removedPaymentIdsMap', {});
                console.log('Yes!1');
        helper.requestEnqueueAction(cmp.get('c.searchPayments'), {
            jsonParam: JSON.stringify({
                accountId: paymentTnx.AAkPay__Account__c,
                contactId: paymentTnx.AAkPay__Contact__c, 
                campaignId: paymentTnx.AAkPay__Campaign__c, 
                paymentTypeId: paymentTnx.AAkPay__Payment_Type__c, 
                ownerId: contact.OwnerId, 
                amountCharged: paymentTnx.AAkPay__Card_Charged_Amount__c, 
                receiptEmail: emailPayment,
                fromDate: fromDate, 
                toDate: untilDate,
                receiptPrintedOption: receiptPrintedOption,
                isRecurringPayment: isRecurringPayment
            })
        }, function(error, paymentRecordsFound) {
            cmp.set('v.isLoading', false);
            if(error){
                if(error[0] && error[0].message){
                    cmp.set("v.isError", true);
                    cmp.set("v.message", error[0].message );
                    return ;
                }
            }
            cmp.set("v.isError", false);
            cmp.set('v.paymentTXNRec', paymentRecordsFound);
            
            if(paymentRecordsFound.length == 0){
                cmp.set("v.isNoResultFound", true);
            }else{
                cmp.set("v.isNoResultFound", false);
            }
            cmp.set('v.generatePdfUrl', helper.getPdfUrl(paymentRecordsFound, cmp.get('v.removedPaymentIdsMap')));
			
            $A.enqueueAction( cmp.get('c.renderPagination') );
        });
                console.log('Yes!2');
    },



    goToPage: function(cmp, evt, helper) {
        var page = evt.currentTarget.dataset.page;
        if( isNaN(parseInt(page)) ) { return; }

        cmp.set('v.currentPage', parseInt(page));
        $A.enqueueAction( cmp.get('c.renderPagination') );
    },


    togglePdfMenuDropdown: function(cmp, evt, helper) {
        var classDropdown = cmp.get('v.pdfMenuDropdownClass');
        if( classDropdown === 'slds-is-open' ) {
            cmp.set('v.pdfMenuDropdownClass', '');
        } else {
            cmp.set('v.pdfMenuDropdownClass', 'slds-is-open');
        }
    },


    renderPagination: function(cmp, evt, helper) {
        console.log('Yes------------------------------');
        console.log('Spd: renderPagination...');

        cmp.set('v.pdfMenuDropdownClass', '');

        var paymentRecords = cmp.get('v.paymentTXNRec');
        var removedPaymentIdsMap = cmp.get('v.removedPaymentIdsMap');
        var currentPage = parseInt(cmp.get('v.currentPage'));
        var PER_PAGE = parseInt(cmp.get('v.settings.Pagination_Size__c'));

        var pageSize = Math.ceil( paymentRecords.length / PER_PAGE );

        var MAX_RECORDS = parseInt(cmp.get('v.settings.Printable_Max_Page__c'));
        var printChucks = [];
        if( paymentRecords.length > MAX_RECORDS ) {
            // var paymentRecords
            var i,j,chunk = MAX_RECORDS;
            for (i=0, j=paymentRecords.length; i<j; i+=chunk) {
                var oneChuck = paymentRecords.slice(i, i+chunk);
                var hrefString = helper.getPdfUrl(oneChuck, removedPaymentIdsMap);
                var rangeLabel = ' from ' + (i+1) + ' to ' + ( ((i+chunk) > paymentRecords.length)?paymentRecords.length:(i+chunk) );

                printChucks.push({
                    payments: oneChuck,
                    paymentsCsv: oneChuck.map(function(i) { return i.Id; }).join(','),
                    hrefString: hrefString,
                    rangeLabel: rangeLabel
                });
            }
        } else {
            printChucks.push({
                payments: paymentRecords,
                paymentsCsv: paymentRecords.map(function(i) { return i.Id; }).join(','),
                hrefString: helper.getPdfUrl(paymentRecords, removedPaymentIdsMap),
                rangeLabel: ' from 1 to ' + (paymentRecords.length)
            });
        }
        console.log('Spd: printChucks ', printChucks);
        cmp.set('v.printChucks', printChucks)

        if( currentPage < 1 ) { currentPage = 1; }
        if( currentPage > pageSize ) { currentPage = pageSize; }

        console.log('Spd: pageSize ' + pageSize);
        var pageList = [];

        for( var pageIndex = (currentPage-2); pageIndex <= (currentPage+2); pageIndex++ ) {
            if( pageIndex >= 1 && pageIndex <= pageSize ) {
                pageList.push({
                    number: pageIndex,
                    label: pageIndex
                }); 
            }
        }

        if( pageList[0].number !== 1 ) {
            if( pageList.length > 1 && pageList[0].number !== 2 ) {
                pageList.unshift({
                    number: '...',
                    label: '...'
                });
            }
            pageList.unshift({
                number: 1,
                label: 1
            });
        }

        if( pageList[pageList.length-1].number !== pageSize ) {
            if( pageList.length > 1 && pageList[pageList.length-1].number !== (pageSize-1) ) {
                pageList.push({
                    number: '...',
                    label: '...'
                });
            }
            pageList.push({
                number: pageSize,
                label: pageSize
            });
        }

        var pageListIndex = [];
        for( var i = 0; i < pageList.length; i++ ) {
            pageListIndex.push(i);
        }

        cmp.set('v.pageList', pageList);
        cmp.set('v.pageListIndex', pageListIndex);
        console.log('Yes!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        cmp.set('v.paymentRecordsPerPage', paymentRecords.slice( (currentPage-1)*PER_PAGE, currentPage*PER_PAGE) );
        cmp.set('v.currentPage', currentPage);
    },



    doUpdateReceiptPrinted: function(cmp, evt, helper) {
        console.log('Spd: doUpdateReceiptPrinted...');
        var payments = evt.currentTarget.dataset.payments;
        var paymentRecordsToPrint = payments.split(',');
        // var removedPaymentIdsMap = cmp.get('v.removedPaymentIdsMap');
        cmp.set('v.isLoading', true);

        // var paymentRecordsToPrint = helper.getPaymentIdsToPrint(paymentRecords, removedPaymentIdsMap);

        if( paymentRecordsToPrint.length === 0 ) {
            return;
        }

        helper.requestEnqueueAction(cmp.get('c.updateReceiptPrinted'), {
            paymentIds: paymentRecordsToPrint
        }, function(error, response) {
            cmp.set('v.isLoading', false);
            if( error ) {
                if(error[0] && error[0].message){
                    cmp.set("v.isError", true);
                    cmp.set("v.message", error[0].message );
                }
                if(error[0] && error[0].pageErrors && error[0].pageErrors[0] && error[0].pageErrors[0].message){
                    cmp.set("v.isError", true);
                    cmp.set("v.message", error[0].pageErrors[0].message );
                }
                if( error[0] && error[0].fieldErrors ) {
                    var fieldErrors = error[0].fieldErrors;
                    var firstError = fieldErrors[Object.keys(fieldErrors)[0]];
                    if( firstError && firstError[0] && firstError[0].message ) {
                        cmp.set("v.isError", true);
                        cmp.set("v.message", firstError[0].message );
                    }
                }
                return;
            }
            console.log('Spd: updateReceiptPrinted response: ', response);

            // var urlEvent = $A.get("e.force:navigateToURL");
            // urlEvent.setParams({
            //     "url": helper.getPdfUrl(paymentRecords, removedPaymentIdsMap)
            // });
            // urlEvent.fire();

            // // urlEvent.fire not working
            // if( typeof window !== 'undefined' && window.location ) {
            //     window.location = helper.getPdfUrl(paymentRecords, removedPaymentIdsMap);
            // }
        });
    },

    removePayment: function(cmp, evt, helper){
        var paymentId = evt.currentTarget.dataset.paymentId;

        var paymentRecords = cmp.get('v.paymentTXNRec');
        var removedPaymentIdsMap = cmp.get('v.removedPaymentIdsMap');
        removedPaymentIdsMap[paymentId] = paymentId;

        var paymentRecordsToShow = [];
        paymentRecords.forEach(function(onePayment) {
            if( !removedPaymentIdsMap[onePayment.Id] ) {
                paymentRecordsToShow.push(onePayment)
            }
        });

        cmp.set('v.paymentTXNRec', paymentRecordsToShow);
        cmp.set('v.removedPaymentIdsMap', removedPaymentIdsMap);
        cmp.set('v.generatePdfUrl', helper.getPdfUrl(paymentRecordsToShow, removedPaymentIdsMap));

        $A.enqueueAction( cmp.get('c.renderPagination') );
    },
})