if schema_id(N'administration') is null
  execute (N'create schema administration');

go

if object_id(N'[administration].[get_missing_index_list]'
             , N'P') is not null
  drop procedure [administration].[get_missing_index_list];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'administration',
			@object [sysname] = N'get_missing_index_list';

	--
	-------------------------------------------------
	select [schemas].[name]               as [schema]
		   ,[procedures].[name]           as [procedure]
		   ,[parameters].[name]           as [parameter]
		   ,[extended_properties].[name]  as [property]
		   ,[extended_properties].[value] as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[procedures] as [procedures]
			 on [procedures].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[procedures].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and
		   [procedures].[name]=@object
	order  by [parameter]; 
*/
create procedure [administration].[get_missing_index_list] @database [sysname] = null
                                                           , @output [xml] = null output
as
  begin
      set @output = (select [dm_db_missing_index_details].[statement]                                                               as [object]
                            , [dm_db_missing_index_details].[equality_columns]                                                      as [equality_columns]
                            , [dm_db_missing_index_details].[inequality_columns]                                                    as [inequality_columns]
                            , [dm_db_missing_index_details].[included_columns]                                                      as [included_columns]
                            --
                            , [dm_db_missing_index_columns].[column_name]                                                           as [column_name]
                            , [dm_db_missing_index_columns].[column_usage]                                                          as [column_usage]
                            --
                            , cast([avg_total_user_cost] * [avg_user_impact] * ( [user_seeks] + [user_scans] ) as [decimal](16, 2)) as [cumulative_measure]
                            --
                            , [dm_db_missing_index_group_stats].[avg_system_impact]                                                 as [avg_system_impact]
                            , [dm_db_missing_index_group_stats].[avg_total_system_cost]                                             as [avg_total_system_cost]
                            , cast([dm_db_missing_index_group_stats].[avg_total_user_cost] as [decimal](10, 2))                     as [avg_total_user_cost]
                            , [dm_db_missing_index_group_stats].[avg_user_impact]                                                   as [avg_user_impact]
                            , [dm_db_missing_index_group_stats].[last_system_scan]                                                  as [last_system_scan]
                            , [dm_db_missing_index_group_stats].[last_system_seek]                                                  as [last_system_seek]
                            , [dm_db_missing_index_group_stats].[last_user_scan]                                                    as [last_user_scan]
                            , [dm_db_missing_index_group_stats].[system_scans]                                                      as [system_scans]
                            , [dm_db_missing_index_group_stats].[system_seeks]                                                      as [system_seeks]
                            , [dm_db_missing_index_group_stats].[unique_compiles]                                                   as [unique_compiles]
                            , [dm_db_missing_index_group_stats].[user_scans]                                                        as [user_scans]
                            , [dm_db_missing_index_group_stats].[user_seeks]                                                        as [user_seeks]
                     from   sys.dm_db_missing_index_details as [dm_db_missing_index_details]
                            cross apply sys.dm_db_missing_index_columns ([dm_db_missing_index_details].[index_handle]) as [dm_db_missing_index_columns]
                            inner join sys.dm_db_missing_index_groups as [dm_db_missing_index_groups]
                                    on [dm_db_missing_index_groups].[index_handle] = [dm_db_missing_index_details].[index_handle]
                            inner join sys.dm_db_missing_index_group_stats as [dm_db_missing_index_group_stats]
                                    on [dm_db_missing_index_group_stats].[group_handle] = [dm_db_missing_index_groups].[index_group_handle]
                     where  db_name(database_id) = @database
                             or @database is null
                     order  by [cumulative_measure] desc
                     for xml path(N'missing_index'), root(N'missing_index_list'));
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'todo'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_missing_index_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'todo',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_missing_index_list';

go

exec sys.sp_addextendedproperty
  @name = N'todo',
  @value = N'1) Add documentation to extended properties. 2) Log output.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_missing_index_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_missing_index_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_missing_index_list';

