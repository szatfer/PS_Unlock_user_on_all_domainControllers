# Import the Active Directory module
$module = "ActiveDirectory"

if(Get-module $module){
Import-module $module
}
Else{
Install-Module $module -Force -Scope CurrentUser
Import-module $module
}

# The text string to search for
$searchString = Read-Host "Enter the username you want to unlock"

# Search in Active Directory and store the results in a variable
$foundUsers = Get-ADUser -Filter "SamAccountName -like '*$searchString*'" -Properties SamAccountName, LockedOut

# Query domain controllers
$domainControllers = Get-ADDomainController -Filter *

Write-host "Examining found users:" -ForegroundColor DarkGreen -BackgroundColor White
# Unlock users on all domain controllers and handle errors
foreach ($user in $foundUsers) {
    if ($user.LockedOut) {
        foreach ($dc in $domainControllers) {
            try {
                Unlock-ADAccount -Identity $user.SamAccountName -Server $dc.HostName
                Write-Host "Successfully unlocked $($user.SamAccountName) on $($dc.HostName)" -ForegroundColor Black -BackgroundColor Green
            } catch {
                Write-Host "Failed to unlock $($user.SamAccountName) on $($dc.HostName): $_" -ForegroundColor Black -BackgroundColor Red
            }
        }
    } else {
        Write-Host "$($user.SamAccountName) is not in a locked state." -ForegroundColor Yellow -BackgroundColor Black
    }
}

Read-Host "Press Enter to exit."
