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

if object_id(N'[utility].[fruit]'
             , N'U') is not null
  drop table [utility].[fruit];

go

create table [utility].[fruit]
  (
     [fruit]        [sysname] primary key clustered
     , [color]      [sysname]
     , [persistent] [sysname] default( N'false')
  );

insert into [utility].[fruit]
            ([fruit],
             [color])
values      (N'apple',
             N'red'),
            (N'banana',
             N'yellow'),
            (N'orange',
             N'orange');

insert into [utility].[fruit]
            ([fruit],
             [color],
             [persistent])
values      (N'pear',
             N'green',
             N'true');

select *
from   [utility].[fruit];

go

declare @fruit      [sysname] = N'pear',
        @color      [sysname] = N'orange',
        @persistent [sysname];

with [non_persistent]
     as (select [fruit]        as [fruit]
                , [color]      as [color]
                , [persistent] as [persistent]
         from   [utility].[fruit])
merge into [non_persistent] as target
using (values (@fruit,
      @color,
      N'false')) as source ([fruit], [color], [persistent])
on target.[fruit] = source.[fruit]
-- only match for an update when target.[persistent]=N'false'
when matched and target.[persistent]=N'false' then
  update set target.[color] = source.[color]
-- does not update as it was matched based on primary key
when not matched by target then
  insert ([fruit],
          [color])
  values (source.[fruit],
          source.[color])
output $action
       , inserted.*
       , deleted.*;

select *
from   [utility].[fruit];

go 
