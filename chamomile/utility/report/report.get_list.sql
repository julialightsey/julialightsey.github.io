use [chamomile];

go

if schema_id(N'report') is null
  execute (N'create schema report');

go

if object_id(N'[report].[get_list]'
             , N'TF') is not null
  drop function [report].[get_list];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'report', @object [sysname] = N'get_list';

	--
	-------------------------------------------------
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
		   case when Object_name([objects].[parent_object_id]) is not null 
				then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
				else Object_name([objects].[object_id]) +N']' + 
					case when [parameters].[parameter_id] > 0
						then coalesce(N'.['+[parameters].[name] + N']', N'') 
						else N'' 
					end 
			end                                                                     as [object]
		   ,case when [extended_properties].[minor_id]=0 then [objects].[type_desc]
				else N'PARAMETER'
			end                                                                     as [type]
		   ,[extended_properties].[name]                                            as [property]
		   ,[extended_properties].[value]                                           as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and
		   [objects].[name]=@object
	order  by [parameters].[name],[object],[type],[property]; 
*/
create function [report].[get_list] (@category    [sysname]
                                     , @class     [sysname]
                                     , @type      [sysname]
                                     , @timestamp [datetime])
returns @list table (
  [id]          [uniqueidentifier],
  [category]    [sysname],
  [class]       [sysname],
  [type]        [sysname],
  [value]       [sysname],
  [description] [nvarchar](max),
  [entry]       [xml],
  [created]     [datetime])
as
  begin
      insert into @list
                  ([id],
                   [category],
                   [class],
                   [type],
                   [value],
                   [description],
                   [entry],
                   [created])
      select [id]
             , [category]
             , [class]
             , [type]
             , [value]
             , [description]
             , [entry]
             , [created]
      from   [repository_secure].[get_list] (N'report'
                                             , @category
                                             , @class
                                             , @type
                                             , @timestamp);

      return;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Returns a table of all columns in the [log_secure].[data] table for a match on [category].[class].[type] and [created] if @timestamp is not null.',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150727'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150727',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list';

exec sys.sp_addextendedproperty
  @name = N'revision_20150727',
  @value = N'KELightsey@gmail.com – create.',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_log'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_log',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list';

exec sys.sp_addextendedproperty
  @name = N'package_log',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'version_00_01_00'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'version_00_01_00',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list';

exec sys.sp_addextendedproperty
  @name = N'version_00_01_00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list';

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
		select * from [report].[get_list] (N''clinicScorecard'', N''patientExperience'', N''cfsParticipation'');',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , N'column'
                                          , N'@category'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list',
    @level2type = N'column',
    @level2name = N'@category';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Matches to the [category] column.',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list',
  @level2type = N'parameter',
  @level2name = N'@category';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , N'column'
                                          , N'@class'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list',
    @level2type = N'column',
    @level2name = N'@class';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Matches to the [class] column.',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list',
  @level2type = N'parameter',
  @level2name = N'@class';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'report'
                                          , N'function'
                                          , N'get_list'
                                          , N'column'
                                          , N'@type'))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'report',
    @level1type = N'function',
    @level1name = N'get_list',
    @level2type = N'column',
    @level2name = N'@type';

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Matches to the [type] column.',
  @level0type = N'schema',
  @level0name = N'report',
  @level1type = N'function',
  @level1name = N'get_list',
  @level2type = N'parameter',
  @level2name = N'@type';

go 
