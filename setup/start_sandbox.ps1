# DFIRWS

# Import common functions
. $HOME\Documents\tools\wscommon.ps1

$WIN10=(Get-ComputerInfo | Select-Object -expand OsName) -match 10
#$WIN11=(Get-ComputerInfo | Select-Object -expand OsName) -match 11

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-DateLog "start_sandbox.ps1"

# Bypass the execution policy for the current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Set variables
$DATA = "C:\data"
$GIT = "C:\git"
$LOCAL_PATH = "C:\local"
$NEO_JAVA = "C:\java"
$PDFSTREAMDUMPER = "C:\Sandsprite\PDFStreamDumper"
$SETUP_PATH = "C:\downloads"
$TEMP = "C:\tmp"
$TOOLS = "C:\Tools"
$VENV = "C:\venv"

# Create required directories
New-Item -ItemType Directory "$TEMP"
New-Item -ItemType Directory "$DATA"
New-Item -ItemType Directory "$env:ProgramFiles\bin"
New-Item -ItemType Directory "$HOME\Documents\WindowsPowerShell"
New-Item -ItemType Directory "$HOME\Documents\PowerShell"
New-Item -ItemType Directory "$env:ProgramFiles\PowerShell\Modules\PSDecode"
New-Item -ItemType Directory "$HOME\Documents\jupyter"

# Copy config files and import them
Copy-Item "$HOME\Documents\tools\config.txt" $TEMP\config.ps1
Copy-Item "$HOME\Documents\tools\default-config.txt" $TEMP\default-config.ps1
. $TEMP\default-config.ps1
. $TEMP\config.ps1

# PowerShell
Copy-Item "$HOME\Documents\tools\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Copy-Item "$HOME\Documents\tools\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Copy-Item "$HOME\Documents\tools\utils\PSDecode.psm1" "$env:ProgramFiles\PowerShell\Modules\PSDecode"

# Jupyter
Copy-Item "$HOME\Documents\tools\jupyter\.jupyter" "$HOME\" -Recurse
Copy-Item $HOME\Documents\tools\jupyter\*.ipynb "$HOME\Documents\jupyter\"

# Install latest PowerShell
Copy-Item   "$SETUP_PATH\powershell.msi" "$TEMP\powershell.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\powershell.msi /qn /norestart"
$POWERSHELL_EXE = "$env:ProgramFiles\PowerShell\7\pwsh.exe"

# Install 7-Zip
Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\7zip.msi /qn /norestart"

# Always install common Java.
Copy-Item "$SETUP_PATH\corretto.msi" "$TEMP\corretto.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\corretto.msi /qn /norestart"

# Java 11 for NEO4J
if ($WSDFIR_JAVA_JDK11 -eq "Yes") {
    Copy-Item "$SETUP_PATH\microsoft-jdk-11.msi" "$TEMP\microsoft-jdk-11.msi"
    Start-Process -Wait msiexec -ArgumentList "/i $TEMP\microsoft-jdk-11.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR=$NEO_JAVA /qn /norestart"
}

if (($WSDFIR_JAVA_JDK11 -eq "Yes") -and ($WSDFIR_NEO4J -eq "Yes")) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\neo4j.zip" -o"$env:ProgramFiles"
    Move-Item $env:ProgramFiles\neo4j-community* $env:ProgramFiles\neo4j
    Add-ToUserPath "$env:ProgramFiles\neo4j\bin"
    & "$env:ProgramFiles\neo4j\bin\neo4j-admin" set-initial-password neo4j
    Copy-Item -Recurse "$TOOLS\neo4j" "$env:ProgramFiles"
}

