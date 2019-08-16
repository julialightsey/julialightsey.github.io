USE [chamomile];

GO

SET NOCOUNT ON;

IF object_id(N'tempdb..##state_management', N'U') IS NULL
  CREATE TABLE ##state_management (
    [timestamp] DATETIMEOFFSET
    );

go

IF NOT EXISTS(SELECT *
              FROM   ##state_management)
  INSERT INTO ##state_management
              ([timestamp])
  VALUES      (sysdatetimeoffset());
ELSE
  UPDATE ##state_management
  SET    [timestamp] = sysdatetimeoffset();

go

--
-------------------------------------------------
DECLARE @timestamp [DATETIMEOFFSET]= (SELECT TOP (1) CAST([value] AS [DATETIMEOFFSET])
           FROM   [sys].[partition_range_values] AS [partition_range_values]
                  JOIN [sys].[partition_functions] AS [partition_functions]
                    ON [partition_functions].[function_id] = [partition_range_values].[function_id]
           WHERE  [partition_functions].[name] = N'hourly_partition_function'
           ORDER  BY [boundary_id] DESC)
        , @count   [INT] = 2;

--
-- insert records
-------------------------------------------------
WHILE @count > 0
  BEGIN
      INSERT INTO [forex].[data]
                  ([timestamp])
      VALUES      (@timestamp);

      SELECT @count = @count - 1;
  END;

--
-- get record count for each partition
-------------------------------------------------
SELECT QUOTENAME(DB_NAME()) + N'.'
       + QUOTENAME([schemas].[name]) + N'.'
       + QUOTENAME([tables].[name])      AS [object]
       , [partitions].[partition_number] AS [partition_number]
       , [filegroups].[name]             AS [file_group]
       , [partitions].[rows]             AS [row_count]
FROM   [sys].[partitions] AS [partitions]
       INNER JOIN [sys].[allocation_units] AS [allocation_units]
               ON [allocation_units].[container_id] = [partitions].[hobt_id]
       INNER JOIN [sys].[filegroups] AS [filegroups]
               ON [filegroups].[data_space_id] = [allocation_units].[data_space_id]
       JOIN [sys].[tables] AS [tables]
         ON [tables].[object_id] = [partitions].[object_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [tables].[schema_id]
WHERE  ( [schemas].[name] IN( N'forex', N'forex_aged' ) )
       AND ( [tables].[name] IN( N'data' ) )
ORDER  BY QUOTENAME(DB_NAME()) + N'.'
          + QUOTENAME([schemas].[name]) + N'.'
          + QUOTENAME([tables].[name])
          , [partitions].[partition_number];

--
-- drop last partition and create a new one
-------------------------------------------------
BEGIN
    --
    -- display schema
    -------------------------------------------------
/*
    SELECT [partition_range_values].[function_id] AS [function_id], 
           [partition_range_values].[boundary_id] AS [boundary_id], 
           [partition_range_values].[parameter_id] AS [parameter_id], 
           CAST([partition_range_values].[value] AS DATETIMEOFFSET) AS [value]
    FROM   [sys].[partition_range_values] AS [partition_range_values]
           JOIN [sys].[partition_functions] AS [partition_functions]
               ON [partition_functions].[function_id] = [partition_range_values].[function_id]
    WHERE  [partition_functions].[name] IN(N'hourly_partition_function', N'hourly_partition_function_aged')
    ORDER BY [function_id] ASC, 
             CAST([value] AS DATETIMEOFFSET) ASC;
*/
    --
    -- get records in each table
    -------------------------------------------------
    SELECT N'[forex].[data]' AS [forex.data]
           , [id]
           , [timestamp]
    FROM   [forex].[data]
    ORDER  BY [timestamp] ASC;

    SELECT N'[forex_aged].[data]' AS [forex_aged.data]
           , [id]
           , [timestamp]
    FROM   [forex_aged].[data]
    ORDER  BY [timestamp] ASC;

    --
    -- manage partitions
    -------------------------------------------------
    EXECUTE [forex].[hourly_partition_function_delete_left];

    EXECUTE [forex].[hourly_partition_function_add_right];
END;

--
-- get record count for each partition
-------------------------------------------------
SELECT QUOTENAME(DB_NAME()) + N'.'
       + QUOTENAME([schemas].[name]) + N'.'
       + QUOTENAME([tables].[name])      AS [object]
       , [partitions].[partition_number] AS [partition_number]
       , [filegroups].[name]             AS [file_group]
       , [partitions].[rows]             AS [row_count]
FROM   [sys].[partitions] AS [partitions]
       INNER JOIN [sys].[allocation_units] AS [allocation_units]
               ON [allocation_units].[container_id] = [partitions].[hobt_id]
       INNER JOIN [sys].[filegroups] AS [filegroups]
               ON [filegroups].[data_space_id] = [allocation_units].[data_space_id]
       JOIN [sys].[tables] AS [tables]
         ON [tables].[object_id] = [partitions].[object_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [tables].[schema_id]
WHERE  ( [schemas].[name] IN( N'forex', N'forex_aged' ) )
       AND ( [tables].[name] IN( N'data' ) )
ORDER  BY QUOTENAME(DB_NAME()) + N'.'
          + QUOTENAME([schemas].[name]) + N'.'
          + QUOTENAME([tables].[name])
          , [partitions].[partition_number];

--
-- get records in each table
-------------------------------------------------
SELECT N'[forex].[data]' AS [forex.data]
       , [id]
       , [timestamp]
FROM   [forex].[data]
ORDER  BY [timestamp] ASC;

SELECT N'[forex_aged].[data]' AS [forex_aged.data]
       , [id]
       , [timestamp]
FROM   [forex_aged].[data]
ORDER  BY [timestamp] ASC; 
