public with sharing class LWCRelatedOppsToAccs {
    
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts(){
        return [SELECT Id, Name FROM Account];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getRelatedOpps(Id accId){
        return [
        SELECT Id, Name, StageName, Amount
        FROM Opportunity
        WHERE AccountId = :accId
        ORDER BY Amount DESC
        ];    }
        
        @AuraEnabled(cacheable=true)
        public static List<AccountSummary> getTopAccounts() {
            List<AggregateResult> results = [
            SELECT AccountId, Account.Name name, SUM(Amount) totalAmount
            FROM Opportunity
            WHERE IsClosed = FALSE AND Amount != null AND AccountId != null
            GROUP BY AccountId, Account.Name
            ORDER BY SUM(Amount) DESC
            LIMIT 5
            ];
            
            List<AccountSummary> summaries = new List<AccountSummary>();
            for (AggregateResult ar : results) {
                summaries.add(new AccountSummary(
                (Id)ar.get('AccountId'),
                (String)ar.get('name'),
                (Decimal)ar.get('totalAmount')
                ));
            }
            return summaries;
        }
        
        public class AccountSummary {
            @AuraEnabled public Id accountId;
            @AuraEnabled public String accountName;
            @AuraEnabled public Decimal totalAmount;
            
            public AccountSummary(Id id, String name, Decimal amount) {
                accountId = id;
                accountName = name;
                totalAmount = amount;
            }
        }
        
        @AuraEnabled(cacheable = true)
        public static List<Contact> getRelatedContacts(Id accId){
            return [
            SELECT 
            Id, FirstName, LastName, Phone , Email 
            From Contact 
            WHERE AccountId = : accId
            ];
        }
        
        @AuraEnabled
        public static void updateContact(Contact contact) {
            update contact;
        }
        
        
        @AuraEnabled(cacheable=true)
        public static List<SObject> getRecords(String objectApiName, String searchKey) {
            if (String.isBlank(objectApiName) || String.isBlank(searchKey)) return new List<SObject>();
            
            String query = 'SELECT Id, Name FROM ' + String.escapeSingleQuotes(objectApiName) +
            ' WHERE Name LIKE :searchKey LIMIT 10';
            return Database.query(query);
        }
        
        @AuraEnabled
        public static Account createAccount(String accName) {
            if (String.isBlank(accName)) {
                throw new AuraHandledException('Account name cannot be empty');
            }
            
            Account acc = new Account(Name = accName);
            insert acc;
            return acc;
        }
        
    }