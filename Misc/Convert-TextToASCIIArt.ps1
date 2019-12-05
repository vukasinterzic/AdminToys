<#
.SYNOPSIS
Convert your text to ASCII Art by using web API.

.DESCRIPTION
Convert text. Output is also copied to sclipboard.

.PARAMETER Text
Add text. Parameter is mandatory.

.INPUTS
Text;

.OUTPUTS

.EXAMPLE
Convert-TextToASCIIArt -Text "Hello World"

.LINK
https://github.com/vukasinterzic/AdminToolBox

#>

function Convert-TextToASCIIArt {

    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string] $Text

    )

    begin {
        Write-Verbose "Function Convert-TextToASCIIArt is called"
    }

    process {
        
        $Text = $Text.Replace(" ","+")
        $URL = "http://artii.herokuapp.com/make?text="+$Text
        $ASCIIArtText = (Invoke-WebREquest -URI $URL).Content

        $ASCIIArtText | clip

        Write-Verbose "Text converted and copied to clipboard"

        if ($ASCIIArtText) {
            $ASCIIArtText
        }

    } #end of Process

    end {
        Write-Verbose "End of Convert-TextToASCIIArt function."
    }

}

#TODO Add font selection option