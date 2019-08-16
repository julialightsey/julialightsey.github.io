/*
	Change to target database prior to running.
*/
if schema_id(N'administration') is null
  execute (N'create schema administration;');

go

if object_id(N'[administration].[defragment__index]', N'P') is not null
  drop procedure [administration].[defragment__index]; ;

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'administration', @object [sysname] = N'defragment__index';
	--
	select N'[' + object_schema_name([extended_properties].[major_id]) +N'].['+
       case when Object_name([objects].[parent_object_id]) is not null 
			then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
			else Object_name([objects].[object_id]) +N']' + 
				case when [parameters].[parameter_id] > 0
					then coalesce(N'.['+[parameters].[name] + N']', N'') 
					else N'' 
				end +
				case when columnproperty ([objects].[object_id], [parameters].[name], N'IsOutParam') = 1  then N' output'
					else N''
				end
		end                                                                     as [object]
       ,case when [extended_properties].[minor_id]=0 then [objects].[type_desc]
			else N'PARAMETER'
        end                                                                     as [type]
		   ,[extended_properties].[name]                                        as [property]
		   ,[extended_properties].[value]                                       as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   join [sys].[schemas] as [schemas]
			 on [schemas].[schema_id]=[objects].[schema_id]
		   left join [sys].[parameters] as [parameters]
				  on [extended_properties].[major_id]=[parameters].[object_id] and
					 [parameters].[parameter_id]=[extended_properties].[minor_id]
	where  [schemas].[name]=@schema and [objects].[name]=@object
	order  by [parameters].[parameter_id],[object],[type],[property]; 
	
	-- execute_as
	DECLARE @maximum_fragmentation    [INT] = 25
			, @minimum_page_count     [INT] = 500
			, @fillfactor             [INT] = NULL
			, @reorganize_demarcation [INT] = 25
			, @defrag_count_limit     [INT] = 2
			, @output                 [XML];
	EXECUTE [administration].[defragment__index]
		@maximum_fragmentation=@maximum_fragmentation
		, @minimum_page_count=@minimum_page_count
		, @fillfactor=@fillfactor
		, @reorganize_demarcation=@reorganize_demarcation
		, @defrag_count_limit=@defrag_count_limit
		, @output=@output OUTPUT;
	SELECT @output as [output];
	
*/
create procedure [administration].[defragment__index] @maximum_fragmentation    [int] = 25
                                                      , @minimum_page_count     [int] = 500
                                                      , @fillfactor             [int] = null
                                                      , @reorganize_demarcation [int] = 25
                                                      , @defrag_count_limit     [int] = null
                                                      , @output                 [xml] = null OUT
