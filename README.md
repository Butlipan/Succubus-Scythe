# 🩸 Succubus Scythe
> “Cut through the system like a scythe through flesh, and let the secrets bleed.”
<img width="1024" height="1536" alt="72d5f512-c894-44a1-aefb-5a12eb7138f7" src="https://github.com/user-attachments/assets/51dd382c-dde7-46bc-80ca-bf420689b4e4" />

# Succubus Scythe | Windows Post-Exploitation Enumeration Toolkit

Succubus Scythe is a PS-based post-exploitation script made for penetration testers, red teamers, and anyone curious about Windows security. Its main goal is to gather info about a system, spot potential privilege escalation paths, and help with labs or CTFs like Hack The Box.
> Heads up: this is noisy, so don’t run it where OPSEC actually matters.

Features
- System Info: Grabs Windows version, build, and product details.
- Users & Groups: Lists local users, groups, and who's in Administrators.
- Firewall Check: Shows both basic and full firewall settings.
- Services & Tasks: Finds running services, their paths, and scheduled tasks.
- Password Policies: Checks which accounts need passwords and shows local policy.
- Sensitive Files: Looks for creds, logs, configs in common locations.
- Registry: Enumerates HKLM, HKCU, HKU, and startup entries.
- SMB Shares: Lists shares on machine.
- Network Connections: Active TCP connections.
- Privilege Escalation Checks: Spots unquoted service paths, weak permissions, stored creds.
- Stored Credentials: Pulls creds from AutoLogon, PuTTY, Windows cmdkey, Wi-Fi profiles.
- PowerShell History: Collects history files from all users to potential creds or interesting commands.

## 🧰 How to use

PowerShell
```
.\Succubus_Scythe.ps1
.\Succubus_Scythe.exe
```
> Currently, there are no flags. This may change in the next update.

## ⚠️ Disclaimer:
It is intended for educational purposes, security research, and practice in ethical hacking contexts.

## 🙏🏼 Feedback
If you find ANY bugs related to this script, just write to me! I will be grateful for your feedback
