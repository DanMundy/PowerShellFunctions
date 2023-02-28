# Purpose: Create custom policies
# Version: 20230131T1228
# Author: Dan Mundy
# 
# Ref:
# - [Microsoft recommendations for EOP and Defender for Office 365 security settings - Office 365 | Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365?view=o365-worldwide)

# "Remember, if you never turned on the Standard preset security policy or the Strict preset security policy
# in the Microsoft 365 Defender portal, 
# the associated security policies for the preset security policy don't exist." 
# ([Preset security policies - Office 365 | Microsoft Learn](https://learn.microsoft.com/en-au/microsoft-365/security/office-365-security/preset-security-policies?view=o365-worldwide))
# 
# If you want to double check that they exist before trying to clone them;
# 
#   Get-AntiPhishPolicy | where -Property RecommendedPolicyType -Eq Standard | fl Name,ObjectClass,DistinguishedName
#   Get-MalwareFilterPolicy | where -Property RecommendedPolicyType -Eq Standard | fl Name,ObjectClass,DistinguishedName
#   Get-SafeAttachmentPolicy | where -Property RecommendedPolicyType -Eq Standard | fl Name,ObjectClass,DistinguishedName
#   Get-SafeLinksPolicy | where -Property RecommendedPolicyType -Eq Standard | fl Name,ObjectClass,DistinguishedName
# --/

# Quick commands to get everything for documentation:
# ----------
# Show-DMAntiPhishPolicy
# Show-DMMalwareFilterPolicy
# Show-DMSafeAttachmentPolicy
# Show-DMSafeLinksPolicy
# Show-DMHostedContentFilterPolicy
# Show-DMHostedOutboundSpamFilterPolicy

# Quick commands for deploy policies:
# ----------
# New-DMStandardAntiPhishPolicy
# New-DMStandardMalwareFilterPolicy
# New-DMStandardSafeAttachmentPolicy
# New-DMStandardSafeLinksPolicy
# New-DMStandardHostedContentFilterPolicy
# New-DMStandardHostedOutboundSpamFilterPolicy

# To wipe and start again:
# ----------
# Remove-DMAllCustomDefenderPolicies



########## Setting Up The Session
##########

function Connect-DMExchangeOnline {
    Install-Module ExchangeOnlineManagement
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline

    $domains = (Get-AcceptedDomain).Name
}



########## Creating The Policies
##########


# Create an AntiPhish Policy by copying the Standard preset security policy
# --------------------
function New-DMStandardAntiPhishPolicy{
    $StandardAntiPhishPolicy = Get-AntiPhishPolicy | where -Property RecommendedPolicyType -Eq Standard
    $StandardAntiPhishPolicyAttributes = $Null
    $StandardAntiPhishPolicyAttributes = @{
        AuthenticationFailAction = $StandardAntiPhishPolicy.AuthenticationFailAction
        #DmarcQuarantineAction = $StandardAntiPhishPolicy.DmarcQuarantineAction
        #DmarcRejectAction = $StandardAntiPhishPolicy.DmarcRejectAction
        EnableFirstContactSafetyTips = $StandardAntiPhishPolicy.EnableFirstContactSafetyTips
        EnableMailboxIntelligence = $StandardAntiPhishPolicy.EnableMailboxIntelligence
        EnableMailboxIntelligenceProtection = $StandardAntiPhishPolicy.EnableMailboxIntelligenceProtection
        EnableOrganizationDomainsProtection = $StandardAntiPhishPolicy.EnableOrganizationDomainsProtection
        EnableSimilarDomainsSafetyTips = $StandardAntiPhishPolicy.EnableSimilarDomainsSafetyTips
        EnableSimilarUsersSafetyTips = $StandardAntiPhishPolicy.EnableSimilarUsersSafetyTips
        EnableSpoofIntelligence = $StandardAntiPhishPolicy.EnableSpoofIntelligence
        EnableTargetedDomainsProtection = $StandardAntiPhishPolicy.EnableTargetedDomainsProtection
        EnableTargetedUserProtection = $StandardAntiPhishPolicy.EnableTargetedUserProtection
        EnableUnauthenticatedSender = $StandardAntiPhishPolicy.EnableUnauthenticatedSender
        EnableUnusualCharactersSafetyTips = $StandardAntiPhishPolicy.EnableUnusualCharactersSafetyTips
        EnableViaTag = $StandardAntiPhishPolicy.EnableViaTag
        #HonorDmarcPolicy = $StandardAntiPhishPolicy.HonorDmarcPolicy
        MailboxIntelligenceProtectionAction = $StandardAntiPhishPolicy.MailboxIntelligenceProtectionAction
        MailboxIntelligenceQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #MailboxIntelligenceQuarantineTag = $StandardAntiPhishPolicy.MailboxIntelligenceQuarantineTag
        PhishThresholdLevel = $StandardAntiPhishPolicy.PhishThresholdLevel
        SpoofQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #SpoofQuarantineTag = $StandardAntiPhishPolicy.SpoofQuarantineTag
        TargetedDomainProtectionAction = $StandardAntiPhishPolicy.TargetedDomainProtectionAction
        TargetedDomainQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #TargetedDomainQuarantineTag = $StandardAntiPhishPolicy.TargetedDomainQuarantineTag
        TargetedUserProtectionAction = $StandardAntiPhishPolicy.TargetedUserProtectionAction
        TargetedUserQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #TargetedUserQuarantineTag = $StandardAntiPhishPolicy.TargetedUserQuarantineTag
    }
    New-AntiPhishPolicy -Name "Anti-Phish Policy (Custom)" -Enabled $true @StandardAntiPhishPolicyAttributes
    New-AntiPhishRule -Name "Anti-Phish Rule (Custom)" -AntiPhishPolicy "Anti-Phish Policy (Custom)" -RecipientDomainIs $domains
}

