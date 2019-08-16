/*
	--
	---------------------------------------------
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	--
	---------------------------------------------

	Clarke's Three Laws are three "laws" of prediction formulated by the British writer Arthur C. Clarke.
		1. When a distinguished but elderly scientist states that something is possible, she is almost 
			certainly right. When she states that something is impossible, she is very probably wrong.
		2. The only way of discovering the limits of the possible is to venture a little way past them 
			into the impossible.
		3. Any sufficiently advanced technology is indistinguishable from magic.

	That you do not understand a technology is not an indictment of the technology, but rather is only
		an indication of your ignorance of the technology.

	Ignorance is the absence of knowledge. Stupidity is the insistence on remaining ignorant.

	Scientist (http://en.wikipedia.org/wiki/Scientist):
		A scientist, in a broad sense, is one engaging in a systematic activity to acquire knowledge. 
			In a more restricted sense, a scientist may refer to an individual who uses the scientific 
			method. The person may be an expert in one or more areas of science.

	Scientific Method (http://en.wikipedia.org/wiki/Scientific_method):
		The Oxford English Dictionary defines the scientific method as "a method or procedure... consisting 
		in systematic observation, measurement, and experiment, and the formulation, testing, and modification 
		of hypotheses.

	--
	--	description
	---------------------------------------------
		this presentation demonstrates a technique for unit testing sql code.

	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--

	--
	--	questions are interspersed within the code and comments blocks. you should attempt to understand both
	--		what the answer is and why the question is being asked.
	---------------------------------------------
	
	--
	-- references
	---------------------------------------------
*/
--
-- code block begin
-------------------------------------------------
--
-- do you trust SQL?
-- before you begin unit testing with SQL, you should understand
--	it well enough to trust it.
-------------------------------------------------
use [chamomile];
go
--
if object_id(N'tempdb..##data', N'U') is not null
  drop table ##data;
go
create table ##data (
  [value] [int]
  );
go
--
insert into ##data
            ([value])
values      (30),
            (20);
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- what will the average be? are you sure? why are you sure?
-------------------------------------------------
select avg([value])
from   ##data;
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- what will the average be? are you sure? why are you sure?
-------------------------------------------------
select avg(cast ([value] as [float]))
from   ##data;
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- what will the average be? are you sure? why are you sure?
-- what values will be in the table afterwards?
-------------------------------------------------
select *
  from ##data;
begin
    begin transaction;
    truncate table ##data;
    insert into ##data
                ([value])
         values (5),
                (2);
    --
    select avg(cast ([value] as [float]))
      from ##data;
    rollback;
end;
select *
  from ##data; 
-----------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- what will happen if we add other columns to the table? will we get a different average for [value]? why or why not?
-------------------------------------------------
alter table ##data add [flower] [sysname];
go
--
select *
  from ##data;
begin
    begin transaction;
    truncate table ##data;
    insert into ##data
                ([value])
         values (5),
                (2);
    --
    select avg(cast ([value] as [float]))
      from ##data;
    rollback;
end;
select *
  from ##data; 
-----------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
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
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
/*
	--
	-- to view documentation
	------------------------------------------------
	select [name]
           , [value]
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'divide', null, null);  

	--
	-- without viewing the actual business method {[math].[divide]}, can you tell what business functionality
	--	[math].[divide] is required to exhibit by only looking at this test?
	-- is this test a clear and consistent definition of what is required in the business method?
	-- what things are NOT required by this test?
	--	are you required to implement large numbers?
	------------------------------------------------
*/
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
create procedure [math__test].[run]
  @stack [xml] output
