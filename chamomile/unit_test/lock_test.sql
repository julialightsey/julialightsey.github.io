/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ----------------------------------------------------------------------
    declare @schema   [sysname] = N''
            , @object [sysname] = N'';
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
use [chamomile];

go

if exists (select *
           from   sys.triggers
           where  parent_class = 0
                  and name = 'lock_test')
  drop trigger [lock_test] on database;

go

create trigger [lock_test]
on database
after alter_function, drop_function, alter_procedure, drop_procedure, alter_table, drop_table
as
  begin
      declare @log_entry_prototype [nvarchar](max) = N'[chamomile].[log_stack].[stack].[prototype]',
              @log_prototype       [nvarchar](max) = N'[chamomile].[log].[stack].[prototype]';
      declare @test_stack                 [xml] = [utility].[get_prototype](N'[chamomile].[xsc].[stack].[prototype]'),
              @command_stack              [xml] = [utility].[get_prototype](N'[chamomile].[command_stack].[stack].[prototype]'),
              @command                    [xml] = [utility].[get_prototype](N'[chamomile].[command].[stack].[prototype]'),
              @default_test_schema_suffix [sysname] = [utility].[get_meta_data](N'[chamomile].[constant].[test].[default].[suffix]'),
              @description                [nvarchar](max) = N'programmatic test',
              @schema                     [sysname],
              @object                     [sysname],
              @log                        [xml]=[utility].[get_prototype](@log_prototype),
              @test_schema                [sysname],
              @object_fqn                 [nvarchar](max),
              @event_data                 [xml]=eventdata(),
              @stack                      [xml],
              @error_count                [int],
              @message                    [nvarchar](max);

      --
      select @schema = @event_data.value(N'(/EVENT_INSTANCE/SchemaName/text())[1]'
                                         , N'[sysname]')
             , @object = @event_data.value(N'(/EVENT_INSTANCE/ObjectName/text())[1]'
                                           , N'[sysname]');

      select @test_schema = @schema + @default_test_schema_suffix;

      select @object_fqn = N'[' + @test_schema + N'].[' + @object + N']';

      --
      set @command.modify(N'replace value of (/*/description/text())[1] with sql:variable("@description")');
      set @command.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@object_fqn")');
      --
      set @command_stack.modify(N'replace value of (/*/description/text())[1] with sql:variable("@description")');
      set @command_stack.modify(N'insert sql:variable("@command") as last into (/*)[1]');
      --
      set @test_stack.modify(N'replace value of (/*/subject/description/text())[1] with sql:variable("@description")');
      set @test_stack.modify(N'insert sql:variable("@command_stack") as last into (/*/object)[1]');

      --
      if object_id(N'[test].[run]'
                   , N'P') is not null
        begin
            execute [test].[run]
              @stack=@test_stack output;

            --
            select @error_count = @test_stack.value(N'(//test_suite/@error_count)[1]'
                                                    , N'[int]');

            if @error_count > 0
                or @error_count is null
              rollback;

            --
            set @object_fqn = N'[chamomile].[lock_test].[result].'
                              + @object_fqn;
            set @message = N'error_count greater than 0 caused trigger to rollback for object_fqn('
                           + @object_fqn + N')';
            set @log.modify(N'replace value of (/log/@fqn)[1] with sql:variable("@object_fqn")');
            set @log.modify(N'insert sql:variable("@test_stack") as last into (/*)[1]');
            set @log.modify(N'replace value of (/log/description/text())[1] with sql:variable("@message")');

            --
            execute [utility].[set_log]
              @object_fqn = @object_fqn,
              @log = @log,
              @description = @description;
        end;
  end;

go 
