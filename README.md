# Arknights: Endfield DLSS Detection Fix for Linux

This project documents a Lutris/DXVK workaround for a specific Linux setup where Arknights: Endfield runs on an NVIDIA RTX GPU but does not show NVIDIA DLSS in **Settings → Performance & Graphics → Image Enhancement**.

The tested workaround changes the GPU name reported by DXVK to `NVIDIA GeForce RTX 3060`. On one RTX 3050 Laptop GPU setup, this made the game's DLSS option appear. The game still renders on the actual NVIDIA GPU; this setting changes the device description presented to the game.

## Compatibility and limitations

- Intended for Lutris entries that launch GRYPHYLINK through Wine/Proton and use DXVK.
- Tested on Arch Linux, Lutris, UMU/GE-Proton, an NVIDIA RTX 3050 Laptop GPU, and NVIDIA driver 615.78.08.
- This is a community workaround, not an official Gryphline, NVIDIA, or Lutris fix. It may not work on other runners, GPUs, or game versions.
- It changes the reported model name to RTX 3060. Do not use it if a title or tool relies on an exact hardware model report.
- The fix does not install NVIDIA drivers, DLSS libraries, or game files.

### ⚠️ Important: Anti-Cheat and Account Ban Risk

**Use this workaround at your own risk.**

This workaround involves GPU hardware spoofing by changing the device description reported to the game. Although it only modifies the GPU model name exposed through DXVK, it may affect how the game's anti-cheat system identifies or evaluates the hardware and system environment.

- The anti-cheat system may detect this modification and interpret it as unauthorized hardware manipulation or a violation of its rules.
- There is no guarantee that this workaround is safe or will remain undetected by the anti-cheat system.
- Using it could potentially result in an account penalty, including a temporary or permanent ban.
- This project is not endorsed by Gryphline, and the author cannot guarantee account safety.

**If you are concerned about your account or want to avoid any risk of an anti-cheat violation, do not use this workaround.** Review the game's current Terms of Service and anti-cheat policies before proceeding.

## Install

1. Close Endfield and GRYPHYLINK.
2. Clone or download this repository.
3. Run the installer:

   ```bash
   chmod +x install.sh uninstall.sh
   ./install.sh
   ```

The installer searches Lutris game YAML files under `~/.local/share/lutris/games` for a GRYPHYLINK entry. It finds the game directory from the launcher path, writes `dxvk.conf` beside Endfield's executable, and adds `DXVK_CONFIG_FILE` to that Lutris entry. It creates timestamped backups before modifying existing files and does not require root access.

If automatic detection fails, pass the paths explicitly:

```bash
./install.sh \
  --lutris-config "$HOME/.local/share/lutris/games/gryphylink-1793631428.yml" \
  --game-dir "$HOME/Games/GRYPHLINK/games/Arknights Endfield"
```

Then launch GRYPHLINK from Lutris and check the Image Enhancement menu.

## Uninstall

Close the game and launcher, then run:

```bash
./uninstall.sh
```

The uninstaller removes only the `DXVK_CONFIG_FILE` entry added by this project and the exact `dxvk.conf` it creates. Timestamped backups remain available for manual recovery.

## Manual setup

Create `dxvk.conf` in the Endfield game directory:

```ini
dxgi.customDeviceDesc = "NVIDIA GeForce RTX 3060"
```

Add this variable to the GRYPHYLINK Lutris entry's `system.env` section:

```yaml
DXVK_CONFIG_FILE: "/absolute/path/to/Endfield/dxvk.conf"
```

Restart Lutris or relaunch the game after changing the configuration.

## Troubleshooting

- Confirm the game is launched from the Lutris entry that was modified.
- Confirm the log contains `DXVK_CONFIG_FILE` and that it points to the created `dxvk.conf`.
- Ensure Endfield is actually using DXVK for the renderer. A DXVK configuration will not affect a path that bypasses DXVK.
- If the option still does not appear, remove the workaround and verify the NVIDIA driver, NVIDIA Vulkan ICD, runner, and game files first.
- To restore an automatic backup manually, copy the desired `.bak.*` file over the corresponding configuration file while Lutris is closed.

## Contributing

Please include your distribution, GPU, NVIDIA driver, Lutris runner, renderer, and whether DLSS appeared. Avoid posting account tokens, launcher credentials, or private game logs without reviewing them first.
