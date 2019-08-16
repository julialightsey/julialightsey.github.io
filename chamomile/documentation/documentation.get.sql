use [chamomile];

go

if object_id(N'[documentation].[get]'
             , N'FN') is not null
  drop function [documentation].[get];

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
            , @object [sysname] = N'get';
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
create function [documentation].[get] (@object_fqn [nvarchar](max))
returns [xml]
as
  begin
      declare @builder       [xml],
              @stale         [sysname],
              @timestamp     [sysname] = convert([sysname], current_timestamp, 126),
              @documentation [xml];
      declare @data table
        (
           [id]      [uniqueidentifier] null
           , [entry] [xml] null
           , [fqn]   [nvarchar](max)
           , [data]  [xml] null
        );

      insert into @data
                  ([id],
                   [entry],
                   [fqn],
                   [data])
      select [id]
             , [entry]
             , [fqn]
             , [data]
      from   [repository].[get] (null
                                 , @object_fqn);

      --
      ----------------------------------------------
      select @stale = isnull((select [entry].value(N'(/*/object/documentation_stack/@stale)[1]'
                                                   , N'[sysname]')
                              from   @data)
                             , N'false')
             , @timestamp = isnull((select [entry].value(N'(/*/object/documentation_stack/@timestamp)[1]'
                                                         , N'[sysname]')
                                    from   @data)
                                   , @timestamp);

      set @documentation = N'<details><summary>' + @object_fqn
                           + N'</summary>
						   <p class="footer">timestamp {'
                           + @timestamp + N'} stale {' + @stale
                           + N'}</p></details>'
      --
      ----------------------------------------------
      set @builder = (select t.c.value(N'(@sequence)[1]'
                                       , N'[int]') as N'@sequence'
                             , case
                                 when cast(t.c.query(N'local-name(.)[1]="text"') as [sysname]) = N'true' then N'<p>'
                                                                                                              + t.c.value(N'(./text())[1]', N'[nvarchar](max)')
                                                                                                              + N'</p>'
                                 when cast(t.c.query(N'local-name(.)[1]="html"') as [sysname]) = N'true' then t.c.query(N'(./*)[1]')
                                 when cast(t.c.query(N'local-name(.)[1]="data"') as [sysname]) = N'true' then t.c.query(N'(./*)[1]')
                                 else null
                               end
                      from   @data
                             cross apply [entry].nodes(N'/*/object/documentation_stack/*[local-name()!="description"]') as t(c)
                      order  by t.c.value(N'(@sequence)[1]'
                                          , N'[int]')
                      for xml path(N'sequence'), root(N'documentation'));
      --
      ----------------------------------------------
      set @documentation.modify(N'insert sql:variable("@builder") as last into (/*)[1]');
      set @documentation.modify(N'insert attribute stale {sql:variable("@stale")} as last into (/*)[1]');
      set @documentation.modify(N'insert attribute timestamp {sql:variable("@timestamp")} as last into (/*)[1]');

      --
      ---------------------------------------------
      return @documentation;
  end;

go

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'retrieves an object formatted as documentation from the [chamomile] repository.',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get';

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](N''[chamomile].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get';

go

if exists (select *
           from   ::fn_listextendedproperty(N'classification'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'classification',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'classification',
  @value =N'low',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get';

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140723'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140723',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140723',
  @value =N'Katherine E. Lightsey',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get';

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_documentation'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_documentation',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_documentation',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get';

go

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.93.00'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.93.00',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'release_00.93.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get';

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'declare @stack xml;
    execute [chamomile].[documentation].[set]
      @object_fqn      =N''[chamomile].[documentation].[get].[test_01]''
      , @builder =N''test modified documentation for [chamomile].[documentation].[get].[test_01].''
      , @type          =N''text''
      , @stack         =@stack output;
    select @stack, [documentation].[get] (N''[chamomile].[documentation].[get].[test_01]''); ',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get'

go

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get';

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'todo',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get'

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'function'
                                            , N'get'
                                            , N'parameter'
                                            , N'@object_fqn'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get',
    @level2type=N'parameter',
    @level2name=N'@object_fqn';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@object_fqn [nvarchar] (max) - the fully qualified name of the documentation object to retrieve from the repository in "[category].[class].[type]" format.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get',
  @level2type=N'parameter',
  @level2name=N'@object_fqn'; 
