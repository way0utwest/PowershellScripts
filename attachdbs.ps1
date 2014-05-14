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
 #end debug
 }

Write-Host "Checking Files in " + $folder
Write-Host " "

# loop through each  of the file
foreach ($file in Get-ChildItem $folder)
{
#Debug
if ($debug -eq 1)
    {
     write-host "All Files: " $file.name
     #end debug
    }


    # reset the check
    $found = 0

   if ($file.Extension -eq '.mdf') 
    {

     if ($debug -eq 1)
     {
      write-host "MDF File: " $file.name
      #end debug
     }

     # output file name being checked
     #"File:" + $file.BaseName
     # loop through each  of the databases
     foreach($sqlDatabase in $Server.databases) 
        { 
         # grab an owner here. 
         $dbholder = $server.Databases[0]
         $owner = $dbholder.Owner

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
        "Need to attach database " + $file.FullName

        # attach the databases
        $dbfiles = New-Object System.Collections.Specialized.StringCollection

        $dbfiles.Add($file.FullName) | Out-Null

        #get database name
        $dbname = $file.BaseName

        # get log file, assuming same basename as mdf
        $logfile = $folder + "\" + $file.BaseName + "_log.ldf"
        $dbfiles.Add($logfile) | Out-Null

        "Attaching as database (" + $dbname + ") from mdf (" + $file.FullName + ") and ldf (" + $logfile + ")"
        try
        {
            $server.AttachDatabase($dbname, $dbfiles)
        #end try
        }
        catch
        {
        Write-Host $_.exception;
        #end catch
        }
        #$Server.AttachDatabase($dbname,$dbfiles, $owner, [Microsoft.SqlServer.Management.Smo.AttachOptions]::None)

    #end of not found
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
