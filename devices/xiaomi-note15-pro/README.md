# Xiaomi Redmi Note 15 Pro 5G (8+512 GB) — ADB Setup & Hardening

Setup pipeline, debloating rules, battery optimization, and post-migration audit procedures for **Xiaomi Redmi Note 15 Pro 5G** (HyperOS).

---

## Quickstart

1. **Enable USB Debugging on Phone**:
   - Open **Settings** -> **About Phone** -> Tap **OS Version** 7 times to unlock Developer Options.
   - Go to **Settings** -> **Additional Settings** -> **Developer Options**.
   - Enable **USB Debugging** and **USB Debugging (Security settings)** (if installing apps via ADB).

2. **Connect via USB & Run Bootstrap Pipeline**:
   ```bash
   python3 bootstrap.py
   ```

3. **Verify Data Migration Outcome**:
   ```bash
   python3 post_install_check.py
   ```

---

## What `bootstrap.py` Does

### 1. System State Audit & Backup (`./phone_backup/`)
- Dumps installed packages (`pm list packages -f`)
- Dumps disabled packages (`pm list packages -d`)
- Dumps active notification listeners and accessibility services

### 2. Regional & System Defaults
- Sets locale to `ru-RU` (Russian)
- Enables 24-hour time display
- Marks initial provisioning complete

### 3. Safe HyperOS Debloating
Removes tracking, ads, quick app stubs, and preinstalled third-party bloat for `User 0` without breaking OTA updates, Xiaomi Camera, or Gallery:
- **Ads & Analytics**: `com.miui.msa.global`, `com.miui.analytics`, `com.miui.daemon`
- **Promos**: `com.miui.android.fashiongallery`, `com.xiaomi.glance.internet`
- **Bloatware**: `com.xiaomi.mipicks` (GetApps), `com.mi.global.bbs`, `com.miui.videoplayer`, `com.mi.health`, `com.miui.player`, `com.miui.hybrid` (Quick Apps)
- **Preinstalls**: Facebook packages (`com.facebook.system`, etc.), Netflix stubs

### 4. Power & Doze Whitelisting
Prevents Doze mode background hibernation for critical applications:
- **Messaging/Banking**: Telegram, WhatsApp, Sberbank / SberPay
- **VPN Services**: Paper VPN (`io.papervpn.android.client`), Amnezia VPN
- **Wearables**: Mi Fitness (`com.xiaomi.wearable`) for uninterrupted Mi Smart Band syncing

### 5. UI Polishing & UX Alignment
- Enforces System Dark Mode (`ui_night_mode 2`)
- Softens haptics and suppresses keypress vibration
- Sets standard crisp display scaling (`density 420`)

---

## Manual Post-Bootstrap Checklist

1. Sign into Google Account & RuStore.
2. Register Biometrics (Fingerprint / Face Unlock).
3. Open **Mi Fitness**, log into Xiaomi Account, and pair **Xiaomi Smart Band**. Grant notification & battery permissions when prompted.
4. Open **Paper VPN**, enter subscription key, and initiate connection test.
5. Organize Home Screen app folders (*Связь, Финансы, Покупки, Путешествия, Инструменты*).
6. Customize Quick Settings tiles (*Flashlight, VPN, Hotspot, QR Scanner, DND, Battery Saver*).
