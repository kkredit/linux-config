
:: Fix VirtualBox USB issues. Steps are from:
:: https://bytefreaks.net/windows/virtualbox-failed-to-attach-the-usb-device-to-the-virtual-machine

:: Step 1: delete a registry entry
set regkey="HKLM\SYSTEM\CurrentControlSet\Control\Class\{36fc9e60-c465-11cf-8056-444553540000}"
reg delete %regkey% /v UpperFilters /f

:: Step 2: reinstall the VirtualBox USB driver
set driverinf="C:\Program Files\Oracle\VirtualBox\drivers\USB\filter\VBoxUSBMon.inf"
%SystemRoot%\System32\InfDefaultInstall.exe %driverinf%
