/*
	Use this to get a list of steps and commands for a job
		along with job step history.
*/
--
-------------------------------------------------
use [msdb];

go

exec [dbo].[sp_help_jobactivity];

go

--
-- get running jobs
-------------------------------------------------
select [sysjobs].[name]
       , [sysjobactivity].*
from   [msdb].[dbo].[sysjobactivity] as [sysjobactivity]
       inner join msdb.dbo.[sysjobs] as [sysjobs]
               on [sysjobactivity].[job_id] = [sysjobs].[job_id]
where  [sysjobactivity].[start_execution_date] is not null
       and [sysjobactivity].[stop_execution_date] is null
order  by [sysjobs].[name];

--       
-------------------------------------------------
declare @job_name [sysname] = N'refresh.DWReporting.daily',
        @database [sysname] = N'DWReporting';

select [sysjobs].[job_id]          as [job_id]
       , [sysjobs].[name]          as [job]
       , [sysjobsteps].[step_name] as [step]
       , [sysjobsteps].[command]   as [command]
       , [sysjobs].[description]   as [description]
       ,
       --  
       [sysjobsteps].[step_id]     as [step_id]
       , [sysjobsteps].[step_uid]  as [step_uid]
       ,
       -- 
       null                        as [all_sysjobs_columns]
       , [sysjobs].*
       ,
       -- 
       null                        as [all_sysjobsteps_columns]
       , [sysjobsteps].*
from   [msdb].[dbo].[sysjobs] as [sysjobs]
       left join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
              on [sysjobsteps].[job_id] = [sysjobs].[job_id]
where  [sysjobs].[name] like N'%' + @job_name + N'%'
       and [sysjobsteps].[database_name] = @database
-- order by [sysjobsteps].[command];
-- order by [sysjobs].[name], [sysjobsteps].[step_id];
order  by [sysjobsteps].[step_name];

go

--
-- Use this to get job schedules, run dates, and other job information.
-------------------------------------------------
declare @job_name [sysname] = N'refresh.DWReporting.daily',
        @database [sysname] = N'DWReporting';

select [sysjobs].[job_id]              as [job_id]
       , [sysjobs].[name]              as [job]
       , [database_principals].[name]  as [owner]
       , [syscategories].[name]        as [category]
       , [sysjobs].[description]       as [description]
       , case [sysjobs].[enabled]
           when 1 then 'yes'
           when 0 then 'no'
         end                           as [is_enabled]
       , case
           when [sysschedules].[schedule_uid] is null then 'no'
           else 'yes'
         end                           as [is_scheduled]
       , [sysjobs].[date_created]      as [created]
       , [sysjobs].[date_modified]     as [modified]
       , [servers].[name]              as [server]
       , [sysjobsteps].[step_id]       as [start_step_number]
       , [sysjobsteps].[step_name]     as [start_step_name]
       , [sysschedules].[schedule_uid] as [schedule_id]
       , [sysschedules].[name]         as [schedule_name]
from   [msdb].[dbo].[sysjobs] as [sysjobs]
       left join [msdb].[sys].[servers] as [servers]
              on [sysjobs].[originating_server_id] = [servers].[server_id]
       left join [msdb].[dbo].[syscategories] as [syscategories]
              on [sysjobs].[category_id] = [syscategories].[category_id]
       left join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
              on [sysjobs].[job_id] = [sysjobsteps].[job_id]
                 and [sysjobs].[start_step_id] = [sysjobsteps].[step_id]
       left join [msdb].[sys].[database_principals] as [database_principals]
              on [sysjobs].[owner_sid] = [database_principals].[sid]
       left join [msdb].[dbo].[sysjobschedules] as [sysjobschedules]
              on [sysjobs].[job_id] = [sysjobschedules].[job_id]
       left join [msdb].[dbo].[sysschedules] as [sysschedules]
              on [sysjobschedules].[schedule_id] = [sysschedules].[schedule_id]
where  [sysjobsteps].[database_name] = @database
--and [sysjobs].[name] like N'%' + @job_name + N'%' 
order  by [job]; 
