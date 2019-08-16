--
-- code block begin
-------------------------------------------------
--
-- we can add a "run" method to run all math tests
-------------------------------------------------
if object_id(N'[math__test].[run]', N'P') is not null
  drop procedure [math__test].[run];

go

/*
	select [name]
           , [value]
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'run', null, null);  
*/
create procedure [math__test].[run] @stack [xml] output
as
  begin
      declare @test_stack   [xml]
              , @test_suite [xml] = N'<test_suite stack_count="0" test_count="0" error_count="0" pass_count="0" />'
              , @count      [int];

      execute [math__test].[divide] @stack=@test_stack output;

      set @test_suite.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');

      --
      execute [math__test].[divide_using_decimal] @stack=@test_stack output;

      set @test_suite.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');
      --
      ----------------------------------------------
      set @count = @test_suite.value(N'count (//test_stack)', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@stack_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test)', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test[@actual="fail"])', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test[@actual="pass"])', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      --
      ----------------------------------------------
      set @stack = @test_suite;
  end;

go

if exists (select *
           from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'run', default, default))
  exec sys.sp_dropextendedproperty @name         = N'execute_as'
                                   , @level0type = N'schema'
                                   , @level0name = N'math__test'
                                   , @level1type = N'procedure'
                                   , @level1name = N'run'
                                   , @level2type = null
                                   , @level2name =null;

exec sys.sp_addextendedproperty @name         = N'execute_as'
                                , @value      = N'declare @stack [xml]; execute [math__test].[run] @stack=@stack output; select @stack;'
                                , @level0type = N'schema'
                                , @level0name = N'math__test'
                                , @level1type = N'procedure'
                                , @level1name = N'run'
                                , @level2type = null
                                , @level2name =null;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];

execute [math__test].[run] @stack=@stack output;

select @stack;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
/*
	we can modify the test run method to automatically run all tests in the schema.

	select [name]
           , [value]
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'run', null, null);  
*/
if object_id(N'[math__test].[run]', N'P') is not null
  drop procedure [math__test].[run];

go

create procedure [math__test].[run] @stack [xml] output
as
  begin
      declare @test_stack   [xml]
              , @test_suite [xml] = N'<test_suite stack_count="0" test_count="0" error_count="0" pass_count="0" />'
              , @count      [int]
              , @object     [nvarchar](max)
              , @sql        [nvarchar](max)
              , @parameters [nvarchar](max);
      declare test_list cursor for
        select N'[math__test].[' + [name] + N']'
        from   [sys].[procedures]
        where  object_schema_name([object_id]) = N'math__test'
               and [object_id] != @@procid;

      open test_list;

      fetch next from test_list into @object;

      while @@fetch_status = 0
        begin
            select @sql = N'execute ' + @object
                          + N' @stack=@test_stack output;'
                   , @parameters = N'@test_stack [xml] output';

            begin try
                execute sp_executesql @sql          =@sql
                                      , @parameters =@parameters
                                      , @test_stack = @test_stack output;
            end try
            begin catch
                select error_message()
                       , @sql
                       , @parameters;
            end catch;

            set @test_suite.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');

            fetch next from test_list into @object;
        end;

      close test_list;

      deallocate test_list;

      --
      ----------------------------------------------
      set @count = @test_suite.value(N'count (//test_stack)', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@stack_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test)', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test[@actual="fail"])', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test[@actual="pass"])', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      --
      ----------------------------------------------
      set @stack = @test_suite;
  end;

go

if exists (select *
           from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'run', default, default))
  exec sys.sp_dropextendedproperty @name         = N'execute_as'
                                   , @level0type = N'schema'
                                   , @level0name = N'math__test'
                                   , @level1type = N'procedure'
                                   , @level1name = N'run'
                                   , @level2type = null
                                   , @level2name =null;

