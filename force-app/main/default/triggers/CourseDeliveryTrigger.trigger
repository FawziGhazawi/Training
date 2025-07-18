trigger CourseDeliveryTrigger on Course_Delivery__c (before insert, before update, before delete) {

    // Retrieve the Custom Metadata Type record for this trigger
    Trigger_Switch__mdt tsw = Trigger_Switch__mdt.getInstance('Course_Delivery_Trigger');

    // If no Custom Metadata Type record found or if the active flag is set to true then execute the trigger logic
    if (tsw == null || tsw.Active_Flag__c == true) {

       // TODO #1: Invoke the static method of the CourseDeliveryTriggerHandler class called 
       // preventInvalidCourseDeliveries and pass in the Trigger.new and Trigger.oldMap variables.
       if(!Trigger.isDelete) CourseDeliveryTriggerHandler.preventInvalidCourseDeliveries(Trigger.new, Trigger.oldMap);
    //    else CourseDeliveryTriggerHandler.preventDeletePastDeliveries(Trigger.old);
    }
}

// //TODO #1: Enter the DML events
// trigger CourseDeliveryTrigger on Course_Delivery__c (before insert, before update, after undelete) {
    
//     Trigger_Switch__mdt tsw = Trigger_Switch__mdt.getInstance('Course_Delivery_Trigger');

//     if(tsw == null || tsw.Active_Flag__c == true){
            
//         //TODO #2: Review the for loop to see how we are populating allHolidays
//         //  We have assumed that there are no recurring Holidays, for simplicity's sake.
//         Set<Date> allHolidays = new Set<Date>();
//         for (Holiday h : [SELECT ActivityDate FROM Holiday]) {
//             allHolidays.add(h.ActivityDate);
//         }
        
//         for (Course_Delivery__c cd : Trigger.new) {

//             // Always check Inserts, but only check Updates when the Delivery Date just changed:
//             Boolean checkDate = (Trigger.isInsert || 
//                                 Trigger.isUndelete 
//                                 || Trigger.oldMap.get(cd.Id).Start_Date__c != cd.Start_Date__c);
//             if (checkDate && cd.Start_Date__c != NULL) {

//                 //TODO #3: Prevent the invoking DML action if the Start Date is 
//                 //  in the allHolidays set.  Create an If statement that 
//                 //  determines if the Set allHolidays contains the course delivery 
//                 //  Start Date. Use the addError method of the sObject class to
//                 //  add an error to the cd sObject using the custom label you defined earlier
//                 if (allHolidays.contains(cd.Start_Date__c)) {
//                     cd.Start_Date__c.addError(Label.Invalid_Delivery_Start_Date);
//                 }
//             }
//         }
//     }

// }