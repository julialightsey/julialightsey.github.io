use [chamomile];

go

if schema_id(N'repository') is null
  execute (N'create schema repository');

go

if object_id(N'[repository].[data]'
             , N'V') is not null
  drop view [repository].[data];

go

set ansi_nulls on;

go

set ansi_padding on;

go

set ansi_warnings on;

go

set concat_null_yields_null on;

go

set numeric_roundabort off;

go

set quoted_identifier on;

go

/*
	select * from [repository].[data];
*/
create view [repository].[data]
with schemabinding
as
  select [id]
         , [source]
         , [category]
         , [class]
         , [type]
         , [entry]
         , [description]
         , [active]
         , [expire]
         , 0 as [immutable]
         , [created]
  from   [repository__secure].[mutable]
  union all
  select [id]
         , [source]
         , [category]
         , [class]
         , [type]
         , [entry]
         , [description]
         , [active]
         , [expire]
         , 1 as [immutable]
         , [created]
  from   [repository__secure].[immutable];

go 