# Changes after policy created:
function Set-DMStandardAntiPhishPolicy {
    $StandardAntiPhishPolicyAttributes = $Null
    $StandardAntiPhishPolicyAttributes = @{
        EnableTargetedUserProtection = $StandardAntiPhishPolicy.EnableTargetedUserProtection
        EnableMailboxIntelligenceProtection = $StandardAntiPhishPolicy.EnableMailboxIntelligenceProtection
        EnableTargetedDomainsProtection = $StandardAntiPhishPolicy.EnableTargetedDomainsProtection
        EnableOrganizationDomainsProtection = $StandardAntiPhishPolicy.EnableOrganizationDomainsProtection
        EnableMailboxIntelligence = $StandardAntiPhishPolicy.EnableMailboxIntelligence
        EnableFirstContactSafetyTips = $StandardAntiPhishPolicy.EnableFirstContactSafetyTips
        EnableSimilarUsersSafetyTips = $StandardAntiPhishPolicy.EnableSimilarUsersSafetyTips
        EnableSimilarDomainsSafetyTips = $StandardAntiPhishPolicy.EnableSimilarDomainsSafetyTips
        EnableUnusualCharactersSafetyTips = $StandardAntiPhishPolicy.EnableUnusualCharactersSafetyTips
        TargetedUserProtectionAction = $StandardAntiPhishPolicy.TargetedUserProtectionAction
        MailboxIntelligenceProtectionAction = $StandardAntiPhishPolicy.MailboxIntelligenceProtectionAction
        TargetedDomainProtectionAction = $StandardAntiPhishPolicy.TargetedDomainProtectionAction
        AuthenticationFailAction = $StandardAntiPhishPolicy.AuthenticationFailAction
        EnableSpoofIntelligence = $StandardAntiPhishPolicy.EnableSpoofIntelligence
        EnableViaTag = $StandardAntiPhishPolicy.EnableViaTag
        EnableUnauthenticatedSender = $StandardAntiPhishPolicy.EnableUnauthenticatedSender
        #HonorDmarcPolicy = $StandardAntiPhishPolicy.HonorDmarcPolicy
        #DmarcRejectAction = $StandardAntiPhishPolicy.DmarcRejectAction
        #DmarcQuarantineAction = $StandardAntiPhishPolicy.DmarcQuarantineAction
        PhishThresholdLevel = $StandardAntiPhishPolicy.PhishThresholdLevel
        TargetedUserQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        MailboxIntelligenceQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        TargetedDomainQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        SpoofQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
    }
    Get-AntiPhishPolicy | where -Property RecommendedPolicyType -Eq Standard | Set-AntiPhishPolicy @StandardAntiPhishPolicyAttributes
}

# Create an Anti-Malware Policy by copying the Standard preset security policy
# --------------------

