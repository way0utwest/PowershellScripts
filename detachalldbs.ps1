$instance = "Aristotle\SQL2017"
$dbpath = "D:\SQLServerData\SQL2017\"

Get-DbaDatabase -SqlInstance $instance -ExcludeSystem | Select-Object name
