$folder = 'D:\mssqlserver\MSSQL11.MSSQLSERVER\MSSQL\DATA'
$debug = 0

# loop through each  of the file
foreach ($file in Get-ChildItem $folder)
{
 #Debug
 if ($debug -eq 1)
    {
     write-host "All files: " $file.name
     #end debug
    }

 if ($file.Extension -eq '.mdf') 
    {
     if ($debug -eq 1)
     {
      write-host "MDF Files: "  $file.name
      #end debug
     }

    $file.Name

    # end if
    }

# end for loop of files
}
