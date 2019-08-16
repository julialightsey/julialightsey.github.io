--
select [db].[name]
       , max([usage].[last_user_seek])   as [last_user_seek_max]
       , max([usage].[last_user_scan])   as [last_user_scan_max]
       , max([usage].[last_user_lookup]) as [last_user_lookup_max]
       , max([usage].[last_user_update]) as [last_user_update_max]
from   [sys].[dm_db_index_usage_stats] as [usage]
       join [sys].[databases] as [db]
         on [db].[database_id] = [usage].[database_id]
group  by [db].[name]
order by max([usage].[last_user_update]) asc;
--order  by [db].[name] asc; 
