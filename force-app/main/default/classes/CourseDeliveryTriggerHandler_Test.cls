@isTest
private class CourseDeliveryTriggerHandler_Test {

    @testSetup
    private static void testSetupObjectDataFactory() {
        Course__c testCourse = new Course__c(Name = 'Test Course 1', Status__c = 'Active');
        insert testCourse;
        System.debug([SELECT Id, Name from Course__c]);

        // TODO #1: Review the code to see how we make use of a System.runAs block
        //          to avoid mixed DML errors and use Test.loadData to load Holiday
        //          records from a static resource file
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = [SELECT Id FROM User WHERE profileId = :p.Id LIMIT 1];
        System.runAs(u) {
            Test.loadData(Holiday.sObjectType, 'Test_Holidays');
            System.debug([SELECT Id, ActivityDate, Name FROM Holiday]);
        }
    }

    // This test method tests whether a Course Delivery
    // that is not scheduled on a Holiday can be inserted
    // with no errors.


    @isTest
	private static void insertCourseDeliverySuccess() {

        // TODO #2: Review the code to see how the variable course is being
        //          assigned the value of a course from the database.
        List<Course__c> activeCourses = [SELECT Id FROM Course__c LIMIT 1];
        Course__c course = activeCourses[0];

        Course_Delivery__c courseDelivery = new Course_Delivery__c();

        //TODO #3: Assign the Course__c field of the variable courseDelivery the
        //         value of the id field of the variable course.
        courseDelivery.Course__c = course.Id;

        //TODO #4: Review this code that assigns the start date 
        //         of courseDelivery.
        courseDelivery.Start_Date__c = Date.newInstance(2025, 12, 31);

        //TODO #5: Review this code that
        //         a) attempts to insert courseDelivery into the database and
        //         b) captures the results of the insert in insertResults
        Test.startTest();
        Database.SaveResult insertionResult = Database.insert(courseDelivery, false);
        Test.stopTest();

        // Determine if insertionResult contains any errors, and, if so, which errors
        Integer errorCount = 0;

        //TODO #6: Insert the custom label you created earlier
        if (!insertionResult.isSuccess()) {
            if (insertionResult.getErrors()[0].getMessage() == Label.Invalid_Delivery_Start_Date) {
                System.debug('Received expected error message');
            }
            ++errorCount;
        }
        
        //TODO #7: Use the assertEquals method of the System class to raise 
        //  an assertion if the number of errors reported by errorCount 
        //  does not equal 0.
        System.assertEquals(1, errorCount, 'ERROR: Expected no errors in this test');
    }
}