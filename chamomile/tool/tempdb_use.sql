--
-- https://technet.microsoft.com/en-us/library/ms176029(v=sql.105).aspx
-------------------------------------------------
-------------------------------------------------
SELECT SUM([dm_db_file_space_usage].[internal_object_reserved_page_count])                   AS [internal object pages used]
       , ( SUM([dm_db_file_space_usage].[internal_object_reserved_page_count]) * 1.0 / 128 ) AS [internal object space in MB]
FROM   [sys].[dm_db_file_space_usage];

--
-- Determining the Amount of Space Used by User Objects
-------------------------------------------------
SELECT SUM([dm_db_file_space_usage].[user_object_reserved_page_count])                   AS [user object pages used]
       , ( SUM([dm_db_file_space_usage].[user_object_reserved_page_count]) * 1.0 / 128 ) AS [user object space in MB]
FROM   [sys].[dm_db_file_space_usage];

--
-- http://blog.sqlauthority.com/2015/01/23/sql-server-who-is-consuming-my-tempdb-now/
-------------------------------------------------
-------------------------------------------------
SELECT [st].[dbid]                                                                                           AS [QueryExecutionContextDBID]
       , DB_NAME([st].[dbid])                                                                                AS [QueryExecContextDBNAME]
       , [st].[objectid]                                                                                     AS [ModuleObjectId]
       , SUBSTRING([st].[text]
                   , [dmv_er].[statement_start_offset] / 2 + 1
                   , ( CASE
                         WHEN [dmv_er].[statement_end_offset] = -1 THEN
                           LEN(CONVERT(nvarchar(MAX), [st].[text])) * 2
                         ELSE [dmv_er].[statement_end_offset]
                       END - [dmv_er].[statement_start_offset] ) / 2)                                        AS [Query_Text]
       , [dmv_tsu].[session_id]
       , [dmv_tsu].[request_id]
       , [dmv_tsu].[exec_context_id]
       , ( [dmv_tsu].[user_objects_alloc_page_count] - [dmv_tsu].[user_objects_dealloc_page_count] )         AS [OutStanding_user_objects_page_counts]
       , ( [dmv_tsu].[internal_objects_alloc_page_count] - [dmv_tsu].[internal_objects_dealloc_page_count] ) AS [OutStanding_internal_objects_page_counts]
       , [dmv_er].[start_time]
       , [dmv_er].[command]
       , [dmv_er].[open_transaction_count]
       , [dmv_er].[percent_complete]
       , [dmv_er].[estimated_completion_time]
       , [dmv_er].[cpu_time]
       , [dmv_er].[total_elapsed_time]
       , [dmv_er].[reads]
       , [dmv_er].[writes]
       , [dmv_er].[logical_reads]
       , [dmv_er].[granted_query_memory]
       , [dmv_es].[host_name]
       , [dmv_es].[login_name]
       , [dmv_es].[program_name]
FROM   [sys].[dm_db_task_space_usage] [dmv_tsu]
       INNER JOIN [sys].[dm_exec_requests] [dmv_er]
               ON ( [dmv_tsu].[session_id] = [dmv_er].[session_id]
                    AND [dmv_tsu].[request_id] = [dmv_er].[request_id] )
       INNER JOIN [sys].[dm_exec_sessions] [dmv_es]
               ON ( [dmv_tsu].[session_id] = [dmv_es].[session_id] )
       CROSS APPLY [sys].[dm_exec_sql_text]([dmv_er].[sql_handle]) [st]
WHERE  ( [dmv_tsu].[internal_objects_alloc_page_count]
         + [dmv_tsu].[user_objects_alloc_page_count] ) > 0
ORDER  BY ( [dmv_tsu].[user_objects_alloc_page_count] - [dmv_tsu].[user_objects_dealloc_page_count] ) + ( [dmv_tsu].[internal_objects_alloc_page_count] - [dmv_tsu].[internal_objects_dealloc_page_count] ) DESC;

--
-- http://dba.stackexchange.com/questions/19870/how-to-identify-which-query-is-filling-up-the-tempdb-transaction-log
-------------------------------------------------
WITH [task_space_usage]
     AS (
        -- SUM alloc/delloc pages
        SELECT [dm_db_task_space_usage].[session_id]
               , [dm_db_task_space_usage].[request_id]
               , SUM([dm_db_task_space_usage].[internal_objects_alloc_page_count])   AS [alloc_pages]
               , SUM([dm_db_task_space_usage].[internal_objects_dealloc_page_count]) AS [dealloc_pages]
         FROM   [sys].[dm_db_task_space_usage] WITH ( NOLOCK )
         WHERE  [dm_db_task_space_usage].[session_id] <> @@SPID
         GROUP  BY [dm_db_task_space_usage].[session_id]
                   , [dm_db_task_space_usage].[request_id])
SELECT [TSU].[session_id]
       , [TSU].[alloc_pages] * 1.0 / 128   AS [internal object MB space]
       , [TSU].[dealloc_pages] * 1.0 / 128 AS [internal object dealloc MB space]
       , [EST].[text]
       ,
       -- Extract statement from sql text
       ISNULL(NULLIF(SUBSTRING([EST].[text]
                                 , [ERQ].[statement_start_offset] / 2
                                 , CASE
                                     WHEN [ERQ].[statement_end_offset] < [ERQ].[statement_start_offset] THEN
                                       0
                                     ELSE ( [ERQ].[statement_end_offset] - [ERQ].[statement_start_offset] ) / 2
                                   END)
                       , '')
                , [EST].[text])            AS [statement text]
       , [EQP].[query_plan]
FROM   [task_space_usage] AS [TSU]
       INNER JOIN [sys].[dm_exec_requests] [ERQ] WITH ( NOLOCK )
               ON [TSU].[session_id] = [ERQ].[session_id]
                  AND [TSU].[request_id] = [ERQ].[request_id]
       OUTER APPLY [sys].[dm_exec_sql_text]([ERQ].[sql_handle]) AS [EST]
       OUTER APPLY [sys].[dm_exec_query_plan]([ERQ].[plan_handle]) AS [EQP]
WHERE  [EST].[text] IS NOT NULL
        OR [EQP].[query_plan] IS NOT NULL
ORDER  BY 3 DESC; 
