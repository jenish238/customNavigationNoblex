/**
     * Use the MetadataService and Zippex Classes to build and deploy a
     * DestructiveChanges package to batch delete inactive Flows and Process Builders
     * 
     * 08/24/20 -   Eric Smith -    Version 1.2     Changed deploy options to run an Apex Test so it will work in Production Orgs
     * 05/29/20 -   Eric Smith -    Version 1.1     Created an Apex-Defined Descriptor Class for the Flow Information
     * 05/09/20 -   Eric Smith -    Version 1.0
     * 
     * Apex-Defined Variable Descriptor Class:      FlowDatatableDescriptor.cls
     * 
     */

public with sharing class DeployDeleteInactiveFlows {

    Static final Integer SLEEP_MULTIPLIER = 1;
    Static final Integer SLEEP_START_SECONDS = 5;
    
    // Attributes passed in from the Flow
    public class Requests {

        @InvocableVariable(label='Flow Records Selected for Deletion')
        public String flowRecordString;

        @InvocableVariable(label='Wait for Deletions to Complete?')
        public Boolean waitForCompletion;

    }

    // Attributes passed back to the Flow
    public class Results {

        @InvocableVariable
        public String completedMessage;
    }

    // Expose this Action to the Flow
    @InvocableMethod
    public static List<Results> DeployDeleteInactiveFlows(List<Requests> requestList) {

        // Instantiate the record collection
        List<FlowDatatableDescriptor> flowRecords = new List<FlowDatatableDescriptor>();
        
        // Prepare the response to send back to the Flow
        Results response = new Results();
        List<Results> responseWrapper = new List<Results>();

        // Bulkify proccessing of multiple requests
        for (Requests req : requestList) {

            // Get Input Value(s)
            String flowRecordString = req.flowRecordString;
            Boolean waitForCompletion = req.waitForCompletion;

            // BEGIN APEX ACTION PROCESSING LOGIC
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            String testLevel = 'NoTestRun';

            String zippedFile = generateZipfile(flowRecordString);
            String jobId;
            if (!Test.isRunningTest()) {
                MetadataService.AsyncResult deployResult= service.deploy(zippedFile, getDeployOptions());
                jobId = deployResult.id;
            } else {
                getDeployOptions();
            }

            String status = 'InProgress';
            Integer counter = 0;
            Integer sleepTimer = 0;
            Integer delayInMilliseconds = 1000; // One-second delay
            Long startingTime;
            do {
                if (!Test.isRunningTest()) {
                    MetadataService.DeployResult result = service.checkDeployStatus(jobId,true);
                    System.debug('deploy status is: ' + result.status + ' ' + result.stateDetail + ' Sleep Timer: ' + sleepTimer);
                    status = result.status;
                }
                counter += 1;
                sleepTimer = (SLEEP_START_SECONDS + (counter * SLEEP_MULTIPLIER)) * delayInMilliseconds;
                startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
                while (System.now().getTime() - startingTime < sleepTimer)  {
                    // Do nothing until desired delay has passed
                }
            } while (status == 'InProgress' && waitForCompletion);

            // END APEX ACTION PROCESSING LOGIC

            // Set Output Values
            response.completedMessage = 'Deletion result is: ' + status;
            responseWrapper.add(response);
        }
        // Return values back to the Flow
        return responseWrapper;

    }   

    // public static String generateZipfile(List<FlowDatatableDescriptor> flowRecords) {
    public static String generateZipfile(String flowRecordString) {
        Zippex sampleZip = new Zippex();
        Blob fileData = Blob.valueOf(getPackageXml());
        sampleZip.addFile('package.xml', fileData, null);
        fileData = Blob.valueOf(getDestructiveChangesXml(flowRecordString));
        sampleZip.addFile('destructiveChanges.xml', fileData, null);
        return EncodingUtil.base64Encode(sampleZip.getZipArchive());
    }

    public static MetadataService.DeployOptions getDeployOptions(){
                
        MetadataService.DeployOptions lvDeployOption = new MetadataService.DeployOptions();
        lvDeployOption.allowMissingFiles = false;
        lvDeployOption.autoUpdatePackage = true;
        lvDeployOption.checkOnly = false;
        lvDeployOption.ignoreWarnings = true;
        lvDeployOption.performRetrieve = false;
        lvDeployOption.purgeOnDelete = false;
        lvDeployOption.rollbackOnError = true;
        // lvDeployOption.runTests = new String[]{};
        lvDeployOption.runTests = new String[]{'DeployDeleteInactiveFlowsTest'};
        lvDeployOption.singlePackage = true;
        // lvDeployOption.testLevel = 'NoTestRun';
        lvDeployOption.testLevel = 'RunSpecifiedTests';
            
        return lvDeployOption;
    }

    public static String getPackageXml() {
        return  '<?xml version="1.0" encoding="UTF-8"?>' + 
                '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
                    '<version>41.0</version>' +
                '</Package>';	
    }
    
    public static String getDestructiveChangesXml(String flowRecordString) {

        List<FlowDatatableDescriptor> flowRecords = (List<FlowDatatableDescriptor>)System.JSON.deserialize(flowRecordString, List<FlowDatatableDescriptor>.class);

        String retFile;
        retFile =   '<?xml version="1.0" encoding="UTF-8"?>' +
                    '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
                        '<types>';
        
        for (FlowDatatableDescriptor fn : flowRecords) {
            if (fn.Status != 'Active') {
                retFile = retFile + '<members>'+fn.ApiName+'-'+String.valueOf(fn.VersionNumber)+'</members>';
            }
        }

        retFile = retFile +
                            '<name>Flow</name>' + 
                        '</types>' + 
                    '</Package>';
  
        return retFile;
    }

}