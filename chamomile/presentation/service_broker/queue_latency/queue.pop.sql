USE [chamomile];

go

IF schema_id(N'queue') IS NULL
  EXECUTE (N'CREATE SCHEMA queue;');

go

IF object_id(N'[queue].[pop]', N'P') IS NOT NULL
  DROP PROCEDURE [queue].[pop];

go

CREATE PROCEDURE [queue].[pop] @count INT = 0 output
AS
  BEGIN
      SET NOCOUNT ON;

      DECLARE @conversation_handle UNIQUEIDENTIFIER=NULL
              , @message_type_name SYSNAME
              , @message_body      XML
              , @row_count         INT
              , @queuing_order     INT;

      --
      -----------------------------------
      SET @row_count = 1;

      WHILE @row_count > 0
        BEGIN;
            RECEIVE TOP(1) @conversation_handle=[conversation_handle], @message_body=[message_body], @message_type_name=[message_type_name], @queuing_order=[queuing_order] FROM [chamomile].[dbo].[oltp_queue];

            SET @row_count = @@ROWCOUNT;

            IF @row_count > 0
              SET @count = @count + 1;

            IF @message_type_name = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
              BEGIN
                  IF @conversation_handle IS NOT NULL
                    END CONVERSATION @conversation_handle;
              END;
        END;

      RETURN 0;
  END;

GO 
