/* 
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
    -- todo
    -- alter constraint with NO CHECK and CHECK
*/
-- 
-- code block begin 
-------------------------------------------------
if schema_id(N'flower') is null
  execute (N'create schema flower');

go

if object_id(N'[flower].[order]'
             , N'U') is not null
  drop table [flower].[order];

go

create table [flower].[order]
  (
     [id]         [int] identity(1, 1) not null
          constraint [presentation.create_table.id.primary_key_clustered] primary key clustered ([id])
     , [flower]   [sysname] constraint [presentation.create_table.flower.check] check ([flower] in (N'rose', N'tulip', N'lily'))
     , [color]    [nvarchar](20)
     , [delivery] [datetime] not null
  );

go

-------------------------------------------------
-- code block end 
-- 
-- 
-- code block begin 
-------------------------------------------------
--
-- add a default constraint to the table
-------------------------------------------------
alter table [flower].[order]
  add [quantity] [int] not null constraint [flower.order.quantity.default] default (12);

go

--
-- alter a column on the table
-------------------------------------------------
alter table [flower].[order]
  alter column [color] [sysname];

go

-------------------------------------------------
-- code block end 
-- 
/* 
	display the columns 
		note the use of type_name([user_type_id]) rather than 
		type_name([system_type_id]). For type [sysname] the
		[system_type_id] is 231, the same as [nvarchar]. This makes
		sense as [sysname] is a synonym for [nvarchar](128) not null.
		The [user_type_id] for [sysname] is 256 where [nvarchar] is 
		still 231.
*/
-------------------------------------------------
select [name]                      as [name]
       , type_name([user_type_id]) as [type]
from   [sys].[columns]
where  object_schema_name([object_id]) = N'flower'
       and object_name([object_id]) = N'order'
order  by [name];

-------------------------------------------------
-- code block end 
-- 
-- 
-- code block begin 
-------------------------------------------------
alter table [flower].[order]
  add constraint [presentation.create_table.color.check] check ([color] in (N'red', N'blue', N'white'));

-------------------------------------------------
-- code block end 
-- 
-- 
-- code block begin 
-------------------------------------------------
--
-- display constraints
-------------------------------------------------
select N'['
       + object_schema_name([columns].[object_id])
       + N'].[' + object_name([columns].[object_id])
       + N']'                       as [object]
       , [columns].[name]           as [column]
       , [constraints].[name]       as [constraint]
       , N'[default_constraint]'    as [type]
       , [constraints].[definition] as [definition]
from   [sys].[default_constraints] as [constraints]
       join [sys].[columns] as [columns]
         on [columns].[object_id] = [constraints].[parent_object_id]
            and [columns].[column_id] = [constraints].[parent_column_id]
union
select N'['
       + object_schema_name([columns].[object_id])
       + N'].[' + object_name([columns].[object_id])
       + N']'                       as [object]
       , [columns].[name]           as [column]
       , [constraints].[name]       as [constraint]
       , N'[check_constraints]'     as [type]
       , [constraints].[definition] as [definition]
from   [sys].[check_constraints] as [constraints]
       join [sys].[columns] as [columns]
         on [columns].[object_id] = [constraints].[parent_object_id]
            and [columns].[column_id] = [constraints].[parent_column_id];
-------------------------------------------------
-- code block end 
-- 
