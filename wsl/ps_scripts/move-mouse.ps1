# See https://flamingkeys.com/moving-the-mouse-cursor-with-windows-powershell/
# and https://stackoverflow.com/questions/39353073/how-i-can-send-mouse-click-in-powershell

# Imports
Add-Type -AssemblyName System.Windows.Forms
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W

# Move mouse
[Windows.Forms.Cursor]::Position = "$($screen.Width),$($screen.Height)"

# Click
[W.U32]::mouse_event(6,0,0,0,0)