/**
 * MIT License
 *
 * Copyright (c) 2021 PankaJJakhar
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 * OR OTHER DEALINGS IN THE SOFTWARE.
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

        Savepoint dbSavepoint = Database.setSavepoint();

        try {
            Queue processQueue = new Queue(queueMessagesList);
            processQueue.submit();
        } catch (Exception ex) {
            Database.rollback(dbSavepoint);

            System.debug(LoggingLevel.ERROR, 'QueueSchedulerJob -> execute() -> Exception: ' + ex.getMessage() +
                    +'\n' + ex.getStackTraceString());
        }

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