as
  begin
      declare @schema                         [sysname]
              , @table                        [sysname]
              , @index                        [sysname]
              , @average_fragmentation_before decimal(10, 2)
              , @average_fragmentation_after  decimal(10, 2)
              , @sql                          [nvarchar](max)
              , @xml_builder                  [xml]
              , @defrag_count                 [int] = 0
              , @start                        datetime2
              , @complete                     datetime2
              , @elapsed                      decimal(10, 2)
              --
              , @timestamp                    datetime = current_timestamp
              , @this                         nvarchar(1024) = quotename(db_name()) + N'.'
                + quotename(object_schema_name(@@procid))
                + N'.' + quotename(object_name(@@procid));

      --
      -------------------------------------------
      select @output = coalesce(@output, N'<index_list subject="' + @this
                                         + '" timestamp="'
                                         + convert(sysname, @timestamp, 126) + '"/>')
             , @defrag_count_limit = coalesce(@defrag_count_limit, 1);

      --
      -------------------------------------------
      set @output.modify(N'insert attribute maximum_fragmentation {sql:variable("@maximum_fragmentation")} as last into (/*)[1]');
      set @output.modify(N'insert attribute minimum_page_count {sql:variable("@minimum_page_count")} as last into (/*)[1]');
      set @output.modify(N'insert attribute fillfactor {sql:variable("@fillfactor")} as last into (/*)[1]');
      set @output.modify(N'insert attribute reorganize_demarcation {sql:variable("@reorganize_demarcation")} as last into (/*)[1]');
      set @output.modify(N'insert attribute defrag_count_limit {sql:variable("@defrag_count_limit")} as last into (/*)[1]');

      --
      -------------------------------------------
      declare [table_cursor] cursor for
        select [schemas].[name]                                              as [schema]
               , [tables].[name]                                             as [table]
               , [indexes].[name]                                            as [index]
               , [dm_db_index_physical_stats].[avg_fragmentation_in_percent] as [average_fragmentation_before]
        from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, 'LIMITED') as [dm_db_index_physical_stats]
               join [sys].[indexes] as [indexes]
                 on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                    and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
               join [sys].[tables] as [tables]
                 on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
               join [sys].[schemas] as [schemas]
                 on [schemas].[schema_id] = [tables].[schema_id]
        where  [indexes].[name] is not null
               and [dm_db_index_physical_stats].[avg_fragmentation_in_percent] > @maximum_fragmentation
               and [dm_db_index_physical_stats].[page_count] > @minimum_page_count
        order  by [dm_db_index_physical_stats].[avg_fragmentation_in_percent] desc,[schemas].[name],[tables].[name];

      --
      -------------------------------------------
      begin
          open [table_cursor];

          fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;

          while @@fetch_status = 0
                and ( @defrag_count < @defrag_count_limit )
            begin
                if @average_fragmentation_before > @reorganize_demarcation
                  begin
                      set @sql = 'alter index [' + @index + N'] on [' + @schema
                                 + N'].[' + @table + '] rebuild ';

                      if @fillfactor is not null
                        begin
                            set @sql = @sql + ' with (fillfactor='
                                       + cast(@fillfactor as [sysname]) + ')';
                        end;

                      set @sql = @sql + ' ; ';
                  end;
                else
                  begin
                      set @sql = 'alter index [' + @index + N'] on [' + @schema
                                 + N'].[' + @table + '] reorganize';
                  end;

                --
                -------------------------------
                if @sql is not null
                  begin
                      --
                      ---------------------------
                      set @start = current_timestamp;

                      execute (@sql);

                      set @complete = current_timestamp;
                      set @elapsed = datediff(millisecond, @start, @complete);
                      --
                      -- build output
                      ---------------------------
                      set @xml_builder = (select @schema                                                                               as N'@schema'
                                                 , @table                                                                              as N'@table'
                                                 , @index                                                                              as N'@index'
                                                 , @average_fragmentation_before                                                       as N'@average_fragmentation_before'
                                                 , cast([dm_db_index_physical_stats].[avg_fragmentation_in_percent] as decimal(10, 2)) as N'@average_fragmentation_after'
                                                 , @elapsed                                                                            as N'@elapsed_milliseconds'
                                                 , @sql                                                                                as N'sql'
                                          from   [sys].[dm_db_index_physical_stats](db_id(), null, null, null, 'LIMITED') as [dm_db_index_physical_stats]
                                                 join [sys].[indexes] as [indexes]
                                                   on [dm_db_index_physical_stats].[object_id] = [indexes].[object_id]
                                                      and [dm_db_index_physical_stats].[index_id] = [indexes].[index_id]
                                                 join [sys].[tables] as [tables]
                                                   on [tables].[object_id] = [dm_db_index_physical_stats].[object_id]
                                                 join [sys].[schemas] as [schemas]
                                                   on [schemas].[schema_id] = [tables].[schema_id]
                                          where  [schemas].[name] = @schema
                                                 and [tables].[name] = @table
                                                 and [indexes].[name] = @index
                                          for xml path(N'result'), root(N'index'));

                      --
                      ---------------------------
                      if @xml_builder is not null
                        begin
                            set @output.modify(N'insert sql:variable("@xml_builder") as last into (/*)[1]');
                        end;
                  end;

                set @defrag_count = @defrag_count + 1;

                fetch next from [table_cursor] into @schema, @table, @index, @average_fragmentation_before;
            end;

          close [table_cursor];

          deallocate [table_cursor];
      end;
  end;

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment__index', default, default))
  exec sys.sp_dropextendedproperty @name         = N'description'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index';

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'Rebuild all indexes over @maximum_fragmentation.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20160106', N'schema', N'administration', N'procedure', N'defragment__index', default, default))
  exec sys.sp_dropextendedproperty @name         = N'revision_20160106'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'revision_20150810', N'schema', N'administration', N'procedure', N'defragment__index', default, default))
  exec sys.sp_dropextendedproperty @name         = N'revision_20150810'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index';

go

exec sys.sp_addextendedproperty @name         = N'revision_20150810'
                                , @value      = N'KELightsey@gmail.com – created.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'package_administration', N'schema', N'administration', N'procedure', N'defragment__index', default, default))
  exec sys.sp_dropextendedproperty @name         = N'package_administration'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index';

go

exec sys.sp_addextendedproperty @name         = N'package_administration'
                                , @value      = N'label_only'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'execute_as', N'schema', N'administration', N'procedure', N'defragment__index', default, default))
  exec sys.sp_dropextendedproperty @name         = N'execute_as'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index';

