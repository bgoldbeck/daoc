#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf
WinActivate("DAOC1", "")
If Not WinExists("DAOC1", "") Then Exit


ControlSend("DAOC1", "", "", "6")
Sleep(200)
ControlSend("DAOC1", "", "", "4")
Sleep(200)
ControlSend("DAOC1", "", "", "1")
Sleep(200)
ControlSend("DAOC1", "", "", "1")
Sleep(200)
ControlSend("DAOC1", "", "", "1")
Sleep(200)
;NEXT BOT

WinActivate("DAOC2", "")
If Not WinExists("DAOC2", "") Then Exit

ControlSend("DAOC2", "", "", "6")
Sleep(200)
ControlSend("DAOC2", "", "", "4")
Sleep(200)
ControlSend("DAOC2", "", "", "1")
Sleep(200)
ControlSend("DAOC2", "", "", "1")
Sleep(200)
ControlSend("DAOC2", "", "", "1")
Sleep(200)
WinActivate("DAOC1", "")
