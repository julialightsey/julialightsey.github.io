--
-- http://www.sqlmatters.com/Articles/See%20what%20queries%20are%20currently%20running.aspx
-- https://www.mssqltips.com/sqlservertip/1811/how-to-isolate-the-current-running-commands-in-sql-server/
-------------------------------------------------------
SELECT [dm_exec_requests].[start_time]             AS [start_time]
       , [dm_exec_requests].[session_id]           AS [spid]
       , DB_NAME([dm_exec_requests].[database_id]) AS [database]
       , SUBSTRING([dm_exec_sql_text].[text], ( [dm_exec_requests].[statement_start_offset] / 2 ) + 1,
         --
         CASE
             WHEN [dm_exec_requests].[statement_end_offset] = -1
                   OR [dm_exec_requests].[statement_end_offset] = 0 THEN
                 ( DATALENGTH([dm_exec_sql_text].[text]) - [dm_exec_requests].[statement_start_offset] / 2 ) + 1
             ELSE
                 ( [dm_exec_requests].[statement_end_offset] - [dm_exec_requests].[statement_start_offset] ) / 2 + 1
         END)                                      AS [executing_sql]
       , [dm_exec_requests].[status]               AS [status]
       , [dm_exec_requests].[command]              AS [command]
       , [dm_exec_requests].[wait_type]            AS [wait_type]
       , [dm_exec_requests].[wait_time]            AS [wait_time]
       , [dm_exec_requests].[wait_resource]        AS [wait_resource]
       , [dm_exec_requests].[last_wait_type]       AS [last_wait_type]
	   , [dm_exec_sessions].*
FROM   [sys].[dm_exec_requests] AS [dm_exec_requests]
       OUTER APPLY [sys].[dm_exec_sql_text]([sql_handle]) AS [dm_exec_sql_text]
	   join [sys].[dm_exec_sessions] as [dm_exec_sessions] on [dm_exec_sessions].[session_id] = [dm_exec_requests].[session_id]
WHERE  [dm_exec_requests].[session_id] != @@SPID -- don't show this query
	--AND [dm_exec_requests].[session_id] > 50 -- don't show system queries
	AND [dm_exec_sessions].[is_user_process] = 1 -- show only user processes
ORDER  BY [dm_exec_requests].[start_time]; 


select session_id
       , status
       , blocking_session_id
       , wait_type
       , wait_time
       , wait_resource
       , transaction_id
       , *
from   sys.dm_exec_requests
where  status = N'suspended';

go

select [dm_exec_sql_text].[text] as [sql_text]
       , [dm_exec_requests].*
from   [sys].[dm_exec_requests] as [dm_exec_requests]
       cross apply [sys].[dm_exec_sql_text]([sql_handle]) as [dm_exec_sql_text];

select object_schema_name([sql_modules].[object_id]) as [schema]
       , object_name([sql_modules].[object_id])      as [method]
       , [sql_modules].[definition]                  as [sql_text]
from   [sys].[sql_modules] as [sql_modules]
where  [sql_modules].[definition] like N'%<find_this_column>%';

--
-- track a running job by changes to the index
-------------------------------------------------
select [sysindexes].[name]        as [name]
       , [sysindexes].[rows]      as [rows]
       , [sysindexes].[rowmodctr] as [rowmodctr]
       , *
from   [sys].[sysindexes] as [sysindexes] with (nolock)
where  [sysindexes].[id] = object_id('[equity].[data]')
order  by [sysindexes].[name];

select *
from   [sys].[dm_tran_active_transactions]
where  [name] like N'equity_load%';

select *
from   sys.dm_tran_active_transactions
where  name like N'%<table_name>%'
order  by name;

-- http://stackoverflow.com/questions/980143/how-to-check-that-there-is-transaction-that-is-not-yet-committed-in-sql-server-2
select trans.session_id             as [session id]
       , eses.host_name             as [host name]
       , login_name                 as [login name]
       , trans.transaction_id       as [transaction id]
       , tas.name                   as [transaction name]
       , tas.transaction_begin_time as [transaction begin time]
       , tds.database_id            as [database id]
       , dbs.name                   as [database name]
from   sys.dm_tran_active_transactions tas
       join sys.dm_tran_session_transactions trans
         on ( trans.transaction_id = tas.transaction_id )
       left outer join sys.dm_tran_database_transactions tds
                    on ( tas.transaction_id = tds.transaction_id )
       left outer join sys.databases as dbs
                    on tds.database_id = dbs.database_id
       left outer join sys.dm_exec_sessions as eses
                    on trans.session_id = eses.session_id
where  eses.session_id is not null;

--
-- or 
select count(*)
from   [dbo].[<table_name>] with (nolock)

--
-------------------------------------------------
exec sp_who2

go

--
-------------------------------------------------
select *
from   [sys].[dm_tran_active_transactions] -- where name like N'%TX%';

--
-------------------------------------------------
select [blocking_session_id]
       , *
from   sys.dm_exec_requests
where  blocking_session_id <> 0;

go

dbcc inputbuffer(131)

go

kill 102 with statusonly;

go

--
-------------------------------------------------
select object_schema_name([dm_exec_sql_text].[objectid]
                          , [dm_exec_requests].[database_id]) as [schema]
       , object_name([dm_exec_sql_text].[objectid]
                     , [dm_exec_requests].[database_id])      as [object]
       , [dm_exec_requests].[session_id]                      as [session_id]
       , [dm_exec_requests].[blocking_session_id]             as [blocking_session_id]
       , [dm_exec_sql_text].[text]                            as [text]
       , [objectid]                                           as [objectid]
       , *
from   sys.dm_exec_requests as [dm_exec_requests]
       cross apply sys.dm_exec_sql_text([dm_exec_requests].[sql_handle]) as [dm_exec_sql_text];

--
-------------------------------------------------
declare @sqltext varbinary(199)

select @sqltext = sql_handle
from   sys.sysprocesses
where  spid = 61

select text
from   sys.dm_exec_sql_text(@sqltext)

go

declare @sqltext varbinary(128)

select @sqltext = sql_handle
from   sys.sysprocesses
where  spid = 61

select text
from   ::fn_get_sql(@sqltext)

go

execute sp_lock;

select session_id
       , wait_duration_ms
       , wait_type
       , blocking_session_id
from   sys.dm_os_waiting_tasks
where  blocking_session_id <> 0

kill 68 with statusonly;

go

select spid
       , status
       , loginame=substring(loginame
                            , 1
                            , 12)
       , hostname=substring(hostname
                            , 1
                            , 12)
       , blk = convert(char(3), blocked)
       , dbname=substring(db_name(dbid)
                          , 1
                          , 10)
       , cmd
       , waittype
from   master.dbo.sysprocesses
where  spid in (select blocked
                from   master.dbo.sysprocesses)

declare @databasename nvarchar(50) = N'DWReporting'
declare @sql varchar(max)

set @sql = ''

select @sql = @sql + 'Kill ' + convert(varchar, spid) + ';'
from   master..sysprocesses
where  dbid = db_id(@databasename)
       and spid <> @@spid
       and spid in (select blocked
                    from   master.dbo.sysprocesses)

--You can see the kill Processes ID
select @sql

--Kill the Processes
exec(@sql) 
