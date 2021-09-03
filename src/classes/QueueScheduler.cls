/**
 * Created by pankajjakhar on 3/09/21.
 */
public with sharing class QueueScheduler implements Database.Batchable<sObject> {
    private List<QueueMessage__c> queueMessagesList;

    private Set<Id> queueMessageIdsSet;

    public QueueScheduler(List<QueueMessage__c> queueMessagesList) {
        queueMessageIdsSet = new Set<Id>();
        this.queueMessagesList = queueMessagesList;

        for (QueueMessage__c queueMessage : queueMessagesList) {
            queueMessageIdsSet.add(queueMessage.Id);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String query = ' SELECT Id,' +
                '    Body__c, ' +
                '    EventType__c, ' +
                '    Status__c ' +
                ' WHERE ID IN :queueMessageIdsSet';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<QueueMessage__c> queueMessagesList) {
        Queue processQueue = new Queue(queueMessagesList);
        processQueue.submit();
    }

    public void finish(Database.BatchableContext batchableContext) {

    }
}