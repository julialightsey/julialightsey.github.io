SELECT [sql_text].[text]                                                                                                           AS [sql_text]
       , [dm_exec_query_stats].[execution_count]
       , [dm_exec_query_stats].[total_rows]
       , Cast([dm_exec_query_stats].[total_rows] / Cast([dm_exec_query_stats].[execution_count] AS [DECIMAL]) AS [DECIMAL](16, 2)) AS [rows_per]
       , [dm_exec_query_stats].[total_worker_time]
       , [dm_exec_query_stats].[total_physical_reads]
       , [dm_exec_query_stats].[total_logical_writes]
       , [dm_exec_query_stats].[total_elapsed_time]
       , [dm_exec_query_stats].[last_execution_time]
       , Cast(Cume_dist()
                OVER (
                  ORDER BY [total_elapsed_time])AS DECIMAL (5, 2))                                                                 AS [cumulative_distribution]
       , Cast(Percent_rank()
                OVER (
                  ORDER BY [total_elapsed_time])AS DECIMAL (5, 2))                                                                 AS [percent_rank]
       , *
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS apply [sys].[Dm_exec_sql_text](sql_handle) AS [sql_text]
ORDER  BY [cumulative_distribution] DESC, [dm_exec_query_stats].[last_execution_time] DESC; 
--ORDER  BY [dm_exec_query_stats].[last_execution_time] DESC, [cumulative_distribution] DESC; 
