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
        [string]$SubscriptionName
    
    )


    #FIXME Add check for module
    #FIXME Add check for Azure authentication, and initiate if missing
    #FIXME After Function is completed, add it to module and description to README file.

    #Connecting to Azure (this is temporary):

    #Connect-AzAccount





    if (!$SubscriptionName) {

        Write-Verbose -Message "SubscriptionName not specified. Searching for VM in all Subscriptions..."

        $Subscriptions = Get-AzSubscription | Where-Object Name -notlike 'Access to Azure Active Directory'

    } else {

        $Subscriptions = Get-AzSubscription -SubscriptionName $SubscriptionName

    }

    foreach ($Subscription in $Subscriptions) {
    
        Write-Verbose -Message "Selecting Subscription $($Subscription.Name)... "

        Get-AzSubscription -SubscriptionName $Subscription.Name | Set-AZContext

        if (Get-AzVM -Name $VMName) { 

            Write-Verbose -Message "VM Found in Subscription $($Subscription.Name)!"
            Write-Verbose -Message "Getting VM and Subscription info..."
            $VMinfo = Get-AZVM -Name $VMName
            $SubscriptionInfo = Get-AzSubscription -SubscriptionName $Subscription.Name
            
            Write-Verbose -Message "Breaking the ForeEach loop..."
            break

        } else {
        
            Write-Verbose -Message "VM with name $VMName not found in subscription $($Subscription.Name)"
        
        }
        
    }

    

    #Get Disks + info

    #Get AZ Agent info

    #Get OS, domain, azure user, ip, public ip

    #get backup info

    #get Description Tag if Exists

    #get Azure Update management configuration


    $global:FullVMInfo = @()

    #Create custom object with all collected properties
    $obj = New-Object psobject
    $obj | Add-Member -MemberType NoteProperty -Name Name -Value $VMInfo.Name
    $obj | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $VMInfo.ResourceGroupName
    $obj | Add-Member -MemberType NoteProperty -Name Location -Value $VMInfo.Location
    $obj | Add-Member -MemberType NoteProperty -Name Tags -Value $VMInfo.Tags
    $obj | Add-Member -MemberType NoteProperty -Name Subscription -Value $SubscriptionInfo.Name
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value
    $obj | Add-Member -MemberType NoteProperty -Name -Value


    Write-Verbose -Message "Server $($Server.Name) is online and collected information was added to list of online servers."
    $global:FullVMInfo += $obj




}