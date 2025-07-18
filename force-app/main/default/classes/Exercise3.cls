public with sharing class Exercise3 {

    // ----- Prevents the creation of a competitor in case the account related to it is found on another competitor if related to opportunity or quote ---- //
    public static void checkCompetitorLinks(List<Competitor__c> newList, Map<Id,Competitor__c> oldMap, Map<Id,Competitor__c> newMap){

        // Creating a map of Account IDs to Competitors. One for the quotes and one for the opps
        Map<Id,Competitor__c> accountIdsToCompetitorForQuotesMap = new Map<Id,Competitor__c>();
        Map<Id,Competitor__c> accountIdsToCompetitorForOppsMap = new Map<Id,Competitor__c>();

        // Looping over the new list of created competitors
        for(Competitor__c comp : newList){

            // If the old map is null (ie: in a create state) or the quote has been changed or the account has been changed
            if(
                (oldMap == null || oldMap.get(comp.Id).Quote__c != comp.Quote__c || oldMap.get(comp.Id).Account__c != comp.Account__c)
                    && 
                (comp.Quote__c != null && comp.Account__c != null)
            ) {
                // Add the account Id and the competitor to the corresponsing map
                accountIdsToCompetitorForQuotesMap.put(comp.Account__c,comp);
            }

            // If the old map is null (ie: in a create state) or the opportunity has been changed or the account has been changed
            if(
                (oldMap == null || oldMap.get(comp.Id).Opportunity__c != comp.Opportunity__c || oldMap.get(comp.Id).Account__c != comp.Account__c)
                    &&
                (comp.Opportunity__c != null && comp.Account__c != null)
            ) {
                // Add the account Id and the competitor to the corresponsing map
                accountIdsToCompetitorForOppsMap.put(comp.Account__c,comp);
            }
        }

        // If the map isn't empty
        if(!accountIdsToCompetitorForQuotesMap.isEmpty()){

            // Looping over all the accounts that have the account ids in the map and quote is not null
            for(Competitor__c comp : [SELECT Id,Account__c FROM Competitor__c WHERE Account__c IN :accountIdsToCompetitorForQuotesMap.keySet() AND Quote__c != null]){

                // If the comprtitor is not part of the current transaction
                if(oldMap == null || !newMap.keySet().contains(comp.Id)){
                    // Getting the competitor from the filled map
                    Competitor__c accountComp = accountIdsToCompetitorForQuotesMap.get(comp.Account__c);

                    // Adding the error
                    accountComp.addError('This Account is already used on both a Quote and an Opportunity in other Competitor records.');
                }
                
            }
        }
        
        // If the map isn't empty
        if(!accountIdsToCompetitorForOppsMap.isEmpty()){

            // Looping over all the accounts that have the account ids in the map and opportunity is not null
            for(Competitor__c comp : [SELECT Id,Account__c FROM Competitor__c WHERE Account__c IN :accountIdsToCompetitorForOppsMap.keySet() AND Opportunity__c != null]){

                // If the comprtitor is not part of the current transaction
                if(oldMap == null || !newMap.keySet().contains(comp.Id)){
                    // Getting the competitor from the filled map
                    Competitor__c accountComp = accountIdsToCompetitorForOppsMap.get(comp.Account__c);

                    // Adding the error
                    accountComp.addError('This Account is already used on both a Quote and an Opportunity in other Competitor records.');
                }
            }
        }
        
    }

    // ----- Responsible for assigning the account to the existing opportunity in case the account is assigned to a quote ----- //
    public static void assignCompetitorToAccount(List<Competitor__c> newList, Map<Id,Competitor__c> oldMap){

        // Creating a quote Id to Account Id map to query the quote and assign them to competitor Account
        Map<Id,Id> quoteIdToAccountId = new Map<Id,Id>();

        // Looping over the new list of competitors
        for(Competitor__c comp : newList){

            // If old map is null or quote has been changed and the quote and account are filled in
            if((oldMap == null || oldMap.get(comp.Id).Quote__c != comp.Quote__c) && comp.Quote__c != null && comp.Account__c != null){

                // Adding the comp quote (key) and comp account (value) to the map
                quoteIdToAccountId.put(comp.Quote__c, comp.Account__c);
            }
        }

        // If the map is not empty (ie: Their has been assignment to a qupte related to account)
        if(!quoteIdToAccountId.isEmpty()){

            // The competitor list that will be inserted
            List<Competitor__c> compList = new List<Competitor__c>();

            // Looping over all the quotes that have the key inside the map in order to get the opportunity related to them
            for(Quote__c quote : [SELECT Opportunity__c,Opportunity__r.Name FROM Quote__c WHERE Id IN :quoteIdToAccountId.keySet()]){

                // Creating the competitor
                Competitor__c comp = new Competitor__c(Account__c = quoteIdToAccountId.get(quote.Id), Opportunity__c = quote.Opportunity__c,Name = 'Comp ' + quote.Opportunity__r.Name);

                // Adding it to the list
                compList.add(comp);
            }

            // Making it as a Database.insert with allOrNone as false because the comp creation might fail if the account is already related to an opportunity
            Database.insert(compList,false);
        }

    }
}
/*
part 1
    public static void CompetitorAccountRestriction(
        List<Competitor__c> triggerNew,
        Map<Id, Competitor__c> oldMap
    ) {
        Set<Id> accountsOnOpportunity = new Set<Id>();
        Set<Id> accountsOnQuote = new Set<Id>();

        Set<Id> competitorIds = new Set<Id>();
        for (Competitor__c cmp : triggerNew) {
            competitorIds.add(cmp.Id);
        }
        System.debug('competitorIds>>>>'+competitorIds);
        for (Competitor__c cmp : triggerNew) {
            Competitor__c oldCmp = oldMap != null ? oldMap.get(cmp.Id) : null;

            Boolean isChanged = oldCmp == null || 
                oldCmp.Account__c != cmp.Account__c ||
                oldCmp.Opportunity__c != cmp.Opportunity__c ||
                oldCmp.Quote__c != cmp.Quote__c;

            if (cmp.Account__c != null && isChanged) {

                if (cmp.Quote__c != null) {
                    accountsOnQuote.add(cmp.Account__c);
                }
                if (cmp.Opportunity__c != null) {
                    accountsOnOpportunity.add(cmp.Account__c);
                }
            }
        }

        Set<Id> conflictingAccounts = new Set<Id>();
        Set<Id> commonAccounts = new Set<Id>();
        commonAccounts.addAll(accountsOnQuote);
        commonAccounts.addAll(accountsOnOpportunity);

        System.debug('commonAccount>>>>'+commonAccounts);


List<Competitor__c> existingCompetitors = [
    SELECT Id, Account__c, Quote__c, Opportunity__c
    FROM Competitor__c
    WHERE Account__c IN :commonAccounts
    AND Id NOT IN :competitorIds
];

for (Competitor__c cmp : triggerNew) {
    for (Competitor__c existing : existingCompetitors) {
        if (
            cmp.Account__c == existing.Account__c &&
            (
                (cmp.Quote__c != null && existing.Opportunity__c != null) ||
                (cmp.Opportunity__c != null && existing.Quote__c != null)
            )
        ) {
            cmp.addError('This Account is already used on both a Quote and an Opportunity in other Competitor records.');
            break;
        }
    }
}
    }
*/