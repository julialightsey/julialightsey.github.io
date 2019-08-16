use [chamomile];

go

if exists (select *
           from   sys.services
           where  name = N'//AWDB/InternalAct/TargetService')
  drop service [//awdb/internalact/targetservice];

if exists (select *
           from   sys.service_queues
           where  name = N'TargetQueueIntAct')
  drop queue targetqueueintact;

-- Drop the intitator queue and service if they already exist.
if exists (select *
           from   sys.services
           where  name = N'//AWDB/InternalAct/InitiatorService')
  drop service [//awdb/internalact/initiatorservice];

if exists (select *
           from   sys.service_queues
           where  name = N'InitiatorQueueIntAct')
  drop queue initiatorqueueintact;

-- Drop contract and message type if they already exist.
if exists (select *
           from   sys.service_contracts
           where  name = N'//AWDB/InternalAct/SampleContract')
  drop contract [//awdb/internalact/samplecontract];

if exists (select *
           from   sys.service_message_types
           where  name = N'//AWDB/InternalAct/RequestMessage')
  drop message type [//awdb/internalact/requestmessage];

if exists (select *
           from   sys.service_message_types
           where  name = N'//AWDB/InternalAct/ReplyMessage')
  drop message type [//awdb/internalact/replymessage];

create message type [//awdb/internalact/requestmessage] validation = well_formed_xml;

create message type [//awdb/internalact/replymessage] validation = well_formed_xml;

go

create contract [//awdb/internalact/samplecontract] ([//awdb/internalact/requestmessage] sent by initiator, [//awdb/internalact/replymessage] sent by target );

go

create queue targetqueueintact;

create service [//awdb/internalact/targetservice] on queue targetqueueintact ([//awdb/internalact/samplecontract]);

go

create queue initiatorqueueintact;

create service [//awdb/internalact/initiatorservice] on queue initiatorqueueintact;

go

alter queue targetqueueintact with activation ( status = on, procedure_name = [workflow].[target_queue_reader], max_queue_readers = 10, execute as self );

go 
