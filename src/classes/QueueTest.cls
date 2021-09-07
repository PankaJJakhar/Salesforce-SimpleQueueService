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
@IsTest(SeeAllData = false)
private class QueueTest {
    @TestSetup
    private static void createSeedData() {
        insert TestHelper.createUncommittedAccount();

        insert TestHelper.createUncommittedContact();
    }

    @IsTest
    private static void testBehavior() {
        Account accountRecord = [SELECT Id, Name FROM Account LIMIT 1];
        Contact contactRecord = [SELECT Id, Name FROM Contact LIMIT 1];

        List<QueueMessage__c> queueMessagesList = new List<QueueMessage__c>();

        String eventType = QueueConstants.EVENT_TYPE_UPDATE_ACCOUNT;
        QueueMessage__c queueMessage = TestHelper.getUncommittedQueueMessage(eventType);
        queueMessage.Body__c = getAccountMessageBody(accountRecord.Id);
        queueMessagesList.add(queueMessage);

        eventType = QueueConstants.EVENT_TYPE_UPDATE_CONTACT;
        queueMessage = TestHelper.getUncommittedQueueMessage(eventType);
        queueMessage.Body__c = getContactMessageBody(contactRecord.Id);
        queueMessagesList.add(queueMessage);

        Test.startTest();
        insert queueMessagesList;
        Test.stopTest();

        Account returnedAccountRecord = [SELECT Id, Site FROM Account LIMIT 1];
        Contact returnedContactRecord = [SELECT Id, Phone FROM Contact LIMIT 1];

        System.assertEquals(returnedAccountRecord.Site, 'www.wayne.com');
        System.assertEquals(returnedContactRecord.Phone, '4141414141');

        List<QueueMessage__c> returnedQueueMessagesList = [
                SELECT Id,
                        Status__c
                FROM QueueMessage__c
                WHERE Status__c = :QueueConstants.QUEUE_MESSAGE_STATUS_PROCESSED
        ];
        System.assert(returnedQueueMessagesList.size() == 2);
    }

    @IsTest
    private static void testBulkBehavior() {
        List<Account> accountsList = new List<Account>();

        Integer testSize = 200;

        for (Integer index = 0; index < testSize; index++) {
            accountsList.add(TestHelper.createUncommittedAccount());
        }

        insert accountsList;

        List<QueueMessage__c> queueMessagesList = new List<QueueMessage__c>();

        String eventType = QueueConstants.EVENT_TYPE_UPDATE_ACCOUNT;

        Set<Id> accountIdsSet = new Set<Id>();
        for (Account accountRecord : accountsList) {
            accountIdsSet.add(accountRecord.Id);

            QueueMessage__c queueMessage = TestHelper.getUncommittedQueueMessage(eventType);
            queueMessage.Body__c = getAccountMessageBody(accountRecord.Id);

            queueMessagesList.add(queueMessage);
        }

        Test.startTest();
        insert queueMessagesList;

        Set<Id> queueMessageIdsSet = new Set<Id>();
        for (QueueMessage__c queueMessage : queueMessagesList) {
            queueMessageIdsSet.add(queueMessage.Id);
        }
        Test.stopTest();

        List<Account> returnedAccountRecordsList = [SELECT Id, Site FROM Account WHERE ID IN :accountIdsSet];

        for (Account returnedAccountRecord : returnedAccountRecordsList) {
            System.assertEquals(returnedAccountRecord.Site, 'www.wayne.com');
        }

        List<QueueMessage__c> returnedQueueMessagesList = [
                SELECT Id,
                        Status__c
                FROM QueueMessage__c
                WHERE ID = :queueMessageIdsSet
                AND Status__c = :QueueConstants.QUEUE_MESSAGE_STATUS_PROCESSED
        ];

        System.assertEquals(testSize, returnedQueueMessagesList.size());
    }

    private static String getAccountMessageBody(Id accountId) {
        AccountMessageHandler.AccountMessage message = new AccountMessageHandler.AccountMessage();
        message.accountId = accountId;
        message.site = 'www.wayne.com';

        return JSON.Serialize(message);
    }

    private static String getContactMessageBody(Id contactId) {
        ContactMessageHandler.ContactMessage message = new ContactMessageHandler.ContactMessage();
        message.contactId = contactId;
        message.phone = '4141414141';

        return JSON.Serialize(message);
    }
}