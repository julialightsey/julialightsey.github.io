/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		XQuery is a complete languaged defined by the W3C and adopted, implemented, and extended by various organizations 
			such as Microsoft, Oracle, etc. in the same manner that the SQL language was adopted, implemented, and extended.

		[xml] can be used to store and present COMPLEX and HETEROGENEOUS data in a ROBUST and FLEXIBLE manner. XQUERY is the
		languaged used to manage [xml].

			HETEROGENOUS
			1. Different in kind; unlike; incongruous.
			2. Composed of parts of different kinds; having widely dissimilar elements or constituents.
			COMPLEX
			1. Composed of many interconnected parts; compound; composite.
			2. Characterized by a very complicated or involved arrangement of parts, units, etc.
			3. So complicated or intricate as to be hard to understand or deal with.
			ROBUST
			1. Capable of recovery: describes a computer program or system that is able to recover from unexpected 
				conditions during operation.
			2. Strongly constructed: built, constructed, or designed to be sturdy, durable, or hard-wearing.
			FLEXIBLE
			1. Able to adapt to new situation: able to change or be changed according to circumstances.
			2. Subject to influence: able to be persuaded or influenced.

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
		XQuery Language Reference (SQL Server): http://msdn.microsoft.com/en-us/library/ms189075.aspx
		Understanding [xml] in SQL Server: http://msdn.microsoft.com/en-us/library/bb522493(v=SQL.105).aspx
		[xml] Support in Microsoft SQL Server 2005: http://msdn.microsoft.com/en-us/library/ms345117(SQL.90).aspx 
		CREATE [xml] INDEX: http://msdn.microsoft.com/en-us/library/bb934097.aspx
		[xml] Indexes: http://msdn.microsoft.com/en-us/library/ms191497.aspx
		Data Type Coercions and the sql:datatype Annotation: http://msdn.microsoft.com/en-us/library/aa258643(v=SQL.80).aspx
		Writing Typed Data: http://msdn.microsoft.com/en-us/library/vstudio/bft97s8e(v=vs.100).aspx
		Mapping SQL datatypes to [xml] Schema datatypes:
			http://www.w3.org/2001/sw/rdb2rdf/wiki/Mapping_SQL_datatypes_to_XML_Schema_datatypes
		[xml] Schema Definition Tool (Xsd.exe): http://msdn.microsoft.com/en-us/library/x6c1kb0s(v=VS.71).aspx
			(Installed in \\dfs.com\root\Dept-IT\_EDM\users\KatherineELightsey\Tools\XSD)
		W3C [xml] Query (XQuery): http://www.w3.org/[xml]/Query/
		XQUERY Wiki: http://en.wikipedia.org/wiki/XQuery
		Create Indexes with Included Columns: http://msdn.microsoft.com/en-us/library/ms190806(v=sql.110).aspx
		W3C [xml] Query (XQuery): http://www.w3.org/[xml]/Query/
		FLWOR Statement and Iteration (XQuery) - http://msdn.microsoft.com/en-us/library/ms190945.aspx
		XQuery - http://www.datypic.com/books/xquery/chapter07.html
*/
--
-- BUILD TEST DATA
-- Build test data for this presentation
-------------------------------------------------
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
use [chamomile_oltp];

go

if Schema_id(N'xquery_demo') is null
  execute (N'create schema xquery_demo');

go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- DROP ALL OBJECTS
--------------------------------------------------------------------------
if object_id('[xquery_demo].[set.log]'
             , N'P') is not null
  drop procedure [xquery_demo].[set.log];

go 

if object_id(N'[xquery_demo].[address]'
             , N'U') is not null
  drop table [xquery_demo].[address];

go

if object_id(N'[xquery_demo].[get_person]'
             , N'FN') is not null
  drop function [xquery_demo].[get_person];

go

if object_id(N'[xquery_demo].[log]'
             , N'U') is not null
  drop table [xquery_demo].[log];

go

if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_log'
                  and xsc.schema_id = Schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].[xsd_log];

go

if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_log_business_application_01'
                  and xsc.schema_id = Schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].[xsd_log_business_application_01];

go

if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_log_business_application_02'
                  and xsc.schema_id = Schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].xsd_log_business_application_02;

go

if object_id('[xquery_demo].[set.log]'
             , N'P') is not null
  drop procedure [xquery_demo].[set.log];

go

if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_test_02'
                  and xsc.schema_id = Schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].[xsd_test_02];

go

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog] on [xquery_demo].[log];

go

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog_value'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog_value] on [xquery_demo].[log];

go

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog_property]'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog_property] on [xquery_demo].[log];

go

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog_path]'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog_path] on [xquery_demo].[log];

go

if object_id(N'[xquery_demo].[address]'
             , N'U') is not null
  drop table [xquery_demo].[address];

go

if object_id(N'[xquery_demo].pr_application'
             , N'P') is not null
  drop procedure [xquery_demo].[pr_application];

go

if object_id(N'[xquery_demo].[test02]'
             , N'U') is not null
  drop table [xquery_demo].[test02];

go

if exists(select *
          from   sys.triggers as trg
          where  trg.name = N'tr_DocumentationRepositoryUpdate')
  drop trigger [tr_documentationrepositoryupdate] on database;

go

if object_id(N'[xquery_demo].[get]'
             , N'FN') is not null
  drop function [xquery_demo].[get];

go

if object_id(N'[xquery_demo].[pr_get]'
             , N'U') is not null
  drop procedure [xquery_demo].[pr_get];

go

if object_id(N'[xquery_demo].[get_xml_data]'
             , N'U') is not null
  drop procedure [xquery_demo].[get_xml_data];

go 
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
use [chamomile_oltp];
go
truncate table [address].[sample_data];
go
if schema_id(N'address') is null
execute (N'create schema address');
go
if object_id(N'[address].[sample_data]', N'U') is not null
  drop table [address].[sample_data];
go
create table [address].[sample_data] (
  [name]      [nvarchar](250) null
  , [street_01] [nvarchar](250) null
  , [city]      [nvarchar](250) null
  , [email]     [nvarchar](250) null
  );
go 
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- http://www.generatedata.com/
--	bcp [address].[sample_data] format nul -c -x -f address.sample_data.xml -t, -d chamomile_oltp -T -S MCK790L8159\CHAMOMILE
--	bcp [address].[sample_data] in chamomile.presentation.xquery_sample_data.pdv -d chamomile_oltp -T -F 2 -f address.sample_data.xml -S MCK790L8159\CHAMOMILE
-------------------------------------------------
select * from  [address].[sample_data];
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------

-- 
-- CREATE A UTILITY FUNCTION TO BUILD A TEST [xml] TREE
-- The utility function will be used throughout this presentation to build an [xml] tree to demonstrate methods on
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
if schema_id(N'xquery_demo') is null
  execute (N'create schema xquery_demo');
go
if object_id(N'[xquery_demo].[get_person]', N'FN') is not null
  drop function [xquery_demo].[get_person];
