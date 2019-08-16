if schema_id(N'chamomile') is null
  execute (N'create schema chamomile');

go

set nocount on;

go

/*
	All content is licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and 
		copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved,
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
	---------------------------------------------
*/
if exists (select xml_collection_id
           from   sys.xml_schema_collections as true_false
           where  true_false.name = 'true_false'
                  and true_false.schema_id = schema_id(N'chamomile'))
  drop xml schema collection [chamomile].[true_false];

go

/*
	--
	-- License
	----------------------------------------------------------------------
	Katherine E. Lightsey
	http://www.katherinelightsey.com
	
	All content is copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
	licensed as [chamomile] (http://www.katherinelightsey.com/#!license/cjlz) and copyright Katherine Elizabeth Lightsey, 1959-2014 (aka; my life), all rights reserved, 
		and as open source under the GNU Affero GPL (http://www.gnu.org/licenses/agpl-3.0.html).
		
	--
	-- to view documentation
	-----------------------------------------------------------------------------------------------
	select objtype
		   , objname
		   , name
		   , value
	from   fn_listextendedproperty (null
									, 'schema'
									, 'chamomile'
									, 'xml schema collection'
									, 'true_false'
									, default
									, default);
*/
create xml schema collection [chamomile].[true_false] as N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:chamomile="http://www.katherinelightsey.com/" targetNamespace="http://www.katherinelightsey.com/">

    <xsd:element name="true_false" type="chamomile:true_false_type" />

    <xsd:complexType name="true_false_type">
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:attribute name="true_false" type="chamomile:pass_fail_enumeration" default="false" />
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>

  <xsd:simpleType name="pass_fail_enumeration">
    <xsd:restriction base="xsd:NMTOKEN">
      <xsd:enumeration value="true" />
      <xsd:enumeration value="false" />
    </xsd:restriction>
  </xsd:simpleType>

</xsd:schema>';

go

declare @true_false xml([chamomile].[true_false]) = N'<chamomile:true_false xmlns:chamomile="http://www.katherinelightsey.com/" true_false="true" />';

if (select @true_false.value(N'(/*/@true_false)[1]'
                             , N'[sysname]')) = N'true'
  select N'true';

go

declare @true_false xml([chamomile].[true_false]) = N'<chamomile:true_false xmlns:chamomile="http://www.katherinelightsey.com/" true_false="false" />';

go

declare @true_false xml([chamomile].[true_false]) = N'<chamomile:true_false xmlns:chamomile="http://www.katherinelightsey.com/" true_false="not_valid" />';

go 
