/*

	declare @stack         xml
            , @error_stack [xml];
    execute [unbreakable_code_test].[set_flower]
      @stack        =@stack output
      , @error_stack=@error_stack output;
    select @stack         as N'@stack from [unbreakable_code_test].[set_flower]'
           , @error_stack as N'@error_stack'; 
    




	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		A demonstration of the technique required to call a destructive method,
			one that inserts, updates, deletes, etc., from a unbreakable_code, with absolute
			certainly that the production state will be returned to it's state prior
			to the unbreakable_code.

			This allows unit unbreakable_codes to be run in production, allowing the goal of
			"unbreakable code" to be reached.

	--
	--	notes
	---------------------------------------------
		this unbreakable_code is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:

		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
	
	--
	-- references
	---------------------------------------------
		Unit testing - http://en.wikipedia.org/wiki/Unit_unbreakable_codeing
		test-driven development - http://en.wikipedia.org/wiki/unbreakable_code-driven_development
		White-box testing - http://en.wikipedia.org/wiki/White-box_unbreakable_codeing
		Black-box testing - http://en.wikipedia.org/wiki/Black-box_unbreakable_codein
	--
	-- to view documentation
	---------------------------------------------
	select [sch].[name]
		   , [prc].[name]
		   , [prop].[name]
		   , [prop].[value]
	from   [sys].[extended_properties] as [prop]
	join   [sys].[procedures] as [prc]
	  on [prc].[object_id] = [prop].[major_id]
	join   [sys].[schemas] as [sch]
	  on [prc].[schema_id] = [sch].[schema_id]
	where  [sch].[name] = N'unbreakable_code'
		   and [prc].[name] = N'set_flower'; 
*/
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'unbreakable_code_test') is null
  execute (N'create schema unbreakable_code_test');

go

if object_id(N'[unbreakable_code_test].[set_flower]'
             , N'P') is not null
  drop procedure [unbreakable_code_test].[set_flower];

go

-------------------------------------------------
-- code block end
--
create procedure [unbreakable_code_test].[set_flower] @stack         [xml] = null output
                                                      , @error_stack xml ([chamomile].[xsc]) output
