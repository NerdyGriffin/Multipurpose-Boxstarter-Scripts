choco upgrade -y powershell
choco upgrade -y powershell-core
refreshenv

#--- Fonts ---
# choco install -y cascadiafonts
# choco install -y cascadia-code-nerd-font
# choco install -y firacodenf

#--- Windows Terminal ---
choco upgrade -y microsoft-windows-terminal; choco upgrade -y microsoft-windows-terminal # Does this twice because the first attempt often fails but leaves the install partially completed, and then it completes successfully the second time.

#--- Enable Powershell Script Execution
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
refreshenv

#--- Update all modules ---
[ScriptBLock]$ScriptBlock = {
	Write-Host 'Updating all modules...'
	Update-Module
}
# Run the script block in PowerShell
powershell.exe -Command $ScriptBlock
# Run the script block in PowerShell Core
pwsh.exe -Command $ScriptBlock


#--- Prepend a Custom Printed Message to the PowerShell Profile
[ScriptBlock]$ScriptBlock = {
	if (-not(Test-Path $PROFILE)) {
		Write-Verbose "`$PROFILE does not exist at $PROFILE`nCreating new `$PROFILE..."
		New-Item -Path $PROFILE -ItemType File -Force
	}
	Write-Host 'Prepending Custom Message to PowerShell Profile...'
	$ProfileString = 'Write-Output "Loading Custom PowerShell Profile..."'
	Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
	if (-not(Select-String -Pattern $ProfileString -Path $PROFILE )) {
		Write-Output 'Attempting to add the following line to $PROFILE :' | Write-Debug
		Write-Output $ProfileString | Write-Debug
		Set-Content -Path $PROFILE -Value ($ProfileString, (Get-Content $PROFILE))
	}
}
# Run the script block in PowerShell
powershell.exe -Command $ScriptBlock
# Run the script block in PowerShell Core
pwsh.exe -Command $ScriptBlock


#--- Install & Configure the Powerline Modules
try {
	Write-Host 'Installing Posh-Git and Oh-My-Posh - [Dependencies for Powerline]'
	Write-Host 'Installing Posh-Git...'
	if (-not(Get-Module -ListAvailable -Name posh-git)) {
		Install-Module posh-git -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose
	} else { Write-Host "Module 'posh-git' already installed" }
	refreshenv
	Write-Host 'Installing Oh-My-Posh...'
	if (-not(Get-Module -ListAvailable -Name oh-my-posh)) {
		try {
			Install-Module oh-my-posh -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose -AllowPrerelease
		} catch {
			Install-Module oh-my-posh -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose
		}
	} else { Write-Host "Module 'oh-my-posh' already installed" }
	refreshenv
	[ScriptBlock]$ScriptBlock = {
		Write-Host 'Appending Configuration for Powerline to PowerShell Profile...'
		$PowerlineProfile = @(
			'# Dependencies for powerline',
			# '[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding', # Workaround for oh-my-posh bug in 2021-03-14
			'Import-Module posh-git',
			'Set-PoshPrompt -Theme microverse-power'
			# 'Set-PoshPrompt -Theme paradox'
			# 'Set-PoshPrompt -Theme slimfat'
			# 'Set-PoshPrompt -Theme sorin'
		)
		Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
		if (-not(Select-String -Pattern $PowerlineProfile[0] -Path $PROFILE )) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $PowerlineProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $PowerlineProfile
		}
	}
	# Run the script block in PowerShell
	powershell.exe -Command $ScriptBlock;
	# Run the script block in PowerShell Core
	pwsh.exe -Command $ScriptBlock;
	# Install additional Powerline-related packages via chocolatey
	# choco install -y poshgit
	# choco install -y posh-github
	# refreshenv
} catch {
	Write-Host  'Powerline failed to install' | Write-Warning
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	# Move on if Powerline install fails due to error
}


#--- Install & Configure the PSReadline Module
try {
	Write-Host 'Installing PSReadLine -- [Bash-like CLI features and Optional Dependency for Powerline]'
	if (-not(Get-Module -ListAvailable -Name PSReadLine)) {
		Install-Module -Name PSReadLine -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose
	} else { Write-Host "Module 'PSReadLine' already installed" }
	refreshenv
	[ScriptBlock]$ScriptBlock = {
		Write-Host 'Appending Configuration for PSReadLine to PowerShell Profile...'
		$PSReadlineProfile = @(
			'# Customize PSReadline to make PowerShell behave more like Bash',
			'Import-Module PSReadLine',
			'Set-PSReadLineOption -DingTone 440 -EditMode Emacs -HistoryNoDuplicates -HistorySearchCursorMovesToEnd',
			# 'Set-PSReadLineOption -BellStyle Audible -DingTone 512',
			'# Creates an alias for ls like I use in Bash',
			'Set-Alias -Name v -Value Get-ChildItem'
		)
		Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
		if (-not(Select-String -Pattern $PSReadlineProfile[0] -Path $PROFILE)) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $PSReadlineProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $PSReadlineProfile
		}
	}
	# Run the script block in PowerShell
	powershell.exe -Command $ScriptBlock;
	# Run the script block in PowerShell Core
	pwsh.exe -Command $ScriptBlock;
} catch {
	Write-Host  'PSReadline failed to install' | Write-Warning
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	# Move on if PSReadline install fails due to errors
}


