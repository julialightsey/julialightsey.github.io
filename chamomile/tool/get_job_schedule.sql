--
-- Output all jobs with schedule information.
-- get_job_schedule.sql
-------------------------------------------------
set transaction isolation level read uncommitted;

with [builder]
     as (select [jobs].[name]                                         as [job_name]
                , [jobs].[enabled]                                    as [enabled]
                , isnull([sysschedules].[enabled], 0)                 as [scheduled]
                , [jobs].[description]                                as [job_description]
                , [sysschedules].[name]                               as [schedule_name]
				, [sysschedules].[schedule_id]
                , case [sysschedules].[freq_type]
                    when 1 then 'Once'
                    when 4 then 'Daily'
                    when 8 then 'Weekly'
                    when 16 then 'Monthly'
                    when 32 then 'Monthly relative'
                    when 64 then 'When SQL Server Agent starts'
                    when 128 then 'Start whenever the CPU(s) become idle'
                    else ''
                  end                                                 as [occurs]
                , case [sysschedules].[freq_type]
                    when 1 then 'O'
                    when 4 then 'Every '
                                + convert(varchar, [sysschedules].[freq_interval])
                                + ' day(s)'
                    when 8 then 'Every '
                                + convert(varchar, [sysschedules].[freq_recurrence_factor])
                                + ' weeks(s) on ' + left( case when [sysschedules].[freq_interval] & 1 = 1 then 'Sunday, ' else '' end + case when [sysschedules].[freq_interval] & 2 = 2 then 'Monday, ' else '' end + case when [sysschedules].[freq_interval] & 4 = 4 then 'Tuesday, ' else '' end + case when [sysschedules].[freq_interval] & 8 = 8 then 'Wednesday, ' else '' end + case when [sysschedules].[freq_interval] & 16 = 16 then 'Thursday, ' else '' end + case when [sysschedules].[freq_interval] & 32 = 32 then 'Friday, ' else '' end + case when [sysschedules].[freq_interval] & 64 = 64 then 'Saturday, ' else '' end, len( case when [sysschedules].[freq_interval] & 1 = 1 then 'Sunday, ' else '' end + case when [sysschedules].[freq_interval] & 2 = 2 then 'Monday, ' else '' end + case when [sysschedules].[freq_interval] & 4 = 4 then 'Tuesday, ' else '' end + case when [sysschedules].[freq_interval] & 8 = 8 then 'Wednesday, ' else '' end + case when [sysschedules].[freq_interval] & 16 = 16
                                then
                                'Thursday, '
                                else '' end + case when [sysschedules].[freq_interval] & 32 = 32 then 'Friday, ' else '' end + case when [sysschedules].[freq_interval] & 64 = 64 then 'Saturday, ' else '' end ) - 1 )
                    when 16 then 'Day '
                                 + convert(varchar, [sysschedules].[freq_interval])
                                 + ' of every '
                                 + convert(varchar, [sysschedules].[freq_recurrence_factor])
                                 + ' month(s)'
                    when 32 then 'The '
                                 + case [sysschedules].[freq_relative_interval]
                                     when 1 then 'First'
                                     when 2 then 'Second'
                                     when 4 then 'Third'
                                     when 8 then 'Fourth'
                                     when 16 then 'Last'
                                   end
                                 + case [sysschedules].[freq_interval]
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
                                 + convert(varchar, [sysschedules].[freq_recurrence_factor])
                                 + ' month(s)'
                    else ''
                  end                                                 as [occurs_detail]
                , case [sysschedules].[freq_subday_type]
                    when 1 then 'Occurs once at '
                                + stuff(stuff(right('000000' + convert(varchar(8), [sysschedules].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                    when 2 then 'Occurs every '
                                + convert(varchar, [sysschedules].[freq_subday_interval])
                                + ' Seconds(s) between '
                                + stuff(stuff(right('000000' + convert(varchar(8), [sysschedules].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                                + ' and '
                                + stuff(stuff(right('000000' + convert(varchar(8), [sysschedules].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
                    when 4 then 'Occurs every '
                                + convert(varchar, [sysschedules].[freq_subday_interval])
                                + ' Minute(s) between '
                                + stuff(stuff(right('000000' + convert(varchar(8), [sysschedules].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                                + ' and '
                                + stuff(stuff(right('000000' + convert(varchar(8), [sysschedules].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
                    when 8 then 'Occurs every '
                                + convert(varchar, [sysschedules].[freq_subday_interval])
                                + ' Hour(s) between '
                                + stuff(stuff(right('000000' + convert(varchar(8), [sysschedules].[active_start_time]), 6), 5, 0, ':'), 3, 0, ':')
                                + ' and '
                                + stuff(stuff(right('000000' + convert(varchar(8), [sysschedules].[active_end_time]), 6), 5, 0, ':'), 3, 0, ':')
                    else ''
                  end                                                 as [frequency]
                , convert(decimal(18, 2), [jobhistory].[AvgDuration]) as [avg_duration_sec]
                , case [sysjobschedules].[next_run_date]
                    when 0 then convert(datetime, '1900/1/1')
                    else convert(datetime, convert(char(8), [sysjobschedules].[next_run_date], 112)
                                           + ' '
                                           + stuff(stuff(right('000000' + convert(varchar(8), [sysjobschedules].[next_run_time]), 6), 5, 0, ':'), 3, 0, ':'))
                  end                                                 as [next_run_date]
                , [categories].[name]                                 as [category]
                , suser_sname([jobs].[owner_sid])                     as [owner]
         from   [msdb].[dbo].[sysjobs] as [jobs]
                left outer join [msdb].[dbo].[sysjobschedules] as [sysjobschedules]
                             on [jobs].[job_id] = [sysjobschedules].[job_id]
                left outer join [msdb].[dbo].[sysschedules] as [sysschedules]
                             on [sysjobschedules].[schedule_id] = [sysschedules].[schedule_id]
                inner join [msdb].[dbo].[syscategories] [categories]
                        on [jobs].[category_id] = [categories].[category_id]
                left outer join (select [job_id]
                                        , [AvgDuration] = ( sum(( ( [run_duration] / 10000 * 3600 ) + ( ( [run_duration] % 10000 ) / 100 * 60 ) + ( [run_duration] % 10000 ) % 100 )) * 1.0 ) / count([job_id])
                                 from   [msdb].[dbo].[sysjobhistory]
                                 where  [step_id] = 0
                                 group  by [job_id]) as [jobhistory]
                             on [jobhistory].[job_id] = [jobs].[job_id])
select *
from   [builder]
where  [scheduled] <> 0 
order  by [next_run_date] asc;

GO 
