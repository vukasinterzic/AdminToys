<#
.SYNOPSIS

Collect basic information about specified servers or all servers found in Active Directory. Collected information is useful for having basic overview of where they are, what systems are they running and what are they used for.

.DESCRIPTION

This script is collecting basic information about specified servers or all servers that are found in Active Directory Domain. Script collects following info: Name, IP, OS, HW mode, VM host, Site, Description. Script can collect information from AD and export it to CSV. Or it import information from previousely exported file. This is usefull in case you want to work with the result (filtering, searching etc).
Script will require credentials.
To see full information use -Verbose parameter.

.PARAMETER Servers
ParameterSet: ExportInfo
List of servers to scan. If parameter is not specified, script will collect all servers from AD.

.PARAMETER Domain
ParameterSet: ExportInfo
Specify AD domain. If parameter is not specified, domain of user will be used. This will not work if you are on non-domain joined PC.

.PARAMETER ExportPath
ParameterSet: ExportInfo
This parameter specify where export CSV file will be saved.
If its not specified, no export will be saved.
It can be path including file name OR it can be only path without specifying file name. In that case file name will be generated in format ADServerInfo-Export-$timeStamp.csv

.PARAMETER ImportPath
ParameterSet: ImportInfo
Specify path to file that should be imported.

.PARAMETER ImportLastFile
ParameterSet: ImportInfo
This is a Switch parameter. If it is used, script will import newest CSV file from folder specified in ImportPath parameter.

.INPUTS

.OUTPUTS

.EXAMPLE
Get-ADServerInfo -Servers $ServerList -Domain $domain -ExportPath $path

.EXAMPLE
Get-ADServerInfo -ImportPath $path -ImportLastFile

.LINK
https://github.com/vukasinterzic/AdminToolBox

#>

