# install.ps1 — dotfiles ブートストラップスクリプト (Windows)
#
# ワンライナー:
#   irm https://raw.githubusercontent.com/neelbauman/dotfiles/main/install.ps1 | iex
#
# 処理フロー:
#   1. dotfiles リポジトリをクローン（既にあれば pull）
#   2. GitHub Releases から最新バイナリをダウンロード
#   3. バイナリがなければ cargo build --release にフォールバック
#   4. それもなければ PowerShell フォールバック

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/neelbauman/dotfiles.git"
$DOTFILES_DIR = if ($env:DOTFILES_DIR) { $env:DOTFILES_DIR } else { Join-Path $env:USERPROFILE "dotfiles" }
$BIN_DIR = Join-Path $DOTFILES_DIR "bin"
$INSTALLER_BIN = Join-Path $BIN_DIR "dotfiles-installer.exe"
$GITHUB_REPO = "neelbauman/dotfiles"

# ---------------------------------------------------------
# ヘルパー関数
# ---------------------------------------------------------
function Write-Info  { param([string]$Msg) Write-Host "[INFO] $Msg" -ForegroundColor Blue }
function Write-Warn  { param([string]$Msg) Write-Host "[WARN] $Msg" -ForegroundColor Yellow }
function Write-Err   { param([string]$Msg) Write-Host "[ERROR] $Msg" -ForegroundColor Red }

function Detect-Target {
    return "x86_64-pc-windows-msvc"
}

# ---------------------------------------------------------
# 1. リポジトリの取得
# ---------------------------------------------------------
function Clone-OrPull {
    if (Test-Path (Join-Path $DOTFILES_DIR ".git")) {
        Write-Info "既存リポジトリを更新中: $DOTFILES_DIR"
        git -C $DOTFILES_DIR pull --rebase --quiet
    } else {
        Write-Info "リポジトリをクローン中: $DOTFILES_DIR"
        git clone $REPO_URL $DOTFILES_DIR
    }
}

# ---------------------------------------------------------
# 2. GitHub Releases からバイナリをダウンロード
# ---------------------------------------------------------
function Download-Binary {
    $target = Detect-Target
    $assetName = "dotfiles-installer-${target}.zip"

    Write-Info "最新リリースを確認中..."

    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" -Headers @{ "User-Agent" = "dotfiles-installer" }
    } catch {
        Write-Warn "リリース情報の取得に失敗しました"
        return $false
    }

    $asset = $release.assets | Where-Object { $_.name -eq $assetName } | Select-Object -First 1

    if (-not $asset) {
        Write-Warn "リリースバイナリが見つかりません ($assetName)"
        return $false
    }

    $url = $asset.browser_download_url
    $zipPath = Join-Path $env:TEMP "dotfiles-installer.zip"

    Write-Info "バイナリをダウンロード中: $assetName"

    if (-not (Test-Path $BIN_DIR)) {
        New-Item -ItemType Directory -Path $BIN_DIR -Force | Out-Null
    }

    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $BIN_DIR -Force
    Remove-Item $zipPath -Force

    Write-Info "ダウンロード完了: $INSTALLER_BIN"
    return $true
}

# ---------------------------------------------------------
# 3. cargo build フォールバック
# ---------------------------------------------------------
function Cargo-Build {
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        return $false
    }

    $cargoToml = Join-Path $DOTFILES_DIR "Cargo.toml"
    if (-not (Test-Path $cargoToml)) {
        return $false
    }

    Write-Info "Rust インストーラーをビルド中..."
    cargo build --release --manifest-path $cargoToml

    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    if (-not (Test-Path $BIN_DIR)) {
        New-Item -ItemType Directory -Path $BIN_DIR -Force | Out-Null
    }

    $builtBin = Join-Path $DOTFILES_DIR "target\release\dotfiles-installer.exe"
    Copy-Item $builtBin $INSTALLER_BIN -Force
    Write-Info "ビルド完了: $INSTALLER_BIN"
    return $true
}

