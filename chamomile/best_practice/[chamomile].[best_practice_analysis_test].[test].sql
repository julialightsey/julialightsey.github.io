/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'best_practice_analysis'
            , @object [sysname] = N'test';
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
--
-------------------------------------------------
if exists
   (select *
    from   sys.objects
    where  object_id = object_id('[best_practice_analysis_test].[invalid_table_01]')
           and type in ( N'U' ))
  drop table [best_practice_analysis_test].[invalid_table_01];
go
create table [best_practice_analysis_test].[invalid_table_01](
  [flower] [sysname]
  , [color]  [sysname]
  );
go 

--
-------------------------------------------------
if exists
   (select *
    from   sys.objects
    where  object_id = object_id('[best_practice_analysis_test].[valid_table_01]')
           and type in ( N'U' ))
  drop table [best_practice_analysis_test].[valid_table_01];
go
create table [best_practice_analysis_test].[valid_table_01](
  [id]       [int] identity(1, 1) not null,
    constraint [best_practice_analysis_test.valid_table_01.id.clustered_primary_key] primary key ([id])
    , [flower] [sysname],
    constraint [best_practice_analysis_test.valid_table_01.flower.unique] unique ([flower])
  , [color]  [sysname]
  );
go
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', N'column', N'color'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =N'column'
    , @level2name =N'color';
exec sys.sp_addextendedproperty
  @name         =N'description'
  , @value      =N'[color]  [sysname]  '
  , @level0type =N'schema'
  , @level0name =N'best_practice_analysis_test'
  , @level1type =N'table'
  , @level1name =N'valid_table_01'
  , @level2type =N'column'
  , @level2name =N'color';
go
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', N'column', N'flower'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =N'column'
    , @level2name =N'flower';
exec sys.sp_addextendedproperty
  @name         =N'description'
  , @value      =N'[flower] [sysname] '
  , @level0type =N'schema'
  , @level0name =N'best_practice_analysis_test'
  , @level1type =N'table'
  , @level1name =N'valid_table_01'
  , @level2type =N'column'
  , @level2name =N'flower';
go
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', N'column', N'id'))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =N'column'
    , @level2name =N'id';
exec sys.sp_addextendedproperty
  @name         =N'description'
  , @value      =N'[id]       [int] identity(1, 1) not null'
  , @level0type =N'schema'
  , @level0name =N'best_practice_analysis_test'
  , @level1type =N'table'
  , @level1name =N'valid_table_01'
  , @level2type =N'column'
  , @level2name =N'id';
go
if exists
   (select *
    from   fn_listextendedproperty(N'description', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name        =N'description'
  , @value     =N'table used for test'
  , @level0type=N'schema'
  , @level0name=N'best_practice_analysis_test'
  , @level1type=N'table'
  , @level1name=N'valid_table_01'
  , @level2type=null
  , @level2name=null;
go
if exists
   (select *
    from   fn_listextendedproperty(N'license', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'license'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name        =N'license'
  , @value     =N'select [utility].[get_meta_data](null, N'[chamomile].[documentation].[license]');'
  , @level0type=N'schema'
  , @level0name=N'best_practice_analysis_test'
  , @level1type=N'table'
  , @level1name=N'valid_table_01'
  , @level2type=null
  , @level2name=null;
go
if exists
   (select *
    from   fn_listextendedproperty(N'classification', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'classification'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name        =N'classification'
  , @value     =N'oltp'
  , @level0type=N'schema'
  , @level0name=N'best_practice_analysis_test'
  , @level1type=N'table'
  , @level1name=N'valid_table_01'
  , @level2type=null
  , @level2name=null;
go
if exists
   (select *
    from   fn_listextendedproperty(N'package_best_practice_analysis', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'package_best_practice_analysis'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name        =N'package_best_practice_analysis'
  , @value     =N''
  , @level0type=N'schema'
  , @level0name=N'best_practice_analysis_test'
  , @level1type=N'table'
  , @level1name=N'valid_table_01'
  , @level2type=null
  , @level2name=null;
go
if exists
   (select *
    from   fn_listextendedproperty(N'revision_20140723', N'schema', N'best_practice_analysis_test', N'table', N'valid_table_01', default, default))
  exec sys.sp_dropextendedproperty
    @name         = N'revision_20140723'
    , @level0type = N'schema'
    , @level0name = N'best_practice_analysis_test'
    , @level1type = N'table'
    , @level1name = N'valid_table_01'
    , @level2type =null
    , @level2name =null;
exec sys.sp_addextendedproperty
  @name        =N'revision_20140723'
  , @value     =N'Katherine E. Lightsey - created.'
  , @level0type=N'schema'
  , @level0name=N'best_practice_analysis_test'
  , @level1type=N'table'
  , @level1name=N'valid_table_01'
  , @level2type=null
  , @level2name=null;
go 
