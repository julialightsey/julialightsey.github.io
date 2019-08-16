use [chamomile];

go

if schema_id(N'utility') is null
  execute(N'create schema utility');

go

if object_id(N'[utility].[handle_error]'
             , N'P') is not null
  drop procedure [utility].[handle_error];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------
		
	--
	-- to view documentation
	-----------------------------------------------------------------------------------------------
	declare @schema   [sysname] = N'utility'
            , @object [sysname] = N'handle_error';
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
create procedure [utility].[handle_error]
  --alter procedure [utility].[handle_error] 
  @stack                 xml ([chamomile].[xsc]) output
  , @procedure_id        [int]
  , @application_message [xml]
as
  begin
      declare @pass_meta_data                [nvarchar](1000)= N'[chamomile].[constant].[result].[default].[pass]',
              @fail_meta_data                [nvarchar](1000)= N'[chamomile].[constant].[result].[default].[fail]',
              @utility_xsc_prototype         [nvarchar](1000)= N'[chamomile].[xsc].[stack].[prototype]',
              @error_prototype               [nvarchar](1000)= N'[chamomile].[utility].[error].[stack].[prototype]',
              @application_message_prototype [nvarchar](1000)= N'[chamomile].[utility].[application_message].[prototype]',
              @handle_error_description      [nvarchar](1000)= N'[chamomile].[constant].[utility].[handle_error].[description]',
              @prototype_not_found           [nvarchar](1000)= N'[chamomile].[constant].[return_code].[prototype_not_found]',
              @meta_data_not_found           [nvarchar](1000)= N'[chamomile].[constant].[return_code].[meta_data_not_found]';
      declare @prototype                 [xml],
              @error_procedure           [sysname],
              @error_line                [int],
              @error_number              [int],
              @schema                    [sysname],
              @message                   [nvarchar](max),
              @error_message             [nvarchar](max),
              @error_handler_description [nvarchar](max) = [utility].[get_meta_data](N'[chamomile].[constant].[utility].[handle_error].[description]'),
              @error_builder             [xml]=( [utility].[get_prototype](@error_prototype) ),
              @error_stack_builder       [xml]=( [utility].[get_prototype](@utility_xsc_prototype) ),
              @error_fqn                 [nvarchar](max),
              @error_severity            [int],
              @error_state               [int],
              @return_code               [int],
              @builder                   [xml],
              @subject_fqn               [nvarchar](1000),
              @object_fqn                [nvarchar](1000),
              @timestamp                 [sysname] = convert([sysname], current_timestamp, 126);

      set @error_stack_builder = isnull(@stack
                                        , ( [utility].[get_prototype](@utility_xsc_prototype) ));

      --
      ---------------------------------------
      execute [dbo].[sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @subject_fqn = @builder.value(N'(/*/fqn/@fqn)[1]'
                                        , N'[nvarchar](1000)');

      begin try
          --
          -- validate meta data and prototypes
          --	this method allows validation to occur in the same construct as that of building
          --	a result set of invalid results.
          -------------------------------------------------
          begin
              set @message=null;

              with [invalid_data_finder]
                   as (select [value]
                              , [prototype]
                       from   ( values (@error_handler_description,
                              N'[chamomile].[constant].[utility].[handle_error].[description]'),
                                       (cast(@error_builder as [nvarchar](max)),
                              @error_prototype),
                                       (cast(@error_stack_builder as [nvarchar](max)),
                              @utility_xsc_prototype) ) as [invalid_data] ([value], [prototype]))
              select @message = coalesce(@message, N'', N'') + [prototype]
                                + N', '
              from   [invalid_data_finder]
              where  [value] is null;

              if @message is not null
                begin
                    set @message=isnull(left(@message, len(@message) - 1), N'')
                                 + @subject_fqn;

                    raiserror (100066,1,1,@message);

                    return 100066;
                end;
          end;

          --
          ---------------------------------------
          set @error_stack_builder.modify(N'replace value of (/*/subject/@fqn)[1] with sql:variable("@subject_fqn")');
          set @error_stack_builder.modify(N'replace value of (/*/subject/description/text())[1] with sql:variable("@error_handler_description")');
          set @error_stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
          --
          ---------------------------------------
          set @object_fqn = @builder.value(N'(/*/fqn_prefix/@fqn)[1]', N'[nvarchar](1000)')
                            + '.['
                            + isnull(object_schema_name(@procedure_id), N'')
                            + '].['
                            + isnull(object_name(@procedure_id), N'')
                            + ']';
          --
          ---------------------------------------
          set @error_procedure = isnull(error_procedure()
                                        , N'');
          set @error_line = isnull(error_line()
                                   , N'');
          set @error_number = isnull(error_number()
                                     , N'');
          set @error_message = isnull(error_message()
                                      , N'');
          set @error_severity = isnull(error_severity()
                                       , N'');
          set @error_state = isnull(error_state()
                                    , N'');
          set @schema = isnull(object_schema_name(@procedure_id)
                               , N'');
          set @error_fqn = lower(N'[' + db_name() + N'].[' + @schema + N'].['
                                 + @error_procedure + N']');
          --
          ------------------------------------------------------------------------------------------------
          set @application_message = isnull(@application_message
                                            , (select [data]
                                               from   [repository].[get] (null
                                                                          , @application_message_prototype)));
          set @error_builder.modify(N'insert sql:variable("@application_message") as last into (/*)[1]');
          --
          ------------------------------------------------------------------------------------------------
          set @error_builder.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@error_fqn")');
          set @error_builder.modify(N'insert text {sql:variable("@error_message")} as last into (/*/error_message)[1]');
          set @error_builder.modify(N'replace value of (/*/description/text())[1] with sql:variable("@error_handler_description")');
          set @error_builder.modify(N'replace value of (/*/@error_procedure)[1] with sql:variable("@error_procedure")');
          set @error_builder.modify(N'replace value of (/*/@schema)[1] with sql:variable("@schema")');
          set @error_builder.modify(N'replace value of (/*/@error_line)[1] with sql:variable("@error_line")');
          set @error_builder.modify(N'replace value of (/*/@error_number)[1] with sql:variable("@error_number")');
          set @error_builder.modify(N'replace value of (/*/@error_severity)[1] with sql:variable("@error_severity")');
          set @error_builder.modify(N'replace value of (/*/@error_state)[1] with sql:variable("@error_state")');
          set @error_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');

          --
          ---------------------------------------
          if @error_builder is not null
            set @error_stack_builder.modify(N'insert sql:variable("@error_builder") as last into (/*/result)[1]');

          set @stack = @error_stack_builder;
      end try

      begin catch
          select object_schema_name(@@procid)        as [object_schema_name(@@procid)]
                 , object_name(@@procid)             as [object_name(@@procid)]
                 , @error_stack_builder              as N'@error_stack_builder'
                 , @error_builder                    as [@error_builder]
                 , @stack                            as [@stack]
                 , error_message()                   as [error_message]
                 , error_line()                      as [error_line]
                 , object_schema_name(@procedure_id) as [object_schema_name(@procedure_id)]
                 , error_procedure()                 as [error_procedure()];
      end catch
  end

go

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'{todo: business description | where to find the value | how to use the value | what constraints are on the value}',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error';

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'
			
			<!DOCTYPE html>
			<html>
				<head>
					<link rel="stylesheet" type="text/css" href="..\..\source\common.css">
				</head>
				<body class="footer">
					All content and software is copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
					Licensed as <a href="http://www.katherinelightsey.com/#!license/cjlz" target="blank">[chamomile]</a>
					 and as open source under the <a href="http://www.gnu.org/licenses/agpl-3.0.html" target="blank">GNU Affero GPL</a>.
				</body>
			</html>
			
		',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error';

go

if exists (select *
           from   ::fn_listextendedproperty(N'classification'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'classification',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'classification',
  @value =N'low',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error';

go

if exists (select *
           from   ::fn_listextendedproperty(N'todo'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'todo',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'todo',
  @value =N'{todo: business description | where to find the value | how to use the value | what constraints are on the value}',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error';

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140723'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140723',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140723',
  @value =N'Katherine E. Lightsey',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error';

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_documentation'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_documentation',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_documentation',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error';

go

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.93.00'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.93.00',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'release_00.93.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error';

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error';

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'todo',
  @level0type=N'SCHEMA',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , N'parameter'
                                            , N'@stack'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error',
    @level2type=N'parameter',
    @level2name=N'@stack';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'[@stack] [xml] - {todo: business description | where to find the value | how to use the value | what constraints are on the value}',
  @level0type=N'schema',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error',
  @level2type=N'parameter',
  @level2name=N'@stack';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , N'parameter'
                                            , N'@procedure_id'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error',
    @level2type=N'parameter',
    @level2name=N'@procedure_id';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'[@procedure_id] [int] - {todo: business description | where to find the value | how to use the value | what constraints are on the value}',
  @level0type=N'schema',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error',
  @level2type=N'parameter',
  @level2name=N'@procedure_id';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'utility'
                                            , N'procedure'
                                            , N'handle_error'
                                            , N'parameter'
                                            , N'@application_message'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'utility',
    @level1type=N'procedure',
    @level1name=N'handle_error',
    @level2type=N'parameter',
    @level2name=N'@application_message';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'[@application_message] [xml] - {todo: business description | where to find the value | how to use the value | what constraints are on the value}',
  @level0type=N'schema',
  @level0name=N'utility',
  @level1type=N'procedure',
  @level1name=N'handle_error',
  @level2type=N'parameter',
  @level2name=N'@application_message'; 
