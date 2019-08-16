/*
	All content is copyright Katherine E. Lightsey(http://www.kelightsey.com/) 1959-2015 (aka; my life), 
		all rights reserved. All software contained herein is licensed as 
		[chamomile](http://www.chamomilesql.com/source/license.html) and as open source under the 
		GNU Affero GPL(http://www.gnu.org/licenses/agpl-3.0.html).
	This project is hosted on GitHub(https://github.com/KELightsey/ChamomileSQL). All software including 
		presentations and utilities may be downloaded from the GitHub project. Contributions are welcome.
	--
	--	description
	---------------------------------------------
		THROW (Transact-SQL) - Raises an exception and transfers execution to a CATCH block of a 
			TRY…CATCH construct in SQL Server 2014.
			Syntax
				 THROW [ { error_number([int])		| @local_variable },
						{ message([nvarchar](2048)) | @local_variable },
						{ state([tinyint])			| @local_variable } ] 
				[ ; ]
			Arguments
				error_number([int]) - Is a constant or variable that represents the exception. error_number 
					is int and must be greater than or equal to 50000 and less than or equal to 2147483647.
				message([nvarchar](2048)) - Is an string or variable that describes the exception. message 
					is nvarchar(2048). 
				state([tinyint]) - Is a constant or variable between 0 and 255 that indicates the state 
					to associate with the message. state is tinyint.

		RAISERROR (Transact-SQL) - Generates an error message and initiates error processing for the session. 
			RAISERROR can either reference a user-defined message stored in the sys.messages catalog view or 
			build a message dynamically. The message is returned as a server error message to the calling 
			application or to an associated CATCH block of a TRY…CATCH construct. New applications should 
				use THROW instead.
			Applies to: SQL Server (SQL Server 2008 through current version), Azure SQL Database.
			
			Syntax
				RAISERROR ( { msg_id | msg_str | @local_variable }
					{ ,severity ,state }
					[ ,argument [ ,...n ] ] )
					[ WITH option [ ,...n ] ]

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
		THROW (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ee677615.aspx

*/
--
-- code block begin
--------------------------------------------------------------------------
use [chamomile];

go

if schema_id(N'throw_vs_raiserror') is null
  execute (N'create schema throw_vs_raiserror');

go 
