#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf
WinActivate("DAOC1", "")
If Not WinExists("DAOC1", "") Then Exit
   
Global $msg = IniRead(@SCRIPTDIR & "\usermsg.ini", "User", "Say", "")

If StringInStr($msg, "/q") Then
   ControlSend("DAOC1", "", "", "{ENTER}")
   Sleep(100)
   ControlSend("DAOC1", "", "", "/q")
   Sleep(400)
   ControlSend("DAOC1", "", "", "{ENTER}")
   Sleep(100)
   Exit
EndIf

If StringInStr($msg, "ESC") Then
   ControlSend("DAOC1", "", "", "{ESC}")
   Sleep(200)
   ControlSend("DAOC1", "", "", "{ESC}")
   Exit
EndIf

ControlSend("DAOC1", "", "", "{ENTER}")
Sleep(100)
ControlSend("DAOC1", "", "", "/say " & $msg)
Sleep(400)
ControlSend("DAOC1", "", "", "{ENTER}")
Exit
