#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf

Global $primaryBuffBotName = IniRead(@SCRIPTDIR & "\usermsg.ini", "User", "PrimaryBuffBot", "")
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
ControlSend("DAOC1", "", "", "/assist " & $userToBuff)
Sleep(100)
ControlSend("DAOC1", "", "", "{ENTER}")

While 1
   Sleep(20)
   $coord = PixelSearch($left, $top, $right, $bottom, $hex)
   If Not @ERROR Then
	  ExitLoop
   EndIf

   $dif = TimerDiff($timer)
   If $dif > 3500 Then
	  Exit
   EndIf
WEnd
Sleep(100)
ControlSend("DAOC1", "", "", "f")
Sleep(100)
ControlSend("DAOC1", "", "", "0")
Sleep(100)
ControlSend("DAOC1", "", "", "0")
Sleep(1600)
ControlSend("DAOC1", "", "", "9")
Sleep(1600)
ControlSend("DAOC1", "", "", "3")

If Not WinExists("DAOC2", "") Then
   Sleep(1600)
   ControlSend("DAOC1", "", "", "7")
   Sleep(1600)
   ControlSend("DAOC1", "", "", "6")
   Sleep(1600)
   ControlSend("DAOC1", "", "", "5")
   Sleep(1600)
   ControlSend("DAOC1", "", "", "4")
EndIf
Sleep(100)
ControlSend("DAOC1", "", "", "1")
Sleep(100)
ControlSend("DAOC1", "", "", "1")

;NEXT BOT
$timer  = TimerInit()
$dif = 0
WinActivate("DAOC2", "")
If Not WinExists("DAOC2", "") Then Exit
Sleep(100)
ControlSend("DAOC2", "", "", "{ENTER}")
Sleep(100)
ControlSend("DAOC2", "", "", "/assist " & $primaryBuffBotName)
Sleep(100)
ControlSend("DAOC2", "", "", "{ENTER}")
Sleep(30)
While 1
   $coord = PixelSearch($left, $top, $right, $bottom, $hex)
   If Not @ERROR Then
	  Sleep(100)
	  ExitLoop
   EndIf

   $dif = TimerDiff($timer)
   If $dif > 9500 Then
	  Exit
   EndIf
   Sleep(20)
WEnd
Sleep(100)
ControlSend("DAOC2", "", "", "f")
Sleep(100)
ControlSend("DAOC2", "", "", "0")
Sleep(100)
ControlSend("DAOC2", "", "", "0")
Sleep(2350)
ControlSend("DAOC2", "", "", "8")
Sleep(2600)
ControlSend("DAOC2", "", "", "6")
Sleep(2350)
ControlSend("DAOC2", "", "", "5")
Sleep(100)
ControlSend("DAOC2", "", "", "1")
Sleep(100)
ControlSend("DAOC2", "", "", "1")
Sleep(100)
ControlSend("DAOC2", "", "", "{ESC}") ;Untarget
Sleep(100)
WinActivate("DAOC1", "")
Sleep(200)
ControlSend("DAOC1", "", "", "{ESC}") ;Untarget
