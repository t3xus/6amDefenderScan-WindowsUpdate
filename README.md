# 6amDefenderScan-WindowsUpdate

Script to automate the creation, configuration, and scheduling of a daily Windows Defender quick scan and Windows Update check.

## What it does

- Creates `DailyMaintenance.ps1` in the current user's home directory.
- Sets basic execute permissions on the script.
- Registers a scheduled task named **6am Scan and Update** that runs the maintenance script every day at 6:00 AM under the SYSTEM account.

## Requirements

- Windows PowerShell 5.1 or later
- Administrator privileges (to create the scheduled task and set ACLs)
- `PSWindowsUpdate` module available for the update step (installed on first run if missing)

## Usage

```powershell
.\SetupDailyMaintenance.ps1
```

After running, the task will appear in Task Scheduler as **6am Scan and Update**.

## License

MIT License
