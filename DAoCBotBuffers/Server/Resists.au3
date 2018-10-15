#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf

$left   = IniRead("config.ini", "Rectangle", "Left","")
$top    = iniread("config.ini", "Rectangle", "Top","")
$right  = iniread("config.ini", "Rectangle", "Right","")
$bottom = iniread("config.ini", "Rectangle", "Bottom","")
$hex    = iniread("Config.ini","Color","Color''Hit''","")

WinActivate("DAOC2", "")
If Not WinExists("DAOC1", "") Then Exit
Sleep(100)

MouseMove(650, 120)
MouseClick("Left")
Sleep(300)
ControlSend("DAOC2", "", "", "9")
Sleep(2000)
ControlSend("DAOC2", "", "", "8")
Sleep(2000)
ControlSend("DAOC2", "", "", "7")
Sleep(2000)
ControlSend("DAOC2", "", "", "=")
Sleep(2200)
ControlSend("DAOC2", "", "", "6")
Sleep(100)

$coord = PixelSearch($left, $top, $right, $bottom, $hex)
If Not @ERROR Then
   Sleep(100)
   ControlSend("DAOC2", "", "", "{ESC}")
EndIf   
Sleep(100)
ControlSend("DAOC2", "", "", "3")