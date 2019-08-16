/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
    -- to view documentation
    ---------------------------------------------
    declare @schema   [sysname]=N'utility_test'
            , @object [sysname]=N'handle_error';
    select [schemas].[name]                as [schema]
           , [procedures].[name]           as [object]
           , [extended_properties].[name]  as [property]
           , [extended_properties].[value] as [value]
    from   [sys].[extended_properties] as [extended_properties]
           join [sys].[procedures] as [procedures]
             on [procedures].[object_id]=[extended_properties].[major_id]
           join [sys].[schemas] as [schemas]
             on [procedures].[schema_id]=[schemas].[schema_id]
    where  [schemas].[name]=@schema
           and [procedures].[name]=@object; 
*/
use [chamomile];

go

if schema_id(N'utility_test') is null
  execute (N'create schema utility_test');

go

if object_id(N'[utility_test].[handle_error]'
             , N'P') is not null
  drop procedure [utility_test].[handle_error];

go

create procedure [utility_test].[handle_error] @stack         xml ([chamomile].[xsc]) output
                                               , @error_stack xml ([chamomile].[xsc])=null output
as
  begin
      set nocount on;
      set transaction isolation level serializable;

      --
      -------------------------------------------
      declare @application_message      [xml],
              @test_name                [sysname],
              @test_description         [nvarchar](max),
              @test_object_description  [nvarchar](max),
              @expected_result          [nvarchar](max),
              @return_code              [int],
              @sequence                 [int],
              @count                    [int],
              @error                    [xml],
              @server_information       [xml],
              @builder                  [xml],
              @actual                   [sysname],
              @name                     [nvarchar](1000),
              @subject_fqn              [nvarchar](1000),
              @object_fqn               [nvarchar](1000),
              @message                  [nvarchar](max),
              @timestamp                [sysname]=convert([sysname], current_timestamp, 126)
              --
              -- begin modify - insert text appropriate to your method
              -----------------------------------
              ,
              @stack_description        [nvarchar](max)=N'{replace with method specific text} the stack of all objects, tests, and results within this method.',
              @test_stack_description   [nvarchar](max)=N'{replace with method specific text} the stack of all tests executed within this method, along with counts of all tests and results.',
              @stack_result_description [nvarchar](max)=N'{replace with method specific text} individual results are contained within the tests. No aggregate result is expected for this stack.'
              -----------------------------------
              -- end modify
              --
              --
              -- create unique transaction name, must be 32 characters or less
              -- todo - necessary for parallel operations?
              -----------------------------------
              ,
              @transaction              [nvarchar](32);

      --
      ---------------------------------------
      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@server_information output;

      set @subject_fqn=@server_information.value(N'(/*/fqn/@fqn)[1]'
                                                 , N'[nvarchar](1000)');
      set @object_fqn=@server_information.value(N'(/*/fqn_prefix/@fqn)[1]'
                                                , N'[nvarchar](1000)');

      --
      -- meta data and prototype names, used both to get meta data and messages and in error messages (raiserror)
      -------------------------------------------
      --
      -- begin modify - declare and initialize prototypes and meta data appropriate to your method
      -------------------------------------------
      declare @pass_meta_data        [nvarchar](1000)=N'[chamomile].[constant].[result].[default].[pass]',
              @fail_meta_data        [nvarchar](1000)=N'[chamomile].[constant].[result].[default].[fail]',
              @meta_data_not_found   [nvarchar](1000)=N'[chamomile].[return_code].[meta_data_not_found]',
              @test_stack_prototype  [nvarchar](1000)=N'[chamomile].[test].[test_stack].[stack].[prototype]',
              @data_stack_prototype  [nvarchar](1000)=N'[chamomile].[data].[stack].[prototype]',
              @utility_xsc_prototype [nvarchar](1000)=N'[chamomile].[xsc].[stack].[prototype]',
              @test_prototype        [nvarchar](1000)=N'[chamomile].[test].[test].[stack].[prototype]',
              @error_stack_prototype [nvarchar](1000)=N'[chamomile].[error_stack].[stack].[prototype]',
              @error_prototype       [nvarchar](1000)=N'[chamomile].[error].[stack].[prototype]',
              @prototype_not_found   [nvarchar](1000)=N'[chamomile].[return_code].[prototype_not_found]';
      --
      -- initialize meta data and prototypes
      -------------------------------------------
      declare @pass                [sysname]=[utility].[get_meta_data](@pass_meta_data),
              @fail                [sysname]=[utility].[get_meta_data](@fail_meta_data),
              @test                [xml]=( [utility].[get_prototype](@test_prototype) ),
              @stack_builder       [xml]=( [utility].[get_prototype](@utility_xsc_prototype) ),
              @test_stack          [xml]=( [utility].[get_prototype](@test_stack_prototype) ),
              @error_stack_builder [xml]=( [utility].[get_prototype](@utility_xsc_prototype) ),
              @data_stack          [xml]=( [utility].[get_prototype](@data_stack_prototype) ),
              @builder_01          [xml]=( [utility].[get_prototype](@utility_xsc_prototype) );

      set @builder =[utility].[get_prototype](@error_stack_prototype);
      -------------------------------------------
      -- end modify
      --
      --
      -- initialize the error stack
      -------------------------------------------
      set @error_stack=isnull(@error_stack
                              , ( [utility].[get_prototype](@utility_xsc_prototype) ));
      set @error_stack.modify(N'insert sql:variable("@builder") as last into (/*/result)[1]');

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
                   from   ( values (@pass,
                          @pass_meta_data),
                                   (@fail,
                          @fail_meta_data),
                                   (cast(@test as [nvarchar](max)),
                          @test_prototype),
                                   (cast(@stack_builder as [nvarchar](max)),
                          @utility_xsc_prototype),
                                   (cast(@test_stack as [nvarchar](max)),
                          @test_stack_prototype),
                                   (cast(@error_stack_builder as [nvarchar](max)),
                          @utility_xsc_prototype),
                                   (cast(@data_stack as [nvarchar](max)),
                          @data_stack_prototype),
                                   (cast(@builder_01 as [nvarchar](max)),
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
      -------------------------------------------
      set @test_stack.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@subject_fqn")');
      set @test_stack.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_stack_description")');
      set @test_stack.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
      --
      -------------------------------------------
      set @stack_builder.modify(N'replace value of (/*/subject/@fqn)[1] with sql:variable("@subject_fqn")');
      set @stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
      set @stack_builder.modify(N'replace value of (/*/result/description/text())[1] with sql:variable("@stack_result_description")');
      set @stack_builder.modify(N'replace value of (/*/subject/description/text())[1] with sql:variable("@stack_description")');

      --
      -------------------------------------------
      begin
          --
          -------------------------------------------
          begin
              --
              -- begin modify - todo
              -----------------------------------
              --
              -- @sequence is hand coded rather than incremented programmatically so that the developer can easily refer
              --	to the @sequence value when trying to match the output @stack to the code.
              -----------------------------------
              set @sequence=1;
              --
              -- the test name should be the full subject name plus specific test name designator. this is not required
              --	but it makes the code easier to trace.
              -----------------------------------
              set @test_name = @subject_fqn + N'.[build_single_error]';
              set @expected_result=N'The call will pass with no exception or error thrown.';
              --
              -- the test description should be sufficient to describe what is being accomplished without referring to the code.
              -----------------------------------
              set @test_description=N'{replace with text appropriate to this test} test for correct handling of a single error within a method. a single error is thrown and put on the stack.';
              -----------------------------------
              -- end modify
              --
              --
              -----------------------------------
              set @test= [utility].[get_prototype] (@test_prototype);
              set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
              set @test.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@test_name")');
              set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');
              --
              -- a randomized transaction name is used to avoid issues in parallel processing (-- todo - is this necessary?)
              --	the transaction prefix should be a descriptive name of the overall method sufficient to allow it to be 
              --	understood on inspection of [sys].[dm_tran_active_transactions]. The maximum length for transaction names 
              --	is 32 characters. system  message 100067 states that the method could not process due to an existing 
              --	transaction. the @subject_fqn is passed in for information.
              ---------------------------------------
              set @transaction=N'handle_error_test_'
                               + cast(round(rand()*100000, -1) as [sysname])
                               + N'_'
                               + cast(datepart(millisecond, current_timestamp) as [sysname]);

              --if ( @@trancount ) = 0
              begin transaction @transaction;

          /* else
             begin
                 select *
                 from   [sys].[dm_tran_active_transactions];
                 set @message=@subject_fqn;
          raiserror (100067,1,1,@message);
          return 100067;
          end;*/
              --
              -----------------------------------
              begin try
                  --
                  -- begin modify - define your test
                  -------------------------------
                  set @count=(select 1 / 0);
              -------------------------------
              -- end modify
              --
              end try

              begin catch
                  --
                  -- an application message with information about the test where the failure occurs should be created to facilitate error diagnosis.
                  -------------------------------
                  set @application_message=N'<application_message sequence="'
                                           + cast(@sequence as [sysname])
                                           + N'" test_name="' + @test_name
                                           + N'"><description>' + @test_description
                                           + N'</description>
					</application_message>';

                  --
                  -- [utility].[handle_error] takes @@procid so that the schema for the calling object may be determined. @application_message is
                  --	optional, but adds value to the error stack. @stack is required, but may be null. If null, a default stack will be built
                  --	and passed back in.
                  -----------------------------------
                  execute @return_code = [utility].[handle_error]
                    @procedure_id =@@procid,
                    @application_message=@application_message,
                    @stack =@error_stack_builder output;

                  set @test.modify(N'insert sql:variable("@error_stack_builder") as last into (/*/result)[1]');
              -- if @return_code != 0 throw;
              end catch;

              --
              -- if there are errors, this test passes as it was intended to generate an error. there should be only one error.
              -----------------------------------
              if @error_stack_builder.value(N'count(//error)'
                                            , N'[int]') = 1
                set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

              --
              -- the @test is added to the @test_stack
              -----------------------------------
              set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');

              --
              -- [sys].[dm_tran_active_transactions] is checked so that an error doesn't occur, and only the named transaction is rolled back.
              -------------------------------
              if exists (select *
                         from   [sys].[dm_tran_active_transactions]
                         where  [name] = @transaction)
                rollback transaction @transaction;
          end;

          --
          -------------------------------------------
          begin
              set @sequence=2;
              set @test_name = @subject_fqn + N'.[build_double_error]';
              set @expected_result=N'The call will pass with no exception or error thrown.';
              set @test_description=N'{replace with text appropriate to this test} test for correct handling of a multiple errors within a method. two errors are thrown and added to the stack.';
              --
              -----------------------------------
              set @test= [utility].[get_prototype] (@test_prototype);
              set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
              set @test.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@test_name")');
              set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');
              --
              -- neither the object node nor the result node is not used for this test. other tests may have complex objects that are tested
              --	(such as when building @sql and @parameters for sp_executesql calls). these should be placed in the object node. complex
              --	result sets would then be placed in the result node for either manual or programmatic evaluation.
              -----------------------------------
              set @transaction=N'handle_error_test_'
                               + cast(round(rand()*100000, -1) as [sysname])
                               + N'_'
                               + cast(datepart(millisecond, current_timestamp) as [sysname]);

              -- if ( @@trancount ) = 0
              begin transaction @transaction;

          /* else
             begin
                 select *
                 from   [sys].[dm_tran_active_transactions];
                 set @message=@subject_fqn;
                 raiserror (100067,1,1,@message);
                 return 100067;
             end; */
              --
              ---------------------------------------
              begin try
                  set @count=cast (N'character string' as [int]);
              end try

              begin catch
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                  set @application_message=N'<application_message sequence="'
                                           + cast(@sequence as [sysname])
                                           + N'" test_name="' + @test_name
                                           + N'">
					</application_message>';

                  --
                  -----------------------------------
                  execute @return_code = [utility].[handle_error]
                    @procedure_id =@@procid,
                    @application_message=@application_message,
                    @stack =@error_stack_builder output;

                  set @test.modify(N'insert sql:variable("@error_stack_builder") as last into (/*/result)[1]');
              end catch;

              --
              ---------------------------------------
              begin try
                  set @count=1 / 0;
              end try

              begin catch
                  set @application_message=N'<application_message sequence="'
                                           + cast(@sequence as [sysname])
                                           + N'" test_name="' + @test_name
                                           + N'">
					</application_message>';

                  --
                  -----------------------------------
                  execute @return_code = [utility].[handle_error]
                    @procedure_id =@@procid,
                    @application_message=@application_message,
                    @stack =@error_stack_builder output;

                  set @test.modify(N'insert sql:variable("@error_stack_builder") as last into (/*/result)[1]');
              --if @return_code != 0 throw;
              end catch;

              if @error_stack_builder.value(N'count (/*/result/error)'
                                            , N'[int]') = 3
                set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

              set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');

              --
              -------------------------------
              if exists (select *
                         from   [sys].[dm_tran_active_transactions]
                         where  [name] = @transaction)
                rollback transaction @transaction;
          end;

          --
          -------------------------------------------
          begin
              set @sequence=3;
              set @test_name = @subject_fqn
                               + N'.[handle_null_error_stack]';
              set @expected_result=N'The call will pass with no exception or error thrown.';
              set @test_description=N'{replace with text appropriate to this test} test for correct handling of a null @error_stack passed to 
				the method, which should create a default stack. -- todo - target method should create appropriate descriptions.';
              set @error_stack_builder=null;
              --
              -----------------------------------
              set @test= [utility].[get_prototype] (@test_prototype);
              set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
              set @test.modify(N'replace value of (/*/@fqn)[1] with sql:variable("@test_name")');
              set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
              set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');
              --
              -- neither the object node nor the result node is not used for this test. other tests may have complex objects that are tested
              --	(such as when building @sql and @parameters for sp_executesql calls). these should be placed in the object node. complex
              --	result sets would then be placed in the result node for either manual or programmatic evaluation.
              -----------------------------------
              set @transaction=N'handle_error_test_'
                               + cast(round(rand()*100000, -1) as [sysname])
                               + N'_'
                               + cast(datepart(millisecond, current_timestamp) as [sysname]);

              --  if ( @@trancount ) = 0
              begin transaction @transaction;

          /* else
             begin
                 select *
                 from   [sys].[dm_tran_active_transactions];
                 set @message=@subject_fqn;
          raiserror (100067,1,1,@message);
          return 100067;
          end;*/
              --
              ---------------------------------------
              begin try
                  set @count=(select 1 / 0);
              end try

              begin catch
                  set @application_message=N'<application_message sequence="'
                                           + cast(@sequence as [sysname])
                                           + N'" test_name="' + @test_name
                                           + N'">
					</application_message>';

                  --
                  -----------------------------------
                  execute @return_code=[utility].[handle_error]
                    @procedure_id =@@procid,
                    @application_message=@application_message,
                    @stack =@error_stack_builder output;

                  --
                  set @test.modify(N'insert sql:variable("@error_stack_builder") as last into (/*/result)[1]');
              --
              --if @return_code != 0  throw;
              end catch;

              if @error_stack_builder.value(N'count (/*/result/error)'
                                            , N'[int]') = 1
                set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

              set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');

              --
              -----------------------------------
              if exists (select *
                         from   [sys].[dm_tran_active_transactions]
                         where  [name] = @transaction)
                rollback transaction @transaction;
          end;
      end;

      --
      -- build totals
      -------------------------------------------
      begin
          --
          -------------------------------------------
          set @builder=@error_stack;
          set @builder.modify(N'insert sql:variable("@error_stack_builder") as last into (/*/result/error_stack)[1]');
          set @count=@builder.value(N'count (/*/result/error_stack/*/result/error)'
                                    , N'[int]');

          if @count > 0
            begin
                set @builder.modify(N'replace value of (/*/result/error_stack/@error_count)[1] with sql:variable("@count")');
                set @error_stack=@builder;
            end;
          else
            --
            -- set @error_stack to null if there are no errors so programmatic testing can test for 
            --	"if @error_stack is not null" rather than have to parse the @error_stack tree and count errors
            -----------------------------------------------
            set @error_stack=null;

          --
          -------------------------------------------
          set @count=@test_stack.value(N'count (/*/test)'
                                       , N'[int]');
          set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
          set @count=@test_stack.value(N'count (/*/test[@actual="pass"])'
                                       , N'[int]');
          set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
          set @count=@test_stack.value(N'count (/*/test[@actual="fail"])'
                                       , N'[int]');
          set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      end;

      --
      -------------------------------------------
      set @stack_builder.modify(N'insert sql:variable("@test_stack") as last into (/*/object)[1]');
      set @stack=@stack_builder;

      return 0;
  end;

go

if exists (select *
           from   ::fn_listextendedproperty(N'test_object_utility_handle_error'
                                            , N'SCHEMA'
                                            , N'utility_test'
                                            , N'PROCEDURE'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'test_object_utility_handle_error',
    @level0type=N'SCHEMA',
    @level0name=N'utility_test',
    @level1type=N'PROCEDURE',
    @level1name=N'handle_error'

go

exec sys.sp_addextendedproperty
  @name =N'test_object_utility_handle_error',
  @value =N'[utility].[handle_error];',
  @level0type=N'SCHEMA',
  @level0name=N'utility_test',
  @level1type=N'PROCEDURE',
  @level1name=N'handle_error'

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , N'SCHEMA'
                                            , N'utility_test'
                                            , N'PROCEDURE'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=N'SCHEMA',
    @level0name=N'utility_test',
    @level1type=N'PROCEDURE',
    @level1name=N'handle_error'

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](N''[chamomile].[license]'');',
  @level0type=N'SCHEMA',
  @level0name=N'utility_test',
  @level1type=N'PROCEDURE',
  @level1name=N'handle_error'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'SCHEMA'
                                            , N'utility_test'
                                            , N'PROCEDURE'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'SCHEMA',
    @level0name=N'utility_test',
    @level1type=N'PROCEDURE',
    @level1name=N'handle_error'

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'Unit tests for [utility].[handle_error]',
  @level0type=N'SCHEMA',
  @level0name=N'utility_test',
  @level1type=N'PROCEDURE',
  @level1name=N'handle_error'

go

if exists (select *
           from   ::fn_listextendedproperty(N'execute_as'
                                            , N'SCHEMA'
                                            , N'utility_test'
                                            , N'PROCEDURE'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'execute_as',
    @level0type=N'SCHEMA',
    @level0name=N'utility_test',
    @level1type=N'PROCEDURE',
    @level1name=N'handle_error'

go

exec sys.sp_addextendedproperty
  @name =N'execute_as',
  @value =N'declare @stack         xml
        , @error_stack [xml]
        , @return_code [int];
execute @return_code = [utility_test].[handle_error]
  @stack        =@stack output;
select @stack         as N''@stack from [utility_test].[handle_error]''
       , @error_stack as N''@error_stack''
       , @return_code as N''@return_code'';',
  @level0type=N'SCHEMA',
  @level0name=N'utility_test',
  @level1type=N'PROCEDURE',
  @level1name=N'handle_error'

go

if exists (select *
           from   ::fn_listextendedproperty(N'revision_20140715'
                                            , N'SCHEMA'
                                            , N'utility_test'
                                            , N'PROCEDURE'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'revision_20140715',
    @level0type=N'SCHEMA',
    @level0name=N'utility_test',
    @level1type=N'PROCEDURE',
    @level1name=N'handle_error'

go

exec sys.sp_addextendedproperty
  @name =N'revision_20140715',
  @value =N'Katherine E. Lightsey - created.',
  @level0type=N'SCHEMA',
  @level0name=N'utility_test',
  @level1type=N'PROCEDURE',
  @level1name=N'handle_error'

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_basic'
                                            , N'SCHEMA'
                                            , N'utility_test'
                                            , N'PROCEDURE'
                                            , N'handle_error'
                                            , null
                                            , null))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_basic',
    @level0type=N'SCHEMA',
    @level0name=N'utility_test',
    @level1type=N'PROCEDURE',
    @level1name=N'handle_error'

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_basic',
  @value =N'',
  @level0type=N'SCHEMA',
  @level0name=N'utility_test',
  @level1type=N'PROCEDURE',
  @level1name=N'handle_error'

go

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'utility_test'
                                            , N'procedure'
                                            , N'handle_error'
                                            , N'parameter'
                                            , N'@stack'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'utility_test',
    @level1type=N'procedure',
    @level1name=N'handle_error',
    @level2type=N'parameter',
    @level2name=N'@stack';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N' @stack xml ([chamomile].[xsc]) output - output of test.',
  @level0type=N'schema',
  @level0name=N'utility_test',
  @level1type=N'procedure',
  @level1name=N'handle_error',
  @level2type=N'parameter',
  @level2name=N'@stack';

if exists (select *
           from   ::fn_listextendedproperty(N'description'
                                            , N'schema'
                                            , N'utility_test'
                                            , N'procedure'
                                            , N'handle_error'
                                            , N'parameter'
                                            , N'@error_stack'))
  exec sys.sp_dropextendedproperty
    @name =N'description',
    @level0type=N'schema',
    @level0name=N'utility_test',
    @level1type=N'procedure',
    @level1name=N'handle_error',
    @level2type=N'parameter',
    @level2name=N'@error_stack';

go

exec sys.sp_addextendedproperty
  @name =N'description',
  @value =N'@error_stack xml ([chamomile].[xsc])=null output - optional; output of error stack - expected to have results due to the internal testing mechanism.',
  @level0type=N'schema',
  @level0name=N'utility_test',
  @level1type=N'procedure',
  @level1name=N'handle_error',
  @level2type=N'parameter',
  @level2name=N'@error_stack'; 
