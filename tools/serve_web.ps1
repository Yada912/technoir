# Memoirs of Technoir — export (optional) + serve HTML5 build for browser/touch testing.
param(
    [string]$Godot = $env:GODOT,
    [int]$Port = 8060,
    [switch]$Export
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$OutDir = Join-Path $Root "build\web"
$Index = Join-Path $OutDir "index.html"

function Find-Godot {
    if ($Godot -and (Test-Path $Godot)) { return $Godot }
    $candidates = @(
        "godot",
        "godot4",
        "$env:LOCALAPPDATA\Programs\Godot\Godot*.exe",
        "$env:USERPROFILE\Downloads\Godot*.exe",
        "C:\Godot\Godot*.exe"
    )
    foreach ($c in $candidates) {
        if ($c -like "*`**") {
            $hit = Get-Item $c -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($hit) { return $hit.FullName }
        } else {
            $cmd = Get-Command $c -ErrorAction SilentlyContinue
            if ($cmd) { return $cmd.Source }
        }
    }
    return $null
}

if ($Export) {
    $exe = Find-Godot
    if (-not $exe) {
        Write-Host "Godot not found. Install Godot 4.3+ (standard), open the project, then Project > Export > Web to build/web/index.html"
        Write-Host "Or set GODOT env var to your Godot.exe and re-run with -Export"
        exit 1
    }
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    Write-Host "Exporting Web with: $exe"
    & $exe --headless --path $Root --export-release "Web" $Index
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Export failed. Export once from the editor to download export templates, then retry."
        exit $LASTEXITCODE
    }
}

if (-not (Test-Path $Index)) {
    Write-Host "Missing $Index"
    Write-Host "1) Open project in Godot 4 (Compatibility)"
    Write-Host "2) Install Web export templates"
    Write-Host "3) Export preset 'Web' to build/web/index.html"
    Write-Host "4) Re-run: powershell -File tools/serve_web.ps1"
    Write-Host ""
    Write-Host "Editor play (no web): open project.godot and press F5"
    exit 1
}

Write-Host "Serving $OutDir at http://127.0.0.1:$Port/"
Write-Host "Use a touch laptop or DevTools device mode. Ctrl+C to stop."
Set-Location $OutDir

function Test-RealPython([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) { return $false }
    # Skip Windows Store app-execution alias stubs
    if ($cmd.Source -match "WindowsApps\\python") { return $false }
    & $Name -c "import http.server" 2>$null
    return ($LASTEXITCODE -eq 0)
}

$served = $false
if (Test-RealPython "py") {
    py -m http.server $Port
    $served = $true
} elseif (Test-RealPython "python") {
    python -m http.server $Port
    $served = $true
} elseif (Get-Command npx -ErrorAction SilentlyContinue) {
    npx --yes serve -l $Port .
    $served = $true
}

if (-not $served) {
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://127.0.0.1:$Port/")
    $listener.Start()
    Write-Host "PowerShell HttpListener ready."
    try {
        while ($listener.IsListening) {
            $ctx = $listener.GetContext()
            $path = $ctx.Request.Url.LocalPath.TrimStart("/")
            if ([string]::IsNullOrWhiteSpace($path)) { $path = "index.html" }
            $file = Join-Path $OutDir ($path -replace "/", [IO.Path]::DirectorySeparatorChar)
            if (-not (Test-Path -LiteralPath $file)) {
                $ctx.Response.StatusCode = 404
                $ctx.Response.Close()
                continue
            }
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $ext = [System.IO.Path]::GetExtension($file).ToLowerInvariant()
            $ctx.Response.ContentType = switch ($ext) {
                ".html" { "text/html" }
                ".js" { "application/javascript" }
                ".wasm" { "application/wasm" }
                ".pck" { "application/octet-stream" }
                ".png" { "image/png" }
                ".svg" { "image/svg+xml" }
                default { "application/octet-stream" }
            }
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            $ctx.Response.Close()
        }
    } finally {
        $listener.Stop()
    }
}
