--
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobs-transact-sql?view=sql-server-2017
-------------------------------------------------

use [msdb];

go

-- 
-- find jobs with no email notification
-------------------------------------------------
select [sysjobs].[name] as [job_name]
from   [msdb].[dbo].[sysjobs] as [sysjobs]
       left join [msdb].[dbo].[sysoperators] as [sysoperators]
              on ( [sysjobs].[notify_email_operator_id] = [sysoperators].[id] )
where  [sysjobs].[enabled] = 1
       and [sysjobs].[notify_level_email] not in ( 1, 2, 3 )

GO

select [sysjobs].[name]                    as [job_name]
       , [sysjobs].[notify_level_email]    as [notify_level_email]
       , [notify_email_operator].[name]    as [email_operator]
       , [sysjobs].[notify_level_netsend]  as [notify_level_netsend]
       , [notify_netsend_operator].[name]  as [net_send_operator]
       , [sysjobs].[notify_level_page]     as [notify_level_page]
       , [notify_page_operator].[name]     as [pager_operator]
       , [sysjobs].[notify_level_eventlog] as [notify_level_eventlog]
       , [sysjobs].[delete_level]          as [delete_level]
from   [msdb].[dbo].[sysjobs] as [sysjobs]
       left join [msdb].[dbo].[sysoperators] as [notify_email_operator]
              on [sysjobs].[notify_email_operator_id] = [notify_email_operator].[id]
       left join [msdb].[dbo].[sysoperators] as [notify_netsend_operator]
              on [sysjobs].[notify_netsend_operator_id] = [notify_netsend_operator].[id]
       left join [msdb].[dbo].[sysoperators] as [notify_page_operator]
              on [sysjobs].[notify_page_operator_id] = [notify_page_operator].[id];

go

use [msdb];

GO

with jobStates
     as (select 0            as [Level]
                , 'Disabled' as [Description]
         union all
         select 1
                , 'On Success'
         union all
         select 2
                , 'On Failure'
         union all
         select 3
                , 'On Completion')
select [j].[job_id]
       , [j].name
       , [es].[Description]     as [EmailOnJobState]
       , [e].name               as [EmailOperatorName]
       , [e].[email_address]    as [EmailOperatorEmailAddress]
       , [ps].[Description]     as [PageOnJobState]
       , [p].name               as [PageOperatorName]
       , [p].[pager_address]    as [PageOperatorPagerAddress]
       , [nss].[Description]    as [NetSendOnJobState]
       , [ns].name              as [NetSendOperatorName]
       , [ns].[netsend_address] as [NetSendOperatorNetSendAddress]
       , [els].[Description]    as [EventLogOnJobState]
       , [ds].[Description]     as [DeleteJobOnJobState]
from   [dbo].[sysjobs] [j]
       inner join jobStates [es]
               on [es].[Level] = [j].[notify_level_email]
       inner join jobStates [ps]
               on [ps].[Level] = [j].[notify_level_page]
       inner join jobStates [nss]
               on [nss].[Level] = [j].[notify_level_netsend]
       inner join jobStates [els]
               on [els].[Level] = [j].[notify_level_eventlog]
       inner join jobStates [ds]
               on [ds].[Level] = [j].[delete_level]
       left outer join [dbo].[sysoperators] [e]
                    on ( [j].[notify_level_email] > 0 )
                       and ( [e].[id] = [j].[notify_email_operator_id] )
       left outer join [dbo].[sysoperators] [p]
                    on ( [j].[notify_level_page] > 0 )
                       and ( [p].[id] = [j].[notify_page_operator_id] )
       left outer join [dbo].[sysoperators] [ns]
                    on ( [j].[notify_level_netsend] > 0 )
                       and ( [ns].[id] = [j].[notify_netsend_operator_id] ); 
