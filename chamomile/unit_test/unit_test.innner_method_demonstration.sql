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

insert into [test].[data]
            ([flower],
             [color])
values      (N'rose',
             N'red');

--
-------------------------------------------------
if object_id(N'[test].[inner]'
             , N'P') is not null
  drop procedure [test].[inner];

go

create procedure [test].[inner]
as
  begin
      select [flower] as N'in inner'
             , [color]
      from   [test].[data];
  end;

go

--
-------------------------------------------------
if object_id(N'[test].[outer]'
             , N'P') is not null
  drop procedure [test].[outer];

go

create procedure [test].[outer]
as
  begin
      set nocount on;
      set transaction isolation level serializable;

      begin transaction outer_transaction;

      update [test].[data]
      set    [color] = N'yellow'
      where  [flower] = N'rose';

      execute [test].[inner];

      rollback transaction outer_transaction;
  end;

go

execute [test].[outer];

go

select *
from   [test].[data]; 
