use [chamomile];

go

if schema_id(N'repository__secure') is null
  execute (N'create schema repository__secure');

go

if object_id(N'[repository__secure].[mutable]'
             , N'U') is not null
  drop table [repository__secure].[mutable];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------		
	declare @schema [sysname] = N'repository__secure', @object [sysname] = N'mutable';
	--  
	select N'[' +object_schema_name([extended_properties].[major_id]) +N'].['+
		   case when Object_name([objects].[parent_object_id]) is not null 
				then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
				else Object_name([objects].[object_id]) +N']' + coalesce(N'.['+[columns].[name] + N']', N'')
			end                                                                as [object]
		   ,case when [extended_properties].[minor_id]=0 
					then [objects].[type_desc]
				 when [extended_properties].[class] = 7
					then N'INDEX'
				 else N'COLUMN'
			end                                                                as [type]
		   ,[extended_properties].[name]                                       as [property]
		   ,[extended_properties].[value]                                      as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   left join [sys].[columns] as [columns]
				  on [extended_properties].[major_id]=[columns].[object_id] and
					 [columns].[column_id]=[extended_properties].[minor_id]
	where   coalesce(Object_schema_name([objects].[parent_object_id]), Object_schema_name([extended_properties].[major_id]))=@schema and
			coalesce(Object_name([objects].[parent_object_id]), Object_name([extended_properties].[major_id]))=@object
	order  by [type],[columns].[name],[object],[property]; 
*/
create table [repository__secure].[mutable]
  (
     [id]            [uniqueidentifier] not null constraint [repository__secure.mutable.id.default] default (newsequentialid()),
          constraint [repository__secure.mutable.id.primary_key_clustered] primary key clustered ([id])
     , [source]      [sysname] not null constraint [repository__secure.mutable.source.check] check ([source] in (N'metadata', N'report', N'log'))
     , [category]    [sysname]
     , [class]       [sysname]
     , [type]        [sysname]
     , [entry]       [xml] not null
     , [description] [nvarchar](max) null
     , [active]      [datetime] not null constraint [repository__secure.mutable.active.default] default current_timestamp
     , [expire]      [datetime] null
     , [created]     [datetime] not null constraint [repository__secure.mutable.created.default] default current_timestamp
  );

go

--
------------------------------------------------- 
------------------------------------------------- 
if indexproperty (object_id('[repository__secure].[mutable]')
                  , 'repository__secure.mutable.category.class.type.index'
                  , 'IndexID') is not null
  drop index [repository__secure.mutable.category.class.type.index] on [repository__secure].[mutable];

go

create nonclustered index [repository__secure.mutable.category.class.type.index]
  on [repository__secure].[mutable]([category], [class], [type]);

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'index'
                                          , N'repository__secure.mutable.category.class.type.index'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'index',
    @level2name = N'repository__secure.mutable.category.class.type.index';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'create nonclustered index [repository__secure.mutable.category.class.type.index] 
  on [repository__secure].[mutable]([category], [class], [type]);',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'index',
  @level2name = N'repository__secure.mutable.category.class.type.index';

go

--
------------------------------------------------- 
------------------------------------------------- 
if indexproperty (object_id('[repository__secure].[mutable]')
                  , 'repository__secure.mutable.entry.index'
                  , 'IndexID') is not null
  drop index [repository__secure.mutable.entry.index] on [repository__secure].[mutable];

go

create primary xml index [repository__secure.mutable.entry.index]
  on [repository__secure].[mutable] ([entry]);

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'index'
                                          , N'repository__secure.mutable.entry.index'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'index',
    @level2name = N'repository__secure.mutable.entry.index';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'create primary xml index [repository__secure.mutable.entry.index] on [repository__secure].[mutable] ([entry]);',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'index',
  @level2name = N'repository__secure.mutable.entry.index';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'The [repository__secure].[mutable] repository contains objects which must meet the business rules as defined in the 
	"business_rules" extended properties documentation. A [uniqueidentifier] is defined as the primary
	key to allow the repository to be used for other objects such as [report] and [metadata] which may also need
	to occasionally store mutable data.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'business_rules'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'business_rules',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable';

go

exec sys.sp_addextendedproperty
  @name = N'business_rules',
  @value = N'<h4>Business Rules</h4>
<ol>
	<li><b>Purpose</b>. Data must be accepted and returned for any application within the enterprise 
		which can access SQL objects with minimum complexity. The implementation must be both specific 
		enough to be used for logging and to meet the business rules as well as generic enough to 
		allow logging by any application.</li>
	<li><b>mutable</b>. Data stored is an 
		<a href="https://en.wikipedia.org/wiki/mutable_object" target="blank">mutable object</a>. 
		Once an entry is logged, it must not be modified so that an audit trail is maintained for 
		regulatory compliance as well as for systems analysis and internal reporting.</li>
	<li><b>Extensibility</b>. The object must be able to be extended to support additional or future 
	functionality without breaking existing applications which access the object.</li>
	<li><b>Robustness</b>. The object must be implemented with sufficient robustness that business 
	data is neither lost nor corrupted.</li>
</ol>',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_log'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_log',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable';

go

exec sys.sp_addextendedproperty
  @name = N'package_log',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20140804'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140804',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20140804',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'release_00.93.00'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'release_00.93.00',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable';

go

exec sys.sp_addextendedproperty
  @name = N'release_00.93.00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'column'
                                          , N'category'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'column',
    @level2name = N'category'

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Primary descriptor in [category].[class].[type] unique constraint.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'column',
  @level2name = N'category';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'column'
                                          , N'class'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'column',
    @level2name = N'class';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Secondary descriptor in [category].[class].[type] unique constraint.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'column',
  @level2name = N'class';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'column'
                                          , N'description'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'column',
    @level2name = N'description';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'A description for the log stored.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'column',
  @level2name = N'description';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'column'
                                          , N'id'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'column',
    @level2name = N'id';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Primary key clustered and identity column.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'column',
  @level2name = N'id';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'column'
                                          , N'entry'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'column',
    @level2name = N'entry';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'May contain [xml] data.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'column',
  @level2name = N'entry';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'repository__secure'
                                          , N'table'
                                          , N'mutable'
                                          , N'column'
                                          , N'type'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'repository__secure',
    @level1type = N'table',
    @level1name = N'mutable',
    @level2type = N'column',
    @level2name = N'type';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Tertiary descriptor in [category].[class].[type] unique constraint.',
  @level0type = N'schema',
  @level0name = N'repository__secure',
  @level1type = N'table',
  @level1name = N'mutable',
  @level2type = N'column',
  @level2name = N'type';

go 
