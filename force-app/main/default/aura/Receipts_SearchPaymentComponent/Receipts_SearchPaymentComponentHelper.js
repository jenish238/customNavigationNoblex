({
    requestEnqueueAction: function(action, params, callback) {
        // requestSearchPayments
        // updateReceiptPrinted
        callback = callback || function() {};
        console.log('Spd helper params ', params);
        action.setParams(params);
        action.setCallback(this, function(response) {
            console.log('Spd response.getState() ', response.getState());
            if (response.getState() === 'SUCCESS') {
                callback(null, response.getReturnValue());
            } else if (response.getState() === 'ERROR'){
                var errors = response.getError();
                callback(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getPdfUrl: function(paymentRecords, removedPaymentIdsMap) {
        var pdfUrl = '/apex/Receipts_PDF?paymentIds=';

        paymentRecords.forEach(function(onePayment) {
            if( !removedPaymentIdsMap[onePayment.Id] ) {
                pdfUrl = pdfUrl + onePayment.Id + ',';
            }
        });

        return pdfUrl;
    },
    getPaymentIdsToPrint: function(paymentRecords, removedPaymentIdsMap) {
        var paymentIds = [];

        paymentRecords.forEach(function(onePayment) {
            if( !removedPaymentIdsMap[onePayment.Id] ) {
                paymentIds.push( onePayment.Id );
            }
        });

        return paymentIds;
    }
})