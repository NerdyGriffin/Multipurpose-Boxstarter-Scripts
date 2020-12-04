try {
	Disable-UAC

	if (Test-Path 'D:\') {
		Move-LibraryDirectory 'Personal' (Join-Path 'D:\Users' $env:Username 'Documents')
		Create-SymLink -Path (Join-Path $env:UserProfile 'Documents') -Value (Join-Path 'D:\Users' $env:Username 'Documents') -ErrorAction SilentlyContinue
		# Create-SymLink -Path "D:\Documents" -Value (Join-Path 'D:\Users' $env:Username 'Documents') -ErrorAction SilentlyContinue
	}

	if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path '\\GRIFFINUNRAID\media\')) {
		Move-LibraryDirectory 'My Music' '\\GRIFFINUNRAID\media\Music' -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value '\\GRIFFINUNRAID\media\Music' -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' '\\GRIFFINUNRAID\media\Pictures' -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value '\\GRIFFINUNRAID\media\Pictures' -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' '\\GRIFFINUNRAID\media\Videos' -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value '\\GRIFFINUNRAID\media\Videos' -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Move-LibraryDirectory 'My Music' (Join-Path 'D:\Users' $env:Username 'Music') -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value (Join-Path 'D:\Users' $env:Username 'Music') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' (Join-Path 'D:\Users' $env:Username 'Pictures') -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value (Join-Path 'D:\Users' $env:Username 'Pictures') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' (Join-Path 'D:\Users' $env:Username 'Videos') -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value (Join-Path 'D:\Users' $env:Username 'Videos') -ErrorAction SilentlyContinue
	}

	if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path '\\GRIFFINUNRAID\personal\')) {
		Move-LibraryDirectory 'Downloads' '\\GRIFFINUNRAID\personal\Downloads' -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value '\\GRIFFINUNRAID\personal\Downloads' -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Move-LibraryDirectory 'Downloads' (Join-Path 'D:\Users' $env:Username 'Downloads') -ErrorAction SilentlyContinue
		Create-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value (Join-Path 'D:\Users' $env:Username 'Downloads') -ErrorAction SilentlyContinue
	}

	Write-Debug 'The script completed successfully' -ForegroundColor Green
	Write-ChocolateySuccess 'nerdygriffin.Move-Libraries'
} catch {
	Write-ChocolateyFailure 'nerdygriffin.Move-Libraries' $($_.Exception.Message)
	throw
}