/**
 * Created by pankajjakhar on 6/09/21.
 */
public with sharing class QueueSchedulerJob implements Database.Batchable<sObject> {
    private Set<Id> queueMessageIdsSet;
    private Set<String> statusSet;

    public QueueSchedulerJob(List<QueueMessage__c> queueMessagesList) {
        queueMessageIdsSet = new Set<Id>();
        statusSet = new Set<String>();

        for (QueueMessage__c queueMessage : queueMessagesList) {
            queueMessageIdsSet.add(queueMessage.Id);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        statusSet.add(QueueConstants.QUEUE_MESSAGE_STATUS_PENDING);
        statusSet.add(QueueConstants.QUEUE_MESSAGE_STATUS_FAILED);

        String query = ' SELECT Id, ' +
                '     Body__c, ' +
                '     EventType__c, ' +
                '     Status__c ' +
                ' FROM QueueMessage__c ' +
                ' WHERE ID IN :queueMessageIdsSet ' +
                ' AND Status__c IN :statusSet ';

        System.debug(LoggingLevel.DEBUG, 'QueueScheduler.start -> query: ' + query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<QueueMessage__c> queueMessagesList) {
        System.debug(LoggingLevel.DEBUG, 'QueueScheduler.execute -> queueMessagesList.size(): ' + queueMessagesList.size());

        Queue processQueue = new Queue(queueMessagesList);
        processQueue.submit();
    }

    public void finish(Database.BatchableContext batchableContext) {
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [
                SELECT Id,
                        Status,
                        NumberOfErrors,
                        JobItemsProcessed,
                        TotalJobItems,
                        CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :batchableContext.getJobId()
        ];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                a.CreatedBy.Email
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody
                ('The batch Apex job processed ' + a.TotalJobItems +
                        ' batches with ' + a.NumberOfErrors + ' failures.');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }
}