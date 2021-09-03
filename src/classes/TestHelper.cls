/**
 * Created by pankajjakhar on 3/09/21.
 */
@IsTest(SeeAllData = false)
public class TestHelper {

    public static QueueMessage__c getUncommittedQueueMessage(String updateUserInfo) {
        QueueMessage__c queueMessage = new QueueMessage__c();
        queueMessage.EventType__c = updateUserInfo;
        queueMessage.Body__c = '';

        return queueMessage;
    }

    public static Account createUncommittedAccount() {
        Account accountRecord = new Account();
        accountRecord.Name = 'Mr. Wayne Enterprises';
        accountRecord.Site = 'nosite.com';

        return accountRecord;
    }

    public static Contact createUncommittedContact() {
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Wayne';
        contactRecord.LastName = 'E';
        contactRecord.Phone = '65465698';

        return contactRecord;
    }
}