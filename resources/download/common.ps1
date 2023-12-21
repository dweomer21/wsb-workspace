# Set the default encoding for Out-File to UTF-8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Variables used by the script
$SETUP_PATH=".\downloads"
$TEMP="C:\tmp"
$TOOLS=".\mount\Tools"
$mutexName = "Global\dfirwsMutex"

$null=$SETUP_PATH
$null=$TEMP
$null=$TOOLS
$null=$mutexName

<#
.SYNOPSIS
Function to download a file from a given URI and save it to a specified file path.

.DESCRIPTION
This function allows you to download a file from a specified URI and save it to a specified file path on your local machine.

.PARAMETER Uri
The URI of the file to be downloaded.

.PARAMETER FilePath
The file path where the downloaded file will be saved.

.EXAMPLE
Download-File -Uri "https://example.com/file.txt" -FilePath "C:\Downloads\file.txt"
Downloads the file from the specified URI and saves it to the specified file path.

.NOTES
Author: Peter Reuterås
Date:   2023-12-21
#>
function Get-FileFromUri {
    Param (
        [Parameter(Mandatory=$True)] [string]$Uri,
        [Parameter(Mandatory=$True)] [string]$FilePath
    )

    # Remove any leading '..' from the file path and set up temporary file path and final file path
    $CleanPath = $FilePath -replace "^..", ""
    $TmpFilePath= "$PSScriptRoot\..\..\tmp\$CleanPath"
    $FilePath = "$PSScriptRoot\..\..\$CleanPath"

    # Ensure the directory for the final file path exists
    If (! ( Test-Path ([System.IO.FileInfo]$FilePath).DirectoryName ) ) {
        New-Item ([System.IO.FileInfo]$FilePath).DirectoryName -force -type directory | Out-Null
    }

    # Ensure the directory for the temporary file path exists
    If (! ( Test-Path ([System.IO.FileInfo]$TmpFilePath).DirectoryName ) ) {
        New-Item ([System.IO.FileInfo]$TmpFilePath).DirectoryName -force -type directory | Out-Null
    }

    # Set the number of retries for the download
    $retries = 3
    $ProgressPreference = 'SilentlyContinue'
    while($true) {
        try {
            # Attempt to download the file from the specified URI
            Remove-Item -Force $TmpFilePath -ErrorAction SilentlyContinue
            if ($Uri -like "*github.com*") {
                if ($GH_USER -eq "" -or $GH_PASS -eq "") {
                    curl.exe --silent -L --output $TmpFilePath $Uri
                } else {
                    curl.exe --silent -u "${GH_USER}:${GH_PASS}" -L --output $TmpFilePath $Uri
                }
            } elseif ($Uri -like "*marketplace.visualstudio.com*") {
                Invoke-WebRequest -uri $Uri -outfile $TmpFilePath -RetryIntervalSec 20 -MaximumRetryCount 3
            } else {
                curl.exe --silent -L --user-agent "Wget x64" --output $TmpFilePath $Uri
            }
            Write-SynchronizedLog "Downloaded $Uri to $FilePath."
            break
        }
        catch {
            $exceptionMessage = $_.Exception.Message
            Write-SynchronizedLog "Failed to download '$Uri': $exceptionMessage"
            if ($retries -gt 0) {
                $retries--
                Write-SynchronizedLog "Waiting 10 seconds before retrying. Retries left: $retries"
                Start-Sleep -Seconds 10
            } else {
                $exception = $_.Exception
                throw $exception
            }
        }
    }
    # Copy the temporary file to the final file path and remove the temporary file
    $result = rclone copyto --metadata --verbose --inplace --checksum $TmpFilePath $FilePath 2>&1 | Out-String
    Write-SynchronizedLog "$result"
    Remove-Item $TmpFilePath -Force | Out-Null
    $ProgressPreference = 'Continue'
}

<#
.SYNOPSIS
Retrieves the download URL for a GitHub release based on a provided regex match.

