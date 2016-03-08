$Path = "C:\deploy_result.txt"
$File_exists = Test-Path $Path
If ($File_exists -eq $True) {C:\Users\abhijajo\Desktop\sendmail.ps1}
Else {Write-Host "No file at this location"}