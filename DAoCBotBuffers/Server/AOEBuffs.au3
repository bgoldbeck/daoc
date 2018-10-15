#include <Misc.au3>
#RequireAdmin

If _Singleton("Buff",1) = 0 Then
   Exit
EndIf

WinActivate("DAOC1", "")
If Not WinExists("DAOC1", "") Then Exit
Sleep(100)
ControlSend("DAOC1", "", "", "9")
Sleep(1700)
ControlSend("DAOC1", "", "", "8")
Sleep(1700)
ControlSend("DAOC1", "", "", "7")
Sleep(1000)

