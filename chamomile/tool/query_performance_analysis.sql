--
-- [sys].[dm_exec_procedure_stats]
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-procedure-stats-transact-sql
--
-- Evaluate total elapsed time and run count of procedures (in cache)
-- Use to identify objects for elimination or to be refactored based on time per run, total runs, etc.
-------------------------------------------------
DECLARE @database SYSNAME = N'target_database';

SELECT [objects].[name]                                        AS [object]
       , [objects].[type_desc]                                 AS [object_type]
       , [dm_exec_procedure_stats].[total_elapsed_time] / 1000 AS [total_elapsed_milliseconds]
       , [dm_exec_procedure_stats].[execution_count]           AS [execution_count]
       , [dm_exec_procedure_stats].[total_physical_reads]      AS [total_physical_reads]
       , [dm_exec_procedure_stats].[total_logical_reads]       AS [total_logical_reads]
       , [dm_exec_procedure_stats].[total_logical_writes]      AS [total_logical_writes]
       , *
FROM   [sys].[dm_exec_procedure_stats] AS [dm_exec_procedure_stats]
       JOIN [sys].[objects] AS [objects]
         ON [objects].[object_id] = [dm_exec_procedure_stats].[object_id]
       JOIN [sys].[databases] AS [databases]
         ON [databases].[database_id] = [dm_exec_procedure_stats].[database_id]
WHERE  [databases].[name] = @database
ORDER  BY [dm_exec_procedure_stats].[total_elapsed_time] DESC;

GO

--
-------------------------------------------------
DECLARE @database SYSNAME = N'target_database';

SELECT quotename(object_schema_name([dm_exec_query_plan].[objectid]))
       + N'.'
       + quotename(object_name([dm_exec_query_plan].[objectid]))                                             AS [object]
       , avg([dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count]) / 1000000  AS [average_cpu_time_seconds]
       , avg([dm_exec_query_stats].[total_elapsed_time] / [dm_exec_query_stats].[execution_count]) / 1000000 AS [average_run_time_seconds]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS apply [sys].[dm_exec_sql_text]([dm_exec_query_stats].[plan_handle]) AS [dm_exec_sql_txt]
       CROSS apply [sys].[dm_exec_query_plan]([dm_exec_query_stats].[plan_handle]) AS [dm_exec_query_plan]
WHERE  DB_NAME([dm_exec_sql_txt].[dbid]) = @database
GROUP  BY quotename(object_schema_name([dm_exec_query_plan].[objectid]))
          + N'.'
          + quotename(object_name([dm_exec_query_plan].[objectid]))
ORDER  BY [average_cpu_time_seconds] DESC;

GO

--
-- http://www.codeproject.com/Articles/579593/How-to-Find-the-Top-Most-Expens
-- Top 10 Total CPU Consuming Queries
-------------------------------------------------
DECLARE @database SYSNAME = N'target_database';

