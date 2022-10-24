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
        [Parameter(Mandatory = $false,
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
    #TODO Add switch parameter to export to CSV file
    #TODO Add switch parameter -AllVms to get info about all VMs in Subscription


    #Connecting to Azure (this is temporary):

    #Connect-AzAccount





    if (!$SubscriptionName) {

        Write-Verbose -Message "SubscriptionName not specified. Searching for VM in all Subscriptions..."

        $Subscriptions = Get-AzSubscription | Where-Object Name -notlike 'Access to Azure Active Directory'

    } else {

        $Subscriptions = Get-AzSubscription -SubscriptionName $SubscriptionName

    }

    <#
    Write-Verbose -Message "Getting the list of Backup Vaults..."
    $BackupVaults = Get-AzRecoveryServicesVault
    #>


    foreach ($Subscription in $Subscriptions) {
    
        Write-Verbose -Message "Selecting Subscription $($Subscription.Name)... "

        Get-AzSubscription -SubscriptionName $Subscription.Name | Set-AZContext

        if (!$VMName) {
            
            $VMs = Get-AzVM

        } else {
            $VMs = Get-AzVM -Name $VMName
        }
        
        foreach ($VM in $VMs) {

            Write-Verbose -Message "VM Found in Subscription $($Subscription.Name)!"
            Write-Verbose -Message "Getting VM and Subscription info..."
            $VMinfo = Get-AZVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
            $SubscriptionInfo = Get-AzSubscription -SubscriptionName $Subscription.Name

            <#
            $VMDataDiskSize = $VMinfo.StorageProfile.DataDisks.DiskSizeGB
            $VMDataDiskType = $VMinfo.StorageProfile.DataDisks.ManagedDisk.StorageAccountType
            $VMNetworkInterface = $VMinfo.NetworkProfile.NetworkInterfaces[0].Id
            $VMNetworkInterfaceName = $VMinfo.NetworkProfile.NetworkInterfaces[0].Id.Split('/')[-1]
            #>

            $NetworkProfile = $VMInfo.NetworkProfile.NetworkInterfaces.Id.Split("/") | Select-Object -Last 1

            $VMIPConfig = Get-AzNetworkInterface -Name $NetworkProfile | Select-Object -ExpandProperty IpConfigurations

            if ($VMIPConfig.PublicIpAddress) {
                $VMPublicIP = (Get-AzPublicIpAddress -Name $($VMIPConfig.PublicIpAddress.Id.Split("/") | Select-Object -Last 1)).IpAddress
            } else {
                $VMPublicIP = "None"
            }

            if ($VMinfo.LicenseType) {
                $VMLicenseType = "$($VMinfo.LicenseType) (Azure Hybrid Use Benefit)"
            } else {
                $VMLicenseType = "Azure License"
            }


            $recoveryVaultInfo = Get-AzRecoveryServicesBackupStatus -Name $VMinfo.Name -ResourceGroupName $VMinfo.ResourceGroupName -Type 'AzureVM'

            if ($recoveryVaultInfo.BackedUp -eq $true) {
                $VMBackupStatus = "Enabled"
            } else {
                $VMBackupStatus = "Disabled"
            }

            
            Write-Verbose -Message "Breaking the ForeEach loop..."
            break

        } else {
        
            Write-Verbose -Message "VM with name $VMName not found in subscription $($Subscription.Name)"
        
        }
        
    }

    

    #Get AZ Agent info

    #get Azure Update management configuration

    


    $global:FullVMInfo = @()

    #Create custom object with all collected properties
    $obj = New-Object psobject
    $obj | Add-Member -MemberType NoteProperty -Name Subscription -Value $SubscriptionInfo.Name
    $obj | Add-Member -MemberType NoteProperty -Name Location -Value $VMInfo.Location
    $obj | Add-Member -MemberType NoteProperty -Name AzureName -Value $VMInfo.Name
    $obj | Add-Member -MemberType NoteProperty -Name WindowsName -Value $VMinfo.OsProfile.ComputerName
    $obj | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $VMInfo.ResourceGroupName
    $obj | Add-Member -MemberType NoteProperty -Name Description -Value $VMinfo.Tags.Description
    $obj | Add-Member -MemberType NoteProperty -Name Environment -Value $VMinfo.Tags.Environment
    $obj | Add-Member -MemberType NoteProperty -Name SLA -Value $VMinfo.Tags.SLA
    $obj | Add-Member -MemberType NoteProperty -Name Contact -Value $VMinfo.Tags.'Business-Contact'
    $obj | Add-Member -MemberType NoteProperty -Name OS -Value "$($VMinfo.StorageProfile.ImageReference.Offer) $($VMinfo.StorageProfile.ImageReference.Sku)"
    $obj | Add-Member -MemberType NoteProperty -Name License -Value $VMLicenseType
    $obj | Add-Member -MemberType NoteProperty -Name Size -Value $VMinfo.HardwareProfile.VmSize
    $obj | Add-Member -MemberType NoteProperty -Name OSDiskSize -Value $VMinfo.StorageProfile.OsDisk.DiskSizeGB
    $obj | Add-Member -MemberType NoteProperty -Name OSDiskType -Value $VMinfo.StorageProfile.OsDisk.ManagedDisk.StorageAccountType
    $obj | Add-Member -MemberType NoteProperty -Name NumberOfDataDisks -Value $VMinfo.StorageProfile.DataDisks.Count
    $obj | Add-Member -MemberType NoteProperty -Name PrivateIP -Value $VMIPConfig.PrivateIpAddress
    $obj | Add-Member -MemberType NoteProperty -Name vNET -Value $VMIPConfig.Subnet.Id.Split("/")[8]
    $obj | Add-Member -MemberType NoteProperty -Name Subnet -Value $VMIPConfig.Subnet.Id.Split("/") | Select-Object -Last 1
    $obj | Add-Member -MemberType NoteProperty -Name IPAllocation -Value $VMIPConfig.PrivateIpAllocationMethod
    $obj | Add-Member -MemberType NoteProperty -Name PublicIP -Value $VMPublicIP
    $obj | Add-Member -MemberType NoteProperty -Name AzureBackup -Value $VMBackupStatus

    $global:FullVMInfo += $obj

}