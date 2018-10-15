#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf

Global $userToBuff = IniRead(@SCRIPTDIR & "\usermsg.ini", "User", "Name", "")

$left   = IniRead("config.ini", "Rectangle", "Left","")
$top    = iniread("config.ini", "Rectangle", "Top","")
$right  = iniread("config.ini", "Rectangle", "Right","")
$bottom = iniread("config.ini", "Rectangle", "Bottom","")
$hex    = iniread("Config.ini","Color","Color''Hit''","")
$timer  = TimerInit()
$dif    = 0

WinActivate("DAOC1", "")
If Not WinExists("DAOC1", "") Then Exit
Sleep(100)
ControlSend("DAOC1", "", "", "{ENTER}")
Sleep(100)
ControlSend("DAOC1", "", "", "/target " & $userToBuff)
Sleep(400)
ControlSend("DAOC1", "", "", "{ENTER}")
While 1
   $coord = PixelSearch($left, $top, $right, $bottom, $hex)
   If Not @ERROR Then
	  Sleep(100)
	  ExitLoop
   EndIf

   $dif = TimerDiff($timer)
   If $dif > 5000 Then
	  Exit
   EndIf
   Sleep(20)
WEnd
Sleep(200)
ControlSend("DAOC1", "", "", "f")
Sleep(100)
ControlSend("DAOC1", "", "", "0")
Sleep(100)
ControlSend("DAOC1", "", "", "0")
Sleep(900)
ControlSend("DAOC1", "", "", "1")
Sleep(100)
ControlSend("DAOC1", "", "", "1")
Sleep(100)
ControlSend("DAOC1", "", "", "{ESC}") ;Untarget
