#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf
WinActivate("DAOC2", "")
If Not WinExists("DAOC2", "") Then Exit
   
Global $msg = IniRead(@SCRIPTDIR & "\usermsg.ini", "User", "Say", "")

If StringInStr($msg, "/q") Then
   ControlSend("DAOC2", "", "", "{ENTER}")
   Sleep(100)
   ControlSend("DAOC2", "", "", "/q")
   Sleep(400)
   ControlSend("DAOC2", "", "", "{ENTER}")
   Sleep(100)
   Exit
EndIf

If StringInStr($msg, "ESC") Then
   ControlSend("DAOC2", "", "", "{ESC}")
   Sleep(200)
   ControlSend("DAOC2", "", "", "{ESC}")
   Exit
EndIf

ControlSend("DAOC2", "", "", "{ENTER}")
Sleep(100)
ControlSend("DAOC2", "", "", "/say " & $msg)
Sleep(400)
ControlSend("DAOC2", "", "", "{ENTER}")
Exit
