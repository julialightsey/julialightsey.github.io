/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
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
--
-- code block begin
use [chamomile];

go

if schema_id(N'unbreakable_code') is null
  execute (N'create schema unbreakable_code');

go

-- code block end
-- Command pattern using [xml] 
-- command object 
-- receiver object 
declare @command [xml] = N'<command> 
        <receiver> 
            <parameters>@output [xml] output</parameters> 
            <sql>select @output = (<select statement>  
                for xml path(N''output''), root(N''output_tree''));</sql> 
        </receiver> 
    </command>';

go

-- Setter / Run 
-- invoker object 
create procedure [workflow].[run] @workflow [xml]
                                  , @output [xml] output
as
    declare @sql        [nvarchar](max) = @workflow.value(N'(/command/receiver/sql/text())[1]'
                              , N'[nvarchar](max)'),
            @parameters [nvarchar](max) = @workflow.value(N'(/command/receiver/parameters/text())[1]'
                              , N'[nvarchar](max)');

    if ( @workflow is not null )
      execute sp_execute
        @sql =@sql,
        @parameters=@parameters,
        @output =@output output;

go 
