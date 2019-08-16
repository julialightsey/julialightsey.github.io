/* 
  All content is licensed as [chamomile] (http://www.KELightsey.com/license.html) and  
    copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
    and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html). 
  --------------------------------------------- 

  -- 
  --  description 
  --------------------------------------------- 
  Is it faster to use null for a column such as [expired] or to use a fictitous date
	such as '21001231'?
  
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
use [ChamomileSQL];
go
if schema_id(N'flower') is null
	execute (N'create schema flower');
go
--
-- using null for [expired]
-------------------------------------------------
if object_id(N'[flower].[standing_order_with_null_expiration]', N'U') is not null
drop table [flower].[standing_order_with_null_expiration];
go
create table [flower].[standing_order_with_null_expiration]
  ([id]       [int] identity(1, 1) not null,
      constraint [flower.sstanding_order_with_null_expiration.id.primary_key_clustered] primary key clustered ([id]),
   [color]    [sysname],
   [flower]   [sysname],
   [customer] [sysname],
   [quantity] [int] not null,
   [created]  [datetime] not null constraint [flower.standing_order_with_null_expiration.created.default] default current_timestamp,
   [updated]  [datetime] null,
   [expired]  [datetime] null
  ); 
--
-- using fictitious date for [expired]
-------------------------------------------------
if object_id(N'[flower].[standing_order_with_fictitious_expiration]', N'U') is not null
drop table [flower].[standing_order_with_fictitious_expiration];
go
create table [flower].[standing_order_with_fictitious_expiration]
  ([id]       [int] identity(1, 1) not null,
      constraint [flower.sstanding_order_with_fictitious_expiration.id.primary_key_clustered] primary key clustered ([id]),
   [color]    [sysname],
   [flower]   [sysname],
   [customer] [sysname],
   [quantity] [int] not null,
   [created]  [datetime] not null constraint [flower.standing_order_with_fictitious_expiration.created.default] default current_timestamp,
   [updated]  [datetime] null,
   [expired]  [datetime] not null  constraint [flower.standing_order_with_fictitious_expiration.expired.default] default N'21001231'
  ); 
--
-- todo: insert large quantities of generated records into both, index and search
--	timing each.
-------------------------------------------------