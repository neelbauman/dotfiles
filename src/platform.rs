use anyhow::{Context, Result};
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Platform {
    Linux,
    MacOS,
    Windows,
}

impl Platform {
    pub fn current() -> Self {
        if cfg!(target_os = "windows") {
            Platform::Windows
        } else if cfg!(target_os = "macos") {
            Platform::MacOS
        } else {
            Platform::Linux
        }
    }

    pub fn name(&self) -> &'static str {
        match self {
            Platform::Linux => "linux",
            Platform::MacOS => "macos",
            Platform::Windows => "windows",
        }
    }
}

pub fn home_dir() -> Result<PathBuf> {
    dirs::home_dir().context("ホームディレクトリが見つかりません")
}

pub fn config_dir() -> Result<PathBuf> {
    let platform = Platform::current();
    match platform {
        Platform::Linux | Platform::MacOS => {
            let home = home_dir()?;
            Ok(home.join(".config"))
        }
        Platform::Windows => {
            dirs::config_dir().context("設定ディレクトリが見つかりません")
        }
    }
}

pub fn bin_dir() -> Result<PathBuf> {
    let home = home_dir()?;
    Ok(home.join(".local").join("bin"))
}

pub fn create_symlink(source: &Path, target: &Path) -> Result<()> {
    #[cfg(unix)]
    {
        std::os::unix::fs::symlink(source, target)
            .with_context(|| format!("symlink作成失敗: {} -> {}", source.display(), target.display()))?;
    }

    #[cfg(windows)]
    {
        // Try symlink first, fall back to copy
        let result = if source.is_dir() {
            std::os::windows::fs::symlink_dir(source, target)
        } else {
            std::os::windows::fs::symlink_file(source, target)
        };

        if let Err(_) = result {
            // Fallback: copy instead
            if source.is_dir() {
                copy_dir_recursive(source, target)?;
            } else {
                std::fs::copy(source, target).with_context(|| {
                    format!("コピー失敗: {} -> {}", source.display(), target.display())
                })?;
            }
        }
    }

    Ok(())
}

#[cfg(windows)]
fn copy_dir_recursive(src: &Path, dst: &Path) -> Result<()> {
    std::fs::create_dir_all(dst)?;
    for entry in std::fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        let dst_path = dst.join(entry.file_name());
        if ty.is_dir() {
            copy_dir_recursive(&entry.path(), &dst_path)?;
        } else {
            std::fs::copy(entry.path(), &dst_path)?;
        }
    }
    Ok(())
}

pub fn is_symlink(path: &Path) -> bool {
    path.symlink_metadata()
        .map(|m| m.file_type().is_symlink())
        .unwrap_or(false)
}

pub fn read_link(path: &Path) -> Result<PathBuf> {
    std::fs::read_link(path).with_context(|| format!("リンク読み取り失敗: {}", path.display()))
}
