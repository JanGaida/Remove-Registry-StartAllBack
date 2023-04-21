# Remove-Registry-StartAllBack

Helps removing registry entries made by StartAllBack.

```
⚠️ Warning: Might delete addtional registry-entires upon user-interaction; use with caution.
```

## How-To-Use:

### ℹ️ One-Time usage:

1. Grab the PowerShell-Script (named 'Remove-Registry-StartAllBack.ps1') and place it somewhere
2. Open a new (Power)Shell ideally with administrator privileges (**not required**) and change the directory to the directory which contains the script-file
3. Execute the script with:
```
powershell -executionpolicy bypass -file .\Remove-Reg-StartAllback.ps1
```
4. Continue following the instructions (Press CTRL+C to force quit)

#### Screenshot:
![Screenshot of the powershell-cli running the schedule-script](https://raw.githubusercontent.com/JanGaida/Remove-Registry-StartAllBack/main/Screenshots/Screenshot__Remove-Registry-StartAllBack.png)

---

### ⏰ Regularly usage:

```
⚠️ Warning: Might delete addtional registry-entires without user-interaction; try 'One-Time usage' before and use with caution.
```

1. Grab the PowerShell-Scripts (named 'Remove-Registry-StartAllBack.ps1' and 'Schedule-Remove-Registry-StartAllBack') and place them in the same directory somewhere (ie. *'C:\Program Files\StartAllBack\Remove-Registry-StartAllBack'*)
2. Open a new (Power)Shell ideally with administrator privileges (**not required**) and change the directory to the directory which contains the script-files
3. Execute the scheduler-script with - you might want to change certain parameters (like the trigger-time) either via the windows's taskscheduler-userinterface or by giving certain parameters to the scheduler-script (like 'AtTime 8pm'):
```
powershell -executionpolicy bypass -file .\Schedule-Remove-Registry-StartAllBack.ps1
```
4. Confirm/Edit the settings in the opened windows's taskscheduler-window

#### Screenshot:
![Screenshot of the powershell-cli running the schedule-script](https://raw.githubusercontent.com/JanGaida/Remove-Registry-StartAllBack/main/Screenshots/Screenshot__Schedule-Remove-Registry-StartAllBack.ps1.png)

## Requirements:

- Microsoft.PowerShell
```
winget install Microsoft.PowerShell
```

