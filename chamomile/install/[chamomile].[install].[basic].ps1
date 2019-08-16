<#
	Katherine E. Lightsey
	20140212
	
	dependencies: [utility].[handle_error]

	execute_as
		<powershell.exe> .\chamomile.install.basic.ps1 -directory .\ -serverinstance MCK790L8159\CHAMOMILE -database master;
		
		
#>
	#--
	#------------------------------------------
	param([string]$directory, [string]$serverinstance, [string]$database);

	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - (script): " + $MyInvocation.MyCommand.Path);

	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - (parameter) directory: " + $directory);
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - (parameter) serverinstance: " + $serverinstance);
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - (parameter) database: " + $database);

	[string]$inputfile;

	#--
	#------------------------------------------
	Add-PSSnapin SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue;
	Add-PSSnapin SqlServerProviderSnapin100 -ErrorAction SilentlyContinue;
	[Environment]::CurrentDirectory = Get-Location;

	#--
	#------------------------------------------
	$inputfile="chamomile.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.documentation.get_license.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.utility.xsc.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database master;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}


	#--
	#------------------------------------------
	$inputfile="chamomile.utility.xsc.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database chamomile;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}
	#--
	#------------------------------------------
	$inputfile="chamomile.repository_secure.data.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.repository_secure.data.load.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}


	#--
	#------------------------------------------
	$inputfile="master.dbo.sp_get_server_information.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.utility.split_string.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.utility.strip_string.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}
	
	#--
	#------------------------------------------
	$inputfile="chamomile.repository.get_list.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.repository.set.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.repository.get.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.utility.get_meta_data.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.utility.meta_data_list.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.utility.set_meta_data.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.meta_data.load.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}
	#--
	#------------------------------------------
	$inputfile="chamomile.utility.handle_error.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		#invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="master.dbo.sp_create_extended_property.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="master.dbo.sp_get_documentation.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="master.dbo.sp_get_best_practice_analysis.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.repository_test.get.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.repository_test.set.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.test.run.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}

	#--
	#------------------------------------------
	$inputfile="chamomile.lock_test.sql";
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - Installing inputfile: " + $directory+$inputfile);
	try {	
		invoke-sqlcmd -inputfile $directory$inputfile -serverinstance $serverinstance  -database $database;
		write-host "successfully installed - $directory$inputfile";
	} catch [Exception] {
		write-host (((get-date -format yyyyMMdd.HH:mm:ss) + " - Exception occurred in '"  + $MyInvocation.MyCommand.Path + "' attempting to install ($directory$inputfile). Full text of exception follows"));
		write-host $_.Exception.GetType().FullName; 
		write-host $_.Exception.Message; 
		exit 1;
	}
	
	#--
	#-- tests
	#------------------------------------------
	
	#--
	#------------------------------------------
	write-host (".");
	write-host ((get-date -format yyyyMMdd.HH:mm:ss) + " - installation complete.");
	write-host (".");