param(
    [string]$TaskName = "InternshipTrackerWeekly",
    [string]$DaysOfWeek = "Monday",
    [string]$At = "9:00 AM",
    [string]$PythonCommand = ""
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$runnerPath = Join-Path $repoRoot "run_tracker.ps1"

if (-not (Test-Path $runnerPath)) {
    throw "Could not find run_tracker.ps1 at $runnerPath"
}

$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$runnerPath`""

$trigger = New-ScheduledTaskTrigger `
    -Weekly `
    -DaysOfWeek $DaysOfWeek `
    -At $At

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -WakeToRun `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Description "Send weekly internship deadline summary email" `
    -Force | Out-Null

if ($PythonCommand) {
    [Environment]::SetEnvironmentVariable(
        "INTERNSHIP_TRACKER_PYTHON",
        $PythonCommand,
        "User"
    )
}

Write-Host "Scheduled task '$TaskName' is configured."
Write-Host "The task will run every $DaysOfWeek at $At."
Write-Host "Missed runs will start when the computer is available."
Write-Host "Wake timers must be allowed in Windows power settings for wake-from-sleep to work."
