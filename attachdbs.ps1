<#
Description: Attach databases from a folder that are not already on the instance.
#>

$folder = 'D:\mssqlserver\MSSQL11.MSSQLSERVER\MSSQL\DATA'
$instance = 'Tiny'

#placeholder
"================================================="
"=       Start                                   ="
"================================================="

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $instance
"Database List"
"-------------"

foreach($sqlDatabase in $Server.databases) 
    { "DB:" + $sqlDatabase.name
    }

foreach ($file in Get-ChildItem $folder)
{
#$file.FullName
#$file.Extension

if ($file.Extension -eq '.mdf') 
  {"File:" + $file.BaseName
    foreach($sqlDatabase in $Server.databases) 
        { 

          if ($file.BaseName -neq $sqlDatabase.name)
            { "  **** Database Does Not Exist **** "
            }
        }

   }
}
write-host "Done"
