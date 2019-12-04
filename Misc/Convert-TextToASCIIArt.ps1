<#
.SYNOPSIS
Convert your text to ASCII Art by using web API and save it to $ASCIIArt variable + copy to clipboard

.DESCRIPTION
Convert text. Output is variable and clipboard

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
$global:ASCIIArtText = ""

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
        $global:ASCIIArtText = (Invoke-WebREquest -URI $URL).Content

        $global:ASCIIArtText | clip

        Write-Verbose "Text converted and saved in variable `$ASCIIArtText"

    } #end of Process

    end {
        Write-Verbose "End of Convert-TextToASCIIArt function."
    }

}

#TODO Add description
#TODO Add font selection
#TODO Add color and print option