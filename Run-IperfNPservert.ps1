<#
.SYNOPSIS
Runs `iperf3` in server mode optimized for use with NetSpot WiFi Analyzer, with an option to stop the server by pressing the 'Q' key.

.DESCRIPTION
This script starts `iperf3` in server mode suitable for WiFi performance testing in conjunction with NetSpot's `iperf3` feature. It allows the user to terminate the `iperf3` server process by pressing the 'Q' key. Each session's results are logged with a timestamp.

.PARAMETER iperf3Path
Specifies the full path to the `iperf3` executable. Default is "C:\iperf3\iperf3.exe".

.PARAMETER logDirectory
Defines the directory where log files will be stored. Default is "C:\iperf3\log\".

.EXAMPLE
.\Run-IperfNPservert.ps1

Runs the script with default parameters, initiating `iperf3` in server mode for testing with NetSpot, and logs the output in the specified directory. Press 'Q' to stop the server.

.NOTES
Adjust the `iperf3` path and log directory as needed. Ensure NetSpot is configured to connect to this `iperf3` server for testing.

.NOTES
Created by: Gabriel Jensen
For:        Florim USA, Inc.
Date:       Feb 21st 2024
Version:    v02212024

#>

# Configuration
$iperf3Path = "C:\iperf3\iperf3.exe"
$logDirectory = "C:\iperf3\log\"

# Validation
if (-Not (Test-Path $iperf3Path)) {
    Write-Error "iperf3 executable not found at path: $iperf3Path"
    exit 1
}
if (-Not (Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Force -Path $logDirectory
}

# Logging setup
$currentDate = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$logFileName = "iperf-netspot-$currentDate.txt"
$logFilePath = Join-Path -Path $logDirectory -ChildPath $logFileName

# Start iperf3 server in a background job
$iperfJob = Start-Job -ScriptBlock { param($path, $log) & $path -s | Out-File $log } -ArgumentList $iperf3Path, $logFilePath

Write-Host "iperf3 server started. Press 'Q' to stop."

# Wait for 'Q' key press to stop the server
do {
    if ($Host.UI.RawUI.KeyAvailable -and ($Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character -eq 'q')) {
        Write-Host "`n'Q' key pressed. Stopping iperf3 server..."
        Stop-Job -Job $iperfJob
        Remove-Job -Job $iperfJob
        break
    }
    Start-Sleep -Milliseconds 500
} while ($true)

Write-Host "iperf3 server stopped."
