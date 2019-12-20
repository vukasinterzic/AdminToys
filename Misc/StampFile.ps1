<#
.SYNOPSIS
Add date and time stamp to file name, or create new file. 

.DESCRIPTION
Rename any type of file or files and add current date and time stamp to the end of file name. You can also decide to keep existing file and create new file with the date and time added to the original name.

.PARAMETER fileNames
Specify name of file or files. This can come from pipeline. Parameter is mandatory.

.PARAMETER KeepOriginal
Switch parameter, if selected original file will not be renamed and new file will be created instead.

.INPUTS

.OUTPUTS

.EXAMPLE
StampFile -fileNames test.txt

.EXAMPLE
StampFile -fileNames test.txt -KeepOriginal

.EXAMPLE
Get-ChildItem | where Name -like "test*" | StampFile

.LINK
https://github.com/vukasinterzic/AdminToys

#>

function StampFile {

    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array] $fileNames,
    
        [Parameter(Mandatory = $false)]
        [switch]$KeepOriginal
        
    )

    begin {
        Write-Verbose "Function StampFile is called"
    }

    process {
    
        foreach ($fileName in $fileNames) {
            Write-Verbose "Testing if file $fileName exists..."
            if (!(Test-Path $fileName)) {
                Write-Host -ForegroundColor Magenta "File $fileName is not found."
            }
            else {
                Write-Host -ForegroundColor Cyan "Original file: $fileName"
                
                $obj = Get-Item $fileName
                Write-Verbose "Getting date and time stamp..."
                $timeStamp = Get-Date -UFormat "%Y-%m-%d_%H-%M-%S"
    
                Write-Verbose "Getting file extension..."
                $ext = $obj.extension
    
                if ($ext.Length -eq 0) {
                    $name = $obj.Name
    
                    Write-Verbose "File doesn't have extension."
                    if ($KeepOriginal) {
                        Write-Verbose "KeepOriginal switch was selected. Copying file..."
                        $filePath = Split-Path $obj -Parent
                        Copy-Item $obj -Destination "$filePath`\$name-$timeStamp$ext"
                        Write-Host -ForegroundColor Green "New file name: $name-$timeStamp"
                    }
                    else {
                        Write-Verbose "Renaming original file..."
                        Rename-Item -Path $obj -NewName "$name-$timeStamp"
                        Write-Host -ForegroundColor Green "Renamed file name: $name-$timeStamp"
                    }
    
                }
                else {
                    Write-Verbose "File does have extension."
                    $name = $obj.Name.Replace( $obj.Extension, '')
                    
                    if ($KeepOriginal) {
                        Write-Verbose "KeepOriginal switch was selected. Copying file ..."
                        $filePath = Split-Path $obj -Parent
                        Copy-Item $obj -Destination "$filePath`\$name-$timeStamp$ext"
                        Write-Host -ForegroundColor Green "New file name: $name-$timeStamp$ext"
                    }
                    else {
                        Write-Verbose "Renaming original file..."
                        Rename-Item -Path $obj -NewName "$name-$timeStamp$ext"
                        Write-Host -ForegroundColor Green "Renamed file name: $name-$timeStamp$ext"

                    }
                }
    
    
            } #end of file processing file
        } #end of foreach file loop


    } #end of Process

    end {
        Write-Verbose "End of StampFile function."
    }

}