@isTest
private class ContactTriggerHandlerTest {
    @isTest
    static void testContactCountUpdateOnAccount() {
        // Create test Account
        Account acc = new Account(Name = 'Test Co.');
        insert acc;

        // Insert Contacts: 2 match (null + ''), 1 no match
        List<Contact> contacts = new List<Contact>{
            new Contact(AccountId = acc.Id, FirstName = null, LastName = 'Jackson'),   // match
            new Contact(AccountId = acc.Id, FirstName = '', LastName = 'Smith'),       // match
            new Contact(AccountId = acc.Id, FirstName = 'Mike', LastName = 'Lee'),      // no match
            new Contact(AccountId = acc.Id, FirstName = 'Mike', LastName = 'Smith')      // no match
        };
        insert contacts;

        // Verify field updated
        Account accFetched = [SELECT Contacts_Matching_Criteria__c FROM Account WHERE Id = :acc.Id];
        System.debug('Contact count: ' + accFetched.Contacts_Matching_Criteria__c);
        System.assertEquals(3, accFetched.Contacts_Matching_Criteria__c);  //  2 match

        // Delete 1 matching contact
        delete contacts[0];

        accFetched = [SELECT Contacts_Matching_Criteria__c FROM Account WHERE Id = :acc.Id];
        System.debug('Contact count after delete: ' + accFetched.Contacts_Matching_Criteria__c);
        System.assertEquals(2, accFetched.Contacts_Matching_Criteria__c);  //  1 match
    }
}