# Install LibreOffice with custom arguments
if ($WSDFIR_LIBREOFFICE -eq "Yes") {
    Copy-Item "$SETUP_PATH\LibreOffice.msi" "$TEMP\LibreOffice.msi"
    Start-Process -Wait msiexec -ArgumentList "/qb /i $TEMP\LibreOffice.msi /l* $TEMP\LibreOffice_install_log.txt REGISTER_ALL_MSO_TYPES=1 UI_LANGS=en_US ISCHECKFORPRODUCTUPDATES=0 REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 REMOVE=gm_o_Onlineupdate,gm_r_ex_Dictionary_Af,gm_r_ex_Dictionary_An,gm_r_ex_Dictionary_Ar,gm_r_ex_Dictionary_Be,gm_r_ex_Dictionary_Bg,gm_r_ex_Dictionary_Bn,gm_r_ex_Dictionary_Bo,gm_r_ex_Dictionary_Br,gm_r_ex_Dictionary_Pt_Br,gm_r_ex_Dictionary_Bs,gm_r_ex_Dictionary_Pt_Pt,gm_r_ex_Dictionary_Ca,gm_r_ex_Dictionary_Cs,gm_r_ex_Dictionary_Da,gm_r_ex_Dictionary_Nl,gm_r_ex_Dictionary_Et,gm_r_ex_Dictionary_Gd,gm_r_ex_Dictionary_Gl,gm_r_ex_Dictionary_Gu,gm_r_ex_Dictionary_He,gm_r_ex_Dictionary_Hi,gm_r_ex_Dictionary_Hu,gm_r_ex_Dictionary_Lt,gm_r_ex_Dictionary_Lv,gm_r_ex_Dictionary_Ne,gm_r_ex_Dictionary_No,gm_r_ex_Dictionary_Oc,gm_r_ex_Dictionary_Pl,gm_r_ex_Dictionary_Ro,gm_r_ex_Dictionary_Ru,gm_r_ex_Dictionary_Si,gm_r_ex_Dictionary_Sk,gm_r_ex_Dictionary_Sl,gm_r_ex_Dictionary_El,gm_r_ex_Dictionary_Es,gm_r_ex_Dictionary_Te,gm_r_ex_Dictionary_Th,gm_r_ex_Dictionary_Tr,gm_r_ex_Dictionary_Uk,gm_r_ex_Dictionary_Vi,gm_r_ex_Dictionary_Zu,gm_r_ex_Dictionary_Sq,gm_r_ex_Dictionary_Hr,gm_r_ex_Dictionary_De,gm_r_ex_Dictionary_Id,gm_r_ex_Dictionary_Is,gm_r_ex_Dictionary_Ko,gm_r_ex_Dictionary_Lo,gm_r_ex_Dictionary_Mn,gm_r_ex_Dictionary_Sr,gm_r_ex_Dictionary_Eo,gm_r_ex_Dictionary_It,gm_r_ex_Dictionary_Fr"
}

# Install Python
& "$SETUP_PATH\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

# Install Visual C++ Redistributable 16 and 17
Start-Process -Wait "$SETUP_PATH\vcredist_16_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -Wait "$SETUP_PATH\vcredist_17_x64.exe" -ArgumentList "/passive /norestart"

# Install .NET 6
Start-Process -Wait "$SETUP_PATH\dotnet6.exe" -ArgumentList "/install /quiet /norestart"

# Install HxD
Copy-Item "$TOOLS\hxd\HxDSetup.exe" "$TEMP\HxDSetup.exe"
& "$TEMP\HxDSetup.exe" /VERYSILENT /NORESTART

# Install Git if specified
if ($WSDFIR_GIT -eq "Yes") {
    Copy-Item "$SETUP_PATH\git.exe" "$TEMP\git.exe"
    Copy-Item "$HOME\Documents\tools\.bashrc" "$HOME\"
    & "$TEMP\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
}

# Install Notepad++ and ComparePlus plugin if specified
Copy-Item "$SETUP_PATH\notepad++.exe" "$TEMP\notepad++.exe"
& "$TEMP\notepad++.exe" /S
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\comparePlus.zip" -o"$env:ProgramFiles\Notepad++\Plugins\ComparePlus"

# Install PDFStreamDumper if specified
if ($WSDFIR_PDFSTREAM -eq "Yes") {
    Copy-Item "$SETUP_PATH\PDFStreamDumper.exe" "$TEMP\PDFStreamDumper.exe"
    & "$TEMP\PDFStreamDumper.exe" /verysilent
}

