$folder = 'D:\mssqlserver\MSSQL11.MSSQLSERVER\MSSQL\DATA'
$debug = 0
$instance = 'Tiny'

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $instance
if ($debug -eq 3)
 {
    "Database List"
    "-------------"
    foreach($sqlDatabase in $Server.databases) 
        { Write-Output "DB:" $sqlDatabase.name
        }
 #end debug
 }


# loop through each  of the file
foreach ($file in Get-ChildItem $folder)
{
 #Debug
 if ($debug -eq 1)
    {
     Write-Output "Debug 1: All files: " $file.name
     #end debug
    }

 if ($file.Extension -eq '.mdf') 
    {
     if ($debug -eq 1)
     {
      Write-Output "Debug 1: MDF Files: "  $file.name
      #end debug
     }

     # Reset our flag for each file
     $found = 0

     # loop through each  of the databases
     foreach($sqlDatabase in $Server.databases) 
        {

         $sqlfg = $sqlDatabase.FileGroups
         foreach ($fg in $sqlfg | Where-Object {$_.ISDefault -eq $true})
         {
          if ($debug -eq 6)
          {
           Write-Output "Debug 6: File " $file.Name $sqlDatabase.name " " $fg.Name
          # end if
          }

          foreach ($dbfile in $fg.files | Where-Object {$_.ISPrimaryFile -eq $true} )
           {

            if ($debug -eq 4)
            {
            Write-Output "Debug 4: File" $file.BaseName " DB MDF File: "  $dbfile.Name
            #end debug
            }

            if ($file.FullName -eq $dbfile.FileName)
             { 
              $found = 1

              if ($debug -eq 5)
              {
                Write-Output "Debug 5: Match " $file.FullName " = " $dbfile.FileName
               #end if
              }
              #end if
             }

           #end foreach db file
           }
         #end foreach filegroup
         }

        # end foreach 
        }

    if ($found -eq 0)
    {
    # attach this file
    $dbfiles = New-Object System.Collections.Specialized.StringCollection

    $dbfiles.Add($file.FullName) | Out-Null

    #get database name
    $dbname = $file.BaseName

    # get log file, assuming same basename as mdf
    $logfile = $folder + "\" + $file.BaseName + "_log.ldf"
    $dbfiles.Add($logfile) | Out-Null

    Write-Output "Attaching as database (" + $dbname + ") from mdf (" + $file.FullName + ") and ldf (" + $logfile + ")"
    try
     {
      $server.AttachDatabase($dbname, $dbfiles)
     #end try
     }
     catch
     {
      Write-Output $_.exception;
     #end catch
     }


    if ($debug -eq 7)
    {
    Write-Output "Debug 7: " $file.Name "not found"
    #end if debug
    }

    #end if found = 0
    }

    # end if is this an mdf file
    }

# end for loop of files
}
