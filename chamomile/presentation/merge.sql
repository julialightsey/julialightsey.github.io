/*
	All content is licensed as [chamomile] (http://www.ChamomileSQL.com/source/license.html) and  
	copyright Katherine Elizabeth Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), all rights reserved, 
	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------

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
*/
use [chamomile];

go

set nocount on;

go

if schema_id(N'presentation') is null
  execute (N'create schema presentation');

go

if object_id(N'tempdb..##merge_target'
             , N'U') is not null
  drop table ##merge_target;

go

create table [##merge_target]
  (
     [flower]  [nvarchar](25) not null unique
     , [color] [nvarchar](25) null
  );

go

insert into [##merge_target]
            ([flower],
             [color])
values      (N'rose',
             N'red'),
            (N'petunia',
             N'yellow'),
            (N'marigold',
             N'gold'),
            (N'bluebonnet',
             N'blue');

go

if object_id(N'[presentation].[merge]'
             , N'P') is not null
  drop procedure [presentation].[merge];

go

create procedure [presentation].[merge] @flower   [nvarchar](25)
                                        , @color  [nvarchar](25) = null
                                        , @delete [bit] = 0
                                        , @output [xml] = null output
as
  begin
      set nocount on;

      declare @timestamp   [datetime] = current_timestamp,
              @subject_fqn [nvarchar](1000);
      declare @output_list as table
        (
           [action]            [sysname] null
           , [flower_source]   [sysname] null
           , [color_source]    [sysname] null
           , [flower_inserted] [sysname] null
           , [color_inserted]  [sysname] null
           , [flower_deleted]  [sysname] null
           , [color_deleted]   [sysname] null
        );

      --
      --------------------------------------------------------------------------
      set @subject_fqn = N'['
                         + convert([sysname], serverproperty(N'MachineName'))
                         + '].['
                         + convert([sysname], serverproperty(N'ComputerNamePhysicalNetBIOS'))
                         + '].['
                         + isnull(convert([sysname], serverproperty(N'InstanceName')), N'default')
                         + N'].[' + db_name() + N'].['
                         + object_schema_name(@@procid) + N'].['
                         + object_name(@@procid) + N']';

      if @delete = 1
        delete from [##merge_target]
        output N'delete'
               , @flower
               , @color
               , null
               , null
               , deleted.[flower]
               , deleted.[color]
        into @output_list ([action], [flower_source], [color_source], [flower_inserted], [color_inserted], [flower_deleted], [color_deleted])
        where  [flower] = @flower;
      else
        merge into [##merge_target] as target
        using (values(@flower,
              @color)) as source ([flower], [color])
        on target.[flower] = source.[flower]
        when matched then
          update set target.[color] = source.[color]
        when not matched by target then
          insert ([flower],
                  [color])
          values ([flower],
                  [color])
        output lower($action)
               , source.[flower]
               , source.[color]
               , inserted.[flower]
               , inserted.[color]
               , deleted.[flower]
               , deleted.[color]
        into @output_list ([action], [flower_source], [color_source], [flower_inserted], [color_inserted], [flower_deleted], [color_deleted]);

      set @output = (select isnull([action]
                                   , N'')   as N'@action'
                            , isnull([flower_inserted]
                                     , N'') as N'inserted/@flower'
                            , isnull([color_inserted]
                                     , N'') as N'inserted/@color'
                            , isnull([flower_deleted]
                                     , N'') as N'deleted/@flower'
                            , isnull([color_deleted]
                                     , N'') as N'deleted/@color'
                            , isnull([flower_source]
                                     , N'') as N'source/@flower'
                            , isnull([color_source]
                                     , N'') as N'source/@color'
                     from   @output_list
                     for xml path(N'action'), root(N'result'));
      set @output.modify(N'insert attribute name {sql:variable("@subject_fqn")} as first into (/*)[1]');
      set @output.modify(N'insert attribute result_type {("output")} as last into (/*)[1]');
      set @output.modify(N'insert attribute timestamp {sql:variable("@timestamp")} as last into (/*)[1]');
  end

go

declare @output [xml];

execute [presentation].[merge]
  @flower = N'sunflower',
  @color = N'gold',
  @output = @output output;

select @output as [@output];

go

declare @output [xml];

execute [presentation].[merge]
  @flower = N'petunia',
  @color = N'yellow_update',
  @output = @output output;

select @output as [@output];

go

declare @output [xml];

execute [presentation].[merge]
  @flower = N'marigold',
  @color = N'gold_update',
  @output = @output output;

select @output as [@output];

go

declare @output [xml];

execute [presentation].[merge]
  @flower = N'petunia',
  @output = @output output,
  @delete = 1;

select @output as [@output];

go

if object_id(N'[presentation].[merge]'
             , N'P') is not null
  drop procedure [presentation].[merge];

go

if object_id(N'tempdb..##merge_target'
             , N'U') is not null
  drop table ##merge_target;

go 
