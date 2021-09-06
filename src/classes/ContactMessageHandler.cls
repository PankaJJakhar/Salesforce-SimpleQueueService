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
public with sharing class ContactMessageHandler implements IQueueMessageHandler {
    public class ContactMessage {
        public String contactId { get; set; }
        public String phone { get; set; }
    }

    private List<QueueMessage__c> queueMessagesList;
    private List<Contact> contactsToUpdateList;

    public ContactMessageHandler() {
        System.debug(LoggingLevel.DEBUG, 'ContactMessageHandler.ContactMessageHandler');

        queueMessagesList = new List<QueueMessage__c>();
        contactsToUpdateList = new List<Contact>();
    }

    public void addMessage(QueueMessage__c queueMessage) {
        queueMessagesList.add(queueMessage);
    }

    public void process() {
        // Perform the action that you want to perform in this handler
        for (QueueMessage__c queueMessage : queueMessagesList) {
            ContactMessage message = (ContactMessage) JSON.deserialize(queueMessage.Body__c, ContactMessage.class);

            contactsToUpdateList.add(new Contact(
                    Id = message.contactId,
                    Phone = message.phone
            ));

            queueMessage.Status__c = QueueConstants.QUEUE_MESSAGE_STATUS_PROCESSED;
        }

        update contactsToUpdateList;
        update queueMessagesList;
    }
}