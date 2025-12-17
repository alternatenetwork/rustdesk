use hbb_common::log;
use rdev::{Event, EventType, Key};
use std::collections::HashSet;
use std::fs;
use std::path::Path;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Shortcut {
    pub ctrl: bool,
    pub alt: bool,
    pub shift: bool,
    pub key: String,
}

lazy_static::lazy_static! {
    static ref PASSWORD_MANAGER_SHORTCUTS: HashSet<Shortcut> = load_shortcuts();
}

fn load_shortcuts() -> HashSet<Shortcut> {
    let mut shortcuts = HashSet::new();
    
    // Default shortcuts
    shortcuts.insert(Shortcut { ctrl: true, alt: true, shift: false, key: "A".to_string() }); // KeePass
    shortcuts.insert(Shortcut { ctrl: true, alt: false, shift: true, key: "A".to_string() }); // RDM
    shortcuts.insert(Shortcut { ctrl: true, alt: false, shift: true, key: "L".to_string() }); // Bitwarden
    shortcuts.insert(Shortcut { ctrl: true, alt: false, shift: false, key: "Backslash".to_string() }); // 1Password
    shortcuts.insert(Shortcut { ctrl: false, alt: true, shift: false, key: "G".to_string() }); // LastPass
    shortcuts.insert(Shortcut { ctrl: true, alt: true, shift: false, key: "P".to_string() }); // Generic
    shortcuts.insert(Shortcut { ctrl: true, alt: false, shift: true, key: "P".to_string() }); // Generic
    
    // Try to load from config file
    let config_path = "password_manager_shortcuts.txt";
    if Path::new(config_path).exists() {
        match fs::read_to_string(config_path) {
            Ok(content) => {
                log::info!("Loading password manager shortcuts from {}", config_path);
                for line in content.lines() {
                    let line = line.trim();
                    if line.is_empty() || line.starts_with('#') {
                        continue;
                    }
                    
                    if let Some(shortcut) = parse_shortcut_line(line) {
                        log::debug!("Loaded shortcut: {:?}", shortcut);
                        shortcuts.insert(shortcut);
                    }
                }
            }
            Err(e) => {
                log::warn!("Failed to load password manager shortcuts config: {}", e);
            }
        }
    } else {
        log::info!("No password_manager_shortcuts.txt found, using default shortcuts");
    }
    
    log::info!("Loaded {} password manager shortcuts", shortcuts.len());
    shortcuts
}

fn parse_shortcut_line(line: &str) -> Option<Shortcut> {
    let parts: Vec<&str> = line.split('+').map(|s| s.trim()).collect();
    if parts.len() < 2 {
        log::warn!("Invalid shortcut format: {}", line);
        return None;
    }
    
    let mut ctrl = false;
    let mut alt = false;
    let mut shift = false;
    let mut key = String::new();
    
    for (i, part) in parts.iter().enumerate() {
        if i == parts.len() - 1 {
            // Last part is the key
            key = part.to_string();
        } else {
            // Modifiers
            match part.to_lowercase().as_str() {
                "ctrl" | "control" => ctrl = true,
                "alt" => alt = true,
                "shift" => shift = true,
                _ => {
                    log::warn!("Unknown modifier: {}", part);
                    return None;
                }
            }
        }
    }
    
    if key.is_empty() {
        return None;
    }
    
    Some(Shortcut { ctrl, alt, shift, key })
}

pub fn is_password_manager_shortcut(event: &Event) -> bool {
    match event.event_type {
        EventType::KeyPress(key) => {
            let ctrl = rdev::get_modifier(Key::ControlLeft) || rdev::get_modifier(Key::ControlRight);
            let alt = rdev::get_modifier(Key::Alt) || rdev::get_modifier(Key::AltGr);
            let shift = rdev::get_modifier(Key::ShiftLeft) || rdev::get_modifier(Key::ShiftRight);
            
            // Get key name
            let key_name = match key {
                Key::KeyA => "A",
                Key::KeyB => "B",
                Key::KeyC => "C",
                Key::KeyD => "D",
                Key::KeyE => "E",
                Key::KeyF => "F",
                Key::KeyG => "G",
                Key::KeyH => "H",
                Key::KeyI => "I",
                Key::KeyJ => "J",
                Key::KeyK => "K",
                Key::KeyL => "L",
                Key::KeyM => "M",
                Key::KeyN => "N",
                Key::KeyO => "O",
                Key::KeyP => "P",
                Key::KeyQ => "Q",
                Key::KeyR => "R",
                Key::KeyS => "S",
                Key::KeyT => "T",
                Key::KeyU => "U",
                Key::KeyV => "V",
                Key::KeyW => "W",
                Key::KeyX => "X",
                Key::KeyY => "Y",
                Key::KeyZ => "Z",
                Key::BackSlash => "Backslash",
                _ => return false,
            };
            
            let current_shortcut = Shortcut {
                ctrl,
                alt,
                shift,
                key: key_name.to_string(),
            };
            
            if PASSWORD_MANAGER_SHORTCUTS.contains(&current_shortcut) {
                log::info!("Password manager shortcut detected: Ctrl={}, Alt={}, Shift={}, Key={}",
                    ctrl, alt, shift, key_name);
                true
            } else {
                false
            }
        }
        _ => false
    }
}