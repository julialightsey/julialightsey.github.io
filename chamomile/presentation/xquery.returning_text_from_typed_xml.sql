/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------

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
*/
--
-- code block begin
/*
	A sample of a record from [chamomile].[repository_secure].[data].[entry]([chamomile].[xsc]) is shown below. 
	Returning text from a typed xml construct is a difficult issue.
	
	<chamomile:stack xmlns:chamomile="http://www.katherinelightsey.com/" persistent="true" timestamp="2014-07-11T19:58:03.553">
	  <subject name="[chamomile].[repository_secure].[data].[load.sql]">
		<description>Data pre-load script.</description>
	  </subject>
	  <object>
		<error name="[chamomile].[error].[stack].[prototype]" schema="error_procedure_schema" procedure="error_procedure" error_number="0" error_line="0" error_severity="0" error_state="0" timestamp="2014-07-11T19:58:03.553">
		  <description>prototype for [chamomile].[error].[stack]</description>
		  <error_message></error_message>
		  <application_message name="[message].[from].[application]">
			<description></description>
		  </application_message>
		</error>
	  </object>
	</chamomile:stack>
*/
declare @entry xml ([chamomile].[xsc]) = N'<chamomile:stack xmlns:chamomile="http://www.katherinelightsey.com/" persistent="true" timestamp="2014-07-11T19:58:03.553">
	  <subject name="[chamomile].[repository_secure].[data].[load.sql]">
		<description>Data pre-load script.</description>
	  </subject>
	  <object>
		<error name="[chamomile].[error].[stack].[prototype]" schema="error_procedure_schema" procedure="error_procedure" error_number="0" error_line="0" error_severity="0" error_state="0" timestamp="2014-07-11T19:58:03.553">
		  <description>prototype for [chamomile].[error].[stack]</description>
		  <error_message></error_message>
		  <application_message name="[message].[from].[application]">
			<description></description>
		  </application_message>
		</error>
	  </object>
	</chamomile:stack>';

--
-- this returns the correct result
-------------------------------------------------
select cast(@entry.query('declare namespace chamomile="http://www.katherinelightsey.com/";
					for $d in /chamomile:stack/*/description return $d').query(N'./*/text()') as [nvarchar](max)) as [description];

--
-- this returns nothing
-------------------------------------------------
select @entry.query('declare namespace chamomile="http://www.katherinelightsey.com/";
					(/chamomile:stack/*/description/*)') as [description];

--
-- this throws an exception
------------------------------------------------
select @entry.query('declare namespace chamomile="http://www.katherinelightsey.com/";
					(/chamomile:stack/*/description/text())') as [description];

--
-- test against [repository_secure].[data]		
-------------------------------------------------
-------------------------------------------------
--
-- this throws an exception
-------------------------------------------------
select [id]                                                                                                            as [id]
       , [entry]                                                                                                       as [entry]
       , [entry].query('declare namespace chamomile="http://www.katherinelightsey.com/";
					(/chamomile:stack/*/description/text())')                                                                  as [description]
       , [entry].query(N'declare namespace chamomile="http://www.katherinelightsey.com/";  (/chamomile:stack/object)') as [object]
from   [repository_secure].[data];

--
-- this returns nothing
-------------------------------------------------
select [id]                                                                                                            as [id]
       , [entry]                                                                                                       as [entry]
       , [entry].query('declare namespace chamomile="http://www.katherinelightsey.com/";
					(/chamomile:stack/*/description/*)')                                                                       as [description]
       , [entry].query(N'declare namespace chamomile="http://www.katherinelightsey.com/";  (/chamomile:stack/object)') as [object]
from   [repository_secure].[data];

--
-- this returns the correct result
-------------------------------------------------
select [id]                                                                                                            as [id]
       , [entry]                                                                                                       as [entry]
       , cast([entry].query('declare namespace chamomile="http://www.katherinelightsey.com/";
					for $d in /chamomile:stack/*/description return $d').query(N'./*/text()') as [nvarchar](max))              as [description]
       , [entry].query(N'declare namespace chamomile="http://www.katherinelightsey.com/";  (/chamomile:stack/object)') as [object]
from   [repository_secure].[data];

--
-- notice that this doesn't work, because the data in the cte is still typed data!
-------------------------------------------------
with [getter]
     as (select [entry] as [entry]
         from   [repository_secure].[data])
select [entry].query('declare namespace chamomile="http://www.katherinelightsey.com/";
					(/chamomile:stack/*/description/text())') as [description]
from   [getter];

--
-- notice that this does work as the data is converted to untyped xml when it's inserted into the table variable
--	 but it's a brute force way of doing the job.
-------------------------------------------------
declare @getter as table
  (
     [entry] [xml]
  );

insert into @getter
select [entry] as [entry]
from   [repository_secure].[data];

select [entry].query('declare namespace chamomile="http://www.katherinelightsey.com/";
					(/chamomile:stack/*/description/text())') as [description]
from   @getter; 
