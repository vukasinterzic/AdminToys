<#
.SYNOPSIS

This function help you find and export disk space information from local or remote computer. 

.DESCRIPTION

This function help you find and export disk space information from local or remote computer. Size is automatically converted to MB,GB or TB.

.PARAMETER Computer

Specifies the name computer that needs to be scanned.

.PARAMETER ExportPath

Specify export file.

.PARAMETER SizeIn

Specify in which unit will disk size be displayed. It can be in MB, GB or TB.

.PARAMETER WriteToLog

If this parameter is used, log will be writtend in file. Specify path.

.INPUTS

None; Computer(s) name(s); SizeIn;

.OUTPUTS

Size, FreeSpace, UsedSpace, Totals

.EXAMPLE

C:\PS> Get-DiskSpace

.EXAMPLE

C:\PS> Get-DiskSpace -Computer COMPUTERNAME

.EXAMPLE

C:\PS> computerlist.txt | Get-DiskSpace

.LINK

http://www.vukasinterzic.com

#>


#create function, that can be used on any PC or multiple PCs
#no computer name paramter = local pc, multiple names = multiple PCs check
#add results to object and then display sorted
#add parameter for export to file
#add parameter for size conversion (MB,GB,TB)
#add parameter pro Logovani (nova funkce?)

# OSETRIT ERROR A kdyz nepujde gwmi tak zkusit Get-CimInstance
# v pripade chyby vypsat chybu a zapsat radek do logu/exportu


function Get-DiskSpace {
    [CmdletBinding()]

    param 
    (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Computers = ".",
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath = "",
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$SizeIn = "",

        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$WriteToLog = "",

        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$Full
    )

    begin {
        Write-Verbose "Function begin. Finding disk space."
    }



}


<#
if ($Full) {
    $selectProperties = @("*")
}
else {
    $selectProperties = @("")
}
#>

if ($Computers) {

    foreach ($Computer in $Computers) {

        $allDisks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $Computer | Select-Object DeviceID, DriveType, VolumeName, Size, FreeSpace, @{n = 'UsedSpace'; e = {$_.Size - $_.FreeSpace}}
        
    }

}



<#plan: check error
if no error continue
create object and add:
properties
convert sizes depending on switch
convert disk tyep to text
calculate sum and add to same object
#>







write `n`r 
$MyString = Get-WmiObject win32_logicaldisk | select DeviceID, VolumeName, @{n = "Size(GB)"; e = {" {0:N2}" -f ($_.Size / 1GB)}}, @{n = "FreeSpace(GB)"; e = {" {0:N2}" -f ($_.FreeSpace / 1GB)}}, @{n = "UsedSpace(GB)"; e = {" {0:N2}" -f (($_.Size - $_.FreeSpace) / 1GB)}} | ft
($MyString | Out-String).Trim()

$WorkVar = Get-WmiObject win32_logicaldisk | select DeviceID, VolumeName, Size, FreeSpace, @{n = "UsedSpace"; e = {$_.Size - $_.FreeSpace}}

$totalsize = 0
$totalfree = 0
$totalused = 0

foreach ($disk in $WorkVar) {
    $totalsize += $disk.Size
    $totalfree += $disk.FreeSpace
    $totalused += $disk.UsedSpace
}

$totalsizeTB = "{0:N2}" -f ($totalsize / 1tb)
$totalfreeTB = "{0:N2}" -f ($totalfree / 1tb)
$totalusedTB = "{0:N2}" -f ($totalused / 1tb)

$totalCount = "Total count:        $totalsizeTB TB  $totalfreeTB TB       $totalusedTB TB"
Write-Host $totalCount -ForegroundColor Green
write `n`r 



$typeHash = @{

    2 = "Removable disk"
 
    3 = "Fixed local disk"
 
    4 = "Network disk"
 
    5 = "Compact disk"
}