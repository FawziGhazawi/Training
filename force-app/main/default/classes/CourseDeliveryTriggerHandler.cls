public class CourseDeliveryTriggerHandler {

    //TODO #1: Review the following static initialization block.
    //  It encapsulates some of the logic that was formerly found in the 
    //  trigger.  We moved the declaration and query of the set of holiday 
    //  dates to a static initialization block because the data is likely 
    //  not to change within the apex transaction context and this ensures
    //  the query is executed exactly once regardless how many times the
    //  preventInvalidCourseDeliveries() method is called in a given 
    //  transaction.  This kind of caching helps to stay within SOQL 
    //  query limits.
    public static Set<Date> allHolidays = new Set<Date>();

    static {
        for (Holiday h : [SELECT ActivityDate FROM Holiday]) {
            allHolidays.add(h.ActivityDate);
        }
    }

    //TODO #2: Review the following static method.
    // It encapsulates the logic that was formerly found in the trigger.
    // It is static, so it can be invoked without instantiating the class.
    // Notice that instead of referencing Trigger.new and Trigger.oldMap directly as 
    // was done in the trigger block, we now reference the trigger context variables passed
    // in as arguments to this method in order to improve testability and code reuse.


    public static void preventInvalidCourseDeliveries(List<Course_Delivery__c> newCourseDeliveryList,
        Map<ID, Course_Delivery__c> oldCourseDeliveryMap) {

        for (Course_Delivery__c cd : newCourseDeliveryList) {
            if (oldCourseDeliveryMap?.get(cd.Id).Start_Date__c != cd.Start_Date__c) {   
                if ( allHolidays.contains(cd.Start_Date__c) ) {
                    cd.Start_Date__c.addError(Label.Invalid_Delivery_Start_Date);

                    // TODO #1
                    // Immediately Publish a platform event with details of the error
                    Error_Message__e event = new Error_Message__e();
                    event.Source_Component__c = 'CourseDeliveryTriggerHandler';
                    event.Error_Message__c = 'ERROR: ' + Label.Invalid_Delivery_Start_Date;
                    EventBus.publish(event);
                }
            }
        }
    }

    /*public static void preventDeletePastDeliveries(List<Course_Delivery__c> oldCourseDeliveryList) {
        Set<Id> cdIds = new Set<Id>();
        for (Course_Delivery__c cd : oldCourseDeliveryList) {
            cdIds.add(cd.Id);
        }
    
        List<Course_Delivery__c> deliveries = [
            SELECT Id, Start_Date__c, Course__r.Duration__c
            FROM Course_Delivery__c
            WHERE Id IN :cdIds
        ];
    
        for (Course_Delivery__c cd : deliveries) {
            Date startDate = cd.Start_Date__c;
            Integer duration = Integer.valueOf(cd.Course__r.Duration__c);
    
            if (startDate != null && duration != null) {
                Date calculatedEndDate = startDate.addDays(duration);
    
                if (calculatedEndDate < Date.today()) {

                    for (Course_Delivery__c oldCd : oldCourseDeliveryList) {
                        if (oldCd.Id == cd.Id) {
                            oldCd.Start_Date__c.addError('Can\'t delete an already finished course!');
                            break;
                        }
                    }
                }
            }
        }
    }
    
    // public static void preventDeletePastDeliveries(List<Course_Delivery__c> oldCourseDelivery){
    //     for(Course_Delivery__c cd : oldCourseDelivery){
    //     Date endDate = cd.End_Date__c;
    //     Date currentDate = Date.today();
    //     if(endDate != null && endDate < currentDate){
    //         cd.End_Date__c.addError('Can\'t delete an already finished course!');
    //     }
    //     }


    // }*/

}