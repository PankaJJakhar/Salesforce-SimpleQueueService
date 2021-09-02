/**
 * Created by pankajjakhar on 2/09/21.
 */

public with sharing class UserInfoMessageHandler implements IQueueMessageHandler {
    private static UserInfoMessageHandler INSTANCE;

    private List<QueueMessage__c> queueMessagesList;

    public UserInfoMessageHandler() {
        queueMessagesList = new List<QueueMessage__c>();
    }

    public static IQueueMessageHandler getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new UserInfoMessageHandler();
        }

        return INSTANCE;
    }

    public void addMessage(QueueMessage__c queueMessage) {
        queueMessagesList.add(queueMessage);
    }

    public void process() {
        // Perform the action that you want to perform in this handler
    }
}