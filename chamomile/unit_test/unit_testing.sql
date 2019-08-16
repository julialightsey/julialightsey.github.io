/*
	--
	---------------------------------------------
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html). 
*/ 
use [chamomile];
go
if schema_id(N'math') is null
  execute (N'create schema math');
go
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
if schema_id(N'math__test') is null
  execute (N'create schema math__test');
go
if object_id(N'[test].[run]', N'P') is not null
  drop procedure [test].[run];
go
if object_id(N'[math__test].[divide]', N'P') is not null
  drop procedure [math__test].[divide];
go 
create procedure [math__test].[divide]
  @stack [xml] output
as
  begin
      declare @test_stack       [xml] = N'<test_stack fqn="" test_count="0" error_count="0" pass_count="0" />'
              , @test_prototype [xml] = N'<test test_sequence="0" test_name="{replace_me}" expected="pass" actual="fail" />'
              , @test           [xml]
              , @test_sequence  [int]
              , @test_value     [float]
              , @count          [int]
              , @message        [nvarchar](max)
              , @test_name      [sysname]
              , @pass           [sysname] = N'pass'
              , @fail           [sysname] = N'fail'
              --
              -- a six part fqn is used to distinguish the complete fully qualified name of the object and where it is run.
              -- on a cluster, ComputerNamePhysicalNetBIOS is unique to the physical machine but MachineName is shared.
              --------------------------------------------
              , @subject_fqn    [nvarchar](max) = N'['
                + isnull(lower(cast(serverproperty(N'ComputerNamePhysicalNetBIOS') as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(serverproperty(N'MachineName') as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(serverproperty(N'InstanceName') as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(db_name() as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(object_schema_name(@@procid) as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(object_name(@@procid) as [sysname])), N'default')
                + N']';
      set @test_stack.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@subject_fqn")');
      --
      -------------------------------------------
      select @test_sequence = 1
             , @test_name = N'determine if target method exists'
             , @test = @test_prototype;
      set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
      set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
      --
      if object_id(N'[math].[divide]', N'FN') is null
        begin
            select @message = N'target function does not exist';
            set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;
      else
        begin
            --
            -- the target method existed, so include that as the first test in the stack
            -------------------------------------
            set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            --
            -------------------------------------
            begin
                --
                -------------------------------------
                select @test_sequence = 2
                       , @test_name = N'normal operation, white box test, return value must be numeric'
                       , @test = @test_prototype;
                set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
                set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
                begin try
                    if isnumeric([math].[divide](3, 3)) = 1
                      set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                end try
                begin catch
                    select @message = error_message();
                    set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                end catch;
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
            --
            -------------------------------------
            begin
                select @test_sequence = 3
                       , @test_name = N'divide by zero returns 0'
                       , @test = @test_prototype;
                set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
                set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
                begin try
                    if [math].[divide](3, 0) = 0
                      set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                end try
                begin catch
                    select @message = error_message();
                    set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                end catch;
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
            --
            -------------------------------------
            begin
                select @test_sequence = 4
                       , @test_name = N'null denominator returns 0'
                       , @test = @test_prototype;
                set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
                set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
                begin try
                    if [math].[divide](3, null) = 0
                      set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                end try
                begin catch
                    select @message = error_message();
                    set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                end catch;
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
            --
            -------------------------------------
            begin
                select @test_sequence = 5
                       , @test_name = N'null numerator returns 0'
                       , @test = @test_prototype;
                set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
                set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
                begin try
                    if [math].[divide](null, 3) = 0
                      set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                end try
                begin catch
                    select @message = error_message();
                    set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                end catch;
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
            --
            -------------------------------------
            begin
                select @test_sequence = 6
                       , @test_name = N'zero numerator returns 0'
                       , @test = @test_prototype;
                set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
                set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
                begin try
                    if [math].[divide](0, 3) = 0
                      set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                end try
                begin catch
                    select @message = error_message();
                    set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                end catch;
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
            --
            -------------------------------------
            begin
                select @test_sequence = 7
                       , @test_name = N'returns value rounded upwards to six places'
                       , @test = @test_prototype;
                set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
                set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
                begin try
                    set @test_value = [math].[divide](22, 7)
                    if @test_value = 3.142857
                      set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                    else
                      begin
                          select @message = N'expected 3.142857, actual value returned was '
                                            + cast(@test_value as [sysname]) + N'';
                          set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                      end;
                end try
                begin catch
                    select @message = error_message();
                    set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                end catch;
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
        end;
      --
      ----------------------------------------------
      set @count = @test_stack.value(N'count (//test)', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (//test[@actual="fail"])', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (//test[@actual="pass"])', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      --
      ----------------------------------------------
      set @stack = @test_stack;
  end;
go
if exists
   (select *
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'divide', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'math__test'
    , @level1type = N'procedure'
    , @level1name = N'divide'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'execute_as'
  , @value      = N'declare @stack [xml]; execute [math__test].[divide] @stack=@stack output; select @stack;'
  , @level0type = N'schema'
  , @level0name = N'math__test'
  , @level1type = N'procedure'
  , @level1name = N'divide'
  , @level2type = null
  , @level2name =null;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- does this method meet the test requirements?
-------------------------------------------------
--
-- note the naming convention used:
--	both the business method (tested object) and the test
--	have the same OBJECT_NAME. OBJECT_SCHEMA_NAME for the 
--	test is OBJECT_SCHEMA_NAME(OBJECT_ID({tested_object})) + N'_test'
-- this naming convention makes it immediately apparent which test
--	is for which object. Additional tests would normally be named
--	[math__test].[divide_{test_name}] so that a normal ORDER BY 
--	clause will order both the objects and associated tests such
--	that their association is obvious by inspection.
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
create function [math].[divide] (
  @numerator     [int]
  , @denominator [int])
returns [int]
as
  begin
      return 1;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];
execute [math__test].[divide]
  @stack=@stack output;
select @stack;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- does this method meet the test requirements?
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
create function [math].[divide] (
  @numerator     [int]
  , @denominator [int])
returns [int]
as
  begin
      return @numerator / @denominator;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];
execute [math__test].[divide]
  @stack=@stack output;
select @stack;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- does this method meet the test requirements?
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
create function [math].[divide] (
  @numerator     [int]
  , @denominator [int])
returns [decimal](10, 6)
as
  begin
      return round(cast (@numerator as [float]) / cast(@denominator as [float]), 6);
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];
execute [math__test].[divide]
  @stack=@stack output;
select @stack;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- does this method meet the test requirements?
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
create function [math].[divide] (
  @numerator     [int]
  , @denominator [int])
returns [decimal](10, 6)
as
  begin
      declare @return [decimal](10, 6);
      if @numerator is null
          or @denominator is null
        set @return = 0;
      else
        set @return = round(cast (@numerator as [float]) / cast(@denominator as [float]), 6);
      return @return;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];
execute [math__test].[divide]
  @stack=@stack output;
select @stack;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
--
-- does this method meet the test requirements?
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
create function [math].[divide] (
  @numerator     [int]
  , @denominator [int])
returns [decimal](10, 6)
as
  begin
      declare @return [decimal](10, 6);
      if @numerator is null
          or @denominator is null
          or @denominator = 0
        set @return = 0;
      else
        set @return = round(cast (@numerator as [float]) / cast(@denominator as [float]), 6);
      return @return;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];
execute [math__test].[divide]
  @stack=@stack output;
select @stack;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- we can add new tests for additional functionality. you can change the method at will,
--	as long as it still meets the original tests.
--
-------------------------------------------------
if object_id(N'[math__test].[divide_using_decimal]', N'P') is not null
  drop procedure [math__test].[divide_using_decimal];
go
/*
	select [name]
           , [value]
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'divide_using_decimal', null, null);  
*/
create procedure [math__test].[divide_using_decimal]
  @stack [xml] output
as
  begin
      declare @test_stack       [xml] = N'<test_stack fqn="" test_count="0" error_count="0" pass_count="0" />'
              , @test_prototype [xml] = N'<test test_sequence="0" test_name="{replace_me}" expected="pass" actual="fail" />'
              , @test           [xml]
              , @test_sequence  [int]
              , @test_value     [float]
              , @count          [int]
              , @message        [nvarchar](max)
              , @test_name      [sysname]
              , @pass           [sysname] = N'pass'
              , @fail           [sysname] = N'fail'
              , @subject_fqn    [nvarchar](max) = N'['
                + isnull(lower(cast(serverproperty(N'ComputerNamePhysicalNetBIOS') as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(serverproperty(N'MachineName') as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(serverproperty(N'InstanceName') as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(db_name() as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(object_schema_name(@@procid) as [sysname])), N'default')
                + N'].['
                + isnull(lower(cast(object_name(@@procid) as [sysname])), N'default')
                + N']';
      set @test_stack.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@subject_fqn")');
      --
      -------------------------------------------
      select @test_sequence = 1
             , @test_name = N'determine if target method exists'
             , @test = @test_prototype;
      set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
      set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
      if object_id(N'[math].[divide]', N'FN') is null
        begin
            select @message = N'target function does not exist';
            set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;
      else
        begin
            set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            --
            -------------------------------------
            begin
                select @test_sequence = 2
                       , @test_name = N'returns value rounded upwards to six places based on decimal input'
                       , @test = @test_prototype;
                set @test.modify(N'replace value of (/*/@test_sequence)[1] with sql:variable("@test_sequence")');
                set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
                begin try
                    set @test_value = [math].[divide](33.333333, 3)
                    if @test_value = 11.111111
                      set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                    else
                      begin
                          select @message = N'expected 11.111111, actual value returned was '
                                            + cast(@test_value as [sysname]) + N'';
                          set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                      end;
                end try
                begin catch
                    select @message = error_message();
                    set @test.modify(N'insert text {sql:variable("@message")} as last into (/*)[1]');
                end catch;
                set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
            end;
        end;
      --
      ----------------------------------------------
      set @count = @test_stack.value(N'count (//test)', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (//test[@actual="fail"])', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (//test[@actual="pass"])', N'[int]');
      set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      --
      ----------------------------------------------
      set @stack = @test_stack;
  end;
go
if exists
   (select *
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'divide_using_decimal', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'math__test'
    , @level1type = N'procedure'
    , @level1name = N'divide_using_decimal'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'execute_as'
  , @value      = N'declare @stack [xml]; execute [math__test].[divide_using_decimal] @stack=@stack output; select @stack;'
  , @level0type = N'schema'
  , @level0name = N'math__test'
  , @level1type = N'procedure'
  , @level1name = N'divide_using_decimal'
  , @level2type = null
  , @level2name =null;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
--
--
-- does this method meet the test requirements?
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
create function [math].[divide] (
  @numerator     [decimal](10, 6)
  , @denominator [int])
returns [decimal](10, 6)
as
  begin
      declare @return [decimal](10, 6);
      if @numerator is null
          or @denominator is null
          or @denominator = 0
        set @return = 0;
      else
        set @return = round(cast (@numerator as [float]) / cast(@denominator as [float]), 6);
      return @return;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @stack [xml];
execute [math__test].[divide_using_decimal]
  @stack=@stack output;
select @stack;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- does it still meet the original requirements?
-------------------------------------------------
declare @stack [xml];
execute [math__test].[divide]
  @stack=@stack output;
select @stack;
go
-------------------------------------------------
-- code block end
--