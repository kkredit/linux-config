:: Install choco.exe
@powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
