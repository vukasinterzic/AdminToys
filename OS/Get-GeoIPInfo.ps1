<#
.SYNOPSIS
This function finds GEO information about public IP

.DESCRIPTION
Use this function to find geographical information about public IP address.

.PARAMETER IP
Specifies and IP address to check

.INPUTS
Public IP Address

.OUTPUTS
Geo information about IP

.EXAMPLE
C:\PS> Get-GeoIPInfo -IP $IP

.EXAMPLE
C:\PS> $IPAddressList | % { Get-GeoIPInfo -IP $_ }

.LINK
https://github.com/vukasinterzic/AdminToys

#>

function Get-GeoIPInfo {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$IP,

        [Parameter(Mandatory = $false)]
        [switch]$ShowOnMap
    )

    Write-Verbose -Message "Running function Get-GeoIPInfo..."

    $GeoIPInfo = @()
    [bool]$IsCorrect = $false

    if (!$IP) {

        Write-Verbose -Message "Public IP not entered. Getting the results for this computer IP ..."
        $IsCorrect = $true
        $IsCorrect

    } else {

        Write-Verbose -Message "Testing if provided IP address parameter is entered in the correct format..."

        If ([bool]($IP -as [ipaddress])) {

            Write-Verbose -Message "Provided parameter is in the correct format. Testing if the IP address is private or public..." #or APIPA

            if (($IP -like "192.168.*") -or ($IP -like "172.16.*") -or ($IP -like "10.*") -or ($IP -like "169.254.*")) {

                Write-Verbose -Message "IP address $IP is PRIVATE IP address and it will be skipped."
                $IsCorrect = $false

            } else {
                Write-Verbose -Message "IP address is valid PUBLIC IP address. Getting GEO info..."
                $IsCorrect = $true
            }

        } else {
            
            Write-Verbose "IP address "$IP" is not a valid IP address, it will be skipped."
            $IsCorrect = $false

        }
    
    }


    if ($IsCorrect) {

        <#  Switched from ipstack.com to ip-api.com because first one didn't contain ISP info in free version, location was not accurate and and it required access key
            #You need to use your access key here in order to make it work. To get it, create free account on www.ipstack.com
            $AccessKey = "813e23240f5899917a13c29e6f2212bc" #it will stop working if overused
            $url = "http://api.ipstack.com/$($IP)?access_key=$($AccessKey)&format=1&output=json"
        #>

        #limit is 45 requests per minute from single IP
        $url = "http://ip-api.com/json/"+$IP+"?fields=16515071" #for different field selection URL go to https://ip-api.com/docs/api:json

        $GeoInfo = Invoke-RestMethod -Method Get -URI $url

        $GoogleMapsLink = "http://maps.google.com/maps?q=$($GeoInfo.lat),$($GeoInfo.lon)"

        If ($ShowOnMap) {

            Write-Verbose "Show On Map is requested. Opening Google Map Link in a separate browser tab."

            Start-Process $GoogleMapsLink

        }

        #Create custom object with all collected properties
        $obj = New-Object psobject
        $obj | Add-Member -MemberType NoteProperty -Name IP -Value $GeoInfo.query
        $obj | Add-Member -MemberType NoteProperty -Name Status -Value $GeoInfo.status
        $obj | Add-Member -MemberType NoteProperty -Name ISP -Value $GeoInfo.isp
        $obj | Add-Member -MemberType NoteProperty -Name AS -Value $GeoInfo.as
        $obj | Add-Member -MemberType NoteProperty -Name ASname -Value $GeoInfo.asname
        $obj | Add-Member -MemberType NoteProperty -Name ReverseLookup -Value $GeoInfo.reverse #this is slow, comment out if not needed
        $obj | Add-Member -MemberType NoteProperty -Name Mobile -Value $GeoInfo.mobile
        $obj | Add-Member -MemberType NoteProperty -Name Proxy -Value $GeoInfo.proxy
        $obj | Add-Member -MemberType NoteProperty -Name ContinentCode -Value $GeoInfo.continentCode
        $obj | Add-Member -MemberType NoteProperty -Name ContinentName -Value $GeoInfo.continent
        $obj | Add-Member -MemberType NoteProperty -Name CountryCode -Value $GeoInfo.countryCode
        $obj | Add-Member -MemberType NoteProperty -Name CountryName -Value $GeoInfo.country
        $obj | Add-Member -MemberType NoteProperty -Name RegionCode -Value $GeoInfo.region
        $obj | Add-Member -MemberType NoteProperty -Name RegionName -Value $GeoInfo.regionName
        $obj | Add-Member -MemberType NoteProperty -Name City -Value $GeoInfo.city
        $obj | Add-Member -MemberType NoteProperty -Name District -Value $GeoInfo.district
        $obj | Add-Member -MemberType NoteProperty -Name ZipCode -Value $GeoInfo.zip
        $obj | Add-Member -MemberType NoteProperty -Name TimeZone -Value $GeoInfo.timezone
        $obj | Add-Member -MemberType NoteProperty -Name Currency -Value $GeoInfo.currency
        $obj | Add-Member -MemberType NoteProperty -Name Latitude -Value $GeoInfo.lat
        $obj | Add-Member -MemberType NoteProperty -Name Longitude -Value $GeoInfo.lon
        #$obj | Add-Member -MemberType NoteProperty -Name CountryCapital -Value 
        #$obj | Add-Member -MemberType NoteProperty -Name Language -Value 
        #$obj | Add-Member -MemberType NoteProperty -Name CountryCallingCode -Value 
        #$obj | Add-Member -MemberType NoteProperty -Name IsInEU -Value 
        $obj | Add-Member -MemberType NoteProperty -Name GoogleMapsLink -Value $GoogleMapsLink

        $GeoIPInfo += $obj

    } # The end of the IP check


    if ($GeoIPInfo) {
        $GeoIPInfo
    }

    Write-Verbose -Message "End of function Get-GeoIPInfo."

}

#TODO Add support for IPv6 input
#TODO Add country information from country API https://restcountries.eu
#FIXME Add limitation to 45 requests per minute
#FIXME Improve IP format check. Currently it checks text and wrong size. But it will still try to work with just numbers such as 123123123.