go
create function [xquery_demo].[get_person]()
returns [xml]
as
  begin
      declare @return [xml] = (select [address].[name]        as N'@name'
                , [address].[street_01] as N'@street_01'
                , [address].[city]      as N'@city'
                , [address].[email]     as N'@email'
         from   [address].[sample_data] as [address]
         order  by [address].[name]
         for xml path('address'), root ('address_tree'));
      return @return;
  end;
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- Now test data can be accessed by a straight select or by declaration of a variable
-------------------------------------------------
declare @address [xml] = [xquery_demo].[get_person]();
select @address                                                 as [@address]
       , [xquery_demo].[get_person]()                           as [function_call]
       , convert([nvarchar](max), [xquery_demo].[get_person]()) as [nvarchar_data];
go 

-------------------------------------------------
-- code block end
--
--  XQUERY CONSISTS OF FIVE METHODS - query(), value(), exist(), nodes(), modify();
--
-- code block begin
-------------------------------------------------
--
-- FILTERED DATA
-- The query() method
-------------------------------------------------
declare @address [xml] = [xquery_demo].[get_person]();
select @address.query('address_tree/address[@name="Odette"]');
select [xquery_demo].[get_person]().query('address_tree/address[@city="Morrinsville"]');
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
--
-- NOTE THAT THIS DOES NOT WORK!!!! XQUERY IS CASE SENSITIVE
-------------------------------------------------
declare @address [xml] = [xquery_demo].[get_person]();
select @address.query('address_tree/address[@city="morrinsville"]');
go 

-------------------------------------------------
-- code block end
--
-------------------------------------------------
-- MULTIPLE FILTERS
-- The query() method
-- Multiple filters can be used within one query
-------------------------------------------------
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
select [xquery_demo].[get_person]().query('address_tree/address[@name="Fiona"]');
select [xquery_demo].[get_person]().query('address_tree/address[@name="Fiona"][@city="Eghezee"]');
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @address [xml] = [xquery_demo].[get_person]();
select t.c.query(N'.')
from   @address.nodes(N'/address_tree/address[@name="Fiona"]') as t(c);
select t.c.query(N'.')
from   @address.nodes(N'/address_tree/address[@name="Fiona"][@city="Eghezee"]') as t(c);
go
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- retrieving data from explicit or implicit locations
-------------------------------------------------
declare @address [xml] = [xquery_demo].[get_person]();
--
-- explicitly state the node
-------------------------------------------------
select t.c.query(N'.')
from   @address.nodes(N'/address_tree/address[@name="Fiona"][@city="Eghezee"]') as t(c);
--
-- get data from any second level address
-------------------------------------------------
select t.c.query(N'.')
from   @address.nodes(N'/*/address[@name="Fiona"][@city="Eghezee"]') as t(c);
--
-- get from any third level node that has a "name" attribute
-------------------------------------------------
select t.c.query(N'.')
from   @address.nodes(N'/*/*[@name="Fiona"][@city="Eghezee"]') as t(c);
--
-- get from any node anywhere that has a "name" attribute
-------------------------------------------------
select t.c.query(N'.')
from   @address.nodes(N'//*[@name="Fiona"][@city="Eghezee"]') as t(c);
go
-------------------------------------------------
-- code block end
--

if schema_id(N'person') is null
  execute (N'create schema person');
go
if object_id(N'[person].[call_log]', N'U') is not null
  drop table [person].[call_log];
go
create table [person].[call_log] (
  [id]    [int] identity(1, 1) not null constraint [person.call_log.id.clustered_primary_key] primary key clustered
  , [log] [xml]
  );
go
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @log       xml = [xquery_demo].[get_person]().query('address_tree/address[@name="Fiona"][@city="Eghezee"]')
        , @contact [xml] = N'<contact_record timestamp="' + @timestamp
          + N'">She called, we answered.</contact_record>';
set @log.modify(N'insert sql:variable("@contact") as last into (/*)[1]');
insert into [person].[call_log]
            ([log])
values      (@log);
--
select @log = [xquery_demo].[get_person]().query('address_tree/address[@name="Sasha"][@city="Inuvik"]')
       , @contact = N'<contact_record timestamp="' + @timestamp
                    + N'">She does not like the cold weather</contact_record>';
set @log.modify(N'insert sql:variable("@contact") as last into (/*)[1]');
insert into [person].[call_log]
            ([log])
values      (@log);
select [id]
       , [log]
from   [person].[call_log]; 















-- code block end


-- begin code block
-- find nodes by local name
declare @address [xml] = N'
		<test_stack object_count="0" test_count="0" pass_count="0" environment="[LOIS].[LOIS].[KATE_01].[chamomile].[test].[run].[LOIS]" user="Lois\Katherine" timestamp="2014-02-13 16:46:11.327">
		  <log xmlns:noetic="http://www.katherinelightsey.com/" user="Lois\Katherine" timestamp="2014-02-13T16:46:11.33">
			<object_fqn environment="[LOIS].[LOIS].[KATE_01].[chamomile].[utility_test].[log.xsc]" />
			<log_entry object_type="result">
			  <any_valid_xml>test<no_matter /><how_complex>it is</how_complex></any_valid_xml>
			</log_entry>
		  </log>
		  <log user="Lois\Katherine" timestamp="2014-02-13T16:46:11.333">
			<object_fqn environment="[LOIS].[LOIS].[KATE_01].[chamomile].[utility_test].[log.set]" />
			<log_entry object_type="result">
			  <any_valid_xml>test<no_matter /><how_complex>it is</how_complex></any_valid_xml>
			</log_entry>
		  </log>
		</test_stack>';

select @address.exist('//*[local-name()="log_entry"]');

select @address.value('(//*[local-name()="log_entry"]/@object_type)[1]'
                          , N'[sysname]');

select @address.query('//*[local-name()="log_entry"][@object_type="result"]');

select @address.value('count (//*[local-name()="log_entry"][@object_type="result"])[1]'
                          , N'[int]');
go
-- end code block


-------------------------------------------------
-------------------------------------------------
-- USING THE VALUE() METHOD: SUM AND COUNT
-- [xml] FUNCTIONS: http://msdn.microsoft.com/en-us/library/ms189254.aspx
-- Some of the [xml] functions available include ceiling, floor, round, concat, contains, substring, lower-case,
--	string-length, upper-case, not, number, local-name, namespace-uri, last, position, empty, distinct-values,
--	id, count, avg, min, max, sum, string, data, true, false, expanded-QName, local-name-from-QName,
--	namespace-uri-from-QName, sql:column(), sql:variable().
-------------------------------------------------
-------------------------------------------------
-- begin code block
declare @address [xml] = [xquery_demo].[get_person]();
select @address;

--
-- Use the "sum" function to get the sum of all bonuses
select @address.value('sum (/address_tree/address/@bonus)'
                          , 'float');

--
-- Use the "count" function to get the count of all sales persons
select @address.value('count (/address_tree/address)'
                          , '[int]');

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
-- BUILDING A TREE - ADDING NODES AND ATTRIBUTES AND GETTING SUM AND COUNT
-- The modify() methods
-- Using modify() to add data to a tree
-------------------------------------------------
-------------------------------------------------
-- begin code block
declare @address [xml] = [xquery_demo].[get_person]();
--
-- build sum and count to insert as attributes into address
declare @sum numeric(38, 2) = @address.value('sum (/address_tree/address/@bonus)'
                     , 'float');