go

exec sys.sp_addextendedproperty @name         = N'execute_as'
                                , @value      = N'execute [administration].[defragment__index];  
	DECLARE @maximum_fragmentation    [INT] = 85
			, @fillfactor             [INT] = NULL
			, @reorganize_demarcation [INT] = 25
			, @defrag_count_limit     [INT] = 2
			, @output                 [XML];
	EXECUTE [administration].[defragment__index]
		@maximum_fragmentation=@maximum_fragmentation
		, @fillfactor=@fillfactor
		, @reorganize_demarcation=@reorganize_demarcation
		, @defrag_count_limit=@defrag_count_limit
		, @output=@output OUTPUT;
	SELECT @output as [output];
	'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment__index', N'parameter', N'@minimum_page_count'))
  exec sys.sp_dropextendedproperty @name         = N'description'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index'
                                   , @level2type = N'parameter'
                                   , @level2name = N'@minimum_page_count';

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'@minimum_page_count [INT] = 500 - Tables with page count less than this will not be defragmented. Default 500.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index'
                                , @level2type = N'parameter'
                                , @level2name = N'@minimum_page_count';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment__index', N'parameter', N'@fillfactor'))
  exec sys.sp_dropextendedproperty @name         = N'description'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index'
                                   , @level2type = N'parameter'
                                   , @level2name = N'@fillfactor';

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'@fillfactor [INT] - The fill factor to be used if an index is rebuilt. If NULL, the existing fill factor will be used for the index. DEFAULT - NULL.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index'
                                , @level2type = N'parameter'
                                , @level2name = N'@fillfactor';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'todo', N'schema', N'administration', N'procedure', N'defragment__index', null, null))
  exec sys.sp_dropextendedproperty @name         = N'todo'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index';

go

exec sys.sp_addextendedproperty @name         = N'todo'
                                , @value      = N'-- Test rebuild/reorganize.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment__index', N'parameter', N'@reorganize_demarcation'))
  exec sys.sp_dropextendedproperty @name         = N'description'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index'
                                   , @level2type = N'parameter'
                                   , @level2name = N'@reorganize_demarcation';

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'@reorganize_demarcation [INT] - The demarcation limit between a REORGANIZE vs REBUILD operation. Indexes having less than or equal to this level of fragmentation will be reorganized. Indexes with greater than this level of fragmentation will be rebuilt. DEFAULT - 25.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index'
                                , @level2type = N'parameter'
                                , @level2name = N'@reorganize_demarcation';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment__index', N'parameter', N'@maximum_fragmentation'))
  exec sys.sp_dropextendedproperty @name         = N'description'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index'
                                   , @level2type = N'parameter'
                                   , @level2name = N'@maximum_fragmentation';

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'@maximum_fragmentation [INT] - The maximum fragmentation allowed before the procedure will attempt to defragment it. Indexes with fragmentation below this level will not be defragmented. DEFAULT 25.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index'
                                , @level2type = N'parameter'
                                , @level2name = N'@maximum_fragmentation';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment__index', N'parameter', N'@defrag_count_limit'))
  exec sys.sp_dropextendedproperty @name         = N'description'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index'
                                   , @level2type = N'parameter'
                                   , @level2name = N'@defrag_count_limit';

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'@defrag_count_limit [INT] -  The maximum number of indexes to defragment. Used to limit the total time and resources to be consumed by a run. This will be used in conjunction with the @maximum_fragmentation parameter and should be considered to be the "TOP(n)" of indexes above the @maximum_fragmentation parameter. DEFAULT - NULL - Will be set to 1.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index'
                                , @level2type = N'parameter'
                                , @level2name = N'@defrag_count_limit';

go

--
------------------------------------------------- 
if exists (select *
           from   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'defragment__index', N'parameter', N'@output'))
  exec sys.sp_dropextendedproperty @name         = N'description'
                                   , @level0type = N'schema'
                                   , @level0name = N'administration'
                                   , @level1type = N'procedure'
                                   , @level1name = N'defragment__index'
                                   , @level2type = N'parameter'
                                   , @level2name = N'@output';

go

exec sys.sp_addextendedproperty @name         = N'description'
                                , @value      = N'@output [XML] - An XML output construct containing the SQL used to defragment each index, the before and after fragmentation level, elapsed time in milliseconds, and other statistical information.'
                                , @level0type = N'schema'
                                , @level0name = N'administration'
                                , @level1type = N'procedure'
                                , @level1name = N'defragment__index'
                                , @level2type = N'parameter'
                                , @level2name = N'@output';

go 
