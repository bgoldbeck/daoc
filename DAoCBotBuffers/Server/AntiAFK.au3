#include <Misc.au3>
#RequireAdmin
If _Singleton("Buff",1) = 0 Then
   Exit
EndIf


WinActivate("DAOC1", "")
If Not WinExists("DAOC1", "") Then Exit
ControlSend("DAOC1", "", "", "9")
Sleep(1800)
ControlSend("DAOC1", "", "", "8")
Sleep(1800)
ControlSend("DAOC1", "", "", "7")
Sleep(1800)
ControlSend("DAOC1", "", "", "3")
Sleep(100)
ControlSend("DAOC1", "", "", "3")
Sleep(100)


If WinExists("DAOC2", "") Then
   WinActivate("DAOC2", "")
   Sleep(100)
   ControlSend("DAOC2", "", "", "3")
   Sleep(1000)
   ControlSend("DAOC2", "", "", "3")
   Sleep(100)
   WinActivate("DAOC1", "")
   Sleep(1000)
EndIf

Sleep(5500)
