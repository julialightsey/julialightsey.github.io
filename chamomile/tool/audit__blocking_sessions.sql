/*
--
	dbcc TRACEON (1204, -1);
	go
	dbcc TRACEON (1222, -1);
	go
	--
	dbcc TRACESTATUS(1204, -1);
	go
	dbcc TRACESTATUS(1222, -1);
	go
	dbcc TRACESTATUS(-1);
	GO 
*/
if object_id(N'tempdb..#sp_who2', N'U') is not null
  drop table #sp_who2;

go

create table #sp_who2
  (
     [SPID]          int
     , [Status]      varchar(255)
     , [Login]       varchar(255)
     , [HostName]    varchar(255)
     , [BlkBy]       varchar(255)
     , [DBName]      varchar(255)
     , [Command]     varchar(255)
     , [CPUTime]     int
     , [DiskIO]      int
     , [LastBatch]   varchar(255)
     , [ProgramName] varchar(255)
     , [SPID2]       int
     , [REQUESTID]   int
  )

declare @blocking_count          [int] = 1
        , @notification_interval [int] = 3
        , @count                 [int] = 0
        , @message               [nvarchar](4000);

while 1 = 1
  begin
      truncate table #sp_who2;

      insert into #sp_who2
      exec sp_who2;

      select @blocking_count = count(*)
      from   #sp_who2
      where  try_cast([BlkBy] as [int]) > 0;

      select @blocking_count;

      if @blocking_count <> 0
        begin
            exec msdb.dbo.sp_send_dbmail
              @profile_name = N'<email_address>'
              , @recipients = N'<email_address>'
              , @subject = N'blocking exists'
              , @body = N'see sp_who2';
        end;

      /*
          if @count % @notification_interval = 0
            begin
                set @message = N'Monitoring interval ('
                               + cast(@count as [sysname]) + N').';
      
                exec msdb.dbo.sp_send_dbmail
                  @profile_name = N'ProjectOneDMT@aristocrat.com'
                  , @recipients = N'katherine.lightsey@aristocrat.com'
                  , @subject = N'Monitoring status'
                  , @body = N'see sp_who2';
            end;
      */
      waitfor delay N'00:00:30';

      set @count = @count + 1;
  end; 
