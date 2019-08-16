/*
	--
	---------------------------------------------
	All content is copyright Katherine E. Lightsey (http://www.KELightsey.com/), 1959-2015 (aka; my life), 
	all rights reserved. All software contained herein is licensed as 
	[chamomile] (http://www.ChamomileSQL.com/source/license.html) and as open source under 
	the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		Stores a new user-defined error message in an instance of the SQL Server Database Engine. 
			Messages stored by using sp_addmessage can be viewed by using the sys.messages catalog view.
			Applies to: SQL Server (SQL Server 2008 through current version).

			sp_addmessage [ @msgnum= ] msg_id , [ @severity= ] severity , [ @msgtext= ] 'msg' 
				[ , [ @lang= ] 'language' ] 
				[ , [ @with_log= ] { 'TRUE' | 'FALSE' } ] 
				[ , [ @replace= ] 'replace' ] 
		Arguments
			
			[ @msgnum= ] msg_id
			Is the ID of the message. msg_id is int with a default of NULL. msg_id for user-defined error messages can be an integer between 50,001 and 2,147,483,647. The combination of msg_id and language must be unique; an error is returned if the ID already exists for the specified language.
			
			[ @severity = ]severity
			Is the severity level of the error. severity is smallint with a default of NULL. Valid levels are from 1 through 25. For more information about severities, see Database Engine Error Severities.
			
			[ @msgtext = ] 'msg'
			Is the text of the error message. msg is nvarchar(255) with a default of NULL.
			
			[ @lang = ] 'language'
			Is the language for this message. language is sysname with a default of NULL. Because multiple languages can be installed on the same server, language specifies the language in which each message is written. When language is omitted, the language is the default language for the session.
			
			[ @with_log = ] { 'TRUE' | 'FALSE' }
			Is whether the message is to be written to the Windows application log when it occurs. @with_log is varchar(5) with a default of FALSE. If TRUE, the error is always written to the Windows application log. If FALSE, the error is not always written to the Windows application log but can be written, depending on how the error was raised. Only members of the sysadmin server role can use this option.
				Note - If a message is written to the Windows application log, it is also written to the Database Engine error log file.

			[ @replace = ] 'replace'
			If specified as the string replace, an existing error message is overwritten with new message text and severity level. replace is varchar(7) with a default of NULL. This option must be specified if msg_id already exists. If you replace a U.S. English message, the severity level is replaced for all messages in all other languages that have the same msg_id.
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
		sp_addmessage (Transact-SQL)	- http://msdn.microsoft.com/en-us/library/ms178649.aspx
		sys.messages (Transact-SQL)		- http://msdn.microsoft.com/en-us/library/ms187382.aspx
		sp_altermessage (Transact-SQL)	- http://msdn.microsoft.com/en-us/library/ms175094.aspx
		sp_dropmessage (Transact-SQL)	- http://msdn.microsoft.com/en-us/library/ms174369.aspx
		FORMATMESSAGE (Transact-SQL)	- http://msdn.microsoft.com/en-us/library/ms186788.aspx

*/
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'sp_addmessage') is null
  execute (N'create schema sp_addmessage');

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
-- 50,001 and 2,147,483,647
-- meta data was not found for the object fqn provided - 65
if exists (select *
           from   [sys].[messages]
           where  [message_id] = 200065)
  execute [dbo].[sp_dropmessage]
    @msgnum = 200065;

go

execute [dbo].[sp_addmessage]
  @msgnum = 200065,
  @severity=11,
  @msgtext = N'meta data was not found for the object fqn provided (%s). Additional information {if available} (%s).',
  @lang = null,
  @with_log=N'TRUE',
  @replace ='replace';

go

select *
from   [sys].[messages]
where  [message_id] = 200065;

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @message nvarchar(2048) = formatmessage(200065
                , N'First string');

throw 200065, @message, 1;

go

declare @message nvarchar(2048) = formatmessage(200065
                , N'First string'
                , N'optional message');

throw 200065, @message, 1;

go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
