use [master];

go

if object_id(N'[dbo].[sp_chamomile_documentation_get_server_information]'
             , N'P') is not null
  drop procedure [dbo].[sp_chamomile_documentation_get_server_information];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'dbo'
            , @object [sysname] = N'sp_chamomile_documentation_get_server_information';
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
*/
create procedure [dbo].[sp_chamomile_documentation_get_server_information] @procedure_id [int]
                                                                           , @stack      xml output
as
  begin
      declare @builder            [xml],
              @stack_builder      [xml],
              @timestamp          [sysname] = convert([sysname], current_timestamp, 126),
              @stripped_timestamp [sysname] = [chamomile].[utility].[strip_string](convert(sysname, current_timestamp, 126)
                                                     , N'a-z0-9'
                                                     , null
                                                     , null);

      set @stack_builder = (select [0]    as N'@major_version'
                                   , [1]  as N'@minor_version'
                                   , [2]  as N'@milli_version'
                                   , [3]  as N'@product_version'
                                   , [4]  as N'@product_level'
                                   , [5]  as N'@edition'
                                   , [6]  as N'@netbios'
                                   , [7]  as N'@machine'
                                   , [8]  as N'@instance'
                                   , [9]  as N'@database'
                                   , [10] as N'@schema'
                                   , [11] as N'@procedure'
                            from   (select [node]
                                           , [index]
                                    from   [chamomile].[utility].[split_string] (isnull(lower(cast(serverproperty('productversion') as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(serverproperty ('productlevel') as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(serverproperty ('edition') as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(serverproperty(N'ComputerNamePhysicalNetBIOS') as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(serverproperty(N'MachineName') as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(serverproperty(N'InstanceName') as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(db_name() as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(object_schema_name(@procedure_id) as [sysname])), N'default')
                                                                                 + N'.'
                                                                                 + isnull(lower(cast(object_name(@procedure_id) as [sysname])), N'default')
                                                                                 , N'.', null, null)) as [source_table]
                                   pivot (max([node])
                                         for [index] in ([0],
                                                         [1],
                                                         [2],
                                                         [3],
                                                         [4],
                                                         [5],
                                                         [6],
                                                         [7],
                                                         [8],
                                                         [9],
                                                         [10],
                                                         [11])) as [pivot_table]
                            for xml path(N'complete'), root(N'server_information'));
      set @builder = N'<fqn fqn="['
                     + @stack_builder.value(N'(/*/*/@netbios)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@machine)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@instance)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@database)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@schema)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@procedure)[1]', N'[sysname]')
                     + N']" />';
      set @stack_builder.modify(N'insert sql:variable("@builder") as last into (/*)[1]');
      set @builder = N'<fqn_prefix fqn="['
                     + @stack_builder.value(N'(/*/*/@netbios)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@machine)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@instance)[1]', N'[sysname]')
                     + N'].['
                     + @stack_builder.value(N'(/*/*/@database)[1]', N'[sysname]')
                     + N']" />';
      set @stack_builder.modify(N'insert sql:variable("@builder") as last into (/*)[1]');
      set @builder = N'<server name="'
                     + lower(cast(serverproperty(N'ServerName') as [nvarchar](1000)))
                     + N'" />';
      set @stack_builder.modify(N'insert sql:variable("@builder") as last into (/*)[1]');
      set @builder = N'<normalized_server name="'
                     + lower(lower(cast(serverproperty(N'MachineName') as [nvarchar](1000))) + N'_' + lower(cast(serverproperty(N'InstanceName') as [nvarchar](1000))))
                     + N'" />';
      set @stack_builder.modify(N'insert sql:variable("@builder") as last into (/*)[1]');
      set @stack_builder.modify(N'insert attribute timestamp {sql:variable("@timestamp")} as last into (/*)[1]');
      set @stack_builder.modify(N'insert attribute stripped_timestamp {sql:variable("@stripped_timestamp")} as last into (/*)[1]');
      set @stack = @stack_builder;
  end;

go

exec [sp_ms_marksystemobject]
  N'sp_chamomile_documentation_get_server_information';

go

if exists (select *
           from   ::fn_listextendedproperty(N'todo'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_chamomile_documentation_get_server_information'
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'todo',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_chamomile_documentation_get_server_information',
    @level2type=null,
    @level2name=null;

go

exec sys.sp_addextendedproperty
  @name =N'todo',
  @value =N'<ol><li>Use [chamomile].[xsc].</li></ol>',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_chamomile_documentation_get_server_information';

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_chamomile_documentation_get_server_information'
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_chamomile_documentation_get_server_information',
    @level2type=null,
    @level2name=null;

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](null, N''[chamomile].[documentation].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_chamomile_documentation_get_server_information';

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_chamomile_documentation_get_server_information'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_chamomile_documentation_get_server_information'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'Returns sql version information for ease of access. http://sqlserverbuilds.blogspot.com/',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_chamomile_documentation_get_server_information'

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_chamomile_documentation_get_server_information'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_chamomile_documentation_get_server_information'

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'
  declare @builder       [xml]
        , @subject_fqn [nvarchar](1000)
        , @server_name [nvarchar](1000);

execute [sp_chamomile_documentation_get_server_information]
  @procedure_id=@@procid
  , @stack     =@builder output;

set @subject_fqn=@builder.value(N''(/*/fqn/@name)[1]''
                                , N''[nvarchar](1000)'');
set @server_name=@builder.value(N''(/*/server/@name)[1]''
                                , N''[nvarchar](1000)'');

select @builder
       , @subject_fqn
       , @server_name; ',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_chamomile_documentation_get_server_information'

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140706'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_chamomile_documentation_get_server_information'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140706',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_chamomile_documentation_get_server_information'

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140706',
  @value =N'Katherine E. Lightsey - created.',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_chamomile_documentation_get_server_information'

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_basic'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_chamomile_documentation_get_server_information'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_basic',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_chamomile_documentation_get_server_information'

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_basic',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_chamomile_documentation_get_server_information'

go

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.92.00'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_chamomile_documentation_get_server_information'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.92.00',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_chamomile_documentation_get_server_information'

go

exec sys.sp_addextendedproperty
  @name =N'release_00.92.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_chamomile_documentation_get_server_information'

go 
