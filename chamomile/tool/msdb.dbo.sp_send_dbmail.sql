

-- Mail (Id: 182) queued.
select [items].[subject]
       , [items].[last_mod_date]
       , [l].[description]
from   [msdb].[dbo].[sysmail_faileditems] as [items]
       inner join [msdb].[dbo].[sysmail_event_log] as [l]
               on [items].[mailitem_id] = [l].[mailitem_id]
where  [items].[subject] like N'%Table Size Audit Result%';

select *
from   [msdb].[dbo].[sysmail_allitems]
order  by [send_request_date] desc;

select *
from   [msdb].[dbo].[sysmail_event_log]
order  by [last_mod_date] desc; 
