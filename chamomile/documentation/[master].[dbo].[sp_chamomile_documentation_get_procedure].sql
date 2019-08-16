use [master];

go

if object_id(N'[dbo].[sp_chamomile_documentation_get_procedure]'
             , N'P') is not null
  drop procedure [dbo].[sp_chamomile_documentation_get_procedure];

go

/*
	select *
      from fn_listextendedproperty(default, N'schema', N'dbo', N'procedure', N'sp_chamomile_documentation_get_procedure', default, default); 
    
*/
create procedure [dbo].[sp_chamomile_documentation_get_procedure] @object_fqn         [nvarchar](max)
                                                                  , @timestamp_output [bit] = 0
                                                                  , @bcp_command      [nvarchar](max) = null output
                                                                  , @documentation    [nvarchar](max) = null output
                                                                  , @stack            [xml] = null output
as
  begin
      declare @parameter_list       [nvarchar](max),
              @execute_as           [xml],
              @builder              [xml],
              @server               [sysname],
              @normalized_server    [sysname],
              @subject_fqn          [nvarchar](max),
              @message              [nvarchar](max),
              @timestamp            [sysname] = convert([sysname], current_timestamp, 126),
              @object_type          [sysname],
              @schema               [sysname],
              @object               [sysname],
              @sql                  [nvarchar](max),
              @parameters           [nvarchar](max),
              @procedure_properties [nvarchar](max),
              @log_prototype        [xml],
              @stripped_timestamp   [sysname];

      --
      -------------------------------------------------
      execute [sp_chamomile_documentation_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      --
      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](1000)');
      set @normalized_server=@builder.value(N'(/*/normalized_server/@name)[1]'
                                            , N'[nvarchar](1000)');
      set @subject_fqn=@builder.value(N'(/*/fqn/@fqn)[1]'
                                      , N'[nvarchar](1000)');
      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](1000)');
      set @stripped_timestamp = @builder.value(N'(/*/@stripped_timestamp)[1]'
                                               , N'[sysname]');

      --
      select @schema = parsename(@object_fqn
                                 , 2)
             , @object = parsename(@object_fqn
                                   , 1)
             , @object_type = (select [objects].[type_desc]
                               from   [sys].[objects] as [objects]
                               where  object_schema_name([objects].[object_id]) = @schema
                                      and [objects].[name] = @object);

      --
      if lower(@object_type) not like N'%procedure%'
        begin
            set @message = @subject_fqn
                           + N' is only used to format procedures. '
                           + @object_fqn + N' is type {' + @object_type
                           + N'}.';

            raiserror(510000,@message,1);
        end;

      --
      -------------------------------------------
      select @procedure_properties = coalesce(@procedure_properties + N' ', N'')
                                     + N'<details id="fourth_indent"><summary>['
                                     + [extended_properties].[name]
                                     + N']</summary>'
                                     + cast([extended_properties].[value] as [nvarchar](max))
                                     + N'</details>'
      from   [sys].[procedures] as [procedures]
             left join [sys].[extended_properties] as [extended_properties]
                    on [extended_properties].[major_id] = [procedures].[object_id]
      where  [extended_properties].[class] = 1
             and object_schema_name([procedures].[object_id]) = @schema
             and [procedures].[name] = @object
      order  by [extended_properties].[name];

      --
      -------------------------------------------------
      select @parameter_list = coalesce(@parameter_list + N' ', N',')
                               + N'<li>' + [parameters].[name] + N' ['
                               + type_name([parameters].[user_type_id])
                               + N']('+
                               + cast([parameters].[max_length]/2 as [sysname])
                               + N') '
                               + isnull('property="' + [extended_properties].[name] + N'" value="' + cast([extended_properties].[value] as [nvarchar](max)) + N'"', N'')
                               + N'</li>'
      from   [sys].[parameters] as [parameters]
             left join [sys].[extended_properties] as [extended_properties]
                    on [extended_properties].[major_id] = [parameters].[object_id]
                       and [extended_properties].[minor_id] = [parameters].[parameter_id]
      where  object_schema_name([parameters].[object_id]) = @schema
             and object_name([parameters].[object_id]) = @object
      order  by [parameters].[name];

      select @parameter_list = N'<details id="fourth_indent"><summary>[parameter_list]</summary><ol>'
                               + right(@parameter_list, len(@parameter_list) -1 )
                               + N'</ol></details>';

      --
      -------------------------------------------
      set @documentation = N'<details id="third_indent"><summary>'
                           + @object_fqn + N' <span class="note">{'
                           + @timestamp + N'}</span></summary>'
                           + isnull(@procedure_properties, N'')
                           + isnull(@parameter_list, N'') + N'</details>';

      --
      -- load documentation into repository and create bcp extraction command
      -------------------------------------------
      begin
          set @log_prototype =[chamomile].[utility].[get_prototype](N'[chamomile].[log].[stack].[prototype]');
          set @log_prototype.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
          set @log_prototype.modify(N'replace value of (/log/description/text())[1] with sql:variable("@documentation")');
          --
          -------------------------------------------
          set @stack = null;

          begin try
              execute [chamomile].[utility].[set_log]
                @object_fqn = @object_fqn,
                @log = @log_prototype,
                @sequence = 1,
                @stack = @stack output;
          end try

          begin catch
              select error_message() + N' ignore';

              --
              -------------------------------------------
              if @timestamp_output = 1
                set @message = N'_' + @stripped_timestamp;
              else
                set @message = N'';

              --
              -------------------------------------------
              set @bcp_command = N'BCP "select [chamomile].[documentation].[get_formatted_html]([chamomile].[utility].[get_log_text](N'''
                                 + @object_fqn + N'''));" queryout '
                                 + @subject_fqn + '_' + @object_fqn + @message
                                 + N'.html' + N' -t, -T -c -d ' + db_name()
                                 + N' -S ' + @server + N';';
          end catch;
      end;
  end;

go

exec [sp_ms_marksystemobject]
  N'sp_chamomile_documentation_get_procedure';

go

if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'dbo'
                                          , N'procedure'
                                          , N'sp_chamomile_documentation_get_procedure'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'dbo',
    @level1type = N'procedure',
    @level1name = N'sp_chamomile_documentation_get_procedure',
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'use [chamomile_oltp];
go
declare @bcp_command     [nvarchar](max)
        , @documentation [nvarchar](max)
        , @stack         [xml]
        , @object_fqn    [nvarchar](max) = ''[flower].[set]'';
execute [dbo].[sp_chamomile_documentation_get_procedure]
  @object_fqn      =@object_fqn
  , @documentation = @documentation output
  , @bcp_command   =@bcp_command output
  , @stack         =@stack output;
select @bcp_command                                                                                          as [@bcp_command]
       , @documentation                                                                                      as [@documentation]
       , [chamomile].[documentation].[get_formatted_html](@documentation)                                    as [html_output]
       , @stack                                                                                              as [@stack]
       , [chamomile].[utility].[get_log_text](@object_fqn)                                                   as [log_text]
       , [chamomile].[documentation].[get_formatted_html]([chamomile].[utility].[get_log_text](@object_fqn)) as [formatted_log_text]; ',
  @level0type = N'schema',
  @level0name = N'dbo',
  @level1type = N'procedure',
  @level1name = N'sp_chamomile_documentation_get_procedure',
  @level2type = null,
  @level2name =null; 
