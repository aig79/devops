
function Get-DiskSpace() {
<#
.SYNOPSIS
Returns the total amount of disk space, amount free, and percent free (in bytes)

.DESCRIPTION
The Get-DiskSpace function returns the total amount of disk space available in bytes, and optionally the 
amount free, or the percent free for a server or a list of servers. You can also optionally pass in 
credentials for the authenticating to remote servers.

.EXAMPLE
View percent of disk space free on local server.
Get-DiskSpace -Percent

.EXAMPLE
Read server names from a file and retrieve disk space data.
Get-Content C:\serverlist.txt | Get-DiskSpace

.EXAMPLE 
Get-DiskSpace | ft SystemName,DeviceID,VolumeName,@{Label="Total Size";Expression={$_.Size / 1gb -as [int] }},@{Label="Free Size";Expression={$_.freespace / 1gb -as [int] }} -autosize

.NOTES
@author DevOpsLibrary

#>
 
    [CmdletBinding()] 
    param(
        # A single computer naem or an array of computer names. You may also provide IP addresses.
        [Parameter(ValueFromPipeline=$true)][string]$ServerName,
        # The Username and Password stored as a credential for authenticating to remote servers (Only applies to remote servers)
        $PSCredential,
        # Retun Free Space if switch specified
        [switch]$Free,
        # Return Total Space if switch specified
        [switch]$Total,
        # Return Percent if switch specified
        [switch]$Percent
    )
    $array = @()
    $parms = @{ 'class' = 'Win32_LogicalDisk';'filter' = 'DriveType=3' }

    if ($PSCredential) { $parms.Add('Credential', $PSCredential) } # Add Paramater if set, otherwise run locally.

    $ServerName | % {
        if ($_) { $parms.Set_Item('ComputerName',$_)} # Add ServerName if set, otherwise run locally.
        $array += Get-WmiObject @parms
    }

    Switch ($PSBoundParameters.Keys) {
        'Free' { return $array | % {$_.FreeSpace} } # Retun Free Space if switch specified
        'Total' { return $array | % {$_.Size} } # Return Total Space if switch specified
        'Percent' { return $array | % {$_.FreeSpace / $_.Size} } # Return Percent if switch specified
    }

    return $array
}
