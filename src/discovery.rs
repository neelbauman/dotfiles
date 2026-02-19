use anyhow::Result;
use std::path::{Path, PathBuf};

const EXCLUDED: &[&str] = &["vim", "dev"];

pub fn discover_topics(dotfiles_dir: &Path, filter: &Option<Vec<String>>) -> Result<Vec<PathBuf>> {
    let mut topics = Vec::new();

    let topics_dir = dotfiles_dir.join("topics");
    for entry in std::fs::read_dir(&topics_dir)? {
        let entry = entry?;
        let path = entry.path();

        if !path.is_dir() {
            continue;
        }

        let name = match path.file_name().and_then(|n| n.to_str()) {
            Some(n) => n.to_string(),
            None => continue,
        };

        // Skip hidden dirs and excluded entries
        if name.starts_with('.') || EXCLUDED.contains(&name.as_str()) {
            continue;
        }

        // If filter is specified, only include matching topics
        if let Some(ref allowed) = filter {
            if !allowed.iter().any(|a| a == &name) {
                continue;
            }
        }

        topics.push(path);
    }

    topics.sort();
    Ok(topics)
}
