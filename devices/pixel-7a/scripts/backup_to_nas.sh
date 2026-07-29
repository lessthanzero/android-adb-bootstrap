#!/bin/bash
# Pixel 7a Phone-to-NAS Backup Script
# Pulls ROMs, save states, BIOS files, and archived dumps from Pixel 7a to local/NAS target directory.

set -euo pipefail

# Configurable NAS destination path (defaults to /Volumes/ROMs or NAS_DIR env var)
NAS="${NAS_DIR:-/Volumes/ROMs}"

DEVICE=$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')

if [[ -z "${DEVICE}" ]]; then
  echo "[!] Error: No connected ADB phone detected."
  exit 1
fi

if [[ ! -d "${NAS}" ]]; then
  echo "[!] Error: Backup destination directory '${NAS}' is not mounted or does not exist."
  echo "    Set NAS_DIR=/path/to/backup before running."
  exit 1
fi

echo "[+] Target ADB Device: ${DEVICE}"
echo "[+] Destination Backup Storage: ${NAS}"

mkdir -p "${NAS}"/{GameCube,Dreamcast,SNES,3DS,PSP,"PlayStation 2",PlayStation,_archived,BIOS,incoming}

pull_folder() {
  local src="$1" dst="$2"
  echo "=== Backup: ${src} → ${dst} ==="
  mkdir -p "${dst}"
  adb pull "${src}." "${dst}/" 2>/dev/null || true
}

pull_folder /sdcard/ROMs/GameCube/        "${NAS}/GameCube/"
pull_folder /sdcard/ROMs/Dreamcast/       "${NAS}/Dreamcast/"
pull_folder /sdcard/ROMs/SNES/            "${NAS}/SNES/"
pull_folder /sdcard/ROMs/3DS-Games/       "${NAS}/3DS/"
pull_folder /sdcard/ROMs/PSP/             "${NAS}/PSP/"
pull_folder "/sdcard/ROMs/PlayStation 2/" "${NAS}/PlayStation 2/"
pull_folder /sdcard/ROMs/PlayStation/     "${NAS}/PlayStation/"
pull_folder /sdcard/ROMs/_archived/       "${NAS}/_archived/"
pull_folder /sdcard/ROMs/BIOS/            "${NAS}/BIOS/"

echo ""
echo "[✔] Backup Complete! Storage Summary at ${NAS}:"
du -sh "${NAS}"/* 2>/dev/null | grep -v '@' || true
