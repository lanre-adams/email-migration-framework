
# Log-MigrationResult.ps1
# Logs migration results for each mailbox
param (
    [string]$Mailbox,
    [string]$Status,
    [int]$Duration,
    [int]$RetryCount = 0,
    [string]$ErrorDetails = ""
)

$logEntry = [PSCustomObject]@{
    Timestamp   = (Get-Date).ToString("s")
    Mailbox     = $Mailbox
    Status      = $Status
    Duration    = $Duration
    RetryCount  = $RetryCount
    Error       = $ErrorDetails
}

$logPath = "data/migration_log.csv"
if (-Not (Test-Path $logPath)) {
    $logEntry | Export-Csv -Path $logPath -NoTypeInformation
} else {
    $logEntry | Export-Csv -Path $logPath -Append -NoTypeInformation
}
