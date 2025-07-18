trigger CompetitorTrigger on Competitor__c (before insert, before update, before delete, after insert, after update, after delete) {
    new CompetitorTriggerHandler().run();
}
