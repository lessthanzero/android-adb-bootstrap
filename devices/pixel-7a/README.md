# Google Pixel 7a — Handheld Emulation & ADB Setup Guide

Comprehensive reference guide and ADB automation scripts for managing retro gaming, emulators, and storage layouts on the **Google Pixel 7a**.

---

## Device Architecture & Constraints

- **Device**: Google Pixel 7a (Tensor G2, 64-bit architecture only).
- **Architecture Note**: Android 14+ on Pixel 7a **strictly drops 32-bit (`armeabi-v7a`) app support**. Legacy 32-bit Android games/APKs (e.g. older ports) cannot be installed (`INSTALL_FAILED_NO_MATCHING_ABI`).
- **Frontend Launcher**: Beacon Game Launcher (`com.radikal.gamelauncher`).

---

## On-Device Storage Layout (`/sdcard/ROMs/`)

```
/sdcard/ROMs/
├── 3DS-Games/          ← Beacon Nintendo 3DS scan path ONLY (.cxi, .cci, .3ds)
├── PSVita/             ← Beacon PS Vita scan path ONLY (.psvita stubs + .jpg covers)
├── PS Vita/            ← Vita3K data directory ONLY (ux0, os0, firmware, saves) — DO NOT SCAN
├── Dreamcast/          ← Beacon -> Flycast (.cdi, .gdi, .chd)
├── GameCube/           ← Beacon -> Dolphin (.iso, .gcm, .m3u)
├── PSP/                ← Beacon -> PPSSPP (.iso, .cso, .pbp)
├── PlayStation 2/      ← Beacon -> AetherSX2 / NetherSX2 (.iso, .chd)
├── BIOS/               ← Shared system BIOS files (PS1, PS2, Dreamcast boot ROMs)
├── _config/            ← Reference configs & platform checklists
├── _covers/            ← Cover art overrides for manual selection
└── _archived/          ← Archived source dumps (.cia, .zip) outside active scan paths
```

---

## Android Storage Access Framework (SAF) & URI Rules

On Android 11+, several emulators **cannot open direct file paths** (`file:///sdcard/...`), even when granted *All files access*. Beacon passes ROMs via Storage Access Framework (`content://com.android.externalstorage.documents/...`).

| Emulator | Intent Launch | Common Failure Symptom | Fix / Workaround |
|---|---|---|---|
| **Flycast (Dreamcast)** | `{file_path}` | "Cannot open CDI file" / crash | Configure Beacon custom launch command with `{file_uri}` |
| **Dolphin (GameCube)** | `{file_uri}` via `AutoStartFile` | Works for `.iso`; `.m3u` fails with "file not found" | M3U entries must use SAF document-path encoding (see below) |
| **Azahar / Lime3DS** | `{file_uri}` | Zelda missing in Beacon | Convert `.cia` to `.cxi` (Beacon default filter ignores `.cia`) |
| **Vita3K (PS Vita)** | Title ID via `AppStartParameters` | Ghost entries / infinite logo hang | Use `.psvita` Title ID stubs in `ROMs/PSVita/` |

---

## Emulator Configurations

### 1. Nintendo 3DS (Azahar / Lime3DS)
- **Package**: `io.github.lime3ds.android`
- **Data Folder**: `/sdcard/Azahar/` (Set app data directory outside scan path).
- **Rule**: Beacon built-in extensions exclude `.cia`. Extract decrypted CIAs to `.cxi` on host machine prior to pushing:
  ```bash
  ctrtool --contents=/tmp/out game.cia
  cp /tmp/out/contents.0000.* "Game Name.cxi"
  ```

### 2. PS Vita (Vita3K)
- **Package**: `org.vita3k.emulator`
- **Configuration**: `/sdcard/Android/data/org.vita3k.emulator/files/config.yml`
- **Key Settings**:
  ```yaml
  backend-renderer: Vulkan
  ngs-enable: true
  show-live-area-screen: false
  boot-apps-full-screen: true
  delay-start: 0
  pref-path: /storage/emulated/0/ROMs/PS Vita/
  ```
- **Stubs**: Place Title ID stubs (`PCSE00404.psvita`) inside `ROMs/PSVita/` containing one line with the Title ID.

### 3. Dreamcast (Flycast)
- **Package**: `com.flycast.emulator`
- **Custom Launch Command in Beacon**:
  ```
  am start -n com.flycast.emulator/com.flycast.emulator.MainActivity -a android.intent.action.VIEW -d {file_uri}
  ```

### 4. GameCube Multi-Disc M3U Format (Dolphin)
Dolphin Android resolves M3U entries using SAF document paths. Relative file names will fail.
Format each line in the `.m3u` file using URL-encoded document paths:
```
primary%3AROMs%2FGameCube%2FMetal%20Gear%20Solid%20-%20The%20Twin%20Snakes%20(Disc%201).iso
primary%3AROMs%2FGameCube%2FMetal%20Gear%20Solid%20-%20The%20Twin%20Snakes%20(Disc%202).iso
```

---

## Staging & Sync Workflow (`phone-transfer`)

You can optionally maintain a transient staging directory on your Mac (e.g. `$HOME/phone-transfer/staging/`) for queueing games before pushing to the phone:

1. **Deploy Staging to Phone**:
   ```bash
   STAGING_DIR=$HOME/phone-transfer/staging ./scripts/push_to_pixel.sh
   ```

2. **Backup On-Device Saves & ROMs to Storage/NAS**:
   ```bash
   NAS_DIR=/Volumes/ROMs ./scripts/backup_to_nas.sh
   ```
