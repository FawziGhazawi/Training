public with sharing class QuoteCreationController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunity(Id oppId) {
        return [
        SELECT Id, Name, Lease_Type__c, StageName 
        FROM Opportunity 
        WHERE Id = :oppId 
        LIMIT 1
        ];
    }
    
    @AuraEnabled
    public static String createQuote(Id opportunityId, Map<String, Object> formData) {
        try {
            List<Opportunity> opps = [SELECT Id, Lease_Type__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
            if (opps.isEmpty()) {
                throw new AuraHandledException('Opportunity not found for Id: ' + opportunityId);
            }
            Opportunity opp = opps[0];
            
            Quote__c quote = new Quote__c();
            quote.Opportunity__c = opp.Id;
            
            // Common field
            if (formData.containsKey('startDate')) {
                quote.Proposed_Start_Date__c = Date.valueOf((String)formData.get('startDate'));
            }
            
            // OFFICE or RETAIL
            if (opp.Lease_Type__c == 'Office' || opp.Lease_Type__c == 'Retail') {
                if (formData.containsKey('endDate')) {
                    quote.Proposed_End_Date__c = Date.valueOf((String)formData.get('endDate'));
                }
                if (formData.containsKey('paymentTerms')) {
                    quote.Payment_Terms__c = Integer.valueOf((String)formData.get('paymentTerms'));
                }
                if (formData.containsKey('gracePeriod')) {
                    quote.Grace_Period__c = Integer.valueOf((String)formData.get('gracePeriod'));
                }
                if (opp.Lease_Type__c == 'Retail' && formData.containsKey('retailCategory')) {
                    quote.Retail_Sales_Category__c = (String)formData.get('retailCategory');
                }
            }
            
            // LAND
            if (opp.Lease_Type__c == 'Land') {
                if (formData.containsKey('duration')) {
                    quote.Lease_Duration__c = (String)formData.get('duration'); // Picklist
                }
                if (formData.containsKey('rentReview')) {
                    quote.Rent_Review_Frequency__c = Integer.valueOf((String)formData.get('rentReview'));
                }
                
                // Static payment term for Land
                quote.Payment_Terms__c = 4;
            }
            
            insert quote;
            return quote.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void uploadFile(Id parentId, String base64, String fileName) {
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = EncodingUtil.base64Decode(base64);
        insert cv;
        
        Id docId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id = :cv.Id 
        LIMIT 1
        ].ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'V';
        insert cdl;
    }
}
