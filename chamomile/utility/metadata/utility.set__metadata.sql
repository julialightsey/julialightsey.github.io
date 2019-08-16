use [utility];

GO

if object_id(N'[utility].[set__metadata]', N'P') is not null
  drop procedure [utility].[set__metadata];

GO

/*
	--
	-- RUN SCRIPT FOR DOCUMENTATION
	------------------------------------------------
	declare @schema [sysname] = N'utility', @object [sysname] = N'set__metadata';
	--  
	select N'[' +object_schema_name([extended_properties].[major_id]) +N'].['+
		   case when Object_name([objects].[parent_object_id]) is not null 
				then Object_name([objects].[parent_object_id]) +N'].['+Object_name([objects].[object_id]) +N']' 
				else Object_name([objects].[object_id]) +N']' + coalesce(N'.['+[columns].[name] + N']', N'')
			end                                                                as [object]
		   ,case when [extended_properties].[minor_id]=0 
				then [objects].[type_desc]
				else N'parameter'
			end                                                                as [type]
		   ,[extended_properties].[name]                                       as [property]
		   ,[extended_properties].[value]                                      as [value]
	from   [sys].[extended_properties] as [extended_properties]
		   join [sys].[objects] as [objects]
			 on [objects].[object_id]=[extended_properties].[major_id]
		   left join [sys].[columns] as [columns]
				  on [extended_properties].[major_id]=[columns].[object_id] and
					 [columns].[column_id]=[extended_properties].[minor_id]
	where   coalesce(Object_schema_name([objects].[parent_object_id]), Object_schema_name([extended_properties].[major_id]))=@schema and
			coalesce(Object_name([objects].[parent_object_id]), Object_name([extended_properties].[major_id]))=@object
	order  by [columns].[name],[object],[type],[property]; 
*/
create procedure [utility].[set__metadata] @key           [nvarchar](450)
                                           , @value       [nvarchar](max)
                                           , @description [nvarchar](max)
                                           , @created_by  [sysname] = null
as
  begin
      merge into [utility__secure].[metadata] as [target]
      using ( values (@key
            , @value
            , @description
            , coalesce(@created_by, current_user))) as [source] ([key], [value], [description], [created_by])
      on [target].[key] = [source].[key]
      when not matched by target then
        insert ([key]
                , [value]
                , [description]
                , [created_by])
        values ([key]
                , [value]
                , [description]
                , [created_by])
      when matched then
        update set [target].[value] = [source].[value]
                   , [target].[description] = [source].[description]
                   , [target].[created_by] = [source].[created_by];
  end;

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'Merges an entry into [utility__secure].[metadata]. Provision is not made for DELETE. If a DELETE is required, engage the dba to write and log the appropriate script. This is done to ensure that orphan calls are not maded to metadata.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility'
  , @level1type=N'PROCEDURE'
  , @level1name=N'set__metadata'

GO

exec sys.sp_addextendedproperty
  @name=N'execute_as'
  , @value=N'declare @key           [nvarchar](450) =N''category.class.type''
        , @value       [nvarchar](max)=N''value''
        , @description [nvarchar](max)=N''description''
        , @created_by  [sysname] = N''firstname.lastname@aristocrat.com'';

execute [utility].[set__metadata]
  @key =@key
  , @value = @value
  , @description = @description
  , @created_by = @created_by;'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility'
  , @level1type=N'PROCEDURE'
  , @level1name=N'set__metadata'

GO

exec sys.sp_addextendedproperty
  @name=N'revision_20180727'
  , @value=N'Created - katherine.lightsey@aristocrat.com'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility'
  , @level1type=N'PROCEDURE'
  , @level1name=N'set__metadata'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'@key [nvarchar](450) - The key value for the metadata. Should be descriptive and entered in dotted notation similar to "category.class.type".'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility'
  , @level1type=N'PROCEDURE'
  , @level1name=N'set__metadata'
  , @level2type=N'PARAMETER'
  , @level2name=N'@key'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'@value [nvarchar](max) - The value associated with [key]. The value to be returned. As this is an [nvarchar](max), it should be cast/converted to the desired type at the point of use.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility'
  , @level1type=N'PROCEDURE'
  , @level1name=N'set__metadata'
  , @level2type=N'PARAMETER'
  , @level2name=N'@value'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'@description [nvarchar](max) - A description of the key/value pair. This should be descriptive and verbose enough to adequately describe the technical and/or business use of the key/value pair.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility'
  , @level1type=N'PROCEDURE'
  , @level1name=N'set__metadata'
  , @level2type=N'PARAMETER'
  , @level2name=N'@description'

GO

exec sys.sp_addextendedproperty
  @name=N'description'
  , @value=N'@created_by  [sysname] = null - Defaults to CURRENT_USER. Should be more descriptive if possible.'
  , @level0type=N'SCHEMA'
  , @level0name=N'utility'
  , @level1type=N'PROCEDURE'
  , @level1name=N'set__metadata'
  , @level2type=N'PARAMETER'
  , @level2name=N'@created_by'

GO 
