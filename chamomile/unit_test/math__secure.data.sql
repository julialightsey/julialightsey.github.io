--
use [chamomile];

go

if schema_id(N'math__secure') is null
  execute (N'create schema math__secure');

go

--
if object_id(N'[math__secure].[data]', N'U') is not null
  drop table [math__secure].[data];

go

--
create table [math__secure].[data] (
  [id]            [int] identity(1, 1)
  , [numerator]   [int]
  , [denominator] [int]
  , [result]      [decimal](10, 6)
  , [timestamp]   [datetime] default (current_timestamp)
  );

go