exec sys.sp_addextendedproperty @name         = N'execute_as'
                                , @value      = N'declare @stack [xml]; execute [math__test].[run] @stack=@stack output; select @stack;'
                                , @level0type = N'schema'
                                , @level0name = N'math__test'
                                , @level1type = N'procedure'
                                , @level1name = N'run'
                                , @level2type = null
                                , @level2name =null;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];

execute [math__test].[run] @stack=@stack output;

select @stack;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
if schema_id(N'test') is null
  execute (N'create schema test');

go

if object_id(N'[math__test].[run]', N'P') is not null
  drop procedure [math__test].[run];

go

/*
	we can create a test to run all tests in the database.
	
	select [name]
           , [value]
    from   fn_listextendedproperty(N'execute_as', N'schema', N'test', N'procedure', N'run', null, null);  
*/
use [master];

go

if object_id(N'[dbo].[sp__chamomile__run_test]', N'P') is not null
  drop procedure [dbo].[sp__chamomile__run_test];

go

create procedure [dbo].[sp__chamomile__run_test] @stack [xml] output
as
  begin
      declare @test_stack            [xml]
              , @test_suite          [xml] = N'<test_suite stack_count="0" test_count="0" error_count="0" pass_count="0" />'
              , @default_test_suffix [sysname] = N'_test'
              , @count               [int]
              , @object              [nvarchar](max)
              , @sql                 [nvarchar](max)
              , @parameters          [nvarchar](max);
      declare test_list cursor for
        select N'[' + object_schema_name([object_id])
               + N'].[' + [name] + N']'
        from   [sys].[procedures]
        where  object_schema_name([object_id]) like N'%_test'
               and [object_id] != @@procid;

      open test_list;

      fetch next from test_list into @object;

      while @@fetch_status = 0
        begin
            select @sql = N'execute ' + @object
                          + N' @stack=@test_stack output;'
                   , @parameters = N'@test_stack [xml] output';

            begin try
                execute sp_executesql @sql          =@sql
                                      , @parameters =@parameters
                                      , @test_stack = @test_stack output;
            end try
            begin catch
                select error_message()
                       , @sql
                       , @parameters;
            end catch;

            set @test_suite.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');

            fetch next from test_list into @object;
        end;

      close test_list;

      deallocate test_list;

      --
      ----------------------------------------------
      set @count = @test_suite.value(N'count (//test_stack)', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@stack_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test)', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test[@actual="fail"])', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @count = @test_suite.value(N'count (//test[@actual="pass"])', N'[int]');
      set @test_suite.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      --
      ----------------------------------------------
      set @stack = @test_suite;
  end;

go

--
-------------------------------------------------
exec [sp_MS_marksystemobject] N'[dbo].[sp__chamomile__run_test]';

go

if exists (select *
           from   fn_listextendedproperty(N'execute_as', N'schema', N'test', N'procedure', N'run', default, default))
  exec sys.sp_dropextendedproperty @name         = N'execute_as'
                                   , @level0type = N'schema'
                                   , @level0name = N'dbo'
                                   , @level1type = N'procedure'
                                   , @level1name = N'sp__chamomile__run_test'
                                   , @level2type = null
                                   , @level2name =null;

exec sys.sp_addextendedproperty @name         = N'execute_as'
                                , @value      = N'declare @stack [xml]; execute [dbo].[sp__chamomile__run_test] @stack=@stack output; select @stack;'
                                , @level0type = N'schema'
                                , @level0name = N'dbo'
                                , @level1type = N'procedure'
                                , @level1name = N'sp__chamomile__run_test'
                                , @level2type = null
                                , @level2name =null;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];

execute [dbo].[sp__chamomile__run_test] @stack=@stack output;

select @stack
       , @stack.value(N'(/*/@stack_count)[1]', N'[int]') as [stack_count]
       , @stack.value(N'(/*/@test_count)[1]', N'[int]')  as [test_count]
       , @stack.value(N'(/*/@pass_count)[1]', N'[int]')  as [pass_count]
       , @stack.value(N'(/*/@error_count)[1]', N'[int]') as [error_count];

go 

-------------------------------------------------
-- code block end
--