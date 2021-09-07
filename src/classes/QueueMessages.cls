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
public with sharing class QueueMessages extends fflib_SObjectDomain {

    public QueueMessages(List<QueueMessage__c> queueMessagesList) {
        super(queueMessagesList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> queueMessagesList) {
            return new QueueMessages(queueMessagesList);
        }
    }

    public override void onAfterInsert() {
        List<QueueMessage__c> queueMessagesList = (List<QueueMessage__c>) records;

        processQueueMessages(queueMessagesList);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<QueueMessage__c> queueMessagesList = (List<QueueMessage__c>) records;

        processQueueMessages(queueMessagesList);
    }

    private void processQueueMessages(List<QueueMessage__c> queueMessagesList) {
        List<QueueMessage__c> queueMessagesToProcessList = new List<QueueMessage__c>();

        for (QueueMessage__c queueMessage : queueMessagesList) {
            if (String.isNotBlank(queueMessage.Status__c) &&
                    queueMessage.Status__c.equalsIgnoreCase(QueueConstants.QUEUE_MESSAGE_STATUS_PROCESSED) == false) {
                queueMessagesToProcessList.add(queueMessage);
            }
        }

        if (queueMessagesToProcessList.size() > 0) {
            QueueSchedulerJob schedulerJob = new QueueSchedulerJob(queueMessagesToProcessList);
            Database.executeBatch(schedulerJob);
        }
    }
}