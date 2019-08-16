/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	-- todo - check http://stackoverflow.com/questions/442503/bind-a-column-default-value-to-a-function-in-sql-2005
	-- IF someone wants to do it using the interface, typing
		[dbo].[NEWDOC_Order]()
		does the trick. You apparently need all brackets or it will reject your input.

	--
	--	description
	---------------------------------------------
		[verbose].[lower_case].[english_grammar].[bracketed].[separated_by_underscore].[consistent]

		[verbose]					- Use of abbreviations is avoided except in cases where the abbreviation
										is in common usage such as [id] in place of [identity], [us] in 
										place of [united_states], etc. Company specific abbreviations are
										avoided. Industry specific abbreviations are used as long as they
										are standard outside the company, such that new team members will
										be familiar with them if they have industry experience. A good test
										for this is an online search. If an online search does not turn up
										the abbreviation in the first page of results, don't use it.
		[lower_case]				- Use of all lower case letters removes the complexity involved in 
										systems that are case sensitive such as case sensitive sql collations.
										When case specific naming is used, the developer must remember which
										letters were capitalized; was it [Id], [id], or [ID]? [Database] or 
										[DataBase]? Using all lower case allows you to run your code through 
										through lower(@sql_code) prior to execution to ensure you do not
										experience failures due to case sensitivity.
		[english_grammar]			- Use of standard english grammar syntax simplifies the naming of objects.
										You "get data" rather than "data get", and "generate extended
										properties" rather than "extended properties generate". 
		[bracketed]					- 
		[separated_by_underscore]	- The underscore "_" is one of the few characters other than [a-zA-Z0-9]
										that is acceptable in the naming of objects in virtually every
										programming language. (Even then, as with numeric characters, it should
										not be used as the first character in an object name).
		[consistent]				- Use of common constructs simplifies the task of the developer. Knowing 
										that there will (virtually) always be an [id] column on a table
										that is the primary key of the table and an anchor for foreign key
										references simplifies the developers job dramatically. Similarly,
										using a [<schema>].[data] construct as the primary data repository
										for business data in the specified schema, and [<schema>].[set_data]
										and [<schema>].[get_data] as the primary mutator and accessor 
										simplifies the job of the developer. 

										[address].[data].[id] fully specifies the primary key of the primary
										data repository for addresses. [person].[data].[id] fully specifies
										the primary key of the primary data repository for persons. Use of 
										nomenclature such as [person].[individual_information].[individual_id]
										unnecessarily complicates code and serves no purpose. 

										Complexity must justify itself (http://www.katherinelightsey.com/#!8thlaw-complexity/cc4u)

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
		Using SQL Server Collations - http://msdn.microsoft.com/en-us/library/ms144260(v=sql.105).aspx
		Selecting a SQL Server Collation - http://msdn.microsoft.com/en-us/library/ms144250(v=sql.105).aspx
		SERVERPROPERTY (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms174396.aspx
	
		SQL Server Collation Fundamentals
		Microsoft® SQL Server™ 2000 supports several collations. A collation encodes the rules governing 
			the proper use of characters for either a language, such as Greek or Polish, or an alphabet, 
			such as Latin1_General (the Latin alphabet used by western European languages).
		Each SQL Server collation specifies three properties:
		The sort order to use for Unicode data types (nchar, nvarchar, and ntext). A sort order defines 
			the sequence in which characters are sorted, and the way characters are evaluated in comparison 
			operations.
		The sort order to use for non-Unicode character data types (char, varchar, and text).
		The code page used to store non-Unicode character data.
		Note  You cannot specify the equivalent of a code page for the Unicode data types (nchar, nvarchar, 
			and ntext). The double-byte bit patterns used for Unicode characters are defined by the Unicode 
			standard and cannot be changed.
		SQL Server 2000 collations can be specified at many levels. When you install an instance of SQL 
			Server 2000, you specify the default collation for that instance. Each time you create a 
			database, you can specify the default collation used for the database. If you do not specify 
			a collation, the default collation for the database is the default collation for the instance. 
			Whenever you define a character column, you can specify its collation. If you do not specify a 
			collation, the column is created with the default collation of the database. You cannot specify 
			a collation for character variables and parameters; they are always created with the default 
			collation of the database.
		If all of the users of your instance of SQL Server speak the same language, you should pick the 
			collation that supports that language. For example, if all of the users speak French, choose the 
			French collation.
*/
--
-- code block begin
-------------------------------------------------------------------------- 
use [chamomile];

go

if schema_id(N'collation_test') is null
  execute (N'create schema collation_test');

go

-------------------------------------------------------------------------- 
-- code block end
--
--
-- code block begin
-------------------------------------------------------------------------- 
use [master];

go

select distinct [objects].[name]
from   [sys].[all_objects] as [objects]
order  by [objects].[name];

-------------------------------------------------------------------------- 
-- code block end
--
--
-- code block begin
-------------------------------------------------------------------------- 
-- 
-- use of case in naming conventions means you have to KNOW how items are named! 
-- Is it "ID", "id", "Id", or "iD"? 
-------------------------------------------------------------------------- 
if object_id(N'[collation_test].[table_01]'
             , N'U') is not null
  drop table [collation_test].[table_01];

go

create table [collation_test].[table_01]
  (
     [id]          [int] identity(1, 1) not null primary key clustered
     , [firstname] [sysname]
     , [lastname]  [sysname]
  );

go

insert into [collation_test].[table_01]
            ([firstname],
             [lastname])
values      (N'Bob',
             N'Campbell'),
            (N'Mary',
             N'Oconnel');

go

select [firstname]
       , [lastname]
from   [collation_test].[table_01];

go

select [firstname]
       , [lastname]
from   [collation_test].[table_01];

go

-- 
-- use of lower case names for schema objects allows you to pass your sql 
-- code through the lower() function and avoid errors. 
-------------------------------------------------------------------------- 
if object_id(N'[collation_test].[table_01]'
             , N'U') is not null
  drop table [collation_test].[table_01];

go

create table [collation_test].[table_01]
  (
     [id]           [int] identity(1, 1) not null primary key clustered
     , [first_name] [sysname]
     , [last_name]  [sysname]
  );

go

declare @sql [nvarchar](max) = lower(N'insert into [collation_test].[table_01] 
            ([First_name],[Last_name])')
  + N' 
values      (''Bob'',''Campbell''), 
            (''Mary'',''Oconnel'');';

execute sp_executesql
  @sql;

go

select [id]
       , [first_name]
       , [last_name]
from   [collation_test].[table_01];

go

-- 
-- use of lower case names is easier to read when you need to normalize it with lower() 
-- note how much more difficult it is to read Pascal Case and Hungarian notation if you have 
-- to normalize them through the lower() function. 
-------------------------------------------------------------------------- 
declare @oracle_case       [sysname] = N'THIS_IS_AN_EXAMPLE_OF_ORACLE_CASE',
        @lower_oracle_case [sysname]=N'this_is_an_example_of_lower_oracle_case',
        @pascalcase        [sysname] = N'ThisIsAnExampleOfPascalCase',
        @ntnhungarian      [sysname]=N'ntnThisIsAnExampleOfHungarianNotation';

select @oracle_case
       , lower(@oracle_case)
       , @lower_oracle_case
       , lower(@lower_oracle_case)
       , @pascalcase
       , lower(@pascalcase)
       , @ntnhungarian
       , lower(@ntnhungarian);

go 
