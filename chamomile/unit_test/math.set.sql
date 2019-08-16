use [chamomile];

go

if schema_id(N'math') is null
  execute (N'create schema math');

go

if object_id(N'[math].[set]', N'P') is not null
  drop procedure [math].[set];

go

--
create procedure [math].[set] @numerator     [int]
                              , @denominator [int]
                              , @id          [int] = null output
as
  begin
      --
      -- create a unique transation to avoid issues during parallel operations
      -------------------------------------------
      declare @transaction [nvarchar](32) = right(lower(db_name()) + N'_'
              + lower(object_schema_name(@@procid)) + N'_'
              + lower(object_name(@@procid)) + N'_'
              + cast(round(rand()*100000, -1) as [sysname]), 32);

      --
      -- note that a transaction isn't necessarily required here, but it is shown
      --	to demonstrate the correct method for unit testing a mutator that includes
      --	declared transactions
      begin try
          -- checking @@trancount is optional as this method will ONLY rollback or commit
          --	it's own transaction!
          if @@trancount = 0
            begin transaction @transaction;

          begin
              insert into [math__secure].[data]
                          ([numerator],[denominator],[result])
              values      (@numerator,@denominator,[math].[divide] (@numerator, @denominator));

              --
              set @id = scope_identity();
          end;

          --
          -- commit ONLY your own transaction!
          -------------------------------------------
          if exists (select *
                     from   [sys].[dm_tran_active_transactions]
                     where  [name] = @transaction)
            commit transaction @transaction;
      end try
      begin catch
          --
          -- rollback ONLY your own transaction!
          -------------------------------------------
          if exists (select *
                     from   [sys].[dm_tran_active_transactions]
                     where  [name] = @transaction)
            rollback transaction @transaction;
      end catch;
  end;

go 