function New-DMStandardMalwareFilterPolicy {
    $StandardMalwareFilterPolicy = Get-MalwareFilterPolicy | where -Property RecommendedPolicyType -Eq Standard
    $StandardMalwareFilterPolicyAttributes = $Null
    $StandardMalwareFilterPolicyAttributes = @{
        CustomNotifications = $StandardMalwareFilterPolicy.CustomNotifications
        EnableExternalSenderAdminNotifications = $StandardMalwareFilterPolicy.EnableExternalSenderAdminNotifications
        EnableFileFilter = $StandardMalwareFilterPolicy.EnableFileFilter
        EnableInternalSenderAdminNotifications = $StandardMalwareFilterPolicy.EnableInternalSenderAdminNotifications
        FileTypeAction = $StandardMalwareFilterPolicy.FileTypeAction
        FileTypes = $StandardMalwareFilterPolicy.FileTypes
        QuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #QuarantineTag = $StandardMalwareFilterPolicy.QuarantineTag
    }
    New-MalwareFilterPolicy -Name "Anti-Malware Policy (Custom)" @StandardMalwareFilterPolicyAttributes 
    New-MalwareFilterRule -Name "Anti-Malware Rule (Custom)" -MalwareFilterPolicy "Anti-Malware Policy (Custom)" -RecipientDomainIs $domains
}

# Create a Safe Attachment Policy by copying the Standard preset security policy
# --------------------
function New-DMStandardSafeAttachmentPolicy {
    $StandardSafeAttachmentPolicy = Get-SafeAttachmentPolicy | where -Property RecommendedPolicyType -Eq Standard
    $StandardSafeAttachmentPolicyAttributes = $Null
    $StandardSafeAttachmentPolicyAttributes = @{
        Redirect = $StandardSafeAttachmentPolicy.Redirect
        Action = $StandardSafeAttachmentPolicy.Action
        Enable = $StandardSafeAttachmentPolicy.Enable
        ActionOnError = $StandardSafeAttachmentPolicy.ActionOnError
        QuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #QuarantineTag = $StandardSafeAttachmentPolicy.QuarantineTag
    }
    New-SafeAttachmentPolicy -Name "Safe Attachments Policy (Custom)" @StandardSafeAttachmentPolicyAttributes 
    New-SafeAttachmentRule -Name "Safe Attachments Rule (Custom)" -SafeAttachmentPolicy "Safe Attachments Policy (Custom)" -RecipientDomainIs $domains
}

# Create a Safe Links Policy by copying the Standard preset security policy
# --------------------
function New-DMStandardSafeLinksPolicy {
    $StandardSafeLinksPolicy = Get-SafeLinksPolicy | where -Property RecommendedPolicyType -Eq Standard | Select-Object *
    $StandardSafeLinksPolicyAttributes = $Null
    $StandardSafeLinksPolicyAttributes = @{
        EnableSafeLinksForEmail = $StandardSafeLinksPolicy.EnableSafeLinksForEmail
        EnableSafeLinksForTeams = $StandardSafeLinksPolicy.EnableSafeLinksForTeams
        EnableSafeLinksForOffice = $StandardSafeLinksPolicy.EnableSafeLinksForOffice
        TrackClicks = $StandardSafeLinksPolicy.TrackClicks
        AllowClickThrough = $StandardSafeLinksPolicy.AllowClickThrough
        ScanUrls = $StandardSafeLinksPolicy.ScanUrls
        EnableForInternalSenders = $StandardSafeLinksPolicy.EnableForInternalSenders
        DeliverMessageAfterScan = $StandardSafeLinksPolicy.DeliverMessageAfterScan
        DisableUrlRewrite = $StandardSafeLinksPolicy.DisableUrlRewrite
        EnableOrganizationBranding = $StandardSafeLinksPolicy.EnableOrganizationBranding
    }
    New-SafeLinksPolicy -Name "Safe Links Policy (Custom)" @StandardSafeLinksPolicyAttributes
    New-SafeLinksRule -Name "Safe Links Rule (Custom)" -SafeLinksPolicy "Safe Links Policy (Custom)" -RecipientDomainIs $domains
}

