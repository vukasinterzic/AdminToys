<#
.SYNOPSIS
Each hardware vendor uses specific MAC addresses. Use this little script to identify the vendor by MAC address.

.DESCRIPTION
Uses online up-to-date information to identify vendor of MAC address that is provided.

.PARAMETER MACs
Specifies the one or more MAC addresses that you want to check

.PARAMETER ExportPath
Specify export file path, including file name.

.INPUTS
MACs

.OUTPUTS
MAC, Vendor Name

.EXAMPLE
C:\PS> Get-MACVendor -MACs 00-1C-42-98-DC-34

.EXAMPLE
C:\PS> $MAC | Get-MACVendor

.LINK
https://github.com/vukasinterzic/AdminToys

#>

function Get-MACVendor {

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$MACs,
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath
    )
    
    
    Write-Verbose -Message "Running function Get-MACVendor..."

    $MACVendor = @()

    foreach ($MAC in $MACs) {

        Write-Verbose -Message "Performing initial cleanup and MAC Address formatting ..."

        $MAC = $MAC.trim() #Remove space at the begining
        $MAC = $MAC.trimend() #Remove space at the end  
        #$MAC = $MAC -replace "-", ":" # Replace dash
        #$MAC = $MAC -replace ".", ":" # Replace dot
        $MAC = $MAC -replace "/S", ":" # Replace whitespace
        $MAC = $MAC -replace " ", ":" # Replace whitespace

        Write-Verbose -Message "Getting hardware vendor of $MAC..."
        $url = $url = "http://api.macvendors.com/$MAC"
        try {
            $Vendor = Invoke-RestMethod -Method GET -Uri "$url" -ErrorAction Stop

            Write-Verbose -Message "Adding result to custom object ..."
            $obj = New-Object psobject
            $obj | Add-Member -MemberType NoteProperty -Name MAC -Value $MAC
            $obj | Add-Member -MemberType NoteProperty -Name Vendor -Value $Vendor

            $MACVendor = $obj

        }
        catch {
            Write-Verbose "Error was detected."
            Write-Host -ForegroundColor Yellow "Unable to identify hardware vendor of MAC Address " -NoNewline
            Write-Host -ForegroundColor Red  "$MAC" -NoNewline
            Write-Host -ForegroundColor Yellow ". Error message is bellow:"
            Write-Host ""
            Write-Host -ForegroundColor Red $($_.Exception.message)
            Write-Host ""
        }

    }

    if ($MACVendor.Count -gt 0) {

        if ($ExportPath) {
            Write-Verbose "Parameter ExportPath specified, exporting data to CSV file..."
            $MACVendor | Export-Csv -Path $ExportPath -Delimiter ";" -NoTypeInformation
        }

        Write-Verbose -Message "MAC Vendor information:"
        $MACVendor
    }
    
    Write-Verbose -Message "End of function Get-MACVendor."
}