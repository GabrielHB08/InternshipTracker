# Internship Tracker

Internship Tracker is a small Python script that reads internship applications from `applications.json` and sends one email summary with every application that is still open.

Applications with unknown deadlines are still included in the email. Applications with known deadlines are skipped after the deadline has passed.

## Setup

Install the required package:

```powershell
py -m pip install python-dotenv
```

If `py` is not the Python interpreter you use for this project, run the same install command with your project interpreter instead.

## Configure `.env`

Create a `.env` file in the project root using the same format as `env_example.txt`:

```env
EMAIL_ADDRESS=your_email@example.com
EMAIL_PASSWORD=your_app_password
EMAIL_TO=recipient_email@example.com
```

For Gmail, use a Google app password instead of your normal account password.

Make sure `.env` is listed in `.gitignore` so private credentials do not get committed.

## Configure Applications

Copy `template.json` to a new local file named `applications.json`. This file is ignored by Git so your personal application list stays private.

Add internship applications to `applications.json` as a JSON array. Each application should use this format:

```json
{
  "company": "Company",
  "role": "Role",
  "deadline": "yyyy-mm-dd",
  "status": "not_started",
  "link": "https://application-link.example"
}
```

Use `null` for `deadline` if the deadline is unknown:

```json
{
  "company": "Company",
  "role": "Role",
  "deadline": null,
  "status": "not_started",
  "link": "https://application-link.example"
}
```

Set `status` to `submitted` when you no longer want that application included in the reminder email.

## Run Manually

From the project root, run:

```powershell
py tracker.py
```

The script checks that these `.env` values exist before sending:

- `EMAIL_ADDRESS`
- `EMAIL_PASSWORD`
- `EMAIL_TO`

If the script runs successfully, it sends one email titled:

```text
Internship application deadline summary
```

## Weekly Automation On Windows

The repo includes `run_tracker.ps1`, which runs `tracker.py` and saves logs in a local `logs` folder.

To schedule it weekly, open PowerShell and replace `<PATH_TO_REPO>` with the folder path where this repo is stored:

```powershell
$repoPath = "<PATH_TO_REPO>"

$action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument "-ExecutionPolicy Bypass -File `"$repoPath\run_tracker.ps1`""

$trigger = New-ScheduledTaskTrigger `
  -Weekly `
  -DaysOfWeek Monday `
  -At 9am

Register-ScheduledTask `
  -TaskName "InternshipTrackerWeekly" `
  -Action $action `
  -Trigger $trigger `
  -Description "Send weekly internship deadline summary email"
```

Test the scheduled task:

```powershell
Start-ScheduledTask -TaskName "InternshipTrackerWeekly"
```

If your project uses a specific Python executable, set `INTERNSHIP_TRACKER_PYTHON` before running the task or update `run_tracker.ps1` to point to that interpreter.

## Notes

- Links in the email should be clickable in most email clients as long as they include `https://`.
- Applications with `deadline: null` are included with `Deadline: Unknown`.
- Applications with deadlines in the past are skipped.

Best of luck in the application process.
