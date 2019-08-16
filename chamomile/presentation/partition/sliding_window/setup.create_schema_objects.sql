/*
    All content is licensed as [chamomile] (http://www.chamomilesql.com/source/license.html) and  
    copyright Katherine Elizabeth Lightsey (http://www.kelightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
    and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
    ---------------------------------------------

    --
    --	description
    ---------------------------------------------
	   This script sets up the schema objects necessary to demonstrate sliding window partitioning.

    --
    --	notes
    ---------------------------------------------
	   Look for TODO blocks to replace constants as required.
	   This presentation is designed to be run incrementally a code block at a time. 
	   Code blocks are delineated as:

	   --
	   -- code block begin
	   -----------------------------------------
	   <run code here>
	   -----------------------------------------
	   -- code block end
	   --
	
    --
    -- references
    ---------------------------------------------
    Partitioned Tables and Indexes - https://docs.microsoft.com/en-us/sql/relational-databases/partitions/partitioned-tables-and-indexes
    How to Implement an Automatic Sliding Window in a Partitioned Table on SQL Server 2005 - https://technet.microsoft.com/en-us/library/aa964122(v=sql.90).aspx
*/
--
-- code block begin
-------------------------------------------------
USE [chamomile];

go

--
-- create schemas
-------------------------------------------------
-------------------------------------------------
IF Schema_id(N'forex') IS NULL
  EXECUTE (N'CREATE SCHEMA forex;');

GO

IF Schema_id(N'forex_aged') IS NULL
  EXECUTE (N'CREATE SCHEMA forex_aged;');

GO

--
-- drop objects
-------------------------------------------------
-------------------------------------------------
IF Object_id(N'[forex].[data]', N'U') IS NOT NULL
  DROP TABLE [forex].[data];

GO

IF Object_id(N'[forex_aged].[data]', N'U') IS NOT NULL
  DROP TABLE [forex_aged].[data];

GO

IF EXISTS(SELECT *
          FROM   [sys].[partition_schemes]
          WHERE  [name] = N'hourly_partition_scheme')
  DROP PARTITION SCHEME [hourly_partition_scheme];

go

IF EXISTS(SELECT *
          FROM   [sys].[partition_functions]
          WHERE  [name] = N'hourly_partition_function')
  DROP PARTITION FUNCTION [hourly_partition_function];

go

IF EXISTS(SELECT *
          FROM   [sys].[partition_schemes]
          WHERE  [name] = N'hourly_partition_scheme_aged')
  DROP PARTITION SCHEME [hourly_partition_scheme_aged];

go

IF EXISTS(SELECT *
          FROM   [sys].[partition_functions]
          WHERE  [name] = N'hourly_partition_function_aged')
  DROP PARTITION FUNCTION [hourly_partition_function_aged];

go

IF EXISTS(SELECT *
          FROM   [sys].[database_files]
          WHERE  [name] = N'oltp_file')
  ALTER DATABASE [chamomile] REMOVE FILE [oltp_file];

GO

IF EXISTS(SELECT *
          FROM   [sys].[database_files]
          WHERE  [name] = N'oltp_file_aged')
  ALTER DATABASE [chamomile] REMOVE FILE [oltp_file_aged];

GO

IF EXISTS(SELECT *
          FROM   [sys].[filegroups]
          WHERE  [name] = N'oltp_filegroup')
  ALTER DATABASE [chamomile] REMOVE FILEGROUP [oltp_filegroup];

GO

--
-- create filegroups and files
-------------------------------------------------
-------------------------------------------------
ALTER DATABASE [chamomile] ADD FILEGROUP [oltp_filegroup];

GO

--
-- TODO - replace directory with the directories to your data files
-------------------------------------------------
ALTER DATABASE [chamomile] ADD FILE(NAME = [oltp_file], FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.CHAMOMILE\MSSQL\DATA\oltp_file.ndf') TO FILEGROUP [oltp_filegroup];

GO
--
-- create partition functions and schemes
-------------------------------------------------
-------------------------------------------------
--
-- Create the number of partitions required for your application
-------------------------------------------------
DECLARE @timestamp            DATETIMEOFFSET
        , @timestamp_minus_01 DATETIMEOFFSET
        , @timestamp_minus_02 DATETIMEOFFSET;

--
-- Truncate to current hour(or your desired time period for each partition) to begin
-------------------------------------------------
SET @timestamp = DATEADD(hour, DATEDIFF(hour, 0, sysdatetimeoffset()), 0);

--
-- Set two prior partitions
-- TODO - change "hour" as required for your time period
-------------------------------------------------
SELECT @timestamp_minus_01 = Dateadd(hour, -1, @timestamp)
       , @timestamp_minus_02 = Dateadd(hour, -2, @timestamp);

--
-- Create active three partitions. Two will be used for current data and data just older than current. The oldest will be the data that is switched and then truncated.
-- TODO - Add time periods as required for your application
-------------------------------------------------
CREATE PARTITION FUNCTION [hourly_partition_function](DATETIMEOFFSET ) AS RANGE RIGHT FOR VALUES(@timestamp_minus_02, @timestamp_minus_01, @timestamp );

--
-- Create the aged data partition. Best practice is always to have an extra partition available to the left of the current.
-------------------------------------------------
CREATE PARTITION FUNCTION [hourly_partition_function_aged](DATETIMEOFFSET ) AS RANGE RIGHT FOR VALUES(@timestamp_minus_02, @timestamp_minus_01 );

GO

--
-- Both partitions will be placed at the same filegroup. For performance reasons you could use separate disks and controllers.
-------------------------------------------------
CREATE PARTITION SCHEME [hourly_partition_scheme] AS PARTITION [hourly_partition_function] ALL TO([oltp_filegroup] );

GO

CREATE PARTITION SCHEME [hourly_partition_scheme_aged] AS PARTITION [hourly_partition_function_aged] ALL TO([oltp_filegroup]);

GO

--
-- Create the table both for current data
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
CREATE TABLE [forex].[data] (
  [id]          [INT] NOT NULL IDENTITY(1, 1)
  , [timestamp] [DATETIMEOFFSET] NOT NULL,
  CONSTRAINT [PK_data] PRIMARY KEY CLUSTERED ( [id], [timestamp] ) ON [hourly_partition_scheme]([timestamp])
  )
ON [hourly_partition_scheme]([timestamp]);

GO

--
-- Create the table both for aged data. It must be a replica of the current data table including primary key.
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
CREATE TABLE [forex_aged].[data] (
  [id]          [INT] NOT NULL
  , [timestamp] [DATETIMEOFFSET] NOT NULL,
  CONSTRAINT [PK_forex_aged.data.id.timestamp.oltp_key_nonclustered] PRIMARY KEY CLUSTERED ( [id], [timestamp] ) ON [hourly_partition_scheme_aged]([timestamp])
  )
ON [hourly_partition_scheme_aged]([timestamp]);

GO 