# Install Visual Studio Code and PowerShell extension if specified
if ($WSDFIR_VSCODE -eq "Yes") {
    Copy-Item "$SETUP_PATH\vscode.exe" "$TEMP\vscode.exe"
    Start-Process -Wait "$TEMP\vscode.exe" -ArgumentList '/verysilent /suppressmsgboxes /MERGETASKS="!runcode,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,addtopath"'
    if ($WSDFIR_VSCODE_POWERSHELL -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "$SETUP_PATH\vscode\vscode-powershell.vsix"' -WindowStyle Hidden
    }
    if ($WSDFIR_VSCODE_PYTHON -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "$SETUP_PATH\vscode\vscode-python.vsix"' -WindowStyle Hidden
    }
    if ($WSDFIR_VSCODE_SPELL -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "$SETUP_PATH\vscode\vscode-spell-checker.vsix"' -WindowStyle Hidden
    }
}

# Install Zui if specified
if ($WSDFIR_ZUI -eq "Yes") {
    Copy-Item "$SETUP_PATH\zui.exe" "$TEMP\zui.exe"
    & "$TEMP\zui.exe" /S /AllUsers
}

# Set date and time format
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "yyyy-MM-dd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sLongDate -value "yyyy-MMMM-dddd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss"

# Dark mode
if ($WSDFIR_DARK -eq "Yes") {
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0
}

# Show file extensions
Write-DateLog "Show file extensions"
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f

# Add right-click context menu if specified
if ($WSDFIR_RIGHTCLICK -eq "Yes") {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
}

# Import registry settings
reg import $HOME\Documents\tools\registry.reg

# Restart Explorer process
Stop-Process -ProcessName Explorer -Force

# Add to PATH
Write-DateLog "Add to PATH"
Add-ToUserPath "$env:ProgramFiles\4n4lDetector"
Add-ToUserPath "$env:ProgramFiles\7-Zip"
Add-ToUserPath "$env:ProgramFiles\bin"
Add-ToUserPath "$env:ProgramFiles\Git\bin"
Add-ToUserPath "$env:ProgramFiles\Git\usr\bin"
Add-ToUserPath "$env:ProgramFiles\hxd"
Add-ToUserPath "$env:ProgramFiles\idr\bin"
Add-ToUserPath "$env:ProgramFiles\Notepad++"
Add-ToUserPath "$GIT\ese-analyst"
Add-ToUserPath "$GIT\Events-Ripper"
Add-ToUserPath "$GIT\RegRipper3.0"
Add-ToUserPath "$GIT\Trawler"
Add-ToUserPath "$GIT\Zircolite\bin"
Add-ToUserPath "$TOOLS\bin"
Add-ToUserPath "$TOOLS\bulk_extractor\win64"
Add-ToUserPath "$TOOLS\capa"
Add-ToUserPath "$TOOLS\chainsaw"
Add-ToUserPath "$TOOLS\cutter"
Add-ToUserPath "$TOOLS\DB Browser for SQLite"
Add-ToUserPath "$TOOLS\DidierStevens"
Add-ToUserPath "$TOOLS\die"
Add-ToUserPath "$TOOLS\elfparser-ng\Release"
Add-ToUserPath "$TOOLS\exiftool"
Add-ToUserPath "$TOOLS\fakenet"
Add-ToUserPath "$TOOLS\fasm"
Add-ToUserPath "$TOOLS\floss"
Add-ToUserPath "$TOOLS\FullEventLogView"
Add-ToUserPath "$TOOLS\gftrace64"
Add-ToUserPath "$TOOLS\GoReSym"
Add-ToUserPath "$TOOLS\hayabusa"
Add-ToUserPath "$TOOLS\imhex"
Add-ToUserPath "$TOOLS\INDXRipper"
Add-ToUserPath "$TOOLS\jd-gui"
Add-ToUserPath "$TOOLS\malcat\bin"
Add-ToUserPath "$TOOLS\lessmsi"
Add-ToUserPath "$TOOLS\nmap"
Add-ToUserPath "$TOOLS\node"
Add-ToUserPath "$TOOLS\systeminformer\x64"
Add-ToUserPath "$TOOLS\systeminformer\x86"
Add-ToUserPath "$TOOLS\pev"
Add-ToUserPath "$TOOLS\procdot\win64"
Add-ToUserPath "$TOOLS\pstwalker"
Add-ToUserPath "$TOOLS\qpdf\bin"
Add-ToUserPath "$TOOLS\radare2\bin"
Add-ToUserPath "$TOOLS\redress"
#Add-ToUserPath "$TOOLS\resource_hacker"
Add-ToUserPath "$TOOLS\ripgrep"
Add-ToUserPath "$TOOLS\scdbg"
Add-ToUserPath "$TOOLS\sqlite"
Add-ToUserPath "$TOOLS\ssview"
Add-ToUserPath "$TOOLS\sysinternals"
Add-ToUserPath "$TOOLS\thumbcacheviewer"
Add-ToUserPath "$TOOLS\trid"
Add-ToUserPath "$TOOLS\upx"
Add-ToUserPath "$TOOLS\WinApiSearch"
Add-ToUserPath "$TOOLS\WinObjEx64"
Add-ToUserPath "$TOOLS\XELFViewer"
Add-ToUserPath "$TOOLS\Zimmerman"
Add-ToUserPath "$TOOLS\Zimmerman\EvtxECmd"
Add-ToUserPath "$TOOLS\Zimmerman\EZViewer"
Add-ToUserPath "$TOOLS\Zimmerman\Hasher"
Add-ToUserPath "$TOOLS\Zimmerman\iisGeolocate"
Add-ToUserPath "$TOOLS\Zimmerman\JumpListExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\MFTExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\RECmd"
Add-ToUserPath "$TOOLS\Zimmerman\RegistryExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\SDBExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\ShellBagsExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\SQLECmd"
Add-ToUserPath "$TOOLS\Zimmerman\TimelineExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\XWFIM"
Add-ToUserPath "$TOOLS\zstd"
Add-ToUserPath "$HOME\Documents\tools\utils"

