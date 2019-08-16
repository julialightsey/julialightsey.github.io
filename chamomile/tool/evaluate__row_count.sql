/*
	katherine.lightsey@aristocrat.com
	20181219

	This utility evaluates the delete in logged row counts. 
	Row counts must be logged in [utility].[utility].[log] by the utility script log__row_count.sql or by a similar script that logs in that format.
	This utility does not evaluate row counts for a specific database. Therefore, if you have run the utility script for multiple databases you will have to manually set the values of @latest and @prior to evaluate specific logged entries.
*/
use [utility];

go

--
-- execute to view log entries for row count
---------------------------------------------
--select *
--from   [utility].[utility].[log]
--where  [entry].value(N'(/*/@subject)[1]', N'[sysname]') = N'log__row_count'
--order  by [created] desc;
--
-- leave @latest and @prior null to select the latest to logged entries
-- set @latest and @prior to specific values of [id] from [utility].[log] to evaluate those specific entries
-------------------------------------------------
declare @latest [bigint] = null,
        @prior  [bigint] = null;
declare @entry__list as table
  (
     [id]    [bigint],
     [entry] [xml]
  );

if @latest is null
   and @prior is null
  begin;
      insert into @entry__list
                  ([id],
                   [entry])
      select top(2) [id]
                    , [entry]
      from   [utility].[utility].[log]
      where  [entry].value(N'(/*/@subject)[1]', N'[sysname]') = N'log__row_count'
      order  by [created] desc;
  end;
else
  begin;
      insert into @entry__list
                  ([id],
                   [entry])
      select top(2) [id]
                    , [entry]
      from   [utility].[utility].[log]
      where  [entry].value(N'(/*/@subject)[1]', N'[sysname]') = N'log__row_count'
             and [id] = @prior
              or [id] = @latest
      order  by [created] desc;
  end;

--
declare @entry__latest [xml] = (select top(1) [entry]
           from   @entry__list
           where  [entry].value(N'(/*/@subject)[1]', N'[sysname]') = N'log__row_count'
           order  by [id] desc),
        @entry__prior  [xml] = (select top(1) [entry]
           from   @entry__list
           where  [entry].value(N'(/*/@subject)[1]', N'[sysname]') = N'log__row_count'
           order  by [id] asc);

--
with [latest]
     as (select [t].[c].query(N'./table').value(N'(/*)[1]', N'[nvarchar](384)') as [table]
                , [t].[c].query(N'./row_count').value(N'(/*)[1]', N'[bigint]')  as [row_count]
                , @entry__latest.value(N'(/*/@timestamp)[1]', N'[datetime]')    as [timestamp]
         from   @entry__latest.nodes(N'/table__list/table') as [t]([c])),
     [prior]
     as (select [t].[c].query(N'./table').value(N'(/*)[1]', N'[nvarchar](384)') as [table]
                , [t].[c].query(N'./row_count').value(N'(/*)[1]', N'[bigint]')  as [row_count]
                , @entry__prior.value(N'(/*/@timestamp)[1]', N'[datetime]')     as [timestamp]
         from   @entry__prior.nodes(N'/table__list/table') as [t]([c]))
select [latest].[table]
       , format([prior].[row_count], N'###,###,###,###')                        as [prior__row_count]
       , [prior].[timestamp]                                                    as [prior__timestamp]
       , format([latest].[row_count], N'###,###,###,###')                       as [latest__row_count]
       , [latest].[timestamp]                                                   as [latest__timestamp]
       , format([latest].[row_count] - [prior].[row_count], N'###,###,###,###') as [delta__row_count]
from   [latest] as [latest]
       join [prior] as [prior]
         on [prior].[table] = [latest].[table]
where  [latest].[row_count] <> [prior].[row_count]
order  by [latest].[table]; 
