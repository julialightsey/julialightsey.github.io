use [utility]

GO

if schema_id(N'utility__secure') is null
  execute (N'create schema utility__secure');

go

if object_id(N'[utility__secure].[metadata]', N'U') is not null
  drop table [utility__secure].[metadata];

GO

create table [utility__secure].[metadata]
  (
     [key]           [nvarchar](450) not null
     , [value]       [nvarchar](max) null
     , [created]     [datetime] null
     , [created_by]  [sysname] not null
     , [description] [nvarchar](max) null,
     constraint [utility__secure_metadata__key__pk] primary key clustered ( [key] asc )with (PAD_INDEX = off, STATISTICS_NORECOMPUTE = off, IGNORE_DUP_KEY = off, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
  )
on [PRIMARY]
TEXTIMAGE_ON [PRIMARY]

GO

alter table [utility__secure].[metadata]
  add constraint [utility__secure__metadata__created__df] default (getdate()) for [created]

GO

alter table [utility__secure].[metadata]
  add constraint [utility__secure__metadata__created_by__df] default (user_name()) for [created_by]

GO 

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'[key] [nvarchar](450) not null - The primary key for the table.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'COLUMN'
  , @level2name=N'key'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'[value] [nvarchar](max) null - The value in the key/value pair which is to be retrieved.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'COLUMN'
  , @level2name=N'value'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'[description] [nvarchar](max) null - A description of the key/value pair and what its expected or intended use is.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'COLUMN'
  , @level2name=N'description'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'[created] [datetime] constraint [utility__secure__metadata__created__df] default (current_timestamp) - The timestamp that the value of [entry] was created. DELETE is disallowed on the table.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'COLUMN'
  , @level2name=N'created'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N' constraint [utility__secure__metadata__created__df] default (current_timestamp)  - The default value for the column [created_by].'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'CONSTRAINT'
  , @level2name=N'utility__secure__metadata__created__df'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'[created_by] [sysname] constraint [utility__secure__metadata__created_by__df] default (current_user) - The user that was metadataged in when the value of [entry] was created.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'COLUMN'
  , @level2name=N'created_by'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N' constraint [utility__secure__metadata__created_by__df] default (current_timestamp)  - The default value for the column [created].'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'CONSTRAINT'
  , @level2name=N'utility__secure__metadata__created_by__df'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'constraint [utility__secure_metadata__key__pk] primary key clustered ([key]) - The primary key constraint on the table.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'
  , @level2type=N'CONSTRAINT'
  , @level2name=N'utility__secure_metadata__key__pk'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'A table in which ad hoc information is metadataged for all applications in the database.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility__secure'
  , @level1type=N'TABLE'
  , @level1name=N'metadata'

GO 
