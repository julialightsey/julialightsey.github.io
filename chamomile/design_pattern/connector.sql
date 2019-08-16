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

if schema_id(N'design_pattern') is null
  execute (N'create schema design_pattern');

go

-- code block end
--------------------------------------------------------------------------
-- cross database referential integrity pattern 
if object_id(N'[design_pattern].[meta_data]'
             , N'U') is not null
  drop table [design_pattern].[meta_data];

go

create table [design_pattern].[meta_data]
  (
     [id]         [int]
     , [value_01] [int]
  );

go

insert into [design_pattern].[meta_data]
            ([id],
             [value_01])
values      ([id],
             [value_01]);

go

create function [design_pattern].[get_meta_data] (@key [int])
returns [int]
as
  begin
      return
        (select [value_01]
         from   [design_pattern].[meta_data]
         where  [id] = @key);
  end;

go

use [application];

go

create function [design_pattern].[get_meta_data] (@key [int])
returns [int]
as
  begin
      return
        (select [design_pattern].[meta_data] (@key));
  end;

go

alter table [design_pattern].[application_table]
  add constraint [fk_meta_data] check ( [design_pattern].[get_meta_data]([meta_data]) is not null);

go

--------------------------------------------------------------------------------------- 
-- cross database referential integrity pattern 
-- connector 
-- replication alternative - identical to the first but the table is replicated to the  
--    application database. This leaves the original pattern in place for all other  
--    objects. Objects in this database will get the new table due to the  
--    function definition.use [application]; 
go

create table [design_pattern].[meta_data]
  (
     [id]         [int]
     , [value_01] [int]
  );

go

--<replicate [chamomile].[design_pattern].[meta_data] to [application].[design_pattern].[meta_data]>
go

create function [design_pattern].[get_meta_data] (@key [int])
returns [int]
as
  begin
      return
        (select [value_01]
         from   [design_pattern].[meta_data]
         where  [id] = @key);
  end;

go

alter table [design_pattern].[application_table]
  add constraint [fk_meta_data] check ( [design_pattern].[get_meta_data]([meta_data]) is not null);

go

--------------------------------------------------------------------------------------- 
-- cross database referential integrity pattern 
-- singleton connectoruse [application]; 
create function [design_pattern].[get_meta_data] (@key [int])
returns [int]
as
  begin
      return 1; -- <todo> - finish this when i have access to a sql server! 
  end;

go 
