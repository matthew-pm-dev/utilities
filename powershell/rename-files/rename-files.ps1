Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)

# Appends _1,_2, etc to handle name conflict
function Handle-Duplicate {
    param (
        [string]$ModifiedFileName,
        [string]$FileExtension,
        [string]$DirectoryPath
    )

    $newFileName = "$ModifiedFileName$FileExtension"
    $newFilePath = Join-Path -Path $DirectoryPath -ChildPath $newFileName

    $duplicateCount = 0

    $existingFiles = Get-ChildItem -Path $DirectoryPath -File | Where-Object { $_.Extension -eq $FileExtension }
    while ($existingFiles.Name -contains $newFileName) {
        $duplicateCount++
        $newFileName = "$ModifiedFileName`_$duplicateCount$FileExtension"
        $newFilePath = Join-Path -Path $DirectoryPath -ChildPath $newFileName
    }

    return $newFilePath
}

function Rename-File {
    param (
        [string]$OriginalFilePath,
        [string]$NewFilePath
    )

    if (Test-Path $NewFilePath) {
        Write-Warning "File '$NewFilePath' already exists. Skipping renaming for '$OriginalFilePath'."
        return $false
    } else {
        Rename-Item -Path $OriginalFilePath -NewName $NewFilePath -Force
        Write-Host "Renamed '$($OriginalFilePath | Split-Path -Leaf)' to '$($NewFilePath | Split-Path -Leaf)'"
        return $true
    }
}

# Check for TMP file with directory path and age < 24 hours
# User can choose to use stored path or enter new path
# Write whatever path is used to TMP to refresh 24 hour TTL
$tempFilePath = Join-Path -Path $env:TEMP -ChildPath "file_rename_ps_last_used_directory.txt"

if (Test-Path $tempFilePath) {
    $fileCreationDate = (Get-Item $tempFilePath).CreationTime
    if ((Get-Date) - $fileCreationDate -lt (New-TimeSpan -Hours 24)) {
        $storedPath = Get-Content $tempFilePath
        Write-Host "Cached path: [$storedPath]"
        Write-Host "Leave blank to use cached path."
    } else {
        Remove-Item $tempFilePath -Force
        Write-Host "Stored directory path has expired. Please enter a new path."
    }
} else {
    Write-Host "No stored directory path found."
}

$DirectoryPath = Read-Host -Prompt "Enter the path to the directory containing the files"
if (-not $DirectoryPath) {
    $DirectoryPath = $storedPath
}

if (-not (Test-Path $DirectoryPath)) {
    Write-Host "The directory path '$DirectoryPath' does not exist."
    exit
}

Set-Content -Path $tempFilePath -Value $DirectoryPath

# Prompt the user for the new file name prefix
$NewPrefix = Read-Host -Prompt "Enter the new prefix for the files"

if (-not $NewPrefix) {
    Write-Warning "no replacement file prefix given - this may cause error on some files."
}

# Prompt the user for the optional file extension
# default: all files
$FileExtension = Read-Host -Prompt "Enter the file extension to filter by (leave empty for all files)"

# Prompt the user for the substring to replace (optional)
# default: replaces all non-numeric characters
$SubstringToReplace = Read-Host -Prompt "Enter the substring to replace (leave empty to replace all non-numeric characters)"

# Get all files in the specified directory
if ($FileExtension) {
    if (-not $FileExtension.StartsWith('.')) {
        $FileExtension = ".$FileExtension"
    }
    $files = Get-ChildItem -Path $DirectoryPath -File -Filter "*$FileExtension"
} else {
    $files = Get-ChildItem -Path $DirectoryPath -File
}

$excludePattern = ""

if (-not [string]::IsNullOrEmpty($SubstringToReplace)) {
    # Replace the user provided substring directly with the new prefix
    # Leaves the rest of the file name intact.
    foreach ($file in $files) {
        $originalFileName = $file.BaseName
        $modifiedFileName = $originalFileName -replace [regex]::Escape($SubstringToReplace), $NewPrefix
        $fileExtension = $file.Extension

        $newFileName = "$modifiedFileName$fileExtension"

        $newFilePath = Join-Path -Path $DirectoryPath -ChildPath $newFileName

        # Handle duplicates and rename file
        $newFilePath = Handle-Duplicate -ModifiedFileName $modifiedFileName -FileExtension $fileExtension -DirectoryPath $directoryPath      
        $renameSuccess = Rename-File -OriginalFilePath $file.FullName -NewFilePath $newFilePath
    }
} else {
    # Replaces all non-numeric characters with the user provided new prefix
    # Takes optional parameters for additional characters to exclude
    # Generates 3 digit random number and appends xNNN to files without any numbers to prevent conflicts

    $excludeCharacters = Read-Host -Prompt "Enter characters to exclude from replacing (separated by commas, leave empty for none)"
    if ($excludeCharacters) {
        $excludePattern = -join ($excludeCharacters -split ',') -replace '([.*+?^${}()|\[\]\\])', '\\$1'  # Escape special regex characters
    }

    foreach ($file in $files) {
        $originalFileName = $file.BaseName
        $cleanedFileName = $originalFileName -replace "[^$excludePattern\d]", ""
        $numericPart = -join ($originalFileName -replace "[^$excludePattern\d]", '') 

        if (-not $numericPart) {
            $numericPart = "x" + (Get-Random -Minimum 100 -Maximum 999)
        }
        else {
            # If a single digit number, prefix it with a leading zero
            if ($numericPart.Length -eq 1) {
                $numericPart = "0$numericPart"
            }
        }

        $modifiedFileName = "$NewPrefix$numericPart"
        $fileExtension = $file.Extension
        $newFileName = "$modifiedFileName$fileExtension"

        $newFilePath = Join-Path -Path $DirectoryPath -ChildPath $newFileName

        # Handle duplicates and rename file
        $newFilePath = Handle-Duplicate -ModifiedFileName $modifiedFileName -FileExtension $fileExtension -DirectoryPath $directoryPath
        $renameSuccess = Rename-File -OriginalFilePath $file.FullName -NewFilePath $newFilePath

    }
}

Write-Host "Renaming process completed."
Read-Host -Prompt "Press Enter to exit"