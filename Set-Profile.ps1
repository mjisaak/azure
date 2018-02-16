<# 
# Execute the following line to persist the file in your profile:
(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mjisaak/azure/master/Set-Profile.ps1') | 
  Set-Content $profile -Force
#>

$profilePath = 'https://raw.githubusercontent.com/mjisaak/azure/master/profile.ps1'

$downloadString = '{0}?{1}' -f $profilePath, (New-Guid)
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($profilePath))