SELECT TOP 10 [objects].[name]                                    AS [object]
              , [objects].[type_desc]                             AS [object_type]
              , DB_NAME([dm_exec_sql_text].[dbid])                AS [database]
              , [dm_exec_sql_text].[dbid]                         AS [dbid]
              , [dm_exec_sql_text].[objectid]                     AS [object_id]
              , [dm_exec_sql_text].[text]                                                             AS [sql_text]
              , [dm_exec_query_plan].[query_plan]                                                   AS [query_plan]
              , [dm_exec_query_stats].[total_worker_time]                                           AS [cpu_time]
              , [dm_exec_query_stats].[execution_count]                                             AS [execution_count]
              , [dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count] AS [average_cpu_time_microseconds]
              , [dm_exec_sql_text].[text]                                                           AS [sql_text]
              , DB_NAME([dm_exec_sql_text].[dbid])                                                  AS [database]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY SYS.[dm_exec_sql_text] ([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
       JOIN [sys].[objects] AS [objects]
         ON [objects].[object_id] = [dm_exec_sql_text].[objectid]
       CROSS APPLY SYS.[dm_exec_query_plan] ([dm_exec_query_stats].[plan_handle]) AS [dm_exec_query_plan]
WHERE  DB_NAME ([dm_exec_sql_text].[dbid]) = @database
ORDER  BY [dm_exec_query_stats].[total_worker_time] DESC;

GO

--
-- Top 10 I/O Intensive Queries
-------------------------------------------------
DECLARE @database SYSNAME = N'target_database';

SELECT TOP 10 [objects].[name]                                    AS [object]
              , [objects].[type_desc]                             AS [object_type]
              , DB_NAME([dm_exec_sql_text].[dbid])                AS [database]
              , [dm_exec_sql_text].[dbid]                         AS [dbid]
              , [dm_exec_sql_text].[objectid]                     AS [object_id]
              , [dm_exec_query_stats].[total_logical_reads]       AS [total_logical_reads]
              , [dm_exec_query_stats].[total_logical_writes]      AS [total_logical_writes]
              , [dm_exec_query_stats].[execution_count]           AS [execution_count]
              , [dm_exec_query_stats].[total_logical_reads]
                + [dm_exec_query_stats].[total_logical_writes]    AS [total_io]
              , [dm_exec_query_stats].[total_elapsed_time] / 1000 AS [total_elapsed_milliseconds]
              , [dm_exec_sql_text].[text]                         AS [sql_text]
              , DB_NAME([dm_exec_sql_text].[dbid])                AS [database]
              , [dm_exec_sql_text].[objectid]                     AS [object_id]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
       JOIN [sys].[objects] AS [objects]
         ON [objects].[object_id] = [dm_exec_sql_text].[objectid]
WHERE  [dm_exec_query_stats].[total_logical_reads]
       + [dm_exec_query_stats].[total_logical_writes] > 0
       AND DB_NAME ([dm_exec_sql_text].[dbid]) = @database
ORDER  BY [total_io] DESC;

GO 



--
-- Execution Count of Each Query
-------------------------------------------------
DECLARE @database SYSNAME = N'target_database';

SELECT [objects].[name]                          AS [object]
       , [objects].[type_desc]                   AS [object_type]
       , DB_NAME([dm_exec_sql_text].[dbid])      AS [database]
       , [dm_exec_sql_text].[dbid]               AS [dbid]
       , [dm_exec_sql_text].[objectid]           AS [object_id]
       , [dm_exec_query_stats].[execution_count] AS [execution_count]
       , [dm_exec_query_stats].[total_elapsed_time] / 1000 AS [total_elapsed_milliseconds]
       , [dm_exec_sql_text].[text]               AS [sql_text]
       , [dm_exec_query_stats].*
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
       JOIN [sys].[objects] AS [objects]
         ON [objects].[object_id] = [dm_exec_sql_text].[objectid]
WHERE  DB_NAME ([dm_exec_sql_text].[dbid]) = @database
ORDER  BY [dm_exec_query_stats].[execution_count] DESC; 


GO 


--
-- [sys].[dm_exec_query_stats]
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql
--
-- 
-------------------------------------------------
DECLARE @database       SYSNAME = N'target_database'
        , @result_count TINYINT = 25;

SELECT TOP (@result_count) [query_stats].[query_hash]                                                      AS [query_hash]
                           , SUM([query_stats].[total_worker_time]) / SUM([query_stats].[execution_count]) AS [avg_cpu_time]
                           , MIN([query_stats].[statement_text])                                           AS [statement_text]
FROM   (SELECT [dm_exec_query_stats].*
               , SUBSTRING([dm_exec_sql_text].[text], ( [dm_exec_query_stats].[statement_start_offset] / 2 ) + 1, ( ( CASE [statement_end_offset]
                                                                                                                        WHEN -1 THEN DATALENGTH([dm_exec_sql_text].[text])
                                                                                                                        ELSE [dm_exec_query_stats].[statement_end_offset]
                                                                                                                      END - [dm_exec_query_stats].[statement_start_offset] ) / 2 ) + 1) AS [statement_text]
        FROM   sys.[dm_exec_query_stats] AS [dm_exec_query_stats]
               CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
        WHERE  DB_NAME ([dm_exec_sql_text].[dbid]) = @database) AS [query_stats]
GROUP  BY [query_stats].[query_hash]
ORDER  BY [avg_cpu_time] DESC; 
