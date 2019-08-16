--
-- get column names and types
-------------------------------------------------
SELECT [objects].[name]
       , [columns].[name]
       , [types].[name]
FROM   [tempdb].[sys].[objects] AS [objects]
       JOIN [tempdb].[sys].[columns] AS [columns]
         ON [columns].[object_id] = [objects].[object_id]
       JOIN [sys].[types] AS [types]
         ON [types].[user_type_id] = [columns].[user_type_id]
WHERE  [objects].[name] LIKE '#<name>%'
ORDER  BY [columns].[name] ASC;

--
-- get row count
-------------------------------------------------
SELECT [objects].[name]                      AS [table]
       , [dm_db_partition_stats].[row_count] AS [row_count]
       , *
FROM   [tempdb].[sys].[dm_db_partition_stats] AS [dm_db_partition_stats]
       INNER JOIN [tempdb].[sys].[objects] AS [objects]
               ON [dm_db_partition_stats].[object_id] = [objects].[object_id]
WHERE  [objects].[name] LIKE '#<name>%'; 
