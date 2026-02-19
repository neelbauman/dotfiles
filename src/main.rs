mod config;
mod convention;
mod discovery;
mod hooks;
mod linker;
mod output;
mod platform;

use anyhow::Result;
use clap::Parser;
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "dotfiles-installer", about = "Cross-platform dotfiles installer")]
struct Cli {
    /// プレビューモード（実際のリンク作成を行わない）
    #[arg(short = 'n', long)]
    dry_run: bool,

    /// 詳細出力
    #[arg(short, long)]
    verbose: bool,

    /// 特定トピックのみインストール（複数指定可）
    #[arg(short, long)]
    topic: Option<Vec<String>>,

    /// dotfilesディレクトリ指定
    #[arg(long)]
    dotfiles_dir: Option<PathBuf>,

    /// フック実行スキップ
    #[arg(long)]
    no_hooks: bool,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    let dotfiles_dir = match cli.dotfiles_dir {
        Some(ref d) => d.clone(),
        None => {
            // バイナリの位置からリポジトリルートを推定
            // target/release/ や target/debug/ 内にある場合は祖先を辿る
            let exe = std::env::current_exe()?;
            let mut found = None;
            let mut dir = exe.parent();
            while let Some(d) = dir {
                if d.join("Cargo.toml").exists() && d.join(".git").exists() {
                    found = Some(d.to_path_buf());
                    break;
                }
                dir = d.parent();
            }
            found.unwrap_or_else(|| std::env::current_dir().unwrap())
        }
    };

    let current_platform = platform::Platform::current();

    if cli.dry_run {
        output::info(&format!("ドライランモード (プラットフォーム: {})", current_platform.name()));
    } else {
        output::info(&format!("dotfiles セットアップ開始 (プラットフォーム: {})", current_platform.name()));
    }
    output::info(&format!("dotfiles ディレクトリ: {}", dotfiles_dir.display()));

    let topics = discovery::discover_topics(&dotfiles_dir, &cli.topic)?;

    if topics.is_empty() {
        output::warn("トピックが見つかりませんでした");
        return Ok(());
    }

    let mut stats = linker::Stats::default();

    for topic_dir in &topics {
        let topic_name = topic_dir
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("unknown");

        output::topic_header(topic_name);

        // Load optional topic.toml
        let topic_config = config::TopicConfig::load(topic_dir)?;

        // Platform check
        if let Some(ref cfg) = topic_config {
            if !cfg.is_platform_allowed(current_platform.name()) {
                output::skip(&format!("プラットフォーム非対応: {}", current_platform.name()));
                continue;
            }
        }

        let config = topic_config.unwrap_or_default();

        // Resolve link actions
        let mut actions = Vec::new();

        // Custom links from topic.toml
        if !config.links.is_empty() {
            let custom = convention::resolve_custom_links(topic_dir, &config.links)?;
            actions.extend(custom);
        }

        // Convention rules
        if config.should_use_conventions() {
            let conv = convention::resolve_conventions(topic_dir)?;
            actions.extend(conv);
        }

        // Execute link actions
        if !actions.is_empty() {
            linker::execute_actions(&actions, cli.dry_run, cli.verbose, &mut stats);
        }

        // Run hooks (even if no link actions)
        let has_hook = if !cli.no_hooks {
            match hooks::run_hooks(topic_dir, cli.dry_run, cli.verbose) {
                Ok(ran) => ran,
                Err(e) => {
                    output::error(&format!("フックエラー: {}", e));
                    stats.errors += 1;
                    false
                }
            }
        } else {
            false
        };

        if actions.is_empty() && !has_hook {
            output::skip("設定なし、スキップ");
        }
    }

    output::summary(stats.linked, stats.skipped, stats.backed_up, stats.errors);

    Ok(())
}
