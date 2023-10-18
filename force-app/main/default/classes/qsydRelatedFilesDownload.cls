public with sharing class qsydRelatedFilesDownload {
    
    
    /**
     * True if called from a community context
     *
     * @return true if called from a community context, otherwise return false
     */
    @AuraEnabled
    public static Boolean isCommunity() {
        Id siteId = Site.getSiteId();
        if (siteId != null) {
            return true;
        }
        return false;
    }
    
    /**
     * Get the community prefix, if available
     *
     * @return a community prefix, if available
     */
    @AuraEnabled
    public static String getCommunityPrefix() {
        return !String.IsBlank(Site.getPathPrefix()) ? Site.getPathPrefix().removeEndIgnoreCase('/s') : '';
    }
    
     /**
     * Synchronises a records existing content documents with file explorer files
     *
     * @param recordId
     *
     * @return a summary of synchronised file explorer files
     */
    @AuraEnabled
    public static String getFiles(String recordId) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        try {
            contentDocumentLinks = new List<ContentDocumentLink>([
                    SELECT ContentDocument.Title, 
                            ContentDocument.ContentSize,
                            ContentDocument.FileType,
                            ContentDocument.FileExtension,
                            ContentDocument.IsDeleted,
                            ContentDocument.OwnerId,
                            ContentDocumentId,
                            IsDeleted,
                            LinkedEntityId,
                            ShareType,
                            SystemModstamp,
                            Visibility
                    FROM ContentDocumentLink
                    WHERE ContentDocument.IsDeleted = FALSE
                    AND IsDeleted = FALSE
                    AND LinkedEntityId = :recordId
            ]);

            return JSON.serialize(contentDocumentLinks);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }


}