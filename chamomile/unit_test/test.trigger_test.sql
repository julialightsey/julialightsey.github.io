use [chamomile];

go

if schema_id(N'test_test') is null
  execute (N'create schema test_test');

go

if object_id(N'[test_test].[trigger_test]'
             , N'P') is not null
  drop procedure [test_test].[trigger_test];

go

/*
	declare @stack [xml];
	execute [test_test].[trigger_test] @stack=@stack output;
	select @stack;
*/
create procedure [test_test].[trigger_test] @stack xml([chamomile].[xsc]) = null output
as
  begin
      declare @test_stack_prototype    [nvarchar](max)= N'[chamomile].[test].[test_stack].[stack].[prototype]',
              @test_prototype          [nvarchar](max) = N'[chamomile].[test].[test].[stack].[prototype]',
              @chamomile_xsc_prototype [nvarchar](max)= N'[chamomile].[xsc].[stack].[prototype]';
      declare @test_stack             [xml] = [utility].[get_prototype](@test_stack_prototype),
              @stack_builder          [xml] = [utility].[get_prototype](@chamomile_xsc_prototype),
              @pass                   [sysname] = [utility].[get_meta_data](N'[chamomile].[constant].[result].[default].[pass]'),
              @fail                   [sysname] = [utility].[get_meta_data](N'[chamomile].[constant].[result].[default].[fail]'),
              @test_builder           [xml],
              @test_sequence          [int] = 0,
              @test_name              [nvarchar](max),
              @subject_fqn            [sysname],
              @object_fqn             [sysname] = N'[test].[trigger_test]',
              @object_fqn_description [nvarchar](max) = N'business method',
              @count                  [int] = 1,
              @application_message    [xml],
              @builder                [xml],
              @expected               [nvarchar](max),
              @timestamp              [sysname] = convert([sysname], current_timestamp, 126),
              @message                [nvarchar](max);

      --
      ---------------------------
      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      set @subject_fqn = @builder.value(N'(/*/fqn/@fqn)[1]'
                                        , N'[nvarchar](1000)');
      set @message = N'built by {' + @subject_fqn + N'}';
      --
      set @stack_builder.modify(N'replace value of (/*/subject/@fqn)[1] with sql:variable("@subject_fqn")');

      --
      --
      -------------------------------------------
      begin
          select @test_sequence = 1
                 , @test_name = @object_fqn + N'.[get_object_fqn]'
                 , @expected = @object_fqn
                 , @message = N'the tested method should return it''s own subject_fqn and it should be equal to the @object_fqn in the test.';

          --
          set @test_builder = [utility].[get_prototype](@test_prototype);
          set @test_builder.modify(N'replace value of (/*/@expected)[1] with sql:variable("@pass")');
          set @test_builder.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@test_name")');
          set @test_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
          set @test_builder.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@object_fqn")');
          set @test_builder.modify(N'replace value of (/*/description/text())[1] with sql:variable("@message")');
          set @test_builder.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@object_fqn_description")');

          begin try
              if object_id(N'[test].[trigger_test]'
                           , N'P') is not null
                begin
                    if object_id(N'[test].[trigger_test]'
                                 , N'P') is not null
                      execute [test].[trigger_test]
                        @subject_fqn=@subject_fqn output;

                    --
                    set @builder = N'<subject_fqn />'
                    set @builder.modify(N'insert text {sql:variable("@subject_fqn")} as last into (/*)[1]');
                    set @test_builder.modify(N'insert sql:variable("@builder") as last into (/*/result)[1]');

                    --
                    if @subject_fqn = N'[test].[trigger_test]'
                      begin
                          set @test_builder.modify(N'replace value of (/*/object/@fqn)[1] with sql:variable("@subject_fqn")');
                          set @test_builder.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                      end;
                end;
          end try

          begin catch
              select error_message();

              select @message = error_message()
                     , @application_message = N'<application_message><error_message /></application_message>';

              set @application_message.modify(N'replace value of (/application_message/error_message/text())[1] with sql:variable("@message")');
              set @stack_builder.modify(N'insert sql:variable("@application_message") as last into (/*/result)[1]');
          end catch;

          set @test_stack.modify(N'insert sql:variable("@test_builder") as last into (/*)[1]');
      end;

      --
      -------------------------------------------
      set @count = @test_stack.value(N'count (//test)'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (//test[@actual="pass"])'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      set @count = @test_stack.value(N'count (/*/test[@actual="fail"])'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      set @stack_builder.modify(N'insert sql:variable("@test_stack") as last into (/*/object)[1]');
      set @stack = @stack_builder;
  end;

go

if schema_id(N'test') is null
  execute (N'create schema test');

go

if object_id(N'[test].[trigger_test]'
             , N'P') is not null
  drop procedure [test].[trigger_test];

go

/*
	select * from [utility].[get_log_list](N'[chamomile].[lock_test].[result].[test_test].[trigger_test]');

	declare @subject_fqn [sysname];
	execute [test].[trigger_test] @subject_fqn=@subject_fqn output;
	select @subject_fqn as N'@subject_fqn';
*/
create procedure [test].[trigger_test] @subject_fqn [sysname] output
as
  begin
      set @subject_fqn = (select N'[' + object_schema_name(@@procid) + N'].['
                                 + object_name(@@procid) + N']');
  end;

go

--
alter procedure [test].[trigger_test] @subject_fqn [sysname] output
as
  begin
      set @subject_fqn = (select N'[' + object_schema_name(@@procid) + N'].['
                                 + object_name(@@procid) + N']');
  end;

go

--
alter procedure [test].[trigger_test] @subject_fqn [sysname] output
as
  begin
      set @subject_fqn = (select N'[invalid_name]');
  end;

go 
