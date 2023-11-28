param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH = Resolve-Path "$ScriptRoot\..\..\"

$SETUP_PATH="$ROOT_PATH\downloads"

. $ScriptRoot\common.ps1

Write-DateLog "Start Sandbox to install Python pip packages for dfirws." > $ROOT_PATH\log\python.txt

$mutexName = "Global\dfirwsMutex"
$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (! (Test-Path -Path $ROOT_PATH\tmp\venv )) {
    New-Item -ItemType Directory -Force -Path $ROOT_PATH\tmp\venv > $null
}

if (Test-Path -Path $ROOT_PATH\tmp\venv\done ) {
    Remove-Item $ROOT_PATH\tmp\venv\done > $null
}

(Get-Content $ROOT_PATH\resources\templates\generate_venv.wsb.template).replace('__SANDBOX__', $ROOT_PATH) | Set-Content $ROOT_PATH\tmp\generate_venv.wsb

$mutex.WaitOne() | Out-Null
& $ROOT_PATH\tmp\generate_venv.wsb
Start-Sleep 10
Remove-Item $ROOT_PATH\tmp\generate_venv.wsb | Out-Null

Stop-SandboxWhenDone "$ROOT_PATH\tmp\venv\done" $mutex | Out-Null

rclone.exe sync --verbose --checksum "$ROOT_PATH\tmp\venv" "$ROOT_PATH\mount\venv"
Remove-Item -Recurse -Force "$ROOT_PATH\tmp\venv" > $null 2>&1

& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$ROOT_PATH\mount\venv\jep\dist\ghidrathon.zip" -o"$TOOLS\ghidra\Extensions" | Out-Null
Copy-Item $SETUP_PATH\*.py "$ROOT_PATH\mount\venv\default\Scripts\"
Copy-Item "$ROOT_PATH\mount\git\dotnetfile\examples\dotnetfile_dump.py" "$ROOT_PATH\mount\venv\default\Scripts\"
Copy-Item "$ROOT_PATH\setup\utils\hash-id.py" "$ROOT_PATH\mount\venv\default\Scripts\"
Copy-Item "$ROOT_PATH\setup\utils\powershell-cleanup.py" "$ROOT_PATH\mount\venv\default\Scripts\"

Get-ChildItem -Path "$ROOT_PATH\mount\venv\default\Scripts" -Filter *.py | ForEach-Object {
    $content = Get-Content $_.FullName
    if ($content[0] -match "^#!/usr/bin/python3" -or $content[0] -match "^#!/usr/bin/env python3") {
        $content -replace '^#!/usr/bin/.*', '#!/usr/bin/env python' | Set-Content $_.FullName
    }
}

Write-DateLog "Pip packages done."