#requires -version 5.1

<#
  CleanTemp.ps1
  A control script to clean temp folders of files since last boot
  and empty folders.
#>
[cmdletbinding(SupportsShouldProcess)]
Param(
  [Parameter(Position = 0,HelpMessage = "Specify the temp folder path")]
  [string[]]$Path = @($env:temp, 'c:\windows\temp')
)

#dot source functions
. C:\utilities\Remove-EmptyFolder.ps1
. C:\utilities\Remove-File.ps1

#get last boot up time
$bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
Write-Verbose "Last boot = $boottime"
#delete files in temp folders older than the last bootup time
foreach ($folder in $Path) {
  if (Test-Path $Folder) {
    Remove-File -path $folder -cutoff $bootTime -recurse -force
    Remove-EmptyFolder -path $folder
  }
  else {
    Write-Warning "Failed to validate $($folder.toUpper())"
  }
}