# ─── User-configurable variables ────────────────────────────────────────────
$PYTHON_DIR   = "$PSScriptRoot\.."          # 相對於此 script：frontend 的上一層 (backend)
$PYTHON_BIN   = "python"                    # 或 "python3"、venv 路徑
$FRONTEND_DIR = $PSScriptRoot              # 此 script 所在目錄即 frontend
$CHROME_URL   = "http://localhost:3000"
$CHROME_PORT  = 3000
$CHROME_EXE   = "C:\Program Files\Google\Chrome\Application\chrome.exe"
# ─────────────────────────────────────────────────────────────────────────────

$pythonProc = $null
$npmProc    = $null

function Stop-All {
    Write-Host ""
    Write-Host "[start] Shutting down..."
    if ($pythonProc -and -not $pythonProc.HasExited) {
        Stop-Process -Id $pythonProc.Id -Force -ErrorAction SilentlyContinue
        Write-Host "[python] stopped (pid $($pythonProc.Id))"
    }
    if ($npmProc -and -not $npmProc.HasExited) {
        # npm run dev 會產生子 process，用 taskkill 一併結束
        taskkill /PID $npmProc.Id /T /F 2>$null | Out-Null
        Write-Host "[npm] stopped (pid $($npmProc.Id))"
    }
}

# ─── Start Python backend ─────────────────────────────────────────────────────
Write-Host "[python] Starting main.py in $PYTHON_DIR..."
$pythonProc = Start-Process -FilePath $PYTHON_BIN `
    -ArgumentList "main.py" `
    -WorkingDirectory $PYTHON_DIR `
    -PassThru -NoNewWindow
Write-Host "[python] pid $($pythonProc.Id)"

# ─── Start frontend dev server ────────────────────────────────────────────────
Write-Host "[npm] Starting dev server in $FRONTEND_DIR..."
$npmProc = Start-Process -FilePath "npm" `
    -ArgumentList "run", "dev" `
    -WorkingDirectory $FRONTEND_DIR `
    -PassThru -NoNewWindow
Write-Host "[npm] pid $($npmProc.Id)"

# ─── Wait for frontend to be ready ───────────────────────────────────────────
Write-Host -NoNewline "[start] Waiting for server on port $CHROME_PORT"
$timeout = 60
$elapsed = 0
$ready   = $false

while ($elapsed -lt $timeout) {
    try {
        Invoke-WebRequest -Uri "http://localhost:$CHROME_PORT" -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop | Out-Null
        $ready = $true
        break
    } catch { }

    Start-Sleep -Seconds 1
    $elapsed++
    Write-Host -NoNewline "."
}

Write-Host ""

if (-not $ready) {
    Write-Host "[start] ERROR: server did not respond after ${timeout}s. Aborting."
    Stop-All
    exit 1
}

Write-Host "[start] Server is up."

# ─── Launch Chrome in kiosk mode ─────────────────────────────────────────────
if (-not (Test-Path $CHROME_EXE)) {
    $CHROME_EXE = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}
if (-not (Test-Path $CHROME_EXE)) {
    Write-Host "[chrome] ERROR: Chrome not found. Please set `$CHROME_EXE to the correct path."
    Stop-All
    exit 1
}

Write-Host "[chrome] Launching Chrome at $CHROME_URL..."
Start-Process $CHROME_EXE -ArgumentList "--kiosk", "--no-first-run", "--disable-infobars", "--noerrdialogs", $CHROME_URL
Write-Host "[chrome] launched."

# ─── Keep running until Ctrl+C ───────────────────────────────────────────────
Write-Host "[start] Running. Press Ctrl+C to stop."
try {
    while ($true) { Start-Sleep -Seconds 2 }
} finally {
    Stop-All
}
