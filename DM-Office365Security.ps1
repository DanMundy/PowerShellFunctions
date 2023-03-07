### DanMundyPSFunctions: Office 365 Security
### Version: 20230307T1528

## ----------------------------------------------------------------------------

# Function: Get-DMSharedMailboxesWithLoginEnabled
# Purpose: Show enabled Azure AD user accounts which are for Shared Mailboxes
# Usage: Get-DMSharedMailboxesWithLoginEnabled  | Format-Table Mail,UserPrincipalName
# Usage (todo): Pipe it into Set-AzureAdUser to disable the account. Maybe prompt per-mailbox?

function Get-DMSharedMailboxesWithLoginEnabled {
    $SharedMailboxes = Get-EXOMailbox -Filter {recipienttypedetails -eq "SharedMailbox"}
    $Result = ForEach ($Mailbox in $SharedMailboxes) {
        #Write-Host $Mailbox.UserPrincipalName
        Get-AzureADUser -Filter "UserPrincipalName eq '$($Mailbox.UserPrincipalName)'"
    }
    Return $Result | Where -Property AccountEnabled -eq $True
}

## ----------------------------------------------------------------------------
