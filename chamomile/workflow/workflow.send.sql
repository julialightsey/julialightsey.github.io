use [chamomile];

go

declare @initdlghandle uniqueidentifier;
declare @requestmsg nvarchar(100);

begin transaction;

begin dialog @initdlghandle
  from service [//awdb/internalact/initiatorservice]
  to service N'//AWDB/InternalAct/TargetService'
  on contract [//awdb/internalact/samplecontract]
  with encryption = off;

-- Send a message on the conversation
select @requestmsg = N'<RequestMsg>Message for Target service.</RequestMsg>';

send on conversation @initdlghandle
  message type [//awdb/internalact/requestmessage] (@requestmsg);

-- Diplay sent request.
select @requestmsg as sentrequestmsg;

commit transaction;

go 
