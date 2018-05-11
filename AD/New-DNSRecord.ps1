<#
.SYNOPSIS

Create new DNS record in AD integrated DNS server. 

.DESCRIPTION

Create new A DNS record in AD integrated DNS server using dnscmd tool.

.PARAMETER DNSRecordName

Specifies the name for DNS Record. Parameter is mandatory.

.PARAMETER DNSRecordIP

Specifies the IP address for the DNS record. Parameter is mandatory.

.PARAMETER DNSZoneName

Name of DNS zone where record will be created. Parameter is mandatory.

.PARAMETER DNSServerIP

IP address of DNS server where record will be created. Parameter is mandatory.

.PARAMETER logName

FullPath to log file name. Parameter is mandatory.

.PARAMETER DNSNamePrefix

In case all DNSnames need to have same prefix.

.PARAMETER recordType

Specifies record type. This script can create only A records therefore default value is provided.

.LINK

https://github.com/vukasinterzic/AdminToolBox

#>
function New-DNSRecord {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'What is the DNS record name?')]
        [string]$DNSRecordName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$DNSRecordIP,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$DNSZoneName,
    
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$DNSServerIP,

        [Parameter(Mandatory = $true)]
        [string]$logName,

        [string]$DNSNamePrefix,
        [string]$recordType = "A"
    )


    begin {
        Write-Verbose "Creating new $RecordType DNS record."
    }

    process {

        #switch according to the record type:
        switch ($recordType) {


            "A" {
                #creation of A record
            
                $recordFQDN = $DNSNamePrefix + $DNSRecordName + "." + $DNSZoneName
                $recordName = $DNSNamePrefix + $DNSRecordName
            
                <#if (!$DNSServer) {
                    $DNSServer = Get-DnsClientServerAddress | select -ExpandProperty ServerAddresses -Unique -First 1 | select -First 1
                }#>

                #perform check if DNS record already exists
                $dnschk = $NULL
                $dnsexist = $NULL
                $ErrorActionPreference = "silentlycontinue"
                $dnschk = [System.Net.DNS]::GetHostAddresses("$recordFQDN")
                $dnsip = $dnschk.IPAddressToString 
                if ($dnsip -ne $NULL) {
        
                    if ($dnsip -eq $DNSRecordIP) {
                        #if record exist, check if it is correct
    
                        Write-Output "A Record for $recordName already exists and it is correct, skipping..." | Out-File $logName -Append

                    }
                    else {
            
                        Write-Output "A Record for $recordName already exists but it is not correct, logging for later..." | Out-File $logName -Append
                        $wrongDNSRecord += "$recordName;$DNSRecordIP;$dnsip"

                    }

                }
                else {
                    
                    $dnsexist = "false"
                    Write-Output "Creating record: $recordName with IP: $DNSRecordIP" | Out-File $logName -Append
                    dnscmd $DNSServerIP /RecordADD $DNSZoneName $recordName /createPTR $recordType $DNSRecordIP
                
                }

                if ($wrongDNSRecord) { Write-Output "Wrong records: $wrongDNSRecord" | Out-File $logName -Append }



            } #end of A record

            #### Add different types of records here

        } #end of switch

    } #end of process


} #end of New-DNSRecord function

<#

$DNSServerIP = ""
$DNSZoneName = ""
$DNSNamePrefix = ""

$timestamp = Get-Date -Format yyMMdd-HHmmss
$logName = "W:\New-DNSRecord_$timestamp.txt"


$records = Import-Csv -Delimiter ";" -Path "W:\dns.csv"

foreach ($record in $records) {
    New-DNSRecord -DNSRecordName $record.DNSRecordName -DNSRecordIP $record.DNSRecordIP -DNSZoneName $DNSZoneName -DNSServerIP $DNSServerIP -DNSNamePrefix $DNSNamePrefix -logName $logName
}

#>


<#
To Do:

Creation of other record types
Make Log not to be mandatory
Make CSV preparation function, that will pre-create input file. User can then add information in Excel and run creation in bulk

#>