﻿$ErrorActionPreference = 'Stop'

$packageName = $env:ChocolateyPackageName
$url         = 'http://zabkat.com/xplorer2_lite_setup.exe'
$Checksum    = 'ff59df9bd2cdaa0e63394239be9df163e8dfb4ed87685e1d01554a2481c465c8'

# silent install requires AutoHotKey
$ahkExe = 'AutoHotKey'
$toolsDir    = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$ahkFile = Join-Path $toolsDir 'chocolateyInstall.ahk'
$ahkProc = Start-Process -FilePath $ahkExe -ArgumentList "$ahkFile" -PassThru
$ahkId = $ahkProc.Id
Write-Debug "$ahkExe start time:`t$($ahkProc.StartTime.ToShortTimeString())"
Write-Debug "Process ID:`t$ahkId"

$packageArgs = @{
  packageName    = $packageName
  unzipLocation  = $toolsDir
  fileType       = 'EXE'
  url            = $url
  softwareName   = 'xplorer² lite*'
  checksum       = $Checksum
  checksumType   = 'sha256'
  silentArgs     = '/S'
  validExitCodes = @(0)
}
Install-ChocolateyPackage @packageArgs 
