use [utility];

go

drop view [utility].[backup__level];

go

create view [utility].[backup__level]
as
  select [log].[id]                                                        as [id]
         , [t].[c].value(N'(/*/@database)[1]', N'[sysname]')               as [database]
         , [t].[c].value(N'(/*/@database__backup__file)[1]', N'[sysname]') as [database__backup__file]
         , [t].[c].value(N'(/*/@timestamp)[1]', N'[datetime]')             as [timestamp]
         , [log].[created]                                                 as [created]
  from   [utility].[utility].[log] as [log]
         cross apply [entry].nodes(N'/*') as [t]([c])
  where  CAST([t].[c].[query]('fn:local-name(.)') as [sysname]) = N'restore__db'; 
