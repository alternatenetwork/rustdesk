# RustDesk Password Manager Autotype Fix

This modified version of RustDesk enables password manager autotype functionality while preventing trigger shortcuts from being sent to the remote machine.

## Problem Solved

Original issues:
1. Password managers (KeePass, Bitwarden, etc.) couldn't send autotype keystrokes through RustDesk
2. When fixed, the trigger shortcuts (like Ctrl+Shift+A) were also sent to the remote machine
3. Modifier keys (Ctrl/Shift/Alt) were getting stuck on the remote side

## Solution Implemented

### 1. Allow Password Manager Autotype
- Modified keyboard event handling to always pass events to local system
- Ensures password managers can receive their trigger shortcuts
- Location: `src/keyboard.rs` line ~467-495

### 2. Block Only Trigger Shortcuts
- Added simple detection for password manager shortcut combinations
- Only the final key press of shortcuts is blocked from remote (e.g., 'A' in Ctrl+Shift+A)
- Modifier keys themselves are sent normally to maintain proper state
- Location: `src/keyboard.rs` function `is_password_manager_shortcut_simple()`

### 3. Fix Scan Code Issues  
- Password managers often send simulated keystrokes with scan code 0
- Added automatic scan code generation using Windows MapVirtualKeyW API
- Converts virtual key codes to proper scan codes before sending to remote
- Handles two cases:
  - Scan code 0: Uses MapVirtualKeyW to generate proper scan code
  - Scan code = platform code: ASCII codes being used incorrectly
- Location: `src/keyboard.rs` lines ~316-391

### 4. Handle Capitalization for ASCII-based Password Managers
- Some password managers send raw ASCII codes where uppercase ≠ lowercase
- Added logic to inject and release Shift key for uppercase letters
- Preserves correct capitalization when password manager sends ASCII codes
- Location: `src/keyboard.rs` lines ~335-457

### 5. Enhanced Logging
- Added info-level logs for detected password manager shortcuts
- Added debug-level logs for all key presses with scan codes
- Added trace-level logs for key releases and remote transmission
- Added debug logs when fixing scan code 0 issues

## Blocked Shortcuts and Keys

### Password Manager Shortcuts
The following shortcuts will trigger password managers locally but won't be sent to the remote machine:

| Shortcut | Password Manager |
|----------|------------------|
| Ctrl+Alt+A | KeePass/KeePassXC (Global Autotype) |
| Ctrl+Shift+A | Remote Desktop Manager |
| Ctrl+Shift+L | Bitwarden |
| Ctrl+\ | 1Password |
| Alt+G | LastPass |
| Ctrl+Alt+P | Generic/Custom |
| Ctrl+Shift+P | Generic/Custom |

### System Keys Blocked from Remote
The following keys/shortcuts are blocked from being sent to the remote machine to keep them on the host:

| Key/Shortcut | Purpose |
|--------------|---------|
| Windows Key (Left/Right) | Prevents opening remote Start menu |
| Alt+Tab | Keeps task switching on host machine |

## Building from Source

### Prerequisites
- Rust/Cargo (https://rustup.rs/)
- Python 3.x
- Visual Studio Build Tools (Windows)
- vcpkg (for dependencies)
- Flutter (optional, for Flutter UI)

### Build Commands

Using provided scripts:
```bash
# Windows Batch
build_rustdesk_complete.bat

# PowerShell
./build_rustdesk.ps1

# Simple batch
build_rustdesk_windows.bat
```

Manual build:
```bash
# Basic build
cargo build --release

# With Flutter UI
cargo build --release --features flutter

# Using Python build script
python build.py --flutter --release
```

## Installation

1. Close all running instances of RustDesk
2. Locate the built executable: `target/release/rustdesk.exe`
3. Replace your existing rustdesk.exe with the newly built one
4. Run the new rustdesk.exe

## Testing

1. Connect to a remote machine using RustDesk
2. Focus a text field on the remote machine
3. Trigger your password manager's autotype (e.g., Ctrl+Shift+A)
4. The password should be typed on the remote machine
5. The trigger shortcut itself should NOT appear in the remote text field

## Logging

To see the password manager detection logs:
- Set environment variable: `RUST_LOG=rustdesk=debug`
- Run RustDesk from command line to see console output
- Look for messages like "Password manager shortcut detected"

## Customizing Shortcuts

To add or modify blocked shortcuts, edit the `is_password_manager_shortcut()` function in `src/keyboard.rs`.

## Technical Details

### Changes Made

1. **Modified keyboard event handling** (src/keyboard.rs)
   - Changed from consuming key press events to passing them through
   - Added multiple blocking functions:
     - `is_password_manager_shortcut_simple()` - Blocks password manager shortcuts
     - `should_block_from_remote()` - Blocks Windows key and Alt+Tab
   - Added scan code fixing for two cases:
     - Scan code 0: Uses MapVirtualKeyW to generate proper scan code
     - Scan code = platform code: Handles ASCII-based password managers
   - Added shift injection/release for proper capitalization

### How It Works

1. RustDesk captures all keyboard events using `rdev::grab()`
2. When a keyboard event occurs:
   - Fix scan code if it's 0 (common with simulated keystrokes)
   - Check if it's a password manager trigger shortcut
   - If yes: Pass to local system but don't send to remote
   - If no: Pass to local system AND send to remote with fixed scan code
3. Password manager receives its trigger and performs autotype
4. Autotyped characters are captured with proper scan codes and sent to remote

### Scan Code Fix Details

Many password managers send simulated keystrokes with scan code 0, which can cause issues:
- RustDesk's map keyboard mode uses scan codes for key translation
- Keys with scan code 0 may be rejected or misinterpreted
- Solution: Use Windows MapVirtualKeyW to generate proper scan codes from virtual key codes
- This ensures password manager keystrokes work correctly on the remote machine

## Known Limitations

- Only works on Windows (macOS and Linux use different keyboard grabbing mechanisms)
- Shortcut list is hardcoded (future enhancement: config file support)
- Some password managers may use different shortcuts not covered here

## Troubleshooting

### Autotype not working
1. Ensure RustDesk has keyboard control enabled
2. Check if your password manager's shortcut is in the blocked list
3. Enable debug logging to see what shortcuts are being detected

### Shortcuts still appearing on remote
1. Your password manager may use a different shortcut
2. Check logs to see what key combination is being pressed
3. Add the shortcut to `is_password_manager_shortcut()` function

## Contributing

To add support for more password managers:
1. Identify the global autotype shortcut
2. Add it to the `is_password_manager_shortcut()` function
3. Test thoroughly
4. Submit a pull request

## License

Same as RustDesk - GNU Affero General Public License (AGPL)