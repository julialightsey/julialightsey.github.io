use [master];

go

if object_id(N'[dbo].[sp_handle_error]', N'P') is not null
  drop procedure [dbo].[sp_handle_error];

go

/*
    --
    -- All content is licensed as [chamomile] (https://github.com/KELightsey/chamomile) and 
    --	copyright Katherine Elizabeth Lightsey, 1959-2018 (aka; my life), all rights reserved,
    --	and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
    ---------------------------------------------

    --
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'dbo'
            , @object [sysname] = N'sp_handle_error';
    
    select [extended_properties].[name]         as [property]
           , [extended_properties].[class_desc] as [type]
		   , [parameters].[name]			    as [parameter]
           , [extended_properties].[value]      as [value]
    from   [sys].[extended_properties] as [extended_properties]
           join [sys].[objects] as [objects]
             on [objects].[object_id] = [extended_properties].[major_id]
           join [sys].[schemas] as [schemas]
             on [schemas].[schema_id] = [objects].[schema_id]
           left join [sys].[parameters] as [parameters]
                  on [parameters].[object_id] = [extended_properties].[major_id]
                     and [parameters].[parameter_id] = [extended_properties].[minor_id]
    where  [schemas].[name] = @schema
           and [objects].[name] = @object
    order  by [extended_properties].[class_desc] asc
              , [extended_properties].[name] asc
			  , [parameters].[name] asc; 
*/
create procedure [dbo].[sp_handle_error] @error                 [xml] output
                                         , @subject             [nvarchar](1000)
                                         , @application_message [xml] = null
as
  begin
      declare @error_stack_builder [xml] = N'<error subject="" timestamp=""><error_message /></error>'
              , @timestamp         [sysname] = convert([sysname], current_timestamp, 126)
              , @error_procedure   [sysname]
              , @error_line        [int]
              , @error_number      [int]
              , @schema            [sysname]
              , @error_message     [nvarchar](max)
              , @error_severity    [int]
              , @error_state       [int];

      select @error_procedure = isnull(error_procedure(), N'')
             , @error_line = isnull(error_line(), N'')
             , @error_number = isnull(error_number(), N'')
             , @error_message = isnull(error_message(), N'')
             , @error_severity = isnull(error_severity(), N'')
             , @error_state = isnull(error_state(), N'');

      set @error_stack_builder.modify(N'replace value of (/*/@subject)[1] with sql:variable("@subject")');
      set @error_stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
      set @error_stack_builder.modify(N'insert attribute error_procedure {sql:variable("@error_procedure")} as first into (/*)[1]');
      set @error_stack_builder.modify(N'insert attribute error_line {sql:variable("@error_line")} as first into (/*)[1]');
      set @error_stack_builder.modify(N'insert attribute error_number {sql:variable("@error_number")} as first into (/*)[1]');
      set @error_stack_builder.modify(N'insert attribute error_severity {sql:variable("@error_severity")} as first into (/*)[1]');
      set @error_stack_builder.modify(N'insert attribute error_state {sql:variable("@error_state")} as first into (/*)[1]');
      --
      set @error_stack_builder.modify(N'insert text {sql:variable("@error_message")} as last into (/*/error_message)[1]');

      --
      if @application_message is not null
        set @error_stack_builder.modify(N'insert sql:variable("@application_message") as last into (/*)[1]');

      --
      set @error = @error_stack_builder;
  end;

go

exec [sp_MS_marksystemobject]
  N'sp_handle_error';

go

--
-------------------------------------------------
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@application_message [xml] = null - Optional parameter. An optional message in XML format that will be included in the output (@error) parameter. It is suggested that this be included and include conditions that exist when the error occurred such as input parameters, variable conditions at the point of failure, the step in the code, etc.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_handle_error'
  , @level2type = N'parameter'
  , @level2name = N'@application_message';

go

--
-------------------------------------------------
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@subject [nvarchar](1000) - Required parameter. The subject of the exchange, typically the procedure where the error occurred, expected as a fully qualified name; [<database>].[<schema>].[<object>].'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_handle_error'
  , @level2type = N'parameter'
  , @level2name = N'@subject';

go

--
-------------------------------------------------
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'@error [xml] output - Required parameter. The formatted error content.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_handle_error'
  , @level2type = N'parameter'
  , @level2name = N'@error';

go

--
-------------------------------------------------
exec sys.sp_addextendedproperty
  @name = N'description'
  , @value = N'Package error information in a standard format.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_handle_error'
  , @level2type = null
  , @level2name =null;

go

exec sys.sp_addextendedproperty
  @name = N'revision_20180611'
  , @value = N'kelightsey@gmail.com - created.'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_handle_error'
  , @level2type = null
  , @level2name =null;

go

exec sys.sp_addextendedproperty
  @name = N'package_utility'
  , @value = N'label_only'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_handle_error'
  , @level2type = null
  , @level2name =null;

go

exec sys.sp_addextendedproperty
  @name = N'execute_as_01'
  , @value = N'
declare @error [xml]
	, @this [nvarchar](1024) = quotename(db_name()) + N''.'' + quotename(object_schema_name(@@procid)) + N''.'' + quotename(object_name(@@procid))
	, @application_message [xml] = N''<application_message p1="" p2="">comment</application_message>'';
execute [sp_handle_error] @error=@error output, @subject=@this, @application_message=N''bang!'';'
  , @level0type = N'schema'
  , @level0name = N'dbo'
  , @level1type = N'procedure'
  , @level1name = N'sp_handle_error'
  , @level2type = null
  , @level2name =null;

go 