declare @count [int] = @address.value('count (/address_tree/address)'
                     , '[int]');
--
-- build two new trees to insert into address
declare @new_tree [xml] = N'<new_tree><level_01 data="some data"><level_02>Data goes in level 2</level_02></level_01></new_tree>';
declare @another_new_tree [xml] = N'<another_new_tree has_data="maybe">But do you care?</another_new_tree>';

--
-- Insert the new objects
set @address.modify('insert attribute sales_person_count {sql:variable("@count")} as first into (/address_tree)[1]');
set @address.modify('insert attribute sum_of_bonuses {sql:variable("@sum")} as last into (/address_tree)[1]')
set @address.modify('insert sql:variable("@new_tree") as first into (/address_tree)[1]');
set @address.modify('insert sql:variable("@another_new_tree") after (/address_tree/new_tree/level_01)[1]');
set @address.modify(N'insert text {"free text goes here"} as last into (/address_tree/new_tree)[1]');

select @address as N'Complete New Tree';

set @address.modify(N'replace value of (/address_tree/new_tree/text())[1] with "modified text goes here"');

select @address as N'Modified New Tree';

declare @n [sysname] = N' - adding text to existing text';

set @address.modify(N'insert text {sql:variable("@n")} as last into (/address_tree/new_tree)[1]');

select @address as N'Modified New Tree with added text';

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
-- BUILDING A TREE - DELETING ATTRIBUTES, ELEMENTS, AND ELEMENT TEXT
-- The  modify() method
-- modify() to remove data from a tree
-------------------------------------------------
-------------------------------------------------

-- begin code block
declare @address     [xml] = [xquery_demo].[get_person]()
        , @modified_tree [xml];
--
-- build two new trees to add to address
declare @new_tree [xml] = N'<new_tree><level_01 data="some data"><Level2>Data goes in level 2</Level2></level_01></new_tree>';
declare @another_new_tree [xml] = N'<another_new_tree hasdata="maybe">But do you care?</another_new_tree>';

--
-- Insert the new trees into address
set @address.modify('insert sql:variable("@new_tree") as first into (/address_tree)[1]');
set @address.modify('insert sql:variable("@another_new_tree") after (/address_tree/new_tree/level_01)[1]');
--
-- Build a modified tree
set @modified_tree=@address;
--
-- Deleting an attribute
set @modified_tree.modify('delete /address_tree/new_tree/level_01/@data');
--
-- Deleting text in a node
set @modified_tree.modify('delete /address_tree/new_tree/another_new_tree/text()');
--
-- Deleting a node
set @modified_tree.modify('delete /address_tree/new_tree/another_new_tree[1]');
set @modified_tree.modify('delete /address_tree/address[@name="LORETTA"] [@last_name="ALLEN"]');

select @address     as N'Complete New Tree'
       , @modified_tree as N'Deleted /address_tree/new_tree/another_new_tree/text()'

go 
-- end code block

--
-- begin
-- deleting all nodes in a tree based on a sub-node or attribute on a sub node
-------------------------------------------------
declare @sequence        [int] = 99
        , @entry_builder xml = N'<chamomile:stack xmlns:chamomile="http://www.katherinelightsey.com/" persistent="false" timestamp="2014-07-18T14:16:00.7" id="DEDCD4E5-AE0E-E411-A934-20689D66B6F7">
  <subject fqn="[mck790l8159].[mck790l8159].[chamomile].[chamomile].[repository].[set]">
    <description>created by [mck790l8159].[mck790l8159].[chamomile].[chamomile].[repository].[set]</description>
  </subject>
  <object>
    <documentation fqn="[chamomile].[job].[get_change]" stale="false" timestamp="2014-07-18T13:56:57.76">
      <text sequence="99">this job is the stuff, and here is some more stuff!</text>
    </documentation>
    <documentation fqn="[chamomile].[job].[get_change]" stale="false" timestamp="2014-07-18T13:56:57.76">
      <text sequence="99">this job is the stuff, and here is some more stuff! and yet more!</text>
    </documentation>
    <documentation fqn="[chamomile].[job].[get_change]" stale="false" timestamp="2014-07-18T13:56:57.76">
      <text sequence="99">this job is the stuff, and here is some more stuff! and yet more!</text>
    </documentation>
  </object>
  <result>
    <description>Description of result</description>
  </result>
</chamomile:stack>';
set @entry_builder.modify('delete */object/documentation[text/@sequence=sql:variable("@sequence")]');
select @entry_builder; 
-- end
--
-- Deleting multiple records
-------------------------------------------------
-- begin code block
declare @address    [xml] = [xquery_demo].[get_person]()
        , @modified_tree [xml];

set @modified_tree=@address;
set @modified_tree.modify('delete /address_tree/address[@name="David"]');

select @address.value('count (/address_tree/address[@name="David"])'
                          , '[int]')    as N'How many Kenny''s were there?'
       , @modified_tree.value('count (/address_tree/address[@name="David"])'
                             , '[int]') as N'How many David''s are left?';

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
-- EXTRACTING RELATIONAL DATA FROM A TREE
-- The nodes() method.
-- Used to parse an [xml] tree into relational data.
-- Using the nodes() method you can parse a tree into individual nodes (elements) then use either
--	the value() or query() methods to extract data.
-- NO ONE EVER HAS TO KNOW THE DATA IS REALLY STORED IN [xml]!
-------------------------------------------------
-------------------------------------------------
-- begin code block
declare @address [xml] = [xquery_demo].[get_person]();

select t.c.value('./@name,'
                 , '[sysname]')   as N'name'
       , t.c.value('./@last_name,'
                   , '[sysname]') as N'last_name'
       , t.c.value('./@name,'
                   , '[sysname]') as N'name'
       , t.c.value('./@address,'
                   , '[sysname]') as N'address'
       , t.c.value('./@city,'
                   , '[sysname]') as N'city'
       , t.c.value('./@zip_code,'
                   , '[sysname]') as N'zip_code'
       , t.c.value('./@bonus'
                   , '[sysname]') as N'bonus'
from   @address.nodes('/address_tree/address') t(c);

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
-- EXTRACTING RELATIONAL DATA FROM A TREE USING A FILTER
-- The nodes() method
-- Used to parse an [xml] tree into relational data
-- May include filters
-------------------------------------------------
-------------------------------------------------
-- begin code block
declare @address [xml] = [xquery_demo].[get_person]();

select t.c.value('./@name,'
                 , '[sysname]')   as N'name'
       , t.c.value('./@last_name,'
                   , '[sysname]') as N'last_name'
       , t.c.value('./@name,'
                   , '[sysname]') as N'name'
       , t.c.value('./@address,'
                   , '[sysname]') as N'address'
       , t.c.value('./@city,'
                   , '[sysname]') as N'city'
       , t.c.value('./@zip_code,'
                   , '[sysname]') as N'zip_code'
       , t.c.value('./@bonus'
                   , '[sysname]') as N'bonus'
