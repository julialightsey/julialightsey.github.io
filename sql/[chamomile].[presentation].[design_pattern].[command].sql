use [chamomile];

go
/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		http://en.wikipedia.org/wiki/design_pattern_pattern - In object-oriented programming, the design_pattern pattern is a behavioral design pattern  
		in which an object is used to represent and encapsulate all the information needed to call a method at a later time. This  
		information includes the method name, the object that owns the method and values for the method parameters. Using design_pattern objects  
		makes it easier to construct general components that need to delegate, sequence or execute method calls at a time of their choosing  
		without the need to know the class of the method or the method parameters.  

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
	-- references
	---------------------------------------------
	Command pattern - http://en.wikipedia.org/wiki/Command_pattern
*/
-- code block begin
use [chamomile];

go

set nocount on;

-- code block end
/* 
  [design_pattern].[receiver] 
  A design_pattern object has a receiver object and invokes a method of the receiver in a way that is specific  
  to that receiver's class. The receiver executes the design_pattern and builds the output for consumption by  
  the client object. 

  Implementing the design_pattern pattern in SQL - sp_executesql is used to execute the sql design_pattern contained  
  in the [xml] design_pattern object, using the parameter list also contained in the design_pattern object. The output  
  of the design_pattern is returned to the invoker in the [xml] output parameter. 


  <chamomile:command xmlns:chamomile="http://www.katherinelightsey.com/">
  <chamomile:receiver frequency="1" timestamp="2014-06-19T14:20:29.953">
    <parameters>@output [xml] output</parameters>
    <sql>


*/
-- code block begin
if schema_id(N'command') is null
  execute (N'create schema command');

go

if schema_id(N'workflow') is null
  execute (N'create schema workflow');

go

if object_id(N'[command].[receiver]'
             , N'P') is not null
  drop procedure [command].[receiver];

go

create procedure [command].[receiver]
  @stack    xml([utility].[stack_xsc])
  , @output [xml] output
as
    declare @sql          [nvarchar](max)
            , @parameters [nvarchar](max)
            , @builder    [xml];

    set @builder=@stack;
    set @sql = @builder.value(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
		(/chamomile:command/receiver/sql/text())[1]'
                              , N'[nvarchar](max)');
    set @parameters=@builder.value(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
		(/chamomile:command/receiver/parameters/text())[1]'
                                   , N'[nvarchar](max)');

    execute sp_executesql
      @sql         = @sql
      , @parameters= @parameters
      , @output    = @output output;

go

-- code block end
/* 
  [design_pattern].[invoker] 
  A design_pattern object is separately passed to an invoker object, which invokes the design_pattern, and optionally  
  does bookkeeping about the design_pattern execution. Any design_pattern object can be passed to the same invoker  
  object. Using an invoker object allows bookkeeping about design_pattern executions to be conveniently  
  performed, as well as implementing different modes for design_patterns, which are managed by the invoker  
  object, without the need for the client to be aware of the existence of bookkeeping or modes.  
   
  Implementing the design_pattern pattern in SQL - The invoker contains the logic and/or mechanism by which  
  design_patterns are chosen. For example; the invoker may be the procedure which pulls messages off a queue.  
  Alternately, it could accept a parameter such as the [id] of the [design_pattern] object to extract from a  
  table. In this example the design_pattern object is simply pulled out of a table. In an actual implementation  
  the mechanism would obviously be more complex. 

  
	execute [design_pattern].[invoker] @object_fqn=@object, @object_type=N'command';

	<chamomile:workflow xmlns:chamomile="http://www.katherinelightsey.com/">
	  <command name="chamomile.administration.query_performance" />
	  <command name="chamomile.administration.index_fragmentation" />
	</chamomile:workflow>
*/
-- code block begin
if object_id(N'[command].[invoker]'
             , N'P') is not null
  drop procedure [command].[invoker];

go

create procedure [command].[invoker]
  @name     [nvarchar](1000)
  , @output [xml] output
as
  begin
      declare @stack     xml([utility].[stack_xsc])
              , @builder [xml];

      set @stack = (select [utility].[get_object](@name
                                                  , N'command'));

      execute [command].[receiver]
        @stack    =@stack
        , @output =@output output;
  end;

go

