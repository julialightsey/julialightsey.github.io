use [master];
go

if object_id(N'[dbo].[sp_update_statistics]', N'P') is not null
  drop procedure [dbo].[sp_update_statistics];

go

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'dbo', @object [sysname] = N'sp_update_statistics';
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
*/
create procedure [dbo].[sp_update_statistics]
as
  begin
      declare @view  nvarchar(1024)
              , @sql nvarchar(max);

      --
      -----------------------------------------

      --
      -- update statistics on all objects other than indexed views
      -------------------------------------
      execute [sys].[sp_updatestats];

      print N'Executing [sys].[sp_updatestats] complete.';

      --
      -----------------------------------------
      begin
          declare [view_cursor] cursor local fast_forward for
            select quotename([schemas].[name], N'[') + N'.'
                   + quotename([objects].[name], N'[') as [view_name]
            from   [sys].[objects] [objects]
                   inner join [sys].[schemas] [schemas]
                           on [schemas].[schema_id] = [objects].[schema_id]
                   inner join [sys].[indexes] [indexes]
                           on [indexes].[object_id] = [objects].[object_id]
                   inner join [sys].[sysindexes] [sysindexes]
                           on [sysindexes].[id] = [indexes].[object_id]
                              and [sysindexes].[indid] = [indexes].[index_id]
            where  [objects].[type] = 'V'
            group  by quotename([schemas].[name], N'[') + N'.'
                      + quotename([objects].[name], N'[')
            having max([sysindexes].[rowmodctr]) > 0;
      end;

      --
      -----------------------------------------
      begin
          open [view_cursor];

          fetch next from [view_cursor] into @view;

          while ( @@fetch_status = 0 )
            begin
                print N'   Updating stats for view ' + @view;

                set @sql = N'update statistics ' + @view;

                execute (@sql);

                fetch next from [view_cursor] into @view;
            end;

          close [view_cursor];

          deallocate [view_cursor];
      end;

      print N'Updating statistics for indexed views. complete.';
  end;

go

exec [sp_MS_marksystemobject]
  N'sp_update_statistics';

go


exec [sys].sp_addextendedproperty
  @name = N'description'
  , @value = N'Procedure to update all statistics including indexed views..
  Based on a script from:
  Rhys Jones, 7th Feb 2008
	http://www.rmjcs.com/SQLServer/ThingsYouMightNotKnow/sp_updatestatsDoesNotUpdateIndexedViewStats/tabid/414/Default.aspx
	Update stats in indexed views because indexed view stats are not updated by sp_updatestats.
	Only does an update if rowmodctr is non-zero.
	No error handling, does not deal with disabled clustered indexes.
	Does not respect existing sample rate.
	[sys].sysindexes.rowmodctr is not completely reliable in SQL Server 2005.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_update_statistics';

go

exec [sys].sp_addextendedproperty
  @name = N'revision_st_2476'
  , @value = N'lightseyk@ccculv.com - Installed.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_update_statistics';

go


exec [sys].sp_addextendedproperty
  @name = N'package_administration'
  , @value = N'label_only'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_update_statistics';

go


exec [sys].sp_addextendedproperty
  @name = N'execute_as'
  , @value = N'execute [dbo].[sp_update_statistics];'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_update_statistics';

go

exec sys.sp_addextendedproperty
  @name = N'revision_atmdna_18'
  , @value = N'lightseyk@ccculv.com - Created.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_update_statistics'
  , @level2type = null
  , @level2name =null;

go