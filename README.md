# FCheat

![Version](https://img.shields.io/badge/version-2.2-6aa9ff?style=flat-square)
![Language](https://img.shields.io/badge/language-Luau-335fff?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Roblox-111827?style=flat-square)

FCheat is a configurable Luau utility panel with a compact dark interface, persistent settings, visual tools, aiming controls, and customizable keybinds.

> This repository is intended for development and testing in environments where you have permission to run custom client scripts. Use it responsibly and follow the rules of the platform and experience.

## Current Version

The actively maintained build is [`AutoExec/RBtest.txt`](AutoExec/RBtest.txt).

Version 2.2 includes:

- Configurable menu key with automatic persistence
- Animated dark interface with modern transitions
- Lightweight toast notifications
- ESP boxes, names, distance, health, skeleton, highlights, and snaplines
- Aimbot settings with FOV, smoothing, prediction, wall check, and team check
- R6, R15, and nested custom-rig hitbox resolution
- Target priority by crosshair distance, lowest health, or nearest world distance
- Triggerbot controls
- Night mode and configurable hotkey panel
- Night mode brightness up to 1000% with custom ambient, outdoor, and fog colors
- Full HSV color picker with saturation/value field, hue bar, HEX input, and RGB preview
- JSON configuration save, load, and reset actions
- Reduced animation work while the menu is hidden
- Safer tween cleanup when the interface is reloaded

## Controls

| Action | Default key |
| --- | --- |
| Open or close menu | `F2` |
| Save configuration | `F3` |
| Load configuration | `F4` |

The menu key can be changed from the persistent `KEY: F2` button in the window header, or under `MISC -> Menu Keybind` and `CONFIG -> Menu Keybind`:

- Click `Open / Close Menu`, then press a new keyboard key.
- Press `Escape` to cancel key capture.
- Press `Backspace` to restore `F2`.
- Use `Reset Menu Key to F2` for a one-click reset.

## Repository Layout

```text
FCheat/
|-- AutoExec/
|   `-- RBtest.txt       # Current 2.1 build
|-- inject-IS.luau       # Previous Luau build
|-- blant.txt            # Legacy build
|-- .gitignore
`-- README.md
```

## Configuration

Runtime settings are stored in `UtilityPanelConfig_v2.json`. The file is ignored by Git because it contains local preferences and should not be shared between installations.

The configuration system persists:

- UI and hotkey preferences
- Visual settings and colors
- Aiming settings
- Night mode settings
- Hotkey panel position, scale, and transparency

## Updating

Pull the latest version from the default branch:

```powershell
git pull --ff-only origin main
```

Local runtime files, generated configuration, application binaries, and WebView2 data are excluded by `.gitignore`.

## Notes

- `AutoExec/RBtest.txt` depends on APIs exposed by the target runtime, including `Drawing`, file I/O, and mouse input functions.
- Availability of individual features varies between runtimes and experiences.
- Restart the loaded script after updating the file so the new code replaces the previous in-memory instance.
