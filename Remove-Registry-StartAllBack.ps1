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
#     This is a small script helping to fully remove StartAllBack from windows
#     by search for a empty registy key in "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID"
#
# How to use:
#     powershell -executionpolicy bypass -file {PATH_TO_THIS_PS1_SCRIPT}
#
# Example:
#     powershell -executionpolicy bypass -file .\Remove-Registry-StartAllBack.ps1
#     powershell -executionpolicy bypass -file .\Remove-Registry-StartAllBack.ps1 -Automate True
#
# Requirements:
#     - Powershell v7.3+: Install/Upgrade Powershell with "winget install Microsoft.PowerShell"
#
#####

param(
    # wether to run this script without any user-interaction, defaults to false if not 'TRUE' or 'T' or '1'
    [Parameter(Mandatory=$False)]
    [string] $Automate = "",

    # the root-registry-directory, will eventually default to 'HKEY_CURRENT_USER'
    [Parameter(Mandatory=$False)]
    [string] $HKEY = ""
)

# ps-config
$ErrorActionPreference = "Stop"

# quickly transform user-input
$Automate = $Automate.ToUpper().Trim()
$_Automatic = ($Automate -eq "TRUE") -or ($Automate -eq "1") -or ($Automate -eq "T")

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
    Write-Host ' This software searches the windows registry and deletes on demand certain entries from it'
    Write-Host '         if you are unsure about the implications create a backup of the entries located at '
    Write-Host ('         "' + $(Get-RegistryPath-CLSID-All) + '"') -ForegroundColor Cyan
    Write-Host '         or abort this script anytime using ' -NoNewline
    Write-Host 'CTRL + C' -ForegroundColor Red
    Write-Host ''
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
    Write-Host '  All candidates processed.'
    Write-Host '  Operation completed ' -NoNewline
    Write-Host 'successfully' -NoNewline -ForegroundColor Green
    Write-Host '.'
    Write-Host ''
}

#
# Helper to determine the fs-registry-fullpath
#
function Get-RegistryPath-CLSID-All() {
    if ([string]::IsNullOrEmpty($HKEY)) {
        return 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\*'     
    } else {
        return 'Registry::'+ $HKEY +'\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\*'
    }
}

