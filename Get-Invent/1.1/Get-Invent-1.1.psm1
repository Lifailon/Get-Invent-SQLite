function Get-Invent {
<#
.SYNOPSIS
Remote and local hardware inventory via WMI
.DESCRIPTION
Example:
Get-Invent server-01
Get-Invent localhost # default localhost
Get-Invent -Full server-01 # full report
.LINK
https://github.com/Lifailon/Get-Invent
#>
Param (
$srv="localhost",
[switch]$Full
)
$Collection = New-Object System.Collections.Generic.List[System.Object]
$SYS = gwmi Win32_ComputerSystem -computername $srv
$OS = gwmi Win32_OperatingSystem -computername $srv
$BB = gwmi Win32_BaseBoard -computername $srv
$BBv = $BB.Manufacturer+" "+$BB.Product+" "+$BB.Version
$CPU = gwmi Win32_Processor -computername $srv | select Name,
@{Label="Core"; Expression={$_.NumberOfCores}},
@{Label="Thread"; Expression={$_.NumberOfLogicalProcessors}}
$Memory = gwmi Win32_PhysicalMemory -computername $srv | select Manufacturer,PartNumber,
ConfiguredClockSpeed,@{Label="Memory"; Expression={[string]($_.Capacity/1Mb)}}
$MEMs = $Memory.Memory | Measure -Sum
$PhysicalDisk = gwmi Win32_DiskDrive -computername $srv | select Model,
@{Label="Size"; Expression={[int]($_.Size/1Gb)}}
$PDs = $PhysicalDisk.Size | Measure -Sum
$LogicalDisk = gwmi Win32_logicalDisk -ComputerName $srv | where {$_.Size -ne $null} | select @{
Label="Value"; Expression={$_.DeviceID}}, @{Label="AllSize"; Expression={
([int]($_.Size/1Gb))}},@{Label="FreeSize"; Expression={
([int]($_.FreeSpace/1Gb))}}, @{Label="Free%"; Expression={
[string]([int]($_.FreeSpace/$_.Size*100))+" %"}}
$LDs = $LogicalDisk.AllSize | Measure -Sum
$VideoCard = gwmi Win32_VideoController -computername $srv | select @{
Label="VideoCard"; Expression={$_.Name}}, @{Label="Display"; Expression={
[string]$_.CurrentHorizontalResolution+"x"+[string]$_.CurrentVerticalResolution}}, 
@{Label="vRAM"; Expression={($_.AdapterRAM/1Gb)}}
$VCs = $VideoCard.vRAM | Measure -Sum
$NetworkAdapter = gwmi Win32_NetworkAdapter -computername $srv | where {
$_.Macaddress -ne $null} | select Manufacturer, @{
Label="NetworkAdapter"; Expression={$_.Name}},Macaddress
$NAs = $NetworkAdapter | Measure
$Collection.Add([PSCustomObject]@{
Host = $SYS.Name
Owner = $SYS.PrimaryOwnerName
OS = $OS.Caption
MotherBoard = $BBv
CPU = $CPU[0].Name
Core = $CPU[0].Core
Thread = $CPU[0].Thread
MemoryAll = [String]$MEMs.Sum+" Mb"
MemorySlots = $MEMs.Count
PhysicalDiskCount = $PDs.Count
LogicalDiskCount = $LDs.Count
LogicalDiskAllSize = [String]$LDs.Sum+" Gb"
VideoCardCount = $VCs.Count
VideoCardAllSize = [String]$VCs.Sum+" Gb"
NetworkAdapterCount = $NAs.Count
})
$Collection

if ($full) {
$CollectionMEM = New-Object System.Collections.Generic.List[System.Object]
$Memory | %{
$CollectionMEM.Add([PSCustomObject]@{
MemoryModel = [String]$_.ConfiguredClockSpeed+" Mhz "+$_.Manufacturer+" "+$_.PartNumber
})
}

$CollectionPD = New-Object System.Collections.Generic.List[System.Object]
$PhysicalDisk | %{
$CollectionPD.Add([PSCustomObject]@{
PhysicalDiskModel = [string]$_.Size+" Gb "+$_.Model
})
}

$CollectionLD = New-Object System.Collections.Generic.List[System.Object]
$LogicalDisk | %{
$CollectionLD.Add([PSCustomObject]@{
LogicalDisk = $_.Value
AllSize = [string]$_.AllSize+" Gb"
FreeSize = [string]$_.FreeSize+" Gb"
Free = $_."Free%"
})
}

$CollectionVC = New-Object System.Collections.Generic.List[System.Object]
$VideoCard | %{
$CollectionVC.Add([PSCustomObject]@{
VideoCard = $_.VideoCard
Display = $_.Display
vRAM = [string]$_.vRAM+" Gb"
})
}

$CollectionMEM
$CollectionPD
$CollectionLD
$CollectionVC
$NetworkAdapter

#$Collection.Add([PSCustomObject]@{MemoryModel = $CollectionMEM.MemoryModel})
#$Collection | Add-Member -MemberType NoteProperty -Name "MemoryModel" -Value $CollectionMEM.MemoryModel
}
}