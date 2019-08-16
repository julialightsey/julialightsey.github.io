--
declare @name_filter [sysname] = N'data_migration'
        , @enabled   [bit] = 1;

with [get_last_run]
     as (select [sysjobhistory].[job_id]
                , [sysjobs].[name]
                , [sysjobsteps].[step_name]
                , max([msdb].[dbo].[agent_datetime]([run_date], [run_time])) as [run_timestamp]
         from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                inner join [msdb].[dbo].[sysjobs] as [sysjobs]
                        on [sysjobs].[job_id] = [sysjobhistory].[job_id]
                join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
                  on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                     and [sysjobsteps].[step_id] = [sysjobhistory].[step_id]
         where  ( [sysjobs].[name] like @name_filter + N'%'
                   or @name_filter is null )
         group  by [sysjobhistory].[job_id]
                   , [sysjobs].[name]
                   , [sysjobsteps].[step_name])
   , [builder]
     as (select [sysjobhistory].[job_id]
                , [sysjobsteps].[step_name]
                , [sysjobhistory].[run_date]
                , [sysjobhistory].[run_time]
                , case [sysjobhistory].[run_status]
                    when 1 then 0
                    else 1
                  end                                                                                               as [return_code]
                , case [sysjobhistory].[run_status]
                    when 0 then N'failed'
                    when 1 then N'succeeded'
                    when 2 then N'retry'
                    when 3 then N'cancelled'
                    when 4 then N'in_progress'
                  end                                                                                               as [run_status]
                , [sysjobs].[enabled]
                , [msdb].[dbo].[agent_datetime]([run_date], [run_time])                                             as [run_timestamp]
                , ( [run_duration] / 10000 * 60 * 60 ) + ( [run_duration] / 100%100 * 60 ) + ( [run_duration]%100 ) as [run_duration_total_seconds]
         from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                inner join [msdb].[dbo].[sysjobs] as [sysjobs]
                        on [sysjobs].[job_id] = [sysjobhistory].[job_id]
                join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
                  on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                     and [sysjobsteps].[step_id] = [sysjobhistory].[step_id])
select [get_last_run].[name]                    as [job_name]
       , [get_last_run].[step_name]             as [step_name]
       , [builder].[enabled]                    as [enabled]
       , [get_last_run].[run_timestamp]         as [run_timestamp]
       , [builder].[run_status]                 as [run_status]
       , [builder].[return_code]                as [return_code]
       , [builder].[run_duration_total_seconds] as [run_duration_total_seconds]
from   [get_last_run] as [get_last_run]
       join [builder] as [builder]
         on [builder].[job_id] = [get_last_run].[job_id]
            and [builder].[run_timestamp] = [get_last_run].[run_timestamp]
            and [builder].[step_name] = [get_last_run].[step_name]
where  ( [builder].[enabled] = @enabled
          or @enabled is null )
order  by [get_last_run].[name]; 



--
-- get last run time for each job and step
-------------------------------------------------
with [builder]
     as (select [sysjobs].[name]                                             as [name]
                , [sysjobsteps].[job_id]                                     as [job_id]
                , [sysjobsteps].[step_id]                                    as [step_id]
                , max([sysjobhistory].[run_status])                          as [run_status]
                , max([msdb].[dbo].[agent_datetime]([run_date], [run_time])) as [run_date_time]
                , max([sysjobhistory].[message])                             as [message]
         from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                join [msdb].[dbo].[sysjobs] as [sysjobs]
                  on [sysjobs].[job_id] = [sysjobhistory].[job_id]
                --and  [sysjobhistory].[step_id]=0 
                join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
                  on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                     and [sysjobsteps].[step_id] = [sysjobhistory].[step_id]
         group  by [sysjobs].[name],[sysjobsteps].[job_id],[sysjobsteps].[step_id])
select [name]
       , [job_id]
       , [step_id]
	  , [run_status]
       , [run_date_time]
       , [message]
from   [builder]
where  [name] like N'%Migrate_Employee%'
order  by [name],[step_id],[run_date_time] desc;

--
----------------------------------------------
select [sysjobs].[name]                                        as [job_name]
       , [sysjobhistory].[run_duration] / 10000                as [hours]
       , [sysjobhistory].[run_duration] / 100%100              as [minutes]
       , [sysjobhistory].[run_duration]%100                    as [seconds]
       , [msdb].[dbo].[agent_datetime]([run_date], [run_time]) as [run_date_time]
       , [sysjobhistory].[message]                             as [message]
       , [sysjobhistory].[retries_attempted]                   as [retries_attempted]
