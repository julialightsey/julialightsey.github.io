use [chamomile_oltp];

go

if schema_id(N'test') is null
  execute (N'create schema test');

go

--
-------------------------------------------------
if object_id(N'[test].[data]'
             , N'U') is not null
  drop table [test].[data];

go

create table [test].[data]
  (
     [id]       [int] identity(1, 1)
     , [flower] [sysname]
     , [color]  [sysname]
  );

go

--
-------------------------------------------------
if object_id(N'[test].[data_log]'
             , N'U') is not null
  drop table [test].[data_log];

go

create table [test].[data_log]
  (
     [id]       [int]
     , [flower] [sysname]
     , [color]  [sysname]
  );

go

--
-------------------------------------------------
if exists (select *
           from   sys.triggers
           where  parent_class = 0
                  and name = 'test.data_log')
  drop trigger [test.data_log] on database;

go

create trigger [test.data_log]
on [test].[data]
for insert, update
as
  begin
      insert into [test].[data_log]
                  ([id],
                   [flower],
                   [color])
      select [inserted].[id]
             , [inserted].[flower]
             , [inserted].[color]
      from   inserted as [inserted];
  end;

go

--
-------------------------------------------------
begin transaction;

insert into [test].[data]
            ([flower],
             [color])
values      (N'rose',
             N'red');

select *
from   [test].[data_log];

rollback transaction;

--
-------------------------------------------------
select *
from   [test].[data_log]; 
