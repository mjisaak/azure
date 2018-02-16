$profilePath = 'https://raw.githubusercontent.com/mjisaak/azure/master/profile.ps1'

$downloadString = '{0}?{1}' -f $profilePath, (New-Guid)
((New-Object System.Net.WebClient).DownloadString($profilePath)) | 
    Set-Content $profile -Force