from   @address.nodes('/address_tree/address[@last_name="Tsoflias"]') t(c);

go 
-- end code block

--
-- May include multiple filters
-- begin code block
declare @address [xml] = [xquery_demo].[get_person]();

select t.c.value('./@name,'
                 , '[sysname]')   as N'name'
       , t.c.value('./@last_name,'
                   , '[sysname]') as N'last_name'
       , t.c.value('./@name,'
                   , '[sysname]') as N'name'
       , t.c.value('./@address,'
                   , '[sysname]') as N'address'
       , t.c.value('./@city,'
                   , '[sysname]') as N'city'
       , t.c.value('./@zip_code,'
                   , '[sysname]') as N'zip_code'
       , t.c.value('./@bonus'
                   , '[sysname]') as N'bonus'
from   @address.nodes('/address_tree/address[@state="Washington"][@bonus gt 1000]') t(c);

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
-- DETERMINE IF A NODE OR LEAF EXISTS
-- The exist() method
-------------------------------------------------
-------------------------------------------------

-- begin code block
declare @address        [xml] = [xquery_demo].[get_person]()
        , @address_tree [sysname] = N'address_tree'
        , @not_here_node    [sysname] = N'not_here_node';

select
--
-- Determine if there is a node named address_tree
case @address.exist('//*[local-name()=sql:variable("@address_tree")]')
    when 1
        then
      N'There is an address_tree as it should be!'
    else
      N'There is no address_tree bute there should be!'
end   as N'address_tree exists'
--
-- Determine if there is a node named not_here_node
, case @address.exist('//*[local-name()=sql:variable("@not_here_node")]')
      when 1
          then
        N'There is an not_here_node but it should notbe!'
      else
        N'There is no not_here_node nor should there be!'
  end as N'not_here_node does not exist'
--
-- Determine if there are elements with the name attribute of BOBBY
, case @address.exist('address_tree/address[@name="Ranjit"]')
      when 1
          then
        N'There are some Ranjit''s!'
      else
        N'No Ranjit''s!'
  end as N'first_name_Ranjit'
--
-- Determine if there is an element with name="KATHERINE" and @last_name="LIGHTSEY"
, case @address.exist('address_tree/address[@name="Stephen"] [@last_name="Jiang"]')
      when 1
          then
        N'Stephen Jiang was here!'
      else
        N'We haven''t seen Stephen!'
  end as N'Was Stephen Here?'
,
--
-- Determine if there is a tree element of NotReallyHere
case @address.exist('address_tree/NotReallyHere')
      when 1
          then
        N'This isn''t supposed to be here!'
      else
        N'No! NotReallyHere really isn''t here!'
  end as N'Is NotReallyHere here?'
,
--
-- Determine if there is a tree element of NewNode
case @address.exist('address_tree/NewNode')
      when 1
          then
        N'NewNode is here but it is not supposed to be!'
      else
        N'No! NewNode is not supposed to be here!'
  end as N'Is NewNode here?';

go 
-- end code block


-------------------------------------------------
-------------------------------------------------
-- REAL WORLD EXAMPLE
-- A logging address - Used to allow heterogenous applications to log heterogenous and complex data.
-------------------------------------------------
-------------------------------------------------

-- begin code block
if object_id(N'[xquery_demo].[log]'
             , N'U') is not null
  drop table [xquery_demo].[log];

go

create table [xquery_demo].[log] (
  [id]      [int] identity (1, 1) not null primary key clustered
  , [entry] [xml] not null
  );

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log>log data goes here</log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log timestamp="'
             + cast(current_timestamp as [sysname])
             + '" ><business_application_01>
	<table group="job_group" address="application_01" table="table_name" >
		<job job_name="job_name" author="klightsey" >
			<notes_tree>
				<note>note text</note>
				<note>note text</note>
			</notes_tree>
		</job>
	</table></business_application_01></log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log ><business_application_01>
	<table table="table_name" >
			<notes_tree>
				<note>note text</note>
				<note>note text</note>
			</notes_tree>
	</table></business_application_01></log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log><ssis job_name="ssisjob1" /><problem>Well here is your problem!</problem></log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log><ssis job_name="ssisjob1" /><problem>The crankshaft broke!</problem></log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log><ssis job_name="ssisjob1" /><problem>Help! I have fallen and I cannot get up!</problem></log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log address="ssis" timestamp="'
             + cast(current_timestamp as varchar(4000))
             + '"><ssis job_name="ssisjob2" /><problem>Another problem!</problem></log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log address="ssis" timestamp="'
             + cast(current_timestamp as varchar(4000))
             + '"><ssis job_name="ssisjob2" /><problem>Many problems here!</problem></log>');

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log address="ssis" timestamp="'
             + cast(current_timestamp as varchar(4000))
             + '" test="test"><ssis job_name="ssisjob2" /><problem>Katherine ran out of stuff to type about!</problem></log>');

go

declare @log_entry [xml] = N'<log timestamp="'
  + cast(current_timestamp as [sysname])
  + '" >
<business_application_01>
	<table  group="ACCOUNTING_LOAD" address="FINANCE" table="table" >
		<job job_name="job_name2" author="klightsey" >
			<notes_tree>
				<note>notes notes 1</note>
				<note> notes 2</note>
				<note>SQL_ND_PR_CASHCOLLECTIONTOTALS notes 3</note>
			</notes_tree>
		</job>
	</table>
</business_application_01></log>';

insert into [xquery_demo].[log]
            ([entry])
values      (@log_entry);

go

declare @log_entry [xml] = N'<log timestamp="'
  + cast(current_timestamp as [sysname])
  + '" >
  <business_application_01>
  	<table  group="job_group" address="FINANCE" table="table" >
  		<job job_name="DUM_ND_ACCOUNTING_LOAD_BRIDGE" author="klightsey" >
  			<notes_tree>
  				<note> notes 1</note>
  				<note>notes 2</note>
  			</notes_tree>
  		</job>
  	</table>
  </business_application_01></log>';

insert into [xquery_demo].[log]
            ([entry])
values      (@log_entry);

go

--
-- Insert two jobs
declare @log_entry [xml] = N'<log timestamp="'
  + cast(current_timestamp as [sysname])
  + '" >
  <business_application_01>
  	<table  group="job group" address="FINANCE" table="table" >
  		<job job_name="job name" author="klightsey" >
  			<notes_tree>
  				<note>job name notes 1</note>
  			</notes_tree>
  		</job>
  	</table>
  </business_application_01></log>';

insert into [xquery_demo].[log]
            ([entry])
values      (@log_entry);

go

declare @log_entry [xml] = N'<log timestamp="'
  + cast(current_timestamp as [sysname])
  + '" >
  <business_application_01>
  	<table  group="job group" address="FINANCE" table="table" >
  		<job job_name="job name" author="klightsey" >
  			<notes_tree>
  				<note> notes 1</note>
  			</notes_tree>
  		</job>
  	</table>
  </business_application_01></log>';

insert into [xquery_demo].[log]
            ([entry])
values      (@log_entry);

go

