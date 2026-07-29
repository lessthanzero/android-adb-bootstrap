# Android Device Management & ADB Automation Suite

An open-source repository containing isolated ADB bootstrap pipelines, HyperOS debloating, privacy hardening, and handheld emulation configurations for Android devices.

---

## Repository Architecture

```
.
├── README.md                           # Master repository documentation
├── .gitignore                          # Excludes temporary builds, local backups & binary APKs
└── devices/
    ├── xiaomi-note15-pro/              # Xiaomi / Redmi Note 15 Pro 5G (HyperOS)
    │   ├── README.md                   # Detailed setup, debloat manifest & post-migration steps
    │   ├── bootstrap.py                # HyperOS v2 automated ADB debloat & hardening pipeline
    │   └── post_install_check.py       # Post-migration data audit script (Contacts, SMS, Calls)
    │
    └── pixel-7a/                       # Google Pixel 7a (Handheld & Emulation Lab)
        ├── README.md                   # Android SAF URI rules, Beacon Launcher & Emulator guide
        └── scripts/
            ├── push_to_pixel.sh        # Deployment script for ROMs, stubs, and platform configs
            └── backup_to_nas.sh        # Backup script pulling phone saves/ROMs to local/NAS storage
```

---

## Device Pipelines

### 1. Xiaomi / Redmi Note 15 Pro 5G (HyperOS)
Targeted setup for system debloating, background battery optimization for VPNs/wearables, regional defaults, and dark mode UI tuning.
- [Xiaomi Note 15 Pro Setup Documentation](devices/xiaomi-note15-pro/README.md)
- **Bootstrap Script**: [`devices/xiaomi-note15-pro/bootstrap.py`](devices/xiaomi-note15-pro/bootstrap.py)
- **Migration Audit Script**: [`devices/xiaomi-note15-pro/post_install_check.py`](devices/xiaomi-note15-pro/post_install_check.py)

### 2. Google Pixel 7a (Emulation & ADB Management)
Configuration guide and automation scripts for handheld emulation (Beacon Launcher, Vita3K, Lime3DS/Azahar, Flycast, Dolphin) on 64-bit Android.
- [Pixel 7a Emulation & Setup Documentation](devices/pixel-7a/README.md)
- **ADB Push Deployment**: [`devices/pixel-7a/scripts/push_to_pixel.sh`](devices/pixel-7a/scripts/push_to_pixel.sh)
- **Phone-to-NAS Backup**: [`devices/pixel-7a/scripts/backup_to_nas.sh`](devices/pixel-7a/scripts/backup_to_nas.sh)

---

## Prerequisites & Setup

1. **Install Android Debug Bridge (ADB)**:
   - macOS: `brew install android-platform-tools`
   - Linux: `sudo apt install android-tools-adb`
2. **Enable USB Debugging**:
   - Navigate to **Settings** -> **Developer Options** and enable **USB Debugging**.
   - Connect phone via USB and allow prompt on device (`Always allow from this computer`).

---

## Data Privacy & Security Notice

All scripts in this repository are strictly sanitized:
- No hardcoded personal tokens, credentials, subscription keys, or emails are included.
- Device backup dumps (`phone_backup/`), reports, and binary APK packages are excluded via `.gitignore`.
