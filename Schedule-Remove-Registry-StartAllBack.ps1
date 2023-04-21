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
#     powershell -executionpolicy bypass -file .\Schedule-Remove-Registry-StartAllBack.ps1 -DaysInterval 50 -AtTime 12pm
#
# Requirements:
#     - Powershell v7.3+: Install/Upgrade Powershell with "winget install Microsoft.PowerShell"
#
#####

param(
    [Parameter(Mandatory=$False)]
    [int] $DaysInterval = 98,
    
    [Parameter(Mandatory=$False)]
    [string] $AtTime = "6am",

    [Parameter(Mandatory=$False)]
    [string] $TaskPath = "StartAllBack",

    [Parameter(Mandatory=$False)]
    [string] $TaskName = "StartAllBack Remove-Registry",
    
    [Parameter(Mandatory=$False)]
    [string] $ScriptRoot = $PSScriptRoot,

    [Parameter(Mandatory=$False)]
    [string] $ScriptFilename = "Remove-Registry-StartAllBack.ps1",

    [Parameter(Mandatory=$False)]
    [string] $ExecutionPolicy = "bypass"
)

# Determine the ps-script-fullpath
$ScriptLocation = "$PSScriptRoot\$ScriptFilename"
If (-Not (Test-Path -Path $ScriptLocation)) {
    Write-Host ""
    Write-Host "Can not find the required ps-script at path '$ScriptLocation'."
    Write-Host ""
    Write-Host "Aborting..."
    Exit 1
} else {
    Write-Host ""
    Write-Host "Detected the ps-script at path '$ScriptLocation'."
}

# Create task and trigger
$TaskExecute = "powershell"
$TaskArguments = "-executionpolicy $ExecutionPolicy -file $ScriptLocation -Automatic True"
$TaskAction = New-ScheduledTaskAction -Execute $TaskExecute -Argument $TaskArguments
$TaskTrigger = New-ScheduledTaskTrigger -Daily -DaysInterval $DaysInterval -At $AtTime
$TaskSettings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Check if a identical task exists
$TaskAlreadyExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName }
if ($TaskAlreadyExists) {
    Write-Host ""
    Write-Host "Detected a task with the same name '$TaskName' ..."

    # Just delete the existing one
    Write-Host "... removing the existing task and creating a new one."
    Unregister-ScheduledTask -TaskName "$TaskName" -Confirm:$False 
}


# Schedule the task
Write-Host "Creating task with:"
Write-Host "   DaysInterval = '$DaysInterval'"
Write-Host "   TaskPath     = '$TaskPath'"
Write-Host "   TaskName     = '$TaskName'"
Write-Host "   Execute      = '$TaskExecute'"
Write-Host "   Arguments    = '$TaskArguments'"
Write-Host ""

Register-ScheduledTask -Trigger $TaskTrigger -Action $TaskAction -TaskName $TaskName -Settings $TaskSettings | Out-Null
Write-Host "Done; Opening taskscheduler .."
taskschd
