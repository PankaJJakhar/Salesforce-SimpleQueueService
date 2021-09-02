/**
 * Created by pankajjakhar on 2/09/21.
 */
trigger QueueMessageTrigger on QueueMessage__c (after insert) {
    fflib_SObjectDomain.triggerHandler(QueueMessages.class);
}