# Shortcut for PowerShell
Add-Shortcut -SourceLnk "$HOME\Desktop\PowerShell.lnk" -DestinationPath "$env:ProgramFiles\PowerShell\7\pwsh.exe" -WorkingDirectory "$HOME\Desktop"

# Copy tools
Copy-Item "$SETUP_PATH\BeaconHunter.exe" "$env:ProgramFiles\bin"
Copy-Item -Recurse -Force $TOOLS\4n4lDetector "$env:ProgramFiles"
Copy-Item -Recurse -Force $GIT\IDR "$env:ProgramFiles"

# Add jadx
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\jadx.zip" -o"$env:ProgramFiles\jadx"
Add-ToUserPath "$env:ProgramFiles\jadx\bin"

# Add x64dbg if specified
if ($WSDFIR_X64DBG -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\x64dbg.zip" -o"$env:ProgramFiles\x64dbg"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x32"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x64"
}

# Configure PowerShell logging
New-Item -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1 -Force

# Add cmder
if ($WSDFIR_CMDER -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cmder.7z" -o"$env:ProgramFiles\cmder"
    Add-ToUserPath "$env:ProgramFiles\cmder"
    Add-ToUserPath "$env:ProgramFiles\cmder\bin"
    Write-Output "$VENV\default\scripts\activate.bat" | Out-File -Append -Encoding "ascii" $env:ProgramFiles\cmder\config\user_profile.cmd
    & "$env:ProgramFiles\cmder\cmder.exe" /REGISTER ALL
}

# Add PersistenceSniper
if ($WSDFIR_PERSISTENCESNIPER -eq "Yes") {
    Import-Module $GIT\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1
}

# Add apimonitor
if ($WSDFIR_APIMONITOR -eq "Yes") {
    Copy-Item "$SETUP_PATH\apimonitor64.exe" "$TEMP"
    & $TEMP\apimonitor64.exe /s /v/qn
    Add-ToUserPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor"
}