# Create a Spam Filter (Inbound) Policy by copying the Standard preset security policy
# --------------------
function New-DMStandardHostedContentFilterPolicy {
    $StandardHostedContentFilterPolicy = Get-HostedContentFilterPolicy | where -Property RecommendedPolicyType -Eq Standard | Select-Object *
    $StandardHostedContentFilterPolicyAttributes = $Null
    $StandardHostedContentFilterPolicyAttributes = @{
        AllowedSenderDomains = $StandardHostedContentFilterPolicy.AllowedSenderDomains
        AllowedSenders = $StandardHostedContentFilterPolicy.AllowedSenders
        BlockedSenderDomains = $StandardHostedContentFilterPolicy.BlockedSenderDomains
        BlockedSenders = $StandardHostedContentFilterPolicy.BlockedSenders
        BulkQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #BulkQuarantineTag = $StandardHostedContentFilterPolicy.BulkQuarantineTag
        BulkSpamAction = $StandardHostedContentFilterPolicy.BulkSpamAction
        BulkThreshold = $StandardHostedContentFilterPolicy.BulkThreshold
        DownloadLink = $StandardHostedContentFilterPolicy.DownloadLink
        EnableEndUserSpamNotifications = $StandardHostedContentFilterPolicy.EnableEndUserSpamNotifications
        EnableLanguageBlockList = $StandardHostedContentFilterPolicy.EnableLanguageBlockList
        EnableRegionBlockList = $StandardHostedContentFilterPolicy.EnableRegionBlockList
        EndUserSpamNotificationFrequency = $StandardHostedContentFilterPolicy.EndUserSpamNotificationFrequency
        EndUserSpamNotificationLanguage = $StandardHostedContentFilterPolicy.EndUserSpamNotificationLanguage
        EndUserSpamNotificationLimit = $StandardHostedContentFilterPolicy.EndUserSpamNotificationLimit
        HighConfidencePhishAction = $StandardHostedContentFilterPolicy.HighConfidencePhishAction
        HighConfidencePhishQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #HighConfidencePhishQuarantineTag = $StandardHostedContentFilterPolicy.HighConfidencePhishQuarantineTag
        HighConfidenceSpamAction = $StandardHostedContentFilterPolicy.HighConfidenceSpamAction
        HighConfidenceSpamQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #HighConfidenceSpamQuarantineTag = $StandardHostedContentFilterPolicy.HighConfidenceSpamQuarantineTag
        IncreaseScoreWithBizOrInfoUrls = $StandardHostedContentFilterPolicy.IncreaseScoreWithBizOrInfoUrls
        IncreaseScoreWithImageLinks = $StandardHostedContentFilterPolicy.IncreaseScoreWithImageLinks
        IncreaseScoreWithNumericIps = $StandardHostedContentFilterPolicy.IncreaseScoreWithNumericIps
        IncreaseScoreWithRedirectToOtherPort = $StandardHostedContentFilterPolicy.IncreaseScoreWithRedirectToOtherPort
        InlineSafetyTipsEnabled = $StandardHostedContentFilterPolicy.InlineSafetyTipsEnabled
        MarkAsSpamBulkMail = $StandardHostedContentFilterPolicy.MarkAsSpamBulkMail
        MarkAsSpamEmbedTagsInHtml = $StandardHostedContentFilterPolicy.MarkAsSpamEmbedTagsInHtml
        MarkAsSpamEmptyMessages = $StandardHostedContentFilterPolicy.MarkAsSpamEmptyMessages
        MarkAsSpamFormTagsInHtml = $StandardHostedContentFilterPolicy.MarkAsSpamFormTagsInHtml
        MarkAsSpamFramesInHtml = $StandardHostedContentFilterPolicy.MarkAsSpamFramesInHtml
        MarkAsSpamFromAddressAuthFail = $StandardHostedContentFilterPolicy.MarkAsSpamFromAddressAuthFail
        MarkAsSpamJavaScriptInHtml = $StandardHostedContentFilterPolicy.MarkAsSpamJavaScriptInHtml
        MarkAsSpamNdrBackscatter = $StandardHostedContentFilterPolicy.MarkAsSpamNdrBackscatter
        MarkAsSpamObjectTagsInHtml = $StandardHostedContentFilterPolicy.MarkAsSpamObjectTagsInHtml
        MarkAsSpamSensitiveWordList = $StandardHostedContentFilterPolicy.MarkAsSpamSensitiveWordList
        MarkAsSpamSpfRecordHardFail = $StandardHostedContentFilterPolicy.MarkAsSpamSpfRecordHardFail
        MarkAsSpamWebBugsInHtml = $StandardHostedContentFilterPolicy.MarkAsSpamWebBugsInHtml
        PhishQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #PhishQuarantineTag = $StandardHostedContentFilterPolicy.PhishQuarantineTag
        PhishSpamAction = $StandardHostedContentFilterPolicy.PhishSpamAction
        PhishZapEnabled = $StandardHostedContentFilterPolicy.PhishZapEnabled
        QuarantineRetentionPeriod = $StandardHostedContentFilterPolicy.QuarantineRetentionPeriod
        SpamAction = $StandardHostedContentFilterPolicy.SpamAction
        SpamQuarantineTag = "DefaultFullAccessWithNotificationPolicy"
        #SpamQuarantineTag = $StandardHostedContentFilterPolicy.SpamQuarantineTag
        SpamZapEnabled = $StandardHostedContentFilterPolicy.SpamZapEnabled
        TestModeAction = $StandardHostedContentFilterPolicy.TestModeAction
    }
    New-HostedContentFilterPolicy -Name "Anti-Spam Inbound Policy (Custom)" @StandardHostedContentFilterPolicyAttributes
    New-HostedContentFilterRule -Name "Anti-Spam Inbound Rule (Custom)" -HostedContentFilterPolicy "Anti-Spam Inbound Policy (Custom)" -RecipientDomainIs $domains
}

