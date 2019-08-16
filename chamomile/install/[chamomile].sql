use [master];

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------

	--
	--	description
	---------------------------------------------
		drop and install the [chamomile] database.

*/
if db_id(N'chamomile') is not null
  drop database [chamomile];

if db_id(N'chamomile') is null
  create database chamomile;

go

alter authorization on database::[chamomile] to [sa];

go

alter database [chamomile]

set allow_snapshot_isolation on

go

alter database [chamomile]

set read_committed_snapshot on;

go

alter database [chamomile]

set enable_broker;

go

use [chamomile];

go

execute sp_configure
  'disallow results from triggers',
  1;

go

reconfigure;

go

if (select [is_cdc_enabled]
    from   [sys].[databases]
    where  [name] = N'chamomile') = 1
  exec [sys].[sp_cdc_disable_db];

go

exec [sys].sp_cdc_enable_db;

go

exec sp_configure
  'show advanced options',
  1;

go

reconfigure;

go

exec sp_configure
  'max text repl size',
  -1;

go

reconfigure;

go

--
-- database and documentation
--------------------------------------------------------------------------
--------------------------------------------------------------------------
if exists (select *
           from   ::fn_listextendedproperty(N'error_messages'
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'error_messages',
    @level0type=null,
    @level0name=null,
    @level1type=null,
    @level1name=null

go

exec sys.sp_addextendedproperty
  @name =N'error_messages',
  @value =N'<ol>
		<li>[chamomile] error messages start at 100065 (100,065) and increase. </li>
		<li>message number 2000000000 (2,000,000,000) is reserved for testing and should remain unused.</li>
		<li>[chamomile].[presentation].[sp_addmessage] uses error messages starting at 200065 (200,065) and increase.</li>
		<li>See <a href="">[chamomile].[presentation].[sp_addmessage]</a> for examples.</li>
	</ol>',
  @level0type=null,
  @level0name=null,
  @level1type=null,
  @level1name=null;

go

if exists (select *
           from   ::fn_listextendedproperty(N'license'
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'license',
    @level0type=null,
    @level0name=null,
    @level1type=null,
    @level1name=null

go

exec sys.sp_addextendedproperty
  @name =N'license',
  @value =N'select [utility].[get_meta_data](null, N''[chamomile].[documentation].[license]'');',
  @level0type=null,
  @level0name=null,
  @level1type=null,
  @level1name=null

go

if exists (select *
           from   sys.fn_listextendedproperty(N'revision_20140706'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'Katherine E. Lightsey - created.',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'code_formatting'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'code_formatting',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'code_formatting',
  @value = N'I use <a href="http://www.dpriver.com/" target="blank">SQL Pretty Printer</a> for programmatic code formatting. While no programmatic tool is likely to get code formatted as beautifully as if you can touched every line, SQL Printer Printer has enough flexibility that I can get close enough for my purposes. If you do not like the way my code is formatted, get your own copy of SQL Pretty Printer (it is free for an annoy-supported version) and re-format it to whatever works for you.',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'naming_convention'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'naming_convention',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'naming_convention',
  @value = N'<a href="http://www.katherinelightsey.com/#!namingconvention/cu8w" target="blank">[chamomile].[naming_convention]</a> - In the past decade or so I moved gradually towards a naming convention as [all_lower_case_with_no_abbreviations]. There are a number of reasons for this move on my part, among them having spent a lot of time working on internationalized and otherwise case sensitive implementations of both SQL Server and Oracle as well as a lot of time with Java and XML, which are both case sensitive. I found it easier to avoid mistakes and remember variable names by doing this. Previously, I used <a href="http://en.wikipedia.org/wiki/Hungarian_notation" target="blank">Hungarian Notation</a> and found that the prefixes offered little of real value but added complexity with the need to remember or categorize prefixes! If you run the script 

<br>
<div><span style="font-family: Courier New; font-size: 10pt;">
<span style="color: blue; ">select</span>&nbsp;<span style="color: blue; ">distinct</span><span style="color: maroon; ">(</span>&nbsp;<span style="color: maroon; ">[name]</span>&nbsp;<span style="color: maroon; ">)</span>
<br/><span style="color: blue; ">from</span>&nbsp;&nbsp;&nbsp;<span style="color: maroon; ">[sys]</span><span style="color: silver; ">.</span><span style="color: maroon; ">[all_objects]</span>
<br/><span style="color: blue; ">where</span>&nbsp;&nbsp;<span style="color: fuchsia; font-style: italic; ">lower</span><span style="color: maroon; ">(</span><span style="color: #FF0080; font-weight: bold; ">object_schema_name</span><span style="color: maroon; ">(</span><span style="color: maroon; ">[object_id]</span><span style="color: maroon; ">)</span><span style="color: maroon; ">)</span>&nbsp;<span style="color: silver; ">=</span>&nbsp;<span style="color: red; ">N''sys''</span>
<br/><span style="color: blue; ">order</span>&nbsp;&nbsp;<span style="color: blue; ">by</span>&nbsp;<span style="color: maroon; ">[name]</span><span style="color: silver; ">;</span>&nbsp;
</span></div>
<br>
  you will see that the vast majority of objects named by Microsoft follow this convention at least in part; I would guess for similar reasons. So, while I used to be a vocal proponent of Hungarian Notation I have now sacrified some legibility in favor of what I perceive more robust code. Regardless, when I am working in a shop I attempt to adhere devoutly to their naming conventions, as I believe it to be better to have a standard which may not be optimal than it is to have no standard.
',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'best_practice'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'best_practice',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'best_practice',
  @value = N'<a href="http://www.katherinelightsey.com/#!bestpracticesforsql/ces8" target="blank">[sql_best_practice]</a> - My intention is always to follow industry best practices as much as possible. In the case of our industry, development using the SQL language on Microsoft SQL Server, those standards are often not written out as such but are rather encased in the design practices of <a href="http://msftdbprodsamples.codeplex.com/releases/view/55330" target="blank">AdventureWorks</a>. Sometimes they are written out in KB articles or on <a href="http://msdn.microsoft.com/en-US/" target="blank">MSDN</a>. I will only deviate from a known best practice if I can convince myself that there is a clear reason for the deviation.',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'installation'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'installation',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'installation',
  @value = N'An installer script is included with <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a>. Simply run that script in a PowerShell window or at the DOS prompt using the appropriate call to the PowerShell executable and provide it the name of the server instance you wish to install to as well as the directory name where the <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> scripts are located. The server instance can be determined either by the query 
  
  <pre><code class="language-sql">
  select cast(serverproperty(N''MachineName'') as [sysname]) + N''\'' + cast (serverproperty(N''InstanceName'') as [sysname]);"
  </code></pre>

  or by the query
  
  <pre><code class="language-sql">
  select serverproperty(N''ServerName'');
  </code></pre>
  
  the installer for <a href="http://www.katherinelightsey.com/#!chamomilebasic/cfj3" target="blank">[chamomile].[basic]</a> performs a destructive install, that is to say that it first deletes and then reinstalls the objects. This includes the database itself! If you wish to do a partial install you can run the scripts individually. That is why I have included the scripts individually rather than as one large script. It may take some experimentation for you to determine interdependencies, but anyone with reasonable experience with SQL Server should be able to figure it out. If you do not have that level of experience then you are probably better off installing the whole.',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'description'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value =
N'Database <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> is the container for <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> methods and data including [testing], [documentation], [logging], [administration], etc. The objects contained here are implementations or extensions of scripts I have collected, developed, and used since I first began working with SQL Server in 1997. <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> is simply an implementation of many of these scripts as a cohesive whole. As such, it can be used simply as a set of utility objects for your own SQL Server instances. <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> is more than simply a loose collections of utilities though. With <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> I have attempted to deploy a framework on an architecture that both implements and demonstrates the best practices that I have learned over three decades as an engineer and developer. Each <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> object is built using not only the same patterns, styles, and best practices of the whole, it is also built USING other <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> components thus providing examples of how you can use <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> as both a set of utilities and a set of templates and patterns on which to build your highly robust, maintainable, and extensible database application.'
,
@level0type = null,
@level0name = null,
@level1type = null,
@level1name = null,
@level2type = null,
@level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'system_requirements'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'system_requirements',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'system_requirements',
  @value = N'<a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> has been written and tested using Microsoft SQL Server versions 2008R2, 2012, and 2014.',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'copyright_1997_2014'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'copyright_1997_2014',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'copyright_1997_2014',
  @value = N'Copyright 1997_2014 Katherine E. Lightsey.',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'contributors'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'contributors',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'contributors',
  @value = N'If you develop methods or tools using or extending Chamomile that generally follow the methodology used I would welcome contributions.',
  @level0type = null,
  @level0name = null,
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   sys.fn_listextendedproperty(N'copying_permission_statement'
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default
                                              , default))
  exec sys.sp_dropextendedproperty
    @name = N'copying_permission_statement',
    @level0type = null,
    @level0name = null,
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'copying_permission_statement',
  @value =
N'1997_2013 - Katherine E. Lightsey. This file is part of <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a>, a set of tools and utilities developed, maintained, and made available by Katherine E. Lightsey. <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> is licensed by the <a href="http://www.gnu.org/licenses/agpl-3.0.html">Affero General Public License (AGPL)</a> and is free software: you can redistribute it and/or modify it under the terms of the <a href="http://www.gnu.org/copyleft/gpl.html">GNU General Public License</a> as published by the <a href="http://www.fsf.org/">Free Software Foundation</a>, either version 3 of the License, or (at your option) any later version. <a href="http://www.katherinelightsey.com/#!chamomile/c1pl" target="blank">[chamomile]</a> is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. '
,
@level0type = null,
@level0name = null,
@level1type = null,
@level1name = null,
@level2type = null,
@level2name =null;

go

--
-- schemas and documentation
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--
-- schema command_stack
--------------------------------------------------------------------------
if schema_id(N'command_stack') is null
  execute (N'create schema command_stack');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'command_stack'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'command_stack',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'command_stack',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'command_stack'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'command_stack',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'command_stack objects are stored here.',
  @level0type = N'SCHEMA',
  @level0name = N'command_stack',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema command
--------------------------------------------------------------------------
if schema_id(N'command') is null
  execute (N'create schema command');

go

if schema_id(N'command') is null
  execute (N'create schema command');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'command'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'command',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'command',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'command'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'command',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'command objects are stored here.',
  @level0type = N'SCHEMA',
  @level0name = N'command',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema repository_secure
--------------------------------------------------------------------------
if schema_id(N'repository_secure') is null
  execute (N'create schema repository_secure');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'repository_secure'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'repository_secure',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'repository_secure',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'repository_secure'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'repository_secure',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Content objects are stored here.',
  @level0type = N'SCHEMA',
  @level0name = N'repository_secure',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema repository_test
--------------------------------------------------------------------------
if schema_id(N'repository_test') is null
  execute (N'create schema repository_test');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'repository_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'repository_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'repository_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'repository_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'repository_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Test objects for [repository*]',
  @level0type = N'SCHEMA',
  @level0name = N'repository_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema repository
--------------------------------------------------------------------------
if schema_id(N'repository') is null
  execute (N'create schema repository');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'repository'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'repository',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'repository',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'repository'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'repository',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Public interface to [repository_secure], where content objects are stored.',
  @level0type = N'SCHEMA',
  @level0name = N'repository',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema utility
--------------------------------------------------------------------------
if schema_id(N'utility') is null
  execute (N'create schema utility');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'utility'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'utility',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'utility',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'utility'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'utility',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Utility objects, objects that are used by many different areas.',
  @level0type = N'SCHEMA',
  @level0name = N'utility',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema utility_test
--------------------------------------------------------------------------
if schema_id(N'utility_test') is null
  execute (N'create schema utility_test');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'utility_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'utility_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'utility_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'utility_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'utility_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Test objects for [utility*].',
  @level0type = N'SCHEMA',
  @level0name = N'utility_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema administration
--------------------------------------------------------------------------
if schema_id(N'administration') is null
  execute (N'create schema administration');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'administration'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'administration',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'administration',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'administration'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'administration',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Objects that deal with dba type of information',
  @level0type = N'SCHEMA',
  @level0name = N'administration',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema administration_test
--------------------------------------------------------------------------
if schema_id(N'administration_test') is null
  execute (N'create schema administration_test');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'administration_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'administration_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'administration_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'administration_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'administration_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Test objects for [administration*].',
  @level0type = N'SCHEMA',
  @level0name = N'administration_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema test
--------------------------------------------------------------------------
if schema_id(N'test') is null
  execute (N'create schema test');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Objects that deal with general testing.',
  @level0type = N'SCHEMA',
  @level0name = N'test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema documentation
--------------------------------------------------------------------------
if schema_id(N'documentation') is null
  execute (N'create schema documentation');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'documentation'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'documentation',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'documentation',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'documentation'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'documentation',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Objects that deal with dba type of information',
  @level0type = N'SCHEMA',
  @level0name = N'documentation',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

--
-- schema documentation_test
--------------------------------------------------------------------------
if schema_id(N'documentation_test') is null
  execute (N'create schema documentation_test');

go

if exists (select *
           from   fn_listextendedproperty(N'revision_20140706'
                                          , N'SCHEMA'
                                          , N'documentation_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'revision_20140706',
    @level0type = N'SCHEMA',
    @level0name = N'documentation_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'revision_20140706',
  @value = N'20130410 - Katherine E. Lightsey - created.',
  @level0type = N'SCHEMA',
  @level0name = N'documentation_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   fn_listextendedproperty(N'description'
                                          , N'SCHEMA'
                                          , N'documentation_test'
                                          , default
                                          , default
                                          , default
                                          , default))
  exec sys.sp_dropextendedproperty
    @name = N'description',
    @level0type = N'SCHEMA',
    @level0name = N'documentation_test',
    @level1type = null,
    @level1name = null,
    @level2type = null,
    @level2name =null;

exec sys.sp_addextendedproperty
  @name = N'description',
  @value = N'Test objects for [documentation*].',
  @level0type = N'SCHEMA',
  @level0name = N'documentation_test',
  @level1type = null,
  @level1name = null,
  @level2type = null,
  @level2name =null;

go

if exists (select *
           from   ::fn_listextendedproperty(N'package_chamomile_basic'
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'package_chamomile_basic',
    @level0type=null,
    @level0name=null,
    @level1type=null,
    @level1name=null

go

exec sys.sp_addextendedproperty
  @name =N'package_chamomile_basic',
  @value =N'',
  @level0type=null,
  @level0name=null,
  @level1type=null,
  @level1name=null

go

if exists (select *
           from   ::fn_listextendedproperty(N'release_00.92.00'
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default
                                            , default))
  exec sys.sp_dropextendedproperty
    @name =N'release_00.92.00',
    @level0type=null,
    @level0name=null,
    @level1type=null,
    @level1name=null

go

exec sys.sp_addextendedproperty
  @name =N'release_00.92.00',
  @value =N'',
  @level0type=null,
  @level0name=null,
  @level1type=null,
  @level1name=null

go 
