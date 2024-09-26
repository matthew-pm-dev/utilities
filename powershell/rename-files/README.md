# File Rename PowerShell Script

## Overview
This PowerShell script allows users to rename multiple files in a specified directory while retaining numerics.  It is primarily designed to change or fix broken file names for batches of files while retaining their numbering.

In addition to preserving numbers, the script can:
- Automatically add leading 0 to single digit numbers for more reliable file sorting.
- Specify additional characters to exclude from replacement (ex: ignore "-" for files organized by date YYYY-MM-DD).
- Target a specific file extension and ignore all other file types.
- Alternatively, specify a single substring to replace within the filenames leaving the rest intact.

## Important Warning
- **Caution:** The default behavior of this script renames **all files** in the specified directory. If no new prefix is provided, the script will remove all text from the file names, potentially leading to loss of meaningful file identifiers. Always review the directory contents and ensure you have backups before executing the script.

## Features
- **Directory Path Handling**: Automatically retrieves the last used directory path or allows the user to specify a new one.
- **Prefix Addition**: Users can specify a new prefix to be added to the file names.
- **File Extension Filtering**: Users can filter files by specific extensions or process all files.
- **Custom Replacement**: Replace specified substrings in file names, or replace all non-numeric characters.
- **Duplicate Handling**: Automatically handles duplicate file names by appending `_1`, `_2`, etc.
- **Caching**: Caches the last used directory path for 24 hours for quick access.

## Usage
1. Clone the repository or download the script file (`file-rename.ps1`).
2. Open PowerShell.
3. Navigate to the directory where the script is located.
4. Execute the script using the following command:
   ```powershell
   .\file-rename.ps1
5. Follow the prompts to specify:
   - The directory containing the files.
   - A new prefix for the files.
   - An optional file extension to filter.
   - A substring to replace or characters to exclude from replacement.

## Requirements
- PowerShell 5.0 or higher (included in Windows 10 and later).
- Basic knowledge of PowerShell command line usage.

## Examples
- To rename files in `C:\Images` with the prefix `Vacation_`:
   - Suppose you have the following files in `C:\Images`:
     - `img_01.jpg`
     - `photo_02.png`
   - Run the script and enter `C:\Images` as the directory path.
   - Enter `Vacation_` as the new prefix.
   - After executing the script, the renamed files will be:
     - `Vacation_01.jpg`
     - `Vacation_02.png`

## Contributing
If you would like to contribute to this project, please fork the repository and create a pull request.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