# Create a Spam Filter (Outbound) Policy by copying the Standard preset security policy
# --------------------
function New-DMStandardHostedOutboundSpamFilterPolicy {
    $StandardHostedOutboundSpamFilterPolicyAttributes = $Null
    $StandardHostedOutboundSpamFilterPolicyAttributes = @{
        # Ref: [Recommended settings for EOP and Microsoft Defender for Office 365 security](https://dan.srl/FGQU)

        # Restriction placed on users who reach the message limit
        # (BlockUser = Restrict the user from sending mail)
        ActionWhenThresholdReached = "BlockUser"
        
        # Automatic forwarding rules
        # (Automatic = Off = Automatic external forwarding is NOT allowed)
        AutoForwardingMode =  "Automatic"
        
        # Set an external message limit:
        RecipientLimitExternalPerHour =  500

        # Set an internal message limit:
        RecipientLimitInternalPerHour =  1000
        
        # Set a daily message limit:
        RecipientLimitPerDay =  1000
    }
    New-HostedOutboundSpamFilterPolicy -Name "Anti-Spam Outbound Policy (Custom)" @StandardHostedOutboundSpamFilterPolicyAttributes
    New-HostedOutboundSpamFilterRule -Name "Anti-Spam Outbound Rule (Custom)" -HostedOutboundSpamFilterPolicy "Anti-Spam Outbound Policy (Custom)" -SenderDomainIs $domains
}




########## For Documentation
##########

