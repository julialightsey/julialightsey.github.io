--
-------------------------------------------------
SELECT N'Run time for all queries';

SELECT quotename([schemas].[name]) + N'.'
       + quotename([objects].[name])                                                                         AS [object]
       , avg([dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count]) / 1000000  AS [average_cpu_time_seconds]
       , avg([dm_exec_query_stats].[total_elapsed_time] / [dm_exec_query_stats].[execution_count]) / 1000000 AS [average_run_time_seconds]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS apply [sys].[dm_exec_sql_text]([dm_exec_query_stats].[plan_handle]) AS [dm_exec_sql_txt]
       CROSS apply [sys].[dm_exec_query_plan]([dm_exec_query_stats].[plan_handle]) AS [dm_exec_query_plan]
       LEFT JOIN [sys].[objects] AS [objects]
              ON [objects].[object_id] = [dm_exec_query_plan].[objectid]
       LEFT JOIN [sys].[schemas] AS [schemas]
              ON [schemas].[schema_id] = [objects].[schema_id]
GROUP  BY quotename([schemas].[name]) + N'.'
          + quotename([objects].[name])
ORDER  BY [average_cpu_time_seconds] DESC;

--
-- http://www.codeproject.com/Articles/579593/How-to-Find-the-Top-Most-Expens
-------------------------------------------------
SELECT N'Top 10 Total CPU Consuming Queries';

SELECT TOP 50 quotename([databases].[name]) + N'.' + quotename([schemas].[name]) + N'.'
              + quotename([objects].[name])                                                         AS [object]
              , [dm_exec_query_stats].[total_worker_time]                                           AS [cpu_time]
              , [dm_exec_query_stats].[execution_count]                                             AS [execution_count]
              , [dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count] AS [average_cpu_time_microseconds]
              --, [dm_exec_query_plan].[query_plan]                                                   AS [query_plan]
              --, [dm_exec_sql_text].[text]                                                           AS [sql_text]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY SYS.[dm_exec_sql_text] ([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
       CROSS APPLY SYS.[dm_exec_query_plan] ([dm_exec_query_stats].[plan_handle]) AS [dm_exec_query_plan]
       LEFT JOIN [sys].[databases] AS [databases]
              ON [databases].[database_id] = [dm_exec_sql_text].[dbid]
       LEFT JOIN [sys].[objects] AS [objects]
              ON [objects].[object_id] = [dm_exec_sql_text].[objectid]
       LEFT JOIN [sys].[schemas] AS [schemas]
              ON [schemas].[schema_id] = [objects].[schema_id]
ORDER  BY [dm_exec_query_stats].[total_worker_time] DESC;

--
-------------------------------------------------
SELECT N'Top 10 I/O Intensive Queries';

SELECT TOP 50 quotename([databases].[name]) + N'.' + quotename([schemas].[name]) + N'.'
              + quotename([objects].[name])                    AS [object]
              , [dm_exec_query_stats].[total_logical_reads]    AS [total_logical_reads]
              , [dm_exec_query_stats].[total_logical_writes]   AS [total_logical_writes]
              , [dm_exec_query_stats].[execution_count]        AS [execution_count]
              , [dm_exec_query_stats].[total_logical_reads]
                + [dm_exec_query_stats].[total_logical_writes] AS [total_io]
              --, [dm_exec_sql_text].[text]                      AS [sql_text]
              , [dm_exec_sql_text].[objectid]                  AS [object_id]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
       LEFT JOIN [sys].[databases] AS [databases]
              ON [databases].[database_id] = [dm_exec_sql_text].[dbid]
       LEFT JOIN [sys].[objects] AS [objects]
              ON [objects].[object_id] = [dm_exec_sql_text].[objectid]
       LEFT JOIN [sys].[schemas] AS [schemas]
              ON [schemas].[schema_id] = [objects].[schema_id]
WHERE  [dm_exec_query_stats].[total_logical_reads]
       + [dm_exec_query_stats].[total_logical_writes] > 0
ORDER  BY [total_io] DESC;

--
-------------------------------------------------
SELECT N'Execution Count of Each Query';

SELECT [dm_exec_query_stats].[execution_count] AS [execution_count]
       , [dm_exec_sql_text].[text]             AS [sql_text]
       , [dm_exec_sql_text].[dbid]             AS [dbid]
       , [dm_exec_sql_text].[objectid]         AS [object_id]
       , [databases].[name]                    AS [database]
       , [dm_exec_query_stats].*
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) AS [dm_exec_sql_text]
       LEFT JOIN [sys].[databases] AS [databases]
              ON [databases].[database_id] = [dm_exec_sql_text].[dbid]
ORDER  BY [dm_exec_query_stats].[execution_count] DESC;

--
-- distribution of queries
-------------------------------------------------
SELECT cast(cume_dist()
              OVER (
                ORDER BY [total_elapsed_time])AS DECIMAL (5, 2))   AS [cumulative_distribution]
       , cast(percent_rank()
                OVER (
                  ORDER BY [total_elapsed_time])AS DECIMAL (5, 2)) AS [percent_rank]
       , *
FROM   [sys].[dm_exec_query_stats]
       CROSS apply [sys].[dm_exec_sql_text]([sql_handle]) AS [sql_text]
ORDER  BY [cumulative_distribution] DESC 