function Get-ADServerInfo {
    [CmdletBinding(DefaultParameterSetName = "ExportInfo")]
    param
    (
        [Parameter(Mandatory = $false,
            ParameterSetName = 'ExportInfo',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Enter Server names:')]
        [array]$Servers,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'ExportInfo',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Enter Server names:')]
        [string]$Domain,

        [Parameter(Mandatory = $false,      
            ParameterSetName = 'ExportInfo',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath,
        
        [Parameter(Mandatory = $true,
            ParameterSetName = 'ImportInfo',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ImportPath,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'ImportInfo',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$ImportLastFile
    )

    
    Write-Verbose "Start of function Get-ADServerInfo."

    if (!$ImportPath) {
        Write-Verbose "Parameter Set ExportPath is used."
        Write-Verbose "Getting user credentials..."
        $credentials = Get-Credential
        $global:onlineServers = @()
        $global:offlineServers = @()
        
        if (!$Domain) {
            Write-Verbose "Domain name not specified. Using domain of localhost computer."
            $Domain = $ENV:USERDOMAIN
        }

        #list of servers, excluding Cluster CNO
        if (!$Servers) {
            Write-Verbose -ForegroundColor Cyan "Server list not specified. Getting all servers in AD domain..."
            $Servers = Get-ADComputer -Server $Domain -Credential $credentials -filter {(OperatingSystem -like "*Server*") -and ((Description -notlike "*") -or (Description -notlike "*Failover cluster virtual network name account*"))} -Properties Name | Select-Object -ExpandProperty Name
        }

        $i = 0

        foreach ($Server in $Servers) {

            $i++
            Write-Host -ForegroundColor DarkGray "Proceeding with server $($Server) - $i/$($Servers.Count)"

            $Server = Get-ADComputer -Server $Domain -Identity $Server -Credential $credentials -Properties Name, DNSHostName, IPv4Address, OperatingSystem, Description | Select-Object Name, DNSHostName, IPv4Address, OperatingSystem, Description

            if (Test-Connection $Server.DNSHostName -Quiet -Count 1) {

                Write-Verbose "Getting NetBIOS name of server..."
                $netBIOSName = (Get-ADDOmain -Server $Domain -Credential $credentials).NetBIOSName

                Write-Verbose "Getting server site..."
                $ServerSite = Get-WmiObject -Class Win32_ntdomain -ComputerName $Server.DNSHostName -Credential $credentials | Where-Object DomainName -Like $netBIOSName | Select-Object -ExpandProperty ClientSiteName
                
                Write-Verbose "Getting server model..."
                $ServerModel = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Server.DNSHostName -Credential $credentials | Select-Object -ExpandProperty Model
                

                if ($ServerModel -like "*Virtual*") {
                    
                    Write-Verbose "Server is Virtual Machine. Getting the name of physical host..."
                    $HKLMdef = "2147483650"
                    $KeyName = "SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters"            
                    $ValueName = "PhysicalHostName"

                    $wmi = Get-Wmiobject -list "StdRegProv" -namespace root\default -Computername $Server.DNSHostName -Credential $credentials
                    $VMHost = $wmi.GetStringValue($HKLMdef, $KeyName, $ValueName).svalue

                }
                else {
                    Write-Verbose "Server is not Virtual Machine. There is no physical host."
                    $VMHost = $null
                }


                #Get CPU, Memory, HDD, Network adapters, DNS Settings, C drive, shares, 


                #Create custom object with all collected properties
                $obj = New-Object psobject
                $obj | Add-Member -MemberType NoteProperty -Name Name -Value $Server.Name
                $obj | Add-Member -MemberType NoteProperty -Name IP -Value $Server.IPv4Address
                $obj | Add-Member -MemberType NoteProperty -Name OS -Value $Server.OperatingSystem
                $obj | Add-Member -MemberType NoteProperty -Name Model -Value $ServerModel
                $obj | Add-Member -MemberType NoteProperty -Name Host -Value $VMHost
                $obj | Add-Member -MemberType NoteProperty -Name Site -Value $ServerSite
                $obj | Add-Member -MemberType NoteProperty -Name Description -Value $Server.Description

                Write-Verbose "Server $($Server.Name) is online and collected information was added to list of online servers."
                $global:onlineServers += $obj

            }
            else {
                Write-Verbose "Server $($Server.Name) is offline and it was added to the list of offline servers."
                $global:offlineServers += $Server.Name
            
            }

        }

        #Display Results

        Write-Verbose "Collected information about accessible servers:"
        Write-Host -ForegroundColor Cyan "Online servers information:"
        $onlineServers | Format-Table -AutoSize


        if ($offlineServers.Count -gt 0) {
            Write-Host "Number of inaccessible servers is >0."
            Write-Host -ForegroundColor Magenta "Offline servers list:"    
            $offlineServers

        }

        # Export results to CSV if $ExportPath is specified
        if ($ExportPath) {
            $timeStamp = Get-Date -f yyyy-MM-dd_HH-mm

            Write-Verbose "ExportPath is selected. Results will be exported to CSV file."
            Write-Verbose "Testing if provided path is file or directory..."

            if ((Get-Item $ExportPath -ErrorAction SilentlyContinue) -isnot [System.IO.DirectoryInfo]) {

                Write-Verbose "Provided path is file."

                $fileName = $ExportPath

            }
            else {

                Write-Verbose "Provided path is directory. New file will be created."
               
                #Test if provided path contains \ in the end.
                if ($ExportPath -notmatch '.+?\\$') {

                    $fileName = $ExportPath + "\" + "ADServerInfo-Export-$timeStamp.csv"

                }
                else {
                    $fileName = $ExportPath + "ADServerInfo-Export-$timeStamp.csv"
                }
                
            }

            Write-Verbose "Exporting results to CSV file..."
            $onlineServers | Export-Csv -Path $fileName -Delimiter ";" -NoTypeInformation -Append #Append because file might already exist

        }

    }
    else {
        # End of information collection. Start of Information import.
        
        If ($ImportLastFile) {
            Write-Verbose "Parameter ImportLastFile was selected. Finding the last file in specified path."
            $fileName = (Get-ChildItem -Path $ImportPath | Where-Object Name -like "*.csv" | Sort-Object LastAccessTime -Descending | Select-Object -First 1).FullName
        
        }
        else {
            Write-Verbose "Full path to file specified. Testing if file is available..."

            if (Test-Path $ImportPath) {
                Write-Verbose "Provided file is accessible. Checking if file is CSV."

                $extn = [IO.Path]::GetExtension($ImportPath)

                if ($extn -eq ".csv") {
                    Write-Verbose "File is accessible and CSV. Importing..."
                    $fileName = $ImportPath

                }
                else {
                    Write-Host -ForegroundColor Magenta "Provided file is not CSV file. Can't import."
                }
                
            }
            else {
                Write-Host -ForegroundColor Magenta "Provided file is not accessible. Can't import."
            }
            
        }


        if ($fileName) {

            # Import CSV file
            Write-Verbose "Importing CSV file to object `$ServerInfo..."
            $global:ServerInfo = Import-Csv -Path $fileName -Delimiter ";"

            # Display imported info
            Write-Verbose "Show import server info."
            Write-Host -ForegroundColor Cyan "Data imported to object `$ServerInfo"
            $ServerInfo | Format-Table -AutoSize

        }

    } # End of Import

    Write-Verbose "End of Function Get-ADServerInfo"
} # End of Get-ADServerInfo
