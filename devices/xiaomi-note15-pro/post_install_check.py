#!/usr/bin/env python3
"""
Xiaomi Redmi Note 15 Pro 5G - Post-Installation Migration Audit Script
Queries Android system content providers over ADB to verify restored data counts (Contacts, SMS, Call Logs, Media).
"""

import subprocess


def run_adb(cmd: str, ignore_error: bool = False) -> str:
    """Executes an adb command and returns stripped output."""
    full_cmd = f"adb {cmd}"
    try:
        result = subprocess.run(
            full_cmd, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        if not ignore_error:
            print(f"  [!] Warning running '{full_cmd}': {e.stderr.strip()}")
        return ""


def run_phase_migration_audit() -> dict:
    """Inspects ADB provider stores to verify data migration outcome."""
    print("\nPhase: Verifying iPhone Data Migration Outcome...")

    # 1. Check Restored Contacts Count
    contacts_raw = run_adb(
        "shell content query --uri content://com.android.contacts/contacts --projection _id",
        ignore_error=True
    )
    contacts_count = len(contacts_raw.splitlines()) if contacts_raw else 0

    # 2. Check Restored SMS Messages Count
    sms_raw = run_adb(
        "shell content query --uri content://sms/ --projection _id",
        ignore_error=True
    )
    sms_count = len(sms_raw.splitlines()) if sms_raw else 0

    # 3. Check Restored Call Logs Count
    calls_raw = run_adb(
        "shell content query --uri content://call_log/calls --projection _id",
        ignore_error=True
    )
    calls_count = len(calls_raw.splitlines()) if calls_raw else 0

    # 4. Check Photo/Video Storage Count in DCIM/Pictures
    media_files = run_adb(
        "shell find /sdcard/DCIM /sdcard/Pictures -type f 2>/dev/null | wc -l",
        ignore_error=True
    )
    media_count = int(media_files.strip()) if media_files.isdigit() else 0

    migration_data = {
        "contacts_restored": contacts_count,
        "sms_restored": sms_count,
        "calls_restored": calls_count,
        "media_files_count": media_count
    }

    print(f"   [Audit] Contacts Restored: {contacts_count}")
    print(f"   [Audit] SMS Messages Restored: {sms_count}")
    print(f"   [Audit] Call Logs Restored: {calls_count}")
    print(f"   [Audit] Photos/Media Files Detected: {media_count}")

    return migration_data


if __name__ == "__main__":
    run_phase_migration_audit()
