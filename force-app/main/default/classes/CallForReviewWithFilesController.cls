public with sharing class CallForReviewWithFilesController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<ContentDocument>> getRelatedDocuments(Id workOrderId) {
        Map<String, List<ContentDocument>> result = new Map<String, List<ContentDocument>>();
        
        System.debug('workOrderId>>>'+workOrderId);
        if (workOrderId == null) return result;
        // Get Account and Contact IDs from Work Order
        WorkOrder wo = [
            SELECT Id, AccountId, ContactId 
            FROM WorkOrder 
            WHERE Id = :workOrderId 
            LIMIT 1
        ];

        System.debug('wo>>>'+wo);
        
        Set<Id> entityIds = new Set<Id>();
        entityIds.add(workOrderId); // Always include the work order itself
        
        if (wo.AccountId != null) entityIds.add(wo.AccountId);
        if (wo.ContactId != null) entityIds.add(wo.ContactId);
        
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :entityIds
        ];

        System.debug('docLinks>>>'+docLinks);
        
        Set<Id> docIds = new Set<Id>();
        Map<Id, String> entityMap = new Map<Id, String>();
        for (ContentDocumentLink link : docLinks) {
            docIds.add(link.ContentDocumentId);
            if (link.LinkedEntityId == wo.AccountId) {
                entityMap.put(link.ContentDocumentId, 'Account');
            } else if (link.LinkedEntityId == wo.ContactId) {
                entityMap.put(link.ContentDocumentId, 'Contact');
            } else if (link.LinkedEntityId == workOrderId) {
                entityMap.put(link.ContentDocumentId, 'WorkOrder');
            }
        }
        
        Map<Id, ContentDocument> docMap = new Map<Id, ContentDocument>(
            [SELECT Id, Title FROM ContentDocument WHERE Id IN :docIds]
        );

        System.debug('docMap>>>'+docMap);
        
        for (Id docId : docMap.keySet()) {
            String type = entityMap.get(docId);
            if (!result.containsKey(type)) {
                result.put(type, new List<ContentDocument>());
            }
            result.get(type).add(docMap.get(docId));
        }
        System.debug('result>>>'+result);
        return result;
    }
    
@AuraEnabled
    public static void submitReview(
        Id workOrderId,
        String missingInfoDescription,
        List<String> selectedFileIds,
        List<String> requestedFileNames,
        List<String> requestedFileTypes,
        String accountMissingInfo,
        String contactMissingInfo,
        String workOrderMissingInfo
    ) {
        System.debug('selectedFileIds>>>'+selectedFileIds);
        System.debug('requestedFileNames>>>'+requestedFileNames);
        System.debug('requestedFileTypes>>>'+requestedFileTypes);
        if (String.isBlank(workOrderId)) {
            throw new AuraHandledException('Missing Work Order Id.');
        }
        
        WorkOrder wo = [SELECT Id, Status__c FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
        System.debug('wo>>>'+wo);
        if (wo.Status__c != 'Submitted') {
            throw new AuraHandledException('Only Submitted Work Orders can be called for review.');
        }
        
        wo.Status__c = 'Call for Review';
        wo.Missing_Info_Description__c = missingInfoDescription;
        update wo;
        
        List<Work_Order_Review_Document__c> toInsert = new List<Work_Order_Review_Document__c>();
        
        // Handle selected files
        for (String fileId : selectedFileIds) {
            toInsert.add(new Work_Order_Review_Document__c(
                Name = 'Selected: ' + fileId,
                Related_To_Id__c = fileId,
                Is_Requested__c = false,
                Work_Order__c = workOrderId
            ));
        }
        
        // Handle requested files
        for (Integer i = 0; i < requestedFileNames.size(); i++) {
            String fileName = requestedFileNames[i];
            String fileType = i < requestedFileTypes.size() ? requestedFileTypes[i] : '';
            String missingInfo = '';
            
            // Assign missing info based on file type
            if (fileType == 'Account') {
                missingInfo = accountMissingInfo;
            } else if (fileType == 'Contact') {
                missingInfo = contactMissingInfo;
            } else if (fileType == 'WorkOrder') {
                fileType = 'Work Order';
                missingInfo = workOrderMissingInfo;
            }
            
            toInsert.add(new Work_Order_Review_Document__c(
                Name = fileName,
                Related_To_Type__c = fileType,
                Missing_Info_Description__c = missingInfo,
                Is_Requested__c = true,
                Work_Order__c = workOrderId
            ));
        }
        
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
}