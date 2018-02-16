
$profilePath = 'https://raw.githubusercontent.com/mjisaak/azure/master/profile.ps1'
((New-Object System.Net.WebClient).DownloadString($profilePath)) | Set-Content $profile -Force

function Say-Hello 
{
  Write-Host "This works fine."
}
