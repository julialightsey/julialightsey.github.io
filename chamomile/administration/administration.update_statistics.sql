/*
	Change to target database prior to running.
*/
IF schema_id(N'administration') IS NULL
  EXECUTE (N'CREATE SCHEMA administration');

go

SET ansi_nulls ON;

go

SET quoted_identifier ON;

go

IF object_id(N'[administration].[update_statistics]', N'P') IS NOT NULL
  DROP PROCEDURE [administration].[update_statistics];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'administration', @object [sysname] = N'update_statistics';
	--
	-------------------------------------------------
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
	
	execute [administration].[update_statistics];
	
*/
CREATE PROCEDURE [administration].[update_statistics] @table_filter [SYSNAME] = NULL
AS
  BEGIN
      DECLARE @view  NVARCHAR(1024)
              , @sql NVARCHAR(max);

      --
      -----------------------------------------------
      IF @table_filter IS NULL
        BEGIN
            PRINT N'Executing [sys].[sp_updatestats] to update statistics on all objects other than indexed views.';

			--
            -- update statistics on all objects other than indexed views
            -------------------------------------
            EXECUTE [sys].[sp_updatestats];

            PRINT N'Executing [sys].[sp_updatestats] complete.';

            --
            -- update statistics for indexed views
            -------------------------------------
            PRINT N'Updating statistics for indexed views.';

            DECLARE [view_cursor] CURSOR local fast_forward FOR
              SELECT quotename([schemas].[name], N'[') + N'.'
                     + quotename([objects].[name], N'[') AS [view_name]
              FROM   [sys].[objects] [objects]
                     INNER JOIN [sys].[schemas] [schemas]
                             ON [schemas].[schema_id] = [objects].[schema_id]
                     INNER JOIN [sys].[indexes] [indexes]
                             ON [indexes].[object_id] = [objects].[object_id]
                     INNER JOIN [sys].[sysindexes] [sysindexes]
                             ON [sysindexes].id = [indexes].[object_id]
                                AND [sysindexes].[indid] = [indexes].[index_id]
              WHERE  [objects].[type] = 'V'
              GROUP  BY quotename([schemas].[name], N'[') + N'.'
                        + quotename([objects].[name], N'[')
              HAVING max([sysindexes].[rowmodctr]) > 0;
        END;

      --
      -----------------------------------------
      BEGIN
          OPEN [view_cursor];

          FETCH next FROM [view_cursor] INTO @view;

          WHILE ( @@FETCH_STATUS = 0 )
            BEGIN
                PRINT N'   Updating stats for view ' + @view;

                SET @sql = N'update statistics ' + @view;

                EXECUTE (@sql);

                FETCH next FROM [view_cursor] INTO @view;
            END;

          CLOSE [view_cursor];

          DEALLOCATE [view_cursor];
      END;

      PRINT N'Updating statistics for indexed views. complete.';
  END;

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'update_statistics', DEFAULT, DEFAULT))
  EXEC [sys].sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'update_statistics';

go

EXEC [sys].sp_addextendedproperty
  @name         = N'description'
  , @value      = N'Procedure to update all statistics including indexed views..
  Based on a script from:
  Rhys Jones, 7th Feb 2008
	http://www.rmjcs.com/SQLServer/ThingsYouMightNotKnow/sp_updatestatsDoesNotUpdateIndexedViewStats/tabid/414/Default.aspx
	Update stats in indexed views because indexed view stats are not updated by sp_updatestats.
	Only does an update if rowmodctr is non-zero.
	No error handling, does not deal with disabled clustered indexes.
	Does not respect existing sample rate.
	[sys].sysindexes.rowmodctr is not completely reliable in SQL Server 2005.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'update_statistics';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'TODO', N'schema', N'administration', N'procedure', N'update_statistics', DEFAULT, DEFAULT))
  EXEC [sys].sp_dropextendedproperty
    @name         = N'TODO'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'update_statistics';

go

EXEC [sys].sp_addextendedproperty
  @name         = N'TODO'
  , @value      = N'Refactor to use @table_filter properly.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'update_statistics';

go


--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'revision_20160106', N'schema', N'administration', N'procedure', N'update_statistics', DEFAULT, DEFAULT))
  EXEC [sys].sp_dropextendedproperty
    @name         = N'revision_20160106'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'update_statistics';

go

EXEC [sys].sp_addextendedproperty
  @name         = N'revision_20160106'
  , @value      = N'KELightsey@gmail.com – Added @table_filter.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'update_statistics';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'revision_20150810', N'schema', N'administration', N'procedure', N'update_statistics', DEFAULT, DEFAULT))
  EXEC [sys].sp_dropextendedproperty
    @name         = N'revision_20150810'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'update_statistics';

go

EXEC [sys].sp_addextendedproperty
  @name         = N'revision_20150810'
  , @value      = N'KELightsey@gmail.com – created.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'update_statistics';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'package_administration', N'schema', N'administration', N'procedure', N'update_statistics', DEFAULT, DEFAULT))
  EXEC [sys].sp_dropextendedproperty
    @name         = N'package_administration'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'update_statistics';

go

EXEC [sys].sp_addextendedproperty
  @name         = N'package_administration'
  , @value      = N'label_only'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'update_statistics';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'execute_as', N'schema', N'administration', N'procedure', N'update_statistics', DEFAULT, DEFAULT))
  EXEC [sys].sp_dropextendedproperty
    @name         = N'execute_as'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'update_statistics';

go

EXEC [sys].sp_addextendedproperty
  @name         = N'execute_as'
  , @value      = N'execute [administration].[update_statistics];'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'update_statistics';

go

--
------------------------------------------------- 
IF EXISTS (SELECT *
           FROM   fn_listextendedproperty(N'description', N'schema', N'administration', N'procedure', N'update_statistics', N'parameter', N'@table_filter'))
  EXEC sys.sp_dropextendedproperty
    @name         = N'description'
    , @level0type = N'schema'
    , @level0name = N'administration'
    , @level1type = N'procedure'
    , @level1name = N'update_statistics'
    , @level2type = N'parameter'
    , @level2name = N'@table_filter';

go

EXEC sys.sp_addextendedproperty
  @name         = N'description'
  , @value      = N'@table [sysname] NOT NULL - optional parameter, if used, constrains UPDATE STATISTICS to tables matching on LIKE syntax.'
  , @level0type = N'schema'
  , @level0name = N'administration'
  , @level1type = N'procedure'
  , @level1name = N'update_statistics'
  , @level2type = N'parameter'
  , @level2name = N'@table_filter';

go 
