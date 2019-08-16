use [chamomile];

go

if schema_id(N'test') is null
  execute (N'create schema test');

go

if object_id(N'[test].[production_schema]', N'U') is not null
  drop table [test].[production_schema];

go

create table [test].[production_schema]
  (
     [ProductModelID] int primary key
     , [Instructions] xml (Production.ManuInstructionsSchemaCollection)
  )

go

insert into [test].[production_schema]
select 7
       , N'<root xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions">
                Adventure Works CyclesFR-210B Instructions for Manufacturing HL Touring Frame. Summary: This document contains manufacturing instructions for manufacturing the HL Touring Frame, Product Model 7. Instructions are work center specific and are identified by Work Center ID. These instructions must be followed in the order presented. Deviation from the instructions is not permitted unless an authorized Change Order detailing the deviation is provided by the Engineering Manager.<Location LaborHours="2.5" LotSize="100" MachineHours="3" SetupHours="0.5" LocationID="10">
                    Work Center 10 - Frame Forming. The following instructions pertain to Work Center 10. (Setup hours = .5, Labor Hours = 2.5, Machine Hours = 3, Lot Sizing = 100)<step>
                        Insert <material>aluminum sheet MS-2341</material> into the <tool>T-85A framing tool</tool>.
                    </step><step>
                        Attach <tool>Trim Jig TJ-26</tool> to the upper and lower right corners of the aluminum sheet.
                    </step><step>
                        Using a <tool>router with a carbide tip 15</tool>, route the aluminum sheet following the jig carefully.
                    </step><step>
                        Insert the frame into <tool>Forming Tool FT-15</tool> and press Start.
                    </step><step>
                        When finished, inspect the forms for defects per Inspection Specification <specs>INFS-111</specs>.
                    </step><step>Remove the frames from the tool and place them in the Completed or Rejected bin as appropriate.</step></Location><Location LaborHours="1.75" LotSize="1" MachineHours="2" SetupHours="0.15" LocationID="20">
                    Work Center 20 - Frame Welding. The following instructions pertain to Work Center 20. (Setup hours = .15, Labor Hours = 1.75, Machine Hours = 2, Lot Sizing = 1)<step>
                        Assemble all frame components following blueprint <blueprint>1299</blueprint>.
                    </step><step>
                        Weld all frame components together as shown in illustration <diag>3</diag></step><step>
                        Inspect all weld joints per Adventure Works Cycles Inspection Specification <specs>INFS-208</specs>.
                    </step></Location><Location LaborHours="1" LotSize="1" LocationID="30">
                    Work Center 30 - Debur and Polish. The following instructions pertain to Work Center 30. (Setup hours = 0, Labor Hours = 1, Machine Hours = 0, Lot Sizing = 1)<step>
                        Using the <tool>standard debur tool</tool>, remove all excess material from weld areas.
                    </step><step>
                        Using <material>Acme Polish Cream</material>, polish all weld areas.
                    </step></Location><Location LaborHours="0.5" LotSize="20" MachineHours="0.65" LocationID="45">
                    Work Center 45 - Specialized Paint. The following instructions pertain to Work Center 45. (Setup hours = 0, Labor Hours = .5, Machine Hours = .65, Lot Sizing = 20)<step>
                        Attach <material>a maximum of 20 frames</material> to <tool>paint harness</tool> ensuring frames are not touching.
                    </step><step>
                        Mix <material>primer PA-529S</material>. Test spray pattern on sample area and correct flow and pattern as required per engineering spec <specs>AWC-501</specs>.
                    </step><step>Apply thin coat of primer to all surfaces.  </step><step>After 30 minutes, touch test for dryness. If dry to touch, lightly sand all surfaces. Remove all surface debris with compressed air. </step><step>
                        Mix <material>paint</material> per manufacturer instructions.
                    </step><step>
                        Test spray pattern on sample area and correct flow and pattern as required per engineering spec <specs>AWC-509</specs>.
                    </step><step>Apply thin coat of paint to all surfaces. </step><step>After 60 minutes, touch test for dryness. If dry to touch, reapply second coat. </step><step>
                        Allow paint to cure for 24 hours and inspect per <specs>AWC-5015</specs>.
                    </step></Location><Location LaborHours="3" LotSize="1" SetupHours="0.25" LocationID="50">
                    Work Center 50 - SubAssembly. The following instructions pertain to Work Center 50. (Setup hours = .25, Labor Hours = 3, Machine Hours = 0, Lot Sizing = 1)<step>Add Seat Assembly. </step><step>Add Brake assembly.   </step><step>Add Wheel Assembly. </step><step>Inspect Front Derailleur. </step><step>Inspect Rear Derailleur. </step></Location><Location LaborHours="4" LotSize="1" LocationID="60">
                    Work Center 60 - Final Assembly. The following instructions pertain to Work Center 60. (Setup hours = 0, Labor Hours = 4, Machine Hours = 0, Lot Sizing = 1)<step>
                        Perform final inspection per engineering specification <specs>AWC-915</specs>.
                    </step><step>Complete all required certification forms.</step><step>Move to shipping.</step></Location>
			</root>'

go

--insert a new location - <Location 1000/>.   
update [test].[production_schema]
set    [Instructions].modify('  
  declare namespace MI="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions";  
insert <MI:Location LocationID="1000"  LaborHours="1000"  LotSize="1000" >  
           <MI:step>Do something using <MI:tool>hammer</MI:tool></MI:step>  
         </MI:Location>  
  as first  
  into   (/MI:root)[1]  
')

go

select [Instructions]
from   [test].[production_schema]

go

-- Now replace manu. tool in location 1000  
update [test].[production_schema]
set    [Instructions].modify('  
  declare namespace MI="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions";  
  replace value of (/MI:root/MI:Location/MI:step/MI:tool)[1]   
  with   "screwdriver"  
')

go

select [Instructions]
from   [test].[production_schema]

-- Now replace value of lot size  
update [test].[production_schema]
set    [Instructions].modify('  
  declare namespace MI="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions";  
  replace value of (/MI:root/MI:Location/@LotSize)[1]   
  with   500 cast as xs:decimal ?  
')

go

select [Instructions]
from   [test].[production_schema]; 
