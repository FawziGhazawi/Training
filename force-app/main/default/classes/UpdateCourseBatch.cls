public with sharing class UpdateCourseBatch {
    public UpdateCourseBatch() {

    }
}

/*

Select Id from certification


global class MyBatchClass implements Database.Batchable<SObject> {

    // Step 1: Start method - defines the scope of records
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Collect Certification IDs first
        Set<Id> courseIds = new Set<Id>();

        for (Certification cert : [SELECT Id FROM Certification]) {
            courseIds.add(cert.Id);
        }

        // Now query Course_Attendee__c based on those Certification IDs
        return Database.getQueryLocator([
            SELECT Id, Course_Delivery__r.Course__r.Certification__c 
            FROM Course_Attendee__c 
            WHERE Course_Delivery__r.Course__r.Certification__c IN :courseIds
        ]);
    }

    // Step 2: Execute method - processes each batch of Course_Attendee__c records
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Course_Attendee__c> attendees = (List<Course_Attendee__c>) scope;

        for (Course_Attendee__c attendee : attendees) {
            // Example processing — you can update fields here
            attendee.Your_Field__c = 'Processed'; // replace with a real field
        }

        if (!attendees.isEmpty()) {
            update attendees;
        }
    }

    // Step 3: Finish method - post-processing like logging, email, etc.
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch process completed.');
        // Optional: Send notification or trigger another batch
    }
}

*/