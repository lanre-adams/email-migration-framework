
<#
.DESCRIPTION
    Sets up environment, installs dependencies, and optionally schedules automation tasks.
#>

# Variables
$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptDir = Join-Path $BaseDir "scripts"
$DataDir = Join-Path $BaseDir "data"
$Dashboard = Join-Path $BaseDir "dashboards\migration_dashboard.pbix"

Write-Host "📦 Starting Email Migration Framework Installer..." -ForegroundColor Cyan

# 1. Set Execution Policy
Write-Host "🔐 Setting execution policy..."
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. Install Required Modules
Write-Host "🛠️ Installing required PowerShell modules..."
$requiredModules = @("ExchangeOnlineManagement", "ThreadJob")
foreach ($mod in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Install-Module -Name $mod -Scope CurrentUser -Force
    }
}

# 3. Connect to Exchange (if needed)
Write-Host "🔗 Please authenticate to Exchange Online (if applicable)..."
try {
    Connect-ExchangeOnline -ErrorAction Stop
} catch {
    Write-Warning "Could not connect to Exchange Online. Skipping Exchange validation."
}

# 4. Create necessary directories
Write-Host "📁 Ensuring data directory exists..."
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir | Out-Null
}

# 5. Register Scheduled Task for Nightly Migration Watchdog
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptDir\Monitor-MigrationWatchdog.ps1`""
$Trigger = New-ScheduledTaskTrigger -Daily -At 2am
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive
$TaskName = "MigrationWatchdog"

Write-Host "🕒 Creating scheduled task '$TaskName'..."
try {
    Register-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -TaskName $TaskName -Description "Runs migration watchdog to restart failed batches" -Force
} catch {
    Write-Warning "⚠️ Failed to create scheduled task. Run PowerShell as Admin if needed."
}

# 6. (Optional) Launch Power BI Dashboard
if (Test-Path $Dashboard) {
    Write-Host "📊 Opening Power BI Dashboard..."
    Start-Process -FilePath $Dashboard
} else {
    Write-Host "📊 Dashboard not found. You can open migration_dashboard.pbix manually later."
}

Write-Host "✅ Installation complete. You are ready to run your migration scripts!" -ForegroundColor Green
