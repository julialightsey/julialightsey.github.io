/*
	--
	--	description
	---------------------------------------------
		sql service broker diagnosis
			Validate Infrastructure Objects - Service Broker is dependent on five of infrastructure objects in 
			order to operate properly.  As such, once you have created your Service Broker objects, it is wise 
			to validate that all of the objects have been created.  The queries below would validate that the 
			objects exist.  These queries should be issued in both the initiator and target databases to 
			validate that the objects exist in both SQL Server environments.



	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
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
	Service Broker Troubleshooting - http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
	How to troubleshoot Service Broker problems - http://www.sqlteam.com/article/how-to-troubleshoot-service-broker-problems

*/
/*
	ALTER DATABASE [db_name]

	SET SINGLE_USER WITH

	ROLLBACK IMMEDIATE;

	go

	ALTER DATABASE [db_name]

	SET ENABLE_BROKER;

	go

	ALTER DATABASE [db_name]

	SET MULTI_USER;

	go 

*/
-- ssbdiagnose -E -d chamomile -S MCK790L8159\INSTANCE_2014_01 CONFIGURATION FROM SERVICE //chamomile.katherinelightsey.com/command_stack/initiator_service TO SERVICE //chamomile.katherinelightsey.com/command_stack/target_service;
-- ssbdiagnose -E -d oltp -S MCK790L8159\INSTANCE_2014_01 CONFIGURATION FROM SERVICE //chamomile.katherinelightsey.com/command_stack/initiator_service TO SERVICE //chamomile.katherinelightsey.com/command_stack/target_service;
-- ssbdiagnose CONFIGURATION FROM SERVICE //InstDB/2InstSample/InitiatorService -S MCK790L8159\CHAMOMILE_OLTP -d InstInitiatorDB TO SERVICE //TgtDB/2InstSample/TargetService -S MCK790L8159\CHAMOMILE -d InstTargetDB ON CONTRACT //BothDB/2InstSample/SimpleContract
-- ssbdiagnose runtime connect to -S MCK790L8159\CHAMOMILE_OLTP connect to -S MCK790L8159\CHAMOMILE
--------------------------------------------------------------------------
SELECT *
FROM   [sys].[service_message_types];

SELECT *
FROM   [sys].[service_contracts];

SELECT *
FROM   [sys].[services];

SELECT *
FROM   [sys].[endpoints];

SELECT *
FROM   [sys].[service_broker_endpoints];

SELECT *
FROM   [sys].[routes];

SELECT *
FROM   [sys].[conversation_endpoints];

SELECT *
FROM   [sys].[service_queues];

--
-------------------------------------------------
/*
	ALTER QUEUE <queue_name>
		WITH ACTIVATION
		( STATUS = ON,
		  PROCEDURE_NAME = <procedure_name>,
		  MAX_QUEUE_READERS = 5,
		  EXECUTE AS SELF
		);
	GO
*/
/*
	Troubleshooting the Service Broker Queues - Once you start adding messages to your queues 
	and receiving data from your queues, it is necessary to ensure you are not having any issues 
	with your endpoints, services and contracts.  If you are experiencing issues, then this query 
	may identify the conversations that are having issues and additional research may be necessary 
	to troubleshoot the issues further.
	http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
*/
--------------------------------------------------------------------------
SELECT [conversation_handle]
       , [is_initiator]
       , [s].[Name]  AS 'local service'
       , [far_service]
       , [sc].[Name] AS 'contract'
       , [state_desc]
FROM   [sys].[conversation_endpoints] [ce]
       LEFT JOIN [sys].[services] [s]
              ON [ce].[service_id] = [s].[service_id]
       LEFT JOIN [sys].[service_contracts] [sc]
              ON [ce].[service_contract_id] = [sc].[service_contract_id];

/*
	Another key queue to keep in mind when troubleshooting Service Broker is the sys.transmission_queue.  
	This is the queue that receives any records that are not written to the user defined queue appropriately.  
	If your overall Service Broker infrastructure is setup properly, then this may be the next logical place 
	to start troubleshooting the issue.  You are able to validate the conversation as well as take a peek at 
	the xml (message_body) and find out the error message (transmission_status) for the record.
	http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
*/
--------------------------------------------------------------------------
-- Error messages in the queue
-- An error occurred while receiving data: '10054(An existing connection was forcibly closed by the remote host.)'.
SELECT *
FROM   [sys].[transmission_queue];

/*
	Removing all records from the sys.transmission_queue - Odds are that if your Service Broker infrastructure 
	is setup properly and records are in the sys.transmission_queue, they probably need to be removed to continue 
	to build and test the application.  As such, the END CONVERSATION command should be issued with the conversation 
	handle and the 'WITH CLEANUP' parameter.  Below is an example command:
	http://www.mssqltips.com/sqlservertip/1197/service-broker-troubleshooting/
*/
--------------------------------------------------------------------------
--END CONVERSATION 'conversation handle' WITH CLEANUP;
/*
SQL Server Error Log

The next place that should be researched when troubleshooting Service Broker is the SQL Server error log.  Some of 
the issues may not be written to the views above, so the SQL Server error log is another valuable source of information.  
Below outlines two examples, although based on the issue, the errors could differ:
Date 1/1/2007 00:00:00 AM 
Log SQL Server (Current - 1/1/2007 00:00:00 AM 
Source spid62
Message Service Broker needs to access the master key in the database 'YourDatabaseName'. Error code:25. The master 
key has to exist and the service master key encryption is required

Date 1/1/2007 00:00:00 AM 
Log SQL Server (Current - 1/1/2007 00:00:00 AM 
Source spid16

Message The Service Broker protocol transport is disabled or not configured
*/
--
-- returns a row for each Service Broker network connection.
--------------------------------------------------------------------------
SELECT *
FROM   [sys].[dm_broker_connections];

