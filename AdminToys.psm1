
# Get all .ps1 files except those in the Lib folder and import them individually.

Get-ChildItem $PSScriptRoot |
    Where-Object {$_.PSIsContainer -and ($_.Name -ne 'Lib')} |
    ForEach-Object {Get-ChildItem "$($_.FullName)\*" -Include '*.ps1'} |
    ForEach-Object {. $_.FullName}

# To Do:
# add function Aliases here
# add Module menu into PS ISE for easier usage