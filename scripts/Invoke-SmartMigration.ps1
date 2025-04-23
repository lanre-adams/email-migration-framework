
# Invoke-SmartMigration.ps1
# Determines optimal migration parameters and initiates migration
param (
    [string]$Mailbox
)

$stats = Get-MailboxStatistics -Identity $Mailbox
$sizeMB = $stats.TotalItemSize.ToMB()

if ($sizeMB -gt 5000) {
    $batchSize = 50
    $throttle = 60
} elseif ($sizeMB -gt 1000) {
    $batchSize = 100
    $throttle = 30
} else {
    $batchSize = 200
    $throttle = 10
}

Start-MigrationBatch -Identity $Mailbox -BatchSize $batchSize
Start-Sleep -Seconds $throttle
