use [chamomile];

go

declare @stack xml([chamomile].[xsc])= N'<chamomile:stack xmlns:chamomile="http://www.katherinelightsey.com/" timestamp="2014-06-30T18:37:43.61">
    	  <subject fqn="[computer_physical_netbios].[machine].[instance].[database].[schema].[subject]" unique="false" />
    	  <object>
			<command_stack fqn="[computer_physical_netbios].[machine].[instance].[chamomile].[test].[run]" recursion_level="1">
    				<command fqn="[test_test].[trigger_test]" timestamp="2014-06-30T18:37:43.61"/>
    		</command_stack>
    	  </object>
    	</chamomile:stack>';

execute [test].[run]
  @stack=@stack output;

select @stack as N'@stack'; 
