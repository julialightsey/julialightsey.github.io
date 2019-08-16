--
-- Get statistics dates
-- NOTE that rebuilding an index does NOT update all statistics
-- RE: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-stats-properties-transact-sql
-------------------------------------------------
SELECT quotename(db_name()) + N'.'
       + quotename([schemas].[name]) + N'.'
       + quotename([tables].[name])                            AS [tables]
       , [indexes].[name]                                      AS [index]
       , [indexes].[type_desc]                                 AS [index_type]
       , [dm_db_stats_properties].[last_updated]               AS [last_updated]
       , [dm_db_stats_properties].[rows]                       AS [rows_at_update]
       , [partitions].[rows]                                   AS [rows_current_est]
       , [partitions].[rows] - [dm_db_stats_properties].[rows] AS [row_count_delta]
       , [dm_db_stats_properties].[modification_counter]       AS [modification_counter]
       , *
FROM   [sys].[indexes] AS [indexes]
       JOIN [sys].[tables] AS [tables]
         ON [tables].[object_id] = [indexes].[object_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [tables].[schema_id]
       INNER JOIN [sys].[partitions] AS [partitions]
               ON [partitions].[object_id] = [tables].[object_id]
                  AND [partitions].[index_id] = [indexes].[index_id]
       CROSS apply [sys].[dm_db_stats_properties]([tables].[object_id], [indexes].[index_id]) AS [dm_db_stats_properties]
WHERE  [tables].[type_desc] NOT IN ( N'SYSTEM_TABLE', N'INTERNAL_TABLE' )
       AND [dm_db_stats_properties].[last_updated] IS NOT NULL
       AND [dm_db_stats_properties].[modification_counter] <> 0
ORDER  BY [dm_db_stats_properties].[last_updated] ASC; 
