public with sharing class Exrcise4 {

    public static void fillOfferIdentifier(List<Offer__c> newList, Map<Id, Offer__c> oldMap) {
        // Group new offers by Opportunity__c (since Offer Id is null before insert)
        Map<Id, List<Offer__c>> oppIdToOffersMap = new Map<Id, List<Offer__c>>();
        for (Offer__c offer : newList) {
            if (offer.Opportunity__c == null) continue;

            if (oldMap == null || offer.Opportunity__c != oldMap.get(offer.Id)?.Opportunity__c) {
                if (!oppIdToOffersMap.containsKey(offer.Opportunity__c)) {
                    oppIdToOffersMap.put(offer.Opportunity__c, new List<Offer__c>());
                }
                oppIdToOffersMap.get(offer.Opportunity__c).add(offer);
            }
        }

        // Debug
        System.debug('oppIdToOffersMap: ' + oppIdToOffersMap);

        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, Identifier__c, TECH_OfferCount__c FROM Opportunity WHERE Id IN :oppIdToOffersMap.keySet()]
        );

        
        for (Id oppId : oppIdToOffersMap.keySet()) {
            Opportunity opp = oppMap.get(oppId);
            if (opp == null) continue;

            Integer existingCount = opp.TECH_OfferCount__c != null ? opp.TECH_OfferCount__c.intValue() : 0;
            Integer counter = 0;

            for (Offer__c offer : oppIdToOffersMap.get(oppId)) {
                Integer totalCount = existingCount + counter;

                String countToDisplay;
                if (totalCount < 10) {
                    countToDisplay = '00' + totalCount;
                } else if (totalCount < 100) {
                    countToDisplay = '0' + totalCount;
                } else {
                    countToDisplay = String.valueOf(totalCount);
                }
                System.debug('opp.Identifier__c'+opp.Identifier__c);
                offer.Identifier__c = opp.Identifier__c + '-' + countToDisplay;
                counter++;
            }
        }
    }
}