.DESCRIPTION
The Get-DownloadUrl function retrieves the download URL for a GitHub release by querying the GitHub API and filtering the results based on a provided regex match. It supports authentication using GitHub credentials.

.PARAMETER releases
The URL of the GitHub API endpoint that provides information about the releases.

.PARAMETER match
A regex pattern used to filter the download URLs. Only URLs that match the pattern will be returned.

.EXAMPLE
$releases = "https://api.github.com/repos/username/repo/releases/latest"
$match = ".*\.zip$"
$downloadUrl = Get-DownloadUrl -Releases $releases -Match $match
Retrieves the download URL for the latest release of the specified GitHub repository that ends with ".zip".

.NOTES
Author: Peter Reuterås
Date:   2023-12-21
#>
function Get-DownloadUrl {
    Param (
        [Parameter(Mandatory=$True)] [string]$releases,
        [Parameter(Mandatory=$True)] [string]$match
    )
    try {
        # Retrieve the download URLs and filter them based on the provided regex match
        if ($GH_USER -eq "" -or $GH_PASS -eq "") {
            $downloads = (curl.exe --silent -L $releases | ConvertFrom-Json)[0].assets.browser_download_url
        } else {
            $downloads = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json)[0].assets.browser_download_url
        }
    }
    catch {
        $downloads = ""
    }

    if (!$downloads) {
        try {
            if ($GH_USER -eq "" -or $GH_PASS -eq "") {
                $downloads = (curl.exe --silent -L $releases | ConvertFrom-Json).assets[0].browser_download_url
            } else {
                $downloads = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json).assets[0].browser_download_url
            }
        }
        catch {
            $downloads = ""
        }
    }

    if (!$downloads) {
        return ""
    }

    if ( ( Write-Output $downloads | Measure-Object -word ).Words -gt 1 ) {
        return $downloads -replace ' ', "`r`n" | findstr /R $match | findstr /R /V "darwin \.sig blockmap \.sha256 \.asc" | Select-Object -First 1
    } else {
        return $downloads
    }
}

<#
.SYNOPSIS
    Retrieves the download URL for the latest release of a GitHub repository.

.DESCRIPTION
    The Get-GitHubRelease function retrieves the download URL for the latest release of a GitHub repository. It uses the GitHub API to fetch the release information and matches the specified regex pattern to find the download URL.

.PARAMETER repo
    Specifies the GitHub repository in the format "owner/repo".

.PARAMETER path
    Specifies the local file path where the downloaded file will be saved.

.PARAMETER match
    Specifies the regex pattern used to match the desired download URL.

.EXAMPLE
    Get-GitHubRelease -repo "Microsoft/PowerShell" -path "C:\Downloads" -match ".*\.zip"

    This example retrieves the download URL for the latest release of the "Microsoft/PowerShell" repository and saves the downloaded file to the "C:\Downloads" directory. It matches the download URL that ends with ".zip".

.NOTES
    - This function requires an internet connection to access the GitHub API.
    - If the specified regex pattern does not match any download URL in the release information, the function will try to find the download URL without using the "latest" release.
    - If no download URL is found, the function will try to get the tarball URL.
    - If the tarball URL is also not found, an error will be displayed and the function will exit.
#>
function Get-GitHubRelease {
    Param (
        [Parameter(Mandatory=$True)] [string]$repo,
        [Parameter(Mandatory=$True)] [string]$path,
        [Parameter(Mandatory=$True)] [string]$match
    )

    # Construct the URL to get the latest release information
    $releases = "https://api.github.com/repos/$repo/releases/latest"

    # Get the download URL by matching the specified regex pattern
    $Url = Get-DownloadUrl -Releases $releases -Match $match

    # If no download URL is found, try without "latest"
    if ( !$Url ) {
        $releases = "https://api.github.com/repos/$repo/releases"
        $Url = Get-DownloadUrl -Releases $releases -Match $match
    }

    # If still no download URL is found, try getting the tarball URL
    if ( !$Url ) {
        $releases = "https://api.github.com/repos/$repo/releases/latest"
        if ($GH_USER -eq "" -or $GH_PASS -eq "") {
            $Url = (curl.exe --silent -L $releases | ConvertFrom-Json).zipball_url.ToString()
        } else {
            $Url = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json).zipball_url.ToString()
        }
        if ( !$Url) {
            Write-Error "Can't find a file to download for repo $repo."
            Exit
        }
    }

    # Log the chosen URL and download the file
    Write-SynchronizedLog "Using $Url for $repo."
    Get-FileFromUri -uri $Url -FilePath $path
}

