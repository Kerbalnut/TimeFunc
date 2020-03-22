
#-----------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------[Functions]------------------------------------------------------

# help about_Functions
# help about_Functions_Advanced
# help about_Functions_Advanced_Methods
# help about_Functions_Advanced_Parameters
# Get-Verb

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#https://www.powershellgallery.com/packages/Convert-Time/1.0#

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


Function Log-Time {
	<#
		.SYNOPSIS
		Log-Time

		.DESCRIPTION
		Log-Time

		.PARAMETER TimeLogFile
		TimeLogFile

		.PARAMETER TimeStampTag
		TimeStampTag

		.PARAMETER Interactive
		Interactive

		.PARAMETER ClockIn
		ClockIn

		.PARAMETER ClockOut
		ClockOut

		.PARAMETER TimeStamp
		TimeStamp

		.PARAMETER TaskStart
		TaskStart

		.PARAMETER TaskStop
		TaskStop
		
		.PARAMETER BreakStart
		BreakStart
		
		.PARAMETER BreakStop
		BreakStop
		
		.PARAMETER PauseStart
		PauseStart
		
		.PARAMETER PauseStop
		PauseStop
		
		.PARAMETER Distraction
		Distraction
		
		.EXAMPLE
		C:\PS> Test-Param -A "Anne" -D "Dave" -F "Freddy"
	#>
	Param (
		#[CmdletBinding(DefaultParameterSetName="ByUserName")]
		# Script parameters go here
		#https://ss64.com/ps/syntax-args.html
		#http://wahlnetwork.com/2017/07/10/powershell-aliases/
		#https://www.jonathanmedd.net/2013/01/add-a-parameter-to-multiple-parameter-sets-in-powershell.html
		[Parameter(Mandatory=$true,Position=0)]
		[string]$TimeLogFile = '.\TimeLog.csv', 
		
		[Parameter(Mandatory=$false)]
		[Alias('i','PickTime','Add')]
		[switch]$Interactive = $false,
		
		[Parameter(Mandatory=$false,
		Position=1,
		ParameterSetName='CustomTag')]
		[string]$TimeStampTag,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='ClockInTag')]
		[switch]$ClockIn,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='ClockOutTag')]
		[switch]$ClockOut,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='TimeStampTag')]
		[switch]$TimeStamp,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='TaskStartTag')]
		[string]$TaskStart,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='TaskStopTag')]
		[switch]$TaskStop,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='BreakStartTag')]
		[switch]$BreakStart,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='BreakStopTag')]
		[switch]$BreakStop,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='PauseStartTag')]
		[string]$PauseStart,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='PauseStopTag')]
		[switch]$PauseStop,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='DistractionTag')]
		[switch]$Distraction
		
	)
	
	# Function name:
	# https://stackoverflow.com/questions/3689543/is-there-a-way-to-retrieve-a-powershell-function-name-from-within-a-function#3690830
	#$FunctionName = (Get-PSCallStack | Select-Object FunctionName -Skip 1 -First 1).FunctionName
	#$FunctionName = (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Name
	$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
	Write-Verbose "Running function: $FunctionName"
	
	# -----------------------------------------------------------------------------------------------------------------------
	# Evaluate input parameters
	# -----------------------------------------------------------------------------------------------------------------------
	
	If (!$TimeLogFile) {
		Write-Warning "Time-Log file does not exist: '$TimeLogFile'"
        Do {
            $UserInput = Read-Hose "Would you like to create it? [Y/N]"
        } until ($UserInput -eq 'y' -Or $UserInput -eq 'n')
        If ($UserInput -eq 'y') {
            New-Item $UserInput #| Out-Null
        } else {
            Return
        }
	}
	
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	If ($TimeStampTag) {
		$TimeLogTag = $TimeStampTag
		$BeginEnd = "[TimeStamp]"
	}
	
	If ($ClockIn) {
		$TimeLogTag = "Clock-In"
		$BeginEnd = "[Begin]"
	}
	
	If ($ClockOut) {
		$TimeLogTag = "Clock-Out"
		$BeginEnd = "[End]"
	}
	
	If ($TimeStamp) {
		$TimeLogTag = "TimeStamp"
		$BeginEnd = "[TimeStamp]"
	}
	
	If ($TaskStart) {
		$TimeLogTag = "Task-Start='$TaskStart'"
		$BeginEnd = "[Begin]"
	}
	
	If ($TaskStop) {
		$TimeLogTag = "Task-Stop"
		$BeginEnd = "[End]"
	}
	
	If ($BreakStart) {
		$TimeLogTag = "Break-Start"
		$BeginEnd = "[Begin]"
	}
	
	If ($BreakStop) {
		$TimeLogTag = "Break-Stop"
		$BeginEnd = "[End]"
	}
	
	If ($PauseStart) {
		$TimeLogTag = "Pause-Start='$PauseStart'"
		$BeginEnd = "[Begin]"
	}
	
	If ($PauseStop) {
		$TimeLogTag = "Pause-Stop"
		$BeginEnd = "[End]"
	}
	
	If ($Distraction) {
		$TimeLogTag = "Distraction"
		$BeginEnd = "[TimeStamp]"
	}
	
	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# -----------------------------------------------------------------------------------------------------------------------
	# Build Time-Log Entry
	# -----------------------------------------------------------------------------------------------------------------------
	
	
} # End Log-Time function ----------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function Total-TimestampArray {
	
	Param (
		#Script parameters go here
		# https://ss64.com/ps/syntax-args.html
		[Parameter(Mandatory=$false,Position=0)]
		[string]$HRtype = 'SingleLine', 
		
		[Parameter(Mandatory=$false)]
		[switch]$Endcaps = $false,

		[Parameter(Mandatory=$false)]
		[string]$EndcapCharacter = '#',
		
		[Parameter(Mandatory=$false)]
		[switch]$IsWarning = $false,

		[Parameter(Mandatory=$false)]
		[switch]$IsVerbose = $false,

		[Parameter(Mandatory=$false)]
		[switch]$MaxLineLength = $false
	)
	
	# Function name:
	# https://stackoverflow.com/questions/3689543/is-there-a-way-to-retrieve-a-powershell-function-name-from-within-a-function#3690830
	#$FunctionName = (Get-PSCallStack | Select-Object FunctionName -Skip 1 -First 1).FunctionName
	#$FunctionName = (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Name
	$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
	Write-Verbose "Running function: $FunctionName"
	
	
} # End Total-TimestampArray function ---------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------


