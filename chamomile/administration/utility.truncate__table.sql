if object_id(N'[utility].[truncate__table]', N'P') is not null
  drop procedure [utility].[truncate__table]

GO

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'utility', @object [sysname] = N'truncate__table';
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
*/
create procedure [utility].[truncate__table] @table [nvarchar](256)
with execute as '<account_with_ddl_admin_grant>'
as
  begin
      declare @sql              [nvarchar](max)
              , @parameter_list [nvarchar](max)
              , @parameters     [nvarchar](max) = N'@table [nvarchar](256)';
      declare @database [sysname] = coalesce(parsename(@table, 3), db_name())
              , @schema [sysname] = coalesce(parsename(@table, 2), N'dbo')
              , @object [sysname] = parsename(@table, 1);

      if @object is null
        throw 51000, N'The table name cannot be NULL!', 1;

      --
      -- if it is not in [sys].[tables] check [sys].[synonyms]
      ---------------------------------------------
      if not exists(select *
                    from   [sys].[tables] as [tables]
                           join [sys].[schemas] as [schemas]
                             on [schemas].[schema_id] = [tables].[schema_id]
                    where  [schemas].[name] = @schema
                           and [tables].[name] = @object)
        select @table = @database + N'.'
                        + [synonyms].[base_object_name]
        from   [sys].[synonyms] as [synonyms]
               inner join [sys].[schemas] as [schemas]
                       on [schemas].[schema_id] = [synonyms].[schema_id]
        where  quotename([schemas].[name]) = @schema
               and quotename([synonyms].[name]) = @object
               and [synonyms].[type] = 'SN'
               and [synonyms].[is_ms_shipped] = 0;
      else
        begin
            select @table = quotename(@database) + N'.'
                            + quotename(@schema) + N'.' + quotename(@object);
        end;

      --
      ---------------------------------------------
      if @table is null
        throw 51000, N'Unable to find the object you wish to truncate.', 1;

      --
      set @sql = 'truncate table ' + @table + N';';

      --
      execute sp_executesql
        @sql = @sql;
  end;

GO

if not exists (select *
               from   sys.fn_listextendedproperty(N'description', N'SCHEMA', N'utility', N'PROCEDURE', N'truncate__table', null, null))
  exec sys.sp_addextendedproperty
    @name=N'description'
    , @value=N'[utility].[truncate__table] allows users who do not have the ALTER permission to TRUNCATE tables. For example, a developer account may have the database roles db_datareader and db_datawriter, but also needs to be able to TRUNCATE tables in a truncate/load or dev/test environment. Rather than give the developer account ALTER permissions, which could also allow the user to inadvertently delete or modify objects, grant execute on this procedure to the developer account as shown below:
  grant execute on [utility].[truncate__table] to [<user_account>];
  Because procedures cannot be created as system procedures using sys.sp_MS_marksystemobject when created "with execute as...", this procedure must be created in each database where its use is required.
  reference: https://docs.microsoft.com/en-us/sql/t-sql/statements/truncate-table-transact-sql?view=sql-server-2017#permissions'
    , @level0type=N'SCHEMA'
    , @level0name=N'utility'
    , @level1type=N'PROCEDURE'
    , @level1name=N'truncate__table'

GO

if not exists (select *
               from   sys.fn_listextendedproperty(N'execute_as', N'SCHEMA', N'utility', N'PROCEDURE', N'truncate__table', null, null))
  exec sys.sp_addextendedproperty
    @name=N'execute_as'
    , @value=N'execute [utility].[truncate__table] @table = N''[<schema>].[<table>]'';'
    , @level0type=N'SCHEMA'
    , @level0name=N'utility'
    , @level1type=N'PROCEDURE'
    , @level1name=N'truncate__table'

GO

if not exists (select *
               from   sys.fn_listextendedproperty(N'revision_20180718', N'SCHEMA', N'utility', N'PROCEDURE', N'truncate__table', null, null))
  exec sys.sp_addextendedproperty
    @name=N'revision_20180718'
    , @value=N'KELightsey@gmail.com - Created.'
    , @level0type=N'SCHEMA'
    , @level0name=N'utility'
    , @level1type=N'PROCEDURE'
    , @level1name=N'truncate__table'

GO

if not exists (select *
               from   sys.fn_listextendedproperty(N'revision_20180820', N'SCHEMA', N'utility', N'PROCEDURE', N'truncate__table', null, null))
  exec sys.sp_addextendedproperty
    @name=N'revision_20180820'
    , @value=N'KELightsey@gmail.com - Updated to handle synonyms.'
    , @level0type=N'SCHEMA'
    , @level0name=N'utility'
    , @level1type=N'PROCEDURE'
    , @level1name=N'truncate__table'

GO 
