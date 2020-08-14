Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd $PSScriptRoot

. .\Get-MrInternetConnectionSharing.ps1
. .\Set-MrInternetConnectionSharing.ps1

Set-MrInternetConnectionSharing -InternetInterfaceName 'Ethernet 3' -LocalInterfaceName 'Ethernet' -Enabled $false
sleep 5
Set-MrInternetConnectionSharing -InternetInterfaceName 'Ethernet 3' -LocalInterfaceName 'Ethernet' -Enabled $true
