# ─── 路徑設定 ─────────────────────────────────────────────────────────────────
$PROJECT_DIR  = $PSScriptRoot
$FRONTEND_DIR = Join-Path $PROJECT_DIR "graduate-project-frontend"
$KINECT_DIR   = Join-Path $PROJECT_DIR "graduate-project-kinect"
$PYTHON_BIN   = "python"   # fallback; overridden below if venv is found
# ─────────────────────────────────────────────────────────────────────────────

$kinectProc   = $null
$frontendProc = $null

function Stop-All {
    Write-Host ""
    Write-Host "[start_all] Shutting down..."
    if ($kinectProc -and -not $kinectProc.HasExited) {
        taskkill /PID $kinectProc.Id /T /F 2>$null | Out-Null
        Write-Host "[kinect] stopped (pid $($kinectProc.Id))"
    }
    if ($frontendProc -and -not $frontendProc.HasExited) {
        taskkill /PID $frontendProc.Id /T /F 2>$null | Out-Null
        Write-Host "[frontend] stopped (pid $($frontendProc.Id))"
    }
}

# ─── 自動偵測 Kinect venv ─────────────────────────────────────────────────────
foreach ($venvName in @("venv", ".venv")) {
    $candidate = Join-Path $KINECT_DIR "$venvName\Scripts\python.exe"
    if (Test-Path $candidate) {
        $PYTHON_BIN = $candidate
        Write-Host "[kinect] Using venv: $candidate"
        break
    }
}
if ($PYTHON_BIN -eq "python") {
    Write-Host "[kinect] No venv found, using system python."
}

# ─── 啟動 Kinect main.py ──────────────────────────────────────────────────────
Write-Host "[kinect] Starting main.py in $KINECT_DIR..."
$kinectProc = Start-Process -FilePath $PYTHON_BIN `
    -ArgumentList "main.py" `
    -WorkingDirectory $KINECT_DIR `
    -PassThru -NoNewWindow
Write-Host "[kinect] pid $($kinectProc.Id)"

# ─── 啟動 Frontend start.ps1 ─────────────────────────────────────────────────
Write-Host "[frontend] Starting start.ps1 in $FRONTEND_DIR..."
$frontendProc = Start-Process -FilePath "powershell" `
    -ArgumentList "-ExecutionPolicy", "Bypass", "-File", (Join-Path $FRONTEND_DIR "start.ps1") `
    -WorkingDirectory $FRONTEND_DIR `
    -PassThru -NoNewWindow
Write-Host "[frontend] pid $($frontendProc.Id)"

Write-Host "[start_all] Both services started. Press Ctrl+C to stop all."

# ─── 等待任一子程序結束或 Ctrl+C ──────────────────────────────────────────────
try {
    while ($true) {
        Start-Sleep -Seconds 2
        if ($kinectProc.HasExited) {
            Write-Host "[kinect] process exited (code $($kinectProc.ExitCode)). Cleaning up..."
            break
        }
        if ($frontendProc.HasExited) {
            Write-Host "[frontend] process exited (code $($frontendProc.ExitCode)). Cleaning up..."
            break
        }
    }
} finally {
    Stop-All
}
