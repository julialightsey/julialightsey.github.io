use [chamomile];

go

if schema_id(N'chamomile') is null
  execute (N'create schema chamomile');

go

if exists (select [xml_collection_id]
           from   sys.[xml_schema_collections] as [xsc]
           where  [xsc].name = 'xsc_test_stack'
                  and [xsc].[schema_id] = schema_id(N'chamomile'))
  drop xml schema collection [chamomile].[xsc_test_stack];

go

create xml schema collection [chamomile].[xsc_test_stack] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:chamomile="https://github.com/KELightsey/chamomile" targetNamespace="https://github.com/KELightsey/chamomile" elementFormDefault="qualified">
  <xsd:element name="test_stack">
    <xsd:complexType>
      <xsd:sequence>
        <xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
        <xsd:element name="test_stack_detail" type="chamomile:any_complex_type" minOccurs="0" maxOccurs="unbounded" />
        <xsd:element name="test" type="chamomile:test_complex_type" minOccurs="0" maxOccurs="unbounded" />
      </xsd:sequence>
      <xsd:attribute name="name" type="xsd:string" use="required" />
      <xsd:attribute name="test_count" type="xsd:int" use="required" />
      <xsd:attribute name="pass_count" type="xsd:int" use="required" />
      <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
	 <xsd:anyAttribute processContents="lax" />
    </xsd:complexType>
  </xsd:element>
	
	<xsd:complexType name="test_complex_type">
      <xsd:sequence>
        <xsd:element name="description" type="xsd:string" minOccurs="1" maxOccurs="1" />
        <xsd:element name="test_detail" type="chamomile:any_complex_type" minOccurs="0" maxOccurs="unbounded" />
      </xsd:sequence>
      <xsd:attribute name="test_name" type="xsd:string" use="required" />
      <xsd:attribute name="pass" type="xsd:string" use="required" />
      <xsd:attribute name="count" type="xsd:integer" use="required" />
      <xsd:attribute name="timestamp" type="xsd:dateTime" use="required" />
    </xsd:complexType>
	
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

--
-------------------------------------------------
declare @test_stack [xml]([chamomile].[xsc_test_stack]) = N'
	 <chamomile:test_stack xmlns:chamomile="https://github.com/KELightsey/chamomile" name="[chamomile].[person_test].[get_age]" test_count="2" pass_count="2" timestamp="2018-06-24T15:50:19.3466667">
	   <chamomile:description>This test stack consists of tests which validate the functionality of the age calculation for a person.</chamomile:description>
	   <chamomile:test test_name="" pass="na" count="0" timestamp="2018-06-24T15:50:19.3466667">
			<chamomile:description />
	   </chamomile:test>
	 </chamomile:test_stack>'
        , @false    [sysname] = N'false';

set @test_stack.modify(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  replace value of (/chamomile:test_stack/chamomile:test/@count)[1] with 543 cast as xs:integer ?');
set @test_stack.modify(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  replace value of (/chamomile:test_stack/chamomile:test/@pass)[1] with sql:variable("@false") cast as xs:string ?');
set @test_stack.modify(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
insert <chamomile:test_detail expected_age="18" date_of_birth="20001201" calculated_age="18" >  
           <any_valid_xml value="1"><any_valid_xml_again value="2">text goes here</any_valid_xml_again></any_valid_xml>  
         </chamomile:test_detail>  
  as last into (/chamomile:test_stack/chamomile:test)[1]');

--
-------------------------------------------------
select @test_stack                                                       as [test]
       , @test_stack.value(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  (/chamomile:test_stack/chamomile:test/@count)[1]', N'[int]')    as [count]
       , @test_stack.value(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  (/chamomile:test_stack/chamomile:test/@pass)[1]', N'[sysname]') as [pass];

go 
