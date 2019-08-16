DECLARE @filter [SYSNAME]=NULL;

SELECT [sysjobactivity].[job_id]                 AS [job_id]
       , [sysjobs].[name]                        AS [job_name]
       , [sysjobactivity].[start_execution_date] AS [start_execution_date]
       , isnull([last_executed_step_id], 0) + 1  AS [current_executed_step_id]
       , [sysjobsteps].[step_name]               AS [step_name]
FROM   [msdb].[dbo].[sysjobactivity] AS [sysjobactivity]
       LEFT JOIN [msdb].[dbo].[sysjobhistory] AS [sysjobhistory]
              ON [sysjobactivity].[job_history_id] = [sysjobhistory].[instance_id]
       JOIN [msdb].[dbo].[sysjobs] AS [sysjobs]
         ON [sysjobactivity].[job_id] = [sysjobs].[job_id]
       JOIN [msdb].[dbo].[sysjobsteps] AS [sysjobsteps]
         ON [sysjobactivity].[job_id] = [sysjobsteps].[job_id]
            AND isnull([sysjobactivity].[last_executed_step_id], 0)
                + 1 = [sysjobsteps].[step_id]
WHERE  [sysjobactivity].[session_id] = (SELECT TOP (1) [session_id]
                                        FROM   [msdb].[dbo].[syssessions]
                                        ORDER  BY [agent_start_date] DESC)
       AND [start_execution_date] IS NOT NULL
       AND [stop_execution_date] IS NULL
       AND ( [sysjobs].[name] LIKE N'%' + @filter + N'%'
              OR @filter IS NULL );

go 
