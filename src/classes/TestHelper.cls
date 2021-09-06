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
public class TestHelper {

    public static QueueMessage__c getUncommittedQueueMessage(String updateUserInfo) {
        QueueMessage__c queueMessage = new QueueMessage__c();
        queueMessage.EventType__c = updateUserInfo;
        queueMessage.Status__c = QueueConstants.QUEUE_MESSAGE_STATUS_PENDING;
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