<#
.SYNOPSIS
Function to get the download URL for a Chocolatey package.

.DESCRIPTION
This function retrieves the download URL for a specified Chocolatey package.

.PARAMETER PackageName
The name of the Chocolatey package.

.EXAMPLE
Get-ChocolateyUrl -PackageName "example-package"

This example retrieves the download URL for the "example-package" Chocolatey package.

.NOTES
Author: Peter Reuterås
Date:   2023-12-21
#>
function Get-ChocolateyUrl {
    Param (
        [Parameter(Mandatory=$True)] [string]$PackageName
    )

    # Scrape the download URL from the Chocolatey package page
    $Url = curl --silent https://community.chocolatey.org/packages/$PackageName | findstr /C:"Download the raw" | findstr ">Download<" | ForEach-Object { ($_ -split '"' )[1] }

    if (!$Url) {
        Write-Error "Couldn't find download url for Chocolately package $PackageName."
        Exit
    }

    return $Url
}

<#
.SYNOPSIS
Retrieves the download URL from a web page based on a specified regular expression pattern.

.DESCRIPTION
The Get-DownloadUrlFromPage function retrieves the download URL from a web page by sending an HTTP request and parsing the response using a regular expression pattern. It supports authentication for GitHub URLs if the GH_USER and GH_PASS environment variables are set.

.PARAMETER Url
The URL of the web page from which to retrieve the download URL.

.PARAMETER RegEx
The regular expression pattern used to extract the download URL from the web page.

.EXAMPLE
Get-DownloadUrlFromPage -Url "https://example.com" -RegEx "href=\"(.*?)\""

This example retrieves the download URL from the web page "https://example.com" using the regular expression pattern "href=\"(.*?)\"".

.NOTES
Author: Your Name
Date:   Current Date
#>
function Get-DownloadUrlFromPage {
    param (
        [Parameter(Mandatory=$True)] [string]$Url,
        [Parameter(Mandatory=$True)] [regex]$RegEx
    )

    if ($Url -contains "github.com") {
        if ($GH_USER -eq "" -or $GH_PASS -eq "") {
            return curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
        } else {
            return curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
        }
    } else {
        return curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
    }
}

<#
.SYNOPSIS
Get the download URL for a package from the MSYS repository.

.DESCRIPTION
The Get-DownloadUrlMSYS function retrieves the download URL for a specific package from the MSYS repository. It searches for the package name in the repository, filters out any signature files, and returns the URL of the latest version of the package.

.PARAMETER PackageName
The name of the package to retrieve the download URL for.

.EXAMPLE
Get-DownloadUrlMSYS -PackageName "gcc"
Returns the download URL for the latest version of the "gcc" package from the MSYS repository.

.OUTPUTS
System.String

