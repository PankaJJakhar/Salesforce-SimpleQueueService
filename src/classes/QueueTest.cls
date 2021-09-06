/**
 * Created by pankajjakhar on 2/09/21.
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

        for (Integer index = 0; index < 1000; index++) {
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

        System.assertEquals(1000, returnedQueueMessagesList.size());
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