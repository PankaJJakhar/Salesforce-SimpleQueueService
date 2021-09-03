/**
 * Created by pankajjakhar on 2/09/21.
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

        QueueScheduler scheduler = new QueueScheduler(queueMessagesList);
        Database.executeBatch(scheduler);
        //Queue processQueue = new Queue(queueMessagesList);
        //processQueue.submit();
    }

}