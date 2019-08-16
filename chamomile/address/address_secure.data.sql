use [address];

go

if schema_id(N'address_secure') is null
  execute (N'create schema address_secure');

go

if exists (select *
           from   [sys].[objects]
           where  [object_id] = object_id(N'[address_secure].[data]')
                  and [type] in ( N'U' ))
  drop table [address_secure].[data];

go

set ansi_nulls on;

go

set quoted_identifier on;

go

create table [address_secure].[data]
  (
     [id]           [int] identity(1, 1) not null
          constraint [address_secure.data.id.primary_key_clustered] primary key clustered ([id])
     , [entry]      xml ([address_secure].[xsc]) not null
     , [active]     [datetime] not null constraint [address_secure.data.active.default] default (current_timestamp)
     , [expire]     [date] null
     , [created_by] [nvarchar](250) not null constraint [address_secure.data.created_by.default] default (host_name())
     , [created]    [datetimeoffset](7) not null constraint [address_secure.data.created.default] default (current_timestamp)
  );

go

grant execute on [address_secure].[data] to kelightsey;

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'address_secure'
                                            , N'TABLE'
                                            , N'address_secure'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name=N'description',
    @level0type=N'SCHEMA',
    @level0name=N'address_secure',
    @level1type=N'TABLE',
    @level1name=N'data',
    @level2type=null,
    @level2name=null

go

if not exists (select *
               from   ::fn_listextendedproperty(N'description'
                                                , N'SCHEMA'
                                                , N'address_secure'
                                                , N'TABLE'
                                                , N'data'
                                                , null
                                                , null))
  exec sys.sp_addextendedproperty
    @name=N'description',
    @value=N'[address_secure].[data] - Primary store for addresses. Addresses are typed using XML Schema Collection [address_secure].[XSC]. See XSC for examples.',
    @level0type=N'SCHEMA',
    @level0name=N'address_secure',
    @level1type=N'TABLE',
    @level1name=N'data',
    @level2type=null,
    @level2name=null

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'address_secure'
                                            , N'TABLE'
                                            , N'address_secure'
                                            , N'COLUMN'
                                            , N'entry'))
  exec sys.sp_dropextendedproperty
    @name=N'description',
    @level0type=N'SCHEMA',
    @level0name=N'address_secure',
    @level1type=N'TABLE',
    @level1name=N'data',
    @level2type=N'COLUMN',
    @level2name=N'entry'

go

if not exists (select *
               from   ::fn_listextendedproperty(N'description'
                                                , N'SCHEMA'
                                                , N'address_secure'
                                                , N'TABLE'
                                                , N'data'
                                                , N'COLUMN'
                                                , N'entry'))
  exec sys.sp_addextendedproperty
    @name=N'description',
    @value=N'[entry] xml ([address_secure].[XSC]) not null - data is typed using XML Schema Collection [address_secure].[XSC]. See XSC for examples.',
    @level0type=N'SCHEMA',
    @level0name=N'address_secure',
    @level1type=N'TABLE',
    @level1name=N'data',
    @level2type=N'COLUMN',
    @level2name=N'entry'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'address_secure'
                                            , N'TABLE'
                                            , N'address_secure'
                                            , N'COLUMN'
                                            , N'id'))
  exec sys.sp_dropextendedproperty
    @name=N'description',
    @level0type=N'SCHEMA',
    @level0name=N'address_secure',
    @level1type=N'TABLE',
    @level1name=N'data',
    @level2type=N'COLUMN',
    @level2name=N'id'

go

if not exists (select *
               from   ::fn_listextendedproperty(N'description'
                                                , N'SCHEMA'
                                                , N'address_secure'
                                                , N'TABLE'
                                                , N'data'
                                                , N'COLUMN'
                                                , N'id'))
  exec sys.sp_addextendedproperty
    @name=N'description',
    @value=N'[id] [int] identity(1, 1) not null - identity column and primary key.',
    @level0type=N'SCHEMA',
    @level0name=N'address_secure',
    @level1type=N'TABLE',
    @level1name=N'data',
    @level2type=N'COLUMN',
    @level2name=N'id'

go 
