
# Invoke-MigrationWithRetry.ps1
# Tries migration with retry logic and exponential backoff
function Invoke-MigrationWithRetry {
    param (
        [string]$Mailbox,
        [int]$Attempt = 1
    )

    try {
        .\Invoke-SmartMigration.ps1 -Mailbox $Mailbox
    } catch {
        if ($Attempt -lt 3) {
            Write-Host "Retrying migration for $Mailbox - Attempt $Attempt"
            Start-Sleep -Seconds (30 * $Attempt)
            Invoke-MigrationWithRetry -Mailbox $Mailbox -Attempt ($Attempt + 1)
        } else {
            Write-Error "Migration failed for $Mailbox after multiple attempts"
            .\Log-MigrationResult.ps1 -Mailbox $Mailbox -Status "Failed" -Duration 0 -RetryCount $Attempt -ErrorDetails $_.Exception.Message
        }
    }
}