from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
       join [msdb].[dbo].[sysjobs] as [sysjobs]
         on [sysjobs].[job_id] = [sysjobhistory].[job_id]
where  1 = 1
-- and [sysjobs].[enabled] = 1 -- only enabled jobs
--and [sysjobs].[name] = N'<job_name>'
order  by [job_name],[run_date_time] desc;

-- https://www.mssqltips.com/sqlservertip/1394/how-to-store-longer-sql-agent-job-step-output-messages/
exec dbo.sp_help_jobsteplog @job_name = N'test2';

go

--
----------------------------------------------
select [sysjobs].[name]                                        as [job_name]
       , [sysjobhistory].[run_duration] / 10000                as [hours]
       , [sysjobhistory].[run_duration] / 100%100              as [minutes]
       , [sysjobhistory].[run_duration]%100                    as [seconds]
       , [msdb].[dbo].[agent_datetime]([run_date], [run_time]) as [run_date_time]
       , [sysjobhistory].[message]                             as [message]
       , [sysjobhistory].[retries_attempted]                   as [retries_attempted]
from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
       join [msdb].[dbo].[sysjobs] as [sysjobs]
         on [sysjobs].[job_id] = [sysjobhistory].[job_id]
where  1 = 1
-- and [sysjobs].[enabled] = 1 -- only enabled jobs
--and [sysjobs].[name] = N'<job_name>'
order  by [job_name],[run_date_time] desc;

declare @job     [sysname] = N'<job_name>'
        , @begin [datetime] = N'20150901'
        , @end   [datetime] = null;

select [sysjobs].[name]                                        as [job_name]
       , [sysjobsteps].[step_name]                             as [step_name]
       , [sysjobsteps].[step_id]                               as [step_id]
       , [msdb].[dbo].[agent_datetime]([run_date], [run_time]) as [run_datetime]
       , [sysjobhistory].[message]                             as [message]
from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
       inner join [msdb].[dbo].[sysjobs] as [sysjobs]
               on [sysjobs].[job_id] = [sysjobhistory].[job_id]
       inner join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
               on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                  and [sysjobsteps].[step_id] = [sysjobhistory].[step_id]
where  [sysjobs].[name] like @job + N'%'
       and ( [msdb].[dbo].[agent_datetime]([run_date], [run_time]) >= @begin )
       and ( [msdb].[dbo].[agent_datetime]([run_date], [run_time]) <= @end
              or @end is null )
order  by [sysjobs].[name],[sysjobsteps].[job_id],[sysjobsteps].[step_id],[sysjobhistory].[run_date] desc,[sysjobhistory].[run_time] desc;

with [last_run]
     as (select [sysjobs].[name]             as [job]
                , [sysjobsteps].[step_name]  as [step]
                , [sysjobhistory].[run_time] as [start]
         from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory]
                join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
                  on [sysjobsteps].[job_id] = [sysjobhistory].[job_id]
                     and [sysjobsteps].[step_id] = [sysjobhistory].[step_id]
                join [msdb].[dbo].[sysjobs] as [sysjobs]
                  on [sysjobs].[job_id] = [sysjobhistory].[job_id]
         where  [sysjobs].[name] like N'%' + @job + N'%'
         group  by [sysjobs].[name],[sysjobsteps].[step_name],[sysjobhistory].[run_time])
select [sysjobs].[name]     as [job]
       , [step]             as [step]
       , [last_run].[start] as [start]
from   [msdb].[dbo].[sysjobs] as [sysjobs]
       join [msdb].[dbo].[sysjobsteps] as [sysjobsteps]
         on [sysjobsteps].[job_id] = [sysjobs].[job_id]
       join [last_run] as [last_run]
         on [last_run].[job] = [sysjobs].[name]
order  by [job],[step],[last_run].[start] desc;

