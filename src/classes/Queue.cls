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