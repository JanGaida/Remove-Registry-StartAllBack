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
#     This is a small script helping to fully remove StartAllback from windows
#     by search for a empty registy key in "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID"
#
# How to use:
#     powershell -executionpolicy bypass -file {PATH_TO_THIS_PS1_SCRIPT}
#
# Example:
#     powershell -executionpolicy bypass -file C:\Users\jan\Desktop\Remove-Reg-StartAllback.ps1
#
# Requirements:
#     - Powershell v7.3+: Install/Upgrade Powershell with "winget install Microsoft.PowerShell"
#
#####

param(
    [string] $HKEY = ""
)

function Get-RegistryPath-CLSID-All() {
    if ([string]::IsNullOrEmpty($HKEY)) {
        return 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\*'     
    } else {
        return 'Registry::'+ $HKEY +'\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\*'
    }
}

function Print-Headers() {
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---'
    Write-Host ''
    Write-Host ' Clear StartAllblack-Registry'
    Write-Host ''
    Write-Host ' Copyright 2023 Jan Gaida'
    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---'
    Write-Host ''
}

function Search-Registry() {
    $regPath = Get-RegistryPath-CLSID-All
    Write-Host ('Searching registry at "' + $regPath + '" ...')
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
        Write-Host 'Aborting operation since no potential canditates have been found.'
        Exit 0
    }

    Write-Host ''
    Write-Host ('Detected '+$canditates.Count+' potential candidate(s):')
    $script:canditates = $canditates
    $idx = 0
    while ($idx -lt $canditates.length){ 
        Write-Host '  [ '($idx + 1)' ]: '$canditates[$idx]
        $idx++
    }
}

function Interactive-Delete-Yolo() {
    Write-Host ''
    $canditates = $script:canditates
    $idx = 0
    while ($idx -lt $canditates.length){
        Write-Host ('Deleting '+($idx+1)+'/'+$canditates.length+': '+$canditates[$idx])
        Remove-Item -Path ('Registry::'+$canditates[$idx]) -Force
        $idx++
    }
    
    Write-Host ''
    Write-Host 'All candidates processed.'
    Write-Host 'Operation completed successfully.'
}  

function Interactive-Delete-SingleMode() {
    Write-Host ''
    $canditates = $script:canditates
    $idx = 0
    while ($idx -lt $canditates.length){
        Write-Host ''
        Write-Host 'Delete canditate ['($idx+1)']: '($canditates[$idx])'?'
        Write-Host '[Y]es or [No]?'
        $shouldDelete = $false
        while ($true) {
            Write-Host ''
            $ui = Read-Host
            Write-Host ''
            $ui = $ui.ToLower().Trim()
            
            if ($ui -eq 'y') {
                $shouldDelete = $true
                break
            }
            if ($ui -eq 'n') {
                $shouldDelete = $false
                break
            }
            Write-Host 'Invalid input. Please try again.'
            Write-Host ''
        }

        if ($shouldDelete) {
            Write-Host 'Deleting '($idx+1)'/'($canditates.length)': '($canditates[$idx])
            Remove-Item -Path ('Registry::'+$canditates[$idx]) -Force
        }
        else {
            Write-Host 'Keeping canditate ['($idx+1)']'
        }

        $idx++
    }
    
    Write-Host ''
    Write-Host 'All candidates processed.'
    Write-Host 'Operation completed successfully.'
    Write-Host ''
}  

function Interactive-Delete() {
    Write-Host ''
    Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---'
    Write-Host ''
    Write-Host 'Try [A]ll at once, follow up in [S]ingle-Mode or [C]ancel this operation ? Confirm your choice with ENTER'
    Write-Host ''

    while ($true) {
    
        $ui = Read-Host
        Write-Host ''
        $ui = $ui.ToLower().Trim()
        if ($ui -eq "C") {
            Write-Host 'Operation is canceled.'
            Exit 0
        } 
        if ($ui -eq "A") {
            Write-Host 'YOLO ...'
            Write-Host ''
            Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---'
            Interactive-Delete-Yolo
            break
        }
        if ($ui -eq "S") {
            Write-Host 'Starting Single-Mode...'
            Write-Host ''
            Write-Host '--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---'
            Interactive-Delete-SingleMode
            break
        }

        Write-Host 'Invalid input. Please try again.'
    }
}

# Flow
Print-Headers
Search-Registry
Interactive-Delete
Exit 0
