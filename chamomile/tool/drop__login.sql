--
-- https://sqljana.wordpress.com/2017/01/12/sql-server-drop-an-user-in-all-databases-drop-the-login-too/
--Drop the schema's. They WILL NOT get dropped if schema had objects
-------------------------------------------------
declare @user  [sysname] = N'mds_email_login'
        , @sql [nvarchar](4000);

--
-- [drop__schema]
-------------------------------------------------
set @sql = N'USE [?]; IF  EXISTS (SELECT * FROM sys.schemas WHERE name = ''' + @user + N''')
        DROP SCHEMA [' + @user + N'];';

begin try
    exec sp_msforeachdb
      @sql;
end try
begin catch
    select db_name()
           , @sql as [drop__schema]
           , error_message();
    --
    set @sql = N'USE [?]; select db_name()                    as [database]
       , [schemas].[name]           as [schema]
       , [server_principals].[name] as [principle]
		from   [sys].[schemas] as [schemas]
			   join [sys].[server_principals] as [server_principals]
				 on [server_principals].[principal_id] = [schemas].[principal_id]
		where  [server_principals].[name] = ''' + @user + N''';';
    exec sp_msforeachdb
      @sql;
end catch;

--
-- [drop__database_user]
-------------------------------------------------
set @sql = N'USE [?];
        if exists (select *
                   from   [sys].[database_principals]
                   where  name = ''' + @user + N''')
          begin try;
              drop user [' + @user + N'];
          end try
		  begin catch; 
			select db_name(), error_message();
		  end catch;
        ';

begin try
    exec sp_msforeachdb
      @sql;
end try
begin catch
    select @sql as [drop__database_user]
           , error_message();
end catch;

--
-- [drop__login]
-------------------------------------------------
set @sql = N'
if exists (select *
           from   [sys].[server_principals]
           where  name = ''' + @user + N''')
  drop LOGIN [' + @user + N'];';

begin try
    execute sp_executesql
      @sql;
end try
begin catch
    select @sql as [drop__login]
           , error_message();
end catch; 
