#####
#
# Copyright 2022 Jan Gaida
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#####
#
# What is this:
#     This is a small script helping to create a windows-scheduler-task which executes 
#     the 'Remove-Registry-StartAllBack.ps1'-script (must be located at the same root-directory as this script)
#
# How to use:
#     powershell -executionpolicy bypass -file {PATH_TO_THIS_PS1_SCRIPT}
#
# Example:
#     powershell -executionpolicy bypass -file .\Schedule-Remove-Registry-StartAllBack.ps1
#     powershell -executionpolicy bypass -file .\Schedule-Remove-Registry-StartAllBack.ps1 -FireTime 12:00 -TaskName MyName
#
# Requirements:
#     - Powershell v7.3+: Install/Upgrade Powershell with "winget install Microsoft.PowerShell"
#
#####

param(
    # timeformat to apply to the trigger; must be 'hh:mm'
    [Parameter(Mandatory=$False)]
    [string] $FireTime = "06:00",
    
    # Name of the task to be created
    [Parameter(Mandatory=$False)]
    [string] $TaskName = "StartAllBack Remove-Registry",
    
    # root-directory to look at; shall not end with '\' or '/'
    [Parameter(Mandatory=$False)]
    [string] $ScriptRoot = $PSScriptRoot,
    
    # the filename of the dependet ps-script
    [Parameter(Mandatory=$False)]
    [string] $ScriptFilename = "Remove-Registry-StartAllBack.ps1",

    # the ExecutionPolicy to apply when executing the scheduler-task
    [Parameter(Mandatory=$False)]
    [string] $ExecutionPolicy = "bypass"
)

# ps-config
$ErrorActionPreference = "Stop"

# quickly transform user-input
$ScriptLocation = "$PSScriptRoot\$ScriptFilename"


#
# Helper to print out the leading-message
#
function Print-Headers() {
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host '      Remove-Registry-StartAllBack' -ForegroundColor DarkCyan -NoNewline
    Write-Host ' - v1.1.1' -ForegroundColor DarkGray
    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host ' ' -NoNewline
    Write-Host ' WARN: ' -NoNewline -ForegroundColor DarkRed -BackgroundColor DarkYellow
    Write-Host ' This powershell-script is designed to be used with the "Remove-Registry-StartAllBack.ps1"-script.'
    Write-Host '         Run it first and figure out if it suites your needs before scheduling it.'
    Write-Host '         Abort this script anytime using ' -NoNewline
    Write-Host 'CTRL + C' -ForegroundColor Red
    Write-Host ''
    Write-Host ' Copyright 2023 Jan Gaida'
    Write-Host ' Latest version: ' -NoNewline
    Write-Host 'https://github.com/JanGaida/Remove-Registry-StartAllBack' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''
}


#
# Helper to print out the finish-message
#
function Print-Finish() {
    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host '> Finished' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host '  New task scheduled.'
    Write-Host '  Operation completed ' -NoNewline
    Write-Host 'successfully' -NoNewline -ForegroundColor Green
    Write-Host '.'
    Write-Host '  Opening taskscheduler now …'
    Write-Host ''
    taskschd
}

#
# Helper to validate $ScriptLocation or abort
#
function Validate-Script-Location() {
    if (Test-Path -Path $ScriptLocation) {
        Write-Host '> Located ' -NoNewline -ForegroundColor DarkCyan
        Write-Host 'ps-script at ' -NoNewline
        Write-Host ('"'+$ScriptLocation+'"') -NoNewline -ForegroundColor Cyan
        Write-Host "."
        Write-Host ""
    } else {
        Write-Host '> Aborting ' -NoNewline -ForegroundColor Red
        Write-Host 'operation since the ' -NoNewline
        Write-Host ('required script "'+ $ScriptFilename + '" ') -NoNewline -ForegroundColor Red
        Write-Host 'could not be found!'
        Write-Host '  Please grab the ps-script from ' -NoNewline
        Write-Host 'https://github.com/JanGaida/Remove-Registry-StartAllBack ' -NoNewline -ForegroundColor DarkCyan
        Write-Host 'first'
        Write-Host '  and put at into directory ' -NoNewline
        Write-Host ('"' + $PSScriptRoot + '" ') -NoNewline -ForegroundColor Cyan
        Write-Host 'or adjust this scripts parameter to help find it.'
        Write-Host '  No changes ' -NoNewline -ForegroundColor Red
        Write-Host 'have been made!'
        Write-Host ''
        Exit 0
    }
}

