<#
-SYNOPSIS
Collects basic endpoint information

-DESCRIPTION
This script gathers read-only OS information, uptime, C: drive space, key services and installed applications from uninstall registry paths.

-NOTES
Purpose: Endpoint Engineering learning project

#>

# System information
$OS = Get-CimInstance Win32_OperatingSystem
$Disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$LastBoot = $OS.LastBootUpTime
$Uptime = New-TimeSpan -Start $LastBoot -End (Get-Date)

# Key services
$Defender = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$IME = Get-Service -Name IntuneManagementExtension -ErrorAction SilentlyContinue
$SCCM = Get-Service -Name CcmExec -ErrorAction SilentlyContinue

# Build endpoint object
$EndpointHealth = [PSCustomObject]@{
    ComputerName              = $env:COMPUTERNAME
    UserName                  = $env:USERNAME
    OSCaption                 = $OS.Caption
    OSVersion                 = $OS.Version
    LastBoot                  = $LastBoot
    UptimeDays                = $Uptime.Days
    UptimeHours               = $Uptime.Hours
    CDriveFreeGB              = [math]::Round($Disk.FreeSpace / 1GB, 2)
    CDriveTotalGB             = [math]::Round($Disk.Size / 1GB, 2)
    DefenderService           = if ($Defender) { $Defender.Status } else { "Not found" }
    IntuneManagementExtension = if ($IME) { $IME.Status } else { "Not found" }
    SCCMClient                = if ($SCCM) { $SCCM.Status } else { "Not found" }
}

Write-Host "`nEndpoint Health Summary" 
$EndpointHealth | Format-List

Write-Host "`n-------------------------------------------"

# Installed applications
Write-Host "`nInstalled Applications" 

$UninstallPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$AppFilter = Read-Host "Enter app name to search or leave blank for all apps:"

if ([string]::IsNullOrWhiteSpace($AppFilter)) {
    $InstalledApps | Format-Table -AutoSize
} else {
    $InstalledApps | Where-Object {$_.DisplayName -like "*$Appfilter*"} | Format-Table -AutoSize 
    }

Write-Host "`n-------------------------------------------"

#Export logs to .csv

$EndpointHealth | Export-Csv ".\Logs\EndpointHealth.csv" -NoTypeInformation
$InstalledApps | Export-Csv ".\Logs\InstalledApps.csv" -NoTypeInformation