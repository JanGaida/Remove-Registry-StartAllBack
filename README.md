# 🤖 Remove-Registry-StartAllBack

Helps removing registry entries made by StartAllBack via powershell.

```
⚠️ Warning: Might delete addtional registry-entires (only) upon user-interaction; use with caution.
```

<br/>

##  🏆 Capabilites:
- **Removal** of the *leftover* registry-entry by StartAllBack
- Creation of a *SchedulerTask* for this removal based on **day-interval** and **day-span** basis *(and more options available)*
- **Automatability**
- Guidance via a colorized **CLI**
- **No** administrator requirements

<br/>

## 🎯 How-To-Use:

1. Start the **windows terminal** (or any powershell-cli)

2. **Download** the scripts via git (or get and unpack the [zip-files](https://github.com/JanGaida/Remove-Registry-StartAllBack/archive/refs/heads/main.zip) ) 

```bash
cd <Some_Directory>
git clone 'https://github.com/JanGaida/Remove-Registry-StartAllBack' .
```

3. a) Execute the **'Remove-Registry-StartAllBack'**-script …

```bash
powershell -executionpolicy bypass -file .\Remove-Registry-StartAllBack.ps1
```

&nbsp;&nbsp;&nbsp;&nbsp; … and follow its instructions, eg. like:

<p align="center">
<img src="https://raw.githubusercontent.com/JanGaida/Remove-Registry-StartAllBack/main/Screenshots/Screenshot__Remove-Registry-StartAllBack.png" width="75%">
</p>

3. b) If you want create a *SchedulerTask* for **'Remove-Registry-StartAllBack'**-script execute:

```bash
powershell -executionpolicy bypass -file .\Schedule-Remove-Registry-StartAllBack.ps1
```

<p align="center">
<img src="https://raw.githubusercontent.com/JanGaida/Remove-Registry-StartAllBack/main/Screenshots/Screenshot__Schedule-Remove-Registry-StartAllBack.ps1.png" width="75%">
</p>


## 🛟 Requirements:

- Microsoft.PowerShell *(idealy via the windows terminal)*
```
winget install Microsoft.PowerShell
```

- Git *(optional)*
```
winget install -e --id Git.Git
```
