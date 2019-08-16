use [chamomile];

go

if schema_id(N'math__test') is null
  execute (N'create schema math__test');

go

if object_id(N'[math__test].[set_00]', N'P') is not null
  drop procedure [math__test].[set_00];

go

/*
    select [id], [numerator], [denominator], [result], [timestamp], N'before_test' as [before_test]
              from   [math__secure].[data];
    select ident_current(N'[math__secure].[data]') as [ident_current__before_test];

    declare @stack [xml];
    execute [math__test].[set_00] @stack=@stack output;
    
    select [id], [numerator], [denominator], [result], [timestamp], N'after_test' as [after_test]
              from   [math__secure].[data];
    select ident_current(N'[math__secure].[data]') as [ident_current__after_test];
*/
create procedure [math__test].[set_00] @test_stack   [xml] = null output
                                       , @error      [xml] = null output
                                       , @log_output [bit] = 0
                                       , @log_id     [bigint] = null output
as
  begin
      set nocount on;
      --
      -- When SET XACT_ABORT is ON, if a Transact-SQL statement raises a run-time error, the entire transaction is terminated and rolled back.
      -- https://docs.microsoft.com/en-us/sql/t-sql/statements/set-xact-abort-transact-sql?view=sql-server-2017
      -----------------------------------------------
      set xact_abort on;

      declare @object                   [nvarchar](max) = N'[math__secure].[data]'
              , @subject                [nvarchar](1000) = quotename(db_name()) + N'.'
                + quotename(object_schema_name(@@procid))
                + N'.' + quotename(object_name(@@procid))
              , @current_transaction_id [bigint]
              , @id                     [int];
      --
      -- create a unique transation to avoid issues during parallel operations
      -------------------------------------------
      declare @transaction [nvarchar](32) = right(lower(db_name()) + N'_'
                      + lower(object_schema_name(@@procid)) + N'_'
                      + lower(object_name(@@procid)) + N'_'
                      + cast(round(rand()*100000, -1) as [sysname]), 32)
              --
              -- capture identity value before test
              -----------------------------------
              , @identity  [int] = ident_current(@object);

      begin transaction @transaction;

      set @current_transaction_id = CURRENT_TRANSACTION_ID();

      --
      -- If a transaction did not get created and an exception was not thrown, for whatever reason, stop now.
      -------------------------------------------
      if not exists (select *
                     from   [sys].[dm_tran_active_transactions]
                     where  [transaction_id] = @current_transaction_id
                            and [name] = @transaction)
        throw 51000, N'Unable to begin transaction', 1;

      --
      -- If we have successfully begun a transaction which we can reliably identify both by name and id, we can begin the test.
      -------------------------------------------
      begin
          execute [math].[set] @numerator     = 3
                               , @denominator = 2
                               , @id          = @id output;

          --
          -- Display in test results
          -- This is for demonstration purposes only. An actual test will aggregate the results into the @output parameter as shown elsewhere.
          ---------------------------------------
          begin
              select [id]
                     , [numerator]
                     , [denominator]
                     , [result]
                     , [timestamp]
                     , N'during_test' as [during_test]
              from   [math__secure].[data];

              select ident_current(@object) as [ident_current__during_test];
          end;

          --
          if (select [result]
              from   [math__secure].[data]
              where  [id] = @id) = 1.5
            select N'pass' as [test_result];
          else
            select N'fail' as [test_result];
      end;

      --
      -- rollback ONLY your own transaction!
      -------------------------------------------
      if exists (select *
                 from   [sys].[dm_tran_active_transactions]
                 where  [transaction_id] = @current_transaction_id
                        and [name] = @transaction)
        rollback transaction @transaction;

      --
      -- Reset identity value after test
      -- Note that dbcc will not accept a parameter for the object
      -- This is not necessarily required depending on your application. It is shown here for demonstration.
      -------------------------------------------
      dbcc checkident (N'[math__secure].[data]', reseed, @identity);
  end;

go 