# ---------------------------------------------------------
# 4. PowerShell フォールバック
# ---------------------------------------------------------
function PowerShell-Fallback {
    Write-Warn "Rust installer not available, using PowerShell fallback..."

    function Link-File {
        param(
            [string]$SourcePath,
            [string]$TargetPath
        )

        if (-not (Test-Path $SourcePath)) { return }

        $parentDir = Split-Path $TargetPath -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }

        if ((Test-Path $TargetPath) -and -not ((Get-Item $TargetPath).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "${TargetPath}.backup_${timestamp}"
            Write-Host "Backing up $TargetPath..."
            Move-Item $TargetPath $backupPath
        }

        if (Test-Path $TargetPath) {
            Remove-Item $TargetPath -Force
        }

        New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath -Force | Out-Null
        Write-Host "Linked: $SourcePath -> $TargetPath"
    }

    function Process-DefaultConvention {
        param([string]$TopicDir)

        $topicName = Split-Path $TopicDir -Leaf
        $processed = $false

        # config/ → ~/.config/ (Windows: %APPDATA%)
        $configDir = Join-Path $TopicDir "config"
        if (Test-Path $configDir) {
            Write-Host "  [Auto] Found config/ in $topicName"
            foreach ($item in Get-ChildItem $configDir) {
                $targetPath = Join-Path $env:APPDATA $item.Name
                Link-File -SourcePath $item.FullName -TargetPath $targetPath
            }
            $processed = $true
        }

        # home/ → ~/ (Windows: %USERPROFILE%)
        $homeDir = Join-Path $TopicDir "home"
        if (Test-Path $homeDir) {
            Write-Host "  [Auto] Found home/ in $topicName"
            foreach ($item in Get-ChildItem $homeDir) {
                $fname = $item.Name
                if (-not $fname.StartsWith(".")) {
                    $targetPath = Join-Path $env:USERPROFILE ".$fname"
                } else {
                    $targetPath = Join-Path $env:USERPROFILE $fname
                }
                Link-File -SourcePath $item.FullName -TargetPath $targetPath
            }
            $processed = $true
        }

        # bin/ → ~/.local/bin/
        $binDir = Join-Path $TopicDir "bin"
        if (Test-Path $binDir) {
            Write-Host "  [Auto] Found bin/ in $topicName"
            $localBin = Join-Path $env:USERPROFILE ".local\bin"
            foreach ($item in Get-ChildItem $binDir) {
                $targetPath = Join-Path $localBin $item.Name
                Link-File -SourcePath $item.FullName -TargetPath $targetPath
            }
            $processed = $true
        }

        if (-not $processed) {
            Write-Host "  (No configuration found for $topicName, skipping)"
        }
    }

    Write-Host "Starting dotfiles setup (PowerShell fallback)..."

    $excludedTopics = @("vim", "dev")

    foreach ($topicDir in Get-ChildItem (Join-Path $DOTFILES_DIR "topics") -Directory) {
        $topicName = $topicDir.Name

        if ($topicName.StartsWith(".") -or $excludedTopics -contains $topicName) {
            continue
        }

        Write-Host "Checking topic: $topicName"

        Process-DefaultConvention -TopicDir $topicDir.FullName

        $hookScript = Join-Path $topicDir.FullName "install.ps1"
        if (Test-Path $hookScript) {
            Write-Host "  [Hook] Running install.ps1 in $topicName..."
            & $hookScript
        }
    }

    Write-Host "Setup complete!"
}

# ---------------------------------------------------------
# メインフロー
# ---------------------------------------------------------
function Main {
    # ワンライナー実行時はクローンから開始
    # ローカル実行時（$PSScriptRoot が存在）はクローン不要
    if (-not $PSScriptRoot -or -not (Test-Path (Join-Path $PSScriptRoot ".git"))) {
        Clone-OrPull
    } else {
        $script:DOTFILES_DIR = $PSScriptRoot
        $script:BIN_DIR = Join-Path $DOTFILES_DIR "bin"
        $script:INSTALLER_BIN = Join-Path $BIN_DIR "dotfiles-installer.exe"
    }

    # 既にバイナリがあればそのまま実行
    if (Test-Path $INSTALLER_BIN) {
        Write-Info "既存バイナリを使用: $INSTALLER_BIN"
        & $INSTALLER_BIN --dotfiles-dir $DOTFILES_DIR @args
        return
    }

    # GitHub Releases からダウンロード → 実行
    try {
        if (Download-Binary) {
            & $INSTALLER_BIN --dotfiles-dir $DOTFILES_DIR @args
            return
        }
    } catch {
        Write-Warn "バイナリダウンロードに失敗しました: $_"
    }

    # cargo build → 実行
    if (Cargo-Build) {
        & $INSTALLER_BIN --dotfiles-dir $DOTFILES_DIR @args
        return
    }

    # PowerShell フォールバック
    PowerShell-Fallback
}

Main @args
