<#
.SYNOPSIS
Convert your text to ASCII Art by using web API.

.DESCRIPTION
Convert text. Output is also copied to sclipboard.

.PARAMETER Text
Add text. Parameter is mandatory.

.PARAMETER Font
Select different font of your text. You can find font preview in Font-Preview.html file

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

            $FontsPageContent = (Invoke-WebRequest "http://artii.herokuapp.com/fonts_list").Content
            $FontsList = @()
            $FontsList = $FontsPageContent.Split([Environment]::NewLine)
            
            if ($FontsList -contains $Font) {

                Write-Verbose -Message "Font name is valid. Creating URL..."
                $URL = "http://artii.herokuapp.com/make?text="+$Text+"&font="+$Font

            } else {

                Write-Verbose -Message "Font name is not valid. End of function."
                throw "Invalid font name provided. For list and preview of available fonts check Font-Preview.html or generate new one."
            }

        } else {
            Write-Verbose -Message "Font not selected. Creating URL..."
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
#Use this section to get fresh list and preview of each font and save it to the HTML page.

$FontsPageContent = (Invoke-WebRequest "http://artii.herokuapp.com/fonts_list").Content
$FontsList = @()
$FontsList = $FontsPageContent.Split([Environment]::NewLine)

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
foreach ($Font in $FontsList) {

    
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

#>
