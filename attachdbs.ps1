<#
Description: Attach databases from a folder that are not already on the instance.
#>

# we have MDFS and LDFS as shared folders
# try to use the Network Path of the shared folder if your mapped drives cannot be found
# example: $folder = '\\MY-MACHINE\MySharedFolder'
$mdfFolder = 'D:\MDFS\MDFS'
$ldfFolder = 'E:\LDFS\LDFS'
$debug = 0
$instance = 'Tiny'
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
if ($debug -eq 2)
 {
    "Database List"
    "-------------"
    foreach($sqlDatabase in $Server.databases) 
        { Write-Output "Debug 2: DB:" $sqlDatabase.name
        }
 #end debug
 }

Write-Output "Checking Files in " + $mdfFolder
Write-Output " "

# loop through each  of the file
foreach ($file in Get-ChildItem $mdfFolder)
{
#Debug
if ($debug -eq 1)
    {
     Write-Output "Debug 1: All Files: " $file.name
     #end debug
    }


    # reset the check
    $found = 0

   if ($file.Extension -eq '.mdf') 
    {

     if ($debug -eq 1)
     {
      Write-Output "Debug 1: MDF File: " $file.name
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
            
           }
         }



         # check the file v the database name
         if ($debug -eq 1)
          {
             "Debug 1: Checking " + $file.FullName + " v " + $filebeingchecked
           }
          

         if ($file.FullName -eq $filebeingchecked)
          { 
           $found = 1
           $dbsexist = $dbsexist + $file.BaseName + ", "
           #end if
          }

        }
    if ($found -eq 0)
    {
        $dbsnotexist = $dbsnotexist + $file.BaseName + ", "
        Write-Output "Need to attach database " + $file.FullName

        # attach the databases
        $dbfiles = New-Object System.Collections.Specialized.StringCollection

        $dbfiles.Add($file.FullName) | Out-Null

        #get database name
        $dbname = $file.BaseName

        # get log file, assuming same basename as mdf
        $logfile = $ldfFolder + "\" + $file.BaseName + "_log.ldf"
        $dbfiles.Add($logfile) | Out-Null

        Write-output "Attaching as database (" + $dbname + ") from mdf (" + $file.FullName + ") and ldf (" + $logfile + ")"
        try
        {
            $server.AttachDatabase($dbname, $dbfiles)
        #end try
        }
        catch
        {
        Write-Output $_.exception|format-list -force;
        #end catch
        }
        #$Server.AttachDatabase($dbname,$dbfiles, $owner, [Microsoft.SqlServer.Management.Smo.AttachOptions]::None)

    #end of not found
    }

    #end if - check extension
   }

 #end loop through files
}

if ($debug -eq 1)
{
 Write-Output "Debug 1: Databases that exist: " + $dbsexist
 Write-Output "Debug 1: Databases that don't exist: " + $dbsnotexist
}

Write-Output "Done"
