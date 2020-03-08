<#
.SYNOPSIS
Build script for the TimeFunctions module.

.DESCRIPTION
To run this build script, run the "Invoke-Build" command from a PowerShell prompt in the module's directory.

To install the build module, follow thsee instructions at https://github.com/nightroman/Invoke-Build as also copied below:

Install as module: Invoke-Build is distributed as the module InvokeBuild. In PowerShell 5.0 or with PowerShellGet you can install it by this command:

PS:\> Install-Module InvokeBuild

To install the module with Chocolatey, run the following command. NOTE: This package is maintained by its owner, see package info.

C:\> choco install invoke-build -y

Module commands: Invoke-Build, Build-Checkpoint, Build-Parallel. Import the module in order to make them available:

PS:\> Import-Module InvokeBuild

Go to the module's directory

PS:\> CD "$Home\Documents\GitHub\Batch-Tools-SysAdmin\PowerShell\modules\TimeFunctions"

Run the build command, "Invoke-Build"

PS:\> Invoke-Build

.EXAMPLE
Invoke-Build

.EXAMPLE
CD "$Home\Documents\GitHub\Batch-Tools-SysAdmin\PowerShell\modules\TimeFunctions"
PS:\> Invoke-Build

.EXAMPLE
Install-Module InvokeBuild
PS:\> CD "$Home\Documents\GitHub\Batch-Tools-SysAdmin\PowerShell\modules\TimeFunctions"
PS:\> Invoke-Build

.LINK
https://bitsofknowledge.net/2018/03/24/powershell-must-have-tools-for-development/

.LINK
https://github.com/nightroman/Invoke-Build

.LINK
http://duffney.io/GettingStartedWithInvokeBuild#powershell-module-development-workflow
#>

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#http://techgenix.com/powershell-functions-common-parameters/
# To enable common parameters in functions (-Verbose, -Debug, etc.) the following 2 lines must be present:
#[cmdletbinding()]
#Param()

[cmdletbinding()]
Param(
	
)

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#-----------------------------------------------------------------------------------------------------------------------
#=======================================================================================================================
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#
##Script MAIN Execution goes here

#Clear-Host # CLS
Start-Sleep -Milliseconds 100 #Bugfix: Clear-Host acts so quickly, sometimes it won't actually wipe the terminal properly. If you force it to wait, then after PowerShell will display any specially-formatted text properly.

#=======================================================================================================================

# Run chosen tasks for this build script

#Task . InstallDependencies, ResetLogFile, Analyze, Test, UpdateVersion, Clean, Archive, IntegrateFunctions, BuildModule
#Task . InstallDependencies, ResetLogFile, Test, IntegrateFunctions, BuildModule
#Task . ResetLogFile, Test, IntegrateFunctions, BuildModule
Task . ResetLogFile, IntegrateFunctions, BuildModule

#=======================================================================================================================

#-----------------------------------------------------------------------------------------------------------------------

# Install the dependencies required to perform the rest of this build script.

Task InstallDependencies {
	Install-Module PSScriptAnalyzer #-Force
	Install-Module Pester #-Force
}

#-----------------------------------------------------------------------------------------------------------------------

# Reset the build log file

Task ResetLogFile {
	#
}

#-----------------------------------------------------------------------------------------------------------------------

# Use PSScriptAnalyzer to "lint" PowerShell code, a static code checker that uses a set of rules to check for common errors and style
#https://github.com/PowerShell/PSScriptAnalyzer
#https://www.powershellgallery.com/packages/PSScriptAnalyzer

Task Analyze {
	$ScriptAnalyzerParams = @{
		Path = "$BuildRoot\DSCClassResources\TeamCityAgent\"
		Severity = @('Error', 'Warning')
		Recurse = $true
		Verbose = $false
		ExcludeRule = 'PSUseDeclaredVarsMoreThanAssignments'
	}
	
	$ScriptAnalyzerResults = Invoke-ScriptAnalyzer @ScriptAnalyzerParams
	
	If ($ScriptAnalyzerResults) {
		$ScriptAnalyzerResults | Format-Table
		Throw "One or more PSScriptAnalyzer errors/warnings where found."
	}
}

#-----------------------------------------------------------------------------------------------------------------------

# Run Pester Tests on our cmdlets/libraries

Task Test {
	# Build Pester Parameters list via hash table
	$InvokePesterParams = @{
		Strict = $true
		PassThru = $true
		Verbose = $false
		EnableExit = $false
	}
	
	# Publish Test Results as NUnitXml
	$TestResults = Invoke-Pester @InvokePesterParams;
	
	# Write test results to log file
	
	# Assert how many failed tests are allowed before failing the build
	$NumberOfFails = $TestResults.FailedCount
	assert($NumberOfFails -eq 0) ('Failed "{0}" unit tests.' -f $NumberOfFails)
}

#-----------------------------------------------------------------------------------------------------------------------

# Build a 'dot-source'-able .ps1 functions library file, by combining all the different function scripts saved individually into one script

Task IntegrateFunctions {
	
	$CurrentLocation = Get-Location
	
	$ModuleFunctions = ""
	
	$ModuleFunctions += Get-Content "$CurrentLocation\Convert-AMPMhourTo24hour.ps1"
	
	$ModuleFunctions += Get-Content "$CurrentLocation\Convert-TimeZones.ps1"
	
	$ModuleFunctions += Get-Content "$CurrentLocation\PromptForChoice-DayDate.ps1"
	
	$ModuleFunctions += Get-Content "$CurrentLocation\ReadPrompt-AMPM24.ps1"
	
	$ModuleFunctions += Get-Content "$CurrentLocation\Read-PromptTimeValues.ps1"
	
	Set-Content -Path "TimeFunctions.ps1" -Value $ModuleFunctions
	
}

#------------------------------------------------------------------------------------------------------------------------

# Build the PowerShell .psm1 module

Task BuildModule {
	
	$ModuleContent = Get-Content "TimeFunctions.ps1"
	
	Set-Content -Path "TimeFunctions.psm1" -Value $ModuleContent
	
}

#-----------------------------------------------------------------------------------------------------------------------


#Script MAIN Execution ends here
#
#
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#=======================================================================================================================
#-----------------------------------------------------------------------------------------------------------------------
