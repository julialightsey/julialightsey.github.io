/*
	--
	--	description
	---------------------------------------------

	--
	--	notes
	---------------------------------------------
		this presentation is designed to be run incrementally a code block at a time. 
		code blocks are delineated as:
		
	http://www.generatedata.com/
	bcp [address].[sample_data] format nul -c -x -f address.sample_data.xml -t, -d 
		chamomile -T -S <machine_name>\CHAMOMILE
	bcp [address].[sample_data] in chamomile.presentation.xquery_sample_data.pdv -d 
		chamomile -T -F 2 -f address.sample_data.xml -S <machine_name>\CHAMOMILE
		--
		-- code block begin
		-----------------------------------------
			<run code here>
		-----------------------------------------
		-- code block end
		--
*/
--
-- BUILD TEST DATA
-- Build test data for this presentation
-------------------------------------------------
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
use [chamomile];

go

if schema_id(N'xquery_demo') is null
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
-------------------------------------------------
-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
use [chamomile_oltp];

go

if schema_id(N'address') is null
  execute (N'create schema address');

go

if object_id(N'[address].[sample_data]'
             , N'U') is not null
  drop table [address].[sample_data];

go

create table [address].[sample_data]
  (
     [name]        [nvarchar](250) null
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
-- load sample data
-------------------------------------------------
-------------------------------------------------
select *
from   [address].[sample_data];

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
-- 
-- CREATE A UTILITY FUNCTION TO BUILD A TEST [xml] TREE
-- The utility function will be used throughout this presentation to build an [xml] tree 
--	to demonstrate methods on
-------------------------------------------------
--
-- code block begin
-------------------------------------------------
if schema_id(N'xquery_demo') is null
  execute (N'create schema xquery_demo');

go

if object_id(N'[xquery_demo].[get_person]'
             , N'FN') is not null
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
--
-- code block begin
-------------------------------------------------
--
-- MULTIPLE FILTERS
-- The query() method
-- Multiple filters can be used within one query
-- note that multiple records are contained within 1 sql "row"
-------------------------------------------------
select [xquery_demo].[get_person]().query('address_tree/address[@name="Fiona"]');

select [xquery_demo].[get_person]().query('address_tree/address[@name="Fiona"][@city="Eghezee"]');

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- to extract individual xml records into individual records use the nodes method
-- this is called "shredding"
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
--
-- code block begin
-------------------------------------------------
--
-- build a utility repository
-------------------------------------------------
if schema_id(N'repository_secure') is null
  execute (N'create schema repository_secure');

go

if object_id(N'[repository_secure].[data]'
             , N'U') is not null
  drop table [repository_secure].[data];

go

create table [repository_secure].[data]
  (
     [id]      [int] identity(1, 1) not null constraint [repository_secure.data.id.clustered_primary_key] primary key clustered
     , [entry] [xml]
  );

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- insert contact records into the repository
-------------------------------------------------
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @entry   xml = [xquery_demo].[get_person]().query('address_tree/address[@name="Fiona"][@city="Eghezee"]'),
        @contact [xml] = N'<contact_record timestamp="' + @timestamp
          + N'">She called, we answered.</contact_record>';

set @entry.modify(N'insert sql:variable("@contact") as last into (/*)[1]');

insert into [repository_secure].[data]
            ([entry])
values      (@entry);

--
select @entry = [xquery_demo].[get_person]().query('address_tree/address[@name="Sasha"][@city="Inuvik"]')
       , @contact = N'<contact_record timestamp="' + @timestamp
                    + N'">She does not like the cold weather</contact_record>';

set @entry.modify(N'insert sql:variable("@contact") as last into (/*)[1]');

insert into [repository_secure].[data]
            ([entry])
values      (@entry);

--
select [id]
       , [entry]
from   [repository_secure].[data];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- you can insert anything, even garbage records into the repository
-------------------------------------------------
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @entry xml = N'<entry><valid_xml /></entry>';

insert into [repository_secure].[data]
            ([entry])
values      (@entry);

--
select @entry = N'<blah_blah_blah />';

insert into [repository_secure].[data]
            ([entry])
values      (@entry);

--
select [id]
       , [entry]
from   [repository_secure].[data];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- Create an [xml] SCHEMA COLLECTION which specifies the minimum requirements for [repository_secure].[data]
-------------------------------------------------
if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'xsc'
                  and xsc.schema_id = schema_id(N'repository'))
  drop xml schema collection [repository].[xsc];

go

