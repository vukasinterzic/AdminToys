<#
.SYNOPSIS
Find VMs that are protected by Data Protection Manager.

.DESCRIPTION
Requirements:
Data Protection Manager PowerShell
Hyper-V PowerShell

This function help you find and export list of VMs that are backed up by Data Protection Manager, including backup schedule, storage information and protection groups.

.PARAMETER DPMServerName
Specifies the name of DPM Server. If not specified, it will try to run on local host.

.PARAMETER UseCredentials
Switch parameter. If used, you will be asked to provide credentials that are used to access computers.

.PARAMETER ExportPath
Specify export file path, including file name.

.INPUTS
None; DPM Server Name

.OUTPUTS

.EXAMPLE
C:\PS> Get-DPMProtectedVMs -DPMServerName DPM

.EXAMPLE
C:\PS> Get-DPMProtectedVMs

.LINK
https://github.com/vukasinterzic/AdminToolBox

#>

#TODO Delete DiskSpace function
<# DiskSpace -- to be deleted
function Get-DiskSpace {
    [CmdletBinding()]

    param 
    (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$ComputerName = $env:computername,
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Bytes", "KB", "MB", "GB", "TB")]
        [string]$SizeIn = "Bytes",

        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$UseCredentials,
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath
    
    )

    begin {
        Write-Verbose "Function Get-DiskSpace start. Finding disk space."
        
        Write-Verbose "Defining hashtable for disk types..."
        $typeHash = @{

            2 = "Removable disk"
            3 = "Fixed local disk"
            4 = "Network disk"
            5 = "Compact disk"

        }

        if ($sizeIn -eq "Bytes") { 
            $sizeDivide = "1"
        }
        else { 
            $sizeDivide = "1$sizeIn"
        }
        
        if (($UseCredentials) -and (!$Credential)) {
            Write-Verbose "Parameter UseCredentials is used. Getting user credentials..."
            Write-Host -ForegroundColor Cyan "Enter your credentials:"
            [securestring]$Credential = Get-Credential
        }
        
    }

    process {

        $ComputerDisks = @()

        # Computers loop start
        foreach ($Computer in $ComputerName) {

            Try {

                Write-Verbose "Collecting disk information on $Computer..."

                if ($UseCredentials) { 
                    #creating cmdlet with parameter -Credentials. Variables have escape character (`) so their content is not added to $arg string.
                    $arg = "Get-WmiObject -Class Win32_LogicalDisk -ComputerName `$Computer -Credential `$Credential -ErrorAction Stop"

                }
                else {
                    #cmdlet without -Credentials parameter. Useful for localhost or computers where current user has access.
                    $arg = "Get-WmiObject -Class Win32_LogicalDisk -ComputerName `$Computer -ErrorAction Stop"

                }

                $allDisks = Invoke-Expression $arg 
                
                $ComputerDisks += $allDisks |
                    Select-Object @{n = "ComputerName"; e = {$_.PSCOmputerName}},
                @{n = "Type"; e = {$typeHash.item([int]$_.DriveType)}},
                @{n = "NetworkPath"; e = {$_.ProviderName}},
                DeviceID, VolumeName,
                @{n = "Size($SizeIn)"; e = {"{0:N2}" -f ($_.Size / $sizeDivide)}},
                @{n = "FreeSpace($SizeIn)"; e = {"{0:N2}" -f ($_.FreeSpace / $sizeDivide)}},
                @{n = "FreeSpace(%)"; e = {"{0:N0}" -f (($_.FreeSpace / $_.Size) * 100)}},
                @{n = "UsedSpace($SizeIn)"; e = {"{0:N2}" -f (($_.Size - $_.FreeSpace) / $sizeDivide)}}
    
    
            }
            
            Catch {
                Write-Verbose "Error was detected."
                Write-Host -ForegroundColor Yellow "There was an error while connecting to " -NoNewline
                Write-Host -ForegroundColor Red  "$Computer" -NoNewline
                Write-Host -ForegroundColor Yellow ". Error message is bellow:"
                Write-Host ""
                Write-Host -ForegroundColor Red $($_.Exception.message)
                Write-Host ""
            
            } 

        } #end of Computers loop

    } #end of Process

    end {

        if ($ComputerDisks.Count -gt 0) {

            if ($ExportPath) {
                Write-Verbose "Parameter ExportPath specified, exporting data to CSV file..."
                $ComputerDisks | Export-Csv -Path $ExportPath -Delimiter ";" -NoTypeInformation
            }

            Write-Verbose -Message "Disk information:"

            $ComputerDisks

        }


        Write-Verbose "End of Get-DiskSpace function."
    }


} #end of Get-DiskSpace

#>


function Get-DPMProtectedVMs {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}