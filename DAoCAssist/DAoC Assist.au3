#include <ImageSearch.au3>
#include <Misc.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#requireadmin

$gui = GUICreate("DAoC Assist", 280, 275, -1, -1)
GUISetState(@SW_SHOW)

$sprintLabel = GUICtrlCreateLabel("Sprinting:  ", 0, 0, 140, 45)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")


HotKeySet("p", "CheckForImage")

global $y = 0, $x = 0

Func CheckForImage($image)
	local $search = _ImageSearch($image, 1, $x, $y, 100)
	return $search
EndFunc

While 1
	sleep(25)
	$msg = Guigetmsg()

	Select
		Case $msg = $GUI_EVENT_CLOSE
			exit
	EndSelect
	$sprinting = CheckForImage('sprint.bmp')

	GUICtrlSetData($sprintLabel, "Sprinting: " & $sprinting)

WEnd