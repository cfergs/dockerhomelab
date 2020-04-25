<# 
.DESCRIPTION 
This script will  
1. Append the required values required for docker applications to be browsable via https://domainname.com/<<url>>
2. Fix any manually misconfigured url values
3. Update Authelia and OpenLDAP domainname values

  This reduces the need to manually update each file. 

.NOTES
  Name: updatebasevalues.ps1
  Requires:
    - PowerShell v4 onwards

.INPUTS
  ConfigFolder
    directory where docker configs are stored EG c:\docker\configs
  
  DomainName
    domainname of environment. Used by OpenLDAP, Authelia and Sabnzbd

  LDAPUpdate
    Update the 00-startup.ldif ldap file to include correct domainnames
  
  AutheliaUpdate
    Update authelia configuration template to include correct domainnames
  
  AutheliaEmail
    Email address that authelia will use to send emails on
  
  ConfigUpdates
    Update all the services config files to use correct url subdomains.
#> 

Param(
  [String]$ConfigFolder,
  [string]$DomainName,
  [switch]$LDAPUpdate,
  [switch]$AutheliaUpdate,
  [string]$AutheliaEmail,
  [switch]$ConfigUpdates
)

#update openldap config to be specific to your site
If($LDAPUpdate -and $DomainName) {
  Write-Host "Updating Domain Name in LDAP config file"
  (Get-Content ".\ldap\00-startup_template.ldif").Replace("dc=example,dc=com","dc=$($DomainName.Split('.')[0]),dc=$($DomainName.Split('.')[1])").Replace("example.com","$DomainName") | Set-Content ".\ldap\00-startup.ldif"
}

If($AutheliaUpdate -and $DomainName -and $AutheliaEmail) {
  Write-Host "** Updating authelia configuration file **"
  Write-Host "Updating, domainname, email address and exporting file as configuration.yml for use"
  (Get-Content ".\authelia\configuration_template.yml").Replace("dc=example,dc=com","dc=$($DomainName.Split('.')[0]),dc=$($DomainName.Split('.')[1])").Replace("example.com","$DomainName").Replace("emailofuser@gmail.com","$AutheliaEmail") | Set-Content ".\authelia\configuration.yml"
}

If($ConfigUpdates -and $DomainName) {
  Write-Host "Updating URL subdomains"
  #update radarr
  $msg = Get-Content $configfolder\radarr\config.xml 
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
  $msg -Replace ("host_whitelist*.*","host_whitelist = $domainname,basic.$domainname") | Set-Content $ConfigFolder\sabnzbd\sabnzbd.ini

  #update transmission 
  $msg = Get-Content $ConfigFolder\transmission\settings.json
  $msg -Replace ('"rpc-host-whitelist-enabled": true,','"rpc-host-whitelist-enabled": false,') | Set-Content $ConfigFolder\transmission\settings.json
}