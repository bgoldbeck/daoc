#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf
WinActivate("DAOC1", "")
Sleep(300)
ControlSend("DAOC1", "", "", "6")
Sleep(300)
ControlSend("DAOC1", "", "", "2")
Sleep(300)
ControlSend("DAOC1", "", "", "1")
Sleep(3500)

If Not WinExists("DAOC2", "") Then Exit
WinActivate("DAOC2", "")
Sleep(300)
ControlSend("DAOC2", "", "", "6")
Sleep(300)
ControlSend("DAOC2", "", "", "2")
Sleep(300)
ControlSend("DAOC2", "", "", "1")
Sleep(20000)


