
<#
.SYNOPSIS
This function enables Ping firewall rules on local or remote computer

.DESCRIPTION
Use this function to enable TPC IPv4 and IPv6 ping on remote or local computer

.PARAMETER ComputerName
Specifies computer name

.PARAMETER Disable
If this parameter is used, ping will be blocked

.INPUTS

.OUTPUTS

.EXAMPLE
C:\PS> Set-PingFirewallRules -ComputerName VM1

.EXAMPLE
C:\PS> Set-PingFirewallRules -Disable

.LINK
https://github.com/vukasinterzic/AdminToys

#>


function Set-PingFirewallRules {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Server,

        [Parameter(Mandatory = $false)]
        [switch]$Disable
    )

    Write-Verbose -Message "Running function Set-PingFirewallRules..."


if (!$Server) {

    $Server = localhost

}

$CIMSession = New-CimSession -ComputerName $Server

if ($Disable) {

    New-NetFirewallRule -DisplayName "Block inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Block -CimSession $CIMSession
    New-NetFirewallRule -DisplayName "Block inbound ICMPv6" -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Block -CimSession $CIMSession


} else { #Allow part starts here 

    New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow -CimSession $CIMSession
    New-NetFirewallRule -DisplayName "Allow inbound ICMPv6" -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow -CimSession $CIMSession

} #End of Allow part


} #End of Set-PingFirewallRules function



#FIXME Add elevation check.
#TODO Add option to re-open with admin rights
#TODO replace Disable with finding and removing Enable rule. It is disabled by default, explicit disabling can make a mess