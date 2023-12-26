. $PSScriptRoot\common.ps1

# Local function
function Clear-Tmp {
    if (Test-Path -Path .\tmp\winget) {
        Remove-Item -Recurse -Force .\tmp\winget > $null 2>&1
    }
}

# Autopsy - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Autopsy."
winget download SleuthKit.Autopsy -d .\tmp\winget 2>&1 | Out-Null
copy-item .\tmp\winget\Autopsy*.msi .\downloads\autopsy.msi
Clear-Tmp

# DotNet 6 runtime - installed during startup
Clear-Tmp
Write-SynchronizedLog "winget: Downloading DotNet 6 runtime."
winget download Microsoft.DotNet.Runtime.6 -d .\tmp\winget 2>&1 | Out-Null
Copy-Item .\tmp\winget\Microsoft*.exe .\downloads\dotnet6.exe
Clear-Tmp

# GoLang - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading GoLang."
winget download Golang.Go -d .\tmp\winget 2>&1 | Out-Null
Copy-Item .\tmp\winget\Go*.msi .\downloads\golang.msi
Clear-Tmp

# Microsoft LogParser - available via git repo Events-Ripper
#Clear-Tmp
#Write-SynchronizedLog "winget: Downloading Microsoft LogParser."
#winget download Microsoft.LogParser -d .\tmp\winget 2>&1 | Out-Null
#Copy-Item .\tmp\winget\Log*.msi .\downloads\logparser.msi
#Clear-Tmp

# Obsidian - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Obsidian."
winget download Obsidian.Obsidian -d .\tmp\winget 2>&1 | Out-Null
Copy-Item .\tmp\winget\Obsidian*.exe .\downloads\obsidian.exe
Clear-Tmp

# PowerShell 7 - installed during startup
Clear-Tmp
Write-SynchronizedLog "winget: Downloading PowerShell 7."
winget download Microsoft.PowerShell -d .\tmp\winget 2>&1 | Out-Null
Copy-Item .\tmp\winget\PowerShell*.msi .\downloads\powershell.msi
Clear-Tmp

# Qemu - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Qemu."
winget download SoftwareFreedomConservancy.QEMU -d .\tmp\winget 2>&1 | Out-Null
Copy-Item .\tmp\winget\QEMU*.exe .\downloads\qemu.exe
Clear-Tmp

# Ruby - available for installation via dfirws-install.ps1
Clear-Tmp
Write-SynchronizedLog "winget: Downloading Ruby."
winget download RubyInstallerTeam.Ruby.3.3 -d .\tmp\winget 2>&1 | Out-Null
Copy-Item .\tmp\winget\Ruby*.exe .\downloads\ruby.exe
Clear-Tmp

# VirusTotal CLI
Clear-Tmp
Write-SynchronizedLog "winget: Downloading VirusTotal CLI."
winget download VirusTotal.vt-cli -d .\tmp\winget 2>&1 | Out-Null
Copy-Item .\tmp\winget\vt-cli*.zip .\downloads\vt.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\vt.zip" -o"$TOOLS\bin" | Out-Null
Clear-Tmp