-- code block end
/* 
  create design_pattern objects and load [design_pattern].[repository] 
  In this case, the only design_patterns entered into the repository are one to determine the worst performing  
  queries on a system and one to determine index fragmentation. These could be run programmatically,  
  perhaps on a daily basis and the results stored in a metadata table. The results could then be analyzed  
  to determine if a specific query is performing worse over time and if a specific index is fragmenting  
  more over time. 
*/
-- 
--  design_pattern object 
-------------------------------------------------
-- code block begin 
declare @stack         xml
        , @frequency   [int] = 1
        , @sql         [nvarchar](max)
        , @parameters  [nvarchar](max)
        , @subject_fqn [nvarchar](max) = N'['
          + convert([sysname], serverproperty(N'MachineName'))
          + '].['
          + convert([sysname], serverproperty(N'ComputerNamePhysicalNetBIOS'))
          + '].['
          + isnull(convert([sysname], serverproperty(N'InstanceName')), N'default')
          + N'].[chamomile].[design_pattern].[command]'
        , @object_fqn  [nvarchar](max)
        , @object_type [sysname]
        , @command     xml
        , @workflow    xml;

--
--------------------------------------------------------------------------
set @workflow = [utility].[get_object] (N'[chamomile].[workflow].[stack]'
                                        , N'prototype');
set @object_fqn = N'[chamomile].[design_pattern_command].[demonstration]';
set @object_type = N'workflow';
set @workflow.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/subject/@name)[1] with sql:variable("@subject_fqn")');
set @workflow.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/@name)[1] with sql:variable("@object_fqn")');
set @workflow.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/@object_type)[1] with sql:variable("@object_type")');
--
--------------------------------------------------------------------------
set @parameters = N'@output [xml] output';
set @sql = 'set @output=( 
select top (20) current_timestamp                                                                              as N''@timestamp'' 
                , [dm_exec_query_stats].[execution_count]                                                          as N''@execution_count'' 
                , substring([dm_exec_sql_text].[text], [dm_exec_query_stats].statement_start_offset / 2 + 1, (  
case 
                        when [dm_exec_query_stats].[statement_end_offset] = -1 then 
                        len(convert(nvarchar(max), [dm_exec_sql_text].[text])) * 2 
                        else 
                        [dm_exec_query_stats].[statement_end_offset] 
                    end - [dm_exec_query_stats].[statement_start_offset] ) / 2)	    as N''@query_text'' 
                , db_name([dm_exec_sql_text].[dbid])                                                               as N''@repository_base'' 
                , [dm_exec_query_stats].[total_worker_time]                                                        as N''@total_cpu_time'' 
                , [dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count]              as N''@average_cpu_time'' 
                , [dm_exec_query_stats].[total_physical_reads]                                                     as N''@total_physical_reads'' 
                , [dm_exec_query_stats].[total_physical_reads] / [dm_exec_query_stats].[execution_count]           as N''@average_physical_reads'' 
                , [dm_exec_query_stats].[total_logical_reads]                                                      as N''@total_logical_reads'' 
                , [dm_exec_query_stats].[total_logical_reads] / [dm_exec_query_stats].[execution_count]            as N''@average_logical_reads'' 
                , [dm_exec_query_stats].[total_logical_writes]                                                     as N''@total_logical_writes'' 
                , [dm_exec_query_stats].[total_logical_writes] / [dm_exec_query_stats].[execution_count]           as N''@average_logical_writes'' 
                , [dm_exec_query_stats].[total_elapsed_time]                                                       as N''@total_duration'' 
                , [dm_exec_query_stats].[total_elapsed_time] / [dm_exec_query_stats].[execution_count]             as N''@average_duration'' 
                , [dm_exec_query_plan].[query_plan]                                                                as N''plan'' 
  from [sys].[dm_exec_query_stats] as [dm_exec_query_stats] 
       cross apply [sys].[dm_exec_sql_text]([dm_exec_query_stats].[sql_handle]) as [dm_exec_sql_text] 
       cross apply [sys].[dm_exec_query_plan]([dm_exec_query_stats].plan_handle) as [dm_exec_query_plan] 
 where [dm_exec_query_stats].[execution_count] > 50 
        or [dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count] > 100 
        or [dm_exec_query_stats].[total_physical_reads] / [dm_exec_query_stats].[execution_count] > 1000 
        or [dm_exec_query_stats].[total_logical_reads] / [dm_exec_query_stats].[execution_count] > 1000 
        or [dm_exec_query_stats].[total_logical_writes] / [dm_exec_query_stats].[execution_count] > 1000 
        or [dm_exec_query_stats].[total_elapsed_time] / [dm_exec_query_stats].[execution_count] > 1000 
 order by [dm_exec_query_stats].[execution_count] desc 
          , [dm_exec_query_stats].[total_elapsed_time] / [dm_exec_query_stats].[execution_count] desc 
          , [dm_exec_query_stats].[total_worker_time] / [dm_exec_query_stats].[execution_count] desc 
          , [dm_exec_query_stats].[total_physical_reads] / [dm_exec_query_stats].[execution_count] desc 
          , [dm_exec_query_stats].[total_logical_reads] / [dm_exec_query_stats].[execution_count] desc 
          , [dm_exec_query_stats].[total_logical_writes] / [dm_exec_query_stats].[execution_count] desc  
