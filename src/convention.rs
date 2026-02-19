use anyhow::Result;
use std::path::{Path, PathBuf};

use crate::platform;

/// A planned link action: source -> target
#[derive(Debug, Clone)]
pub struct LinkAction {
    pub source: PathBuf,
    pub target: PathBuf,
}

/// Resolve Convention rules for a topic directory.
/// Returns empty vec if no convention subdirs found.
pub fn resolve_conventions(topic_dir: &Path) -> Result<Vec<LinkAction>> {
    let mut actions = Vec::new();

    // 1. config/ -> ~/.config/
    let config_sub = topic_dir.join("config");
    if config_sub.is_dir() {
        let config_target = platform::config_dir()?;
        for entry in std::fs::read_dir(&config_sub)? {
            let entry = entry?;
            let source = entry.path();
            let name = entry.file_name();
            let target = config_target.join(&name);
            actions.push(LinkAction { source, target });
        }
    }

    // 2. home/ -> ~/ (prepend dot if missing)
    let home_sub = topic_dir.join("home");
    if home_sub.is_dir() {
        let home = platform::home_dir()?;
        for entry in std::fs::read_dir(&home_sub)? {
            let entry = entry?;
            let source = entry.path();
            let name_os = entry.file_name();
            let name = name_os.to_string_lossy();
            let target_name = if name.starts_with('.') {
                name.to_string()
            } else {
                format!(".{}", name)
            };
            let target = home.join(&target_name);
            actions.push(LinkAction { source, target });
        }
    }

    // 3. bin/ -> ~/.local/bin/
    let bin_sub = topic_dir.join("bin");
    if bin_sub.is_dir() {
        let bin_target = platform::bin_dir()?;
        for entry in std::fs::read_dir(&bin_sub)? {
            let entry = entry?;
            let source = entry.path();
            let name = entry.file_name();
            let target = bin_target.join(&name);
            actions.push(LinkAction { source, target });
        }
    }

    Ok(actions)
}

/// Resolve custom links defined in topic.toml
pub fn resolve_custom_links(
    topic_dir: &Path,
    links: &[crate::config::LinkEntry],
) -> Result<Vec<LinkAction>> {
    let home = platform::home_dir()?;
    let mut actions = Vec::new();

    for link in links {
        let source_path = topic_dir.join(&link.source);

        // Expand ~ in target
        let target_str = link.target.replace('~', &home.to_string_lossy());
        let target_path = PathBuf::from(&target_str);

        // Handle glob patterns
        if link.source.contains('*') {
            let pattern = topic_dir.join(&link.source).to_string_lossy().to_string();
            for entry in glob::glob(&pattern)? {
                let entry = entry?;
                let fname = entry
                    .file_name()
                    .map(|n| n.to_owned())
                    .unwrap_or_default();
                actions.push(LinkAction {
                    source: entry,
                    target: target_path.join(fname),
                });
            }
        } else {
            actions.push(LinkAction {
                source: source_path,
                target: target_path,
            });
        }
    }

    Ok(actions)
}