/*

select * from  [msdb].[dbo].[sysjobhistory] as [sysjobhistory]

select [sysjobs].[name]                                                                                                                 as [job],
       [sysjobhistory].[step_name]                                                                                                      as [step],
       Cast(Str([sysjobhistory].run_date, 8, 0) as [datetime]) 
       + Cast(Stuff(Stuff(right('000000' + Cast ([sysjobhistory].run_time as [nvarchar](6)), 6), 5, 0, ':'), 3, 0, ':') as [datetime])  as [start], 
       Dateadd(second, ( ( [sysjobhistory].[run_duration] / 1000000 ) * 86400 ) + ( ( ( [sysjobhistory].[run_duration] - ( ( 
                                                                                        [sysjobhistory].[run_duration] / 1000000 ) 
                                                                                                                           * 1000000 ) ) /
                                                                                                      10000 ) * 3600 ) + ( ( (
                       [sysjobhistory].[run_duration] - ( ( 
                       [sysjobhistory].[run_duration] / 10000 ) * 10000 ) ) / 100 ) * 60 ) + ( [sysjobhistory].[run_duration] - ( 
                                                                                               [sysjobhistory].[run_duration] / 100 
                                                                                                                                ) * 100 ),
       Cast(Str([sysjobhistory].run_date, 8, 0) as [datetime]) 
       + Cast(Stuff(Stuff(right('000000' + Cast ([sysjobhistory].run_time as [nvarchar](6)), 6), 5, 0, ':'), 3, 0, ':') as [datetime])) as [end], 
       Stuff(Stuff(Replace(Str([run_duration], 6, 0), ' ', '0'), 3, 0, ':'), 6, 0, ':')                                                 as [duration],
       case [sysjobhistory].[run_status] 
         when 0 then 'failed' 
         when 1 then 'Succeded' 
         when 2 then 'Retry' 
         when 3 then 'Cancelled' 
         when 4 then 'In Progress' 
       end                                                                                                                              as [status],
       [sysjobhistory].[message]                                                                                                        as [message]
from   [msdb].[dbo].[sysjobhistory] as [sysjobhistory] 
       inner join [msdb].[dbo].[sysjobs] as [sysjobs] 
               on [sysjobs].job_id = [sysjobhistory].job_id 
where  [sysjobs].[name] like N'%' + @job + N'%' 
order  by [start] desc; 
*/
-- 
-- Jobs with frequency
-- https://www.sqlprofessionals.com/blog/sql-scripts/2014/10/06/insight-into-sql-agent-job-schedules/
--
select [JobName] = [jobs].[name]
       , [Category] = [categories].[name]
       , [Owner] = SUSER_SNAME([jobs].[owner_sid])
       , [Enabled] = case [jobs].[enabled]
                       when 1 then 'Yes'
                       else 'No'
                     end
       , [Scheduled] = case [schedule].[enabled]
                         when 1 then 'Yes'
                         else 'No'
                       end
       , [Description] = [jobs].[description]
       , [Occurs] = case [schedule].[freq_type]
                      when 1 then 'Once'
                      when 4 then 'Daily'
                      when 8 then 'Weekly'
                      when 16 then 'Monthly'
                      when 32 then 'Monthly relative'
                      when 64 then 'When SQL Server Agent starts'
                      when 128 then 'Start whenever the CPU(s) become idle'
                      else ''
                    end
       , [Occurs_detail] = case [schedule].[freq_type]
                             when 1 then 'O'
                             when 4 then 'Every '
                                         + convert(varchar, [schedule].[freq_interval])
                                         + ' day(s)'
                             when 8 then 'Every '
                                         + convert(varchar, [schedule].[freq_recurrence_factor])
                                         + ' weeks(s) on ' + left( case when [schedule].[freq_interval] & 1 = 1 then 'Sunday, ' else '' end + case when [schedule].[freq_interval] & 2 = 2 then 'Monday, ' else '' end + case when [schedule].[freq_interval] & 4 = 4 then 'Tuesday, ' else '' end + case when [schedule].[freq_interval] & 8 = 8 then 'Wednesday, ' else '' end + case when [schedule].[freq_interval] & 16 = 16 then 'Thursday, ' else '' end + case when [schedule].[freq_interval] & 32 = 32 then 'Friday, ' else '' end + case when [schedule].[freq_interval] & 64 = 64 then 'Saturday, ' else '' end, LEN( case when [schedule].[freq_interval] & 1 = 1 then 'Sunday, ' else '' end + case when [schedule].[freq_interval] & 2 = 2 then 'Monday, ' else '' end + case when [schedule].[freq_interval] & 4 = 4 then 'Tuesday, ' else '' end + case when [schedule].[freq_interval] & 8 = 8 then 'Wednesday, ' else '' end + case when [schedule].[freq_interval] & 16 = 16 then 'Thursday, ' else '' end + case
                                         when
                                         [schedule].[freq_interval] & 32 = 32 then 'Friday, ' else '' end + case when [schedule].[freq_interval] & 64 = 64 then 'Saturday, ' else '' end ) - 1 )
                             when 16 then 'Day '
                                          + convert(varchar, [schedule].[freq_interval])
                                          + ' of every '
                                          + convert(varchar, [schedule].[freq_recurrence_factor])
                                          + ' month(s)'
                             when 32 then 'The '
                                          + case [schedule].[freq_relative_interval]
                                              when 1 then 'First'
                                              when 2 then 'Second'
                                              when 4 then 'Third'
                                              when 8 then 'Fourth'
                                              when 16 then 'Last'
                                            end
                                          + case [schedule].[freq_interval]
                                              when 1 then ' Sunday'
                                              when 2 then ' Monday'
                                              when 3 then ' Tuesday'
                                              when 4 then ' Wednesday'
                                              when 5 then ' Thursday'
                                              when 6 then ' Friday'
                                              when 7 then ' Saturday'
                                              when 8 then ' Day'
                                              when 9 then ' Weekday'
                                              when 10 then ' Weekend Day'
                                            end
                                          + ' of every '
                                          + convert(varchar, [schedule].[freq_recurrence_factor])
                                          + ' month(s)'
                             else ''
                           end
       , [Frequency] = case [schedule].[freq_subday_type]
                         when 1 then 'Occurs once at '
                                     + STUFF(STUFF(right('000000' + convert(varchar(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                         when 2 then 'Occurs every '
                                     + convert(varchar, [schedule].[freq_subday_interval])
                                     + ' Seconds(s) between '
                                     + STUFF(STUFF(right('000000' + convert(varchar(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                                     + ' and '
                                     + STUFF(STUFF(right('000000' + convert(varchar(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
                         when 4 then 'Occurs every '
                                     + convert(varchar, [schedule].[freq_subday_interval])
                                     + ' Minute(s) between '
                                     + STUFF(STUFF(right('000000' + convert(varchar(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                                     + ' and '
                                     + STUFF(STUFF(right('000000' + convert(varchar(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
                         when 8 then 'Occurs every '
                                     + convert(varchar, [schedule].[freq_subday_interval])
                                     + ' Hour(s) between '
                                     + STUFF(STUFF(right('000000' + convert(varchar(8), [schedule].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                                     + ' and '
                                     + STUFF(STUFF(right('000000' + convert(varchar(8), [schedule].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
                         else ''
                       end
       , [AvgDurationInSec] = convert(decimal(18, 2), [jobhistory].[AvgDuration])
       , [Next_Run_Date] = case [jobschedule].[next_run_date]
                             when 0 then convert(datetime, '1900/1/1')
                             else convert(datetime, convert(char(8), [jobschedule].[next_run_date], 112)
                                                    + ' '
                                                    + STUFF(STUFF(right('000000' + convert(varchar(8), [jobschedule].[next_run_time]), 6), 5, 0, ':'), 3, 0, ':'))
                           end
from   [msdb].[dbo].[sysjobs] as [jobs] with(NOLOCK)
       left outer join [msdb].[dbo].[sysjobschedules] as [jobschedule] with(NOLOCK)
                    on [jobs].[job_id] = [jobschedule].[job_id]
       left outer join [msdb].[dbo].[sysschedules] as [schedule] with(NOLOCK)
                    on [jobschedule].[schedule_id] = [schedule].[schedule_id]
       inner join [msdb].[dbo].[syscategories] [categories] with(NOLOCK)
               on [jobs].[category_id] = [categories].[category_id]
       left outer join (select [job_id]
                               , [AvgDuration] = ( SUM(( ( [run_duration] / 10000 * 3600 ) + ( ( [run_duration] % 10000 ) / 100 * 60 ) + ( [run_duration] % 10000 ) % 100 )) * 1.0 ) / COUNT([job_id])
                        from   [msdb].[dbo].[sysjobhistory] with(NOLOCK)
                        where  [step_id] = 0
                        group  by [job_id]) as [jobhistory]
                    on [jobhistory].[job_id] = [jobs].[job_id];

GO 
