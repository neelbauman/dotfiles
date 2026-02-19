use anyhow::Result;
use std::path::Path;
use std::process::Command;

use crate::output;
use crate::platform::Platform;

/// Run hook scripts (install.sh on Unix, install.ps1 on Windows).
/// Returns Ok(true) if a hook was found (and executed or previewed), Ok(false) if none.
pub fn run_hooks(topic_dir: &Path, dry_run: bool, verbose: bool) -> Result<bool> {
    let platform = Platform::current();

    let script = match platform {
        Platform::Windows => topic_dir.join("install.ps1"),
        _ => topic_dir.join("install.sh"),
    };

    if !script.exists() {
        return Ok(false);
    }

    if dry_run {
        output::dry_run_prefix(&format!("フック実行: {}", script.display()));
        return Ok(true);
    }

    if verbose {
        output::info(&format!("フック実行: {}", script.display()));
    }

    let status = match platform {
        Platform::Windows => Command::new("powershell")
            .args(["-ExecutionPolicy", "Bypass", "-File"])
            .arg(&script)
            .status()?,
        _ => Command::new("bash").arg(&script).status()?,
    };

    if !status.success() {
        output::warn(&format!(
            "フックが非ゼロで終了: {} (code: {:?})",
            script.display(),
            status.code()
        ));
    }

    Ok(true)
}
