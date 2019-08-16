use [chamomile];

go

if schema_id(N'test') is null
  execute (N'create schema test');

go

declare @test_stack [xml](Production.ManuInstructionsSchemaCollection) = N'<test_stack xmlns="https://github.com/KELightsey/chamomile" name="test stack name" test_count="0" pass_count="0" timestamp="2018-06-24T15:50:19.3466667">
				<description>t</description>

				<test test_name="test name" pass="false" timestamp="2018-06-24T15:50:19.3466667">
					<description>t</description>
					<test_detail>
						<any_valid_xml />
					</test_detail>
				</test>

				<test3 LaborHours="2.5" LotSize="100" MachineHours="3" SetupHours="0.5" LocationID="10" pass="false">
                    Work Center 10 - Frame Forming. The following instructions pertain to Work Center 10. (Setup hours = .5, Labor Hours = 2.5, Machine Hours = 3, Lot Sizing = 100)
					<step>adsfasdf
                        <tool>T-85A framing tool</tool>.
                    </step>
					<step>
                        <tool>Trim Jig TJ-26</tool>
                    </step>
				</test3>

				<test2 LaborHours="2.5" LotSize="100" MachineHours="3" SetupHours="0.5" LocationID="10">
                    Work Center 10 - Frame Forming. The following instructions pertain to Work Center 10. (Setup hours = .5, Labor Hours = 2.5, Machine Hours = 3, Lot Sizing = 100)
					<step>adsfasdf
                        <tool>T-85A framing tool</tool>.
                    </step>
					<step>
                        <tool>Trim Jig TJ-26</tool>
                    </step>
				</test2>
				<test2 LaborHours="2.5" LotSize="100" MachineHours="3" SetupHours="0.5" LocationID="10">
                    Work Center 10 - Frame Forming. The following instructions pertain to Work Center 10. (Setup hours = .5, Labor Hours = 2.5, Machine Hours = 3, Lot Sizing = 100)
					<step>
                        <tool>T-85A framing tool</tool>.
                    </step>
					<step>
                        <tool>Trim Jig TJ-26</tool>
                    </step>
				</test2>
			</test_stack>';



--insert a new location - <Location 1000/>.   

set @test_stack.modify('declare namespace chamomile="https://github.com/KELightsey/chamomile";  
insert <chamomile:test2 LocationID="1000"  LaborHours="1000"  LotSize="1000" >  
           <chamomile:step><chamomile:tool>inserted one place</chamomile:tool></chamomile:step>  
         </chamomile:test2>  
  as last into (/chamomile:test_stack)[1]');

select @test_stack

--
-------------------------------------------------
set @test_stack.modify('declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  replace value of (/chamomile:test_stack/chamomile:test2/@LotSize)[1] with 500 cast as xs:decimal ?')
set @test_stack.modify('declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  replace value of (/chamomile:test_stack/chamomile:test3/@LotSize)[1] with 15 cast as xs:integer ?');

select @test_stack;

--
-------------------------------------------------
declare @true [sysname] = N'true';

set @test_stack.modify('declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  replace value of (/chamomile:test_stack/chamomile:test3/@pass)[1] with sql:variable("@true") cast as xs:string ?');

set @test_stack.modify('declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  replace value of (/chamomile:test_stack/chamomile:test/@pass)[1] with sql:variable("@true") cast as xs:string ?')

select @test_stack
       , @test_stack.value(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  (/chamomile:test_stack/chamomile:test2/@LotSize)[1]', N'[int]') as [LotSize]
       , @test_stack.value(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  (/chamomile:test_stack/chamomile:test3/@pass)[1]', N'[sysname]') as [pass]; 