# Configure usage of new venv for PowerShell
(Get-ChildItem -File $VENV\default\Scripts\).Name | findstr /R /V "[\._]" | findstr /V activate | `
    ForEach-Object {Write-Output "function $_() { python $VENV\default\Scripts\$_ `$PsBoundParameters.Values + `$args }"} | Out-File -Append -Encoding "ascii" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Signal that everything is done to start using the tools (mostly).
Update-Wallpaper "$SETUP_PATH\dfirws.jpg"

# Run install script for choco packages
if ($WSDFIR_CHOCO -eq "Yes") {
    & "$SETUP_PATH\choco\tools\chocolateyInstall.ps1"
    # Add packages below
}

# Setup Node.js
if ($WSDFIR_NODE -eq "Yes") {
    Copy-Item -r "$TOOLS\node" $HOME\Desktop
}

# Run custom scripts
if (Test-Path "$LOCAL_PATH\customize.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "$LOCAL_PATH\customize.ps1"
}

# Install extra tools for Git-bash
if ($WSDFIR_BASH_EXTRA -eq "Yes") {
    Set-Location "$env:ProgramFiles\Git"
    Get-ChildItem -Path $SETUP_PATH\bash -Include "*.tar" -Recurse |
        ForEach-Object {
            $command = "tar.exe -x -vf /C/downloads/bash/" + $_.Name
            &"$env:ProgramFiles\Git\bin\bash.exe" -c "$command"
        }
}

# Set Notepad++ as default for many file types
# Use %VARIABLE% in cmd.exe
cmd /c Ftype xmlfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype chmfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype cmdfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype htafile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype jsefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype jsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype vbefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype vbsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"

# Last commands
if (($WSDFIR_W10_LOOPBACK -eq "Yes") -and ($WIN10)) {
    & "$HOME\Documents\tools\utils\devcon.exe" install $env:windir\inf\netloop.inf *msloop
}

# Install Loki
if ($WSDFIR_LOKI -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\loki.zip" -o"$env:ProgramFiles\"
    Add-ToUserPath "$env:ProgramFiles\loki"
} else {
    New-Item -ItemType Directory "$env:ProgramFiles\loki"
}

# Clean up
Remove-Item $HOME\Desktop\PdfStreamDumper.exe.lnk

# Create directory for shortcuts to installed tools
New-Item -ItemType Directory "$HOME\Desktop\dfirws"
# $TOOLS\DidierStevens
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\DidierStevens.lnk" -DestinationPath "$TOOLS\DidierStevens"

# Editors
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Editors"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Bytecode Viewer.lnk" -DestinationPath "$TOOLS\bin\bcv.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\HxD.lnk" -DestinationPath "$env:ProgramFiles\HxD\HxD.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\ImHex.lnk" -DestinationPath "C:Tools\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Malcat.lnk" -DestinationPath "$TOOLS\Malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Notepad++.lnk" -DestinationPath "$env:ProgramFiles\Notepad++\notepad++.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Visual Studio Code.lnk" -DestinationPath "$HOME\AppData\Local\Programs\Microsoft VS Code\Code.exe"

# File and apps
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\binlex.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\bulk_extractor64.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\densityscout.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Detect It Easy.lnk" -DestinationPath "$TOOLS\die\die.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\fq.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\lessmsi-gui.lnk" -DestinationPath "$TOOLS\lessmsi\lessmsi-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\ripgrep (rg).lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\trid.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Browser"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\hindsight.lnk" -DestinationPath "$TOOLS\bin\hindsight_gui.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Database"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\DB Browser for SQLite.lnk" -DestinationPath "$TOOLS\DB Browser for SQLite\DB Browser for SQLite.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\ese2csv.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\fqlite.lnk" -DestinationPath "$TOOLS\fqlite\run.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\SQLECmd.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\Zimmerman\SQLECmd\SQLECmd.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\sqlite3.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\sqlite\sqlite3.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\SQLiteWalker.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Disk"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Disk\INDXRipper.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\INDXRipper\INDXRipper.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Log"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\chainsaw.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\Events-Ripper.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\FullEventLogView.lnk" -DestinationPath "$TOOLS\FullEventLogView\FullEventLogView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\hayabusa.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\Microsoft LogParser (LogParser).lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\PowerSiem.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Office and email"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\Mbox Viewer.lnk" -DestinationPath "$TOOLS\mboxviewer\mboxview64.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\MetadataPlus.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\bin\MetadataPlus.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\mraptor.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\msgviewer.lnk" -DestinationPath "$TOOLS\lib\msgviewer.jar"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\msodde.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\oledump.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\oleid.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\olevba.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\msgviewer.lnk" -DestinationPath "$TOOLS\pstwalker\pstwalker.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\rtfdump.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\rtfobj.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\Structured Storage Viewer (SSView).lnk" -DestinationPath "$TOOLS\ssview\SSView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\tree.com.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\zipdump.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\PDF"
if ($WSDFIR_PDFSTREAM -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\pdfstreamdumper.lnk" -DestinationPath "$PDFSTREAMDUMPER\PDFStreamDumper.exe"
}
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\pdf-parser.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\pdfid.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\peepdf.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\qpdf.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\PE"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\4n4lDetector.lnk" -DestinationPath "$env:ProgramFiles\4n4lDetector\4N4LDetector.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\capa.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\capa\capa.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\Debloat.lnk" -DestinationPath "$TOOLS\bin\debloat.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\dll_to_exe.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\hollows_hunter.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\bin\hollows_hunter.exe
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pe2pic.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
#Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pe2shc.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\bin\pe2shc.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\PE-bear.lnk" -DestinationPath "$TOOLS\pebear\PE-bear.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\PE-sieve.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\bin\pe-sieve.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pestudio.lnk" -DestinationPath "$TOOLS\pestudio\pestudio\pestudio.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pescan.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$TOOLS\pev"
#Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\Resource Hacker.lnk" -DestinationPath "$TOOLS\resource_hacker\ResourceHacker.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\shellconv.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\WinObjEx64.lnk" -DestinationPath "$TOOLS\WinObjEx64\WinObjEx64.exe"

# Incident response
New-Item -ItemType Directory "$HOME\Desktop\dfirws\IR"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\IR\Trawler.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# Malware tools
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Malware tools"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\1768.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk" -DestinationPath "$env:ProgramFiles\bin\BeaconHunter.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# Network
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Network"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Network\Fakenet.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\fakenet\fakenet.exe"

# OS
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Android"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Android\apktool.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Linux"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Linux\elfparser-ng.lnk" -DestinationPath "$TOOLS\elfparser-ng\Release\elfparser-ng.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Linux\xelfviewer.lnk" -DestinationPath "$TOOLS\XELFViewer\xelfviewer.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\macOS"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\macOS\dsstore.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$GIT\Python-dsstore"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\macOS\machofile-cli.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Windows"
if ($WSDFIR_APIMONITOR -eq "Yes") {
    Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\apimonitor-x86.lnk" -DestinationPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor\apimonitor-x86.exe"
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\apimonitor-x64.lnk" -DestinationPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor\apimonitor-x64.exe"
}
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk" -DestinationPath "$TOOLS\bin\JumplistBrowser.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk" -DestinationPath "$TOOLS\bin\PrefetchBrowser.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\procdot.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\sidr.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk" -DestinationPath "$TOOLS\thumbcacheviewer\thumbcache_viewer.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Windows\Registry"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Registry\Registry Explorer.lnk" -DestinationPath "$TOOLS\Zimmerman\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Registry\RegRipper (rip).lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# Programming
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\java.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\node.lnk" -DestinationPath "$TOOLS\node\node.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Python.lnk" -DestinationPath "$VENV\default\Scripts\python.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\Delphi"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Delphi\idr.lnk" -DestinationPath "$env:ProgramFiles\idr\bin\Idr.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\Go"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Go\gftrace.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Go\GoReSym.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\Java"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\jadx-gui.lnk" -DestinationPath "$env:ProgramFiles\jadx\bin\jadx-gui.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\jd-gui.lnk" -DestinationPath "$TOOLS\jd-gui\jd-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\recaf.lnk" -DestinationPath "$TOOLS\bin\recaf.bat"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\PowerShell"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\PowerShell\PowerDecode.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$GIT\PowerDecode"

# Reverse Engineering
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Reverse Engineering"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\Cutter.lnk" -DestinationPath "$TOOLS\cutter\cutter.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk" -DestinationPath "$TOOLS\dnSpy32\dnSpy.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk" -DestinationPath "$TOOLS\dnSpy64\dnSpy.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\fasm.lnk" -DestinationPath "$TOOLS\fasm\FASM.EXE"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\Ghidra.lnk" -DestinationPath "$TOOLS\ghidra\ghidraRun.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\radare2.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\scare.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
if ($WSDFIR_X64DBG -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\x32dbg.lnk" -DestinationPath "$env:ProgramFiles\x64dbg\release\x32\x32dbg.exe"
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\x64dbg.lnk" -DestinationPath "$env:ProgramFiles\x64dbg\release\x64\x64dbg.exe"
}

# Signatures and information
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Signatures and information"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Signatures and information\Online tools"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\Online tools\vt.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\evt2sigma.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\loki.lnk" -DestinationPath "$env:ProgramFiles\loki\loki.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\PatchaPalooza.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$GIT\PatchaPalooza"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\WinApiSearch64.lnk" -DestinationPath "$TOOLS\WinApiSearch\WinApiSearch64.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\yara.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# "$HOME\Desktop\dfirws\Sysinternals"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Sysinternals.lnk" -DestinationPath "$TOOLS\sysinternals"

# Utilities
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Utilities"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\7-Zip.lnk" -DestinationPath "$env:ProgramFiles\7-Zip\7zFM.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\bash.lnk" -DestinationPath "$env:ProgramFiles\Git\bin\bash.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\cmder.lnk" -DestinationPath "$env:ProgramFiles\cmder\cmder.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\CyberChef.lnk" -DestinationPath "$TOOLS\CyberChef\CyberChef.html"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\exiftool.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\exiftool\exiftool.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\floss.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\floss\floss.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\git.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$env:ProgramFiles\Git\cmd\git-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Graphviz.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\upx.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\zstd.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# "$HOME\Desktop\dfirws\Zimmerman"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Zimmerman.lnk" -DestinationPath "$TOOLS\Zimmerman"

# Pin to explorer
$shell = new-object -com "Shell.Application"
$folder = $shell.Namespace("$HOME\Desktop")
$item = $folder.Parsename('dfirws')
$verb = $item.Verbs() | Where-Object { $_.Name -eq 'Pin to Quick access' }
if ($verb) {
    $verb.DoIt()
}

$pwsh = $shell.Namespace("$env:ProgramFiles\PowerShell\7")
$pwshitem = $pwsh.Parsename('pwsh.exe')
$pwshverb = $pwshitem.Verbs() | Where-Object { $_.Name -eq '&Pin to Start' }
if ($pwshverb) {
    $pwshverb.DoIt()
}

# TODO
# Links to
# - pip tools
# - node tools

& $SETUP_PATH\graphviz.exe /S /D='$env:ProgramFiles\graphviz'
Add-ToUserPath "$env:ProgramFiles\graphviz\bin"

# Add plugins to Cutter
New-Item -ItemType Directory -Force -Path "$HOME\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item $GIT\radare2-deep-graph\cutter\graphs_plugin_grid.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item $SETUP_PATH\x64dbgcutter.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item $GIT\cutterref\cutterref.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse $GIT\cutterref\archs "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse $GIT\cutter-jupyter\icons "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse $GIT\capa-explorer\capa_explorer_plugin "$HOME\AppData\Roaming\rizin\cutter\plugins\python"

# Unzip signatures for loki and yara
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "$SETUP_PATH\signature.7z" -o"$env:ProgramFiles\loki"
Remove-Item "$env:ProgramFiles\loki\signature.yara"
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "$SETUP_PATH\signature.7z" -o"$DATA"
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "$SETUP_PATH\total.7z" -o"$DATA"

# Start sysmon when installation is done
if ($WSDFIR_SYSMON -eq "Yes") {
    & "$TOOLS\sysinternals\Sysmon64.exe" -accepteula -i "$WSDFIR_SYSMON_CONF"
}

# Start Gollum for local wiki
netsh firewall set opmode DISABLE 2>&1 | Out-Null
Start-Process "$env:ProgramFiles\Amazon Corretto\jdk*\bin\java.exe" -argumentlist "-jar $TOOLS\lib\gollum.war -S gollum $GIT\dfirws.wiki" -WindowStyle Hidden

# Don't ask about new apps
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t REG_DWORD /d 1

# Add shortcuts to desktop for Jupyter and Gollum
Add-Shortcut -SourceLnk "$HOME\Desktop\jupyter.lnk" -DestinationPath "$HOME\Documents\tools\utils\jupyter.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws wiki.lnk" -DestinationPath "$HOME\Documents\tools\utils\gollum.bat"
