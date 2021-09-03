# Simple Queue Service Project

![GitHub Logo](/images/SimpleQueueService.jpeg)

## Components

1. QueueMessage__c : Custom Object
1. QueueConfiguration__mdt : Custom Metadata
1. QueueScheduler : Schedules the Queueing activity asynchronously
1. Queue : Reads the QueueConfiguration__mdt and accordingly distribute the Queue Messages to its respective handlers to process


## How it works?

1. Insert a record in QueueMessage__c custom object of the project.
1. On insertion, in the afterInsert trigger of QueueMessage Object a job will be spawn.
1. This job kicks off the Queue that reads the QueueConfiguration__mdt and dynamically pass the QueueMessages__c to their respective Message Handlers.
1. Developer who uses this project, can write their handlers and configure those in QueueConfiguration__mdt. After configuration that metadata setting must be made active before use.