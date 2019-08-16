use [chamomile]

GO

if object_id(N'[work__secure].[log]', N'U') is not null
  drop table [work__secure].[log];

go

create table [work__secure].[log](
  [id]            [int] identity(1, 1) not null
  , [client]      [sysname] not null
  , [start]       [datetime] not null
  , [end]         [datetime] null
  , [description] [nvarchar](max) null
  , [entry]       [xml] not null,
  constraint [work__secure__log__id__pk] primary key clustered ( [id] asc )
  );

GO

alter table [work__secure].[log]
  add constraint [work__secure__log__start__df] default (getdate()) for [start]

GO

alter table [work__secure].[log]
  add constraint [work__secure__log__entry__df] default (N'<entry_list />') for [entry]

GO 
