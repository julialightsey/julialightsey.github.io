
--
-- code block begin
-------------------------------------------------
--
-- we can create a "lock" trigger to run tests on modification of an object
-- {note that the production implementation of this would check the EventData stack
--	and only run the test for the modified object}
-------------------------------------------------
exec sp_configure 'show advanced options'
                  , 1;

reconfigure;
exec sp_configure 'disallow results from triggers'
                  , 0;

reconfigure;
go
if exists (select *
           from   sys.[triggers]
           where  [parent_class] = 0
                  and name = 'lock_test')
  drop trigger [lock_test] on database;

go

create trigger [lock_test]
on database
after alter_function, drop_function, alter_procedure, drop_procedure, alter_table, drop_table
as
  begin
      declare @stack         [xml]
              , @error_count [int];

      if object_id(N'[dbo].[sp__chamomile__run_test]', N'P') is not null
        begin
            execute [dbo].[sp__chamomile__run_test] @stack=@stack output;

            set @error_count = @stack.value(N'(/*/@error_count)[1]', N'[int]')

            if @error_count > 0
                or @error_count is null
              rollback;
        end;
  end;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- can you drop a method?
-------------------------------------------------
if object_id(N'[math].[divide]', N'FN') is not null
  drop function [math].[divide];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- note that you could NOT drop the method!
-------------------------------------------------
declare @stack [xml];

execute [math__test].[divide] @stack=@stack output;

select @stack;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- can you alter a method to a failing state?
-------------------------------------------------
alter function [math].[divide] (@numerator     [decimal](10, 6)
                                , @denominator [int]
)
returns [decimal](10, 6)
as
  begin
      return 1;
  end;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- note that you could NOT alter the method such that it causes the test to fail!
-------------------------------------------------
declare @stack [xml];

execute [math__test].[divide] @stack=@stack output;

select @stack;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- can you alter a method as long as it still works?
-------------------------------------------------
alter function [math].[divide] (@numerator     [decimal](10, 6)
                                , @denominator [int]
)
returns [decimal](10, 6)
as
  begin
      declare @return [decimal](10, 6);

      if @numerator is null
          or @denominator is null
          or @denominator = 0
        set @return = 0;
      else
        set @return = round(cast (@numerator as [float]) / cast(@denominator as [float]), 6);

      return @return;
  end;

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- note that you CAN alter the method, as long as the existing tests still run successfully!
-------------------------------------------------
declare @stack [xml];

execute [math__test].[divide] @stack=@stack output;

select @stack;

go
-------------------------------------------------
-- code block end
--
