# prompty/install.ps1 — Prompty CLI インストールフック (Windows)

function Install-Prompty {
    if (Get-Command prompty -ErrorAction SilentlyContinue) {
        Write-Host "prompty is already installed. Skipping."
        return
    }

    Write-Host "Installing prompty..."

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Error "'uv' is not installed. Please install uv first."
        return
    }

    $repoDir = Join-Path $env:USERPROFILE ".local\src\prompty"
    $targetPackage = Join-Path $repoDir "runtime\prompty"

    if (-not (Test-Path $repoDir)) {
        Write-Host "Cloning prompty repository to $repoDir..."
        $parentDir = Split-Path $repoDir -Parent
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        git clone https://github.com/neelbauman/prompty.git $repoDir
    } else {
        Write-Host "Prompty repository already exists at $repoDir. Pulling latest..."
        git -C $repoDir pull
    }

    Write-Host "Running uv tool install..."
    uv tool install `
        --with typing_extensions `
        --with openai `
        --python 3.10 `
        --force `
        $targetPackage
}

Install-Prompty
