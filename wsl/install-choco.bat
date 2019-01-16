:: Install choco .exe and add choco to PATH
@powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
    && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
