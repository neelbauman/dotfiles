use anyhow::Result;
use chrono::Local;

use crate::convention::LinkAction;
use crate::output;
use crate::platform;

#[derive(Default)]
pub struct Stats {
    pub linked: usize,
    pub skipped: usize,
    pub backed_up: usize,
    pub errors: usize,
}

pub fn execute_actions(actions: &[LinkAction], dry_run: bool, verbose: bool, stats: &mut Stats) {
    for action in actions {
        if let Err(e) = execute_one(action, dry_run, verbose, stats) {
            output::error(&format!("{}: {}", action.target.display(), e));
            stats.errors += 1;
        }
    }
}

fn execute_one(action: &LinkAction, dry_run: bool, verbose: bool, stats: &mut Stats) -> Result<()> {
    let source = &action.source;
    let target = &action.target;

    if !source.exists() {
        if verbose {
            output::skip(&format!("ソースが存在しません: {}", source.display()));
        }
        return Ok(());
    }

    // Idempotency: already correct symlink?
    if platform::is_symlink(target) {
        let link_dest = platform::read_link(target)?;
        if link_dest == source.as_path() {
            stats.skipped += 1;
            if verbose {
                output::skip(&format!("既にリンク済み: {}", target.display()));
            }
            return Ok(());
        }
    }

    if dry_run {
        output::dry_run_prefix(&format!(
            "{} -> {}",
            source.display(),
            target.display()
        ));
        stats.linked += 1;
        return Ok(());
    }

    // Ensure parent directory exists
    if let Some(parent) = target.parent() {
        std::fs::create_dir_all(parent)?;
    }

    // Backup existing file/directory (not symlink)
    if target.exists() && !platform::is_symlink(target) {
        let timestamp = Local::now().format("%Y%m%d_%H%M%S");
        let backup_name = format!(
            "{}.backup_{}",
            target.file_name().unwrap_or_default().to_string_lossy(),
            timestamp
        );
        let backup_path = target.parent().unwrap().join(backup_name);
        std::fs::rename(target, &backup_path)?;
        output::warn(&format!("バックアップ: {}", backup_path.display()));
        stats.backed_up += 1;
    }

    // Remove existing symlink if it points elsewhere
    if platform::is_symlink(target) {
        std::fs::remove_file(target)?;
    }

    platform::create_symlink(source, target)?;
    output::success(&format!(
        "{} -> {}",
        source.display(),
        target.display()
    ));
    stats.linked += 1;

    Ok(())
}
