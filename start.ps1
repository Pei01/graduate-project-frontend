# ─── User-configurable variables ───────────────────────────────────────────────
$PYTHON_DIR   = "C:\path\to\graduate-project-backend"
$PYTHON_BIN   = "python"
$FRONTEND_DIR = "C:\path\to\graduate-project-frontend"
$CHROME_URL   = "http://localhost:3000"
$CHROME_PORT  = 3000
$CHROME_EXE   = "C:\Program Files\Google\Chrome\Application\chrome.exe"
# ───────────────────────────────────────────────────────────────────────────────

$pythonJob = $null
$npmJob    = $null

function Stop-All {
    Write-Host ""
    Write-Host "[start] Shutting down..."
    if ($pythonJob) { Stop-Job $pythonJob -ErrorAction SilentlyContinue; Remove-Job $pythonJob -Force -ErrorAction SilentlyContinue; Write-Host "[python] stopped" }
    if ($npmJob)    { Stop-Job $npmJob    -ErrorAction SilentlyContinue; Remove-Job $npmJob    -Force -ErrorAction SilentlyContinue; Write-Host "[npm] stopped" }
}

# ─── Start Python backend ────────────────────────────────────────────────────
Write-Host "[python] Starting main.py in $PYTHON_DIR..."
$pythonJob = Start-Job -ScriptBlock {
    param($dir, $bin)
    Set-Location $dir
    & $bin main.py 2>&1
} -ArgumentList $PYTHON_DIR, $PYTHON_BIN

# ─── Start frontend dev server ───────────────────────────────────────────────
Write-Host "[npm] Starting dev server in $FRONTEND_DIR..."
$npmJob = Start-Job -ScriptBlock {
    param($dir)
    Set-Location $dir
    npm run dev 2>&1
} -ArgumentList $FRONTEND_DIR

# ─── Stream job output in background ────────────────────────────────────────
$null = Register-ObjectEvent -InputObject $pythonJob -EventName StateChanged -Action {
    Receive-Job $pythonJob | ForEach-Object { Write-Host "[python] $_" }
}

# ─── Wait for frontend to be ready ──────────────────────────────────────────
Write-Host -NoNewline "[start] Waiting for server on port $CHROME_PORT"
$timeout = 60
$elapsed = 0
$ready   = $false

while ($elapsed -lt $timeout) {
    # Stream any pending output
    Receive-Job $pythonJob -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "[python] $_" }
    Receive-Job $npmJob    -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "[npm] $_" }

    try {
        $resp = Invoke-WebRequest -Uri "http://localhost:$CHROME_PORT" -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop
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

# ─── Launch Chrome in kiosk mode ────────────────────────────────────────────
if (-not (Test-Path $CHROME_EXE)) {
    # Fallback: try x86 path
    $CHROME_EXE = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}
if (-not (Test-Path $CHROME_EXE)) {
    Write-Host "[chrome] ERROR: Chrome not found. Set `$CHROME_EXE to the correct path."
    Stop-All
    exit 1
}

Write-Host "[chrome] Launching Chrome at $CHROME_URL..."
Start-Process $CHROME_EXE -ArgumentList "--kiosk", "--no-first-run", "--disable-infobars", "--noerrdialogs", $CHROME_URL

# ─── Keep running, stream output until Ctrl+C ────────────────────────────────
Write-Host "[start] Running. Press Ctrl+C to stop."
try {
    while ($true) {
        Receive-Job $pythonJob -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "[python] $_" }
        Receive-Job $npmJob    -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "[npm] $_" }
        Start-Sleep -Seconds 1
    }
} finally {
    Stop-All
}
