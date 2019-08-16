--
-- http://www.sommarskog.se/query-plan-mysteries.html#sniffinfo
-------------------------------------------------
DECLARE @database    NVARCHAR(256)
        , @procedure NVARCHAR(256);

SELECT @database = '<database>'
       , @procedure = '<procedure>';

WITH [basedata]
     AS (SELECT [dm_exec_query_stats].[statement_start_offset] / 2    AS [statement_start]
                , [dm_exec_query_stats].[statement_end_offset] / 2    AS [statement_end]
                , [dm_exec_sql_text].[encrypted]                      AS [is_encrypted]
                , [dm_exec_sql_text].[text]                           AS [sqltext]
                , [dm_exec_plan_attributes].[value]                   AS [set_options]
                , [dm_exec_text_query_plan].[query_plan]
                , CHARINDEX('<ParameterList>', [dm_exec_text_query_plan].[query_plan])
                  + LEN('<ParameterList>')                            AS [parameter_start]
                , CHARINDEX('</ParameterList>'
                            , [dm_exec_text_query_plan].[query_plan]) AS [parameter_end]
         FROM   [sys].[dm_exec_query_stats] [dm_exec_query_stats]
                CROSS APPLY [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) [dm_exec_sql_text]
                CROSS APPLY [sys].[dm_exec_text_query_plan]([dm_exec_query_stats].[plan_handle]
                                                            , [dm_exec_query_stats].[statement_start_offset]
                                                            , [dm_exec_query_stats].[statement_end_offset]) [dm_exec_text_query_plan]
                CROSS APPLY [sys].[dm_exec_plan_attributes]([dm_exec_query_stats].[plan_handle]) [dm_exec_plan_attributes]
         WHERE  [dm_exec_sql_text].[objectid] = OBJECT_ID(@procedure)
                AND [dm_exec_sql_text].[dbid] = DB_ID(@database)
                AND [dm_exec_plan_attributes].[attribute] = 'set_options')
   , [next_level]
     AS (SELECT [statement_start]
                , [set_options]
                , [query_plan]
                , CASE
                    WHEN [is_encrypted] = 1 THEN
                      '-- ENCRYPTED'
                    WHEN [statement_start] >= 0 THEN
                      SUBSTRING([sqltext]
                                , [statement_start] + 1
                                , CASE [statement_end]
                                    WHEN 0 THEN
                                      DATALENGTH([sqltext])
                                    ELSE [statement_end] - [statement_start] + 1
                                  END)
                  END AS [Statement]
                , CASE
                    WHEN [parameter_end] > [parameter_start] THEN
                      CAST (SUBSTRING([query_plan]
                                      , [parameter_start]
                                      , [parameter_end] - [parameter_start]) AS XML)
                  END AS [params]
         FROM   [basedata])
SELECT [set_options]                                       AS [set]
       , [next_level].[statement_start]                    AS [position]
       , [next_level].[Statement]
       , [column_reference].[c].[value]('@Column'
                                        , 'nvarchar(128)') AS [parameter]
       , [column_reference].[c].[value]('@ParameterCompiledValue'
                                        , 'nvarchar(128)') AS [sniffed_value]
       , CAST ([query_plan] AS XML)                        AS [query_plan]
FROM   [next_level] [next_level]
       CROSS APPLY [next_level].[params].[nodes]('ColumnReference') AS [column_reference] ( [c] )
ORDER  BY [next_level].[set_options]
          , [next_level].[statement_start]
          , [parameter]; 