function Show-DMAntiPhishPolicy {
    $AntiPhishPolicy = Get-AntiPhishPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false
    Write-Host $AntiPhishPolicy.Name
    Write-Host "----------"
    Write-Host EnableTargetedUserProtection = $AntiPhishPolicy.EnableTargetedUserProtection
    Write-Host EnableMailboxIntelligenceProtection = $AntiPhishPolicy.EnableMailboxIntelligenceProtection
    Write-Host EnableTargetedDomainsProtection = $AntiPhishPolicy.EnableTargetedDomainsProtection
    Write-Host EnableOrganizationDomainsProtection = $AntiPhishPolicy.EnableOrganizationDomainsProtection
    Write-Host EnableMailboxIntelligence = $AntiPhishPolicy.EnableMailboxIntelligence
    Write-Host EnableFirstContactSafetyTips = $AntiPhishPolicy.EnableFirstContactSafetyTips
    Write-Host EnableSimilarUsersSafetyTips = $AntiPhishPolicy.EnableSimilarUsersSafetyTips
    Write-Host EnableSimilarDomainsSafetyTips = $AntiPhishPolicy.EnableSimilarDomainsSafetyTips
    Write-Host EnableUnusualCharactersSafetyTips = $AntiPhishPolicy.EnableUnusualCharactersSafetyTips
    Write-Host TargetedUserProtectionAction = $AntiPhishPolicy.TargetedUserProtectionAction
    Write-Host TargetedUserQuarantineTag = $AntiPhishPolicy.TargetedUserQuarantineTag
    Write-Host MailboxIntelligenceProtectionAction = $AntiPhishPolicy.MailboxIntelligenceProtectionAction
    Write-Host MailboxIntelligenceQuarantineTag = $AntiPhishPolicy.MailboxIntelligenceQuarantineTag
    Write-Host TargetedDomainProtectionAction = $AntiPhishPolicy.TargetedDomainProtectionAction
    Write-Host TargetedDomainQuarantineTag = $AntiPhishPolicy.TargetedDomainQuarantineTag
    Write-Host AuthenticationFailAction = $AntiPhishPolicy.AuthenticationFailAction
    Write-Host SpoofQuarantineTag = $AntiPhishPolicy.SpoofQuarantineTag
    Write-Host EnableSpoofIntelligence = $AntiPhishPolicy.EnableSpoofIntelligence
    Write-Host EnableViaTag = $AntiPhishPolicy.EnableViaTag
    Write-Host EnableUnauthenticatedSender = $AntiPhishPolicy.EnableUnauthenticatedSender
    #Write-Host HonorDmarcPolicy = $AntiPhishPolicy.HonorDmarcPolicy
    #Write-Host DmarcRejectAction = $AntiPhishPolicy.DmarcRejectAction
    #Write-Host DmarcQuarantineAction = $AntiPhishPolicy.DmarcQuarantineAction
    Write-Host PhishThresholdLevel = $AntiPhishPolicy.PhishThresholdLevel
}

function Show-DMMalwareFilterPolicy {
    $MalwareFilterPolicy = Get-MalwareFilterPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false
    Write-Host $MalwareFilterPolicy.Name
    Write-Host CustomNotifications = $MalwareFilterPolicy.CustomNotifications
    Write-Host EnableExternalSenderAdminNotifications = $MalwareFilterPolicy.EnableExternalSenderAdminNotifications
    Write-Host EnableFileFilter = $MalwareFilterPolicy.EnableFileFilter
    Write-Host EnableInternalSenderAdminNotifications = $MalwareFilterPolicy.EnableInternalSenderAdminNotifications
    Write-Host FileTypeAction = $MalwareFilterPolicy.FileTypeAction
    Write-Host FileTypes = $MalwareFilterPolicy.FileTypes
    Write-Host QuarantineTag = $MalwareFilterPolicy.QuarantineTag
}

function Show-DMSafeAttachmentPolicy {
    $SafeAttachmentPolicy = Get-SafeAttachmentPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsBuiltInProtection -ne $true
    Write-Host $SafeAttachmentPolicy.Name
    Write-Host "----------"
    Write-Host Redirect = $SafeAttachmentPolicy.Redirect
    Write-Host Action = $SafeAttachmentPolicy.Action
    Write-Host Enable = $SafeAttachmentPolicy.Enable
    Write-Host ActionOnError = $SafeAttachmentPolicy.ActionOnError
    Write-Host QuarantineTag = $SafeAttachmentPolicy.QuarantineTag
}

function Show-DMSafeLinksPolicy {
    $SafeLinksPolicy = Get-SafeLinksPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsBuiltInProtection -ne $true
    Write-Host $SafeLinksPolicy.Name
    Write-Host "----------"
    Write-Host EnableSafeLinksForEmail = $SafeLinksPolicy.EnableSafeLinksForEmail
    Write-Host EnableSafeLinksForTeams = $SafeLinksPolicy.EnableSafeLinksForTeams
    Write-Host EnableSafeLinksForOffice = $SafeLinksPolicy.EnableSafeLinksForOffice
    Write-Host TrackClicks = $SafeLinksPolicy.TrackClicks
    Write-Host AllowClickThrough = $SafeLinksPolicy.AllowClickThrough
    Write-Host ScanUrls = $SafeLinksPolicy.ScanUrls
    Write-Host EnableForInternalSenders = $SafeLinksPolicy.EnableForInternalSenders
    Write-Host DeliverMessageAfterScan = $SafeLinksPolicy.DeliverMessageAfterScan
    Write-Host DisableUrlRewrite = $SafeLinksPolicy.DisableUrlRewrite
    Write-Host EnableOrganizationBranding = $SafeLinksPolicy.EnableOrganizationBranding
}

