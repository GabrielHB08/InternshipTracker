$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $repoRoot "logs"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = Join-Path $logDir "tracker_$timestamp.log"
$pythonCommand = $env:INTERNSHIP_TRACKER_PYTHON

if (-not $pythonCommand) {
    $pythonCommand = "py"
}

New-Item -ItemType Directory -Force -Path $logDir | Out-Null
Set-Location $repoRoot

try {
    & $pythonCommand "tracker.py" *>> $logFile
    "Tracker completed successfully at $(Get-Date)" | Out-File -FilePath $logFile -Append
}
catch {
    "Tracker failed at $(Get-Date)" | Out-File -FilePath $logFile -Append
    $_ | Out-File -FilePath $logFile -Append
    throw
}
