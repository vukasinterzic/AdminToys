<#
.SYNOPSIS

This function help you find and export disk space information from local or remote computer. 

.DESCRIPTION

This function help you find and export disk space information from local or remote computer. Size is automatically converted to MB,GB or TB.

.PARAMETER Computer

Specifies the name computer or computers.

.PARAMETER SizeIn

Specify in which unit will disk size be displayed. It can be in MB, GB or TB. Default size is in GB

.PARAMETER ExportPath

Specify export file path, including file name.

.INPUTS

None; Computer(s) name(s); SizeIn; ExportPath

.OUTPUTS

Size, FreeSpace, UsedSpace, Totals

.EXAMPLE

C:\PS> Get-DiskSpace

.EXAMPLE

C:\PS> Get-DiskSpace -Computers COMPUTERNAME1 -SizeIn TB -ExportPath C:\export.csv

.EXAMPLE

C:\PS> computerlist.txt | Get-DiskSpace

.LINK

http://www.vukasinterzic.com

#>


function Get-DiskSpace {
    [CmdletBinding()]

    param 
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$Computers = "localhost",
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("MB", "GB", "TB")]
        [string]$SizeIn = "",
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath = ""
    
    )

    begin {
        Write-Verbose "Function begin. Finding disk space."
    }

    process {

        
        # hashtable for conversion of Disk Types
        $typeHash = @{

            2 = "Removable disk"
            3 = "Fixed local disk"
            4 = "Network disk"
            5 = "Compact disk"

        }

        $sizeDivide = "1" + $SizeIn

        # Computer loop
        foreach ($Computer in $Computers) {

            Try {
                $allDisks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $Computer -ErrorAction Stop |
                    Select-Object @{n = "ComputerName"; e = {$_.PSCOmputerName}},
                @{n = "Type"; e = {$typeHash.item([int]$_.DriveType)}},
                ProviderName, DeviceID, VolumeName,
                @{n = "Size($SizeIn)"; e = {"{0:N2}" -f ($_.Size / $sizeDivide)}},
                @{n = "FreeSpace($SizeIn)"; e = {"{0:N2}" -f ($_.FreeSpace / $sizeDivide)}},
                @{n = "UsedSpace($SizeIn)"; e = {"{0:N2}" -f (($_.Size - $_.FreeSpace) / $sizeDivide)}}

                #show results:    
                Write-Host -ForegroundColor Yellow "Disks information for computer " -NoNewline
                Write-Host -ForegroundColor Green  "$Computer" -NoNewline
                Write-Host -ForegroundColor Yellow ":"
    
                $allDisks | Format-Table -AutoSize

                if ($ExportPath) {
                    $allDisks | Export-Csv -Path $ExportPath -Delimiter ";" -NoTypeInformation -Append
                }
    
            }
            
            Catch {

                Write-Host -ForegroundColor Yellow "There was an error while connecting to " -NoNewline
                Write-Host -ForegroundColor Red  "$Computer" -NoNewline
                Write-Host -ForegroundColor Yellow ". Error message is bellow:"
                Write-Host ""
                Write-Host -ForegroundColor Red $($_.Exception.message)
                Write-Host ""
            } 

        } #end of Computers loop


    } #end of Process


} #end of Get-DiskSpace

<#
To Do:

Add error detection and verbose
Add SUM for each individual server

#>