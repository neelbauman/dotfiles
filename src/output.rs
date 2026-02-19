use colored::Colorize;

pub fn info(msg: &str) {
    println!("{} {}", "•".blue(), msg);
}

pub fn success(msg: &str) {
    println!("  {} {}", "✓".green(), msg);
}

pub fn skip(msg: &str) {
    println!("  {} {}", "–".dimmed(), msg.dimmed());
}

pub fn warn(msg: &str) {
    println!("  {} {}", "!".yellow(), msg);
}

pub fn error(msg: &str) {
    eprintln!("  {} {}", "✗".red(), msg);
}

pub fn topic_header(name: &str) {
    println!("\n{}", format!("[{}]", name).cyan().bold());
}

pub fn dry_run_prefix(msg: &str) {
    println!("  {} {}", "(dry-run)".magenta(), msg);
}

pub fn summary(linked: usize, skipped: usize, backed_up: usize, errors: usize) {
    println!();
    println!("{}", "── Summary ──────────────────────".bold());
    println!("  Linked:    {}", linked.to_string().green());
    println!("  Skipped:   {}", skipped.to_string().dimmed());
    println!("  Backed up: {}", backed_up.to_string().yellow());
    if errors > 0 {
        println!("  Errors:    {}", errors.to_string().red());
    }
    println!();
}
