

-- Restore the master Database (Transact-SQL) -- https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/restore-the-master-database-transact-sql?view=sql-server-2017
-- Restoring the SQL Server Master Database Even Without a Backup -- https://www.mssqltips.com/sqlservertip/3266/restoring-the-sql-server-master-database-even-without-a-backup/
-- How to connect to SQL Server if you are completely locked out -- https://www.mssqltips.com/sqlservertip/2465/how-to-connect-to-sql-server-if-you-are-completely-locked-out/

-- Path to executable - service properties window
-- sqlservr.exe -s<instance_name> -m
-- or
-- sqlservr.exe -s <instance_name> -m
-- Use instance name in startup: https://sqlserver-help.com/2014/12/16/error-your-sql-server-installation-is-either-corrupt-or-has-been-tampered-with-error-getting-instance-id-from-name-please-uninstall-then-re-run-setup-to-correct-this-problem/

--Database Engine Service Startup Options -- https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/database-engine-service-startup-options?view=sql-server-2017

C:\Program Files\Microsoft SQL Server\MSSQL13.TEST_2016_01\MSSQL\Binn>sqlservr.exe -s TEST_2016_01 -m
RegOpenKeyEx of "Software\Microsoft\Microsoft SQL Server\MSSQL13.TEST_2016_01\MSSQLServer\HADR" failed.
2018-08-21 12:51:25.94 Server      Error: 17058, Severity: 16, State: 1.
2018-08-21 12:51:25.94 Server      initerrlog: Could not open error log file ''. Operating system error = 3(The system cannot find the path specified.).

Check the value for -e parameter in registry at
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL11.testgk2012\MSSQLServer\Parameters
Also make sure you staring command prompt with alleviated admin privileges. See if this post helps you

-- HOW TO: RESTORE THE MASTER DATABASE IN SQL SERVER 2012 -- https://thomaslarock.com/2014/01/restore-the-master-database-in-sql-server-2012/
-- 1st cmd window in admin mode: .\sqlservr.exe –c –m –s JAMBON
-- 2nd cmd window in norml mode: SQLCMD –S .\JAMBON
restore database master from disk = 'd:\data\master.bak' with replace

-- Considerations for Backing Up and Restoring System Databases -- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2005/ms190190(v=sql.90)
-- Considerations for Backing Up the master Database -- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2005/ms191488%28v%3dsql.90%29
-- Considerations for Restoring the master Database -- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2005/ms175535%28v%3dsql.90%29
-- Considerations for Rebuilding the master Database -- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2005/ms191431(v=sql.90)
-- master Database -- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2005/ms187837%28v%3dsql.90%29

-- Restoring Master DB to different server/instance -- https://www.sqlservercentral.com/Forums/1044988/Restoring-Master-DB-to-different-serverinstance
-- restore master db to different location -- http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=85649
-- How to: Rename a Computer that Hosts a Stand-Alone Instance of SQL Server 2005 -- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2005/ms143799(v=sql.90)

-- How to migrate SQL Server from one machine to another -- http://yrushka.com/index.php/sql-server/database-recovery/sql-server-migration-from-one-server-to-another-detailed-checklist/

-- Sql Server 2012 Restoring Master and Migrating a server -- https://dba.stackexchange.com/questions/47069/sql-server-2012-restoring-master-and-migrating-a-server
-- How to transfer logins and passwords between instances of SQL Server -- https://support.microsoft.com/en-us/help/918992/how-to-transfer-logins-and-passwords-between-instances-of-sql-server




