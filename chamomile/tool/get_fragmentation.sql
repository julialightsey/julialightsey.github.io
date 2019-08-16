--
-- Gets the fragmentation for the current database using LIMITED sampling
-- RE: https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql
-------------------------------------------------
DECLARE @table_filter            SYSNAME = NULL
        , @maximum_fragmentation INT = 5;

SELECT quotename(db_name()) + N'.'
       + quotename([schemas].[name])
       + quotename([tables].[name])                                  AS [table]
       , [indexes].[name]                                            AS [index]
       , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] AS [avg_fragmentation_in_percent]
       , [dm_db_index_physical_stats].*
FROM   [sys].[dm_db_index_physical_stats](db_id(), NULL, NULL, NULL, 'LIMITED') AS [dm_db_index_physical_stats]
       JOIN [sys].[indexes] AS [indexes]
         ON [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
            AND [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
       JOIN [sys].[tables] AS [tables]
         ON [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [tables].[schema_id]
WHERE  [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
       AND ( ( object_name([indexes].[object_id]) LIKE N'%' + @table_filter + N'%' )
              OR ( @table_filter IS NULL ) )
ORDER  BY [dm_db_index_physical_stats].[avg_fragmentation_in_percent] DESC
          , [table] DESC; 