#
# Determines the list of potential registry-candiates
#
function Search-Registry() {
    $regPath = Get-RegistryPath-CLSID-All
    Write-Host '> Searching ' -NoNewline -ForegroundColor DarkCyan
    Write-Host 'at ' -NoNewline
    Write-Host ('"' + $regPath + '"') -ForegroundColor Cyan

    $keys = Get-ChildItem -Path ($regPath) | Select-Object -ExpandProperty Name
    $canditates = @()

    # must match regex
    $idx = 0
    while ($idx -lt $keys.length){
        if ($keys[$idx] -cmatch '\{[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{8}.*$') {
            $canditates += $keys[$idx]
        }
        $idx++
    }

    # must not contain childs
    $idx = 0
    $_canditates = $canditates
    $canditates = @()
    while ($idx -lt $_canditates.length){
        $childCount = Get-Item -Path ('Registry::' + $_canditates[$idx] + "\*") | Select-Object -ExpandProperty Name | Measure-Object | Select-Object -ExpandProperty Count
        if($childCount -eq 0) {
            $canditates += $_canditates[$idx]
        }
        $idx++
    }

    if ($canditates.Count -eq 0) {
        Write-Host ''
        Write-Host '> Aborting ' -NoNewline -ForegroundColor Red
        Write-Host 'operation since ' -NoNewline
        Write-Host 'no potential canditate(s) ' -NoNewline -ForegroundColor Red
        Write-Host 'have been found.'
        Write-Host ''
        Exit 0
    }

    Write-Host ''
    Write-Host '> Detected ' -NoNewline -ForegroundColor DarkCyan
    Write-Host $canditates.Count -NoNewline -ForegroundColor Cyan
    if ($canditates.Count -eq 1) {
        Write-Host ' potential candidate:'
    } else {
        Write-Host ' potential candidates:'
    }
    Write-Host ''
    
    $idx = 0
    while ($idx -lt $canditates.length){ 
        Write-Host '  [ ' -NoNewline
        Write-Host ($idx + 1) -NoNewline -ForegroundColor Cyan
        Write-Host ' ]: ' -NoNewline
        Write-Host ('"' + $canditates[$idx] + '"') -ForegroundColor Cyan
        $idx++
    }
    
    if ($canditates.Count -eq 1) {
        Write-Host ''
        Write-Host ' '-NoNewline
        Write-Host ' INFO: ' -NoNewline -BackgroundColor DarkGreen -ForegroundColor White
        Write-Host ' There is relatively ' -NoNewline
        Write-Host 'high confidence ' -NoNewline  -ForegroundColor DarkGreen
        Write-Host 'that given key is created from StartAllBack.'
    } else {
        Write-Host ''
        Write-Host ' '-NoNewline
        Write-Host ' WARN: ' -NoNewline -ForegroundColor DarkRed -BackgroundColor DarkYellow
        Write-Host ' There is relatively ' -NoNewline
        Write-Host 'low confidence ' -NoNewline -ForegroundColor Red
        Write-Host 'that given key is created from StartAllBack.'
        Write-Host ' '-NoNewline
        Write-Host ' WARN: ' -NoNewline -ForegroundColor DarkRed -BackgroundColor DarkYellow
        Write-Host ' Its recommended to create a ' -NoNewline
        Write-Host 'backup ' -NoNewline -ForegroundColor Red
        Write-Host 'of each registry-key and try each to remove each element in ' -NoNewline
        Write-Host 'single-mode' -NoNewline -ForegroundColor Red
        Write-Host '!'
    }

    $script:canditates = $canditates
}

#
# Asks the user how to handle the candidates  
#
function Interactive-Delete() {
    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
    Write-Host ''
    Write-Host '> Choose' -NoNewline -ForegroundColor DarkCyan
    if ($script:canditates.length -eq 1) {
        Write-Host ' how to handle the candiate:'
    } else {
        Write-Host ' how to handle the candiates:'
    }

    Write-Host ''
    # option all
    Write-Host '    A' -NoNewline -ForegroundColor Cyan
    Write-Host 'll-at-once : ' -NoNewline 
    Write-Host 'Deletes all without addtional user-interaction' -ForegroundColor DarkGray
    # option single
    Write-Host '    ' -NoNewline
    Write-Host 'S' -NoNewline -ForegroundColor Cyan
    Write-Host 'ingle-mode : ' -NoNewline 
    Write-Host 'Asks how to handle each candiate seperately' -ForegroundColor DarkGray
    # option cancel
    Write-Host '    C' -NoNewline -ForegroundColor Cyan
    Write-Host 'ancel      : ' -NoNewline 
    Write-Host 'Aborts this script' -ForegroundColor DarkGray
    Write-Host ''
    # call-to-action
    Write-Host ' Type the highlighted first letter ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' A ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
    Write-Host ', ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' S ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
    Write-Host ' or ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' C ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
    Write-Host ' and confirm your choice by pressing ' -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host ' ENTER ' -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host '. ' -BackgroundColor White -ForegroundColor Black
    Write-Host ''

    if ($_Automatic) {
        Interactive-Delete-Yolo
    } else {
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
            if ($ui -eq "A") {
                Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
                Write-Host ''
                Write-Host '> Executing ' -ForegroundColor DarkCyan -NoNewline
                Write-Host 'All-at-once' -ForegroundColor Cyan
                Interactive-Delete-Yolo
                break
            }
            if ($ui -eq "S") {
                Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
                Write-Host ''
                Write-Host '> Executing ' -ForegroundColor DarkCyan -NoNewline
                Write-Host 'Single-mode' -ForegroundColor Cyan
                Interactive-Delete-SingleMode
                break
            }

            Write-Host '> Invalid input. ' -ForegroundColor DarkRed -BackgroundColor DarkYellow
            Write-Host 'Please try again by either typing their first letter'
            Write-Host 'or abort with ' -NoNewline
            Write-Host 'CTRL + C' -ForegroundColor Red
            Write-Host ''
        }
    }
}

