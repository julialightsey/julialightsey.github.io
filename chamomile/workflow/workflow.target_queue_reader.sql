use [chamomile];

go

if exists (select *
           from   sys.objects
           where  name = N'target_queue_reader')
  drop procedure [workflow].[target_queue_reader];

go

create procedure [workflow].[target_queue_reader]
as
    declare @recvreqdlghandle uniqueidentifier;
    declare @recvreqmsg nvarchar(100);
    declare @recvreqmsgname sysname;

    while ( 1 = 1 )
      begin
          begin transaction;

          waitfor ( receive top(1) @recvreqdlghandle = conversation_handle, @recvreqmsg = message_body, @recvreqmsgname = message_type_name from targetqueueintact ), timeout 5000;

          if ( @@rowcount = 0 )
            begin
                rollback transaction;

                break;
            end

          if @recvreqmsgname = N'//AWDB/InternalAct/RequestMessage'
            begin
                declare @replymsg nvarchar(100);

                select @replymsg = N'<ReplyMsg>[workflow].[target_queue_reader] - Message for Initiator service.</ReplyMsg>';

                send on conversation @recvreqdlghandle
                  message type [//awdb/internalact/replymessage] (@replymsg);
            end
          else if @recvreqmsgname = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
            begin
                end conversation @recvreqdlghandle;
            end
          else if @recvreqmsgname = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
            begin
                end conversation @recvreqdlghandle;
            end

          commit transaction;
      end

go 
