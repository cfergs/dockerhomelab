<# 
.DESCRIPTION 
  This script will append the required values required for docker applications to be browsable via https://domainname.com/<<url>>

  This reduces the need to manually update each file. 
  
  Additionally this script will fix any manually misconfigured url values

.NOTES
  Name: updatebasevalues.ps1
  Requires:
    - PowerShell v4 onwards

.INPUTS
  ConfigFolder
    directory where docker configs are stored EG c:\docker\configs
  
  DomainName
    Sabnzbd required a domainname to be whitelisted before you can access it's webui

#> 

Param(
  [String]$ConfigFolder,
  [string]$DomainName
)

#update radarr
$msg = Get-Content $folder\radarr\config.xml 
$msg -Replace ("<UrlBase>*.*</UrlBase>","<UrlBase>/radarr</UrlBase>") | Set-Content $ConfigFolder\radarr\config.xml

#update sonarr
$msg = Get-Content $ConfigFolder\sonarr\config.xml 
$msg -Replace ("<UrlBase>*.*</UrlBase>","<UrlBase>/sonarr</UrlBase>") | Set-Content $ConfigFolder\sonarr\config.xml

#update bazarr
#Set manually for now (nov 2019)

#update lazylibrarian
$msg = Get-Content $ConfigFolder\lazylibrarian\config.ini 
If($msg | Select-String "http_root") {
  $msg -Replace ("http_root*.*","http_root= /books") | Set-Content $ConfigFolder\lazylibrarian\config.ini
}else {
  Add-Content -Path $ConfigFolder\lazylibrarian\config.ini -Value "`r`nhttp_root= /books"
}

#update mylar
$msg = Get-Content $ConfigFolder\mylar\mylar\config.ini 
$msg -Replace ("http_root*.*","http_root = /comics") | Set-Content $ConfigFolder\mylar\mylar\config.ini

#update nzbhydra
$msg = Get-Content $ConfigFolder\nzbhydra2\nzbhydra.yml 
$msg -Replace ("urlBase:*.*",'urlBase: "/hydra2"') | Set-Content $ConfigFolder\nzbhydra2\nzbhydra.yml

#update jackett
$msg = Get-Content $ConfigFolder\jackett\Jackett\ServerConfig.json 
$msg -Replace ('"BasePathOverride":*.*','"BasePathOverride": "/jackett/",') | Set-Content $ConfigFolder\jackett\Jackett\ServerConfig.json 

#update sabnzbd
$msg = Get-Content $ConfigFolder\sabnzbd\sabnzbd.ini
$msg -Replace ("host_whitelist*.*","host_whitelist = $domainname") | Set-Content $ConfigFolder\sabnzbd\sabnzbd.ini

#update transmission 
$msg = Get-Content $ConfigFolder\transmission\settings.json
$msg -Replace ('"rpc-host-whitelist-enabled": true,','"rpc-host-whitelist-enabled": false,') | Set-Content $ConfigFolder\transmission\settings.json