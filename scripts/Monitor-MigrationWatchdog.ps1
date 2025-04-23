
# Monitor-MigrationWatchdog.ps1
# Monitors and recovers failed or stalled migration jobs
$failedBatches = Get-MigrationBatch | Where-Object { $_.Status -eq "Failed" -or $_.Status -eq "Stalled" }

foreach ($batch in $failedBatches) {
    Write-Host "Restarting failed batch: $($batch.Identity)"
    Stop-MigrationBatch -Identity $batch.Identity -Confirm:$false
    Start-MigrationBatch -Identity $batch.Identity
}