go

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Retrieves a list of missing indexes in [xml] format. Find the 10 missing indexes with the highest anticipated 
		improvement for user queries. The following query determines which 10 missing indexes would produce the highest anticipated 
		cumulative improvement, in descending order, for user queries.
	references
  	sys.dm_db_missing_index_group_stats (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms345421(v=sql.100).aspx
	sys.dm_db_missing_index_columns (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms345364(v=sql.100).aspx
	sys.dm_db_missing_index_groups (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms345407(v=sql.100).aspx
	sys.dm_db_missing_index_details (Transact-SQL) - https://msdn.microsoft.com/en-us/library/ms345434(v=sql.100).aspx
	Create Indexes with Included Columns - https://msdn.microsoft.com/en-us/library/ms190806(v=sql.120).aspx
	Indexes on Computed Columns - https://msdn.microsoft.com/en-us/library/ms189292(v=sql.120).aspx',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_missing_index_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150728'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_missing_index_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20150728',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_missing_index_list';

go

exec sys.sp_addextendedproperty
  @name = N'revision_20150728',
  @value = N'KLightsey@hcpnv.com – create.',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_missing_index_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_administration'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_missing_index_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'package_administration',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_missing_index_list';

go

exec sys.sp_addextendedproperty
  @name = N'package_administration',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_missing_index_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'version_00_01_00'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_missing_index_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'version_00_01_00',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_missing_index_list';

go

exec sys.sp_addextendedproperty
  @name = N'version_00_01_00',
  @value = N'label_only',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_missing_index_list';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'administration'
                                          , N'procedure'
                                          , N'get_missing_index_list'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'administration',
    @level1type = N'procedure',
    @level1name = N'get_missing_index_list';

go

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'
	declare @output [xml], @database[sysname]=N''DWReporting'';
	execute [administration].[get_missing_index_list] @database=@database, @output=@output output;
	select @output.query(N''missing_index_list/documentation'') as [documentation];
	select t.c.value(''(./object/text())[1]'', N''sysname'')                       as [object]
		   ,t.c.value(''(./equality_columns/text())[1]'', N''sysname'')            as [equality_columns]
		   ,t.c.value(N''(./inequality_columns/text())[1]'', N''nvarchar(4000)'')  as [inequality_columns]
		   ,t.c.value(N''(./included_columns/text())[1]'', N''nvarchar(4000)'')    as [included_columns]
		   ,t.c.value(N''(./column_name/text())[1]'', N''[sysname]'')              as [column_name]
		   ,t.c.value(N''(./column_usage/text())[1]'', N''[nvarchar](20)'')        as [column_usage]
		   ,t.c.value(N''(./cumulative_measure/text())[1]'', N''[float]'')         as [cumulative_measure]
		   ,t.c.value(N''(./avg_system_impact/text())[1]'', N''[float]'')          as [avg_system_impact]
		   ,t.c.value(N''(./avg_total_system_cost/text())[1]'', N''[float]'')      as [avg_total_system_cost]
		   ,t.c.value(N''(./avg_total_user_cost/text())[1]'', N''[float]'')        as [avg_total_user_cost]
		   ,t.c.value(N''(./avg_user_impact/text())[1]'', N''[float]'')            as [avg_user_impact]
		   ,t.c.value(N''(./system_scans/text())[1]'', N''[bigint]'')              as [system_scans]
		   ,t.c.value(N''(./system_seeks/text())[1]'', N''[bigint]'')              as [system_seeks]
		   ,t.c.value(N''(./unique_compiles/text())[1]'', N''[bigint]'')           as [unique_compiles]
		   ,t.c.value(N''(./user_scans/text())[1]'', N''[bigint]'')                as [user_scans]
		   ,t.c.value(N''(./user_seeks/text())[1]'', N''[bigint]'')                as [user_seeks]
	from   @output.nodes(''/missing_index_list/missing_index'') t(c)
	order by [cumulative_measure] desc;',
  @level0type = N'schema',
  @level0name = N'administration',
  @level1type = N'procedure',
  @level1name = N'get_missing_index_list';

go 
