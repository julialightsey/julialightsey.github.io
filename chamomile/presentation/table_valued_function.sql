/* 
	--
	---------------------------------------------
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
  -- 
  --  description 
  --------------------------------------------- 
  
  -- 
  --  notes 
  --------------------------------------------- 
    this presentation is designed to be run incrementally a code block at a time.  
    code blocks are delineated as: 

    -- 
    -- code block begin 
    ----------------------------------------- 
       
    ----------------------------------------- 
    -- code block end 
    -- 
   
  -- 
  -- references 
  --------------------------------------------- 
*/
use [chamomilesql];

go

--
-------------------------------------------------
if schema_id(N'kate_test') is null
  execute (N'create schema kate_test');

go

--
-------------------------------------------------
if object_id(N'[kate_test].[table_valued_function]'
             , N'TF') is not null
  drop function [kate_test].[table_valued_function];

go

create function [kate_test].[table_valued_function](@object [sysname])
returns @objectlist table (
  [name]        [sysname],
  [type_desc]   [sysname],
  [object_id]   [int],
  [create_date] [datetime])
as
  begin
      insert into @objectlist
                  ([name],
                   [type_desc],
                   [object_id],
                   [create_date])
      select [name]
             , [type_desc]
             , [object_id]
             , [create_date]
      from   sys.objects
      where  [name] = @object;

      return;
  end;

go

if object_id(N'[kate_test].[sample_01]'
             , N'U') is not null
  drop table [kate_test].[sample_01];

go

create table [kate_test].[sample_01]
  (
     [id]      [int] identity(1, 1) not null
     , [color] [sysname]
  );

go

--
-------------------------------------------------
select [name]
       , [type_desc]
       , [object_id]
       , [create_date]
from   [kate_test].[table_valued_function] (N'sample_01');

go 
