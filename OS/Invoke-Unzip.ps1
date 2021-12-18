<#
.SYNOPSIS
This function performs zip file extraction. 

.DESCRIPTION
Zip file extraction by attempting 3 methods, in case prerequisites are not met.

.PARAMETER ZipFile
Specifies the name or path of the zipped file that needs to be extracted.

.PARAMETER ExportPath
Specify the path for the exported files.

.EXAMPLE
C:\PS> Invoke-Unzip -ZipFile c:\file.zip -ExportPath c:\exported

.LINK
https://github.com/vukasinterzic/AdminToys

#>

function Invoke-Unzip {
    [cmdletbinding()]
    param(
        [string]$ZipFile,
        [string]$ExportPath
    )

    if (!$ExportPath) {
        Write-Verbose -Message "ExportPath not provided. Using same path as ZipFile."
        $ExportPath = Get-Item $ZipFile | Select-Object -ExpandProperty DirectoryName
    }

    if (Get-Command expand-archive) {
        $ErrorActionPreference = 'SilentlyContinue'
        Expand-Archive -Path $ZipFile -DestinationPath $ExportPath
        $ErrorActionPreference = 'Continue'
    }

    else {
        try {
            #Allows for unzipping folders in older versions of powershell if .net 4.5 or newer exists
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $ExportPath)
        }
    
        catch {
            #If .net 4.5 or newer not present, com classes are used. This process is slower.
            [void] (New-Item -Path $ExportPath -ItemType Directory -Force)
            $Shell = New-Object -com Shell.Application
            $Shell.Namespace($outpath).copyhere($Shell.NameSpace($ZipFile).Items(), 4)
        }
    }
}


#FIXME Add Force parameter to enable overwriting existing files