declare @log_entry [xml] = N'<log timestamp="'
  + cast(current_timestamp as [sysname])
  + '" >
  <business_application_01>
  	<table  group="job group" address="FINANCE" table="table" >
  		<job job_name="job name" author="klightsey" >
  			<notes_tree>
  				<note> notes on another job</note>
  			</notes_tree>
  		</job>
  	</table>
  </business_application_01></log>';

insert into [xquery_demo].[log]
            ([entry])
values      (@log_entry);

select [entry]
from   [xquery_demo].[log];

select [entry]
from   [xquery_demo].[log]
where  [entry].value('local-name((/log/*)[1])'
                     , '[sysname]') = N'business_application_01';

select [entry]
from   [xquery_demo].[log]
where  [entry].value('(/log/business_application_01/table/job/@job_name)[1]'
                     , '[sysname]') = N'job name';

select [entry]
from   [xquery_demo].[log]
where  [entry].value('(/log/business_application_01/table/@group)[1]'
                     , '[sysname]') = N'job group';
-- end code block

  
  -------------------------------------------------
  -------------------------------------------------
  -- USING TYPED [xml] TO ENSURE DATA CONFORMS TO REQUIREMENTS
  -- Using a schema to ensure data types.
  -- [xml] Schema Definition Tool (Xsd.exe): http://msdn.microsoft.com/en-us/library/x6c1kb0s(v=VS.71).aspx
  --	(Installed in \\dfs.com\root\Dept-IT\_EDM\users\KatherineELightsey\Tools\XSD)
  -- http://www.w3.org/[xml]/Schema: [xml] Schemas express shared vocabularies and allow machines to carry out rules made by people. 
  --	They provide a means for defining the structure, content and semantics of [xml] documents.
  -- note that [xml] SCHEMA is different from [xml] STYLESHEETS! [xml] STYLESHEETS are a set of processing instructions.
  -- http://www.w3.org/TR/[xml]-stylesheet/: This document allows style sheets to be associated with an [xml] document by 
  --	including one or more processing instructions with a target of [xml]-stylesheet in the document's prolog.
  -------------------------------------------------
  -------------------------------------------------

-- begin code block

  --
  -- Without typed data we can still insert garbage into [xquery_demo].[log]
insert into [xquery_demo].[log]
            ([entry])
values      (N'<SomethingCompletelyDifferent>Garbage data</SomethingCompletelyDifferent>');

--
-- Create an [xml] SCHEMA COLLECTION which specifies the minimum requirements for [xquery_demo].[log]
if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_log'
                  and xsc.schema_id = schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].[xsd_log];

go 

create xml schema collection [xquery_demo].[xsd_log] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="NewDataSet">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:choice minOccurs="0" maxOccurs="unbounded">
            <xsd:element ref="log" />
          </xsd:choice>
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
  <xsd:element name="log">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="business_application_01" maxOccurs="unbounded">
              <xsd:complexType>
                <xsd:complexContent>
                  <xsd:restriction base="xsd:anyType">
                    <xsd:sequence>
                      <xsd:element name="table" maxOccurs="unbounded">
                        <xsd:complexType>
                          <xsd:complexContent>
                            <xsd:restriction base="xsd:anyType">
                              <xsd:sequence>
                                <xsd:element name="job" maxOccurs="unbounded">
                                  <xsd:complexType>
                                    <xsd:complexContent>
                                      <xsd:restriction base="xsd:anyType">
                                        <xsd:sequence>
                                          <xsd:element name="notes_tree" maxOccurs="unbounded">
                                            <xsd:complexType>
                                              <xsd:complexContent>
                                                <xsd:restriction base="xsd:anyType">
                                                  <xsd:sequence>
                                                    <xsd:element name="note" maxOccurs="unbounded" nillable="true">
                                                      <xsd:complexType>
                                                        <xsd:simpleContent>
                                                          <xsd:extension base="xsd:string" />
                                                        </xsd:simpleContent>
                                                      </xsd:complexType>
                                                    </xsd:element>
                                                  </xsd:sequence>
                                                </xsd:restriction>
                                              </xsd:complexContent>
                                            </xsd:complexType>
                                          </xsd:element>
                                        </xsd:sequence>
                                        <xsd:attribute name="job_name" type="xsd:string" use="required" />
                                        <xsd:attribute name="author" type="xsd:string" />
                                      </xsd:restriction>
                                    </xsd:complexContent>
                                  </xsd:complexType>
                                </xsd:element>
                              </xsd:sequence>
                              <xsd:attribute name="group" type="xsd:string" use="required" />
                              <xsd:attribute name="address" type="xsd:string" use="required" />
                              <xsd:attribute name="table" type="xsd:string" use="required" />
                            </xsd:restriction>
                          </xsd:complexContent>
                        </xsd:complexType>
                      </xsd:element>
                    </xsd:sequence>
                  </xsd:restriction>
                </xsd:complexContent>
              </xsd:complexType>
            </xsd:element>
          </xsd:sequence>
          <xsd:attribute name="timestamp" type="xsd:string" use="required" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>';

go

select xml_schema_namespace(N'xquery_demo'
                            , N'xsd_log');

go
-- end code block

-- begin code block
--
-- Recreate [xquery_demo].[log] specifying column [entry] as TYPED [xml] using created
if object_id(N'[xquery_demo].[log]'
             , N'U') is not null
  drop table [xquery_demo].[log];

go

create table [xquery_demo].[log] (
  [id]          [int] identity(1, 1) not null primary key clustered
  , [entry]     xml ([xquery_demo].[xsd_log])
  );

go

insert into [xquery_demo].[log]
            ([entry])
