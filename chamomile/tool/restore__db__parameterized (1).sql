/*
	katherine.lightsey@aristocrat.com
	20181210

	INSTRUCTIONS
		Restore
			Modify the CONSTANT variables as required for your restore then execute the script. 
			Inspect the output and the logged value to ensure the operation completed successfully. The result of the restore is logged as:
				select * from [utility].[utility].[log] where [id] = <id>; -- The [id] of the logged value is output after the script completes.

		Determine Current Restore Level (the latest restore for a database):
			select [id] as [log__id], [database], [database__backup__file], [timestamp] from [utility].[utility].[backup__level] order by [created] desc;

	NOTES
		This script will restore a database from a backup file.
		You MUST inspect and/or modify the "constant" variables below to define both the database to be restored and the file from which to restore it.

*/
use [master];

go

--
-- constants
-------------------------------------------------
declare @database                 [sysname] = N'AxDB'
        , @database__backup__file [nvarchar](1024) = N'J:\MSSQL_BACKUP\AxDB\AxDB_fromTest_12132018.bak';
--
declare @sql                 [nvarchar](max)
        , @entry             [xml] = N'<restore__db />'
        , @timestamp__string [sysname] = convert([sysname], current_timestamp, 126)
        , @application       nvarchar(450) = N'restore__db'
        , @message           [nvarchar](max)
        , @log__id           [bigint];

--
begin;
    if @database is null
        or @database__backup__file is null
      begin;
          throw 51000, N'Neither variable @database or @database__backup__file can be null', 16;
      end;
end;

--
set @entry.modify(N'insert attribute database {sql:variable("@database")} as first into (/*)[1]');
set @entry.modify(N'insert attribute database__backup__file {sql:variable("@database__backup__file")} as last into (/*)[1]');
set @entry.modify(N'insert attribute timestamp {sql:variable("@timestamp__string")} as last into (/*)[1]');

--
begin;
    set @sql = N'alter database [' + @database
               + N'] set SINGLE_USER with rollback IMMEDIATE';

    begin try
        execute sp_executesql
          @sql = @sql;
    end try
    begin catch
        set @message = N'Restore failed | ERROR_MESSAGE '
                       + cast(error_message() as [nvarchar](4000))
                       + N' | SQL ' + @sql;
        throw 51000, @message, 16;
    end catch;
end;

--
begin;
    set @sql = N'restore database [' + @database
               + N'] from disk = '''
               + @database__backup__file
               + N''' with NORECOVERY, REPLACE;';

    begin try
        execute sp_executesql
          @sql = @sql;
    end try
    begin catch
        set @message = N'Restore failed | ERROR_MESSAGE '
                       + cast(error_message() as [nvarchar](4000))
                       + N' | SQL ' + @sql;
        throw 51000, @message, 16;
    end catch;
end;

--
begin;
    set @sql=N'restore database [' + @database
             + N'] from disk = '''
             + @database__backup__file
             + N''' with RECOVERY, REPLACE;';

    begin try
        execute sp_executesql
          @sql = @sql;
    end try
    begin catch
        set @message = N'Restore failed | ERROR_MESSAGE '
                       + cast(error_message() as [nvarchar](4000))
                       + N' | SQL ' + @sql;
        throw 51000, @message, 16;
    end catch;
end;

--
begin;
    set @sql=N'alter database [' + @database
             + N'] set MULTI_USER with rollback IMMEDIATE;';

    begin try
        execute sp_executesql
          @sql = @sql;
    end try
    begin catch
        set @message = N'Restore failed | ERROR_MESSAGE '
                       + cast(error_message() as [nvarchar](4000))
                       + N' | SQL ' + @sql;
        throw 51000, @message, 16;
    end catch;
end;

--
if @entry is not null
  begin;
      execute [utility].[utility].[set__log]
        @entry = @entry
        , @application = @application
        , @id = @log__id output;
  end;

select N'Restore logged at [id] ('
       + cast(@log__id as [sysname]) + N').';

Go 
