public with sharing class MyLWCController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getMethod(Integer maxRecords){
        return [SELECT Id, Name FROM Account LIMIT : maxRecords];
    }
}