@isTest
public with sharing class OfferTriggerHandlerTest {

    @TestSetup
    static void makeData(){

        // Test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Test Opportunity linked to Account
        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity 1', AccountId = acc.Id, CloseDate = Date.today(),StageName = 'Prospecting', Identifier__c = 'op1');
        insert opp1;


    }

    @isTest
    static void FillOfferIdentifierTest() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp1 = [SELECT Id FROM Opportunity LIMIT 1];

        Offer__c offer1 = new Offer__c(Name = 'Test Offer 1 opp 000', Opportunity__c = opp1.Id);
        insert offer1;

        offer1 = [SELECT Id, Identifier__c FROM Offer__c WHERE Id = :offer1.Id ];

        System.debug('offer1>>>>' + offer1);
        
        System.assertEquals((offer1.Identifier__c ), 'op1-000');

        Offer__c offer2 = new Offer__c(Name = 'Test Offer 1 opp 001', Opportunity__c = opp1.Id);
        insert offer2;

        offer2 = [SELECT Id, Identifier__c FROM Offer__c WHERE Id = : offer2.Id ];

        System.assertEquals((offer2.Identifier__c ), 'op1-001');

    }
}