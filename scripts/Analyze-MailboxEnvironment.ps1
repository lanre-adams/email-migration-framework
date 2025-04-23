
# Analyze-MailboxEnvironment.ps1
# Collects metadata from all mailboxes for pre-migration assessment
$mailboxes = Get-Mailbox -ResultSize Unlimited
foreach ($mb in $mailboxes) {
    $stats = Get-MailboxStatistics -Identity $mb.Identity
    [PSCustomObject]@{
        Mailbox     = $mb.DisplayName
        SizeMB      = $stats.TotalItemSize.ToMB()
        ItemCount   = $stats.ItemCount
        Corruption  = Test-Mailbox -Identity $mb.Identity -CorruptionType All
        LastLogon   = $stats.LastLogonTime
    } | Export-Csv -Path "data/mailbox_metadata_sample.csv" -Append -NoTypeInformation
}
