use [master];

go

if object_id(N'[dbo].[sp_chamomile_documentation_get_table]'
             , N'P') is not null
  drop procedure [dbo].[sp_chamomile_documentation_get_table];

go

/*
	select *
      from fn_listextendedproperty(default, N'schema', N'dbo', N'procedure', N'sp_chamomile_documentation_get_table', default, default); 
    
*/
create procedure [dbo].[sp_chamomile_documentation_get_table] @object_fqn         [nvarchar](max)
                                                              , @timestamp_output [bit] = 0
                                                              , @bcp_command      [nvarchar](max) = null output
                                                              , @documentation    [nvarchar](max) = null output
                                                              , @stack            [xml] = null output
as
  begin
      declare @column_list        [nvarchar](max),
              @execute_as         [xml],
              @builder            [xml],
              @server             [sysname],
              @normalized_server  [sysname],
              @subject_fqn        [nvarchar](max),
              @message            [nvarchar](max),
              @timestamp          [sysname] = convert([sysname], current_timestamp, 126),
              @object_type        [sysname],
              @schema             [sysname],
              @object             [sysname],
              @sql                [nvarchar](max),
              @columns            [nvarchar](max),
              @table_properties   [nvarchar](max),
              @log_prototype      [xml],
              @stripped_timestamp [sysname];

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
      if lower(@object_type) not like N'%table%'
        begin
            set @message = @subject_fqn
                           + N' is only used to format tables. '
                           + @object_fqn + N' is type {' + @object_type
                           + N'}.';

            raiserror(510000,@message,1);
        end;

      --
      -------------------------------------------
      select @table_properties = coalesce(@table_properties + N' ', N'')
                                 + N'<details id="fourth_indent"><summary>['
                                 + [extended_properties].[name]
                                 + N']</summary>'
                                 + cast([extended_properties].[value] as [nvarchar](max))
                                 + N'</details>'
      from   [sys].[tables] as [tables]
             left join [sys].[extended_properties] as [extended_properties]
                    on [extended_properties].[major_id] = [tables].[object_id]
      where  [extended_properties].[class] = 1
             and object_schema_name([tables].[object_id]) = @schema
             and [tables].[name] = @object
      order  by [extended_properties].[name];

      --
      -------------------------------------------------
      select @column_list = coalesce(@column_list + N' ', N',')
                            + N'<li>[' + [columns].[name] + N'] ['
                            + type_name([columns].[user_type_id]) + N']'
                            + case
                            --
                            when type_name([columns].[user_type_id]) = N'nvarchar' then N'('+ cast([columns].[max_length]/2 as [sysname]) + N')'
                            --
                            when type_name([columns].[user_type_id]) = N'varchar' then N'('+ cast([columns].[max_length] as [sysname]) + N')'
                            --
                            else N'' end
                            + isnull(N' property="' + [extended_properties].[name] + N'" value="' + cast([extended_properties].[value] as [nvarchar](max)) + N'"', N'')
                            + N'</li>'
      from   [sys].[columns] as [columns]
             left join [sys].[extended_properties] as [extended_properties]
                    on [extended_properties].[major_id] = [columns].[object_id]
                       and [extended_properties].[minor_id] = [columns].[column_id]
      where  object_schema_name([columns].[object_id]) = @schema
             and object_name([columns].[object_id]) = @object
      order  by [columns].[name];

      --
      select @column_list = N'<details id="fourth_indent"><summary>[column_list]</summary><ol>'
                            + right(@column_list, len(@column_list) -1 )
                            + N'</ol></details>';

      --
      -------------------------------------------
      set @documentation = N'<details id="third_indent"><summary>'
                           + @object_fqn + N' <span class="note">{'
                           + @timestamp + N'}</span></summary>'
                           + isnull(@table_properties, N'')
                           + isnull(@column_list, N'') + N'</details>';

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
  N'sp_chamomile_documentation_get_table';

go

if exists (select *
           from   fn_listextendedproperty(N'execute_as'
                                          , N'schema'
                                          , N'dbo'
                                          , N'procedure'
                                          , N'sp_chamomile_documentation_get_table'
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'execute_as',
    @level0type = N'schema',
    @level0name = N'dbo',
    @level1type = N'procedure',
    @level1name = N'sp_chamomile_documentation_get_table',
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'execute_as',
  @value = N'use [chamomile_oltp];
go
declare @bcp_command     [nvarchar](max)
        , @documentation [nvarchar](max)
        , @stack         [xml]
        , @object_fqn    [nvarchar](max) = ''[flower_secure].[order]'';
--
execute [dbo].[sp_chamomile_documentation_get_table]
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
  @level1name = N'sp_chamomile_documentation_get_table',
  @level2type = null,
  @level2name =null; 
