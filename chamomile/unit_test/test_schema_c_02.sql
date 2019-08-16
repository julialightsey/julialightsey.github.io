use [chamomile];

go

declare @test_stack xml (Production.ManuInstructionsSchemaCollection) = N'<test_stack xmlns="https://github.com/KELightsey/chamomile" name="test stack name" test_count="0" pass_count="0" timestamp="2018-06-24T15:50:19.3466667">
				<description>t</description>

				<test test_name="test name" pass="false" timestamp="2018-06-24T15:50:19.3466667">
					<description>t</description>
					<test_detail>
						<any_valid_xml />
					</test_detail>
				</test>
			</test_stack>';

set @test_stack.modify('  
  declare namespace chamomile="https://github.com/KELightsey/chamomile";  
insert <chamomile:test test_name="test name 2" pass="false" timestamp="2018-06-24T15:50:19.3466667">
					<chamomile:description>t</chamomile:description>
					<chamomile:test_detail>
						<any_valid_xml />
					</chamomile:test_detail>
				</chamomile:test> 
  as last  
  into   (/chamomile:test_stack)[1]  
');

select @test_stack;  

--
--
set    @test_stack.modify('declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  replace value of (/chamomile:test_stack/chamomile:test/@LotSize)[1] with 500 cast as xs:decimal ?')





select @test_stack.value(N'declare namespace chamomile="https://github.com/KELightsey/chamomile";  
  (/chamomile:test_stack/chamomile:test2/@LotSize)[1]', N'[int]'); 