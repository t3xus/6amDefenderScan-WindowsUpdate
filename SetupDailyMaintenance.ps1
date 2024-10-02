<#
.SYNOPSIS
    Script to automate the creation, configuration, and scheduling of daily Windows Defender scan and Windows Update initialization.

.DESCRIPTION
    This script dynamically creates a daily maintenance script (DailyMaintenance.ps1) in the user's home directory, 
    sets appropriate permissions, and schedules it to run at 6 AM daily. Maintenance tasks include Windows Update 
    and a quick scan with Windows Defender.

.EXAMPLE
    .\SetupDailyMaintenance.ps1
    This command will execute the script in its current directory.

.NOTES
    Author: James Gooch
    Last Edit: October 2, 2024
    Version: 1.0.0
    Requires: PowerShell version 5.1 or higher

.LINK
    For more information on Windows Update and PowerShell, refer to Microsoft documentation.

.COMPONENT
    System Maintenance, Scheduled Tasks

.ROLE
    System Administrator, User

.FUNCTIONALITY
    Script Generation, ACL Modification, Task Scheduling

#>

# Define the MIT License header
@'
MIT License

Copyright (c) <year> James Gooch

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'@

# Define the Current User's Home Folder
$userHome = [System.Environment]::GetFolderPath('UserProfile')

# Define the path to the DailyMaintenance.ps1 script
$maintenanceScriptPath = "$userHome\DailyMaintenance.ps1"

# PowerShell code to be written in DailyMaintenance.ps1
$maintenanceScriptContent = @'
# DailyMaintenance.ps1
# Script to perform system maintenance tasks such as scanning and updating

# Run Windows Update
Write-Host "Running Windows Update..."
Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot

# Perform a quick scan with Windows Defender
Write-Host "Running Windows Defender Quick Scan..."
Start-MpScan -ScanType QuickScan
'@

# Write the PowerShell code to the DailyMaintenance.ps1 file
Set-Content -Path $maintenanceScriptPath -Value $maintenanceScriptContent -Force

# Set the DailyMaintenance.ps1 file to be executable
$acl = Get-Acl -Path $maintenanceScriptPath
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "ReadAndExecute", "Allow")
$acl.SetAccessRule($rule)
Set-Acl -Path $maintenanceScriptPath -AclObject $acl

# Create a Scheduled Task to run the DailyMaintenance.ps1 script at 6 AM daily
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File `"$maintenanceScriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At 6:00AM
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -AllowHardTerminate -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)

# Register the task
Register-ScheduledTask -TaskName "6am Scan and Update" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Daily system scan and update task"

Write-Host "Scheduled task '6am Scan and Update' has been created and will run at 6 AM daily."
Write-Host "The script DailyMaintenance.ps1 has been written to $maintenanceScriptPath and set to executable.
