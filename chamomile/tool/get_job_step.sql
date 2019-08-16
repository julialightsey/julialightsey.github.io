--
-- Output all jobs with step information.
-- get_job_step.sql
-------------------------------------------------
WITH [builder]
     AS (SELECT [sysjobs].[name]                                                    AS [job_name]
                , [sysjobsteps].[database_name]                                     AS [database_name]
                , [sysjobs].[enabled]                                               AS [enabled]
                , isnull([sysschedules].[enabled], 0)                               AS [scheduled]
                , [sysjobs].[description]                                           AS [job_description]
                , [sysjobsteps].[step_id]                                           AS [step_id]
                , [sysjobsteps].[step_name]                                         AS [step_name]
                , [sysjobsteps].[subsystem]                                         AS [subsystem]
                , [sysjobsteps].[command]                                           AS [command]
                , LEFT(CAST([sysjobsteps].[last_run_date] AS VARCHAR), 4)
                  + '-'
                  + SUBSTRING(CAST([sysjobsteps].[last_run_date] AS VARCHAR), 5, 2)
                  + '-'
                  + SUBSTRING(CAST([sysjobsteps].[last_run_date] AS VARCHAR), 7, 2) AS [last_run_date]
                , CASE
                    WHEN LEN(CAST([sysjobsteps].[last_run_time] AS VARCHAR)) = 6 THEN SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 1, 2)
                                                                                      + ':'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 3, 2)
                                                                                      + ':'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 5, 2)
                    WHEN LEN(CAST([sysjobsteps].[last_run_time] AS VARCHAR)) = 5 THEN '0'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 1, 1)
                                                                                      + ':'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 2, 2)
                                                                                      + ':'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 4, 2)
                    WHEN LEN(CAST([sysjobsteps].[last_run_time] AS VARCHAR)) = 4 THEN '00:'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 1, 2)
                                                                                      + ':'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 3, 2)
                    WHEN LEN(CAST([sysjobsteps].[last_run_time] AS VARCHAR)) = 3 THEN '00:' + '0'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 1, 1)
                                                                                      + ':'
                                                                                      + SUBSTRING(CAST([sysjobsteps].[last_run_time] AS VARCHAR), 2, 2)
                    WHEN LEN(CAST([sysjobsteps].[last_run_time] AS VARCHAR)) = 2 THEN '00:00:'
                                                                                      + CAST([sysjobsteps].[last_run_time] AS VARCHAR)
                    WHEN LEN(CAST([sysjobsteps].[last_run_time] AS VARCHAR)) = 1 THEN '00:00:' + '0'
                                                                                      + CAST([sysjobsteps].[last_run_time] AS VARCHAR)
                  END                                                               AS [last_run_time]
         FROM   msdb.dbo.[sysjobsteps] AS [sysjobsteps]
                JOIN [msdb].[dbo].[sysjobs] AS [sysjobs]
                  ON [sysjobs].[job_id] = [sysjobsteps].[job_id]
                LEFT OUTER JOIN [msdb].[dbo].[sysjobschedules] AS [sysjobschedules]
                             ON [sysjobs].[job_id] = [sysjobschedules].[job_id]
                LEFT OUTER JOIN [msdb].[dbo].[sysschedules] AS [sysschedules]
                             ON [sysjobschedules].[schedule_id] = [sysschedules].[schedule_id])
SELECT [job_name]
       , [database_name]
       , [step_id]
       , [step_name]
       , CASE
           WHEN [subsystem] = 'SSIS' THEN replace(replace(replace(replace(replace(replace([command], '/SQL ', ''), '" /SERVER', ''), '<instance>\<database>', ''), '/CHECKPOINTING OFF', ''), '/REPORTING E', ''), '"', '')
           ELSE NULL
         END                                     AS [command]
       , [subsystem]
       , [enabled]
       , [scheduled]
       , [job_description]
       , [last_run_date] + ' ' + [last_run_time] AS [last_run_datetime]
FROM   [builder]
ORDER  BY [enabled] DESC
          , [job_name]
          , [step_id]; 