values      (N'<log timestamp="'
             + cast(current_timestamp as [sysname])
             + '" >
  <business_application_01>
  	<table  group="job group" address="FINANCE" table="table" >
  		<job job_name="job name" author="klightsey" >
  			<notes_tree>
  				<note> notes on another job</note>
  			</notes_tree>
  		</job>
  	</table>
  </business_application_01></log>');

select [id]
       , [entry]
from   [xquery_demo].[log];

go 
-- end code block

-- begin code block
--
-- job_name is required!
insert into [xquery_demo].[log]
            ([entry])
values      (N'<log timestamp="'
             + cast(current_timestamp as [sysname])
             + '" >
  <business_application_01>
  	<table  group="group name" address="FINANCE" table="table" >
  		<job  author="klightsey" >
  			<notes_tree>
  				<note>notes on another job</note>
  			</notes_tree>
  		</job>
  	</table>
  </business_application_01></log>');
-- end code block

-- begin code block

--
-- timestamp is required!
insert into [xquery_demo].[log]
            ([entry])
values      (N'<log >
  <business_application_01>
  	<table  group="ACS_PAYMENT" address="FINANCE" table="D_ACS_PAYMENT" >
  		<job job_name="FTR_ND_ACS_PAYMENT" author="klightsey" >
  			<notes_tree>
  				<note>CMD_ND_ACS_PAYMENT_LASERUTIL notes on another job</note>
  			</notes_tree>
  		</job>
  	</table>
  </business_application_01></log>'); 
-- end code block


  
-------------------------------------------------
-------------------------------------------------
-- Setting up the logging table to allow entries of multiple types
-------------------------------------------------
-------------------------------------------------

-- begin code block
if object_id(N'[xquery_demo].[log]'
             , N'U') is not null
  drop table [xquery_demo].[log];

go

create table [xquery_demo].[log] (
  [id]    [int] identity primary key
  , [entry] [xml]
  );

go

if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_log'
                  and xsc.schema_id = schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].[xsd_log];

go 

create xml schema collection [xquery_demo].[xsd_log] as N'<?xml version="1.0" encoding="utf-16"?>
<xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:[xml]-msdata">
  <xs:element name="log">
    <xs:complexType>
      <xs:sequence>
        <xs:any minOccurs="0" maxOccurs="unbounded"
          processContents="lax"/>
      </xs:sequence>
      <xs:attribute name="timestamp" type="xs:string" use="required" />
    </xs:complexType>
  </xs:element>
  <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:UseCurrentLocale="true">
    <xs:complexType>
      <xs:choice minOccurs="0" maxOccurs="unbounded">
        <xs:element ref="log" />
      </xs:choice>
    </xs:complexType>
  </xs:element>
</xs:schema>';

go 
declare @x [xml] ([xquery_demo].[xsd_log]) = N'<log timestamp="'
  + cast(current_timestamp as [sysname]) + '" />';

select @x;

go 
declare @x [xml] ([xquery_demo].[xsd_log]) = N'<log timestamp="'
  + cast(current_timestamp as [sysname]) + '" />';

set @x= N'<log timestamp="'
        + cast(current_timestamp as [sysname])
        + '" ><business_application_01 /></log>';

select @x
       , t.c.query('.') as result
from   @x.nodes('/log/*') t(c); 
-- end code block

-------------------------------------------------
-------------------------------------------------
-- TYPED [xml] PARAMETERS
-- Using a schema to ensure that a parameter is loaded with TYPED [xml] data
-------------------------------------------------
-------------------------------------------------

-- begin code block
if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_log_business_application_01'
                  and xsc.schema_id = schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].[xsd_log_business_application_01];

go 

create xml schema collection [xquery_demo].[xsd_log_business_application_01] as N'<?xml version="1.0" encoding="utf-16"?>
<xs:schema id="business_application_01" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:[xml]-msdata">
  <xs:element name="business_application_01" msdata:IsDataSet="true" msdata:UseCurrentLocale="true">
    <xs:complexType>
      <xs:choice minOccurs="1" maxOccurs="unbounded">
        <xs:element name="table">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="job" minOccurs="1" maxOccurs="unbounded">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="notes_tree" minOccurs="1" maxOccurs="unbounded">
                      <xs:complexType>
                        <xs:sequence>
                          <xs:element name="note" nillable="true" minOccurs="1" maxOccurs="unbounded">
                            <xs:complexType>
                              <xs:simpleContent msdata:ColumnName="note_text" msdata:Ordinal="0">
                                <xs:extension base="xs:string">
                                </xs:extension>
                              </xs:simpleContent>
                            </xs:complexType>
                          </xs:element>
                        </xs:sequence>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                  <xs:attribute name="job_name" type="xs:string" use="required" />
                  <xs:attribute name="author" type="xs:string" use="required" />
                </xs:complexType>
              </xs:element>
            </xs:sequence>
            <xs:attribute name="group" type="xs:string" use="required" />
            <xs:attribute name="address" type="xs:string" use="required" />
            <xs:attribute name="table" type="xs:string" use="required" />
          </xs:complexType>
        </xs:element>
      </xs:choice>
    </xs:complexType>
  </xs:element>
</xs:schema>';

go 

if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_log_business_application_02'
                  and xsc.schema_id = schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].xsd_log_business_application_02;

go 
create xml schema collection [xquery_demo].xsd_log_business_application_02 as N'<?xml version="1.0" encoding="utf-16"?>
<xs:schema id="ssis" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:[xml]-msdata">
  <xs:element name="ssis" msdata:IsDataSet="true" msdata:UseCurrentLocale="true">
    <xs:complexType>
      <xs:choice minOccurs="1" maxOccurs="unbounded">
        <xs:element name="address">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="notes_tree" minOccurs="1" maxOccurs="unbounded">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="note" nillable="true" minOccurs="1" maxOccurs="unbounded">
                      <xs:complexType>
                        <xs:simpleContent msdata:ColumnName="note_text" msdata:Ordinal="0">
                          <xs:extension base="xs:string">
                          </xs:extension>
                        </xs:simpleContent>
                      </xs:complexType>
                    </xs:element>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
              <xs:element name="Data" minOccurs="0" maxOccurs="unbounded">
                <xs:complexType>
                  <xs:sequence>
					<xs:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:choice>
    </xs:complexType>
  </xs:element>
</xs:schema>';

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
--	CREATE A PROCEDURE TO BUILD A TYPED LOG ENTRY
-------------------------------------------------
-------------------------------------------------

-- begin code block
if object_id('[xquery_demo].[set.log]'
             , N'P') is not null
  drop procedure [xquery_demo].[set.log];

go 
create procedure [xquery_demo].[set.log]
  @entry     xml ([xquery_demo].[xsd_log])
  , @output [xml] output
