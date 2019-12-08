<#
.SYNOPSIS
This function help you find and export disk space information from local or remote computer. 

.DESCRIPTION
This function help you find and export disk space information from local or remote computer. Size is automatically converted to MB,GB or TB.

.PARAMETER ComputerName
Specifies the name computer or computers.

.PARAMETER SizeIn
Specify in which unit will disk size be displayed. It can be in MB, GB or TB. Default size is in GB

.PARAMETER UseCredentials
Switch parameter. If used, you will be asked to provide credentials that are used to access computers.

.PARAMETER ExportPath
Specify export file path, including file name.

.INPUTS
None; Computer(s) name(s); SizeIn; ExportPath

.OUTPUTS
Size, FreeSpace, UsedSpace, Totals

.EXAMPLE
C:\PS> Get-DiskSpace -SizeIn GB | ? DeviceId -eq "C:"

.EXAMPLE
C:\PS> Get-DiskSpace -ComputerName COMPUTERNAME1 -SizeIn TB -UseCredentials -ExportPath C:\export.csv

.EXAMPLE
C:\PS> $ComputerList | Get-DiskSpace | Format-Table -GroupBy ComputerName

.EXAMPLE
C:\PS> $ComputerList | % { Get-DiskSpace -ComputerName $_ }

.LINK
https://github.com/vukasinterzic/AdminToolBox

#>
 
