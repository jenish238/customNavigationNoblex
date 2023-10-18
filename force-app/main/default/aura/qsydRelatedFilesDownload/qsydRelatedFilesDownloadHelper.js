({

    getFiles: function(component, event, helper){
        helper.callServer(
            component,
            "c.getFiles",
            function (response) {
                if(response){
                    component.set("v.relatedfiles", response);
                    helper.formData(component, event, helper);
                }
            },
            { 
                recordId: component.get('v.recordId')
            }  
        );
    },

    formData: function(component, event, helper){
      const returnedFiles = component.get('v.relatedfiles')
      const files = JSON.parse(returnedFiles);
      let dataItem = {};
      let dataList = [];
      let i;
      for(i = 0; i < files.length; i++){      
        dataItem = {};  
        dataItem.name = files[i].ContentDocument.Title +'.'+ files[i].ContentDocument.FileExtension; 
        dataItem.filesize = helper.getFilesize(files[i].ContentDocument.ContentSize);
        dataItem.downloadLink = helper.getFileDownloadLink(component.get('v.communityPrefix'), files[i].ContentDocumentId);
        dataList.push(dataItem);
      }
      component.set('v.data', dataList);
      if(dataList.length > 0){
          component.set('v.showComponent', true);
      }
    },

    gotoURL : function (url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url
        });
        urlEvent.fire();
    },


    getFileDownloadLink:  function(communityPrefix, contentDocumentId) {
        const FILE_DOWNLOAD = '/sfc/servlet.shepherd/document/download/';
        return communityPrefix + FILE_DOWNLOAD + contentDocumentId;
	},


    getFilesize:  function(filesize) {
		if (filesize == 0 || filesize == null ||
			isNaN(filesize)) {
			return '0.00 B';
		}
		let e = Math.floor(Math.log(filesize) / Math.log(1024));
		return (filesize / Math.pow(1024, e)).toFixed(2) + ' ' +
			' KMGTP'.charAt(e) + 'B';
	},

    getIsCommunity: function(component, event, helper){
        helper.callServer(
            component,
            "c.isCommunity",
            function (response) {
                if(response){
                    helper.getCommunityPrefix(component, event, helper);
                }
            },
            { 
            }
        );
    },

    getCommunityPrefix: function(component, event, helper){
        helper.callServer(
            component,
            "c.getCommunityPrefix",
            function (response) {
                if(response){
                    component.set("v.communityPrefix", response);
                }
            },
            { 
            }
        );
    },

    callServer: function(component, method, callback, params) {
        let action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this, response.getReturnValue());
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})