function Show-DMHostedContentFilterPolicy {
    $HostedContentFilterPolicy = Get-HostedContentFilterPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false
    Write-Host $HostedContentFilterPolicy.Name
    Write-Host "----------"
    Write-Host AllowedSenderDomains = $HostedContentFilterPolicy.AllowedSenderDomains
    Write-Host AllowedSenders = $HostedContentFilterPolicy.AllowedSenders
    Write-Host BlockedSenderDomains = $HostedContentFilterPolicy.BlockedSenderDomains
    Write-Host BlockedSenders = $HostedContentFilterPolicy.BlockedSenders
    Write-Host BulkQuarantineTag = $HostedContentFilterPolicy.BulkQuarantineTag
    Write-Host BulkSpamAction = $HostedContentFilterPolicy.BulkSpamAction
    Write-Host BulkThreshold = $HostedContentFilterPolicy.BulkThreshold
    Write-Host DownloadLink = $HostedContentFilterPolicy.DownloadLink
    Write-Host EnableEndUserSpamNotifications = $HostedContentFilterPolicy.EnableEndUserSpamNotifications
    Write-Host EnableLanguageBlockList = $HostedContentFilterPolicy.EnableLanguageBlockList
    Write-Host EnableRegionBlockList = $HostedContentFilterPolicy.EnableRegionBlockList
    Write-Host EndUserSpamNotificationFrequency = $HostedContentFilterPolicy.EndUserSpamNotificationFrequency
    Write-Host EndUserSpamNotificationLanguage = $HostedContentFilterPolicy.EndUserSpamNotificationLanguage
    Write-Host EndUserSpamNotificationLimit = $HostedContentFilterPolicy.EndUserSpamNotificationLimit
    Write-Host HighConfidencePhishAction = $HostedContentFilterPolicy.HighConfidencePhishAction
    Write-Host HighConfidencePhishQuarantineTag = $HostedContentFilterPolicy.HighConfidencePhishQuarantineTag
    Write-Host HighConfidenceSpamAction = $HostedContentFilterPolicy.HighConfidenceSpamAction
    Write-Host HighConfidenceSpamQuarantineTag = $HostedContentFilterPolicy.HighConfidenceSpamQuarantineTag
    Write-Host IncreaseScoreWithBizOrInfoUrls = $HostedContentFilterPolicy.IncreaseScoreWithBizOrInfoUrls
    Write-Host IncreaseScoreWithImageLinks = $HostedContentFilterPolicy.IncreaseScoreWithImageLinks
    Write-Host IncreaseScoreWithNumericIps = $HostedContentFilterPolicy.IncreaseScoreWithNumericIps
    Write-Host IncreaseScoreWithRedirectToOtherPort = $HostedContentFilterPolicy.IncreaseScoreWithRedirectToOtherPort
    Write-Host InlineSafetyTipsEnabled = $HostedContentFilterPolicy.InlineSafetyTipsEnabled
    Write-Host MarkAsSpamBulkMail = $HostedContentFilterPolicy.MarkAsSpamBulkMail
    Write-Host MarkAsSpamEmbedTagsInHtml = $HostedContentFilterPolicy.MarkAsSpamEmbedTagsInHtml
    Write-Host MarkAsSpamEmptyMessages = $HostedContentFilterPolicy.MarkAsSpamEmptyMessages
    Write-Host MarkAsSpamFormTagsInHtml = $HostedContentFilterPolicy.MarkAsSpamFormTagsInHtml
    Write-Host MarkAsSpamFramesInHtml = $HostedContentFilterPolicy.MarkAsSpamFramesInHtml
    Write-Host MarkAsSpamFromAddressAuthFail = $HostedContentFilterPolicy.MarkAsSpamFromAddressAuthFail
    Write-Host MarkAsSpamJavaScriptInHtml = $HostedContentFilterPolicy.MarkAsSpamJavaScriptInHtml
    Write-Host MarkAsSpamNdrBackscatter = $HostedContentFilterPolicy.MarkAsSpamNdrBackscatter
    Write-Host MarkAsSpamObjectTagsInHtml = $HostedContentFilterPolicy.MarkAsSpamObjectTagsInHtml
    Write-Host MarkAsSpamSensitiveWordList = $HostedContentFilterPolicy.MarkAsSpamSensitiveWordList
    Write-Host MarkAsSpamSpfRecordHardFail = $HostedContentFilterPolicy.MarkAsSpamSpfRecordHardFail
    Write-Host MarkAsSpamWebBugsInHtml = $HostedContentFilterPolicy.MarkAsSpamWebBugsInHtml
    Write-Host PhishQuarantineTag = $HostedContentFilterPolicy.PhishQuarantineTag
    Write-Host PhishSpamAction = $HostedContentFilterPolicy.PhishSpamAction
    Write-Host PhishZapEnabled = $HostedContentFilterPolicy.PhishZapEnabled
    Write-Host QuarantineRetentionPeriod = $HostedContentFilterPolicy.QuarantineRetentionPeriod
    Write-Host SpamAction = $HostedContentFilterPolicy.SpamAction
    Write-Host SpamQuarantineTag = $HostedContentFilterPolicy.SpamQuarantineTag
    Write-Host SpamZapEnabled = $HostedContentFilterPolicy.SpamZapEnabled
    Write-Host TestModeAction = $HostedContentFilterPolicy.TestModeAction

    # Ref: [Recommended settings for EOP and Microsoft Defender for Office 365 security](https://dan.srl/FGQU)
}