for xml path(N''query''), root(N''query_performance''))';
--
--------------------------------------------------------------------------
set @stack = [utility].[get_object](N'[chamomile].[command].[stack]'
                                    , N'prototype');
set @object_fqn = N'[chamomile].[administration].[query_performance]';
set @object_type = N'command';
--
--------------------------------------------------------------------------
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	insert text {sql:variable("@parameters")} as last into (/chamomile:stack/object/chamomile:command/receiver/parameters)[1]');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	insert text {sql:variable("@sql")} as last into (/chamomile:stack/object/chamomile:command/receiver/sql)[1]');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/chamomile:command/receiver/@frequency)[1] with sql:variable("@frequency")');
--
--------------------------------------------------------------------------
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/subject/@name)[1] with sql:variable("@subject_fqn")');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/@name)[1] with sql:variable("@object_fqn")');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/@object_type)[1] with sql:variable("@object_type")');
--
--------------------------------------------------------------------------
set @command = N'<command name="' + @object_fqn + '" />';
set @workflow.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/";  insert sql:variable("@command") as last into (/chamomile:stack/object/chamomile:workflow)[1]');

--
--
--------------------------------------------------------------------------
execute [utility].[set_stack]
  @stack=@stack;

--------------------------------------------------------------------------
set @sql = 'set @output=( 
select [schemas].[name]                                              as N''@schema'' 
       , [tables].[name]                                             as N''@table'' 
       , [columns].[name]                                            as N''@column'' 
       , [indexes].[name]                                            as N''@index'' 
       , [dm_db_index_physical_stats].[index_type_desc]              as N''@index_type'' 
       , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as N''@average_fragmentation_percent'' 
  from [sys].[dm_db_index_physical_stats](db_id(), null, null, null, null) [dm_db_index_physical_stats] 
       inner join [sys].[indexes] [indexes] 
               on [indexes].[object_id] = [dm_db_index_physical_stats].[object_id] 
                  and [indexes].[index_id] = [dm_db_index_physical_stats].[index_id] 
       inner join [sys].[tables] as [tables] 
               on [tables].[object_id] = [indexes].[object_id] 
       inner join [sys].[schemas] as [schemas] 
               on [schemas].[schema_id] = [tables].[schema_id] 
       inner join [sys].[index_columns] as [index_columns] 
               on [index_columns].[index_id] = [indexes].[index_id] 
                  and [index_columns].[object_id] = [tables].[object_id] 
       inner join [sys].[columns] as [columns] 
               on [columns].[column_id] = [index_columns].[column_id] 
                  and [columns].[object_id] = [tables].[object_id] 
 --where [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > 30 
 order by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc  
for xml path(N''query''), root(N''index_fragmentation''))';
--
--------------------------------------------------------------------------
set @stack = [utility].[get_object](N'[chamomile].[command].[stack]'
                                    , N'prototype');
set @object_fqn = N'[chamomile].[administration].[index_fragmentation]';
set @object_type = N'command';
--
--------------------------------------------------------------------------
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	insert text {sql:variable("@parameters")} as last into (/chamomile:stack/object/chamomile:command/receiver/parameters)[1]');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	insert text {sql:variable("@sql")} as last into (/chamomile:stack/object/chamomile:command/receiver/sql)[1]');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/chamomile:command/receiver/@frequency)[1] with sql:variable("@frequency")');
--
--------------------------------------------------------------------------
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/subject/@name)[1] with sql:variable("@subject_fqn")');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/@name)[1] with sql:variable("@object_fqn")');
set @stack.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
	replace value of (/chamomile:stack/object/@object_type)[1] with sql:variable("@object_type")');
