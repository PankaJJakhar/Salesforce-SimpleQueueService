/**
 * Created by pankajjakhar on 3/09/21.
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