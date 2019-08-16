/*
	show__restore_history.sql
	katherine.lightsey@aristocrat.com
	20181213

	This script shows the logged restore history and compares it to [msdb].[dbo].[restorehistory].

	The logged restore is from a script (J:\MSSQL_BACKUP\utility\restore__db__parameterized.sql) and may show a 
		slightly different timestamp than the timestamp in [msdb]. If the timestamps are within five to ten minutes 
		of one another it is highly probable the restore was done as logged.
	If the logged restore and timestamp in [msdb] are more than about fifteen minutes apart the restore was
		likely NOT done with the script and there is no way of being certain which .bak file was restored.
*/
with [restore__builder]
     as (select max([restore_date])           as [last__restore_date]
                , [destination_database_name] as [destination_database_name]
         from   [msdb].[dbo].[restorehistory]
         group  by [destination_database_name])
select top(1) [id]                                                                                     as [log__id]
              , [backup__level].[database]                                                             as [database]
              , [backup__level].[database__backup__file]                                               as [database__backup__file]
              , [backup__level].[timestamp]                                                            as [timestamp]
              , [restore__builder].[last__restore_date]                                                as [last__restore_date]
              , datediff(minute, [backup__level].[timestamp], [restore__builder].[last__restore_date]) as [delta]
from   [utility].[utility].[backup__level] as [backup__level]
       left join [restore__builder] as [restore__builder]
              on [restore__builder].[destination_database_name] = [backup__level].[database]
order  by [created] desc; 
