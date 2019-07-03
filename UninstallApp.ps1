#
# Uninstall Script
#

#Define Search Paths

$SearchPaths = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

#Define Application Name to uninstall (but as your using -match in your where-object this would need to be a regular expression)

$SearchTerm = 'App'

#Get the GUID's for the applications to uninstall, this is what we pass to msiexec.msi.
#check msiexec /? in a cmd prompt for more help on msiexec.exe

$AppsToUninstall = Get-ChildItem -Path $SearchPaths | Get-ItemProperty | Where-Object {$_.DisplayName -match $SearchTerm } | Select-Object -Property PSChildName, DisplayName

#The above search can return multiple GUID's we can uninstall each of the returned GUID's using s foreach loop

foreach($App in $AppsToUninstall)
{
	<#
	  Define MSIExec Arguments
	  The log filename will include spaces so that argument must be encase in "" when passed as an argument 
	  We include this in the string by escaping it with a back tick `

	  a full list of msiexec arguments can be found by starting cmd and typing "msiexec /?"
	#>

	#Define a log file to store the msiexec output (not required but can be useful)

	$MsiLog = $App.DisplayName.ToString() + "_Uninstall.log`""
	
	$Args = "/Uninstall" + $App.PSChildName + " /passive /norestart /log `"C:\Temp\" + $App.DisplayName.ToString() + "_Uninstall.log`""
	
	<#
	  This would be the argument list if you did not want the log file created
	  $Args = "/Uninstall" + $App.PSChildName + " /passive /norestart"
	#>

	#try block to capture any errors 

	try
	{
		<#
		  The start-process cmdlt will run msiExec.exe passing it the argument string we have defines above
		#>

		Start-Process "msiexec.exe" -ArgumentList $Args -Wait -NoNewWindow
	}
	catch
	{
		#define the message to output to the powershell console

		$message = "Failed to install " + $App.DisplayName.ToString() + " because of the following error: " + $_.Exception.Message
		Write-Output $message 
	}
	
}
