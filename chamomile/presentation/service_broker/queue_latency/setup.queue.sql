USE [master];

go

--
-------------------------------------------------
ALTER DATABASE [chamomile]

SET SINGLE_USER WITH

ROLLBACK IMMEDIATE;

go

ALTER DATABASE [chamomile]

SET ENABLE_BROKER;

go

ALTER DATABASE [chamomile]

SET MULTI_USER;

go

--
-------------------------------------------------
USE [chamomile];

GO

--
-------------------------------------------------
IF EXISTS(SELECT *
          FROM   [sys].[services]
          WHERE  [name] = N'etl_service')
  DROP SERVICE [etl_service];

GO

IF EXISTS(SELECT *
          FROM   [sys].[services]
          WHERE  [name] = N'oltp_service')
  DROP SERVICE [oltp_service];

GO

IF EXISTS(SELECT *
          FROM   [sys].[service_queues]
          WHERE  [name] = N'etl_queue')
  DROP QUEUE [dbo].[etl_queue];

GO

IF EXISTS(SELECT *
          FROM   [sys].[service_queues]
          WHERE  [name] = N'oltp_queue')
  DROP QUEUE [dbo].[oltp_queue];

GO

IF EXISTS (SELECT *
           FROM   [sys].[service_contracts]
           WHERE  [name] = N'oltp_processing_contract')
  DROP CONTRACT [oltp_processing_contract];

GO

IF EXISTS (SELECT *
           FROM   [sys].[service_message_types]
           WHERE  [name] = N'oltp_processing_request')
  DROP MESSAGE TYPE [oltp_processing_request];

GO

--
-------------------------------------------------
CREATE QUEUE [dbo].[etl_queue] WITH STATUS = ON, RETENTION = OFF;

GO

CREATE QUEUE [dbo].[oltp_queue] WITH STATUS = ON, RETENTION = OFF;

GO

CREATE MESSAGE TYPE [oltp_processing_request] VALIDATION = well_formed_xml;

GO

CREATE CONTRACT [oltp_processing_contract] ([oltp_processing_request] SENT BY INITIATOR);

GO

CREATE SERVICE [oltp_service] ON QUEUE [dbo].[oltp_queue] ([oltp_processing_contract]);

GO

CREATE SERVICE [etl_service] ON QUEUE [dbo].[etl_queue] ([oltp_processing_contract]);

GO 