as
  begin
      set nocount on;
      set transaction isolation level serializable;

      --
      -------------------------------------------
      declare @application_message             [xml],
              @test_name                       [sysname],
              @test_description                [nvarchar](max),
              @expected_result                 [nvarchar](max),
              @sequence                        [int],
              @count                           [int],
              @error                           [xml],
              @flower                          [sysname],
              @color                           [sysname],
              @sql                             [nvarchar](max),
              @parameters                      [nvarchar](max),
              @test_builder                    [xml],
              @return_code                     [int] = 0,
              @test_builder_result_description [nvarchar](max),
              @id                              [uniqueidentifier],
              @actual                          [sysname],
              @name                            [nvarchar](1000),
              @subject_fqn                     [nvarchar](1000),
              @description                     [nvarchar](max),
              @message                         [nvarchar](max),
              @expected                        [sysname],
              @builder                         [xml],
              @builder_02                      [xml];
      --
      -- meta data and prototype names, used both to get meta data and messages and in error messages (raiserror)
      -------------------------------------------
      declare @test_type_meta_data   [nvarchar](1000)= N'[chamomile].[test].[default].[test]',
              @pass_meta_data        [nvarchar](1000)= N'[chamomile].[result].[default].[pass]',
              @fail_meta_data        [nvarchar](1000)= N'[chamomile].[result].[default].[fail]',
              @existing_transaction  [nvarchar](1000)= N'[chamomile].[return_code].[existing_transaction]',
              @meta_data_not_found   [nvarchar](1000)= N'[chamomile].[return_code].[meta_data_not_found]'
              --
              -----------------------------------
              ,
              @test_stack_prototype  [nvarchar](1000)= N'[chamomile].[test_stack].[stack].[prototype]',
              @data_stack_prototype  [nvarchar](1000)= N'[chamomile].[data].[stack].[prototype]',
              @utility_xsc_prototype [nvarchar](1000)= N'[chamomile].[xsc].[stack].[prototype]',
              @test_prototype        [nvarchar](1000)= N'[chamomile].[test].[stack].[prototype]',
              @error_prototype       [nvarchar](1000)= N'[chamomile].[error].[stack].[prototype]',
              @prototype_not_found   [nvarchar](1000)= N'[chamomile].[return_code].[prototype_not_found]';
      --
      -------------------------------------------
      declare @test                         [xml] = (select [data]
                 from   [repository].[get] (null
                                            , @test_prototype)),
              @stack_builder                [xml] = (select [data].query(N'/*/*[2]')
                 from   [repository].[get](null
                                           , @utility_xsc_prototype)),
              @type                         [sysname] = [utility].[get_meta_data](@test_type_meta_data),
              @pass                         [sysname] = [utility].[get_meta_data](@pass_meta_data),
              @fail                         [sysname]= [utility].[get_meta_data](@fail_meta_data),
              @existing_transaction_message [nvarchar](max)= [utility].[get_meta_data](@existing_transaction),
              @test_stack                   [xml] = (select [data]
                 from   [repository].[get] (null
                                            , @test_stack_prototype)),
              @error_stack_builder          [xml] = (select [data].query(N'/*/*[2]')
                 from   [repository].[get](null
                                           , @utility_xsc_prototype)),
              @data_stack                   [xml] = (select [data]
                 from   [repository].[get] (null
                                            , @data_stack_prototype)),
              @builder_01                   [xml] = (select [data].query(N'/*/*[2]')
                 from   [repository].[get](null
                                           , @utility_xsc_prototype));

      --
      -------------------------------------------
      set @error_stack = (select [data].query(N'/*/*[2]')
                          from   [repository].[get](null
                                                    , @utility_xsc_prototype))

      --
      -------------------------------------------
      declare @test_object_description  [nvarchar](max) = N'the object that is constructed as a test.',
              @test_result_description  [nvarchar](max) = N'the result of the test on the test object.',
              @test_stack_description   [nvarchar](max) = N'the stack of all tests executed within this method, along with counts of all tests and results.',
              @timestamp                [sysname] = convert([sysname], current_timestamp, 126),
              @stack_result_description [nvarchar](max) = N'Individual results are contained within the tests. No aggregate result is expected for this stack.'
              --
              -- create unique transaction name, must be 32 characters or less
              -- todo - necessary for parallel operations?
              -----------------------------------
              ,
              @transaction              [nvarchar](32);

      --
      -------------------------------------------
      begin
          if @test is null
            raiserror (100066,1,1,@test_prototype);
          else if @builder_01 is null
            raiserror (100066,1,1,@utility_xsc_prototype);
          else if @test_stack is null
            raiserror (100066,1,1,@test_stack_prototype);
          else if @pass is null
            raiserror (100065,1,1,@pass_meta_data);
          else if @fail is null
            raiserror (100065,1,1,@fail_meta_data);
          else if @type is null
            raiserror (100065,1,1,@test_type_meta_data);
      end;

      --
      -------------------------------------------
      execute [sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder_01 output;

      set @subject_fqn = @builder_01.value(N'(/*/fqn/@name)[1]'
                                           , N'[nvarchar](1000)');
      --
      -------------------------------------------
      set @test_stack.modify(N'replace value of (/*/@name)[1] with sql:variable("@subject_fqn")');
      set @test_stack.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_stack_description")');
      set @test_stack.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
      --
      -------------------------------------------
      set @stack_builder.modify(N'replace value of (/*/subject/@name)[1] with sql:variable("@subject_fqn")');
      set @stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
      set @stack_builder.modify(N'replace value of (/*/result/description/text())[1] with sql:variable("@stack_result_description")');

      --
      -------------------------------------------
      begin
          --
          -------------------------------------------
          begin
              set @sequence=1;
              set @test_name = N'[chamomile].[presentation].[unbreakable_code_test].[insert_new_record]';
              set @expected_result = N'The call will pass with no exception or error thrown.';
              --
              -----------------------------------
              set @test = (select [data]
                           from   [repository].[get] (null
                                                      , @test_prototype))
              set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
              set @test.modify(N'replace value of (/*/@name)[1] with sql:variable("@test_name")');
              set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
              set @test_description = N'Call to inner method with no failure expected.';
              set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');
              --
              ---------------------------------------
              set @transaction = N'set_flower_test_'
                                 + cast(round(rand()*100000, -1) as [sysname])
                                 + N'_'
                                 + cast(datepart(millisecond, current_timestamp) as [sysname]);

              if ( @@trancount ) = 0
                begin
                    begin transaction @transaction;

                    select N'began transaction (' + @transaction
                           + N') ((' + object_schema_name(@@procid)
                           + N'].[' + + object_name(@@procid) + N'])';
                end;
              else
                begin
                    set @message = @subject_fqn;

                    throw 100067, @message, 1;
                end;

              --
              ---------------------------------------
              begin try
                  select @flower = N'rose_'
                                   + cast(round(rand()*100000, -1) as [sysname])
                                   + N'_'
                                   + cast(datepart(millisecond, current_timestamp) as [sysname])
                         , @color = N'green';

                  set @sql =N'execute [unbreakable_code].[set_flower] @flower=@flower, @color=@color, @error_stack=@error_stack_builder output';
                  set @parameters =N'@error_stack_builder [xml] output, @flower [sysname], @color [sysname]';

                  --
                  -----------------------------------
                  execute sp_executesql
                    @sql = @sql,
                    @parameters =@parameters,
                    @flower =@flower,
                    @color =@color,
                    @error_stack_builder =@error_stack_builder output;

                  if exists (select *
                             from   [unbreakable_code].[flower]
                             where  [flower] = @flower)
                    set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');

                  --
                  -------------------------------
                  select N'in process rollback transaction ('
                         + @transaction + N') (('
                         + object_schema_name(@@procid) + N'].[' +
                         + object_name(@@procid) + N'])';

                  if exists (select *
                             from   [sys].[dm_tran_active_transactions]
                             where  [name] = @transaction)
                    rollback transaction @transaction;
              end try

              begin catch
                  set @application_message = N'<application_message sequence="'
                                             + cast(@sequence as [sysname])
                                             + N'" test_name="' + @test_name
                                             + N'">
					</application_message>';

                  --
                  -----------------------------------
                  execute [utility].[handle_error]
                    @procedure_id = @@procid,
                    @application_message = @application_message,
                    @stack =@error_stack output;

                  set @test.modify(N'insert sql:variable("@application_message") as last into (/*)[1]');

                  --
                  -----------------------------------
                  select N'out of process rollback transaction ('
                         + @transaction + N') (('
                         + object_schema_name(@@procid) + N'].[' +
                         + object_name(@@procid) + N'])';

                  if exists (select *
                             from   [sys].[dm_tran_active_transactions]
                             where  [name] = @transaction)
                    rollback transaction @transaction;
              end catch;

              set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
          end;

          --
          --
          --
          --
          --
          -------------------------------------------
          begin
              set @sequence=2;
              set @test_name = N'[chamomile].[presentation].[unbreakable_code_test].[insert_duplicate_record]';
              set @expected_result = N'The call will pass with no exception or error thrown.';
              --
              -----------------------------------
              set @test = (select [data]
                           from   [repository].[get] (null
                                                      , @test_prototype))
              set @test.modify(N'replace value of (/*/@sequence)[1] with sql:variable("@sequence")');
              set @test.modify(N'replace value of (/*/@name)[1] with sql:variable("@test_name")');
              set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp")');
              set @test_description = N'Call to inner method with no failure expected.';
              set @test.modify(N'replace value of (/*/object/description/text())[1] with sql:variable("@test_description")');
              --
              ---------------------------------------
              set @transaction = N'set_flower_test_'
                                 + cast(round(rand()*100000, -1) as [sysname])
                                 + N'_'
                                 + cast(datepart(millisecond, current_timestamp) as [sysname]);

              if ( @@trancount ) = 0
                begin
                    begin transaction @transaction;

                    select N'began transaction (' + @transaction
                           + N') ((' + object_schema_name(@@procid)
                           + N'].[' + + object_name(@@procid) + N'])';
                end;
              else
                begin
                    set @message = @subject_fqn;

                    throw 100067, @message, 1;
                end;

              --
              ---------------------------------------
              begin try
                  select @flower = N'rose_'
                                   + cast(round(rand()*100000, -1) as [sysname])
                                   + N'_'
                                   + cast(datepart(millisecond, current_timestamp) as [sysname])
                         , @color = N'green';

                  set @sql =N'execute [unbreakable_code].[set_flower] @flower=@flower, @color=@color, @error_stack=@error_stack_builder output';
                  set @parameters =N'@error_stack_builder [xml] output, @flower [sysname], @color [sysname]';

                  --
                  -----------------------------------
                  execute sp_executesql
                    @sql = @sql,
                    @parameters =@parameters,
                    @flower =@flower,
                    @color =@color,
                    @error_stack_builder =@error_stack_builder output;

                  --
                  -- insert duplicate
                  -------------------------------
                  execute sp_executesql
                    @sql = @sql,
                    @parameters =@parameters,
                    @flower =@flower,
                    @color =@color,
                    @error_stack_builder =@error_stack_builder output;

                  --
                  -------------------------------
                  if @error_stack_builder is not null
                    begin
                        set @message = N'in test sequence=' + @sequence;

                        throw 100067, @message, 1;
                    end;

                  select N'in process rollback transaction ('
                         + @transaction + N') (('
                         + object_schema_name(@@procid) + N'].[' +
                         + object_name(@@procid) + N'])';

                  if exists (select *
                             from   [sys].[dm_tran_active_transactions]
                             where  [name] = @transaction)
                    rollback transaction @transaction;
              end try

              begin catch
                  set @test.modify(N'replace value of (/*/@actual)[1] with sql:variable("@pass")');
                  set @application_message = N'<application_message sequence="'
                                             + cast(@sequence as [sysname])
                                             + N'" test_name="' + @test_name
                                             + N'">
					</application_message>';

                  --
                  -----------------------------------
                  execute [utility].[handle_error]
                    @procedure_id = @@procid,
                    @application_message = @application_message,
                    @stack =@error_stack output;

                  set @test.modify(N'insert sql:variable("@application_message") as last into (/*)[1]');

                  --
                  -----------------------------------
                  select N'out of process rollback transaction ('
                         + @transaction + N') (('
                         + object_schema_name(@@procid) + N'].[' +
                         + object_name(@@procid) + N'])';

                  if exists (select *
                             from   [sys].[dm_tran_active_transactions]
                             where  [name] = @transaction)
                    rollback transaction @transaction;
              end catch;

              set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');
          end;
      end;

      --
      -- build totals
      -------------------------------------------
      --
      -------------------------------------------
      set @builder = @error_stack;
      set @builder.modify(N'insert sql:variable("@error_stack_builder") as last into (/*/result/error_stack)[1]');
      set @count = @builder.value(N'count (/*/result/error_stack/*/result/error)'
                                  , N'[int]');

      if @count > 0
        begin
            set @builder.modify(N'replace value of (/*/result/error_stack/@error_count)[1] with sql:variable("@count")');
            set @error_stack=@builder;
        end;
      else
        set @error_stack = null;

      --
      -------------------------------------------
      set @count = @test_stack.value(N'count (/*/test)'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
      --
      set @count = @test_stack.value(N'count (/*/test[@actual="pass"])'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      --
      set @count = @test_stack.value(N'count (/*/test[@actual="fail"])'
                                     , N'[int]');
      set @test_stack.modify(N'replace value of (/*/@error_count)[1] with sql:variable("@count")');
      --
      -------------------------------------------
      set @stack_builder.modify(N'insert sql:variable("@test_stack") as last into (/*/result)[1]');
      set @stack = @stack_builder;
  end;

go
-------------------------------------------------
-- code block end
--
