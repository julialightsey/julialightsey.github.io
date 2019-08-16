/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		Demonstrate a mechanism to handle multiple languages without the requirement to refactor code. 
		Existing mechanism 
		- Uses a separate column for each language. 
		- Requires a change to both the schema and the code for each new language. 
		- Numerous columns in a table can obscure its purpose - clutter. 
		XML mechanism 
		- The XML method uses a single XML column to contain all languages in a typed XML object. 
		- Addition of new languages is done ad hoc, they are simply added to the XML that is 
		entered into the table. 
		- The language type can be constrained so that only allowed languages are entered  
		(this requires drop and add of the table, a simple dba operation, but it must be considered). 
		- Neither the code nor the schema need be changed for addition of new languages (assuming 
		that the language value is not constrained). 
		- XML indexes can be used for performance considerations; 1 primary and up to 256 secondary. 
		- Data can be validated using regular expressions (see ex: language_type, sysname). 
		- Regardless of how many languages implemented, the table only has one name column - clean.

	--
	--	notes
	----------------------------------------------------------------------
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
		SQL/XML - http://en.wikipedia.org/wiki/SQL/XML
		xml (Transact-SQL) - http://msdn.microsoft.com/en-us/library/ms187339.aspx
		XQuery Language Reference (SQL Server) - http://msdn.microsoft.com/en-us/library/ms189075.aspx
		XQuery Functions against the xml Data Type - http://msdn.microsoft.com/en-us/library/ms189254.aspx
		Introduction to XQuery in SQL Server 2005 - http://technet.microsoft.com/en-us/library/ms345122(v=sql.90).aspx
		XQuery in SQL Server, some examples - http://blogs.msdn.com/b/spike/archive/2009/09/21/xquery-in-sql-server-some-examples.aspx
*/
--
-- code block begin
use [chamomile];

go

if schema_id(N'account') is null
  execute (N'create schema account');

go
-- code block end


/******************************************************************************************************** 
	Existing Mechanism
*********************************************************************************************************/
if object_id(N'[account].[management_type]'
             , N'U') is not null
  drop table [account].[management_type];

create table [account].[management_type] (
  [id]            [int] identity(1, 1) not null
  , [name]        [varchar](50) not null
  , [namespanish] [varchar](50) null
  , [description] [varchar](250) null,
  constraint [account.management_type.id.primary_key_clustered] primary key clustered ( [id] asc )
  );

insert into [account].[management_type]
            ([name]
             , [namespanish]
             , [description])
values      (N'door'
             , N'puerto'
             , N'entry'),
            (N'cat'
             , N'gato'
             , N'pet'),
            (N'water'
             , N'agua'
             , N'drink');

/* 
Procedure designed to pull back data regardless of which value is passed in. 
For demonstration purposes only. It is obvious that certain techniques are not highly efficient. 
For high speed or high volume applications the method would need to be refactored. 
This procedure is simply a demonstration of the technique 
*/
if object_id(N'[account].[get_management_type]'
             , N'P') is not null
  drop procedure [account].[get_management_type];

go

create procedure [account].[get_management_type]
  @id             [int] = null
  , @name         [nvarchar](50) = null
  , @spanish_name [nvarchar](50) = null
as
  begin
      with [get_by_id]
           as (select [id]
                      , [name]
                      , [namespanish]
                      , [description]
               from   [account].[management_type]
               where  [id] = @id),
           [get_by_name]
           as (select [id]
                      , [name]
                      , [namespanish]
                      , [description]
               from   [account].[management_type]
               where  [name] = @name),
           [get_by_spanish_name]
           as (select [id]
                      , [name]
                      , [namespanish]
                      , [description]
               from   [account].[management_type]
               where  [namespanish] = @spanish_name),
           [result]
           as (select [id]
                      , [name]
                      , [namespanish]
                      , [description]
               from   [get_by_id]
               union
               select [id]
                      , [name]
                      , [namespanish]
                      , [description]
               from   [get_by_name]
               union
               select [id]
                      , [name]
                      , [namespanish]
                      , [description]
               from   [get_by_spanish_name])
      select [id]
             , [name]
             , [namespanish]
             , [description]
      from   [result];
  end

go

execute [account].[get_management_type]
  @id=2;

go

execute [account].[get_management_type]
  @name=N'cat';

go

execute [account].[get_management_type]
  @spanish_name=N'gato';

go

/******************************************************************************************************** 
	XML Method
*********************************************************************************************************/
-- 
if object_id(N'[account].[management_type]'
             , N'U') is not null
  drop table [account].[management_type];

