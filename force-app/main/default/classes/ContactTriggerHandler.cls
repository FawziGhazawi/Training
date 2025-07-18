public with sharing class ContactTriggerHandler extends TriggerHandler implements ITriggerHandler {

    private Map<Id, Contact> newMap;
    private Map<Id, Contact> oldMap;
    private List<Contact> TriggerNew;
    private List<Contact> TriggerOld;

    public ContactTriggerHandler() {
        this.newMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldMap = (Map<Id, Contact>) Trigger.oldMap;
        this.TriggerNew = (List<Contact>) Trigger.New;
        this.TriggerOld = (List<Contact>) Trigger.Old;
    }

    public static Boolean TriggerDisabled = false;

    public Boolean isDisabled() {
        return TriggerDisabled;
    }

    public override void afterInsert() {
        Exercise2.updateAccountsWithMatchingContactCounts(TriggerNew, new Map<Id, Contact>());
    }

    public override void afterUpdate() {
        Exercise2.updateAccountsWithMatchingContactCounts(TriggerNew, oldMap);
    }

    public override void afterDelete() {
        Exercise2.updateAccountsWithMatchingContactCounts(new List<Contact>(), oldMap);
    }

    public override void afterUnDelete() {
        Exercise2.updateAccountsWithMatchingContactCounts(TriggerNew, new Map<Id, Contact>());
    }


    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
}
