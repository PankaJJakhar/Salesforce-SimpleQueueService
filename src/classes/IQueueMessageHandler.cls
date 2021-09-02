/**
 * Created by pankajjakhar on 2/09/21.
 */
public interface IQueueMessageHandler {
    void addMessage(QueueMessage__c queueMessage);
    void process();
}