if exists (select *
           from   sys.xml_schema_collections c
                  , sys.schemas                s
           where  c.schema_id = s.schema_id
                  and ( quotename(s.name) + '.' + quotename(c.name) ) = N'[account].[xsc_management_type]')
  drop xml schema collection [account].[xsc_management_type]

go

if not exists (select *
               from   sys.xml_schema_collections c
                      , sys.schemas                s
               where  c.schema_id = s.schema_id
                      and ( quotename(s.name) + '.' + quotename(c.name) ) = N'[account].[xsc_management_type]')
  create xml schema collection [account].[xsc_management_type] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:noetic="http://www.noeticpartners.com/" targetNamespace="http://www.noeticpartners.com/">
  <xsd:element name="name"> 
    <xsd:complexType> 
      <xsd:choice minOccurs="0" maxOccurs="unbounded"> 
        <xsd:element name="value" nillable="false"> 
          <xsd:complexType> 
            <xsd:simpleContent> 
              <xsd:extension base="xsd:string"> 
<xsd:attribute name="language" type="noetic:language_type" /> 
<xsd:attribute name="type" type="noetic:sysname" /> 
              </xsd:extension> 
            </xsd:simpleContent> 
          </xsd:complexType> 
        </xsd:element> 
      </xsd:choice> 
    </xsd:complexType> 
  </xsd:element> 

  <xsd:simpleType name="sysname"> 
    <xsd:restriction base="xsd:string"> 
      <xsd:pattern value="[a-zA-Z]{1}[a-zA-Z_]{0,128}" /> 
    </xsd:restriction> 
  </xsd:simpleType> 

  <xsd:simpleType name="language_type"> 
    <xsd:restriction base="xsd:NMTOKEN"> 
      <xsd:enumeration value="english" /> 
      <xsd:enumeration value="spanish" /> 
      <xsd:enumeration value="pig_latin" /> 
    </xsd:restriction> 
  </xsd:simpleType> 
</xsd:schema>';

go

if object_id(N'[account].[management_type]'
             , N'U') is not null
  drop table [account].[management_type];

create table [account].[management_type] (
  [id]            [int] identity(1, 1) not null
  , [name]        xml ([account].[xsc_management_type]) not null
  , [description] [varchar](250) null,
  constraint [account.management_type.id.primary_key_clustered] primary key clustered ( [id] asc )
  );

go

/* 
  Note that I have not written a setter, I have only include a prototype for reference.  
  A setter would use a merge statement to update where there is a match on the english  
  name (or whatever is decided), or on the id. It would insert where there is no match.  
  I have also often used a delete flag (@delete bit=0) in the setter. So the setter  
  covers the CUD of CRUD. 
*/
if object_id(N'[account].[set_management_type]'
             , N'P') is not null
  drop procedure [account].[set_management_type];

go

create procedure [account].[set_management_type]
  @name          xml([account].[xsc_management_type])
  , @description [nvarchar](max)
  , @delete      bit=0
as
  begin
      select N'prototype method';
  end

go

insert into [account].[management_type]
            ([name]
             , [description])
values      (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="english" type="something">door</value> 
<value language="spanish" type="something">puerto</value> 
<value language="pig_latin" type="something">oorday</value> 
</noetic:name>'
             , N'entry'),
            (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="english" type="something">cat</value> 
<value language="spanish" type="something">gato</value> 
<value language="pig_latin" type="something">atcay</value> 
</noetic:name>'
             , N'pet'),
            (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="english" type="something">water</value> 
<value language="spanish" type="something">agua</value> 
<value language="pig_latin" type="something">aterway</value> 
</noetic:name>'
             , N'drink');

go

/* 
Procedure designed to pull back data regardless of which value is passed in. 
For demonstration purposes only. It is obvious that certain techniques are not highly efficient. 
For high speed or high volume applications the method would need to be refactored. 
This procedure is simply a demonstration of the technique 
*/
if object_id(N'[account].[get_management_type]'
             , N'P') is not null
  drop procedure [account].[get_management_type];

go

/* 
  Note that: 
  - You can pass in either an id or an english language name and get a result back.  
  - The procedure defaults to english, but you can pass in any language name. 
  - No modifications are required either to the code or to the schema to add additional languages! 
  - The xml data can be fully typed, requiring it to meet expectations so that garbage data cannot be loaded. 
*/
create procedure [account].[get_management_type]
  @id         [int] = null
  , @name     [nvarchar](50) = null
  , @language [nvarchar](50) = N'english'
