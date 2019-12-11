<#
.SYNOPSIS
Convert your text to ASCII Art by using web API.

.DESCRIPTION
Convert text. Output is also copied to sclipboard.

.PARAMETER Text
Add text. Parameter is mandatory.

.PARAMETER Font
Select different font of your text. You can find font preview in Font-Preview.html page

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
        [string] $Text,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string] $Font

    )

    begin {
        Write-Verbose -Message "Function Convert-TextToASCIIArt is called"
    }

    process {
        
        Write-Verbose -Message "Replacing spaces with + ..."
        $Text = $Text.Replace(" ","+")
        if ($Font) {
            Write-Verbose -Message "Font selected. Checking if font name is valid..."
            Write-Verbose -Message "Getting the list of fonts..."
            

            $URL = "http://artii.herokuapp.com/make?text="+$Text+"&font="+$Font
        } else {
            $URL = "http://artii.herokuapp.com/make?text="+$Text
        }


        
        $ASCIIArtText = (Invoke-WebRequest -URI $URL).Content

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

<#
#>

#Get the font list:

$FontsPageContent = (Invoke-WebRequest "http://artii.herokuapp.com/fonts_list").Content
$fonts = @()
$fonts = $FontsPageContent.Split([Environment]::NewLine)

$Body = @()
$Body +="
<!DOCTYPE html>
<html>

<body>
<h2>Font preview page</h2>
<table>
<tr>
<th>FontName</th>
<th>FontPreview</th>
<tr>
"
$FontPreview = @()
foreach ($Font in $Fonts) {

    
    $URL = "http://artii.herokuapp.com/make?text=Text&font="+$Font
    $FontPreview = (Invoke-WebRequest -Uri $URL).Content

    $Body += "
    <tr>
    <td>$Font</td>
    <td><pre><code>$FontPreview</code></pre></td>
    <tr>
    "

}

$Body += "</table></body></html>"

$Body | Out-File "Font-Preview.html"




#TODO Add font selection option