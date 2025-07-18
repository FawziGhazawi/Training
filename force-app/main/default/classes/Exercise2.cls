public with sharing class Exercise2 {
    
    public static void updateAccountsWithMatchingContactCounts(
        List<Contact> triggerNew,
        Map<Id, Contact> oldMap
    ) {
        Set<Id> accountIds = new Set<Id>();

        for (Contact cntct : triggerNew) {
            if (cntct.AccountId != null) {
                accountIds.add(cntct.AccountId);
            }
        }

        for (Contact cntct : oldMap.values()) {
            if (cntct.AccountId != null) {
                accountIds.add(cntct.AccountId);
            }
        }

        if (accountIds.isEmpty()) return;

        Map<Id, Integer> accIdToCountMap = new Map<Id, Integer>();

        for (Contact c : [
            SELECT Id, AccountId, FirstName, LastName
            FROM Contact
            WHERE AccountId IN :accountIds
            AND ((FirstName = null OR FirstName = '') OR LastName = 'Smith')
        ]) {
            if (c.AccountId != null) {

                Integer count = accIdToCountMap.containsKey(c.AccountId) ? accIdToCountMap.get(c.AccountId) : 0;
                accIdToCountMap.put(c.AccountId, count + 1);
            }
        }

        // for (AggregateResult ar : [
        //     SELECT AccountId accId, COUNT(Id) total
        //     FROM Contact
        //     WHERE AccountId IN :accountIds
        //     AND (FirstName = null OR FirstName = '' OR LastName = 'Smith')
        //     GROUP BY AccountId
        // ]) {
        //     accIdToCountMap.put((Id) ar.get('accId'), (Integer) ar.get('total'));
        //     System.debug('AccountId: ' + ar.get('accId'));
        //     System.debug('Count: ' + ar.get('total'));

        // }


        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Integer count = accIdToCountMap.containsKey(accId) ? accIdToCountMap.get(accId) : 0;
            accountsToUpdate.add(new Account(
                Id = accId,
                Contacts_Matching_Criteria__c = count
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}


/*
public with sharing class Exercise2 {
    public static void countEmpty(
    Map<Id, Contact> oldMap,
    List<Contact> TriggerNew
    ){
        Set<Id> accountIdsSet = new Set<Id>();
        for(Contact cntc: TriggerNew)
        {
            if((oldMap?.get(cntc.Id).FirstName != cntc.FirstName || oldMap?.get(cntc.Id).LastName != cntc.LastName) && cntc.AccountId != null){
                accountIdsSet.add(cntc.AccountId);
            }
        }
        List<Account> accountsToUpdateList = new List<Account>();
        for(Account acc: [SELECT Id, (SELECT Id FROM Contacts WHERE FirstName = '' OR LastName = 'Smith') FROM Account WHERE Id IN: accountIdsSet])
        {
            acc.Nb_Unknown_Contacts__c = acc.Contacts.size();
            accountsToUpdateList.add(acc);
        }
        update accountsToUpdateList;
    }
}
*/