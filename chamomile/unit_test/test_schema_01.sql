use [chamomile];

go
-- http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions/ProductModelManuInstructions.xsd
-- https://docs.microsoft.com/en-us/sql/t-sql/xml/replace-value-of-xml-dml?view=sql-server-2017


if schema_id(N'Production') is null
  execute (N'create schema Production');

go
if object_id(N'[test].[production_schema]', N'U') is not null
  drop table [test].[production_schema];

go


if exists (select [xml_collection_id]
           from   sys.[xml_schema_collections] as [xsc]
           where  [xsc].name = 'ManuInstructionsSchemaCollection'
                  and [xsc].[schema_id] = schema_id(N'Production'))
  drop xml schema collection [Production].[ManuInstructionsSchemaCollection];

go
--select xml_schema_namespace(N'Production',N'ManuInstructionsSchemaCollection');
create xml schema collection [Production].[ManuInstructionsSchemaCollection] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:t="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions" targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions" elementFormDefault="qualified">
  <xsd:element name="root">
    <xsd:complexType mixed="true">
      <xsd:complexContent mixed="true">
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="Location" maxOccurs="unbounded">
              <xsd:complexType mixed="true">
                <xsd:complexContent mixed="true">
                  <xsd:restriction base="xsd:anyType">
                    <xsd:sequence>
                      <xsd:element name="step" type="t:StepType" maxOccurs="unbounded" />
                    </xsd:sequence>
                    <xsd:attribute name="LocationID" type="xsd:integer" use="required" />
                    <xsd:attribute name="SetupHours" type="xsd:decimal" />
                    <xsd:attribute name="MachineHours" type="xsd:decimal" />
                    <xsd:attribute name="LaborHours" type="xsd:decimal" />
                    <xsd:attribute name="LotSize" type="xsd:decimal" />
                  </xsd:restriction>
                </xsd:complexContent>
              </xsd:complexType>
            </xsd:element>
          </xsd:sequence>
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
  <xsd:complexType name="StepType" mixed="true">
    <xsd:complexContent mixed="true">
      <xsd:restriction base="xsd:anyType">
        <xsd:choice minOccurs="0" maxOccurs="unbounded">
          <xsd:element name="tool" type="xsd:string" />
          <xsd:element name="material" type="xsd:string" />
          <xsd:element name="blueprint" type="xsd:string" />
          <xsd:element name="specs" type="xsd:string" />
          <xsd:element name="diag" type="xsd:string" />
        </xsd:choice>
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>
</xsd:schema>'; 
