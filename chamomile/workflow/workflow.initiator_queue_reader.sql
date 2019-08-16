use [chamomile];

go

if object_id(N'[workflow].[initiator_queue_reader]'
             , N'P') is not null
  drop procedure [workflow].[initiator_queue_reader];

go

create procedure [workflow].[initiator_queue_reader]
as
    declare @receive_request_dialog_handle uniqueidentifier,
            @receive_request_message       [xml],
            @receive_request_message_name  sysname,
            @reply_message                 nvarchar(100);

    select N'here in initiator queue reader'

    while ( 1 = 1 )
      begin
          begin transaction;

          waitfor ( receive top(1) @receive_request_dialog_handle = conversation_handle, @receive_request_message = message_body, @receive_request_message_name = message_type_name from initiator_queue ), timeout 5000;

          if ( @@rowcount = 0 )
            begin
                rollback transaction;

                break;
            end

          select @receive_request_message_name
                 , object_name(@@procid);

          if @receive_request_message_name = N'//chamomile/workflow/request_message'
            begin
                select @reply_message = N'<ReplyMsg>Message for Initiator service.</ReplyMsg>';

                send on conversation @receive_request_dialog_handle
                  message type [//chamomile/workflow/reply_message] (@reply_message);
            end
          else if @receive_request_message_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
            begin
                end conversation @receive_request_dialog_handle;
            end
          else if @receive_request_message_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
            begin
                end conversation @receive_request_dialog_handle;
            end

          commit transaction;
      end

go 
