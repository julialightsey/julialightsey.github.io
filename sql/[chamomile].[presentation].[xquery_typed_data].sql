use [chamomile];
go
if schema_id(N'utility_secure') is null
  execute (N'create schema utility_secure');
go
if object_id(N'[utility_secure].[log]', N'U') is not null
  drop table [utility_secure].[log];
go
if exists
   (select xml_collection_id
    from   sys.xml_schema_collections as xsc
    where  xsc.name = 'xsc_log'
           and xsc.schema_id = schema_id(N'chamomile'))
  drop xml schema collection [chamomile].[xsc_log];
go
create xml schema collection [chamomile].[xsc_log] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:chamomile="http://www.katherinelightsey.com/" targetNamespace="http://www.katherinelightsey.com/">
  <xsd:element name="log">
    <xsd:complexType>
      <xsd:sequence>
        <xsd:element name="description" type="xsd:string" minOccurs="0" maxOccurs="1" />
        <xsd:element name="entry" type="chamomile:any_complex_type" minOccurs="0" maxOccurs="unbounded" />
      </xsd:sequence>
      <xsd:attribute name="fqn" type="xsd:string" use="required" />
      <xsd:attribute name="timestamp" type="xsd:dateTime" />
    </xsd:complexType>
  </xsd:element>
	
	<xsd:complexType name="any_complex_type">
		<xsd:complexContent>
			<xsd:restriction base="xsd:anyType">
				<xsd:sequence>
					<xsd:any minOccurs="0" maxOccurs="unbounded" processContents="lax"/>
				</xsd:sequence>
				<xsd:anyAttribute processContents="lax" />
			</xsd:restriction>
		</xsd:complexContent>
	</xsd:complexType>

</xsd:schema>';
go
if object_id(N'[utility_secure].[log]', N'U') is not null
  drop table [utility_secure].[log];
go
create table [utility_secure].[log] (
  [id]      [int] identity(1, 1) not null constraint [utility_secure.log.id.clustered_primary_key] primary key clustered
  , [entry] xml([chamomile].[xsc_log])
  );
go
declare @timestamp [sysname] = convert([sysname], current_timestamp, 126);
declare @entry xml([chamomile].[xsc_log]);
set @entry = N'<chamomile:log xmlns:chamomile="http://www.katherinelightsey.com/" fqn="log entry" timestamp="'
             + @timestamp + N'" >
		<description>log entry</description>
		<entry>
			<any_valid_xml />
		</entry>
	</chamomile:log>';
insert into [utility_secure].[log]
            ([entry])
values      (@entry);

--
-- this doesn't work
-------------------------------------------------
select [entry]
       , [entry].value(N'data (/*/description/text())[1]', N'[nvarchar](max)')
from   [utility_secure].[log];
go
--
-- this works
-------------------------------------------------
select cast([entry].query('declare namespace chamomile="http://www.katherinelightsey.com/";
					for $d in /chamomile:log/description return $d').query(N'./*/text()') as [nvarchar](max)) as [description]
from   [utility_secure].[log];
go 
