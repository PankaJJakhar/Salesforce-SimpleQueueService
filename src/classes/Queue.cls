/**
 * Created by pankajjakhar on 2/09/21.
 */
public with sharing class Queue {
    private Map<String, String> eventTypeToMessageHandlerMap;
    private Map<String, IQueueMessageHandler> eventTypeToMessageHandlerInstanceMap;

    private List<QueueMessage__c> queueMessagesList;

    public Queue(List<QueueMessage__c> queueMessagesList) {
        System.debug(LoggingLevel.DEBUG, 'Queue Initialised');

        this.queueMessagesList = queueMessagesList;

        eventTypeToMessageHandlerMap = new Map<String, String>();
        eventTypeToMessageHandlerInstanceMap = new Map<String, IQueueMessageHandler>();

        initializeQueueConfigurations();
    }

    private void initializeQueueConfigurations() {
        List<QueueConfiguration__mdt> queueConfigurationsList = [
                SELECT
                        DeveloperName,
                        EventType__c,
                        Id,
                        IsActive__c,
                        Label,
                        Language,
                        MasterLabel,
                        MessageHandlerClassName__c,
                        NamespacePrefix,
                        QualifiedApiName
                FROM QueueConfiguration__mdt
                WHERE IsActive__c = TRUE
        ];

        for (QueueConfiguration__mdt queueConfiguration : queueConfigurationsList) {
            eventTypeToMessageHandlerMap.put(queueConfiguration.EventType__c, queueConfiguration.MessageHandlerClassName__c);
        }
    }

    public void submit() {
        distribute();
        process();
    }

    private void distribute() {
        for (QueueMessage__c queueMessage : queueMessagesList) {
            IQueueMessageHandler handler;

            String eventType = queueMessage.EventType__c;

            if (eventTypeToMessageHandlerInstanceMap.containsKey(eventType) == false) {
                Type classType = Type.forName(eventTypeToMessageHandlerMap.get(eventType));
                handler = (IQueueMessageHandler) classType.newInstance();

                eventTypeToMessageHandlerInstanceMap.put(eventType, handler);
            } else {
                handler = eventTypeToMessageHandlerInstanceMap.get(eventType);
            }

            handler.addMessage(queueMessage);
        }
    }

    private void process() {
        for (IQueueMessageHandler handler : eventTypeToMessageHandlerInstanceMap.values()) {
            handler.process();
        }
    }
}