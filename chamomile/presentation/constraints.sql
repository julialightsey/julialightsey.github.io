/* 
  All content is licensed as [chamomile] (http://www.KELightsey.com/license.html) and  
    copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
    and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html). 
  --------------------------------------------- 

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
-- 
-- code block begin 
------------------------------------------------- 
use [chamomilesql];

go

if schema_id(N'flower') is null
  execute (N'create schema flower');

go

--
-- DEFAULT constraint in table definition
-------------------------------------------------
if object_id(N'[flower].[standing_order_with_null_expiration]'
             , N'U') is not null
  drop table [flower].[standing_order_with_null_expiration];

go

create table [flower].[standing_order_with_null_expiration]
  (
     [id]         [int] identity(1, 1) not null,
          constraint [flower.sstanding_order_with_null_expiration.id.primary_key_clustered] primary key clustered ([id])
     , [color]    [sysname]
     , [flower]   [sysname]
     , [customer] [sysname]
     , [quantity] [int] not null
     , [created]  [datetime] not null constraint [flower.standing_order_with_null_expiration.created.default] default current_timestamp
     , [updated]  [datetime] null
     , [expired]  [datetime] null
  ); 