#--- Import Chocolatey Modules
Write-Host 'Appending Configuration for Chocolatey to PowerShell Profile...'
[ScriptBlock]$ChocoScriptBlock = {
	Write-Host 'Appending Configuration for Chocolatey to PowerShell Profile...'
	$ChocolateyProfile = @(
		'# Chocolatey profile',
		'$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"',
		'if (Test-Path($ChocolateyProfile)) {'
		'	Import-Module "$ChocolateyProfile"'
		'}'
	)
	Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
	if (-not(Select-String -Pattern $ChocolateyProfile[0] -Path $PROFILE)) {
		Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
		Write-Output $ChocolateyProfile | Write-Debug
		Add-Content -Path $PROFILE -Value $ChocolateyProfile
	}
}
# Run the script block in PowerShell
powershell.exe -Command $ChocoScriptBlock
# Run the script block in PowerShell Core
pwsh.exe -Command $ChocoScriptBlock


# #--- Import Boxstarter Modules
# [ScriptBlock]$BoxstarterScriptBlock = {
# 	Write-Host 'Appending Configuration for Boxstarter to PowerShell Profile...'
# 	$BoxstarterProfile = @(
# 		'# Boxstarter modules',
# 		'# Import the Chocolatey module first so that $Boxstarter properties',
# 		'# are initialized correctly and then import everything else.',
# 		'if (Test-Path("\\GRIFFINUNRAID\Boxstarter")) {',
# 		'	$BoxstarterInstall = "\\GRIFFINUNRAID\Boxstarter"',
# 		'} elseif (Test-Path("D:\Boxstarter")) {',
# 		'	$BoxstarterInstall = "D:\Boxstarter"',
# 		'}',
# 		'Import-Module $BoxstarterInstall\Boxstarter.Chocolatey\Boxstarter.Chocolatey.psd1 -DisableNameChecking -ErrorAction SilentlyContinue',
# 		'Resolve-Path $BoxstarterInstall\Boxstarter.*\*.psd1 |',
# 		'	% { Import-Module $_.ProviderPath -DisableNameChecking -ErrorAction SilentlyContinue }',
# 		'Import-Module $BoxstarterInstall\Boxstarter.Common\Boxstarter.Common.psd1 -Function Test-Admin'
# 	)
# 	Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
# 	if (-not(Select-String -Pattern $BoxstarterProfile[0] -Path $PROFILE)) {
# 		Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
# 		Write-Output $BoxstarterProfile | Write-Debug
# 		Add-Content -Path $PROFILE -Value $BoxstarterProfile
# 	}
# }
# # Run the script block in PowerShell
# powershell.exe -Command $BoxstarterScriptBlock
# # Run the script block in PowerShell Core
# pwsh.exe -Command $BoxstarterScriptBlock


#--- Install the Pipeworks Module
try {
	Write-Host 'Installing Pipeworks -- [CLI Tools for PowerShell]'
	Write-Host 'Description: PowerShell Pipeworks is a framework for writing Sites and Software Services in Windows PowerShell modules.'
	if (-not(Get-Module -ListAvailable -Name Pipeworks)) {
		Install-Module -Name Pipeworks -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose
	} else { Write-Host "Module 'Pipeworks' already installed" }
	refreshenv
} catch {
	Write-Host 'Pipeworks failed to install' | Write-Warning
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	# Move on if Pipeworks install fails due to errors
}


#--- Install the CredentialManager Module
try {
	Write-Host 'Installing CredentialManager'
	Write-Host 'Description: Provides access to credentials in the Windows Credential Manager.'
	if (-not(Get-Module -ListAvailable -Name CredentialManager)) {
		Install-Module -Name CredentialManager
	} else { Write-Host "Module 'CredentialManager' already installed" }
	refreshenv
} catch {
	Write-Host  'CredentialManager failed to install' | Write-Warning
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	# Move on if CredentialManager install fails due to errors
}


#--- Update all modules ---
[ScriptBLock]$ScriptBlock = {
	Write-Host 'Updating all modules...'
	Update-Module
}
# Run the script block in PowerShell
powershell.exe -Command $ScriptBlock
# Run the script block in PowerShell Core
pwsh.exe -Command $ScriptBlock


$WindowsTerminalSettingsDir = (Join-Path $env:LOCALAPPDATA '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState')
$SymLinkPath = (Join-Path $env:USERPROFILE 'WindowsTerminalSettings')
if (Test-Path $WindowsTerminalSettingsDir) {
	if ((-not(Test-Path $SymLinkPath)) -or (-not(Get-Item $SymLinkPath | Where-Object Attributes -Match ReparsePoint))) {
		New-Item -Path $SymLinkPath -ItemType SymbolicLink -Value $WindowsTerminalSettingsDir -Force -Verbose
	}
	$RemoteBackup = '\\GRIFFINUNRAID\backup\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\.git'
	if ((Test-Path $RemoteBackup) -and (-not(Test-Path (Join-Path $WindowsTerminalSettingsDir '.git')))) {
		$PrevLocation = Get-Location
		Set-Location -Path $RemoteBackup
		git.exe fetch; git.exe pull;
		Copy-Item -Path $RemoteBackup -Destination (Join-Path $WindowsTerminalSettingsDir '.git')
		Set-Location -Path $PrevLocation
	}
}
