USE [<target_database>] ;
GO
DECLARE @Schema [sysname]= N'<schema>'
      , @Object [sysname] = N'<table>' ;
--   
SELECT [filegroups].[name]                      AS [file_group]
       , [filegroups].[is_default]              AS [is_default]
       , [filegroups].[type_desc]               AS [type_desc]
       , [database_files].[name]                AS [file_logical_name]
       , [database_files].[physical_name]       AS [file_physical_name]
       , OBJECT_NAME([partitions].[object_id])  AS [table]
       , [indexes].[name]                       AS [index]
       , [allocation_units].[total_pages] / 128 AS [size_mb]
FROM   [sys].[allocation_units] AS [allocation_units]
       INNER JOIN [sys].[partitions] AS [partitions]
               ON [allocation_units].[container_id] = CASE
                                                        WHEN [allocation_units].[type] IN( 1, 3 )
                                                        THEN [partitions].[hobt_id]
                                                        ELSE [partitions].[partition_id]
                                                      END
       LEFT JOIN [sys].[indexes] AS [indexes]
              ON [indexes].[object_id] = [partitions].[object_id]
                 AND [indexes].[index_id] = [partitions].[index_id]
       INNER JOIN [sys].[database_files] AS [database_files]
               ON [database_files].[data_space_id] = [allocation_units].[data_space_id]
       INNER JOIN [sys].[filegroups] AS [filegroups]
               ON [filegroups].[data_space_id] = [database_files].[data_space_id]
WHERE   OBJECT_NAME([partitions].[object_id])   like '%<table>%'
		--'OBJECT_SCHEMA_NAME([partitions].[object_id]) = @Schema
        --AND OBJECT_NAME([partitions].[object_id]) = @Object
ORDER  BY [file_group]
          , [file_logical_name]
          , [file_physical_name]
          , [table]
          , [index];
