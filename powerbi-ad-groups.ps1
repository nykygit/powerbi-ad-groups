<#
=======================================================
POWERBI AD GROUPS
=======================================================
CONFIG
=======================================================
#>

# GroupInfo is descriptive text used in the AD Security Group Info Property.
$GroupInfo = "These AD Security Groups are automatically created, updated and removed to sync with POWERBI Objects for group based access control."

# ADPath is where we are storing our POWERBI Security Groups in Active Directory
$ADPath = "OU=POWERBI,OU=Groups,OU=LAB,DC=LAB,DC=COM"

# CurrentGroups is a list of all POWERBI Security Groups that currently exist.  We need this to determine if any groups were deprecated.
$CurrentGroups = 

# RequiredGroups is a list of all POWER Security Groups that need to exist.  This is based on Report Server Object GUIDs.
$RequiredGroups = Read-SqlViewData -ServerInstance "SQL1" -DatabaseName "ADSQL" -SchemaName "dbo" -ViewName "VIEW_POWERBI_GROUPS"


<#
=======================================================
LOOP START
=======================================================
#>


ForEach ($RequiredGroup in $RequiredGroups)
{

$GroupName = $RequiredGroup.GroupName
$GroupDescription = $RequiredGroup.GroupDescription


<#
=======================================================
Create the new group if it doesn't exist
=======================================================
#>

Try
{
    New-ADGroup `
    -Name $GroupName `
    -SamAccountName $GroupName `
    -Path $ADPath `
    -Description $GroupDescription `
    -GroupScope Global `
    -OtherAttributes @{'Info'='These AD Security Groups are automatically created, updated and removed to sync with POWERBI Objects for group based access control.'} 
    Write-Host "Group $GroupName was created."
}

<#
=======================================================
Group already exists - Update Description if necessary
=======================================================
#>

Catch [Microsoft.ActiveDirectory.Management.ADException]
{
    Switch ($_.Exception.Message){
        "The specified group already exists"
        {
            Write-Host "Group already exists for $GroupName"
            Write-Host "Checking if description is correct..."
            $ADGroupDescription = (Get-ADGroup -Identity $GroupName -Properties *).Description
            $ADGroupInfo = (Get-ADGroup -Identity $GroupName -Properties *).Info
            <#
            Write-Host 'ADGroupDescription - '$ADGroupDescription
            Write-Host 'GroupDescription - '$GroupDescription
            #>
            If ($ADGroupDescription -ne $GroupDescription){
                Set-ADGroup -Identity $GroupName -Description $GroupDescription
                Write-Host "Group Description Updated for $GroupName"
            }
            Else{
                Write-Host "Group Description OK"
            }
            Write-Host "Checking if description is correct..."
            If ($ADGroupInfo -ne $GroupInfo){
                Set-ADGroup -Identity $GroupName -Description $GroupInfo
                Write-Host "Group Info Updated for $GroupName"
            }
            Else{
                Write-Host "Group Info OK"
            }
        }
        default{Write-Host "Unhandled ADException: $_"}
    }
}

<#
=======================================================
EXCEPTION
=======================================================
#>

Catch {
    Write-Host "Unhandled Exception...Handle it."
    Write-Error $_
}


<#
=======================================================
LOOP END
=======================================================
#>

}
