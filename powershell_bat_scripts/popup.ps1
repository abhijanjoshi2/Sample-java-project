$a=1

While($a -eq 1)
{
Invoke-Item C:\get_file.bat
$Path = "C:\abhijajo.txt"
$File_exists = Test-Path $Path
if ($File_exists -eq $True)
{
C:\Users\abhijajo\Desktop\sendmail.ps1
Remove-Item C:\abhijajo.txt
}
}
