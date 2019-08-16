use [chamomile];

go

if schema_id(N'person_test') is null
  execute (N'create schema person_test');

go

--
-- create test for accessor object
-------------------------------------------------
-------------------------------------------------
if object_id(N'[person_test].[get_age__valid_age_01]', N'P') is not null
  drop procedure [person_test].[get_age__valid_age_01];

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
     declare @schema   [sysname] = N'person_test'
             , @object [sysname] = N'get_age__valid_age_01';
     
     select quotename([schemas].[name]) + N'.'
            + quotename([objects].[name])        as [object]
            , [extended_properties].[name]       as [property]
            , [extended_properties].[class_desc] as [type]
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
     order  by [extended_properties].[class_desc],[extended_properties].[name]; 
     
*/
create procedure [person_test].[get_age__valid_age_01] @output  [xml] output
                                                       , @error [xml] = null output
as
  begin
      --
      -- Either SNAPSHOT or SERIALIZABLE may be used. SNAPSHOT is typically more efficient but the database must be enabled for it.
      -- Either isolation level ensures that no other transaction will see what happens within this transaction.
      -------------------------------------------
      set transaction isolation level snapshot;

      --
      -- These are templates to be used to reset @test_stack and @test to default. They should not be modified directly.
      -- Ideally these would be populated from a table which contains templates so that all tests are sure to get the same, and,
      --   the XML would be typed with an XML Schema to ensure that expected values are in place.
      -------------------------------------------
      declare @test_stack_builder [xml] = N'<test_stack name="" test_count="0" pass_count="0" timestamp="" ><description /></test_stack>'
              , @test_builder     [xml] = N'<test test_name="" pass="false" timestamp="" ><description /></test>'
              , @true             [sysname] = N'true'
              , @false            [sysname] = N'false';
      --
      declare @test_stack         [xml]
              , @test             [xml]
              , @test_description [nvarchar](max)
              , @message          [nvarchar](max)
              , @timestamp        [datetime2](7) = current_timestamp
              , @timestamp_string [sysname]
              , @this             [nvarchar](1000) = (select quotename(db_name()) + N'.'
                        + quotename([schemas].[name]) + N'.'
                        + quotename([procedures].[name])
                 from   [sys].[procedures] as [procedures]
                        join [sys].[schemas] as [schemas]
                          on [schemas].[schema_id] = [procedures].[schema_id]
                 where  [procedures].[object_id] = @@procid)
              , @transaction_id   [bigint]
              , @test_name        [sysname]
              , @id               [int]
              , @age              [int] = null
              , @expected_age     [int] = null
              , @first_name       [sysname]
              , @last_name        [sysname]
              , @date_of_birth    [date]
              , @count            [int]
              , @pass             [sysname];

      --
      -------------------------------------------
      select @timestamp_string = convert(sysname, @timestamp, 126);

      set @test_stack_builder.modify(N'replace value of (/*/@name)[1] with sql:variable("@this")');
      set @test_stack_builder.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp_string")');
      set @message = N'This test stack consists of tests which validate the functionality of the age calculation for a person.';
      set @test_stack_builder.modify(N'insert text{sql:variable("@message")} as first into (/*/description)[1]');
      --
      set @test_stack = @test_stack_builder;

      --
      -- TEST
      -- Note that I prefer NOT creating excessive documentation in a procedure. 
      --   When possible, good code should be self documenting.
      --   Here, and in subsequent tests, I clearly identify where a TEST is beginning.
      --   Then, the first variable is assigned the test name. Another developer (or myself
      --   several weeks, months, years from now, should be able to quickly identify the topic
      --   of this test. Putting the name of the test in the comments only creates one more
      --   place to have a copy/paste error. I can copy this entire test and paste it to create
      --   another test. If I forget to change both the comment and the test name then I have "bad"
      --   comments. It is unlikely that I will forget to reset the @test_name variable as I will
      --   be looking at test output during evaluation. 
      -- "Simplicity is the ultimate sophistication". Leonardo da Vinci.
      -------------------------------------------
      -------------------------------------------
      -------------------------------------------
      begin
          select @test_name = N'validate_age_calculation_born_today'
                 , @test_description = N'This test validates that, for a person born today, the age calculate will return the correct age.'
                 , @timestamp = current_timestamp
                 , @first_name = convert(sysname, newid())
                 , @last_name = convert(sysname, newid())
                 , @date_of_birth = dateadd(year, -20, current_timestamp)
                 , @test = @test_builder;

          select @timestamp_string = convert(sysname, @timestamp, 126)
                 , @expected_age = 20;

          --
          -- Note that we assume a FAIL. So, if the test does not run correctly, we default to FAIL.
          ---------------------------------------
          set @test.modify(N'replace value of (/*/@pass)[1] with sql:variable("@false")');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp_string")');
          set @test.modify(N'insert attribute date_of_birth {sql:variable("@date_of_birth")} as last into (/*)[1]');
          set @test.modify(N'insert attribute expected_age {sql:variable("@expected_age")} as last into (/*)[1]');

          if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
            set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
          else
            set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

          --
          -- The transaction should be as short as possible for performance reasons.
          ---------------------------------------
          begin
              begin transaction;

              --  
              -- It is important to use declared transactions so we can rollback ONLY the transaction created here.
              -- A "bare" ROLLBACK without checking to see if the transaction created here is still in play 
              --  will rollback all current transactions in the calling stack, causing
              --  calling applications to error if they attempt to ROLLBACK. Additionally, if the called
              --  objects have issued a "bare" ROLLBACK, there will be no transaction here to rollback,
              --  so calling a "bare" ROLLBACK will throw an error here, inside the test, which is an 
              --  undesirable behavior!
              ---------------------------------------
              set @transaction_id = CURRENT_TRANSACTION_ID();

              --
              -- Note:
              -- This will increment the identity column. If it is important to you
              --  that there not be a gap in the identity values, capture the current identity
              --  first, then reseed after the test.
              -- In this case we are simply inserting a record presumed to be unique (as the first and last names are GUID's 
              --  created using NEWID()). You could also find a record to use as a test, however, that assumes that there will
              --  exist a record with the conditions you wish to test.
              ---------------------------------------

              --
              -- Insert the test record into the table and capture the INSERTed value of the IDENTIY column.
              -- !!!REMEMBER WE ARE IN A SNAPSHOT OR SERIALIZABLE TRANSACTION!!! SQL Server guarantees that what we do here 
              --  cannot be seen outside of this transaction. Since we ONLY have a rollback in this procedure, what we do
              --  here cannot impact external transactions. 
              -- THIS DOES NOT INCLUDE OBJECTS PLACED ON QUEUES, EMAILS SENT, ETC.!!!
              -- This technique is for professional use only. 
              ---------------------------------------
              insert into [person].[primary]
                          ([first_name],[last_name],[middle_initial],[date_of_birth])
              values      (@first_name,@last_name,null,@date_of_birth);

              select @id = ident_current(N'[person].[primary]');

              --
              -- If the person were born today, 20 years ago, we expect the calculation
              --  to return an age of 20.
              ---------------------------------------
              begin
                  execute [person].[get_age] @id    = @id
                                             , @age = @age output;

                  set @test.modify(N'insert attribute returned_age {sql:variable("@age")} as last into (/*)[1]');

                  if @age = @expected_age
                    set @pass = @true;

                  else
                    set @pass = @false;
              end;

              --
              -- Only rollback the current transaction.
              -- If the transaction does not exist based on [transaction_id] obtained earlier then it was rolled back
              --  by an ill behaved application in the called stack.
              -------------------------------------------
              if exists (select *
                         from   sys.[dm_tran_active_transactions]
                         where  [transaction_id] = @transaction_id)
                rollback transaction;
          end;

          --
          -- Set the value of "pass" with the result of the tests.
          ---------------------------------------
          set @test.modify(N'replace value of (/*/@pass)[1] with sql:variable("@pass")');
          --
          -- Insert the test into the test stack.
          ---------------------------------------
          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');

      end;

      --
      -- TEST
      -------------------------------------------
      -------------------------------------------
      -------------------------------------------
      begin
          select @test_name = N'validate_age_calculation_born_tomorrow'
                 , @test_description = N'This test validates that, for a person born tomorrow, the age calculate will return the correct age. If the person were born tomorrow, 20 years ago, we expect the calculation to return an age of 19.'
                 , @timestamp = current_timestamp
                 , @first_name = convert(sysname, newid())
                 , @last_name = convert(sysname, newid())
                 , @date_of_birth = dateadd(day, 1, dateadd(year, -20, current_timestamp))
                 , @test = @test_builder;

          select @timestamp_string = convert(sysname, @timestamp, 126)
                 , @expected_age = 19;

          --
          ---------------------------------------
          set @test.modify(N'replace value of (/*/@pass)[1] with sql:variable("@false")');
          set @test.modify(N'replace value of (/*/@test_name)[1] with sql:variable("@test_name")');
          set @test.modify(N'replace value of (/*/@timestamp)[1] with sql:variable("@timestamp_string")');
          set @test.modify(N'insert attribute date_of_birth {sql:variable("@date_of_birth")} as last into (/*)[1]');
          set @test.modify(N'insert attribute expected_age {sql:variable("@expected_age")} as last into (/*)[1]');

          if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
            set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
          else
            set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');

          --

          begin
              begin transaction;

              set @transaction_id = CURRENT_TRANSACTION_ID();

              --
              -- set up test conditions
              ---------------------------------------
              insert into [person].[primary]
                          ([first_name],[last_name],[middle_initial],[date_of_birth])
              values      (@first_name,@last_name,null,@date_of_birth);

              select @id = ident_current(N'[person].[primary]');

              begin
                  execute [person].[get_age] @id    = @id
                                             , @age = @age output;

                  set @test.modify(N'insert attribute returned_age {sql:variable("@age")} as last into (/*)[1]');

                  if @age = @expected_age
                    set @pass = @true;

                  else
                    set @pass = @false;
              end;

              --
              if exists (select *
                         from   sys.[dm_tran_active_transactions]
                         where  [transaction_id] = @transaction_id)
                rollback transaction;
          end;

          --
          set @test.modify(N'replace value of (/*/@pass)[1] with sql:variable("@pass")');
          --
          set @test_stack.modify(N'insert sql:variable("@test") as last into (/*)[1]');

      end;

      --
      -- Complete the test_stack
      ---------------------------------------
      begin
          set @count = @test_stack.value('count (/*/test)', '[int]');
          set @test_stack.modify(N'replace value of (/*/@test_count)[1] with sql:variable("@count")');
          --
          set @count = @test_stack.value(N'count (//test[@pass=sql:variable("@true")])', N'[int]');
          set @test_stack.modify(N'replace value of (/*/@pass_count)[1] with sql:variable("@count")');
      end;

      select @output = @test_stack;

      return 0;
  end;

go

-- 
-------------------------------------------------
execute [sys].[sp_addextendedproperty] @name         = N'description'
                                       , @value      = N'@output [xml] output - The output stack of the test procedure.'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_age_01'
                                       , @level2type = N'parameter'
                                       , @level2name = N'@output';

go

execute [sys].[sp_addextendedproperty] @name         = N'description'
                                       , @value      = N'@error [xml] = null output - The error information for the procedure, if any. Optional parameter.'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_age_01'
                                       , @level2type = N'parameter'
                                       , @level2name = N'@error';

go

--
-------------------------------------------------
execute [sys].[sp_addextendedproperty] @name         = N'execute_as'
                                       , @value      = N'
declare @output        [xml]  = null
        , @error       [xml] = null
        , @return_code [int] = null
        , @test_count  [int] = 0
        , @pass_count  [int] = 0;

execute @return_code = [person_test].[get_age__valid_age_01] @output = @output output;

if @return_code <> 0
    or @error is not null
  begin
      select @return_code as [return_code]
             , @error     as [error]
             , @output    as [output];
  end;
else
  begin
      select @test_count = @output.value(''(/test_stack/@test_count)[1]'', N''int'')
             , @pass_count = @output.value(''(/test_stack/@pass_count)[1]'', N''int'');

      if @pass_count = @test_count
        begin
            select N''All tests passed.'' as [result]
                   , @output            as [output]
                   , @test_count        as [test_count]
                   , @pass_count        as [pass_count];
        end;
      else
        begin
            select N''Not all tests passed. Inspect @output for failed tests and conditions.'' as [result]
                   , @output                                                                 as [output]
                   , @test_count                                                             as [test_count]
                   , @pass_count                                                             as [pass_count];
        end;
  end; 
'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_age_01'
                                       , @level2type = null
                                       , @level2name = null;

go

execute [sys].[sp_addextendedproperty] @name         = N'description'
                                       , @value      = N'This test procedure consists of tests which validate the functionality of the age calculation for a person.'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_age_01'
                                       , @level2type = null
                                       , @level2name = null;

go

execute [sys].[sp_addextendedproperty] @name         = N'revision_20180624'
                                       , @value      = N'Created - KELightsey@gmail.com'
                                       , @level0type = N'schema'
                                       , @level0name = N'person_test'
                                       , @level1type = N'procedure'
                                       , @level1name = N'get_age__valid_age_01'
                                       , @level2type = null
                                       , @level2name = null;

go 
