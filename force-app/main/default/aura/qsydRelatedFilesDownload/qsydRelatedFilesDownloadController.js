({
    doInit : function (component, event, helper) {

        component.set('v.columns', [
            { label: 'File Name', fieldName: 'name', type: 'text', sortable: true, wrapText:true, wrapTextMaxLines:5},
            { label: 'File Size', fieldName: 'filesize', type: 'text' },
             {label: '', fieldName: 'downloadLink', type: 'url', typeAttributes: { label: 'Download', target: '_blank'}}
        ]);

        helper.getIsCommunity(component, event, helper);
        helper.getFiles(component, event, helper);
    },


})