create xml schema collection [repository].[xsc] as N'
	<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
	xmlns:repository="http://www.katherinelightsey.com/" 
	targetNamespace="http://www.katherinelightsey.com/">

    <xsd:element name="stack" type="repository:stack_type" />

    <xsd:complexType name="stack_type">
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
			<xsd:element name="entry" type="repository:repository_complex_type" minOccurs="1" maxOccurs="1" />
          </xsd:sequence>
		  <xsd:attribute name="application" type="repository:application_enumeration" use="required" />
          <xsd:attribute name="persistent" type="repository:boolean_enumeration" default="false" />
          <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
		  <xsd:anyAttribute processContents="lax" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>

	<xsd:complexType name="repository_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:attribute name="fqn" type="repository:fqn_pattern_enumeration" use="required" />
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>
	
  <xsd:simpleType name="application_enumeration">
    <xsd:restriction base="xsd:NMTOKEN">
      <xsd:enumeration value="sales" />
      <xsd:enumeration value="customer_support" />
      <xsd:enumeration value="test" />
      <xsd:enumeration value="operations" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="boolean_enumeration">
    <xsd:restriction base="xsd:NMTOKEN">
      <xsd:enumeration value="true" />
      <xsd:enumeration value="false" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="pass_fail_enumeration">
    <xsd:restriction base="xsd:NMTOKEN">
      <xsd:enumeration value="pass" />
      <xsd:enumeration value="fail" />
    </xsd:restriction>
  </xsd:simpleType>

  <!-- an fqn can be either: -->
  <!-- three part:	[category].[class].[type] - typically used for object names -->
  <!-- four part:	
	[database].[schema].[object.][minor_object] 
		- typically used for column or parameter names -->
  <!-- six part:	
	[computer_physical_netbios].[machine].[instance].[database].[schema].[object] 
		- typically used for subject names -->
  <!-- seven part:	
	[computer_physical_netbios].[machine].[instance].[database].[schema].[object].[minor_object] 
		- typically used for column and parameter names -->
  <xsd:simpleType name="fqn_pattern_enumeration">
    <xsd:restriction base="xsd:string">
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]
		{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]
		{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]
		{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]
		{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
	  <xsd:pattern value="\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]
		{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\].\[[a-z0-9._-]{0,128}\]" />
    </xsd:restriction> 
  </xsd:simpleType>

  <xsd:simpleType name="sysname_pattern">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="[a-z0-9._-]{0,128}" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="object_name_pattern">
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="[a-z]{1}[a-z0-9._-]{0,128}" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:element name="email_address">
  <xsd:simpleType>
    <xsd:restriction base="xsd:string">
      <xsd:pattern value="[A-Za-z0-9_]+([-+.''][A-Za-z0-9_]+)*@[A-Za-z0-9_]+([-.][A-Za-z0-9_]+)*
		\.[A-Za-z0-9_]+([-.][A-Za-z0-9_]+)*"/>
    </xsd:restriction>
  </xsd:simpleType>
</xsd:element>

</xsd:schema>';

go

select xml_schema_namespace(N'repository'
                            , N'xsc');

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @entry xml([repository].[xsc]) = N'<
	repository:stack xmlns:repository="http://www.katherinelightsey.com/" application="test" timestamp="'
  + @timestamp + N'">
		<entry fqn="[name]">
			<description />
		</entry>
	</repository:stack>';

--
insert into [repository_secure].[data]
            ([entry])
values      (@entry);

select *
from   [repository_secure].[data];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create table with a typed column so only validated (typed) data is allowed
-------------------------------------------------
if object_id(N'[repository_secure].[data]'
             , N'U') is not null
  drop table [repository_secure].[data];

go

create table [repository_secure].[data]
  (
     [id]      [int] identity(1, 1) not null constraint [repository_secure.data.id.clustered_primary_key] primary key clustered
     , [entry] xml([repository].[xsc])
  );

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- insert a default entry
-------------------------------------------------
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @entry xml([repository].[xsc]) = N'<
	repository:stack xmlns:repository="http://www.katherinelightsey.com/" application="test" timestamp="'
  + @timestamp + N'">
		<entry fqn="[name]">
			<description />
		</entry>
	</repository:stack>';

--
insert into [repository_secure].[data]
            ([entry])
values      (@entry);

select *
from   [repository_secure].[data];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- attempt to insert an invalid entry (using an untyped @entry variable)
-------------------------------------------------
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @entry xml = N'<
	repository:stack xmlns:repository="http://www.katherinelightsey.com/" application="test" timestamp="'
  + @timestamp + N'">
		<not_valid fqn="[name]">
			<description />
		</not_valid>
	</repository:stack>';

--
begin try
    insert into [repository_secure].[data]
                ([entry])
    values      (@entry);
end try

begin catch
    select error_message() as [error_message];
end catch;

select *
from   [repository_secure].[data];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- create an xsc to type a contact record
-------------------------------------------------
if schema_id(N'person') is null
  execute (N'create schema person');

go

if exists (select xml_collection_id
           from   sys.xml_schema_collections as xsc
           where  xsc.name = 'contact_record'
                  and xsc.schema_id = schema_id(N'person'))
  drop xml schema collection [person].[contact_record];

go

create xml schema collection [person].[contact_record] as N'
	<?xml version="1.0" encoding="utf-16"?>
<xs:schema id="NewDataSet" xmlns="" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
  <xs:element name="contact_record">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="address" minOccurs="1" maxOccurs="1">
          <xs:complexType>
            <xs:attribute name="name" type="xs:string"  use="required"/>
            <xs:attribute name="street_01" type="xs:string"  use="required"/>
            <xs:attribute name="city" type="xs:string"  use="required"/>
            <xs:attribute name="email" type="xs:string" />
            <xs:attribute name="value" type="xs:decimal" />
          </xs:complexType>
        </xs:element>
        <xs:element name="note" type="xs:string" minOccurs="0" maxOccurs="unbounded" />
      </xs:sequence>
      <xs:attribute name="timestamp" type="xs:dateTime" use="required"/>
    </xs:complexType>
  </xs:element>
</xs:schema>';

go

select xml_schema_namespace(N'person'
                            , N'contact_record');

--
declare @contact_record xml([person].[contact_record]) = N'
	<contact_record timestamp="2014-08-31T10:48:16.290">
      <address name="Fiona" street_01="Ap #165-7772 Odio Avenue" 
		city="Eghezee" email="tincidunt.congue@euelit.net" />
      <note>She called, we answered, she hung up.</note>
    </contact_record>';

select @contact_record as [typed_contact_record];

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
--
-- insert a valid, complex entry, capture the inserted [id], and display the record
-- note that this is the basic logic for a mutator method which would extract the "entry" from 
--	a value to be inserted, the test it to make sure it is a valid type before inserting or
--	updating the record into the repository.
-------------------------------------------------
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @person         [xml] = [xquery_demo].[get_person]().query( N'address_tree/address[@name="Fiona"][@city="Eghezee"]'),
        @contact_record xml([person].[contact_record]),
        @builder        [xml] = N'<contact_record timestamp="' + @timestamp
          + N'" ><note /></contact_record>',
        @note           [nvarchar](max) = N'She called, we answered, she hung up.',
        @fqn            [nvarchar](max),
        @id             [int];
declare @output table
  (
     [id] [int]
  );

--
set @fqn = lower(N'[contact_record].['
                 + @person.value(N'(/address/@city)[1]', N'[sysname]')
                 + N'].['
                 + @person.value(N'(/address/@name)[1]', N'[sysname]')
                 + N']');
set @builder.modify(N'insert sql:variable("@person") as first into (/*)[1]');
set @builder.modify(N'insert text {sql:variable("@note")} as last into (/*/note)[1]');
--
-- test the built record to make sure it meets the requirements of the xsc by setting it to a typed parameter,
--	effectively "casting" it to a typed value
-------------------------------------------------
set @contact_record =@builder;

-- 
declare @entry xml = N'
	<repository:stack xmlns:repository="http://www.katherinelightsey.com/" 
	application="customer_support" timestamp="'
  + @timestamp + N'">
		<entry fqn="">
			<description>contact record</description>
		</entry>
	</repository:stack>';

--
-- insert the untyped builder as you can't insert a record of one type into another type
-------------------------------------------------
set @entry.modify(N'insert sql:variable("@builder") as last into (/*/entry)[1]');
set @entry.modify(N'replace value of (/*/entry/@fqn)[1] with sql:variable("@fqn")');

--
begin try
    insert into [repository_secure].[data]
                ([entry])
    output      inserted.[id]
    into @output ([id])
    values      (@entry);
end try

begin catch
    select error_message() as [error_message];
end catch;

--
select *
from   [repository_secure].[data]
where  [id] = (select top(1) [id]
               from   @output);

go

-------------------------------------------------
-- code block end
--
--
-- code block begin
-------------------------------------------------
-- find nodes by local name and using VALUE(), SUM and COUNT
-- [xml] FUNCTIONS: http://msdn.microsoft.com/en-us/library/ms189254.aspx
-- Some of the [xml] functions available include ceiling, floor, round, concat, contains, substring, lower-case,
--	string-length, upper-case, not, number, local-name, namespace-uri, last, position, empty, distinct-values,
--	id, count, avg, min, max, sum, string, data, true, false, expanded-QName, local-name-from-QName,
--	namespace-uri-from-QName, sql:column(), sql:variable().
--
-------------------------------------------------
declare @contact_record [xml] = N'
	<repository:stack xmlns:repository="http://www.katherinelightsey.com/" 
	application="customer_support" timestamp="2014-08-31T11:06:23.91" 
	persistent="false">
	  <entry fqn="[contact_record].[eghezee].[fiona]">
		<description>contact record</description>
		<contact_record timestamp="2014-08-31T11:06:23.910">
		  <address name="Fiona" street_01="Ap #165-7772 Odio Avenue" city="Eghezee" 
		  email="tincidunt.congue@euelit.net" value="12.32" />
		  <note>She called, we answered, she hung up.</note>
		</contact_record>
		<contact_record timestamp="2014-08-30T11:06:23.910">
		  <address name="Fiona" street_01="Ap #165-7772 Odio Avenue" city="Eghezee" 
		  email="tincidunt.congue@euelit.net" value="193.85" />
		  <note>Purple and white striped puppy dogs with green 
			and lavendar polka dotted ears.</note>
		</contact_record>
	  </entry>
	</repository:stack>';

select @contact_record.exist('//*[local-name()="note"]');

select @contact_record.value('(//*[local-name()="note"]/text())[1]'
                             , N'[nvarchar](max)');

select @contact_record.query('//*[local-name()="contact_record"][@timestamp="2014-08-30T11:06:23.910"]');

select @contact_record.value('count (//*[local-name()="contact_record"])'
                             , N'[int]');

select t.c.value(N'./@timestamp'
                 , N'[sysname]')
       , t.c.value(N'(./note/text())[1]'
                   , N'[nvarchar](max)')
from   @contact_record.nodes(N'//*[local-name()="contact_record"]') as t(c);

--
-- Use the "sum" function to get the sum of all values
select @contact_record.value('sum (/*/entry/contact_record/address/@value)'
                             , '[float]');

--
-- Use the "count" function to get the count of all sales persons
select @contact_record.value('count (/*/entry/contact_record)'
                             , '[int]');

go

-------------------------------------------------
-- code block end
--
-------------------------------------------------
-------------------------------------------------
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
<xs:schema id="NewDataSet" xmlns="" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
  <xs:element name="log">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="bigint" type="xs:long" minOccurs="0" msdata:Ordinal="0" />
        <xs:element name="float" type="xs:double" minOccurs="0" msdata:Ordinal="1" />
        <xs:element name="int" type="xs:int" minOccurs="0" msdata:Ordinal="2" />
        <xs:element name="decimal" type="xs:decimal" minOccurs="0" msdata:Ordinal="3" />
        <xs:element name="bit" type="xs:boolean" minOccurs="0" msdata:Ordinal="4" />
        <xs:element name="nvarchar-sql_variant-sysname-text-varchar-uniqueidentifier-ntext" 
			type="xs:string" minOccurs="0" msdata:Ordinal="5" />
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
	<nvarchar-sql_variant-sysname-text-varchar-uniqueidentifier-ntext>
		String goes here</nvarchar-sql_variant-sysname-text-varchar-uniqueidentifier-ntext>
</log>';

select @xtest;

-- end code block
-------------------------------------------------
-- begin code block
if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog] on [xquery_demo].[log];

go

create primary xml index [ix_xquery_demo_log_xlog]
  on [xquery_demo].[log] ([entry]);

go

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog_value'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog_value] on [xquery_demo].[log];

go

create xml index [ix_xquery_demo_log_xlog_value]
  on [xquery_demo].[log] ([entry]) using xml index [ix_xquery_demo_log_xlog] for value;

go

if indexproperty (object_id('[xquery_demo].[log]')
                  , 'ix_xquery_demo_log_xlog_property]'
                  , 'IndexID') is not null
  drop index [ix_xquery_demo_log_xlog_property] on [xquery_demo].[log];

go

create xml index [ix_xquery_demo_log_xlog_property]
  on [xquery_demo].[log] ([entry]) using xml index [ix_xquery_demo_log_xlog] for property;

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
