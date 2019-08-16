use [chamomile_oltp];
go
if schema_id(N'flower_secure') is null
  execute (N'create schema flower_secure');
go
if schema_id(N'flower') is null
  execute (N'create schema flower');
go
if object_id(N'[flower_secure].[data]', N'U') is not null
  drop table [flower_secure].[data];
go
create table [flower_secure].[data] (
  [id]              [int] identity(1, 1) not null constraint [flower_secure.data.id.clustered_primary_key] primary key clustered
  , [flower]        [sysname]
  , [quantity]      [int] not null
  , [delivery_date] [datetime] not null
  );
go
insert into [flower_secure].[data]
            ([flower]
             , [quantity]
             , [delivery_date])
values      (N'rose'
             , 12
             , dateadd(day, 3, current_timestamp)),
            (N'lily'
             , 3
             , dateadd(day, 5, current_timestamp)),
            (N'chamomile'
             , 6
             , dateadd(day, 1, current_timestamp));
go
--
-- code block begin
-----------------------------------------
if object_id(N'[flower].[set]', N'P') is not null
  drop procedure [flower].[set];
go
create procedure [flower].[set]
  @id              [int] = null
  , @flower        [sysname] = null
  , @quantity      [int] = null
  , @delivery_date [datetime] = null
  , @commit        [bit] = 0
  , @stack         [xml] output
as
  begin
      declare @result   [xml] = N'<result />'
              , @before [xml]
              , @after  [xml];
      declare @output as table (
        [id]              [int]
        , [flower]        [sysname]
        , [quantity]      [int]
        , [delivery_date] [datetime]
        );
      --
      set @before = (select [id]              as N'id'
                            , [flower]        as N'flower'
                            , [quantity]      as N'quantity'
                            , [delivery_date] as N'delivery_date'
                     from   [flower_secure].[data]
                     where  [id] = @id
                     for xml path(N'before'), root(N'flower'));
      set @result.modify(N'insert sql:variable("@before") as last into (/*)[1]');
      --
      begin transaction;
      merge into [flower_secure].[data] as target
      using (values(@id
            , @flower
            , @quantity
            , @delivery_date)) as source ([id], [flower], [quantity], [delivery_date])
      on target.[id] = source.[id]
      when matched then
        update set target.[flower] = coalesce(source.[flower], target.[flower])
                   , target.[quantity] = coalesce(source.[quantity], target.[quantity])
                   , target.[delivery_date] = coalesce(source.[delivery_date], target.[delivery_date])
      when not matched by target then
        insert ( [flower]
                 , [quantity]
                 , [delivery_date])
        values ( [flower]
                 , [quantity]
                 , [delivery_date])
      output inserted.[id]
             , inserted.[flower]
             , inserted.[quantity]
             , inserted.[delivery_date]
      into @output ([id], [flower], [quantity], [delivery_date]);
      if @commit = 1
        commit transaction;
      else
        rollback transaction;
      --
      set @after =(select [id]              as N'id'
                          , [flower]        as N'flower'
                          , [quantity]      as N'quantity'
                          , [delivery_date] as N'delivery_date'
                   from   @output
                   where  [id] = @id
                   for xml path(N'after'), root(N'flower'));
      set @result.modify(N'insert sql:variable("@after") as last into (/*)[1]');
      --
      set @stack = @result;
  end;
go
-----------------------------------------
-- code block end
--

--
-- code block begin
-----------------------------------------
select [id]
       , [flower]
       , [quantity]
       , [delivery_date]
from   [flower_secure].[data]
where  [id] = 2;
go
declare @stack [xml];
execute [flower].[set]
  @id        = 2
  , @quantity=24
  , @stack   = @stack output;
select @stack as N'@stack';
go
select [id]
       , [flower]
       , [quantity]
       , [delivery_date]
from   [flower_secure].[data]
where  [id] = 2;
go 
-----------------------------------------
-- code block end
--


--
-- code block begin
-----------------------------------------
select [id]
       , [flower]
       , [quantity]
       , [delivery_date]
from   [flower_secure].[data]
where  [id] = 2;
go
declare @stack [xml];
execute [flower].[set]
  @id        = 2
  , @quantity=24
  , @commit  = 1
  , @stack   = @stack output;
select @stack as N'@stack';
go
select [id]
       , [flower]
       , [quantity]
       , [delivery_date]
from   [flower_secure].[data]
where  [id] = 2;
go 

-----------------------------------------
-- code block end
--