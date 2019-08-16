use [master];

go

if object_id(N'[dbo].[sp_get_best_practice_analysis]'
             , N'P') is not null
  drop procedure [dbo].[sp_get_best_practice_analysis];

go

/*  
    -- https://www.sqlcopilot.com/sql-server-best-practices.html
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------
    --
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N'dbo'
            , @object [sysname] = N'sp_get_best_practice_analysis';
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
create procedure [dbo].[sp_get_best_practice_analysis] @object_fqn         [nvarchar](max) = null
                                                       , @status           [sysname]= null
                                                       , @timestamp_output [bit]= 1
                                                       , @stack            [xml] = null output
                                                       , @test_stack       [xml] = null output
                                                       , @bcp_command      [nvarchar](max) = null output
                                                       , @documentation    [nvarchar](max) = null output
as
  begin
      set nocount on;

      declare @identity_column_naming_violation          [nvarchar](max),
              @missing_table_documentation_violation     [nvarchar](max),
              @missing_column_documentation_violation    [nvarchar](max),
              @missing_procedure_documentation_violation [nvarchar](max),
              @missing_parameter_documentation_violation [nvarchar](max),
              @default_constraint_naming_violation       [nvarchar](max),
              @unique_constraint_naming_violation        [nvarchar](max),
              @primary_key_naming_violation              [nvarchar](max),
              @no_primary_key_violation                  [nvarchar](max),
              @no_identity_column_violation              [nvarchar](max),
              @no_unique_constraint_violation            [nvarchar](max),
              @composite_primary_key_violation           [nvarchar](max),
              @todo_violation                            [nvarchar](max),
              @unused_table_warning                      [nvarchar](max),
              @low_row_count_table_warning               [nvarchar](max),
              @unused_query_warning                      [nvarchar](max);
      declare @count                 [int],
              @builder               [xml],
              @xml_builder           [xml],
              @test_builder          [xml],
              @test                  [xml],
              @pass                  [sysname] = [chamomile].[utility].[get_meta_data](N'[chamomile].[constant].[result].[default].[pass]'),
              @fail                  [sysname] = [chamomile].[utility].[get_meta_data](N'[chamomile].[constant].[result].[default].[fail]'),
              @sequence              [int],
              @test_name             [nvarchar](max),
              @test_description      [nvarchar](max),
              @return_code           [int],
              @message               [nvarchar](max),
              @expected              [nvarchar](max),
              @start                 [datetime] = current_timestamp,
              @timestamp             [sysname] = convert([sysname], current_timestamp, 126),
              @subject_fqn           [nvarchar](max),
              @object_type           [sysname],
              @elapsed               [decimal](9, 4),
              @id                    [uniqueidentifier],
              @server                [nvarchar](max),
              @normalized_server     [nvarchar](max),
              @database              [sysname],
              @schema                [sysname],
              @object                [sysname],
              @stripped_timestamp    [sysname],
              @object_classification [sysname],
              @oltp                  [sysname] = N'oltp',
              @olap                  [sysname] = N'olap',
              @oltp_olap             [sysname] = N'oltp_olap',
              @table                 [sysname] = N'table',
              @procedure             [sysname] = N'procedure',
              @function              [sysname] = N'function';
      declare @list as table
        (
           [html] [nvarchar](max)
        );
      declare @required_properties as table
        (
           [property] [sysname]
        );

      select @stack = [utility].[get_prototype](N'[chamomile].[xsc].[stack].[prototype]')
             , @test_stack = [utility].[get_prototype](N'[chamomile].[test].[test_stack].[stack].[prototype]');

      set @object_classification = isnull((select cast([extended_properties].[value] as [sysname])
                                           from   [sys].[extended_properties] as [extended_properties]
                                           where  object_schema_name([extended_properties].[major_id]) = @schema
                                                  and object_name([extended_properties].[major_id]) = @object)
                                          , @oltp_olap);

      --
      ------------------------------------------------
      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](max)');
      set @subject_fqn=@builder.value(N'(/*/fqn/@fqn)[1]'
                                      , N'[nvarchar](max)');
      set @stripped_timestamp = @builder.value(N'(/*/@stripped_timestamp)[1]'
                                               , N'[sysname]');

      --
      -------------------------------------------
      select @object = parsename(@object_fqn
                                 , 1)
             , @schema = parsename(@object_fqn
                                   , 2)
             , @database = parsename(@object_fqn
                                     , 3);

      --
      -------------------------------------------
      with [get_type]
           as (select lower([objects].[type_desc]) as [type_desc]
               from   [sys].[objects] as [objects]
               where  object_schema_name([objects].[object_id]) = @schema
                      and [objects].[name] = @object)
      select @object_type = case
                              when [type_desc] like N'%' + @table + N'%' then @table
                              when [type_desc] like N'%' + @procedure + N'%' then @procedure
                              when [type_desc] like N'%' + @function + N'%' then @function
                            end
      from   [get_type];

      --
      -------------------------------------------
      set @status = coalesce(@status
                             , N'allow_stale');
      set @subject_fqn = N'[' + db_name()
                         + N'].[dbo].[sp_get_best_practice_analysis]';

      --
      -------------------------------------------
      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @server=@builder.value(N'(/*/server/@name)[1]'
                                 , N'[nvarchar](max)');
      set @normalized_server=@builder.value(N'(/*/normalized_server/@name)[1]'
                                            , N'[nvarchar](max)');
      set @subject_fqn=N'[master].[dbo].[best_practice_analysis]';
      --
      -------------------------------------------
      set @message = N'[best_practice_analysis] {'
                     + @subject_fqn + N'}';
      set @test_stack.modify(N'replace value of (/*/description/text())[1] with sql:variable("@message")');

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
         and @object_classification in( @oltp, @oltp_olap )
        begin
            select @message = null
                   , @expected = null
                   , @sequence = 1
                   , @test_name = N'missing_table_documentation_violation';

            --
            -----------------------------------
            delete from @required_properties;

            insert into @required_properties
                        ([property])
            values      (N'description'),
                        (N'package'),
                        (N'revision'),
                        (N'release'),
                        (N'classification'),
                        (N'license');

            select @expected = coalesce(@expected + N', ', N'')
                               + [property]
            from   @required_properties;

            select @expected = N' required properties {' + @expected + N'}';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['+@test_name+N']')
                                       + @expected;

            --
            -----------------------------------
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            ---------------------------------------
            with [template]
                 as (select object_schema_name([object].[object_id]) as [schema]
                            , [object].[name]                        as [table]
                            , [object].[object_id]                   as [object_id]
                            , [required_properties].[property]       as [required_property]
                     from   @required_properties as [required_properties]
                            join [sys].[tables] as [object]
                              on 1 = 1
                                 ----------
                                 and ( object_schema_name([object].[object_id]) = @schema
                                        or @schema is null )
                                 and ( [object].[name] = @object
                                        or @object is null ))
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schema] + N'].[' + [table] + N'].['
                              + [required_property] + N']</li></violation>'
            from   [template] as [template]
                   left join [sys].[extended_properties] as [extended_properties]
                          on [extended_properties].[major_id] = [template].[object_id]
                             and ( substring([extended_properties].[name]
                                             , 0
                                             , len([required_property]) + 1) = [required_property] )
            where  ( [extended_properties].[minor_id] = 0
                      or [extended_properties].[minor_id] is null )
                   and ( substring([extended_properties].[name]
                                   , 0
                                   , len([required_property]) + 1) != [required_property]
                          or [extended_properties].[name] is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @expected = null
                   , @sequence = 2
                   , @test_name = N'missing_column_documentation_violation';

            delete from @required_properties;

            insert into @required_properties
                        ([property])
            values      (N'description');

            select @expected = coalesce(@expected + N', ', N'')
                               + [property]
            from   @required_properties;

            select @expected = N' required properties {' + @expected + N'}';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['+@test_name+N']')
                                       + @expected;

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            with [template]
                 as (select object_schema_name([object].[object_id]) as [schema]
                            , [object].[name]                        as [table]
                            , [object].[object_id]                   as [object_id]
                            , [columns].[name]                       as [column]
                            , [columns].[column_id]                  as [column_id]
                            , [required_properties].[property]       as [required_property]
                     from   @required_properties as [required_properties]
                            join [sys].[tables] as [object]
                              on 1 = 1
                            join [sys].[columns] as [columns]
                              on [columns].[object_id] = [object].[object_id]
                     where
                      ----------
                      ( object_schema_name([object].[object_id]) = @schema
                         or @schema is null )
                      and ( [object].[name] = @object
                             or @object is null ))
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schema] + N'].[' + [table] + N'].[' + [column]
                              + N'].[' + [required_property]
                              + N']</li></violation>'
            from   [template] as [template]
                   left join [sys].[extended_properties] as [extended_properties]
                          on [extended_properties].[major_id] = [template].[object_id]
                             and [extended_properties].[minor_id] = [template].[column_id]
                             and ( substring([extended_properties].[name]
                                             , 0
                                             , len([required_property]) + 1) = [extended_properties].[name] )
            where  ( [extended_properties].[minor_id] = 0
                      or [extended_properties].[minor_id] is null )
                   and ( substring([extended_properties].[name]
                                   , 0
                                   , len([required_property]) + 1) != [extended_properties].[name]
                          or [extended_properties].[name] is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details></'
                                + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @procedure
        begin
            select @message = null
                   , @expected = null
                   , @sequence = 3
                   , @test_name = N'missing_procedure_documentation_violation';

            delete from @required_properties;

            insert into @required_properties
                        ([property])
            values      (N'description'),
                        (N'package'),
                        (N'revision'),
                        (N'release'),
                        (N'frequency'),
                        (N'execute_as'),
                        (N'license');

            select @expected = coalesce(@expected + N', ', N'')
                               + [property]
            from   @required_properties;

            select @expected = N' required properties {' + @expected + N'}';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['+@test_name+N']')
                                       + @expected;

            --
            -------------------------------------
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            with [template]
                 as (select object_schema_name([object].[object_id]) as [schema]
                            , [object].[name]                        as [procedure]
                            , [object].[object_id]                   as [object_id]
                            , [required_properties].[property]       as [required_property]
                     from   @required_properties as [required_properties]
                            join [sys].[procedures] as [object]
                              on 1 = 1
                     ----------
                     where  ( object_schema_name([object].[object_id]) = @schema
                               or @schema is null )
                            and ( [object].[name] = @object
                                   or @object is null ))
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schema] + N'].[' + [procedure] + N'].['
                              + [required_property] + N']</li></violation>'
            from   [template] as [template]
                   left join [sys].[extended_properties] as [extended_properties]
                          on [extended_properties].[major_id] = [template].[object_id]
                             and ( substring([extended_properties].[name]
                                             , 0
                                             , len([required_property]) + 1) = [extended_properties].[name] )
            where  ( [extended_properties].[minor_id] = 0
                      or [extended_properties].[minor_id] is null );

        /*
         select @message = coalesce(@message + ' ', '')
                           + N'<violation><li class="error" >['
                           + [schema] + N'].[' + [procedure] + N'].['
                           + [required_property] + N']</li></violation>'
         from   [template] as [template]
                left join [sys].[extended_properties] as [extended_properties]
                       on [extended_properties].[major_id] = [template].[object_id]
                          and ( substring([extended_properties].[name], 0, len([required_property]) + 1) = [extended_properties].[name] )
         where  ( [extended_properties].[minor_id] = 0
                   or [extended_properties].[minor_id] is null )
                and ( substring([extended_properties].[name], 0, len([required_property]) + 1) != [extended_properties].[name]
                       or [extended_properties].[name] is null );*/
            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');

            select @test_stack as N' missing proc docs'
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @procedure
        begin
            select @message = null
                   , @expected = null
                   , @sequence = 4
                   , @test_name = N'missing_parameter_documentation_violation';

            delete from @required_properties;

            insert into @required_properties
                        ([property])
            values      (N'description');

            select @expected = coalesce(@expected + N', ', N'')
                               + [property]
            from   @required_properties;

            select @expected = N' required properties {' + @expected + N'}';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['+@test_name+N']')
                                       + @expected;

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            with [template]
                 as (select object_schema_name([object].[object_id]) as [schema]
                            , [object].[name]                        as [procedure]
                            , [object].[object_id]                   as [object_id]
                            , [parameters].[name]                    as [parameter]
                            , [parameters].[parameter_id]            as [parameter_id]
                            , [required_properties].[property]       as [required_property]
                     from   @required_properties as [required_properties]
                            join [sys].[procedures] as [object]
                              on 1 = 1
                            join [sys].[parameters] as [parameters]
                              on [parameters].[object_id] = [object].[object_id]
                     ----------
                     where  ( object_schema_name([object].[object_id]) = @schema
                               or @schema is null )
                            and ( [object].[name] = @object
                                   or @object is null ))
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schema] + N'].[' + [procedure] + N'].['
                              + [parameter] + N'].[' + [required_property]
                              + N']</li></violation>'
            from   [template] as [template]
                   left join [sys].[extended_properties] as [extended_properties]
                          on [extended_properties].[major_id] = [template].[object_id]
                             and [extended_properties].[minor_id] = [template].[parameter_id]
                             and ( substring([extended_properties].[name]
                                             , 0
                                             , len([required_property]) + 1) = [extended_properties].[name] )
            where  ( [extended_properties].[minor_id] = 0
                      or [extended_properties].[minor_id] is null )
                   and ( substring([extended_properties].[name]
                                   , 0
                                   , len([required_property]) + 1) != [extended_properties].[name]
                          or [extended_properties].[name] is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 5
                   , @test_name = N'default_constraint_naming_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schemas].[name] + N'].[' + [object].[name]
                              + N'].[' + [columns].[name] + N'].['
                              + [default_constraints].[name]
                              + N']</li></violation>'
            from   [sys].[default_constraints] as [default_constraints]
                   join [sys].[schemas] as [schemas]
                     on [schemas].[schema_id] = [default_constraints].[schema_id]
                   join [sys].[tables] as [object]
                     on [object].[object_id] = [default_constraints].[parent_object_id]
                   join [sys].[columns] as [columns]
                     on [columns].[column_id] = [default_constraints].[parent_column_id]
                        and [columns].[object_id] = [default_constraints].[parent_object_id]
            where  [default_constraints].[name] not like lower(N'' + [schemas].[name] + N'.' + [object].[name]
                                                               + N'.' + [columns].[name] + N'.default')
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 6
                   , @test_name = N'unique_constraint_naming_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schemas].[name] + N'].[' + [object].[name]
                              + N'].[' + [columns].[name] + N'] {['
                              + [indexes].[name]
                              + N']}</li>
							  <li class="error" >'
                              + N'expected {'
                              + lower([schemas].[name] + N'.' + [object].[name] + N'.' + [columns].[name] + N'.unique')
                              + N'}' + N'</li></violation>'
            from   [sys].[indexes] as [indexes]
                   join [sys].[index_columns] as [index_columns]
                     on [indexes].[index_id] = [index_columns].[index_id]
                        and [indexes].[object_id] = [index_columns].[object_id]
                   join [sys].[tables] as [object]
                     on [object].[object_id] = [index_columns].[object_id]
                   join [sys].[schemas] as [schemas]
                     on [schemas].[schema_id] = [object].[schema_id]
                   join [sys].[columns] as [columns]
                     on [columns].[column_id] = [index_columns].[column_id]
                        and [columns].[object_id] = [index_columns].[object_id]
            where  [indexes].[is_unique_constraint] = 1
                   and [indexes].[name] not like lower([schemas].[name] + N'.' + [object].[name] + N'.'
                                                       + [columns].[name] + N'.unique')
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 7
                   , @test_name = N'primary_key_naming_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schemas].[name] + N'].[' + [object].[name]
                              + N'].[' + [columns].[name] + N'].['
                              + [indexes].[name]
                              + N']</li>
							  <li class="error" >'
                              + N'expected {'
                              + lower([schemas].[name] + N'.' + [object].[name] + N'.' + [columns].[name] + N'.clustered_primary_key')
                              + N'}' + N'</li></violation>'
            from   [sys].[tables] as [object]
                   join [sys].[schemas] as [schemas]
                     on [schemas].[schema_id] = [object].[schema_id]
                   left join [sys].[indexes] as [indexes]
                          on [indexes].[object_id] = [object].[object_id]
                   left join [sys].[index_columns] as [index_columns]
                          on [indexes].[index_id] = [index_columns].[index_id]
                             and [indexes].[object_id] = [index_columns].[object_id]
                   left join [sys].[columns] as [columns]
                          on [columns].[column_id] = [index_columns].[column_id]
                             and [columns].[object_id] = [index_columns].[object_id]
            where  [indexes].[is_primary_key] = 1
                   and [indexes].[name] not like lower([schemas].[name] + N'.' + [object].[name] + N'.'
                                                       + [columns].[name]
                                                       + N'.clustered_primary_key')
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 8
                   , @test_name = N'identity_column_naming_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schemas].[name] + N'].[' + [object].[name]
                              + N'].[' + [columns].[name]
                              + N']</li></violation>'
            from   [sys].[tables] as [object]
                   left join [sys].[schemas] as [schemas]
                          on [schemas].[schema_id] = [object].[schema_id]
                   left join [sys].[columns] as [columns]
                          on [object].[object_id] = [columns].[object_id]
                             and [columns].[is_identity] = 1
            where  [columns].[name] != lower(N'id')
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 9
                   , @test_name = N'no_primary_key_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schemas].[name] + N'].[' + [object].[name]
                              + N'].[' + N']</li></violation>'
            from   [sys].[tables] as [object]
                   join [sys].[schemas] as [schemas]
                     on [schemas].[schema_id] = [object].[schema_id]
                   left join [sys].[indexes] as [indexes]
                          on [indexes].[object_id] = [object].[object_id]
                   left join [sys].[index_columns] as [index_columns]
                          on [indexes].[index_id] = [index_columns].[index_id]
                             and [indexes].[object_id] = [index_columns].[object_id]
                   left join [sys].[columns] as [columns]
                          on [columns].[column_id] = [index_columns].[column_id]
                             and [columns].[object_id] = [index_columns].[object_id]
            where  [indexes].[type_desc] = N'HEAP'
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
         and @object_classification in( @oltp, @oltp_olap )
        begin
            select @message = null
                   , @sequence = 10
                   , @test_name = N'no_identity_column_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + N'<violation><li class="error" >['
                              + [schemas].[name] + N'].[' + [object].[name]
                              + N'].[' + N']</li></violation>'
            from   [sys].[tables] as [object]
                   left join [sys].[schemas] as [schemas]
                          on [schemas].[schema_id] = [object].[schema_id]
                   left join [sys].[columns] as [columns]
                          on [object].[object_id] = [columns].[object_id]
                             and [columns].[is_identity] = 1
            ----------
            where  ( object_schema_name([object].[object_id]) = @schema
                      or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null )
            group  by [schemas].[name]
                      , [object].[name]
                      , [columns].[is_identity]
            having [columns].[is_identity] is null;

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 11
                   , @test_name = N'no_unique_constraint_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + isnull(N'<violation><li class="error" >[' + [schemas].[name] + N'].['+ [object].[name] + N']</li></violation>', N'')
            from   [sys].[tables] as [object]
                   join [sys].[schemas] as [schemas]
                     on [schemas].[schema_id] = [object].[schema_id]
                   left join [sys].[indexes] as [indexes]
                          on [indexes].[object_id] = [object].[object_id]
                             and [indexes].[is_unique_constraint] = 1
                   left join [sys].[index_columns] as [index_columns]
                          on [indexes].[index_id] = [index_columns].[index_id]
                             and [indexes].[object_id] = [index_columns].[object_id]
                   left join [sys].[columns] as [columns]
                          on [columns].[column_id] = [index_columns].[column_id]
                             and [columns].[object_id] = [index_columns].[object_id]
            where  [indexes].[name] is null
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null );

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
         and @object_classification in( @oltp, @oltp_olap )
        begin
            select @message = null
                   , @sequence = 12
                   , @test_name = N'composite_primary_key_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + isnull(N'<violation><li class="error" >[' + [schemas].[name] + N'].['+ [object].[name] + N'].[' + [indexes].[name] + N']</li></violation>', N'')
            from   [sys].[tables] as [object]
                   join [sys].[schemas] as [schemas]
                     on [schemas].[schema_id] = [object].[schema_id]
                   left join [sys].[indexes] as [indexes]
                          on [indexes].[object_id] = [object].[object_id]
                   left join [sys].[index_columns] as [index_columns]
                          on [indexes].[index_id] = [index_columns].[index_id]
                             and [indexes].[object_id] = [index_columns].[object_id]
                   left join [sys].[columns] as [columns]
                          on [columns].[column_id] = [index_columns].[column_id]
                             and [columns].[object_id] = [index_columns].[object_id]
            where  [indexes].[is_primary_key] = 1
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null )
            group  by [schemas].[name]
                      , [object].[name]
                      , [indexes].[name]
            having count(*) > 1;

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      begin
          select @message = null
                 , @sequence = 13
                 , @test_name = N'todo_violation';

          select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                           + @test_name + N']');

          --
          set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
          set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
          set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');
          set @builder = null;
          --
          -------------------------------------
      /* insert into @list
                   ([html])
         select N'<li>' + cast([class] as [sysname])
                + [class_desc]
         --  + cast([major_id] as [sysname])
         --  + cast([minor_id] as [sysname])
         --  + object_schema_name([major_id])
         --  + object_name([major_id]) + [name]
         --  + cast([value] as [nvarchar](max)) + N'</li>'
         from   [sys].[extended_properties] as [extended_properties]
         where  cast([name] as [sysname]) like N'%todo%'
                 or cast([value] as [sysname]) like N'%todo%'
                    ----------
                    and ( object_schema_name([major_id]) = @schema
                           or @schema is null )
                    and ( [major_id] = @object
                           or @object is null )
         order  by object_schema_name([major_id])
                   , object_name([major_id])
                   , [name];
       select @todo_violation = coalesce(@todo_violation + ' ', '') + [html]
       from   @list;
       set @todo_violation = @todo_violation;*/
          --
          ---------------------------------------
          set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
          set @test_builder = N'<' + @test_name + N'><details><summary>['
                              + @test_name + N']</summary></details>
								</' + @test_name + N'>';
          set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

          if @test_builder is not null
            begin
                set @count = @test_builder.value(N'count(//violation)'
                                                 , N'[int]');

                if @count > 0
                  begin
                      set @message = N' - violation_count {'
                                     + cast(@count as [sysname]) + N'}';
                      set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                  end;
                else
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                --
                set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
            end;

          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
      end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 14
                   , @test_name = N'unused_table_warning';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + isnull(N'<warning><li class="error" >[' + [schemas].[name] + N'].['+ [object].[name] + + N']</li></warning>', N'')
            from   [sys].[tables] as [object]
                   inner join [sys].[schemas] as [schemas]
                           on [schemas].[schema_id] = [object].[schema_id]
                   inner join [sys].[indexes] as [indexes]
                           on [object].[object_id] = [indexes].[object_id]
                   inner join [sys].[partitions] as [partitions]
                           on [indexes].[object_id] = [partitions].[object_id]
                              and [indexes].[index_id] = [partitions].[index_id]
                   inner join [sys].[allocation_units] as [allocation_units]
                           on [partitions].[partition_id] = [allocation_units].container_id
            where  [object].[name] not like 'dt%'
                   and [object].[is_ms_shipped] = 0
                   and [indexes].[object_id] > 255
                   and [partitions].[rows] = 0
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null )
            group  by [schemas].[name]
                      , [object].[name]
                      , [partitions].[rows]
            order  by sum([allocation_units].total_pages) * 8;

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//warning)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - warning_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @table
        begin
            select @message = null
                   , @sequence = 15
                   , @test_name = N'low_row_count_table_warning';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            select @message = coalesce(@message + ' ', '')
                              + isnull(N'<warning><li class="error" >[' + [schemas].[name] + N'].['+ [object].[name] + + N']</li></warning>', N'')
            from   [sys].[tables] as [object]
                   inner join [sys].[schemas] as [schemas]
                           on [schemas].[schema_id] = [object].[schema_id]
                   inner join [sys].[indexes] as [indexes]
                           on [object].[object_id] = [indexes].[object_id]
                   inner join [sys].[partitions] as [partitions]
                           on [indexes].[object_id] = [partitions].[object_id]
                              and [indexes].[index_id] = [partitions].[index_id]
                   inner join [sys].[allocation_units] as [allocation_units]
                           on [partitions].[partition_id] = [allocation_units].container_id
            where  [object].[name] not like 'dt%'
                   and [object].is_ms_shipped = 0
                   and [indexes].[object_id] > 255
                   and [partitions].[rows] < 5
                   ----------
                   and ( object_schema_name([object].[object_id]) = @schema
                          or @schema is null )
                   and ( [object].[name] = @object
                          or @object is null )
            group  by [schemas].[name]
                      , [object].[name]
                      , [partitions].[rows]
            order  by sum([allocation_units].total_pages) * 8;

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @procedure
         and ( @schema is null )
         and ( @object is null )
        begin
            select @message = null
                   , @sequence = 16
                   , @test_name = N'unused_query_warning';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            --
            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            with [builder]
                 as (select top(10) [objects].[object_id]
                     from   [sys].[dm_exec_procedure_stats] as [dm_exec_procedure_stats]
                            join [sys].[databases] as [databases]
                              on [databases].[database_id] = [dm_exec_procedure_stats].[database_id]
                            join [sys].[objects] as [objects]
                              on [objects].[object_id] = [dm_exec_procedure_stats].[object_id]
                     where  [databases].[name] = db_name()
                            and datediff(day
                                         , [last_execution_time]
                                         , current_timestamp) > 90
                     order  by [last_execution_time] asc)
            select @message = coalesce(@message + ' ', '')
                              + [objects].[name]
                              + convert([sysname], [cached_time])
                              + convert([sysname], [last_execution_time])
                              + convert([sysname], [execution_count])
                              + convert([sysname], [total_worker_time] / [execution_count])
                              + convert([sysname], [total_elapsed_time] / [execution_count])
                              + convert([sysname], [total_logical_reads] / [execution_count])
                              + convert([sysname], [total_logical_writes] / [execution_count])
                              + convert([sysname], [total_physical_reads] / [execution_count])
            from   [sys].[dm_exec_procedure_stats] as [dm_exec_procedure_stats]
                   join [builder] as [builder]
                     on [builder].[object_id] = [dm_exec_procedure_stats].[object_id]
                   join [sys].[databases] as [databases]
                     on [databases].[database_id] = [dm_exec_procedure_stats].[database_id]
                   join [sys].[objects] as [objects]
                     on [objects].[object_id] = [dm_exec_procedure_stats].[object_id]
            where  [databases].[name] = db_name()
            order  by [last_execution_time] asc;

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      -------------------------------------------
      if @object_type = @procedure
        begin
            select @message = null
                   , @sequence = 17
                   , @test_name = N'no_unit_test_violation';

            select @test_description = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis].['
                                                                             + @test_name + N']');

            set @test = [chamomile].[utility].[get_prototype](N'[chamomile].[test].[test].[stack].[prototype]');
            set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
            set @test.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@test_name")');
            set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');

            --
            -------------------------------------
            if not exists (select *
                           from   [sys].[objects] as [object]
                                  join [sys].[objects] as [test]
                                    on object_schema_name([object].[object_id]) = object_schema_name([test].[object_id])
                                                                                  + N'_test'
                                       and [object].[name] = [object].[name]
                                       ----------
                                       and ( object_schema_name([object].[object_id]) = @schema
                                              or @schema is null )
                                       and ( [object].[name] = @object
                                              or @object is null ))
              select @message = coalesce(@message + ' ', '')
                                + isnull(N'<violation><li class="error" >[' + @test_name + N']</li>
									<p>'+@test_description +N'</p>
								</violation>', N'');

            --
            ---------------------------------------
            set @builder = cast(N'<ol>' + @message + N'</ol>' as [xml]);
            set @test_builder = N'<' + @test_name + N'><details><summary>['
                                + @test_name + N']</summary></details>
								</' + @test_name + N'>';
            set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/*)[1]');

            if @test_builder is not null
              begin
                  set @count = @test_builder.value(N'count(//violation)'
                                                   , N'[int]');

                  if @count > 0
                    begin
                        set @message = N' - violation_count {'
                                       + cast(@count as [sysname]) + N'}';
                        set @test_builder.modify(N'insert text {sql:variable("@message")} as last into (/*/details/summary)[1]');
                    end;
                  else
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  set @test.modify(N'insert sql:variable("@test_builder") as last into (/*/result)[1]');
              end;

            set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
        end;

      --
      -------------------------------------------
      select @elapsed = cast(datediff(microsecond
                                      , @start
                                      , current_timestamp) / cast(1000000 as [decimal](9, 0)) as [decimal](9, 4));

      set @count = @test_stack.value(N'count(//violation)'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count(/*/test)'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      --
      -------------------------------------------
      set @builder = @test_stack.query(N'(/*/test/result/*[local-name()!="description"])');
      set @xml_builder = N'<log>
		<description>best practice analysis</description>
			<div id="outer_indent">
				<details>
					<summary>' + @object_fqn
                         + N'</summary>
					<p class="timestamp">built by {'
                         + @subject_fqn + N'} timestamp {' + @timestamp
                         + N'} elapsed_time(s) {'
                         + cast(@elapsed as [sysname]) + N'}</p>'
                         + N'</details>
			</div>
		</log>';
      set @xml_builder.modify(N'insert sql:variable("@builder") as last into (/log/div/details)[1]');
      set @documentation = cast(@xml_builder as [nvarchar](max));
      set @stack.modify(N'insert sql:variable("@test_stack") as last into (/*/result)[1]');

      --
      -- load documentation into repository and create bcp extraction command
      -------------------------------------------
      begin
          declare @log_stack_prototype [xml]=[chamomile].[utility].[get_prototype](N'[chamomile].[log_stack].[stack].[prototype]'),
                  @log_prototype       [xml]=[chamomile].[utility].[get_prototype](N'[chamomile].[log].[stack].[prototype]'),
                  @description         [nvarchar](max) = [chamomile].[utility].[get_meta_data](N'[master].[dbo].[sp_get_best_practice_analysis]');

          set @log_prototype.modify(N'replace value of (/log/@timestamp)[1] with sql:variable("@timestamp")');
          set @log_prototype.modify(N'replace value of (/log/description/text())[1] with sql:variable("@description")');
          set @log_prototype.modify(N'insert sql:variable("@xml_builder") as last into (/log)[1]');

          --
          -------------------------------------------
          execute [chamomile].[utility].[set_log]
            @object_fqn = @object_fqn,
            @log = @log_prototype,
            @sequence = 1,
            @description =N'best practice analysis documentation',
            @stack = @stack output;

          --
          -------------------------------------------
          if @timestamp_output = 1
            set @message = N'_' + @stripped_timestamp;
          else
            set @message = N'';

          --
          -------------------------------------------
          set @bcp_command = N'BCP "select [documentation].[get_formatted_html]([utility].[get_log] ('''
                             + @object_fqn + N'''));" queryout '
                             + @subject_fqn + '_' + @object_fqn + @message
                             + N'.html' + N' -t, -T -c -d ' + db_name()
                             + N' -S ' + @server + N';';
      end;
  end;

go

--
-------------------------------------------------
exec [sp_ms_marksystemobject]
  N'sp_get_best_practice_analysis';

go

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn = N'[master].[dbo].[sp_get_best_practice_analysis]',
  @value =N'[chamomile] [best_practice_analysis] engine.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn = N'[master].[dbo].[sp_get_best_practice_analysis].[missing_table_documentation_violation]',
  @value =N'all tables must have documentation in extended properties including "description", "package", and "revision".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[missing_table_documentation_violation]',
  @value =N'all tables must have documentation in extended properties including "description", "package", and "revision".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[missing_column_documentation_violation]',
  @value =N'all columns must have documentation in extended properties including "description".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[missing_procedure_documentation_violation]',
  @value =N'all procedures must have documentation in extended properties including "description", "package", "execute_as", "license", and "revision".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[missing_parameter_documentation_violation]',
  @value =N'all parameters must have documentation in extended properties including "description".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[default_constraint_naming_violation]',
  @value =N'default constraints must be named as "[{schema}.{object}.{column_list}.default]".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[unique_constraint_naming_violation]',
  @value =N'unique constraints must be named as "[{schema}.{object}.{column_list}.unique]".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[primary_key_naming_violation]',
  @value =N'primary_keys must be named as "[{schema}.{object}.{column_list}.primary_key]", or "[{schema}.{object}.{column_list}.clustered_primary_key]".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[identity_column_naming_violation]',
  @value =N'identity_columns must be named as "[{schema}.{object}.id.identity]".',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[no_primary_key_violation]',
  @value =N'all tables must include a primary key.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[no_unit_test_violation]',
  @value =N'all methods must have at least one unit test.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[no_unique_constraint_violation]',
  @value =N'all tables must include a unique constraint unless identified as "olap" and the primary key is not either an identity or default newsequentialid().',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[composite_primary_key_violation]',
  @value =N'only tables identified as "olap" may have a composite primary key.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[todo_violation]',
  @value =N'objects promoted to production may not have any remaining "todo" items.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[no_identity_column_violation]',
  @value =N'all tables identified as "oltp" must include an identity column or default newsequentialid().',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[unused_table_warning]',
  @value =N'tables with zero record count should be considered for deprecation. this warning will be thrown on initial creation of a table and prior to population and may be ignored.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[low_row_count_table_warning]',
  @value =N'tables with record count of less than five items should be considered for deprecation and column constraints used instead.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
execute [chamomile].[utility].[set_meta_data]
  @object_fqn =N'[master].[dbo].[sp_get_best_practice_analysis].[unused_query_warning]',
  @value =N'unused queries should be considered for deprecation.',
  @description =N'documentation for best practice analysis engine';

--
-------------------------------------------------
if exists (select *
           from   ::fn_listextendedproperty(N'release_00.93.00'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_get_best_practice_analysis'
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.93.00',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_get_best_practice_analysis',
    @level2type=null,
    @level2name=null;

go

exec sys.sp_addextendedproperty
  @name =N'release_00.93.00',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_get_best_practice_analysis',
  @level2type=null,
  @level2name=null;

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'procedure'
                                            , N'sp_get_best_practice_analysis'
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'procedure',
    @level1name=N'sp_get_best_practice_analysis',
    @level2type=null,
    @level2name=null;

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [chamomile].[utility].[get_meta_data](null, N''[chamomile].[documentation].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'procedure',
  @level1name=N'sp_get_best_practice_analysis',
  @level2type=null,
  @level2name=null;

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140723'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_get_best_practice_analysis'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140723',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_get_best_practice_analysis'

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140723',
  @value =N'Katherine E. Lightsey - Created.',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_get_best_practice_analysis';

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_best_practice_analysis'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_get_best_practice_analysis'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_best_practice_analysis',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_get_best_practice_analysis';

go

exec sys.sp_addextendedproperty
  @name =N'package_best_practice_analysis',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_get_best_practice_analysis';

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_get_best_practice_analysis'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_get_best_practice_analysis';

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value = N'use [chamomile];
    go
    declare @bcp_command     [nvarchar](max), @documentation [nvarchar](max), @stack [xml];
    execute [dbo].[sp_get_best_practice_analysis]
      @object_fqn              =N''[utility].[set_log]''
      , @status                =N''force_refresh''
      , @timestamp_output      = 0
      , @stack                 = @stack output
      , @bcp_command           =@bcp_command output
      , @documentation         =@documentation output;
    select @bcp_command     as N''@bcp_command'', @documentation as N''@documentation'', @stack as N''@stack''; ',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_get_best_practice_analysis'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_get_best_practice_analysis'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_get_best_practice_analysis';

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'<details class="summary">
				<summary>[master].[dbo].[sp_get_best_practice_analysis]</summary><ol>
			<p>Analyzes the current database for error of best practice. Best practice evalutions include:</p>
				<ol>
						<li>[naming_error] - The object does conform to standard naming convention.
						<li>[no_primary_key_violation - The table does not include a primary key.
						<li>[composite_primary_key_violation - The table uses a composite primary key. This typically indicateds that the key is a composite natural key. Recommend;ed practice is to use a surrogate individual primary key on OLTP tables, only using a natural or composite natural primary key on OLAP tables.
						<li>[no_identity_column_violation - The table does not include an identity column. All OLTP tables should include an identity column of either type [int] or [bigint].
						<li>[no_unique_constraint_violation - The table does not include a unique index. All tables must include a unique index which defines the uniqueness of the table.

				</ol>
			<p>Objects evaluated include:</p>
				<ol>
					<li>[DEFAULT_CONSTRAINT - </li>
					<li>[FOREIGN_KEY_CONSTRAINT - </li>
					<li>[PRIMARY_KEY_CONSTRAINT -</li>
					<li>[IDENTITY_COLUMN - </li>
					<li>[SQL_SCALAR_FUNCTION -</li>
					<li>[SQL_STORED_PROCEDURE -</li>
					<li>[SQL_TRIGGER -</li>
					<li>[UNIQUE_CONSTRAINT -</li>
					<li>[USER_TABLE - </li>
				</ol></details>',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_get_best_practice_analysis';

go

if exists (select *
           from   ::fn_listextendedproperty(N'todo'
                                            , N'SCHEMA'
                                            , N'dbo'
                                            , N'PROCEDURE'
                                            , N'sp_get_best_practice_analysis'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'todo',
    @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'PROCEDURE',
    @level1name=N'sp_get_best_practice_analysis';

exec sys.sp_addextendedproperty
  @name =N'todo',
  @value =N'<details class="summary">
				<summary>[todo]</summary><ol>
				<ol>
					<li>Check databases to ensure that no files are being stored on the c: drive.</li>
					<li>Add documentation checks for:
						<ol>
							<li>functions and function parameters.</li>
							<li>views and view columns.</li>
							<li>indexes.</li>
						</ol>
					<li>Check for constraints on columns - columns should have constraints by default.</li>
					<li>Check for auditing columns on tables.</li>
					<li>Pass in patterns for naming error checks.</li>
					<li>Exclude xml tables from [no_unique_constraint_violation].</li>
					<li>Check for [newsequentialid] for [no_identity_column_violation].</li>
					<li>Output bcp command similar to [master].[dbo].[sp_create_extended_properties].</li>
					<li>List "todo".</li>
					<li>include "execute [repository].[set] @id=@id, @delete=1" in bcp command.</li>
					<li>Pass in object and schema to allow analysis of granular objects.</li>
					<li>procedures and functions must have existing unit_test.</li>
				</ol>',
  @level0type=N'SCHEMA',
  @level0name=N'dbo',
  @level1type=N'PROCEDURE',
  @level1name=N'sp_get_best_practice_analysis'

go 
