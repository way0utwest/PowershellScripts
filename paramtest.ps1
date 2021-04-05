param (
	[parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$hdr,
	[parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)][datetime]$date,
	[parameter(mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$recordtype
	)
write-host("hdr: $hdr")
