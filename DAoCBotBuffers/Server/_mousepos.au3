#include <Misc.au3>
#RequireAdmin


Global $pos = MouseGetPos()
While 1
   Global $pos = MouseGetPos()
   TrayTip("MousePosition", $pos[0] & " " & $pos[1], 10)
   Sleep(1000)
Wend

;650,120