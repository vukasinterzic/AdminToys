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
https://github.com/vukasinterzic/AdminToys

#>

Write-Verbose -Message "Script must run in console as Administrator, otherwise it will not connect to the DPM server."
#Requires -RunAsAdministrator


function Get-DPMProtectedVMs {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$DPMServer = $env:computername
    )
    
    begin {
        Write-Verbose "Function Get-DPMProtectedVMs start..."

        Write-Verbose "Connecting to DPM server ..."

        Connect-DPMServer -DPMServerName $DPMServer

        if ($?) {
            Write-Verbose "Successfuly connected to DPM server."
        }

    }
    
    process {
        
        $ProtectionGroups = Get-DPMProtectionGroup

        $DPMData = @()

        foreach ($ProtectionGroup in $ProtectionGroups) {

            $DPMData += Get-DPMDatasource -ProtectionGroup $ProtectionGroup | Select-Object ProtectionGroupName, Computer, VmName, CurrentProtectionState, FirstAddedTime, LatestRecoveryPoint

        }        

    } # end of Process
    
    end {
        
        if ($DPMData) {

            Write-Verbose -Message "Collected information:"
            $DPMData
        }


        Write-Verbose -Message "Disconnecting from DPM Server $DPMServer ..."

        Disconnect-DPMServer -DPMServerName $DPMServer

    }
}


#TODO Add disk size, add location of backup, protection type/method
#TODO Add option to specify ProtectionGroup
#FIXME Remote to DPM server - eliminate requiremenets for Module. Allows usage of credentials.
#FIXME Remoting with elevated access
