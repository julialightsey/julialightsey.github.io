use [chamomile];

go

if schema_id(N'documentation') is null
  execute(N'create schema documentation');

go

if object_id(N'[documentation].[get_list]'
             , N'TF') is not null
  drop function [documentation].[get_list];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'documentation'
            , @object [sysname] = N'get_list';
    select [schemas].[name]                as [schema]
           , [objects].[name]              as [object]
           , [extended_properties].[name]  as [property]
           , [extended_properties].[value] as [value]
    from   [sys].[extended_properties] as [extended_properties]
           join [sys].[objects] as [objects]
             on [objects].[object_id] = [extended_properties].[major_id]
           join [sys].[schemas] as [schemas]
             on [objects].[schema_id] = [schemas].[schema_id]
    where  [schemas].[name] = @schema
           and [objects].[name] = @object;

	select * from [documentation].[get_list](N'[chamomile].[boolean]');
*/
create function [documentation].[get_list] (@object_fqn [nvarchar](max))
returns @data table (
  [id]    [uniqueidentifier] null,
  [entry] [xml] null,
  [fqn]   [nvarchar](max),
  [data]  [nvarchar](max) null )
as
  begin
      insert into @data
                  ([id],
                   [entry],
                   [fqn],
                   [data])
      select [id]
             , [entry]
             , [fqn]
             , [data].value(N'(/*/value/text())[1]'
                            , N'[nvarchar](max)')
      from   [repository].[get_list] (@object_fqn);

      return;
  end

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'retrieves all documentation objects that match the input parameter @object_fqn based on a "like %@object_fqn%" match.',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list';

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list';

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'todo',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list';

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list';

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](N''[chamomile].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list';

if exists (select *
           from   ::fn_listextendedproperty(N'classification'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'classification',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list';

exec sys.sp_addextendedproperty
  @name =N'classification',
  @value =N'low',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list';

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140723'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140723',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list';

exec sys.sp_addextendedproperty
  @name =N'revision_20140723',
  @value =N'Katherine E. Lightsey',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list';

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_documentation'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_documentation',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list';

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_documentation',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list';

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.93.00'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.93.00',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list';

exec sys.sp_addextendedproperty
  @name =N'release_00.93.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_list'
                                            , N'parameter'
                                            , N'@object_fqn'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_list',
    @level2type=N'parameter',
    @level2name=N'@object_fqn';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@object_fqn [nvarchar](max) - the fully qualified name of the object(s) to retrieve based on a "like %@object_fqn%" match, in "[category].[class].[type]" format.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_list',
  @level2type=N'parameter',
  @level2name=N'@object_fqn'; 