#
# Function to create, replace and schedule a new scheduler-task
#
function Schedule-Task() {
    # preexisiting?
    $TaskAlreadyExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName }
    if ($TaskAlreadyExists)  {
        Write-Host '> Detected ' -ForegroundColor DarkCyan -NoNewline
        Write-Host 'a identical scheduler-task'
        Write-Host ' INFO: ' -NoNewline -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ' The exisiting task will be removed and a new one will be created.'
        Write-Host ''
        
        # remove it
        Unregister-ScheduledTask -TaskName "$TaskName" -Confirm:$False 
    }
    
    # action

    Write-Host '> Creating ' -ForegroundColor DarkCyan -NoNewline
    Write-Host 'a new scheduler-task'
    $TaskExecute = "powershell"
    $TaskArguments = "-executionpolicy $ExecutionPolicy -file `"$ScriptLocation`" -Automatic True"
    $TaskAction = New-ScheduledTaskAction -Execute $TaskExecute -Argument $TaskArguments
    
    Write-Host ' INFO: ' -NoNewline -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host ' The job does ' -NoNewline
    Write-Host 'not ' -NoNewline -ForegroundColor Cyan
    Write-Host 'include the ' -NoNewline
    Write-Host 'uninstall' -NoNewline -ForegroundColor Cyan
    Write-Host '-command by default; this must be added manually via the gui of windows task-scheduler.'
    Write-Host ''
    
    Write-Host '    Exec-Target : ' -NoNewline
    Write-Host ('"' + $TaskExecute + '"') -ForegroundColor Cyan
    Write-Host '    Arguments   : ' -NoNewline
    Write-Host ('"' + $TaskArguments + '"') -ForegroundColor Cyan

    # trigger

    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''

    Write-Host '> Choose' -NoNewline -ForegroundColor DarkCyan
    Write-Host ' the occurrens-type of the trigger:'

    Write-Host ''
    # option all
    Write-Host '    S' -NoNewline -ForegroundColor Cyan
    Write-Host 'ingle : ' -NoNewline 
    Write-Host 'The task will be executed only once in X-days' -ForegroundColor DarkGray
    # option single
    Write-Host '    ' -NoNewline
    Write-Host 'D' -NoNewline -ForegroundColor Cyan
    Write-Host 'aily  : ' -NoNewline 
    Write-Host 'The task will be executed repeated every X-days' -ForegroundColor DarkGray
    # option cancel
    Write-Host '    C' -NoNewline -ForegroundColor Cyan
    Write-Host 'ancel : ' -NoNewline 
    Write-Host 'Aborts this script' -ForegroundColor DarkGray
    Write-Host ''
    # call-to-action
    Write-Host ' Type the highlighted first letter ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' S ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
    Write-Host ', ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' D ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
    Write-Host ' or ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' C ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
    Write-Host ' and confirm your choice by pressing ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' ENTER ' -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host '. ' -BackgroundColor White -ForegroundColor Black
    Write-Host ''

    
    $TriggerType = "" 
    while ($true) {
        $ui = Read-Host
        Write-Host ''
        $ui = $ui.ToLower().Trim()
        if ($ui -eq "C") {
            Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
            Write-Host ''
            Write-Host '> Aborting ' -NoNewline -ForegroundColor Red
            Write-Host 'operation upon user-request. ' -NoNewline
            Write-Host 'No changes ' -NoNewline -ForegroundColor Red
            Write-Host 'have been made!'
            Write-Host ''
            Exit 0
        } 
        if ($ui -eq "S") {
            $days = Choose-Days -type "S"
            $datetime = $([datetime]::ParseExact($FireTime, "hh:mm", $null)).AddDays($days)
            $TaskTrigger = New-ScheduledTaskTrigger -Once -At $datetime
            Write-Host ''
            Write-Host '> Creating ' -ForegroundColor DarkCyan -NoNewline
            Write-Host 'a new scheduler-trigger'
            Write-Host ''
            Write-Host '    Fires-At : ' -NoNewline
            Write-Host ('"' + $datetime.ToString("hh:mm dd-MM-yyyy") + '"') -NoNewline -ForegroundColor Cyan
            Write-Host ' (hh:mm dd-MM-yyyy)' -ForegroundColor DarkGray
            Write-Host '    Repeates : ' -NoNewline
            Write-Host '"Once"' -ForegroundColor Cyan
            Write-Host ''
            break
        }
        if ($ui -eq "D") {
            $days = Choose-Days -type "D"
            $TaskTrigger = New-ScheduledTaskTrigger -Daily -DaysInterval $days -At $([datetime]::ParseExact($FireTime, "hh:mm", $null))
            Write-Host ''
            Write-Host '> Creating ' -ForegroundColor DarkCyan -NoNewline
            Write-Host 'a new scheduler-trigger'
            Write-Host ''
            Write-Host '    Fires-At : ' -NoNewline
            Write-Host ('"' + $FireTime + '"') -ForegroundColor Cyan
            Write-Host '    Repeates : ' -NoNewline
            Write-Host ('"Every '+ $days +' days"') -ForegroundColor Cyan
            Write-Host ''
            break
        }

        Write-Host '> Invalid input. ' -ForegroundColor DarkRed -BackgroundColor DarkYellow
        Write-Host 'Please try again by either typing their first letter'
        Write-Host 'or abort with ' -NoNewline
        Write-Host 'CTRL + C' -ForegroundColor Red
        Write-Host ''
    }

    # settings
    
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''

    Write-Host '> Creating' -NoNewline -ForegroundColor DarkCyan
    Write-Host ' the settings for the scheduler-task'
    Write-Host ''
    $TaskSettings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
    
    Write-Host '    Hidden                     : ' -NoNewline
    Write-Host '"Yes"' -NoNewline -ForegroundColor Cyan
    Write-Host ' Indicates that the task will be hiden' -ForegroundColor DarkGray
    Write-Host '    StartWhenAvailable         : ' -NoNewline
    Write-Host '"Yes"' -NoNewline -ForegroundColor Cyan
    Write-Host ' Allows to fire asap after the actual specified time' -ForegroundColor DarkGray
    Write-Host '    MultipleInstances          : ' -NoNewline
    Write-Host '"IgnoreNew"' -NoNewline -ForegroundColor Cyan
    Write-Host ' The exisiting task will be executed, ignoring any conkurent triggers' -ForegroundColor DarkGray
    Write-Host '    AllowStartIfOnBatteries    : ' -NoNewline
    Write-Host '"Yes"' -NoNewline -ForegroundColor Cyan
    Write-Host ' Allows to trigger when windows is running on battery power' -ForegroundColor DarkGray
    Write-Host '    DontStopIfGoingOnBatteries : ' -NoNewline
    Write-Host '"Yes"' -NoNewline -ForegroundColor Cyan
    Write-Host ' Allows to keep executing while windows is going to run on battery power' -ForegroundColor DarkGray

    # finally schedule the task
    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''

    Write-Host '> Scheduling' -NoNewline -ForegroundColor DarkCyan
    Write-Host ' the scheduler-task'

    Register-ScheduledTask -Trigger $TaskTrigger -Action $TaskAction -TaskName $TaskName -Settings $TaskSettings | Out-Null

    Write-Host ' INFO: ' -NoNewline -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host ' The job can be further ' -NoNewline
    Write-Host 'modified ' -NoNewline -ForegroundColor Cyan
    Write-Host 'and ' -NoNewline
    Write-Host 'specified ' -NoNewline -ForegroundColor Cyan
    Write-Host ' via the gui of windows task-scheduler. Check it out!'
    Write-Host ''
    
    Write-Host '    TaskName : ' -NoNewline
    Write-Host ('"'+$TaskName+'"') -NoNewline -ForegroundColor Cyan
    Write-Host ''
}


#
# Helper to determine a day-integer
#
function Choose-Days([string] $type) {
    if ($type -eq "S") {
        Write-Host '> Choose' -NoNewline -ForegroundColor DarkCyan
        Write-Host ' how many days to wait until the script should be executed'
        
        # call-to-action
        Write-Host ''
        Write-Host ' Type the ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host ' number ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
        Write-Host ' of days to wait until the task should be executed and confirm your choice by pressing ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host ' ENTER ' -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host '. ' -BackgroundColor White -ForegroundColor Black
        Write-Host ''
        
    } elseif ($type -eq "D") {
    
        Write-Host '> Choose' -NoNewline -ForegroundColor DarkCyan
        Write-Host ' in how many days to repeat the script again'
        
        # call-to-action
        Write-Host ''
        Write-Host ' Type the ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host ' number ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
        Write-Host ' of days to wait until the task should be executed again and confirm your choice by pressing ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host ' ENTER ' -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host '. ' -BackgroundColor White -ForegroundColor Black
        Write-Host ''
    } else {
        Write-Error "Unexpected call"
    }

    # day input
    $NumberInput = $False
    do {
        $inputString = read-host
        $value = $inputString -as [System.Int32]
        $NumberInput = $value -ne $NULL
        if (-Not $NumberInput) {
            Write-Host ''
            Write-Host '> Invalid input. ' -ForegroundColor DarkRed -BackgroundColor DarkYellow
            Write-Host 'Please try again by typing only numeric characters'
            Write-Host 'or abort with ' -NoNewline
            Write-Host 'CTRL + C' -ForegroundColor Red
            Write-Host ''
        }
    }
    until ( $NumberInput )

    return $value
}

#
# Flow
#
Print-Headers
Validate-Script-Location
Schedule-Task
Print-Finish
Exit 0 