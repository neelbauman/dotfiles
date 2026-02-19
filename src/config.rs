use anyhow::Result;
use serde::Deserialize;
use std::path::Path;

#[derive(Debug, Deserialize, Default)]
pub struct TopicConfig {
    /// Restrict this topic to specific platforms (empty = all)
    #[serde(default)]
    pub platforms: Vec<String>,

    /// Explicitly control convention rules.
    /// - None (not set): conventions used if no [[links]], skipped if [[links]] present
    /// - Some(true): always skip conventions
    /// - Some(false): always use conventions (even with [[links]])
    pub skip_conventions: Option<bool>,

    /// Custom link entries
    #[serde(default)]
    pub links: Vec<LinkEntry>,
}

#[derive(Debug, Deserialize, Clone)]
pub struct LinkEntry {
    pub source: String,
    pub target: String,
}

impl TopicConfig {
    pub fn load(topic_dir: &Path) -> Result<Option<Self>> {
        let config_path = topic_dir.join("topic.toml");
        if !config_path.exists() {
            return Ok(None);
        }

        let content = std::fs::read_to_string(&config_path)?;
        let config: TopicConfig = toml::from_str(&content)?;
        Ok(Some(config))
    }

    /// Check if this topic should run on the current platform
    pub fn is_platform_allowed(&self, current: &str) -> bool {
        if self.platforms.is_empty() {
            return true;
        }
        self.platforms.iter().any(|p| p == current)
    }

    /// Whether convention rules should be applied
    pub fn should_use_conventions(&self) -> bool {
        match self.skip_conventions {
            Some(true) => false,
            Some(false) => true,
            None => self.links.is_empty(),
        }
    }
}
