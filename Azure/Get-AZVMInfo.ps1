<#
.SYNOPSIS
This function help you find all necessary information about Azure VM

.DESCRIPTION
Get information about Azure VM, such as: VM size, network configuration, disk information, subscription information, resource group, tags, applied network security group rules, operating system, domain, ...

.PARAMETER VMName
Specifies VM Name

.PARAMETER Subscription
Optional parameter, to be used for cross subscription seaerch

.PARAMETER UseCredentials
Switch parameter. If used, you will be asked to provide credentials that are used to access computers.

.PARAMETER ExportPath
Specify export file path, including file name.

.INPUTS

.OUTPUTS

.EXAMPLE
C:\PS> Get-AZVMInfo -VMName AZVM1

.EXAMPLE
C:\PS> Get-AZVMInfo -VMName AZVM1 -Subscription AZSUB2

.LINK
https://github.com/vukasinterzic/AdminToys

#>

function Get-AZVMInfo {
    [CmdletBinding()]

    param 
    (
        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [string]$Subscription
    
    )


    #FIXME Add check for module
    #FIXME Add check for Azure authentication, and initiate if missing
    #FIXME After Function is completed, add it to module and description to README file.

    #Connecting to Azure (this is temporary):

    #Connect-AzAccount

    #$VMName = 'SBHG-AZMAN'

    if (!$Subscription) {

        $Subscriptions = Get-AzSubscription | Where-Object Name -notlike 'Access to Azure Active Directory'

        foreach ($Subscription in $Subscriptions) {
        
            Write-Verbose -Message 'Searching for VM in all subscriptions...'

            Write-Verbose -Message 'Selecting Subscription $($Subscription.Name)... '

            Get-AzSubscription -SubscriptionName $Subscription.Name | Set-AZContext

            if (Get-AzVM -Name $VMName) { 
                Write-Verbose -Message "VM Found in Subscription $($Subscription.Name)!"
                Write-Verbose -Message "Getting VM and Subscription info..."
                $VMinfo = Get-AZVM -Name $VMName
                $SubscriptionInfo = Get-AzSubscription -SubscriptionName $Subscription.Name
                
                Write-Verbose -Message "Breaking the ForeEach loop..."
                break
            }
            
        }

    }

}