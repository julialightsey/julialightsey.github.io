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

if schema_id(N'address') is null
  execute(N'create schema address');

go

-- code block end
if object_id(N'[address].[data]'
             , N'U') is not null
  drop table [address].[data];

go

create table [address].[data]
  (
     [id]                [int] identity(1, 1) not null primary key clustered
     , [street_01]       [nvarchar](250) null
     , [street_02]       [nvarchar](250) null
     , [rural_route]     [nvarchar] (250) null
     , [post_office_box] [nvarchar](250) null
     , [city]            [sysname]
     , [state]           [sysname]
     , [postal_code]     [nvarchar](50) null
  );

go

/* 
  uses one procedure to get addresses by any of the variables passed in.  
  all the cases are not built out... it should be obvious that there would  
  be a cte for each of the parameters and all would be unioned together. 
   
  I do not mind using "select *" in this case as the select is from the cte 
  just preceding the select statement, and part of the overall construct. 
   
  This gets all of the addresses that meet any of the parameters. a technique 
  to get only addresses that meet all of the parameters is shown elsewhere. 
   
  There is only one method for the calling application to be aware of. This 
  is NOT an example of a God object (anti pattern) as the method still does 
  one very clearly defined task; get an address. 
*/
------------------------------------------------- 
if object_id(N'[address].[get]'
             , N'P') is not null
  drop procedure [address].[get];

go

create procedure [address].[get] @id                [int] = null
                                 , @street_01       [nvarchar](250) = null
                                 , @street_02       [nvarchar](250) = null
                                 , @rural_route     [nvarchar] (250) = null
                                 , @post_office_box [nvarchar](250) = null
                                 , @city            [sysname] = null
                                 , @state           [sysname] = null
                                 , @postal_code     [nvarchar](50) = null
as
  begin
      with [get_by_street_01]
           as (select [id]
                      , [street_01]
                      , [street_02]
                      , [rural_route]
                      , [post_office_box]
                      , [city]
                      , [state]
                      , [postal_code]
               from   [address].[data]
               where  [street_01] = @street_01),
           [get_by_street_02]
           as (select [id]
                      , [street_01]
                      , [street_02]
                      , [rural_route]
                      , [post_office_box]
                      , [city]
                      , [state]
                      , [postal_code]
               from   [address].[data]
               where  [street_02] = @street_02),
           [get_by_city]
           as (select [id]
                      , [street_01]
                      , [street_02]
                      , [rural_route]
                      , [post_office_box]
                      , [city]
                      , [state]
                      , [postal_code]
               from   [address].[data]
               where  [city] = @city),
           [union_all]
           as (select *
               from   [get_by_street_01]
               union
               select *
               from   [get_by_street_02]
               union
               select *
               from   [get_by_city])
      select [id]
             , [street_01]
             , [street_02]
             , [rural_route]
             , [post_office_box]
             , [city]
             , [state]
             , [postal_code]
      from   [union_all];
  end;

go

/* 
  uses one procedure for each parameter. There will need to be a total 
  of eight separate procedures for the interface to call. The 
  developer programming the interface must determine which procedure  
  to call, forcing complexity into the calling application. Additionally, 
  how does the calling application get addresses that match multiple 
  parameters, by building even more methods such as  
  "get_by_street_01_and_street_02", etc. Reductio ad absurdum. I have 
  seen designs such as this result in fifteen to twenty separate methods 
  simply to get an address. 
*/
------------------------------------------------- 
if object_id(N'[address].[get_by_id]'
             , N'P') is not null
  drop procedure [address].[get_by_id];

go

create procedure [address].[get_by_id] @id [int] = null
as
  begin
      select [id]
             , [street_01]
             , [street_02]
             , [rural_route]
             , [post_office_box]
             , [city]
             , [state]
             , [postal_code]
      from   [address].[data]
      where  [id] = @id;
  end;

create procedure [address].[get_by_street_01] @id [int] = null
as
  begin
      select [id]
             , [street_01]
             , [street_02]
             , [rural_route]
             , [post_office_box]
             , [city]
             , [state]
             , [postal_code]
      from   [address].[data]
      where  [street_01] = @street_01;
  end;

go 
