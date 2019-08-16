use [chamomile];

go

--
-------------------------------------------------
select *
from   [repository_secure].[data];

select [entry]
       , *
from   [repository_secure].[data]
where  [id] = N'26EC35D1-6740-E511-B748-005056887C73'

--
-------------------------------------------------
execute [report].[set]
  @category=N'category',
  @class=N'class',
  @type=N'type',
  @value=N'value',
  @description=N'description';

execute [report].[set]
  @category=N'category',
  @class=N'class',
  @type=N'type',
  @value=N'new report',
  @description=N'description';

--
select [report].[get_entry] (N'0C256440-9B40-E511-82A4-4CBB5808949B' -- @id [uniqueidentifier]
                             , null -- @category  [sysname]
                             , null -- @class     [sysname]
                             , null -- @type      [sysname]
                             , null -- @timestamp [datetime]
       );

--
select [report].[get_value] (N'0C256440-9B40-E511-82A4-4CBB5808949B' -- @id [uniqueidentifier]
                             , null -- @category  [sysname]
                             , null -- @class     [sysname]
                             , null -- @type      [sysname]
                             , null -- @timestamp [datetime]
       );

--
select *
from   [report].[get_list] (N'category'
                            , N'class'
                            , null
                            , null);

--
-------------------------------------------------
execute [metadata].[set]
  @category=N'category',
  @class=N'class',
  @type=N'type',
  @value=N'value',
  @description=N'description';

execute [metadata].[set]
  @category=N'category',
  @class=N'class',
  @type=N'type',
  @value=N'value2',
  @description=N'description';

--
select [metadata].[get_entry] (N'E9F7D25A-9B40-E511-82A4-4CBB5808949B' -- @id [uniqueidentifier]
                               , null -- @category  [sysname]
                               , null -- @class     [sysname]
                               , null -- @type      [sysname]
                               , null -- @timestamp [datetime]
       );

--
select [metadata].[get_value] (N'E9F7D25A-9B40-E511-82A4-4CBB5808949B' -- @id [uniqueidentifier]
                               , null -- @category  [sysname]
                               , null -- @class     [sysname]
                               , null -- @type      [sysname]
                               , null -- @timestamp [datetime]
       );

--
select *
from   [metadata].[get_list] (N'category'
                              , N'class'
                              , null
                              , null);

--
-------------------------------------------------
truncate table [repository_secure].[immutable];

delete from [repository_secure].[immutable];

execute [log].[set]
  @source=N'log',
  @category=N'category',
  @class=N'class',
  @type=N'type',
  @value=N'value',
  @description=N'description';

execute [log].[set]
  @source=N'log',
  @category=N'category',
  @class=N'class',
  @type=N'type',
  @value=N'value2',
  @description=N'description';

--
select [log].[get_entry] (N'26EC35D1-6740-E511-B748-005056887C73' -- @id [uniqueidentifier]
                          , null -- @category  [sysname]
                          , null -- @class     [sysname]
                          , null -- @type      [sysname]
                          , null -- @timestamp [datetime]
       );

--
select [log].[get_value] (N'CBA2AB6C-6940-E511-B748-005056887C73' -- @id [uniqueidentifier]
                          , null -- @category  [sysname]
                          , null -- @class     [sysname]
                          , null -- @type      [sysname]
                          , null -- @timestamp [datetime]
       );

--
select [log].[get_value] (null -- @id [uniqueidentifier]
                          , N'category' -- @category  [sysname]
                          , N'class' -- @class     [sysname]
                          , N'type' -- @type      [sysname]
                          , null -- @timestamp [datetime]
       );

--
select *
from   [log].[get_list] (N'category'
                         , N'class'
                         , null
                         , null); 
