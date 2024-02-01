﻿Write-Output "Installing and updating files for dfirws"

$source = "M:\IT\dfirws"

if (! (Test-Path "${HOME}\dfirws")) {
	Write-Output "Creating directory ${HOME}\dfirws for dfirws"
	mkdir "${HOME}\dfirws" | Out-Null

	Set-Location "${HOME}\dfirws"

	Write-Output "Copy initial zip file"
	Copy-Item "M:\IT\dfirws\dfirws.zip" .
	Write-Output "Expand zip"
	tar -xf dfirws.zip | Out-Null
	Write-Output "Remove zip"
	Remove-Item dfirws.zip
}

Write-Output "Update downloads"
Robocopy.exe /MT:96 /MIR "M:\IT\dfirws\dfirws\downloads" "${HOME}\dfirws\downloads"  | Out-Null

Write-Output "Update mount"
Robocopy.exe /MT:96 /MIR "M:\IT\dfirws\dfirws\mount" "${HOME}\dfirws\mount" | Out-Null

Write-Output "Update setup."
Robocopy.exe /MT:96 /MIR "M:\IT\dfirws\dfirws\setup" "${HOME}\dfirws\setup" /XF "config.txt" | Out-Null

$folders = "local", "readonly", "readwrite"
foreach ($folder in $folders) {
	if (! (Test-Path "${HOME}\dfirws\$folder")) {
		mkdir "${HOME}\dfirws\$folder" | Out-Null
	}
}

Write-Output "Update other files."
if (Test-Path "${HOME}\dfirws\dfirws.ps1" ) {
	cp "M:\IT\dfirws\dfirws.ps1" "${HOME}\dfirws\dfirws.ps1" | Out-Null
}

cp "M:\IT\dfirws\dfirws\README.md" "${HOME}\dfirws\README.md" | Out-Null
cp "M:\IT\dfirws\dfirws\createSandboxConfig.ps1" "${HOME}\dfirws\createSandboxConfig.ps1" | Out-Null
cp "M:\IT\dfirws\dfirws\dfirws.wsb.template" "${HOME}\dfirws\dfirws.wsb.template" | Out-Null
cp "M:\IT\dfirws\dfirws\setup\default-config.txt" "${HOME}\dfirws\setup\default-config.txt" | Out-Null
cp "M:\IT\dfirws\dfirws\local\example-customize.ps1" "${HOME}\dfirws\local\example-customize.ps1" | Out-Null
cp "M:\IT\dfirws\dfirws\local\.bashrc.default" "${HOME}\dfirws\local\" | Out-Null
cp "M:\IT\dfirws\dfirws\local\.zcompdump.default" "${HOME}\dfirws\local\" | Out-Null
cp "M:\IT\dfirws\dfirws\local\.zshrc.default" "${HOME}\dfirws\local\" | Out-Null
cp "M:\IT\dfirws\dfirws\local\default-Microsoft.PowerShell_profile.ps1" "${HOME}\dfirws\local\" | Out-Null

if ( -not (Test-Path -Path "${HOME}\dfirws\dfirws.wsb" -PathType Leaf )) {
	Write-Output "Create default dfirws.wsb"
	(Get-Content "${HOME}\dfirws\dfirws.wsb.template").replace("__SANDBOX__", "${HOME}\dfirws") | Set-Content "${HOME}\dfirws\dfirws.wsb"
}

if (! (Test-Path -Path "${HOME}\dfirws\setup\config.txt")) {
		Copy-Item "${HOME}\dfirws\setup\default-config.txt" "${HOME}\dfirws\setup\config.txt"
		Write-Output "Created ${HOME}\dfirws\tools\config.txt. You can use it to customize tools to install based on your needs."
}

if (! (Test-Path -Path "${HOME}\dfirws\local\customize.ps1")) {
		Copy-Item "${HOME}\dfirws\local\example-customize.ps1" "${HOME}\dfirws\local\customize.ps1"
		Write-Output "Created ${HOME}\dfirws\local\customize.ps1. You can use it to create shortcuts and run custom PowerShell code on startup."
}

if((Get-Process "WindowsSandbox" -ea SilentlyContinue) -eq $Null ){
	Write-Output "Starting sandbox."
	& "${HOME}\dfirws\dfirws.wsb"
} else {
	Write-Output "Sandbox is running and can only run one at the time."
}
