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

if exists
   (select *
    from   sys.objects
    where  object_schema_name(object_id) = N'meta_data'
           and name = N'data'
           and type = N'V')
  drop view [meta_data].[data];

go

create view [meta_data].[data]
with schemabinding
as
  select [id]                                                                                              as [id]
         , [entry]                                                                                         as [entry]
         , [utility].[strip]([entry].value(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
 							data(/chamomile:stack/object/@name)[1]', '[nvarchar](max)'), N'a-zA-Z0-9._-', null, null) as [stripped]
         , [entry].value(N'declare namespace chamomile="http://www.katherinelightsey.com/"; 
 							data(/chamomile:stack/object/@object_type)[1]', '[nvarchar](max)')                        as [object_type]
         , parsename([entry].[value](N'data(/*/object/@name)[1]', N'[sysname]'), 3)                        as [category]
         , parsename([entry].[value](N'data(/*/object/@name)[1]', N'[sysname]'), 2)                        as [class]
         , parsename([entry].[value](N'data(/*/object/@name)[1]', N'[sysname]'), 1)                        as [type]
         , [entry].[value](N'data(/*/object/@name)[1]', N'[sysname]')                                      as [name]
         , [entry].[value](N'data(/*/object/@value)[1]', N'[sysname]')                                     as [value]
         , [entry].[value](N'data(/*/object/@constraint)[1]', N'[sysname]')                                as [constraint]
         , [entry].query(N'(/*/object)')                                                                   as [notes]
  from   [repository_secure].[data]
  where  [entry].[value](N'data(/*/object/@object_type)[1]', N'[sysname]') = N'meta_data';

go

create unique clustered index [meta_data.data.category.class.type.unique_clustered_index]
  on [meta_data].[data] ([name]);

go 
