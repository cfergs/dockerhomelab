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

  #update sabnzbd
  #fixes:
  # 1. issue with page not loading due to non-whitelisting
  # 2. sets correct download folders - container doesnt set this as sabnzbd.ini created AFTER container. 
  # 2..cont. + using different folders stops it conflicting with torrent downloads
  $msg = Get-Content $ConfigFolder\sabnzbd\sabnzbd.ini
  $msg -Replace("host_whitelist*.*","host_whitelist = $domainname,base.$domainname") -Replace ("download_dir*.*","download_dir = /data/downloads/usenet/incomplete") -Replace ("complete_dir*.*","complete_dir = /data/downloads/usenet/complete") | Set-Content $ConfigFolder\sabnzbd\sabnzbd.ini
}