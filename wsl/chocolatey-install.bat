:: Install choco .exe and add choco to PATH
@powershell -Command "Start-Process cmd -Verb RunAs"
@powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" ^
    && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

set PACKAGES=hexedit test

echo %PACKAGES%

:: Install all the packages
for %%G in (%PACKAGES%) do echo %%G
