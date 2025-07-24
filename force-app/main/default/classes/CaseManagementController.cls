public with sharing class CaseManagementController {
    
    /**
     * Retrieves all open cases from the database
     * @return List of open Case records
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getOpenCases() {
        try {
            return [
                SELECT Id, CaseNumber, Subject, Priority, Status, CreatedDate, Account.Name, Contact.Name
                FROM Case 
                WHERE Status != 'Closed' 
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving open cases: ' + e.getMessage());
        }
    }
    
    /**
     * Closes a specific case by updating its status to 'Closed'
     * @param caseId The ID of the case to close
     * @return Success message or error
     */
    @AuraEnabled
    public static String closeCase(Id caseId) {
        try {
            Case caseToUpdate = new Case(
                Id = caseId,
                Status = 'Closed'
            );
            
            update caseToUpdate;
            return 'Case closed successfully';
            
        } catch (Exception e) {
            throw new AuraHandledException('Error closing case: ' + e.getMessage());
        }
    }
}