# See https://o365reports.com/2019/08/02/schedule-powershell-script-task-scheduler/#Schedule%20PowerShell%20script%20from%20Task%20Scheduler%20using%20PowerShell

$Time=New-ScheduledTaskTrigger -At 3:00AM -Daily -DaysInterval 1
$Workdir="//wsl$/Ubuntu/kevin/git/linux-config"
$Script="wsl/ps_scripts/toggle-internet-share.ps1"
$Action=New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory $Workdir -Argument ".\$Script"

Register-ScheduledTask -TaskName "Schedule Toggle Internet Share" -Trigger $Time -Action $Action -RunLevel Highest
