/**
 * Created by pankajjakhar on 3/09/21.
 */
public with sharing class QueueConstants {
    public static final String EVENT_TYPE_UPDATE_ACCOUNT = 'Update Account';
    public static final String EVENT_TYPE_UPDATE_CONTACT = 'Update Contact';

    public static final String QUEUE_MESSAGE_STATUS_PENDING = 'Pending';
    public static final String QUEUE_MESSAGE_STATUS_FAILED = 'Failed';
    public static final String QUEUE_MESSAGE_STATUS_PROCESSED = 'Processed';
}