<#
.PURPOSE
Creates an inventory report of Azure subscription VMs

.DESCRIPTION
Collects virtual machine, disk, tag, and power state information from the active subscription.

Author: Tom Almond
Project: Azure Infra Inventory

Disclaimer: This is not a complete security assessment. This is a learning and reporting tool I wrote for a personal project

#>

$Context = Get-AzContext

if (-not $Context) {
    Write-Error "No Azure context was found."
    return
}

Write-Host "Azure VM Inventory" -ForegroundColor Cyan
Write-Host "Subscription: $($Context.Subscription.Name)"
Write-Host ""

# Gets all VMs and their current status
$VirtualMachines = Get-AzVM -Status

if (-not $VirtualMachines) {
    Write-Warning "No virtual machines were found in this subscription."
    return
}

# Creates one report object for each VM
$Report = foreach ($VM in $VirtualMachines) {

    $PowerState = (
        $VM.Statuses |
        Where-Object { $_.Code -like "PowerState/*" }
    ).DisplayStatus

    [PSCustomObject]@{
        VMName        = $VM.Name
        ResourceGroup = $VM.ResourceGroupName
        Location      = $VM.Location
        VMSize        = $VM.HardwareProfile.VmSize
        PowerState    = $PowerState
    }
}

# Displays the results
$Report |
    Sort-Object ResourceGroup, VMName |
    Format-Table -AutoSize