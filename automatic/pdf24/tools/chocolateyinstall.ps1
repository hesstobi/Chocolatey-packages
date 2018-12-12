﻿$ErrorActionPreference = 'Stop'

# The PDF24 Service depends on the Print Spooler service
if ((get-service -DisplayName 'print spooler').Status -ne 'Running') {
   Write-Warning "The Print Spooler service must be running for PDF24 to install."
   Throw 'Print Spooler ("spooler") service is stopped.'
}

$toolsDir   = Split-Path -parent $MyInvocation.MyCommand.Definition
$Installer = (Get-ChildItem $toolsDir -Filter '*.msi').FullName

$InstallArgs = @{
   packageName   = $env:ChocolateyPackageName
   fileType      = 'MSI' 
   File          = $Installer
   softwareName  = "$env:ChocolateyPackageName*"
   silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
   validExitCodes= @(0, 3010, 1641)
}

$pp = Get-PackageParameters

if ($pp['Icon']) { 
   Write-Host 'You have opted for the Desktop Icon.' -ForegroundColor Cyan
   $I = ''
} else { $I = ' DESKTOPICONS=No' } 

if ($pp['Fax']) { 
   Write-Host 'You have opted to include the FaxPrinter.' -ForegroundColor Cyan
   $F = ''
} else { $F = ' FAXPRINTER=No' } 

if ($pp['Basic']) {
   Write-Host 'You requested to configure the PDF Printer feature only.' -ForegroundColor Cyan
   $RegPath = 'HKLM:\SOFTWARE\Wow6432Node'
   if (-not (Test-Path "$RegPath\PDFPrint")) {
      $null = New-Item -Path $RegPath -Name 'PDFPrint' -Force
   }
   $Properties = @(
      'NoTrayIcon',
      'NoOnlineConverter',
      'NoShellContextMenuExtension',
      'NoOnlinePdfTools',
      'NoCloudPrint',
      'NoEmbeddedBrowser',
      'NoPDF24MailInterface',
      'NoScreenCapture',
      'NoFax',
      'NoFaxProfile',
      'NoMail'
   )
   ForEach ($item in $Properties) {
      $null = New-ItemProperty -Path "$RegPath\PDFPrint" -Name $item -PropertyType DWORD -Value 1 -Force
   }
}

$InstallArgs.silentArgs = "$($InstallArgs.silentArgs)$I$F"

Install-ChocolateyInstallPackage @InstallArgs