as
  begin
      with [get_by_id]
           as (select [id]
                      , [name].value('declare namespace noetic="http://www.noeticpartners.com/"; (//noetic:name/value[@language=sql:variable("@language")])[1]'
                                     , N'[nvarchar](max)') as [name]
                      , [description]
               from   [account].[management_type]
               where  [id] = @id),
           [get_by_name]
           as (select [id]
                      , [name].value('declare namespace noetic="http://www.noeticpartners.com/"; (//noetic:name/value[@language=sql:variable("@language")])[1]'
                                     , N'[nvarchar](max)') as [name]
                      , [description]
               from   [account].[management_type]
               where  [name].value('declare namespace noetic="http://www.noeticpartners.com/"; (//noetic:name/value[@language="english"])[1]'
                                   , 'nvarchar(255)') = @name),
           [result]
           as (select [id]
                      , [name]
                      , [description]
               from   [get_by_id]
               union
               select [id]
                      , [name]
                      , [description]
               from   [get_by_name])
      select [id]
             , [name]
             , [description]
      from   [result];
  end

go

/******************************************************************************************************** 
********************************************************************************************************* 
********************************************************************************************************* 
********************************************************************************************************* 
  run tests 
********************************************************************************************************* 
********************************************************************************************************* 
********************************************************************************************************* 
*********************************************************************************************************/
-- correctly returns 'cat' as the english name for entry 2 
execute [account].[get_management_type]
  @id=2;

go

-- correctly returns the spanish name for cat 
execute [account].[get_management_type]
  @name      =N'cat'
  , @language=N'spanish';

go

-- note that this returns an invalid value! I'd write a unit test then refactor the method 
execute [account].[get_management_type]
  @name      =N'cat'
  , @language=N'pig latin';

go

-- correctly returns the pig latin value 
execute [account].[get_management_type]
  @name      =N'cat'
  , @language=N'pig_latin';

go

-- correctly returns a null 
execute [account].[get_management_type];

go

/**** 
  Data validation examples. 
*****/
-- 
-- 
declare @test nvarchar(max) = N'standard entry';

begin try
    insert into [account].[management_type]
                ([name]
                 , [description])
    values      (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="english" type="something">cat</value> 
</noetic:name>'
                 , N'entry');

    select N'pass: ' + @test;
end try

begin catch
    select N'fail: ' + @test;
end catch;

go

-- 
-- 
declare @test nvarchar(max) = N'a blank entry is allowed';

begin try
    insert into [account].[management_type]
                ([name]
                 , [description])
    values      (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="english" type="something" /> 
</noetic:name>'
                 , N'entry');

    select N'pass: ' + @test;
end try

begin catch
    select N'fail: ' + @test;
end catch;

go

-- 
-- 
declare @test nvarchar(max) = N'pig_latin is an allowed language';

begin try
    insert into [account].[management_type]
                ([name]
                 , [description])
    values      (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="pig_latin" type="something" /> 
</noetic:name>'
                 , N'entry');

    select N'pass: ' + @test;
end try

begin catch
    select N'fail: ' + @test;
end catch;

go

-- 
-- 
declare @test nvarchar(max) = N'hungarian is not an allowed language';

begin try
    insert into [account].[management_type]
                ([name]
                 , [description])
    values      (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="hungarian" type="something" /> 
</noetic:name>'
                 , N'entry');

    select N'fail: ' + @test;
end try

begin catch
    select N'pass: ' + @test;
end catch;

go

--  
-- 
declare @test nvarchar(max) = N'type must be an alpha followed by 0-128 alpha or underscore characters';

begin try
    insert into [account].[management_type]
                ([name]
                 , [description])
    values      (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
<value language="pig_latin" type="something_special" /> 
</noetic:name>'
                 , N'entry');

    select N'pass: ' + @test;
end try

begin catch
    select N'fail: ' + @test;
end catch;

go

-- 
-- 
declare @test nvarchar(max) = N'type must be an alpha followed by 0-128 alpha or underscore characters';

begin try
    insert into [account].[management_type]
                ([name]
                 , [description])
    values      (N'<noetic:name xmlns:noetic="http://www.noeticpartners.com/" > 
  	 <value language="pig_latin" type="_something" /> 
  	 </noetic:name>'
                 , N'entry');

    select N'fail: ' + @test;
end try

begin catch
    select N'pass: ' + @test;
end catch;

go 
