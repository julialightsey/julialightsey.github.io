use [chamomile];

go

if object_id(N'[documentation].[get_formatted_html]'
             , N'FN') is not null
  drop function [documentation].[get_formatted_html];

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
            , @object [sysname] = N'get_formatted_html';
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
create function [documentation].[get_formatted_html] (@object [xml])
returns [xml]
as
  begin
      declare @head          [xml] = [utility].[get_prototype](N'[chamomile].[documentation].[html].[head].[template]'),
              @footer        [xml] = [utility].[get_prototype](N'[chamomile].[documentation].[html].[footer].[template]'),
              @documentation [xml] = N'<html><head /><body /></html>';

      set @documentation.modify(N'insert sql:variable("@head") as first into (/html/head)[1]');
      set @documentation.modify(N'insert sql:variable("@object") as last into (/html/body)[1]');
      set @documentation.modify(N'insert sql:variable("@footer") as last into (/html/body)[1]');

      return @documentation;
  end;

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'inserts data passed in as xml (or valid html) into an html head and footer.',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html';

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html';

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'select [documentation].[get_formatted_html] (N''[chamomile].[job].[get_change]'');
	select [documentation].[get_formatted_html]([utility].[get_log](''[utility].[set_meta_data]''));',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html';

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html';

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](N''[chamomile].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html';

if exists (select *
           from   ::fn_listextendedproperty(N'classification'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'classification',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html';

exec sys.sp_addextendedproperty
  @name =N'classification',
  @value =N'low',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html';

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140723'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140723',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html';

exec sys.sp_addextendedproperty
  @name =N'revision_20140723',
  @value =N'Katherine E. Lightsey',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html';

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_documentation'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_documentation',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html';

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_documentation',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html';

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.93.00'
                                            , N'SCHEMA'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.93.00',
    @level0type=N'SCHEMA',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html';

exec sys.sp_addextendedproperty
  @name =N'release_00.93.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'documentation'
                                            , N'function'
                                            , N'get_formatted_html'
                                            , N'parameter'
                                            , N'@object'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'documentation',
    @level1type=N'function',
    @level1name=N'get_formatted_html',
    @level2type=N'parameter',
    @level2name=N'@object';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@object xml - the xml (or valid html) object that is to be wrapped in an html head and footer.',
  @level0type=N'schema',
  @level0name=N'documentation',
  @level1type=N'function',
  @level1name=N'get_formatted_html',
  @level2type=N'parameter',
  @level2name=N'@object'; 
