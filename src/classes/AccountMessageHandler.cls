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
public with sharing class AccountMessageHandler implements IQueueMessageHandler {
    public class AccountMessage {
        public String accountId { get; set; }
        public String site { get; set; }
    }

    private List<QueueMessage__c> queueMessagesList;
    private List<Account> accountsToUpdateList;

    public AccountMessageHandler() {
        System.debug(LoggingLevel.DEBUG, 'AccountMessageHandler.AccountMessageHandler');

        queueMessagesList = new List<QueueMessage__c>();
        accountsToUpdateList = new List<Account>();
    }

    public void addMessage(QueueMessage__c queueMessage) {
        queueMessagesList.add(queueMessage);
    }

    public void process() {
        // Perform the action that you want to perform in this handler
        for (QueueMessage__c queueMessage : queueMessagesList) {
            AccountMessage message = (AccountMessage) JSON.deserialize(queueMessage.Body__c, AccountMessage.class);

            accountsToUpdateList.add(new Account(
                    Id = message.accountId,
                    Site = message.site
            ));

            queueMessage.Status__c = QueueConstants.QUEUE_MESSAGE_STATUS_PROCESSED;
        }

        update accountsToUpdateList;
        update queueMessagesList;
    }
}