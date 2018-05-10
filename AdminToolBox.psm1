
#Get all .ps1 files in Module folder and import them individually. This will load all individual functions.
Get-ChildItem -Path $PSScriptRoot\*.ps1 | ForEach-Object -Process {
    . $_.FullName
}

#To Do:
#add function Aliases here
#add Module menu into PS ISE for easier usage