--
--------------------------------------------------------------------------
set @command = N'<command name="' + @object_fqn + '" />';
set @workflow.modify(N'declare namespace chamomile="http://www.katherinelightsey.com/";  insert sql:variable("@command") as last into (/chamomile:stack/object/chamomile:workflow)[1]');

--
--------------------------------------------------------------------------
execute [utility].[set_stack]
  @stack=@stack;

--
--------------------------------------------------------------------------
execute [utility].[set_stack]
  @stack=@workflow;

-- code block end
/* 
  [design_pattern].[client] 
  The client contains the decision making about which design_patterns to execute at which points. To execute  
  a design_pattern, it passes the design_pattern object to the invoker object. Both an invoker object and several  
  design_pattern objects are held by a client object. 

  The client might be invoked by a sql server agent job and then iterate through all the administrative  
  design_patterns. Alternately, it might be activiated by Service Broker internal activation. In this example,  
  the client uses a cursor to iterate through the design_pattern objects in [design_pattern].[repository]. The  
  frequency is stated in seconds. If elapsed time is greater than frequency, the design_pattern object is run  
  again. In this case, the frequency is set to one second to facilitate demonstration. In practice, one  
  might expect to see frequencies of up to thirty days. For a table that is being loaded multiple times  
  during the day, a frequency of perhaps thirty minutes might be used to check the indexes for fragmentation.  

  What is not shown here is the output of results into a log table. 
	declare @output [xml];
	execute [workflow].[client] @object_fqn=N'chamomile.administration.design_pattern_command_demonstration', @object_type=N'workflow', @output=@output output;


	select [utility].[get_object](N'chamomile.administration.index_fragmentation',N'command');
*/
-- code block begin
if object_id(N'[workflow].[client]'
             , N'P') is not null
  drop procedure [workflow].[client];

go

create procedure [workflow].[client]
  @name     [nvarchar](1000)
  , @output [xml] = null output
as
  begin
      declare @repeat          [bit] = 0
              , @command_fqn   [nvarchar](max)
              , @object        [sysname]
              , @builder       [xml]
              , @client_output [xml]
              , @subject_fqn   [nvarchar](1000);
      declare @object_list table (
        [object] [xml]
        );

      set @subject_fqn = N'['
                         + convert([sysname], serverproperty(N'MachineName'))
                         + '].['
                         + convert([sysname], serverproperty(N'ComputerNamePhysicalNetBIOS'))
                         + '].['
                         + isnull(convert([sysname], serverproperty(N'InstanceName')), N'default')
                         + N'].[' + db_name() + N'].['
                         + object_schema_name(@@procid) + N'].['
                         + object_name(@@procid) + N']'
      set @output = [utility].[get_object](N'[chamomile].[utility].[result_stack]'
                                           , N'prototype');
      set @output.modify(N'replace value of (/*/subject/@name)[1] with sql:variable("@subject_fqn")');
      set @output.modify(N'replace value of (/*/object/@name)[1] with sql:variable("@name")');
      set @builder = (select [utility].[get_object](@name
                                                    , N'workflow'));

      insert into @object_list
                  ([object])
        select t.c.query(N'.') as [command]
        from   @builder.nodes(N'declare namespace chamomile="http://www.katherinelightsey.com/";
				chamomile:workflow/*') as t(c);

      declare [get_command] cursor for
        select [object].value(N'(/command/@name)[1]'
                              , N'[sysname]')
        from   @object_list;

      open [get_command];

      fetch [get_command] into @object;

      while @@fetch_status = 0
        begin
            execute [command].[invoker]
              @name     =@object
              , @output =@client_output output;

            set @client_output.modify(N'insert attribute name {sql:variable("@object")} as first into (/*)[1]');
            set @output.modify(N'insert sql:variable("@client_output") as last into (/*/result)[1]');

            fetch [get_command] into @object;
        end

      close [get_command];

      deallocate [get_command];
  end

go

-- code block end
--
--------------------------------------------------------------------------
-- code block begin
declare @output [xml];

execute [workflow].[client]
  @name     =N'[chamomile].[design_pattern_command].[demonstration]'
  , @output = @output output;

select @output;

-- code block end
go 