as
  begin
      declare @ssis_log_entry       xml ([xquery_demo].xsd_log_business_application_02)
              , -- Variable is TYPED so it will only accept valid data
              @application_01_entry xml ([xquery_demo].[xsd_log_business_application_01])
              , -- Variable is TYPED so it will only accept valid data
              @xerror               [xml] = N'<error><Message /><ValidDataTypes /></error>'
              , @typed_log          xml ([xquery_demo].[xsd_log])
              , @builderx           [xml]
              , @typed_logbuilder   [xml] = N'<log />'
              , @log_entry          [xml]
              , @local_name         [sysname]
              , @timestamp          datetime = current_timestamp
              , @identity           [int]
              , @message            nvarchar (1000)=N''
              , @error_message      nvarchar (1000)=N''
              , @allowed_types      [xml] = N'<allowed_elements><element local_name="ssis" /><element local_name="business_application_01" /></allowed_elements>';

      set @log_entry = @entry;
      set @local_name = coalesce(@entry.value('local-name((/*/*)[1])'
                                              , '[sysname]')
                                 , N'NULL');

      begin try
          if @local_name = N'ssis'
            begin
                -- Validate Data is correctly TYPED. Since the variable is typed, an invalid [xml] structure will result in an error.
                set @ssis_log_entry = (select t.c.query('.') as result
                                       from   @entry.nodes('/log/*') t(c));

                insert into [xquery_demo].[log]
                            ([entry])
                values      (@entry);

                set @output = N'<output id="'
                               + cast(@@identity as [sysname])
                               + '" address="' + @local_name + '"><result>'
                               + @local_name
                               + ' log entry inserted</result></output>';
                set @output.modify('insert sql:variable("@log_entry") as last into (/output)[1]');
            end
          else if @local_name = N'business_application_01'
            begin
                -- Validate Data is correctly TYPED. Since the variable is typed, an invalid [xml] structure will result in an error.
                set @application_01_entry = (select t.c.query('.') as result
                                             from   @entry.nodes('/log/*') t(c));

                insert into [xquery_demo].[log]
                            ([entry])
                values      (@entry);

                set @output = N'<output id="'
                               + cast(@@identity as [sysname])
                               + '" address="' + @local_name + '"><result>'
                               + @local_name
                               + ' log entry inserted</result></output>';
                set @output.modify('insert sql:variable("@log_entry") as last into (/output)[1]');
            end
          else
            begin
                set @error_message = N'<output><result>Local name not found in allowed types for log entry</result></output>';

                raiserror (@error_message,16,1);
            end
      end try

      begin catch
          set @output = N'<output local_name="' + @local_name
                         + '" >
							<result>Failed to process log entry.</result>
							<error>
								<ERROR_MESSAGE>'
                         + replace(error_message(), '''', '''''')
                         + '</ERROR_MESSAGE>
								<ERROR_PROCEDURE>'
                         + error_procedure() + '</ERROR_PROCEDURE>
								<ERROR_LINE>'
                         + cast(error_line()as [sysname])
                         + '</ERROR_LINE>
								<ERROR_NUMBER>'
                         + cast(error_number()as [sysname])
                         + '</ERROR_NUMBER>
							</error>
						<entry/>
						 </output>';
          set @output.modify('insert sql:variable("@allowed_types") as first into (/output)[1]');
          set @output.modify('insert sql:variable("@log_entry") as last into (/output/entry)[1]');
      end catch
  end

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
--	ONLY ENTRIES TYPED WITH ONE OF THE TWO XSD ARE ALLOWED
-------------------------------------------------
-------------------------------------------------

-- begin code block
--
-- This entry will be allowed as it conforms to [xquery_demo].xsd_log_business_application_02
declare @entry         [xml] ([xquery_demo].[xsd_log])
        , @x          [xml] ([xquery_demo].[xsd_log])
        , @log_ssis   [xml] ([xquery_demo].xsd_log_business_application_02)
        , @log_entry  [xml]
        , @log_insert [xml]
        , @output    [xml];

set @entry = N'<log timestamp="'
            + cast(current_timestamp as [sysname]) + '" />'; 
set @log_ssis = N'<ssis>
	<address>
		<notes_tree>
			<note>note text</note>
			<note>note text</note>
		</notes_tree>
	</address></ssis>';
set @log_insert = @log_ssis;
set @log_entry = @entry;
set @log_entry.modify('insert sql:variable("@log_insert") into (/log)[1]');

execute [xquery_demo].[set.log]
  @entry     =@log_entry
  , @output=@output output

select [entry]
from   [xquery_demo].[log]
where  [id] = @output.value('(/output/@id)[1]'
                            , '[int]');

go 
-- end code block


-- begin code block
--
-- This entry will be allowed as it conforms to [xquery_demo].[xsd_log_business_application_01]
declare @entry         [xml] ([xquery_demo].[xsd_log])
        , @x          [xml] ([xquery_demo].[xsd_log])
        , @log_business_application_01    [xml] ([xquery_demo].[xsd_log_business_application_01])
        , @log_entry  [xml]
        , @log_insert [xml]
        , @output    [xml];

set @entry = N'<log timestamp="'
            + cast(current_timestamp as [sysname]) + '" />'; 
set @log_business_application_01 = N'<business_application_01>
		<table  group="ACS_PAYMENT" address="FINANCE" table="D_ACS_PAYMENT" >
			<job job_name="FTR_ND_ACS_PAYMENT" author="klightsey" >
				<notes_tree>
					<note>CMD_ND_ACS_PAYMENT_LASERUTIL notes on another job</note>
				</notes_tree>
			</job>
		</table>
	</business_application_01>';
set @log_insert = @log_business_application_01;
set @log_entry = @entry;
set @log_entry.modify('insert sql:variable("@log_insert") into (/log)[1]');

execute [xquery_demo].[set.log]
  @entry     =@log_entry
  , @output=@output output

select [entry]
from   [xquery_demo].[log]
where  [id] = @output.value('(/output/@id)[1]'
                            , '[int]');

go 
-- end code block

-- begin code block
--
-- This entry will be allowed as it conforms to [xquery_demo].xsd_log_business_application_02 even with the added ad hoc elements
declare @entry         [xml] ([xquery_demo].[xsd_log])
        , @x          [xml] ([xquery_demo].[xsd_log])
        , @log_ssis   [xml] ([xquery_demo].xsd_log_business_application_02)
        , @log_entry  [xml]
        , @log_insert [xml]
        , @output    [xml];

set @entry = N'<log timestamp="'
            + cast(current_timestamp as [sysname]) + '" />'; 
set @log_ssis = N'<ssis>
	<address>
		<notes_tree>
			<note>note text</note>
			<note>note text</note>
		</notes_tree>
		<Data>
			<level_01 attr1="knock knock!" >
				<L2>is where it is at!</L2>
			</level_01>
			<problem description="what the problem is" />
		</Data>
	</address></ssis>';
set @log_insert = @log_ssis;
set @log_entry = @entry;
set @log_entry.modify('insert sql:variable("@log_insert") into (/log)[1]');

execute [xquery_demo].[set.log]
  @entry     =@log_entry
  , @output=@output output

select [entry]
from   [xquery_demo].[log]
where  [id] = @output.value('(/output/@id)[1]'
                            , '[int]');

go 
-- end code block

-- begin code block
--
-- This entry will NOT be allowed as it does not conform to [xquery_demo].[xsd_log_business_application_01]
--	and it's caught before the function is even called because of the use of a
--	TYPED variable to build the data.
-------------------------------------------------
declare @entry         [xml] ([xquery_demo].[xsd_log])
        , @x          [xml] ([xquery_demo].[xsd_log])
        , @log_business_application_01    [xml] ([xquery_demo].[xsd_log_business_application_01])
        , @log_entry  [xml]
        , @log_insert [xml]
        , @output    [xml];

set @entry = N'<log timestamp="'
            + cast(current_timestamp as [sysname]) + '" />';
set @log_business_application_01 = N'<business_application_01>
		<table  group="ACS_PAYMENT" address="FINANCE" table="D_ACS_PAYMENT" >
			<job job_name="FTR_ND_ACS_PAYMENT" author="klightsey" >
				<notes_tree>
					<note>CMD_ND_ACS_PAYMENT_LASERUTIL notes on another job</note>
					<AnElementThatIsNotInTheSchema />
				</notes_tree>
			</job>
		</table>
	</business_application_01>';

go
-- end code block

-- begin code block
--
-- This will NOT be allowed as it does not conform to [xquery_demo].[xsd_log_business_application_01]
--  but because the variables are not typed it isn't caught until it hits the function.
-- An error should be thrown and handled in the procedure.
declare @entry         [xml]
        , @x          [xml]
        , @log_business_application_01    [xml]
        , @log_entry  [xml]
        , @log_insert [xml]
        , @output    [xml];

set @entry = N'<log timestamp="'
            + cast(current_timestamp as [sysname]) + '" />';
set @log_business_application_01 = N'<business_application_01>
		<table_tree  group="job group" address="FINANCE" table="table" >
			<job job_name="job name" author="klightsey" >
				<notes_tree>
					<note>notes on another job</note>
					<AnElementThatIsNotInTheSchema />
				</notes_tree>
			</job>
		</table_tree>
	</business_application_01>';
set @log_insert = @log_business_application_01;
set @log_entry = @entry;
set @log_entry.modify('insert sql:variable("@log_insert") into (/log)[1]');

execute [xquery_demo].[set.log]
  @entry     =@log_entry
  , @output=@output output;

select @output as [error];

go 
-- end code block

-- begin code block
--
-- This will NOT be allowed as it does not have an element that is allowed.
-- An error should be thrown and handled in the procedure.
declare @entry         [xml]
        , @x          [xml]
        , @log_business_application_01    [xml]
        , @log_entry  [xml]
        , @log_insert [xml]
        , @output    [xml];

set @entry = N'<log timestamp="'
            + cast(current_timestamp as [sysname]) + '" />';
set @log_business_application_01 = N'<NotHere>
		<table  group="table group" address="FINANCE" table="table" >
			<job job_name="FTR_ND_ACS_PAYMENT" author="klightsey" >
				<notes_tree>
					<note>notes on another job</note>
					<AnElementThatIsNotInTheSchema />
				</notes_tree>
			</job>
		</table>
	</NotHere>';
set @log_insert = @log_business_application_01;
set @log_entry = @entry;
set @log_entry.modify('insert sql:variable("@log_insert") into (/log)[1]');

execute [xquery_demo].[set.log]
  @entry     =@log_entry
  , @output=@output output;
  
select @output as [error];

go
-- end code block

-- begin code block
--
-- This will NOT be allowed as [entry] is NULL
declare @output [xml];

execute [xquery_demo].[set.log]
  @entry     =null
  , @output=@output output;
  
select @output as [error];

go 
-- end code block

-------------------------------------------------
-------------------------------------------------
--	XSD DATATYPES
--	XSD can be typed to ensure the resultant TYPED [xml] meets requirements.
--  XSD DATATYPES: 
--		Writing Typed Data: http://msdn.microsoft.com/en-us/library/vstudio/bft97s8e(v=vs.100).aspx
--		Mapping SQL datatypes to [xml] Schema datatypes:
--			http://www.w3.org/2001/sw/rdb2rdf/wiki/Mapping_SQL_datatypes_to_XML_Schema_datatypes
--	Data Type Coercions and the sql:datatype Annotation: 
--			http://msdn.microsoft.com/en-us/library/aa258643(v=SQL.80).aspx
--	Some XSD DATATYPES include: boolean, integer, base64Binary, string, dateTime, time, decimal, double, float,
--		yearMonthDuration, dayTimeDuration
-------------------------------------------------
-------------------------------------------------

-- begin code block
if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsd_test_02'
                  and xsc.schema_id = schema_id(N'xquery_demo'))
  drop xml schema collection [xquery_demo].[xsd_test_02];

go 

create xml schema collection [xquery_demo].[xsd_test_02] as N'<?xml version="1.0" encoding="utf-16"?>
<xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
  <xs:element name="log">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="bigint" type="xs:long" minOccurs="0" msdata:Ordinal="0" />
        <xs:element name="float" type="xs:double" minOccurs="0" msdata:Ordinal="1" />
        <xs:element name="int" type="xs:int" minOccurs="0" msdata:Ordinal="2" />
        <xs:element name="decimal" type="xs:decimal" minOccurs="0" msdata:Ordinal="3" />
        <xs:element name="bit" type="xs:boolean" minOccurs="0" msdata:Ordinal="4" />
        <xs:element name="nvarchar-sql_variant-sysname-text-varchar-uniqueidentifier-ntext" type="xs:string" minOccurs="0" msdata:Ordinal="5" />
      </xs:sequence>
      <xs:attribute name="timestamp" type="xs:dateTime" use="required" />
      <xs:attribute name="id" type="xs:int" use="required" />
    </xs:complexType>
  </xs:element>
  <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:UseCurrentLocale="true">
    <xs:complexType>
      <xs:choice minOccurs="0" maxOccurs="unbounded">
        <xs:element ref="log" />
      </xs:choice>
    </xs:complexType>
  </xs:element>
</xs:schema>'

go

declare @xtest [xml] ([xquery_demo].[xsd_test_02]) = N'<log timestamp="'
  + convert(nvarchar(30), current_timestamp, 126)
  + '" id="5" >
	<bigint>5</bigint>
	<float>4.095</float>
	<int>4</int>
	<decimal>10.235</decimal>
	<bit>1</bit>
	<nvarchar-sql_variant-sysname-text-varchar-uniqueidentifier-ntext>String goes here</nvarchar-sql_variant-sysname-text-varchar-uniqueidentifier-ntext>
</log>';

select @xtest; 
-- end code block

--
--	SECONDARY INDEXES can be created FOR VALUE, FOR PROPERTY, and FOR PATH
--	PATH SECONDARY INDEXES are designed to help improve queries that contain a good amount of path expressions. 
--		Queries that use the exist() method are usually good candidates for a PATH index.
--	PROPERTY SECONDARY INDEXES are intended for queries where the primary key is a known value, and multiple
--		return values are required from the same [xml] instance.
--	VALUE SECONDARY INDEXES are useful for searching for known element or attribute values, without necessarily
--		knowing the element or attribute names, or the full path to the value. Queries that use wildcards for
--		portions of a path would probably benefit from a VALUE index.
-------------------------------------------------

-- begin code block

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog] on [xquery_demo].[log];

go 

create primary xml index [ix_xquery_demo_log_xlog] on [xquery_demo].[log] ([entry]);
go 

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog_value'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog_value] on [xquery_demo].[log];

go 

create xml index [ix_xquery_demo_log_xlog_value] on [xquery_demo].[log] ([entry])
	using xml index [ix_xquery_demo_log_xlog]
	for value;
go 

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog_property]'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog_property] on [xquery_demo].[log];

go 

create xml index [ix_xquery_demo_log_xlog_property] on [xquery_demo].[log] ([entry])
	using xml index [ix_xquery_demo_log_xlog]
	for property;
go 

-- end code block

-- begin code block
--
-- Statistics are available on the indexes 
select idx.name              as N'IndexName'
       , idx.object_id       as N'ObjectID'
       , idx.index_id        as N'IndexID'
       , sts.index_type_desc as N'IndexType'
       , sts.*
from   sys.indexes as idx
       join sys.objects as obj
         on obj.object_id = idx.object_id
       join sys.schemas as sch
         on sch.schema_id = obj.schema_id
       left join sys.dm_db_index_physical_stats (db_id(N'chamomile')
                                                 , object_id(N'[xquery_demo].[log]')
                                                 , null
                                                 , null
                                                 , 'DETAILED') as sts
              on sts.object_id = idx.object_id
                 and idx.index_id = sts.index_id
where  idx.type = 3
       and sch.name = N'xquery_demo'
       and obj.name = N'log'
order  by idx.index_id;
-- end code block