#
# Loops all candidates and deletes them without user-interaction
#
function Interactive-Delete-Yolo() {
    Write-Host ''
    $canditates = $script:canditates
    $idx = 0
    while ($idx -lt $canditates.length){
        Write-Host '> Deleting ' -NoNewline -ForegroundColor DarkCyan
        Write-Host 'canditate [ ' -NoNewline
        Write-Host ($idx + 1) -NoNewline -ForegroundColor Cyan
        Write-Host ' ]: ' -NoNewline
        Write-Host ('"' + $canditates[$idx] + '"') -ForegroundColor Cyan
        Remove-Item -Path ('Registry::'+$canditates[$idx]) -Force
        $idx++
    }
}  

#
# Loops all candidates and deletes them upon user-request
#
function Interactive-Delete-SingleMode() {
    $canditates = $script:canditates
    $idx = 0
    while ($idx -lt $canditates.length){
        Write-Host ''
        Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---' -ForegroundColor DarkCyan
        Write-Host ''
        Write-Host '> Delete' -NoNewline -ForegroundColor DarkCyan
        Write-Host ' canditate [ ' -NoNewline
        Write-Host ($idx+1) -NoNewline -ForegroundColor Cyan
        Write-Host ' ] ?'
        Write-Host '  [ ' -NoNewline
        Write-Host ($idx + 1) -NoNewline -ForegroundColor Cyan
        Write-Host ' ]: ' -NoNewline
        Write-Host ('"' + $canditates[$idx] + '"') -ForegroundColor Cyan
        Write-Host ''
        # call-to-action
        Write-Host ' Type ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host ' D ' -NoNewline -ForegroundColor White -BackgroundColor DarkRed
        Write-Host ' to delete it ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host 'or ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host ' K ' -NoNewline -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ' to keep it and confirm your choice by pressing ' -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host ' ENTER ' -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
        Write-Host '. ' -BackgroundColor White -ForegroundColor Black
        
        $shouldDelete = $false
        while ($true) {
            Write-Host ''
            $ui = Read-Host
            $ui = $ui.ToLower().Trim()
            
            if ($ui -eq 'd') {
                $shouldDelete = $true
                break
            }
            if ($ui -eq 'k') {
                $shouldDelete = $false
                break
            }
            Write-Host ''
            Write-Host '> Invalid input. ' -ForegroundColor DarkRed -BackgroundColor DarkYellow
            Write-Host 'Please try again by either typing D to delete the candiate or K to keep it '
            Write-Host 'or abort with ' -NoNewline
            Write-Host 'CTRL + C' -ForegroundColor Red
        }

        if ($shouldDelete) {
            Write-Host ''
            Write-Host '> Deleting ' -NoNewline -ForegroundColor DarkCyan
            Write-Host 'canditate [ ' -NoNewline
            Write-Host ($idx + 1) -NoNewline -ForegroundColor Cyan
            Write-Host ' ]'
            Remove-Item -Path ('Registry::'+$canditates[$idx]) -Force
        }
        else {
            Write-Host ''
            Write-Host '> Keeping ' -NoNewline -ForegroundColor DarkCyan
            Write-Host 'canditate [ ' -NoNewline
            Write-Host ($idx + 1) -NoNewline -ForegroundColor Cyan
            Write-Host ' ]'
        }

        $idx++
    }
    
    # done
    Print-Finish
}  

#
# Flow
#
Print-Headers
Search-Registry
Interactive-Delete

# for debuging restart explorer to force the creation of the next token
#stop-process -name explorer –force
Exit 0