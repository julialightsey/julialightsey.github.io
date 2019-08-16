-- MCKDEVTSQL02
use [pdp_lep];

go

if schema_id(N'dbo_test') is null
  execute (N'create schema dbo_test');

go

if object_id(N'[dbo_test].[test_01]'
             , N'P') is not null
  drop procedure [dbo_test].[test_01];

go

/*
    [master].[dbo_test].[sp_chamomile_documentation_get_server_information]

    execute [dbo_test].[test_01];
*/
create procedure [dbo_test].[test_01]
as
  begin
      declare @builder            [xml],
              @subject_fqn        [nvarchar](max),
              @stripped_timestamp [sysname];

      --
      -------------------------------------------
      execute [dbo].[sp_get_server_information]
        @procedure_id=@@procid,
        @stack =@builder output;

      select @subject_fqn = @builder.value(N'(/*/fqn/@fqn)[1]'
                                           , N'[nvarchar](max)');

      --
      -------------------------------------------
      select @subject_fqn                 as N'@subject_fqn'
             , N'['
               + isnull ( lower ( cast ( serverproperty ( N'ComputerNamePhysicalNetBIOS' ) as [sysname] )), N'default' )
               + N'].['
               + isnull ( lower ( cast ( serverproperty ( N'MachineName' ) as [sysname] )), N'default' )
               + N'].['
               + isnull ( lower ( cast ( serverproperty ( N'InstanceName' ) as [sysname] )), N'default' )
               + N'].['
               + isnull ( lower ( cast ( db_name ( ) as [sysname] )), N'default' )
               + N'].['
               + isnull ( lower ( cast ( object_schema_name ( @@procid ) as [sysname] )), N'default' )
               + N'].['
               + isnull ( lower ( cast ( object_name ( @@procid ) as [sysname] )), N'default' )
               + N']'                     as [built_subject_fqn]
             , @builder.value(N'(/*/complete/@major_version)[1]'
                              , N'[int]') as [major_version]
             , @builder                   as N'@builder';
  end;

go 
