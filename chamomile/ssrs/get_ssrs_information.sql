--
-- Retrieve SSRS report server database information:
--   https://blogs.technet.microsoft.com/dbtechresource/2015/04/04/retrieve-ssrs-report-server-database-information/
-------------------------------------------------
select schema_name([tables].[schema_id])
       , [tables].[name]
       , *
from   [sys].[tables] as [tables]
order  by schema_name([tables].[schema_id])
          , [tables].[name];

--
-------------------------------------------------
select *
from   [dbo].[catalog];

--
-------------------------------------------------
select *
from   [dbo].[DataSource]
where  [Name] is not null;

--
-- Get Datasource Information of specific report
-------------------------------------------------
declare @Namespace    nvarchar(500)
        , @SQL        varchar(max)
        , @ReportName nvarchar(850);

set @ReportName='<report_name>'

select @Namespace = SUBSTRING([x].[CatContent], [x].[CIndex], CHARINDEX('"', [x].[CatContent], [x].[CIndex] + 7) - [x].[CIndex])
from   (select [CatContent] = convert(nvarchar(MAX), convert(xml, convert(varbinary(MAX), [C].[Content])))
               , [CIndex]   = CHARINDEX('xmlns="', convert(nvarchar(MAX), convert(xml, convert(varbinary(MAX), [C].[Content]))))
        from   [ReportServer$SQLDB].dbo.[Catalog] [C]
        where  [C].[Content] is not null
               and [C].[Type] = 2) [X]

select @Namespace = REPLACE(@Namespace, 'xmlns="', '') + ''

select @SQL = 'WITH XMLNAMESPACES ( DEFAULT '''
              + @Namespace + ''', ''http://schemas.microsoft.com/SQLServer/reporting/reportdesigner'' AS rd )
				SELECT  ReportName		 = name
					   ,DataSourceName	 = x.value(''(@Name)[1]'', ''VARCHAR(250)'') 
					   ,DataProvider	 = x.value(''(ConnectionProperties/DataProvider)[1]'',''VARCHAR(250)'')
					   ,ConnectionString = x.value(''(ConnectionProperties/ConnectString)[1]'',''VARCHAR(250)'')
				  FROM (  SELECT top 1 C.Name,CONVERT(XML,CONVERT(VARBINARY(MAX),C.Content)) AS reportXML
						   FROM  [ReportServer$SQLDB].dbo.Catalog C
						  WHERE  C.Content is not null
							AND  C.Type  = 2
							AND  C.Name  = '''
              + @ReportName + '''
				  ) a
				  CROSS APPLY reportXML.nodes(''/Report/DataSources/DataSource'') r ( x )
				ORDER BY name ;'

exec(@SQL);

go

--
-- Get Available Parameter with details in specific Report
-------------------------------------------------
declare @ReportName nvarchar(850) ='<report_name>'

select [name]              as [ReportName]
       , [ParameterName]   = Paravalue.value('Name[1]', 'VARCHAR(250)')
       , [ParameterType]   = Paravalue.value('Type[1]', 'VARCHAR(250)')
       , [ISNullable]      = Paravalue.value('Nullable[1]', 'VARCHAR(250)')
       , [ISAllowBlank]    = Paravalue.value('AllowBlank[1]', 'VARCHAR(250)')
       , [ISMultiValue]    = Paravalue.value('MultiValue[1]', 'VARCHAR(250)')
       , [ISUsedInQuery]   = Paravalue.value('UsedInQuery[1]', 'VARCHAR(250)')
       , [ParameterPrompt] = Paravalue.value('Prompt[1]', 'VARCHAR(250)')
       , [DynamicPrompt]   = Paravalue.value('DynamicPrompt[1]', 'VARCHAR(250)')
       , [PromptUser]      = Paravalue.value('PromptUser[1]', 'VARCHAR(250)')
       , [State]           = Paravalue.value('State[1]', 'VARCHAR(250)')
from   (select top 1 [C].[name]
                     , convert(xml, [C].[Parameter]) as [ParameterXML]
        from   [ReportServer$SQLDB].dbo.[Catalog] [C]
        where  [C].[Content] is not null
               and [C].[type] = 2
               and [C].[name] = @ReportName) [a]
       cross APPLY ParameterXML.nodes('//Parameters/Parameter') [p] ( Paravalue );

go

--
-- Show owner details of specific report
-------------------------------------------------
declare @ReportName nvarchar(850) ='<report_name>';

select [C].[name]
       , [C].[Path]
       , [U].[UserName]
       , [C].[CreationDate]
       , [C].[ModifiedDate]
from   [Catalog] [C]
       inner join [Users] [U]
               on [C].[CreatedByID] = [U].[UserID]
where  [C].[name] = @ReportName;

go

--
-- Search in report server database for specific object
-------------------------------------------------
with Reports
     as (select Name                                                        as [ReportName]
                , convert(varchar(Max), convert(varbinary(MAX), [Content])) as [ReportContent]
         from   [Catalog]
         where  Name is not null)
select [ReportName]
from   Reports
where  [ReportContent] like '%<table_name>%';

go

--
-- Recover report RDL file from report server database
-------------------------------------------------
declare @ReportName nvarchar(850) ='<report_name>';

select [name]                                             as [ReportName]
       , convert(xml, convert(varbinary(MAX), [Content])) as [ReportContent]
from   [Catalog]
where  [name] = @ReportName;

--
-- Get configuration information of Report Server database
-------------------------------------------------
select [name]
       , [value]
from   [ConfigurationInfo];

--
-- Get available roles in Report Server
-------------------------------------------------
select [RoleName]
       , [Description]
from   [Roles];

--
-- Get Report Server Machine Name where Report server database is configured
-------------------------------------------------
select [MachineName]
       , [InstallationID]
       , [InstanceName]
       , [Client]
       , [PublicKey]
       , [SymmetricKey]
from   [Keys]
where  [MachineName] is not null; 


-- http://mscrmuk.blogspot.com/2009/05/reading-rdl-definitions-directly-from.html 
 SELECT Name, convert (varchar(max), convert (varbinary(max),[Content])) AS ReportRDL
 FROM [dbo].[Catalog] where TYPE =2
