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

Write-Host "Checking Files in " + $folder
Write-Host " "

# loop through each  of the file
foreach ($file in Get-ChildItem $folder)
{
#Debug
if ($debug -eq 1)
    {
     write-host $sqlDatabase.name
    }


    # reset the check
    $found = 0

   if ($file.Extension -eq '.mdf' -and $file.PSIsContainer -eq $false) 
    {
     # output file name being checked
     #"File:" + $file.BaseName
     # loop through each  of the databases
     foreach($sqlDatabase in $Server.databases) 
        { 
         #search the filegroups
         $sqlfg = $sqlDatabase.FileGroups
         foreach ($fg in $sqlfg)
         {
          foreach ($dbfile in $fg.files | Where-Object {$_.ISPrimaryFile -eq $true} )
           {
            #get the mdf file name
            $filebeingchecked = $dbfile.filename
            #"File being checked: " + $filebeingchecked
            
           }
         }



         # check the file v the database name
         if ($debug -eq 1)
          {
             "Checking " + $file.FullName + " v " + $filebeingchecked
           }
           
         #"Checking file:" + $file.FullName
         #"Checking db  :" + $filebeingchecked
         #" "
          

         if ($file.FullName -eq $filebeingchecked)
          { 
           $found = 1
           $dbsexist = $dbsexist + $file.BaseName + ", "
          }

        }
    if ($found -eq 0)
    {
        $dbsnotexist = $dbsnotexist + $file.BaseName + ", "
        "Need to restore database from " + $file.FullName
    }

   }

}

if ($debug -eq 1)
{
 write-host "Databases that exist: " + $dbsexist
 write-host "Databases that don't exist: " + $dbsnotexist
 write-host " "
}

write-host " "
write-host "Done"
