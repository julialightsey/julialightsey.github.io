--
-- Exploring Query Plans in SQL - https://www.red-gate.com/simple-talk/sql/database-administration/exploring-query-plans-in-sql/
-------------------------------------------------
--
-- Identifying scan issues
-------------------------------------------------
-------------------------------------------------
--
-- find the database with most scan problems
-------------------------------------------------
SELECT db_name([database_id]) AS [database]
       , max([user_scans])    AS [maximum_user_scans]
       , avg([user_scans])    AS [average_user_scans]
FROM   [sys].[dm_db_index_usage_stats]
GROUP  BY db_name([database_id])
ORDER  BY [average_user_scans] DESC;

--
-- indexes that might have problems
-------------------------------------------------
SELECT object_schema_name([indexes].[object_id]) AS [schema]
       , object_name([indexes].[object_id])      AS [table]
       , [indexes].[name]                        AS [index]
       , [dm_db_index_usage_stats].[user_scans]  AS [user_scans]
       , [dm_db_index_usage_stats].[user_seeks]  AS [user_seeks]
       , CASE [dm_db_index_usage_stats].[index_id]
           WHEN 1 THEN 'CLUSTERED'
           ELSE 'NONCLUSTERED'
         END                                     AS [index_type]
FROM   [sys].[dm_db_index_usage_stats] AS [dm_db_index_usage_stats]
       INNER JOIN [sys].[indexes] AS [indexes]
               ON [indexes].[object_id] = [dm_db_index_usage_stats].[object_id]
                  AND [indexes].[index_id] = [dm_db_index_usage_stats].[index_id]
                  AND [database_id] = DB_ID('<target_database>')
ORDER  BY [dm_db_index_usage_stats].[user_scans] DESC;

--
-- get the query plan for a specific index
-------------------------------------------------
SELECT [dm_exec_query_plan].[query_plan]           AS [query_plan]
       , [dm_exec_sql_text].[text]                 AS [exec_sql_text]
       , [dm_exec_query_stats].[total_worker_time] AS [total_worker_time]
FROM   [sys].[dm_exec_query_stats] AS [dm_exec_query_stats]
       CROSS APPLY [sys].[dm_exec_sql_text]([sql_handle]) [dm_exec_sql_text]
       CROSS APPLY [sys].[dm_exec_query_plan]([plan_handle]) [dm_exec_query_plan]
WHERE  [dm_exec_query_plan].query_plan.exist('declare namespace 
qplan="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
            //qplan:RelOp[@LogicalOp="Index Scan"
            or @LogicalOp="Clustered Index Scan"
            or @LogicalOp="Table Scan"]/qplan:IndexScan/qplan:Object[@Index="[<target_index>]"]') = 1
ORDER  BY [dm_exec_query_stats].[total_worker_time] DESC; 



--
-- Identifying lookup issues
-------------------------------------------------
-------------------------------------------------
--
-- identify database with lots of lookups
-------------------------------------------------
SELECT db_name([database_id])
       , max([user_lookups]) [bigger]
       , avg([user_lookups]) [average]
FROM   [sys].[dm_db_index_usage_stats]
GROUP  BY db_name([database_id])
ORDER  BY [average] DESC;

--
-- find the index causing the lookups
-------------------------------------------------
USE [<target_database>];

GO

SELECT object_schema_name([indexes].[object_id]) AS [schema]
       , object_name([indexes].[object_id])      AS [table]
       , [indexes].[name]                        AS [index]
       , [user_lookups]
       , CASE [dm_db_index_usage_stats].[index_id]
           WHEN 1 THEN 'CLUSTERED'
           ELSE 'NONCLUSTERED'
         END                                     AS [index_type]
FROM   [sys].[dm_db_index_usage_stats] AS [dm_db_index_usage_stats]
       INNER JOIN [sys].[indexes] AS [indexes]
               ON [indexes].[object_id] = [dm_db_index_usage_stats].[object_id]
                  AND [indexes].[index_id] = [dm_db_index_usage_stats].[index_id]
                  AND [database_id] = DB_ID('<target_database>')
ORDER  BY [user_lookups] DESC;

--
-- find query plans with lookups
-------------------------------------------------
SELECT [dm_exec_query_plan].[query_plan]           AS [query_plan]
       , [dm_exec_sql_text].[text]                 AS [exec_sql_text]
       , [dm_exec_query_stats].[total_worker_time] AS [total_worker_time]
       , [dm_exec_query_stats].[plan_handle]       AS [plan_handle]
       , [dm_exec_query_stats].[query_plan_hash]   AS [query_plan_hash]
FROM   [sys].[dm_exec_query_stats]
       CROSS APPLY [sys].dm_exec_sql_text([sql_handle]) AS [dm_exec_sql_text]
       CROSS APPLY [sys].dm_exec_query_plan([plan_handle]) AS [dm_exec_query_plan]
WHERE  [dm_exec_query_plan].[query_plan].exist('declare namespace 
AWMI="http://schemas.microsoft.com/sqlserver/2004/07/showplan";
//AWMI:IndexScan[@Lookup]/AWMI:Object[@Index="[<target_index>]"]') = 1
ORDER  BY [total_worker_time] DESC; 