as
  begin
      declare @test_stack   [xml]
              , @test_suite [xml] = N'<test_suite stack_count="0" test_count="0" error_count="0" pass_count="0" />'
              , @count      [int];
      execute [math__test].[divide]
        @stack=@test_stack output;
      set @test_suite.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');
      --
      execute [math__test].[divide_using_decimal]
        @stack=@test_stack output;
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
if exists
   (select *
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'run', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'math__test'
    , @level1type = N'procedure'
    , @level1name = N'run'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'execute_as'
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
execute [math__test].[run]
  @stack=@stack output;
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
create procedure [math__test].[run]
  @stack [xml] output
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
                execute sp_executesql
                  @sql          =@sql
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
if exists
   (select *
    from   fn_listextendedproperty(N'execute_as', N'schema', N'math__test', N'procedure', N'run', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'math__test'
    , @level1type = N'procedure'
    , @level1name = N'run'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'execute_as'
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
execute [math__test].[run]
  @stack=@stack output;
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

if object_id(N'[test].[run]', N'P') is not null
  drop procedure [test].[run];
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
create procedure [test].[run]
  @stack [xml] output
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
                execute sp_executesql
                  @sql          =@sql
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
if exists
   (select *
    from   fn_listextendedproperty(N'execute_as', N'schema', N'test', N'procedure', N'run', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'test'
    , @level1type = N'procedure'
    , @level1name = N'run'
    , @level2type = null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name         = N'execute_as'
  , @value      = N'declare @stack [xml]; execute [test].[run] @stack=@stack output; select @stack;'
  , @level0type = N'schema'
  , @level0name = N'test'
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
execute [test].[run]
  @stack=@stack output;
select @stack
       , @stack.value(N'(/*/@stack_count)[1]', N'[int]') as [stack_count]
       , @stack.value(N'(/*/@test_count)[1]', N'[int]')  as [test_count]
       , @stack.value(N'(/*/@pass_count)[1]', N'[int]')  as [pass_count]
       , @stack.value(N'(/*/@error_count)[1]', N'[int]') as [error_count];
go 

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- we can create a "lock" trigger to run tests on modification of an object
-- {note that the production implementation of this would check the EventData stack
--	and only run the test for the modified object}
-------------------------------------------------
exec sp_configure 'show advanced options',1;
reconfigure;
exec sp_configure 'disallow results from triggers',0;
reconfigure;
go

if exists
   (select *
    from   sys.triggers
    where  parent_class = 0
           and name = 'lock_test')
  drop trigger [lock_test] on database;
go
create trigger [lock_test]
on database
after alter_function, drop_function, alter_procedure, drop_procedure, alter_table, drop_table
as
  begin
      declare @stack         [xml]
              , @error_count [int];
      if object_id(N'[test].[run]', N'P') is not null
        begin
            execute [test].[run]
              @stack=@stack output;
            set @error_count = @stack.value(N'(/*/@error_count)[1]', N'[int]')
            if @error_count > 0
                or @error_count is null
              rollback;
        end;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- can you drop a method?
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- note that you could NOT drop the method!
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
-- can you alter a method to a failing state?
-------------------------------------------------
alter function [math].[divide] (
  @numerator     [decimal](10, 6)
  , @denominator [int])
returns [decimal](10, 6)
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
--
-- note that you could NOT alter the method such that it causes the test to fail!
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
-- can you alter a method as long as it still works?
-------------------------------------------------
alter function [math].[divide] (
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
--
-- note that you CAN alter the method, as long as the existing tests still run successfully!
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
-- testing for destructive methods
-- how to test methods that mutate data
-------------------------------------------------
-------------------------------------------------
if exists
   (select *
    from   sys.triggers
    where  parent_class = 0
           and name = 'lock_test')
  drop trigger [lock_test] on database;
go
--
if schema_id(N'math_secure') is null
  execute (N'create schema math_secure');
go
--
if object_id(N'[math_secure].[data]', N'U') is not null
  drop table [math_secure].[data];
go
--
create table [math_secure].[data] (
  [id]            [int] identity(1, 1)
  , [numerator]   [int]
  , [denominator] [int]
  , [result]      [decimal](10, 6)
  , [timestamp]   [datetime] default (current_timestamp)
  );
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
if object_id(N'[math].[set]', N'P') is not null
  drop procedure [math].[set];
go
--
create procedure [math].[set]
  @numerator     [int]
  , @denominator [int]
  , @id          [int] output
as
  begin
      --
      -- create a unique transation to avoid issues during parallel operations
      -------------------------------------------
      declare @transaction [nvarchar](32) = right(lower(db_name()) + N'_'
              + lower(object_schema_name(@@procid)) + N'_'
              + lower(object_name(@@procid)) + N'_'
              + cast(round(rand()*100000, -1) as [sysname]), 32);
      --
      -- note that a transaction isn't necessarily required here, but it is shown
      --	to demonstrate the correct method for unit testing a mutator that includes
      --	declared transactions
      begin try
          -- checking @@trancount is optional as this method will ONLY rollback or commit
          --	it's own transaction!
          if @@trancount = 0
            begin transaction @transaction;
          begin
              insert into [math_secure].[data]
                          ([numerator]
                           , [denominator]
                           , [result])
                   values (@numerator
                           , @denominator
                           , [math].[divide] (@numerator, @denominator));
              --
              set @id = scope_identity();
          end;
          --
          -- commit ONLY your own transaction!
          -------------------------------------------
          if exists (select *
                       from [sys].[dm_tran_active_transactions]
                      where [name] = @transaction)
            commit transaction @transaction;
      end try
      begin catch
          --
          -- rollback ONLY your own transaction!
          -------------------------------------------
          if exists (select *
                       from [sys].[dm_tran_active_transactions]
                      where [name] = @transaction)
            rollback transaction @transaction;
      end catch;
  end;
go 


-------------------------------------------------
-- code block end
-- 
--
-- code block begin
-------------------------------------------------
select *
  from [math_secure].[data];
declare @id [int];
execute [math].[set]
  @numerator     = 3
  , @denominator = 2
  , @id          = @id output;
select *
  from [math_secure].[data]; 
select *
  from [math_secure].[data]
  where [id] = @id; 
-------------------------------------------------
-- code block end
-- 
--
-- code block begin
-------------------------------------------------
if object_id(N'[math__test].[set]', N'P') is not null
  drop procedure [math__test].[set];
go
create procedure [math__test].[set]
  @stack [xml] = null output
as
  begin
      declare @tested_object [nvarchar](max) = N'[math_secure].[data]'
              , @id          [int];
      --
      -- create a unique transation to avoid issues during parallel operations
      -------------------------------------------
      declare @transaction [nvarchar](32) = right(lower(db_name()) + N'_'
                      + lower(object_schema_name(@@procid)) + N'_'
                      + lower(object_name(@@procid)) + N'_'
                      + cast(round(rand()*100000, -1) as [sysname]), 32)
              --
              -- capture identity value before test
              -----------------------------------
              , @identity  [int] = ident_current(@tested_object);
      begin transaction @transaction;
      begin
          execute [math].[set]
            @numerator     = 3
            , @denominator = 2
            , @id          = @id output;
          if (select [result]
                from [math_secure].[data]
               where [id] = @id) = 1.5
            select N'pass';
          else
            select N'fail';
      end;
      --
      -- rollback ONLY your own transaction!
      -------------------------------------------
      if exists (select *
                   from [sys].[dm_tran_active_transactions]
                  where [name] = @transaction)
        rollback transaction @transaction;
      --
      -- reset identity value after test
      -------------------------------------------
      --
      -- note that dbcc will not accept a parameter for the object
      -------------------------------------------
      dbcc checkident (N'[math_secure].[data]', reseed, @identity);
  end;
go 

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- note that no persistent records are added due to the test nor is the identity column changed
-------------------------------------------------
select *
from   [math_secure].[data];
execute [math__test].[set];
select *
from   [math_secure].[data];
-------------------------------------------------
-- code block end
--
