# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$GHIDRA_INSTALL_DIR = (Get-ChildItem C:\Tools\ghidra\ | Select-String PUBLIC -Raw | Select-Object -Last 1)


. C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1

if (! (Test-Path "${TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${TEMP}" | Out-Null
}

Write-Output "Get-Content C:\log\python.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Python in Sandbox." >> "C:\log\python.txt"
$PYTHON_BIN="$env:ProgramFiles\Python311\python.exe"
Start-Process "${SETUP_PATH}\python3.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
Get-Job | Receive-Job 2>&1 >> "C:\log\python.txt"

# Source config.ps1
. C:\venv\default\config.ps1

#
# venv default
#
Write-DateLog "Install packages in venv default in sandbox." >> "C:\log\python.txt"
Get-ChildItem C:\venv\default\* -Exclude config.ps1 -Recurse | Remove-Item -Force 2>&1 | Out-null
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\default"
C:\venv\default\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\default\"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U poetry >> "C:\log\python.txt"
# TODO: Get latest version of package
python -m pip install https://github.com/msuhanov/dfir_ntfs/archive/1.1.18.tar.gz >> "C:\log\python.txt"

poetry init `
    --name default `
    --description "Default Python venv for dfirws." `
    --author "dfirws" `
    --license "MIT" `
    --no-interaction >> "C:\log\python.txt"

# Install packages with poetry
poetry add `
    aiohttp[speedups] `
    autoit-ripper `
    beautifulsoup4>=4.12.1 `
    binary-refinery `
    cabarchive `
    capstone `
    cart `
    certifi>=2023.5.7 `
    colorama `
    cryptography>=41.0.1 `
    deep_translator `
    Deprecated>=1.2.13 `
    dnslib `
    dnspython>=2.4.1 `
    docx2txt `
    dotnetfile `
    dpkt `
    elasticsearch[async] `
    elastic_transport>=8.1.2 `
    evtx `
    extract-msg `
    Flask>=2.3.1 `
    folium>=0.13.0 `
    fonttools `
    frida `
    frida-tools `
    geoip2>=4.6.0 `
    ghidriff `
    graphviz `
    grip `
    hachoir `
    httpx>=0.25.1 `
    httpcore>=0.18.0 `
    ijson `
    ipython>=8.18.0 `
    ipywidgets `
    jedi>=0.19.0 `
    jinja2 `
    jsbeautifier `
    jupyterlab `
    keyring>=23.13.1 `
    keystone-engine `
    lief>=0.13.2 `
    LnkParse3 `
    lxml `
    Markdown>=3.5 `
    matplotlib `
    maxminddb>=2.5.0 `
    minidump `
    msal>=1.24.1 `
    msticpy `
    mkyara `
    msgpack `
    msoffcrypto-tool `
    name-that-hash `
    neo4j `
    neo4j-driver `
    netaddr `
    networkx `
    numpy `
    olefile `
    oletools[full]>=0.60.1 `
    openpyxl `
    orjson `
    pandas `
    pcode2code `
    pcodedmp `
    pefile `
    peutils `
    pillow `
    ppdeep `
    prettytable>=3.5 `
    prompt_toolkit>=3.0.35 `
    protobuf>=4.22.0 `
    protodeep `
    ptpython>=3.0.23 `
    pycryptodome `
    pycryptodomex>=3.17.0 `
    pydantic>=2.5.1 `
    pyelftools `
    pyjwt>=2.7.0 `
    pyOneNote `
    pyparsing>=2.4.6 `
    pypdf>=3.17.1 `
    pypng `
    python-dateutil `
    python-magic `
    python-magic-bin `
    pyvis `
    pywin32-ctypes>=0.2.1 `
    pywin32 `
    pywinpty>=2.0.11 `
    PyYAML>=6.0 `
    pyzipper `
    pyzmq>=25.1.0 `
    regipy `
    requests `
    rpds_py>=0.10.5 `
    rzpipe `
    setuptools `
    termcolor>=2.2.0 `
    terminado>=0.17.1 `
    textsearch `
    time-decode `
    tldextract>=5.1.0 `
    tomlkit `
    tqdm `
    treelib `
    tzdata>=2023.1 `
    tzlocal>=5.1 `
    unicorn `
    unpy2exe `
    urllib3>=2.1.0 `
    visidata>=2.11 `
    xlrd>=2.0.0 `
    XLMMacroDeobfuscator>=0.2.6 `
    XlsxWriter>=3.1.8 `
    xxhash>=3.3.0 `
    yara-python >> "C:\log\python.txt"

# Not compatible with Python 3.11:
#     regipy[full]>=3.1.6 - https://github.com/astanin/python-tabulate

Write-DateLog "Install extra scripts in venv." >> "C:\log\python.txt"
Set-Location "C:\venv\default\Scripts"
curl -o "machofile-cli.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile-cli.py"
curl -o "machofile.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile.py"
curl -o "msidump.py" "https://raw.githubusercontent.com/mgeeky/msidump/main/msidump.py"
curl -o "parseUSBs.py" "https://raw.githubusercontent.com/khyrenz/parseusbs/main/parseUSBs.py"
curl -o "shellconv.py" "https://raw.githubusercontent.com/hasherezade/shellconv/master/shellconv.py"
curl -o "smtpsmug.py" "https://raw.githubusercontent.com/hannob/smtpsmug/main/smtpsmug"
curl -o "SQLiteWalker.py" "https://raw.githubusercontent.com/stark4n6/SQLiteWalker/main/SQLiteWalker.py"
curl -o "CanaryTokenScanner.py" "https://raw.githubusercontent.com/0xNslabs/CanaryTokenScanner/main/CanaryTokenScanner.py"

if (Test-Path "C:\git\bmc-tools\bmc-tools.py") {
    Copy-Item "C:\git\bmc-tools\bmc-tools.py" "C:\venv\default\Scripts\bmc-tools.py"
}

if (Test-Path "C:\git\dotnetfile\examples\dotnetfile_dump.py") {
    Copy-Item "C:\git\dotnetfile\examples\dotnetfile_dump.py" "C:\venv\default\Scripts\dotnetfile_dump.py"
}

foreach ($iShutdown in @("iShutdown_detect.py", "iShutdown_parse.py", "iShutdown_stats.py")) {
    if (Test-Path "C:\git\iShutdown\$iShutdown") {
        Copy-Item "C:\git\iShutdown\$iShutdown" "C:\venv\default\Scripts\$iShutdown"
    }
}

(Get-Content .\parseUSBs.py -raw) -replace "#!/bin/python","#!/usr/bin/env python" | Set-Content -Path ".\parseUSBs2.py"
Copy-Item parseUSBs2.py parseUSBs.py
Remove-Item parseUSBs2.py

New-Item -ItemType Directory C:\tmp\rename 2>&1 | Out-null
Get-ChildItem C:\venv\default\Scripts\ -Exclude *.exe,*.py,*.ps1,activate,__pycache__,*.bat | ForEach-Object { Move-Item $_ C:\tmp\rename }
Set-Location C:\tmp\rename
Get-ChildItem | Rename-Item -newname  { $_.Name +".py" }
Copy-Item * C:\venv\default\Scripts
deactivate
Write-DateLog "Python venv default done." >> "C:\log\python.txt"


#
# venv jep
#

if ($INSTALL_JEP -eq "Yes") {
    #
    # venv jep and tools needed for jep
    #

    # Check if jep or ghidrathon has been updated
    & "$PYTHON_BIN" -m pip index versions jep 2>&1 | findstr "Available versions:" | ForEach-Object { $_.split(" ")[2] } | ForEach-Object { $_.split(",")[0] } | Select-Object -Last 1 > ${TEMP}\jep.txt
    ((curl.exe --silent -L "https://api.github.com/repos/mandiant/Ghidrathon/releases/latest" | ConvertFrom-Json).zipball_url.ToString()).Split("/")[-1] >> ${TEMP}\jep.txt
    $GHIDRA_INSTALL_DIR >> ${TEMP}\jep.txt

    if (Test-Path "C:\venv\jep\jep.txt") {
        $CURRENT_VENV = "C:\venv\jep\jep.txt"
    } else {
        $CURRENT_VENV = "C:\Progress.ps1"
    }

    if ((Get-FileHash C:\tmp\jep.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
        Write-DateLog "jep or ghidrathon has been updated. Update jep." >> "C:\log\python.txt"

        # Install Visual Studio Build Tools for jep
        Write-DateLog "Start installation of Visual Studio Build Tools." 2>&1 >> "C:\log\python.txt"
        Copy-Item "${SETUP_PATH}\vs_BuildTools.exe" "${TEMP}\vs_BuildTools.exe"
        Set-Location ${TEMP}
        Start-Process -Wait ".\vs_BuildTools.exe" -ArgumentList "-p --norestart --force --installWhileDownloading --add Microsoft.VisualStudio.Product.BuildTools --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows11SDK.22000 --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --installPath C:\BuildTools"
        Get-Job | Receive-Job 2>&1 >> "C:\log\python.txt"
        & 'C:\BuildTools\Common7\Tools\VsDevCmd.bat' 2>&1 >> "C:\log\python.txt"

        # Install Java for jep
        Write-DateLog "Start installation of Corretto Java." 2>&1 >> "C:\log\python.txt"
        Copy-Item "${SETUP_PATH}\corretto.msi" "${TEMP}\corretto.msi"
        Start-Process -Wait msiexec -ArgumentList "/i ${TEMP}\corretto.msi /qn /norestart"
        Get-Job | Receive-Job 2>&1 >> "C:\log\python.txt"
        $env:JAVA_HOME="C:\Program Files\Amazon Corretto\"+(Get-ChildItem 'C:\Program Files\Amazon Corretto\').Name

        # jep venv
        Get-ChildItem C:\venv\jep\* -Exclude jep.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
        Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv --system-site-packages C:\venv\jep"
        C:\venv\jep\Scripts\Activate.ps1 >> "C:\log\python.txt"
        Set-Location "C:\venv\jep"
        python -m pip install -U pip >> "C:\log\python.txt"
        python -m pip install -U poetry 2>&1 >> "C:\log\python.txt"

        poetry init `
            --name jepvenv `
            --description "Python venv for jep." `
            --author "dfirws" `
            --license "MIT" `
            --no-interaction

        poetry add `
            NumPy `
            flare-capa >> "C:\log\python.txt"

        # Build Ghidrathon for Gidhra
        Write-DateLog "Build Ghidrathon for Ghidra."
        Copy-Item -Recurse "C:\Tools\ghidrathon" "${TEMP}"
        Set-Location "${TEMP}\ghidrathon"
        & "$TOOLS\gradle\bin\gradle.bat" -PGHIDRA_INSTALL_DIR="$GHIDRA_INSTALL_DIR" -PPYTHON_BIN="C:\venv\jep\Scripts\python.exe" >> "C:\log\python.txt"
        if (! (Test-Path "C:\Tools\ghidra_extensions")) {
            New-Item -ItemType Directory -Force -Path "C:\Tools\ghidra_extensions" | Out-Null
        }
        Copy-Item ${TEMP}\ghidrathon\dist\ghidra* "C:\Tools\ghidra_extensions\ghidrathon.zip" 2>&1 >> "C:\log\python.txt"
        Copy-Item ${TEMP}\jep.txt "C:\venv\jep\jep.txt" -Force 2>&1 >> "C:\log\python.txt"
        deactivate
        Write-DateLog "Python venv jep done." >> "C:\log\python.txt"
    } else {
        Write-DateLog "Neither jep or ghidrathon has been updated, don't build jep." >> "C:\log\python.txt"
    }
}


#
# venv dfir-unfurl
#
& "$PYTHON_BIN" -m pip index versions dfir-unfurl 2>&1 | findstr "Available versions:" | ForEach-Object { $_.split(" ")[2] } | ForEach-Object { $_.split(",")[0] } | Select-Object -Last 1 > ${TEMP}\dfir-unfurl.txt

if (Test-Path "C:\venv\dfir-unfurl\dfir-unfurl.txt") {
    $CURRENT_VENV = "C:\venv\dfir-unfurl\dfir-unfurl.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\dfir-unfurl.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv dfir-unfurl in sandbox (needs older packages)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\dfir-unfurl\* -Exclude dfir-unfurl.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\dfir-unfurl"
    C:\venv\dfir-unfurl\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\dfir-unfurl"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U poetry >> "C:\log\python.txt"

    poetry init `
        --name dfir-unfurlvenv `
        --description "Python venv for dfir-unfurl." `
        --author "dfirws" `
        --license "MIT" `
        --no-interaction

    poetry add `
        dfir-unfurl `
        hexdump `
        tomlkit >> "C:\log\python.txt"

    # Download each file and update the base.html content with the local path
    $baseHtmlPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\templates\base.html"
    $baseHtmlContent = Get-Content $baseHtmlPath -Raw
    $urls = [regex]::Matches($baseHtmlContent, 'https://cdnjs.cloudflare.com[^"]+')
    foreach ($url in $urls) {
        $fileName = $url.Value.Split("/")[-1]
        $staticPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\static\$fileName"
        Write-DateLog "Downloading $url.Value to $staticPath." >> "C:\log\python.txt"
        Invoke-WebRequest -Uri $url.Value -OutFile $staticPath
        $baseHtmlContent = $baseHtmlContent.Replace($url.Value, "/static/$fileName")
    }
    Set-Content -Path $baseHtmlPath -Value $baseHtmlContent
    Copy-Item ${TEMP}\dfir-unfurl.txt "C:\venv\dfir-unfurl\dfir-unfurl.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Set-Content "C:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_app.py" -Encoding Ascii -Path C:\venv\default\Scripts\unfurl_app.ps1
    Set-Content "C:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_cli.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\unfurl_cli.ps1
    Write-DateLog "Python venv dfir-unfurl cache done." >> "C:\log\python.txt"
} else {
    Write-DateLog "dfir-unfurl has not been updated, don't update dfir-unfurl venv." >> "C:\log\python.txt"
}


#
# venv pySigma
#

& "$PYTHON_BIN" -m pip index versions pySigma 2>&1 | findstr "Available versions:" | ForEach-Object { $_.split(" ")[2] } | ForEach-Object { $_.split(",")[0] } | Select-Object -Last 1 > ${TEMP}\pySigma.txt

if (Test-Path "C:\venv\pySigma\pySigma.txt") {
    $CURRENT_VENV = "C:\venv\pySigma\pySigma.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\pySigma.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv pySigma in sandbox (needs older packages that conflicts with oletools)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\pySigma\* -Exclude pySigma.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\pySigma"
    C:\venv\pySigma\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\pySigma"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U poetry >> "C:\log\python.txt"

    poetry init `
        --name pySigmavenv `
        --description "Python venv for pySigma." `
        --author "dfirws" `
        --license "MIT" `
        --no-interaction

    poetry add `
        pySigma>=0.9.6 2>&1 >> "C:\log\python.txt"

    Copy-Item ${TEMP}\pySigma.txt "C:\venv\pySigma\pySigma.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv pySigma done." >> "C:\log\python.txt"
} else {
    Write-DateLog "pySigma has not been updated, don't update pySigma venv." >> "C:\log\python.txt"
}


#
# venv pe2pic
#
Set-Location "C:\tmp"

curl -o "pe2pic.py" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/pe2pic.py"
curl -o "pe2pic_requirements.txt" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/requirements.txt"

Get-FileHash -Path "pe2pic.py" -Algorithm SHA256 | Select-Object -ExpandProperty Hash > "C:\tmp\pe2pic.txt"
Get-FileHash -Path "pe2pic_requirements.txt" -Algorithm SHA256 | Select-Object -ExpandProperty Hash >> "C:\tmp\pe2pic.txt"

if (Test-Path "C:\venv\pe2pic\pe2pic.txt") {
    $CURRENT_VENV = "C:\venv\pe2pic\pe2pic.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\pe2pic.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv pe2pic in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\pe2pic\* -Exclude pe2pic.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\pe2pic"
    C:\venv\pe2pic\Scripts\Activate.ps1 >> "C:\log\python.txt"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U setuptools wheel >> "C:\log\python.txt"
    python -m pip install -r "C:\tmp\pe2pic_requirements.txt" 2>&1 >> "C:\log\python.txt"
    Copy-Item "C:\tmp\pe2pic.py" "C:\venv\pe2pic\Scripts\pe2pic.py"
    Copy-Item "C:\tmp\pe2pic.txt" "C:\venv\pe2pic\pe2pic.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Set-Content "C:\venv\pe2pic\Scripts\python.exe C:\venv\pe2pic\Scripts\pe2pic.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\pe2pic.ps1
    Write-DateLog "Python venv pe2pic done." >> "C:\log\python.txt"
} else {
    Write-DateLog "pe2pic has not been updated, don't update pe2pic venv." >> "C:\log\python.txt"
}


#
# venv evt2sigma
#
Set-Location "C:\tmp"

curl -o "evt2sigma.py" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/evt2sigma.py"
curl -o "evt2sigma_requirements.txt" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/requirements.txt"

Get-FileHash -Path "evt2sigma.py" -Algorithm SHA256 | Select-Object -ExpandProperty Hash > "C:\tmp\evt2sigma.txt"
Get-FileHash -Path "evt2sigma_requirements.txt" -Algorithm SHA256 | Select-Object -ExpandProperty Hash >> "C:\tmp\evt2sigma.txt"

if (Test-Path "C:\venv\evt2sigma\evt2sigma.txt") {
    $CURRENT_VENV = "C:\venv\evt2sigma\evt2sigma.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\evt2sigma.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv evt2sigma in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\evt2sigma\* -Exclude evt2sigma.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\evt2sigma"
    C:\venv\evt2sigma\Scripts\Activate.ps1 >> "C:\log\python.txt"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U setuptools wheel >> "C:\log\python.txt"
    python -m pip install -r "C:\tmp\evt2sigma_requirements.txt" 2>&1 >> "C:\log\python.txt"
    Copy-Item "C:\tmp\evt2sigma.py" "C:\venv\evt2sigma\Scripts\evt2sigma.py"
    Set-Content "C:\venv\evt2sigma\Scripts\python.exe C:\venv\evt2sigma\Scripts\evt2sigma.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\evt2sigma.ps1
    Copy-Item "C:\tmp\evt2sigma.txt" "C:\venv\evt2sigma\evt2sigma.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv evt2sigma done." >> "C:\log\python.txt"
} else {
    Write-DateLog "evt2sigma has not been updated, don't update evt2sigma venv." >> "C:\log\python.txt"
}


#
# venv maldump
#

if (! (Test-Path "C:\venv\maldump\Scripts\maldump.exe")) {
    Write-DateLog "Install packages in venv maldump in sandbox (needs specific version of packages)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\maldump\* -Exclude maldump.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\maldump"
    C:\venv\maldump\Scripts\Activate.ps1 >> "C:\log\python.txt"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U setuptools wheel >> "C:\log\python.txt"
    python -m pip install -r https://raw.githubusercontent.com/NUKIB/maldump/v0.2.0/requirements.txt 2>&1 >> "C:\log\python.txt"
    python -m pip install maldump==0.2.0 2>&1 >> "C:\log\python.txt"
    Copy-Item "C:\tmp\maldump.txt" "C:\venv\maldump\maldump.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\maldump\Scripts\Activate.ps1" -Encoding Ascii -Path C:\venv\default\Scripts\maldump.ps1
    Write-DateLog "Python venv maldump done." >> "C:\log\python.txt"
} else {
    Write-DateLog "maldump already installed." >> "C:\log\python.txt"
}

#
# venv scare
#
if (Test-Path "C:\venv\scare\scare\.git\ORIG_HEAD") {
    $CURRENT_VENV = "C:\venv\scare\scare\.git\ORIG_HEAD"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\git\scare\.git\ORIG_HEAD).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv scare in sandbox (needs specific version of packages)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\scare\* -Exclude scare.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\scare"
    C:\venv\scare\Scripts\Activate.ps1 >> "C:\log\python.txt"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U ptpython setuptools wheel >> "C:\log\python.txt"
    Copy-Item -Recurse "C:\git\scare" "C:\venv\scare"
    Set-Location "C:\venv\scare\scare"
    (Get-Content .\requirements.txt -raw) -replace "capstone","capstone`npyreadline3" | Set-Content -Path ".\requirements2.txt" -Encoding ascii
    python -m pip install -r ./requirements2.txt 2>&1 >> "C:\log\python.txt"
    (Get-Content .\scarelib.py -raw) -replace "print\(splash\)","splash = 'Simple Configurable Asm REPL && Emulator'`n    print(splash)" | Set-Content -Path ".\scarelib2.py" -Encoding ascii
    Copy-Item scarelib2.py scarelib.py
    Remove-Item scarelib2.py
    Copy-Item C:\venv\scare\scare\*.py "C:\venv\scare\Scripts"
    Copy-Item C:\tmp\scare.txt "C:\venv\scare\scare.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Set-Content "cd C:\venv\scare\scare && C:\venv\scare\Scripts\ptpython.exe C:\venv\scare\scare\scare.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\scare.ps1
    Write-DateLog "Python venv scare done." >> "C:\log\python.txt"
} else {
    Write-DateLog "scare already up to date." >> "C:\log\python.txt"
}


#
# venv Zircolite
#

if (Test-Path "C:\venv\Zircolite\Zircolite\.git\ORIG_HEAD") {
    $CURRENT_VENV = "C:\venv\Zircolite\Zircolite\.git\ORIG_HEAD"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\git\Zircolite\.git\ORIG_HEAD).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv Zircolite in sandbox (needs specific version of packages)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\Zircolite\* -Exclude Zircolite.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\Zircolite"
    C:\venv\Zircolite\Scripts\Activate.ps1 >> "C:\log\python.txt"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U ptpython setuptools wheel 2>&1 >> "C:\log\python.txt"
    Copy-Item -Recurse "C:\git\Zircolite" "C:\venv\Zircolite"
    Set-Location "C:\venv\Zircolite\Zircolite"
    python -m pip install -r requirements.txt 2>&1 >> "C:\log\python.txt"
S    deactivate
    Set-Content "C:\venv\Zircolite\Scripts\ptpython.exe C:\venv\Zircolite\Zircolite\zircolite.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\zircolite.ps1
    Write-DateLog "Python venv Zircolite done." >> "C:\log\python.txt"
} else {
    Write-DateLog "Zircolite already up to date." >> "C:\log\python.txt"
}


#
# venv chepy
#

& "$PYTHON_BIN" -m pip index versions chepy 2>&1 | findstr "Available versions:" | ForEach-Object { $_.split(" ")[2] } | ForEach-Object { $_.split(",")[0] } | Select-Object -Last 1 > ${TEMP}\chepy.txt

if (Test-Path "C:\venv\chepy\chepy.txt") {
    $CURRENT_VENV = "C:\venv\chepy\chepy.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\chepy.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv chepy in sandbox (needs specific version of packages)." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\chepy\* -Exclude chepy.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\chepy"
    C:\venv\chepy\Scripts\Activate.ps1 >> "C:\log\python.txt"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U setuptools wheel 2>&1 >> "C:\log\python.txt"
    python -m pip install `
        chepy[extras] 2>&1 >> "C:\log\python.txt"
    Copy-Item C:\tmp\chepy.txt "C:\venv\chepy\chepy.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Set-Content "C:\venv\chepy\Scripts\python.exe C:\venv\chepy\Scripts\chepy.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\chepy.ps1
    Write-DateLog "Python venv chepy done." >> "C:\log\python.txt"
} else {
    Write-DateLog "chepy has not been updated, don't update chepy venv." >> "C:\log\python.txt"
}


#
# venv dissect
#

# Build every time because of to many dependencies to check in dissect.target
Write-DateLog "Install packages in venv dissect in sandbox (needs specific version of packages)." >> "C:\log\python.txt"
Get-ChildItem C:\venv\dissect\* -Exclude dissect.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\dissect"
C:\venv\dissect\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U poetry >> "C:\log\python.txt"

poetry init `
    --name dissectvenv `
    --description "Python venv for dissect." `
    --author "dfirws" `
    --license "MIT" `
    --no-interaction

poetry add `
    acquire `
    dissect `
    dissect.target[yara] `
    flow.record >> "C:\log\python.txt"

deactivate
Write-DateLog "Python venv dissect done." >> "C:\log\python.txt"

#
# venv ghidrecomp
#

& "$PYTHON_BIN" -m pip index versions ghidrecomp 2>&1 | findstr "Available versions:" | ForEach-Object { $_.split(" ")[2] } | ForEach-Object { $_.split(",")[0] } | Select-Object -Last 1 > ${TEMP}\ghidrecomp.txt

if (Test-Path "C:\venv\ghidrecomp\ghidrecomp.txt") {
    $CURRENT_VENV = "C:\venv\ghidrecomp\ghidrecomp.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\ghidrecomp.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install ghidrecomp in venv ghidrecomp in sandbox." >> "C:\log\python.txt"
    Get-ChildItem C:\venv\ghidrecomp\* -Exclude ghidrecomp.txt -Recurse | Remove-Item -Force 2>&1 | Out-null
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\ghidrecomp"
    C:\venv\ghidrecomp\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\ghidrecomp"
    python -m pip install -U pip >> "C:\log\python.txt"
    python -m pip install -U poetry >> "C:\log\python.txt"

    poetry init `
        --name ghidrecompvenv `
        --description "Python venv for ghidrecomp." `
        --author "dfirws" `
        --license "MIT" `
        --no-interaction

    poetry add `
        ghidrecomp 2>&1 >> "C:\log\python.txt"

    Copy-Item ${TEMP}\ghidrecomp.txt "C:\venv\ghidrecomp\ghidrecomp.txt" -Force 2>&1 >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv ghidrecomp done." >> "C:\log\python.txt"
} else {
    Write-DateLog "ghidrecomp has not been updated, don't update ghidrecomp venv." >> "C:\log\python.txt"
}

Write-Output "" > C:\venv\default\done