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

.PARAMETER UseCredentials
Switch parameter. If used, you will be asked to provide credentials that are used to access computers.

.PARAMETER ExportPath
ParameterSet: ExportInfo
This parameter specify where export CSV file will be saved.
If its not specified, no export will be saved.
It can be path including file name OR it can be only path without specifying file name. In that case file name will be generated in format ADServerInfo-Export-$timeStamp.csv

.PARAMETER SingleVMWareServer
ParameterSet: ExportInfo
This is a Switch parameter. If it is used, script will only ask for single ESXi host or vCenter server connection. In case VM is not found on specified server, collecting information for that script will be skipped.


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
Get-ADServerInfo -ExportPath C:\export.csv

.EXAMPLE
Get-ADServerInfo -ImportPath $path -ImportLastFile

.LINK
https://github.com/vukasinterzic/AdminToys

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
            HelpMessage = 'Enter Domain name:')]
        [string]$Domain,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'ExportInfo',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$UseCredentials,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'ExportInfo',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$SingleVMWareServer,

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

    #FIXME Make advanced function instead of simple function
    
    Write-Verbose -Message "Start of function Get-ADServerInfo $(Get-Date -Format g)."

    if (!$ImportPath) {
        Write-Verbose -Message "Parameter Set ExportPath is used."
        
        if (($UseCredentials) -and (!$Credential)) {
            Write-Verbose -Message "Parameter UseCredentials is used. Getting user credentials..."
            Write-Host -ForegroundColor Cyan "Enter your credentials:"
            $Credential = Get-Credential
        }
        
        $global:onlineServers = @()
        $global:offlineServers = @()
        
        if (!$Domain) {
            Write-Verbose -Message "Domain name not specified. Using domain of localhost computer."
            $Domain = $ENV:USERDOMAIN
        }

        #list of servers, excluding Cluster CNO
        if (!$Servers) {
            Write-Host -ForegroundColor Cyan "Server list not specified. Getting all servers in AD domain..."
            $Servers = Get-ADComputer -Server $Domain -Credential $Credential -filter {(OperatingSystem -like "*Server*") -and ((Description -notlike "*") -or (Description -notlike "*Failover cluster virtual network name account*"))} -Properties Name | Select-Object -ExpandProperty Name
        }

        $i = 0

        foreach ($Server in $Servers) {

            $i++
            Write-Host -ForegroundColor DarkGray "Proceeding with server $($Server) - $i/$($Servers.Count)"

            if (Test-Connection $Server -Quiet -Count 1) {

                $Server = Get-ADComputer -Server $Domain -Identity $Server -Credential $Credential -Properties Name, DNSHostName, IPv4Address, OperatingSystem, Description | Select-Object Name, DNSHostName, IPv4Address, OperatingSystem, Description

                Write-Verbose -Message "Getting NetBIOS name of server..."
                $netBIOSName = (Get-ADDOmain -Server $Domain -Credential $Credential).NetBIOSName

                Write-Verbose -Message "Getting server site..."
                $ServerSite = Get-WmiObject -Class Win32_ntdomain -ComputerName $Server.DNSHostName -Credential $Credential | Where-Object DomainName -Like $netBIOSName | Select-Object -ExpandProperty ClientSiteName
                
                Write-Verbose -Message "Getting server model..."
                $ServerModel = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Server.DNSHostName -Credential $Credential | Select-Object -ExpandProperty Model
                
                switch ($ServerModel) {

                    'Virtual Machine' {
                        Write-Verbose -Message "Server is a Hyper-V Virtual Machine. Getting the name of physical host..."
                        $HKLMdef = "2147483650"
                        $KeyName = "SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters"            
                        $ValueName = "PhysicalHostName"

                        $wmi = Get-Wmiobject -list "StdRegProv" -namespace root\default -Computername $Server.DNSHostName -Credential $Credential
                        $VMHost = $wmi.GetStringValue($HKLMdef, $KeyName, $ValueName).svalue

                        if (!$VMHost) {
                            $VMHost = "Unknown Hyper-V Host"
                        }
                    }

                    'VMWare Virtual Platform' {

                        Write-Verbose -Message "Server is a VMWare Virtual Machine."

                        $VMWareFinished = $false
                        $VMHost = $null
                        if (!$VMWareAction) { $VMWareAction = "CheckTools"}
                        
                        do {

                            switch ($VMWareAction) {

                                'CheckTools' {

                                    Write-Verbose -Message "Checking if VMWare CLI tools are installed ..."
                                    If (Get-Command "Get-VIToolkitVersion" -ErrorAction SilentlyContinue) {

                                        Write-Verbose -Message "VMware CLI tools are installed on local server."
                                        $VMWareAction = "Connect"
                                        $VMWareFinished = $false
                                    }
                                    else {
                                        Write-Verbose -Message "VMWare CLI tools are not installed on local server or correct module is not loaded. Host info will not be collected."
                                        $VMHost = "Unknown VMWare Host"
                                        $VMWareFinished = $true
                                    }

                                }

                                'Connect' {
                                    
                                    Write-Verbose -Message "Ready to connect to server."
                                    $VMWareServer = Read-Host -Prompt "Enter FQDN of the ESXi host or the vCenter server"
                                    $VMWareCredentials = Get-Credential -Message "Enter Credentials for accessing server $VMWareServer :"

                                    Write-Verbose -Message "Connecting to server $VMWareServer..."
                                    Connect-VIServer -Server $VMWareServer -Credential $VMWareCredentials
                                    if ($?) {
                                        Write-Verbose -Message "VMWare host $VMWareServer connected."
                                        $VMWareAction = "GetVM"
                                        $VMWareFinished = $false
                                    }
                                    else {
                                        Write-Verbose -Message "Connection unsuccessful."
                                        $Answer1 = Read-Host -Prompt "Would you like to try to enter server or credentials? (Y/N)"

                                        if ($Answer1 = "Y") {
                                            $VMWareAction = "Connect"
                                            $VMWareFinished = $false
                                        }
                                        else {
                                            Write-Verbose -Message "Host info will not be collected."
                                            $VMHost = "Unknown VMWare Host"
                                            $VMWareFinished = $true
                                        }
                                    }

                                }

                                'GetVM' {
                                    Write-Verbose -Message "Getting host info about VM $($Server.Name)...."
                                    $VMHost = Get-VM -Name $($Server.Name) -ErrorAction SilentlyContinue | Select-Object VMHost

                                    if ($?) {
                                        $VMHost = $VMHost.VMHost.Name | Select-Object -First 1

                                        $VMWareAction = "GetVM"
                                        $VMWareFinished = $true
                                    }
                                    else {
                                        Write-Verbose -Message "VM $($Server.Name) was not found on the host $VMWareServer."

                                        if (!$SingleVMWareServer) {
                                            $Answer2 = Read-Host -Prompt "Would you like to connect to different VMWare server? (Y/N)"
                                            
                                            if ($Answer2 -eq "Y") {
                                                $VMWareAction = "Connect"
                                                $VMWareFinished = $false
                                            }
                                            else {
                                                Write-Verbose -Message "Host info will not be collected."
                                                $VMHost = "Unknown VMWare Host"
                                                $VMWareFinished = $true
                                            }
                                        }
                                        else {
                                            Write-Verbose -Message "Parameter -SingleVMWareServer was used. Host info will not be collected."
                                            $VMHost = "Unknown VMWare Host"
                                            $VMWareFinished = $true
                                        }
                                        
                                    }

                                }
                            }

                        } while (!$VMWareFinished)
                    
                    }

                
                    'VirtualBox' {
                        Write-Verbose -Message "Server is running in VirtualBox. Still need to figure out how to find the name of the host computer :-)"
                        $VMHost = "Unknown VirtualBox Host"
                    }

                    Default {
                        Write-Verbose -Message "Server is not a Virtual Machine."
                        $VMHost = $null
                    }
                    
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

                Write-Verbose -Message "Server $($Server.Name) is online and collected information was added to list of online servers."
                $global:onlineServers += $obj

            }
            else {
                Write-Verbose -Message "Server $Server is offline or it does no exist. Server name was added to the list of unavailable servers."
                $global:offlineServers += $Server
            
            }

            Write-Verbose -Message "Processing of server $i/$($Servers.Count) completed at $(Get-Date -Format g)."
        }

        #Display Results

        Write-Verbose -Message "Collected information about accessible servers:"
        Write-Host -ForegroundColor Cyan "Online servers information:"
        $onlineServers | Format-Table -AutoSize


        if ($offlineServers.Count -gt 0) {
            Write-Verbose -Message "Number of inaccessible servers is >0."
            Write-Host -ForegroundColor Magenta "Offline servers list:"    
            $offlineServers

        }

        # Export results to CSV if $ExportPath is specified
        if ($ExportPath) {
            $timeStamp = Get-Date -f yyyy-MM-dd_HH-mm

            Write-Verbose -Message "ExportPath is selected. Results will be exported to CSV file."
            Write-Verbose -Message "Testing if provided path is file or directory..."

            if ((Get-Item $ExportPath -ErrorAction SilentlyContinue) -isnot [System.IO.DirectoryInfo]) {

                Write-Verbose -Message "Provided path is file."

                Write-Verbose -Message "Adding TimeStamp to file name..."
                $fileNameSplit = $ExportPath.Split(".")
                $fileName = $fileNameSplit[0] + "-" + $timeStamp + "." + $fileNameSplit[1]
                $fileName2 = $fileNameSplit[0] + "-OfflineServers-" + $timeStamp + ".txt"

            }
            else {

                Write-Verbose -Message "Provided path is directory. New file will be created."
               
                #Test if provided path contains \ in the end.
                if ($ExportPath -notmatch '.+?\\$') {

                    $fileName = $ExportPath + "\" + "ADServerInfo-Export-$timeStamp.csv"
                    $fileName2 = $ExportPath + "\" + "ADServerInfo-OfflineServers-$timeStamp.txt"

                }
                else {
                    $fileName = $ExportPath + "ADServerInfo-Export-$timeStamp.csv"
                    $fileName2 = $ExportPath + "ADServerInfo-OfflineServers-$timeStamp.txt"

                }
                
            }

            Write-Verbose -Message "Exporting results to CSV files..."
            $onlineServers | Export-Csv -Path $fileName -Delimiter ";" -NoTypeInformation -Append #Append because file might already exist
            
            
            if ($offlineServers.Count -gt 0) {

                Write-Verbose -Message "Number of Offline Servers is greater than 0. Exporting list of Offline Servers to separate text file..."
                $offlineServers | Out-File -FilePath $fileName2

            }
            
            
        }

    }
    else {
        # End of information collection. Start of Information import.
        
        If ($ImportLastFile) {
            Write-Verbose -Message "Parameter ImportLastFile was selected. Finding the last file in specified path."
            $fileName = (Get-ChildItem -Path $ImportPath | Where-Object Name -like "*.csv" | Sort-Object LastAccessTime -Descending | Select-Object -First 1).FullName
        
        }
        else {
            Write-Verbose -Message "Full path to file specified. Testing if file is available..."

            if (Test-Path $ImportPath) {
                Write-Verbose -Message "Provided file is accessible. Checking if file is CSV."

                $extn = [IO.Path]::GetExtension($ImportPath)

                if ($extn -eq ".csv") {
                    Write-Verbose -Message "File is accessible and CSV. Importing..."
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
            Write-Verbose -Message "Importing CSV file to object `$ServerInfo..."
            $global:ServerInfo = Import-Csv -Path $fileName -Delimiter ";"

            # Display imported info
            Write-Verbose -Message "Show import server info."
            Write-Host -ForegroundColor Cyan "Data imported to object `$ServerInfo"
            $ServerInfo | Format-Table -AutoSize
            Write-Host -ForegroundColor Cyan "Data imported to object `$ServerInfo"

        }

    } # End of Import

    Write-Verbose -Message "End of Function Get-ADServerInfo $(Get-Date -Format g)."
} # End of Get-ADServerInfo
