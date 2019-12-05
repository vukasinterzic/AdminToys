<#
.SYNOPSIS
This function finds GEO information about public IP

.DESCRIPTION
Use this function to find geographical information about public IP address.

.PARAMETER IPs
Specifies one or multiple IP addresses to check

.INPUTS
IPs

.OUTPUTS
Geo information about IP

.EXAMPLE
C:\PS> Get-GeoIPInfo -IP $IPs

.EXAMPLE
C:\PS> $IPAddressList | Get-GeoIPInfo

.EXAMPLE
C:\PS> $IPAddressList | % { Get-GeoIPInfo -IPs $_ }

.LINK
https://github.com/vukasinterzic/AdminToolBox

#>

function Get-GeoIPInfo {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$IPs
    )

    Write-Verbose -Message "Running function Get-GeoIPInfo..."

    $GeoIPInfo = @()


    foreach ($IP in $IPs) {

        Write-Verbose -Message "Testing if IP address parameter is entered in correct format..."

        If ([bool]($IP -as [ipaddress])) {

            Write-Verbose -Message "Provided parameter is in the correct format. Testing if the IP address is private or public..." #or APIPA

            if (($IP -like "192.168.*") -or ($IP -like "172.16.*") -or ($IP -like "10.*") -or ($IP -like "169.254.*")) {

                Write-Verbose -Message "IP address $IP is PRIVATE IP address and it will be skipped."

            } else {
                Write-Verbose -Message "IP address is valid PUBLIC IP address. Getting GEO info..."

                #You need to use your access key here in order to make it work. To get it, create free account on www.ipstack.com
                $AccessKey = "813e23240f5899917a13c29e6f2212bc"
                $url = "http://api.ipstack.com/$($IP)?access_key=$($AccessKey)&format=1&output=json"

                $GeoInfo = Invoke-RestMethod -Method Get -URI $url

                $GoogleMapsLink = "http://maps.google.com/maps?q=$($GeoInfo.latitude),$($GeoInfo.longitude)"

                #Create custom object with all collected properties
                $obj = New-Object psobject
                $obj | Add-Member -MemberType NoteProperty -Name IP -Value $GeoInfo.ip
                $obj | Add-Member -MemberType NoteProperty -Name Type -Value $GeoInfo.type
                $obj | Add-Member -MemberType NoteProperty -Name ContinentCode -Value $GeoInfo.continent_code
                $obj | Add-Member -MemberType NoteProperty -Name ContinentName -Value $GeoInfo.continent_name
                $obj | Add-Member -MemberType NoteProperty -Name CountryCode -Value $GeoInfo.country_code
                $obj | Add-Member -MemberType NoteProperty -Name CountryName -Value $GeoInfo.country_name
                $obj | Add-Member -MemberType NoteProperty -Name RegionCode -Value $GeoInfo.region_code
                $obj | Add-Member -MemberType NoteProperty -Name RegionName -Value $GeoInfo.region_name
                $obj | Add-Member -MemberType NoteProperty -Name City -Value $GeoInfo.city
                $obj | Add-Member -MemberType NoteProperty -Name ZipCode -Value $GeoInfo.zip
                $obj | Add-Member -MemberType NoteProperty -Name Latitude -Value $GeoInfo.latitude
                $obj | Add-Member -MemberType NoteProperty -Name Longitude -Value $GeoInfo.longitude
                $obj | Add-Member -MemberType NoteProperty -Name CountryCapital -Value $GeoInfo.location.capital
                $obj | Add-Member -MemberType NoteProperty -Name Language -Value $GeoInfo.location.languages.name
                $obj | Add-Member -MemberType NoteProperty -Name CountryCallingCode -Value $GeoInfo.location.calling_code
                $obj | Add-Member -MemberType NoteProperty -Name IsInEU -Value $GeoInfo.location.is_eu
                $obj | Add-Member -MemberType NoteProperty -Name GoogleMapsLink -Value $GoogleMapsLink

                $GeoIPInfo += $obj

            }

        } #end of IP address check
        else {
            Write-Verbose "IP address "$IP" is not a valid IP address, it will be skipped."
        }

    }

    if ($GeoIPInfo) {
        $GeoIPInfo
    }

    Write-Verbose -Message "End of function Get-GeoIPInfo."

}

#TODO Add support for IPv6
#FIXME Switch API to IP-API instead, because it contains information about ISP and it doesn't require registration key