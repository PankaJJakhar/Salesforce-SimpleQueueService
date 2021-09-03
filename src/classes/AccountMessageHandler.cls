/**
 * Created by pankajjakhar on 3/09/21.
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
        }

        update accountsToUpdateList;
    }
}