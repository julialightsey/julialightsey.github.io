USE [chamomile];

go

IF SCHEMA_ID(N'queue') IS NULL
  EXECUTE (N'CREATE SCHEMA queue');

go

IF OBJECT_ID(N'[queue].[push]', N'P') IS NOT NULL
  DROP PROCEDURE [queue].[push];

go

--
-------------------------------------------------
CREATE PROCEDURE [queue].[push] @count    BIGINT
                                , @object XML
AS
  BEGIN
      DECLARE @conversation_handle UNIQUEIDENTIFIER;

      --
      -------------------------------------------
      WHILE @count > 0
        BEGIN
            --
            -------------------------------------
            BEGIN DIALOG CONVERSATION @conversation_handle
              FROM SERVICE [etl_service]
              TO SERVICE 'oltp_service'
              ON CONTRACT [oltp_processing_contract]
              WITH ENCRYPTION = OFF;

            --
            -------------------------------------
            SEND ON CONVERSATION @conversation_handle
              MESSAGE TYPE oltp_processing_request(@object);

            --
            -------------------------------------
            SET @count = @count - 1;
        END;
  END;

go 
