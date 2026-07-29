#!/bin/bash
# Pixel 7a ADB Deployment Script
# Pushes ROMs, emulators, stubs, and platform configs from local staging to Pixel 7a over ADB.

set -euo pipefail

# Path-agnostic staging directory (defaults to ~/phone-transfer/staging or custom STAGING_DIR)
STAGING="${STAGING_DIR:-$HOME/phone-transfer/staging}"

# Ensure ADB is available and device is connected
DEVICE=$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')

if [[ -z "${DEVICE}" ]]; then
  echo "[!] Error: No ADB phone detected. Ensure Pixel 7a is connected, unlocked, and USB Debugging is allowed."
  adb devices -l
  exit 1
fi

echo "[+] Target ADB Device: ${DEVICE}"
echo "[+] Using Staging Folder: ${STAGING}"

if [[ ! -d "${STAGING}" ]]; then
  echo "[!] Warning: Staging directory '${STAGING}' does not exist yet."
  echo "    Create '${STAGING}' or set STAGING_DIR=/path/to/staging before running."
fi

# --- 1. Nintendo 3DS (Beacon scans .cxi / .cci only; NOT .cia) ---
echo "[+] Syncing 3DS platform..."
adb shell "mkdir -p '/sdcard/ROMs/3DS-Games' '/sdcard/ROMs/_archived/3DS' '/sdcard/Azahar'"
if [[ -d "${STAGING}/ROMs/3DS-Games" ]]; then
  adb push "${STAGING}/ROMs/3DS-Games/." "/sdcard/ROMs/3DS-Games/" 2>/dev/null || true
fi

# --- 2. PS Vita (Title ID stubs only to prevent ghost entries) ---
echo "[+] Syncing PS Vita platform..."
adb shell "mkdir -p '/sdcard/ROMs/PSVita' '/sdcard/ROMs/PS Vita/ux0/rePatch'"
if [[ -d "${STAGING}/ROMs/PSVita" ]]; then
  adb push "${STAGING}/ROMs/PSVita/." "/sdcard/ROMs/PSVita/" 2>/dev/null || true
fi

# --- 3. Platform Configurations & Guides ---
echo "[+] Syncing platform configs to /sdcard/ROMs/_config/..."
adb shell "mkdir -p '/sdcard/ROMs/_config'"
if [[ -d "${STAGING}/ROMs/_config" ]]; then
  adb push "${STAGING}/ROMs/_config/." "/sdcard/ROMs/_config/" 2>/dev/null || true
fi

# --- 4. GameCube / Dreamcast / PSP / SNES ---
echo "[+] Syncing retro console platforms..."
for console in GameCube Dreamcast PSP SNES; do
  adb shell "mkdir -p '/sdcard/ROMs/${console}'"
  if [[ -d "${STAGING}/ROMs/${console}" ]]; then
    adb push "${STAGING}/ROMs/${console}/." "/sdcard/ROMs/${console}/" 2>/dev/null || true
  fi
done

# --- 5. Optional Offline APK Installs ---
# Note: Pixel 7a is 64-bit ONLY (Android 14+). Legacy 32-bit (armeabi-v7a) APKs will fail installation.
if [[ -d "${STAGING}/Android/apks" ]]; then
  echo "[+] Installing offline APKs from staging..."
  for apk in "${STAGING}/Android/apks"/*.apk; do
    if [[ -f "${apk}" ]]; then
      echo "    Installing ${apk}..."
      adb install -r "${apk}" || echo "    [!] Package installation failed (may be 32-bit only)."
    fi
  done
fi

echo ""
echo "[✔] Deployment Complete! Check storage on phone:"
adb shell "ls -lh /sdcard/ROMs/ 2>/dev/null"
