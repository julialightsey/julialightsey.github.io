
--
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
USE [chamomile];
GO
IF SCHEMA_ID(N'forex') IS NULL
    EXECUTE (N'CREATE SCHEMA forex;');
GO
IF OBJECT_ID(N'[forex].[hourly_partition_function_add_right]', N'P') IS NOT NULL
    DROP PROCEDURE [forex].[hourly_partition_function_add_right];
GO 

/*
    Summary:    Managing a Range Partitioned Table 
	   Creates a new partition at right.  Add a new partition on the end of table entity for the next day
	   The routine reads entity metadata to discover right boundary.
*/


CREATE PROCEDURE [forex].[hourly_partition_function_add_right]
AS
     BEGIN
         DECLARE @hour DATETIMEOFFSET;

      --
      ----------------------------------------
         SET @hour = CAST(
                         (
                             SELECT TOP (1) [value]
                             FROM [sys].[partition_range_values] AS [partition_range_values]
                                  JOIN [sys].[partition_functions] AS [partition_functions] ON [partition_functions].[function_id] = [partition_range_values].[function_id]
                             WHERE [partition_functions].[name] = N'hourly_partition_function'
                             ORDER BY [boundary_id] DESC
                         ) AS DATETIMEOFFSET);
      --
      ----------------------------------------
         SET @hour = DATEADD(hour, 1, @hour);

      --
      ----------------------------------------
         ALTER PARTITION SCHEME [hourly_partition_scheme] NEXT USED [oltp_filegroup];
         ALTER PARTITION FUNCTION [hourly_partition_function]() SPLIT RANGE(@hour);
     END;
GO 

--
-------------------------------------------------
-------------------------------------------------
-------------------------------------------------
USE [chamomile];
GO
IF OBJECT_ID(N'[forex].[hourly_partition_function_delete_left]', N'P') IS NOT NULL
    DROP PROCEDURE [forex].[hourly_partition_function_delete_left];
GO 


/*
    Summary:       Managing a Range Partitioned Table 
	   Delete data on 2nd most left partition. It means that the most left partition will always stay there
	   to guarantee the size of the second one. This one will be moved. The most left partition will be empty.
*/

CREATE PROCEDURE [forex].[hourly_partition_function_delete_left]
AS
     BEGIN
         DECLARE @hour DATETIMEOFFSET, @next_hour DATETIMEOFFSET;
         
         --
         ----------------------------------------
         ALTER PARTITION SCHEME [hourly_partition_scheme] NEXT USED [oltp_filegroup];
         ALTER PARTITION SCHEME [hourly_partition_scheme_aged] NEXT USED [oltp_filegroup];
         
         --
         ----------------------------------------
         SET @hour = CAST(
                         (
                             SELECT TOP (1) [value]
                             FROM [sys].[partition_range_values] AS [partition_range_values]
                                  JOIN [sys].[partition_functions] AS [partition_functions] ON [partition_functions].[function_id] = [partition_range_values].[function_id]
                             WHERE [partition_functions].[name] = N'hourly_partition_function'
                             ORDER BY [boundary_id] ASC
                         ) AS DATETIMEOFFSET);
         SET @next_hour = DATEADD(hour, 2, @hour); 
         

	    --
	    -- Add a new partition to table [forex_aged].[data] to hold the data from 2nd Left Partition of [data].
	    ----------------------------------------
         ALTER PARTITION FUNCTION [hourly_partition_function_aged]() SPLIT RANGE(@next_hour);

	    --
	    -- Move the data for 2nd FAR LEFT Partition from table [data] to table [forex_aged].[data].
	    -- TODO how is partition number defined?
	    ----------------------------------------
         ALTER TABLE [forex].[data] SWITCH PARTITION 2 TO [forex_aged].[data] PARTITION 2;

	    --
	    -- Merge the 1st and 2nd partitions of table [data].
	    ----------------------------------------
         ALTER PARTITION FUNCTION [hourly_partition_function]() MERGE RANGE(@hour);

	    --
	    -- Merge the partition of table [forex_aged].[data] with the first partition.
	    ----------------------------------------
         ALTER PARTITION FUNCTION [hourly_partition_function_aged]() MERGE RANGE(@hour);

	    --
	    -- display data to be truncated
	    ----------------------------------------

         SELECT N'[forex_aged].[data]' AS [forex_aged.data],
                [id],
                [timestamp]
         FROM [forex_aged].[data]
         ORDER BY [timestamp] asc, [id] ASC;

	    --
	    -- delete the data on [forex_aged].[data]
	    ----------------------------------------
         TRUNCATE TABLE [forex_aged].[data];
     END;
GO