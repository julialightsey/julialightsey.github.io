if schema_id(N'address_secure') is null
  execute(N'create schema address_secure');

go

if object_id(N'[address_secure].[data]'
             , N'U') is not null
  drop table [address_secure].[data];

go

create table [address_secure].[data]
  (
     [id]            [int] identity(1, 1) not null
     , [address_01]  [nvarchar](max) not null
     , [address_02]  [nvarchar](max)
     , [city]        [nvarchar](max) not null
     , [postal_code] [nvarchar](128) not null
  );

go

alter table [address_secure].[data]
  add
  --
  constraint [address_secure.data.id.clustered_primary_key] primary key clustered ([id]),
  --
  constraint [address_secure.data.state.references] foreign key([state]) references [address_secure].[state] ([id]),
  --
  constraint [claim.adjustment.postal_code] check ([postal_code] like '[0-9][0-9][0-9][0-9][0-9]' or [postal_code] like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');

go 