.NOTES
Author: Peter Reuterås
Date:  2023-12-21
#>
function Get-DownloadUrlMSYS {
    param (
        [Parameter(Mandatory=$True)] [string]$PackageName
    )

    $base = "https://repo.msys2.org/msys/x86_64/"
    $PackageName = '"' + $PackageName + "-[0-9]"
    $Url = curl --silent -L $base |
        findstr "$PackageName" |
        findstr /v ".sig" |
        ForEach-Object { ($_ -split '"')[1]} |
        ForEach-Object {
            if ($_ -match '(.+)-([0-9.]+)-([0-9]+)-(.+)\.pkg\.tar\.zst') {
                [PSCustomObject]@{
                    FileName    = $_
                    Name        = $matches[1]
                    Version     = [System.Version]::Parse($matches[2])
                    Release     = [int]::Parse($matches[3])
                    Architecture = $matches[4]
                }
            } else {
                [PSCustomObject]@{
                    FileName    = $_
                }
            }
        } |
        Sort-Object -Property Version, Release -Descending |
        Select-Object -First 1
    return $base + $Url.FileName
}

<#
.SYNOPSIS
Stops the Windows Sandbox when a specific condition is met.

.DESCRIPTION
The Stop-SandboxWhenDone function is used to stop the Windows Sandbox when a specific condition is met. It continuously checks for the presence of the Windows Sandbox process and a specified file path. If both conditions are met, it terminates the Windows Sandbox process, removes the specified file, releases the mutex, and exits the function.

.PARAMETER path
Specifies the path of the file that needs to exist in order to stop the Windows Sandbox.

.PARAMETER Mutex
Specifies the mutex object that is used to synchronize access to shared resources.

.EXAMPLE
Stop-SandboxWhenDone -path "C:\Temp\sample.txt" -Mutex $mutex
This example stops the Windows Sandbox when the file "C:\Temp\sample.txt" exists and the mutex object $mutex is released.

.NOTES
Author: Peter Reuterås
Date:   2023-12-21
#>
function Stop-SandboxWhenDone {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True)] [string]$path,
        [Parameter(Mandatory=$True)] [System.Threading.Mutex] $Mutex
    )

    while ($true) {
        $status = Get-Process WindowsSandboxClient 2> $null
        if ($status) {
            if ( Test-Path $path ) {
                if($PSCmdlet.ShouldProcess($file.Name)) {
                    (Get-Process WindowsSandboxClient).Kill()
                    Remove-Item -Force "$path"
                    Start-Sleep 1
                    $mutex.ReleaseMutex()
                    $mutex.Dispose()
                    return
                }
            }
            Start-Sleep 1
        } else {
            $mutex.ReleaseMutex()
            $mutex.Dispose()
            return
        }
    }
}

<#
.SYNOPSIS
Function to write a synchronized log to a specified file.

.DESCRIPTION
This function writes a synchronized log to a specified file. It ensures that multiple threads or processes can write to the log file without conflicts.

.PARAMETER LogFile
The path to the log file where the log will be written.

.PARAMETER Message
The message to be written to the log file.

.EXAMPLE
Write-SynchronizedLog -LogFile "C:\Logs\log.txt" -Message "This is a log message"

This example demonstrates how to use the Write-SynchronizedLog function to write a log message to the specified log file.

.NOTES
Author: Peter Reuterås
Date:   2023-12-21
#>
function Write-SynchronizedLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message,
        [Parameter(Mandatory=$false)] [string]$LogFile = "$PSScriptRoot\..\..\log\log.txt"
    )

    $logMutex = New-Object -TypeName 'System.Threading.Mutex' -ArgumentList $false, 'Global\dfirwsLogMutex'

    try {
        $result = $logMutex.WaitOne()
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $fullMessage = "$timestamp - $Message"
        Add-Content -Path $LogFile -Value $fullMessage
    }
    finally {
        $result = $logMutex.ReleaseMutex()
    }

    if (!$result) {
        Write-Debug "Error"
    }
}

<#
.SYNOPSIS
Write a log entry with a timestamp.

.DESCRIPTION
This function is used to write a log entry with a timestamp. It can be used to track the execution of a script or record important events.

.PARAMETER Message
The message to be logged.

.EXAMPLE
Write-LogEntry -Message "Script execution started."

This example demonstrates how to use the Write-LogEntry function to write a log entry with a custom message.

#>
function Write-DateLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "$timestamp - $Message"
    Write-Output $fullMessage
}