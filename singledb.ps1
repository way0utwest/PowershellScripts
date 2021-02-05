param($pinstance="localhost\SQL2017", $pdbname, $pdbdatapath = "D:\SQLServerData\SQL2017\")

Write-Output($pinstance)
Write-Output($pdbname)
Get-DbaDatabase -SqlInstance $pinstance -ExcludeSystem | Detach-DbaDatabase -Force

# get the file structure, assume one mdf, one ldf
$pattern = $pdbname + "*"
$files =  Get-ChildItem -Path $pdbdatapath | Where {$_.Name -Like $pattern}

$fileStructure = New-Object System.Collections.Specialized.StringCollection
foreach( $file in $files) { 
    $fileStructure.Add($file.FullName) 
}

Mount-DbaDatabase -SqlInstance $pinstance -Database $pdbname -FileStructure $fileStructure

