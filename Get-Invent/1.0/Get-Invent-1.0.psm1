function Get-Invent ($srv="localhost"){
<#
.SYNOPSIS
Remote and local hardware inventory via WMI
.DESCRIPTION
Example:
Get-Invent server-01
Get-Invent localhost # default localhost
.LINK
https://github.com/Lifailon/Get-Invent
#>
$path = "$env:temp\Get-Invent.tmp"
$gw = @()
$gw += gwmi Win32_OperatingSystem -computername $srv | fl Caption,Version
$gw += gwmi Win32_BaseBoard -computername $srv | fl Manufacturer,Product
$gw += gwmi Win32_Processor -computername $srv | fl Name,
@{Label="Core"; Expression={$_.NumberOfCores}},
@{Label="Thread"; Expression={$_.NumberOfLogicalProcessors}}
$gw += gwmi Win32_PhysicalMemory -computername $srv | fl DeviceLocator,
@{Label="Memory"; Expression={[string]($_.Capacity/1Mb)+" Mb"}}
$gw += gwmi Win32_DiskDrive -computername $srv | fl Model,
@{Label="Size"; Expression={[string]([int]($_.Size/1Gb))+" Gb"}}
$gw += gwmi Win32_logicalDisk -ComputerName $srv | where {$_.Size -ne $null} | fl @{
Label="Value"; Expression={$_.DeviceID}}, @{Label="All"; Expression={
[string]([int]($_.Size/1Gb))+" Gb"}},@{Label="Free"; Expression={
[string]([int]($_.FreeSpace/1Gb))+" Gb"}}, @{Label="Free"; Expression={
[string]([int]($_.FreeSpace/$_.Size*100))+" %"}}
$gw += gwmi Win32_VideoController -computername $srv | fl Name,
CurrentHorizontalResolution,CurrentVerticalResolution,DriverVersion,
@{Label="vRAM"; Expression={[string]($_.AdapterRAM/1Gb)+" Gb"}}
$gw += gwmi Win32_NetworkAdapter -computername $srv | where {
$_.Macaddress -ne $null} | fl Name,Macaddress,Manufacturer
$gw > $path
$gc = gc $path
rm $path
$inv = @()
0..100 | %{if (!$gc[$_].Length -eq 0) {$inv += $gc[$_]}}
$inv = $inv -replace "\s{2,20}"," "
$inv
}