--
-- Returns a row for each queue monitor in the instance. A queue monitor manages activation for a queue.
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-broker-queue-monitors-transact-sql
-------------------------------------------------
SELECT *
FROM   [sys].[dm_broker_queue_monitors] AS [dm_broker_queue_monitors];

--
-- returns a row for each Service Broker message that an instance of SQL Server is in the process of forwarding.
--------------------------------------------------------------------------
SELECT *
FROM   [sys].[dm_broker_forwarded_messages];

--
-- http://technet.microsoft.com/en-us/library/ms166044(v=sql.105).aspx
--------------------------------------------------------------------------
SELECT [is_broker_enabled]
       , *
FROM   [sys].[databases]
WHERE  [database_id] = DB_ID();

--
-- Contains a row for each object in the database that is a service queue, with sys.objects.type = SQ
-- http://technet.microsoft.com/en-us/library/ms166102(v=sql.105).aspx
--------------------------------------------------------------------------
SELECT *
FROM   [sys].[service_queues];

SELECT *
FROM   [sys].[service_queue_usages];

SELECT *
FROM   [sys].[services];

--
SELECT [services].[name]                         AS [service]
       , [service_queues].[name]                 AS [service_queue]
       , [service_queues].[activation_procedure] AS [activation_procedure]
FROM   [sys].[service_queues] AS [service_queues]
       LEFT JOIN [sys].[service_queue_usages] AS [service_queue_usages]
              ON [service_queue_usages].[service_queue_id] = [service_queues].[object_id]
       LEFT JOIN [sys].[services] AS [services]
              ON [services].[service_id] = [service_queue_usages].[service_id];

--
-- returns a row for each stored procedure activated by Service Broker. It can be joined to dm_exec_sessions.session_id via the spid column.
-- http://technet.microsoft.com/en-us/library/ms175029(v=sql.105).aspx
--------------------------------------------------------------------------
SELECT *
FROM   [sys].[dm_broker_activated_tasks] AS [dm_broker_activated_tasks]
       LEFT JOIN [sys].[dm_exec_sessions] AS [dm_exec_sessions]
              ON [dm_exec_sessions].[session_id] = [dm_broker_activated_tasks].[spid];

--
-- Make sure that activation stored procedures are correctly started.
-- returns a row for each queue monitor in the instance. A queue monitor manages activation for a queue.
-- http://technet.microsoft.com/en-us/library/ms166102(v=sql.105).aspx
-- ALTER QUEUE [target_queue] WITH STATUS = ON
--------------------------------------------------------------------------
SELECT *
FROM   [sys].[dm_broker_queue_monitors];

--
SELECT [databases].[name]                                 AS [database]
       , [service_queues].[name]                          AS [queue]
       , [service_queues].[activation_procedure]          AS [activation_procedure]
       , [service_queues].[is_activation_enabled]         AS [is_activation_enabled]
       , [dm_broker_queue_monitors].[state]               AS [state]
       , [dm_broker_queue_monitors].[tasks_waiting]       AS [tasks_waiting]
       , [dm_broker_queue_monitors].[last_activated_time] AS [last_activated_time]
       , *
FROM   [sys].[dm_broker_queue_monitors] AS [dm_broker_queue_monitors]
       LEFT JOIN [sys].[service_queues] AS [service_queues]
              ON [service_queues].[object_id] = [dm_broker_queue_monitors].[queue_id]
       LEFT JOIN [sys].[databases] AS [databases]
              ON [databases].[database_id] = [dm_broker_queue_monitors].[database_id];

--
SELECT [t1].NAME                                           AS [service_name]
       , [t3].NAME                                         AS [schema_name]
       , [t2].NAME                                         AS [queue_name]
       , CASE
           WHEN [t4].[state] IS NULL THEN 'Not available'
           ELSE [t4].[state]
         END                                               AS [queue_state]
       , CASE
           WHEN [t4].[tasks_waiting] IS NULL THEN '--'
           ELSE CONVERT(VARCHAR, [t4].[tasks_waiting])
         END                                               AS [tasks_waiting]
       , CASE
           WHEN [t4].[last_activated_time] IS NULL THEN '--'
           ELSE CONVERT(VARCHAR, [t4].[last_activated_time])
         END                                               AS [last_activated_time]
       , CASE
           WHEN [t4].[last_empty_rowset_time] IS NULL THEN '--'
           ELSE CONVERT(VARCHAR, [t4].[last_empty_rowset_time])
         END                                               AS [last_empty_rowset_time]
       , (SELECT COUNT(*)
          FROM   sys.[transmission_queue] [t6]
          WHERE  ( [t6].[from_service_name] = [t1].NAME )) AS [tran_message_count]
FROM   sys.[services] [t1]
       INNER JOIN sys.[service_queues] [t2]
               ON( [t1].[service_queue_id] = [t2].[object_id] )
       INNER JOIN sys.[schemas] [t3]
               ON( [t2].[schema_id] = [t3].[schema_id] )
       LEFT OUTER JOIN sys.[dm_broker_queue_monitors] [t4]
                    ON( [t2].[object_id] = [t4].[queue_id]
                        AND [t4].[database_id] = DB_ID() )
       INNER JOIN sys.[databases] [t5]
               ON( [t5].[database_id] = DB_ID() ); 
