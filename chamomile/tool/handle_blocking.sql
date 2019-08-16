use [utility];

go

/*
	-- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms188396(v%3dsql.105)
	-- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms178104%28v%3dsql.105%29
	enable Trace Flag 1204 and Trace Flag 1222
*/
set nocount on;
set deadlock_priority 10;
set lock_timeout 1000;

declare @retry_count     [int] = 3
        , @count         [int] = 0
        , @process_delay [sysname] = N'00:00:02'
        , @message       [nvarchar](max);

while @count < @retry_count
  begin
      begin TRY
          truncate table [test].[truncate_deadlock_01];
      end TRY
      begin CATCH
          set @count = @count + 1;
          waitfor DELAY @process_delay;
      end CATCH;
  end;

select @count;

if @count >= @retry_count
  begin;
      set @message = N'Unable to truncate table.';

      throw 50000, @message, 1;
  end;

--
select *
from   [sys].[messages]; 