function Show-DMHostedOutboundSpamFilterPolicy {
    $HostedOutboundSpamFilterPolicy = Get-HostedOutboundSpamFilterPolicy | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false
    Write-Host $HostedOutboundSpamFilterPolicy.Name
    Write-Host "----------"
    Write-Host ActionWhenThresholdReached = $HostedOutboundSpamFilterPolicy.ActionWhenThresholdReached
    Write-Host AutoForwardingMode = $HostedOutboundSpamFilterPolicy.AutoForwardingMode
    Write-Host RecipientLimitExternalPerHour = $HostedOutboundSpamFilterPolicy.RecipientLimitExternalPerHour
    Write-Host RecipientLimitInternalPerHour = $HostedOutboundSpamFilterPolicy.RecipientLimitInternalPerHour
    Write-Host RecipientLimitPerDay = $HostedOutboundSpamFilterPolicy.RecipientLimitPerDay
}






########## For Cleanup / Starting Over
##########

# Remove All Custom Policies and Rules
# (eg if you want to start again from scratch)
function Remove-DMAllCustomDefenderPolicies {
    Get-AntiPhishPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false | Remove-AntiPhishPolicy
    Get-MalwareFilterPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false | Remove-MalwareFilterPolicy
    Get-SafeAttachmentPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsBuiltInProtection -ne $true | Remove-SafeAttachmentPolicy
    Get-SafeLinksPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsBuiltInProtection -ne $true | Remove-SafeLinksPolicy
    Get-HostedContentFilterPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false | Remove-HostedContentFilterPolicy
    Get-HostedOutboundSpamFilterPolicy | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false | Remove-HostedOutboundSpamFilterPolicy
    Get-AntiPhishRule | Remove-AntiPhishRule
    Get-MalwareFilterRule | Remove-MalwareFilterRule
    Get-SafeAttachmentRule | Remove-SafeAttachmentRule
    Get-SafeLinksRule | Remove-SafeLinksRule
    Get-HostedContentFilterRule | Remove-HostedContentFilterRule
    Get-HostedOutboundSpamFilterRule | Remove-HostedOutboundSpamFilterRule
}

function Remove-DMMalwareFilterPolicy {
    Get-MalwareFilterPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false | Remove-MalwareFilterPolicy
    Get-MalwareFilterRule | Remove-MalwareFilterRule
}

function Remove-DMAntiPhishPolicy {
    Get-AntiPhishPolicy  | where -property RecommendedPolicyType -eq "Custom" | where -property IsDefault -eq $false | Remove-AntiPhishPolicy
    Get-AntiPhishRule | Remove-AntiPhishRule
}

###############

function Get-DMMessageTraceDetail {
    [CmdletBinding()]
    param (
        $SenderAddress,
        $RecipientAddress
    )
    $messages = (Get-MessageTrace -RecipientAddress $RecipientAddress -SenderAddress $SenderAddress)
    #Write-Host "Message list:"
    #$messages
    ForEach ($message in $messages) {
        #Write-Host "Message details:"
        #$_
        #Write-Host "Message ID:"
        Get-MessageTraceDetail -MessageTraceId $message.MessageTraceId -RecipientAddress $message.RecipientAddress | Format-List
    }
}