#wtf?
function Get-NetAdapterInfo {

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$ComputerName = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$UseCredentials
    )     

    begin {
        Write-Verbose -Message "Running function Get-NetAdapterInfo..."

        $global:NetAdapterInfo = @()
        $NetAdapterInfoPart1 = @()
        $NetAdapterInfoPart2 = @()


        $TCPNetBIOSOptionsHash = @{
            0 = "Use NetBIOS options from DHCP"
            1 = "Enable NetBIOS over TCP/IP"
            2 = "Disable NetBIOS over TCP/IP"
        }


        if (($UseCredentials) -and (!$Credential)) {
            $Credential = Get-Credential -Message "Enter credentials"
        }
    }

    process {

        foreach ($Computer in $Computers) {

            Try {

                Write-Verbose "Collecting Network Adapter information on $Computer..."

                if ($UseCredentials) {
                    #creating cmdlet with parameter -Credentials. Variables have escape character (`) so their content is not added to $arg string.
                    $arg1 = "Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName `$Computer -Credential `$Credential -ErrorAction Stop"
                    #$cim1 = New-CimSession -ComputerName $Computer -Credential $Credential -ErrorAction Stop
                    $arg2 = "Get-NetAdapter -CimSession `$cim1"

                }
                elseif (($Computer -eq $env:COMPUTERNAME) -or ($Computer -eq ".") -or ($Computer -eq "localhost")) {
                    #cmdlet without -Credentials and without -ComputerName parameters
                    $arg1 = "Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ErrorAction Stop"
                    $arg2 = "Get-NetAdapter"
                }

                else {
                    #cmdlet without -Credentials, useful if user already has access
                    $arg1 = "Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName `$Computer -ErrorAction Stop"
                    $arg2 = "Get-NetAdapter -CimSession `$Computer"

                }

                Write-Verbose -Message "Collecting win32_NetworkAdpterConfiguration info..."
                $NetAdapterInfoPart1 = Invoke-Expression $arg1 | Where-Object IPENabled | 
                    Select-Object IPEnabled, DNSHostName, Index, IPAddress, IPSubnet, DefaultIPGateway, DNSServerSearchOrder, DNSDomainSuffixSearchOrder, FullDNSRegistrationEnabled, TCPIPNetBIOSOptions, Description, MACAddress

                Write-Verbose "Collecting Get-NetAdapter info..."
                $NetAdapterInfoPart2 = Invoke-Expression $arg2 |
                    Select-Object Name, Status, LinkSpeed, FullDuplex, IfDesc, DriverVersion, DriverInformation, DriverFileName, ConnectorPresent, DeviceWakeUpEnable, DriverDate, DriverDescription, DriverProvider, MacAddress


                foreach ($Adapter in $NetAdapterInfoPart1) {

                    $CompareMACAddress = $Adapter.MacAddress -replace ":", "-" #format MacAddress to be same format in both collections

                    $Adapter2 = $NetAdapterInfoPart2 | Where-Object MacAddress -like $CompareMACAddress # selecting network adapter whith same MAC in both collections
                    

                    Write-Verbose -Message "Creating custom object with all collected information from adapter $($Adapter.Description)..."

                    $obj = New-Object psobject
                    
                    #properties from $NetAdapterInfoPart1
                    $obj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer
                    $obj | Add-Member -MemberType NoteProperty -Name IPEnabled -Value $Adapter.IPEnabled
                    $obj | Add-Member -MemberType NoteProperty -Name DNSHostName -Value $Adapter.DNSHostName
                    $obj | Add-Member -MemberType NoteProperty -Name Index -Value $Adapter.Index
                    $obj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $Adapter.IPAddress
                    $obj | Add-Member -MemberType NoteProperty -Name IPSubnet -Value $Adapter.IPSubnet
                    $obj | Add-Member -MemberType NoteProperty -Name DefaultIPGateway -Value $Adapter.DefaultIPGateway
                    $obj | Add-Member -MemberType NoteProperty -Name DNSServerSearchOrder -Value $Adapter.DNSServerSearchOrder
                    $obj | Add-Member -MemberType NoteProperty -Name DNSDomainSuffixSearchOrder -Value $Adapter.DNSDomainSuffixSearchOrder
                    $obj | Add-Member -MemberType NoteProperty -Name FullDNSRegistrationEnabled -Value $Adapter.FullDNSRegistrationEnabled
                    $obj | Add-Member -MemberType NoteProperty -Name TCPIPNetBIOSOptions -Value $TCPNetBIOSOptionsHash[[int]$($Adapter.TCPIPNetBIOSOptions)]
                    $obj | Add-Member -MemberType NoteProperty -Name Description -Value $Adapter.Description
                    $obj | Add-Member -MemberType NoteProperty -Name MACAddress -Value $Adapter.MACAddress
                    
                    #properties from $NetAdapterInfoPart2
                    $obj | Add-Member -MemberType NoteProperty -Name Name -Value $Adapter2.Name
                    $obj | Add-Member -MemberType NoteProperty -Name Status -Value $Adapter2.Status
                    $obj | Add-Member -MemberType NoteProperty -Name LinkSpeed -Value $Adapter2.LinkSpeed
                    $obj | Add-Member -MemberType NoteProperty -Name FullDuplex -Value $Adapter2.FullDuplex
                    $obj | Add-Member -MemberType NoteProperty -Name IfDesc -Value $Adapter2.IfDesc
                    $obj | Add-Member -MemberType NoteProperty -Name DriverVersion -Value $Adapter2.DriverVersion
                    $obj | Add-Member -MemberType NoteProperty -Name DriverDate -Value $Adapter2.DriverDate
                    $obj | Add-Member -MemberType NoteProperty -Name DriverDescription -Value $Adapter2.DriverDescription
                    $obj | Add-Member -MemberType NoteProperty -Name DriverFileName -Value $Adapter2.DriverFileName
                    $obj | Add-Member -MemberType NoteProperty -Name DriverInformation -Value $Adapter2.DriverInformation
                    $obj | Add-Member -MemberType NoteProperty -Name DriverProvider -Value $Adapter2.DriverProvider
                    $obj | Add-Member -MemberType NoteProperty -Name DeviceWakeUpEnable -Value $Adapter2.DeviceWakeUpEnable
                    $obj | Add-Member -MemberType NoteProperty -Name ConnectorPresent -Value $Adapter2.ConnectorPresent

                
                    $NetAdapterInfo += $obj

                }
                
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

        } # end of Computers loop

    } # end of process

    end {

        If ($NetAdapterInfo) {
            $NetAdapterInfo
        }
    
        Write-Verbose -Message "End of function Get-NetAdapterInfo."
    

    }

}
