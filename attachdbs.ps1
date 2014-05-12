<#
Description: Attach databases from a folder that are not already on the instance.
#>

$folder = 'D:\mssqlserver\MSSQL11.MSSQLSERVER\MSSQL\DATA'
$instance = 'Tiny'
$debug = 0
$dbsexist = ""
$dbsnotexist = ""

#placeholder
"================================================="
"=       Start                                   ="
"================================================="

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $instance
if ($debug -eq 1)
 {
    "Database List"
    "-------------"
    foreach($sqlDatabase in $Server.databases) 
        { "DB:" + $sqlDatabase.name
        }
 }

Write-Host "Checking Files"

foreach ($file in Get-ChildItem $folder)
{
#Debug
if ($debug -eq 1)
    {
     write-host $file.FullName
     write-host $file.Extension
     }

if ($file.Extension -eq '.mdf') 
  {
    # output file name being checked
    "File:" + $file.BaseName

    # reset the check
    $found = 0

    # loop through each  of the databases
    foreach($sqlDatabase in $Server.databases) 
        { 
          # check the file v the database name
          if ($debug -eq 1)
           {
              "Checking " + $file.BaseName + " v " + $sqlDatabase.Name
            }

          if ($file.BaseName -eq $sqlDatabase.name)
            { 
             $found = 1
             $dbsexist = $dbsexist + $file.BaseName + ", "
            }

        }
    if ($found -eq 0)
    {
        "  **** Database Does Not Exist **** "
        $dbsnotexist = $dbsnotexist + $file.BaseName + ", "
    }

   }
}
write-host "Databases that exist: " + $dbsexist
write-host "Databases that don't exist: " + $dbsnotexist
write-host " "
write-host "Done"
