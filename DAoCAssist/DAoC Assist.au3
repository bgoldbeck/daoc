#include <ImageSearch.au3>
#include <Misc.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#requireadmin

Global $sprinting = 0
Global $stealthing = 0
Global $y = 0, $x = 0

$windowName = "Dark Age of Camelot © 2001-2017 Electronic Arts Inc. All Rights Reserved."
$sprintKey = "v"

$gui = GUICreate("DAoC Assist", 280, 275, -1, -1)
GUISetState(@SW_SHOW)

$sprintLabel = GUICtrlCreateLabel("Sprinting:  ", 0, 0, 140, 45)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

$stealthLabel = GUICtrlCreateLabel("Stealthing:  ", 0, 50, 140, 45)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

$sprintCheckbox = GUICtrlCreateCheckbox("Always Sprint?", 140, -10, 140, 45)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

Func CheckForImage($image)
	local $search = _ImageSearch($image, 1, $x, $y, 5)
	return $search
EndFunc

While 1
	sleep(25)
	; Get health % Test

	;$search = CheckForImage('hits.bmp')
	;if $search == 1 then
	;	MouseMove($x, $y, 5)
	;	MsgBox(0, "yay", "yay")
	;EndIf
	; Move up 1 pixel to try to move over to the red health pixels.
	;$x = $x + 1
	;$y = $y + 1
	;$healthPixelColor = PixelGetColor($x, $y)
	;MsgBox(1, "start", PixelGetColor($x, $y))

	;while PixelGetColor($x, $y) == $healthPixelColor
	;	MsgBox(1, "loop", PixelGetColor($x, $y))
	;	$x = $x + 1
	;WEnd

	;MsgBox(1, "end", PixelGetColor($x, $y))

	;Exit
	$msg = Guigetmsg()

	Select
		Case $msg = $GUI_EVENT_CLOSE
			exit
	EndSelect

	$sprinting = CheckForImage('sprint.bmp')
	$stealthing = CheckForImage('stealth.bmp')

	GUICtrlSetData($sprintLabel, "Sprinting: " & $sprinting)
	GUICtrlSetData($stealthLabel, "Stealthing: " & $stealthing)

	If (GUICtrlRead($sprintCheckbox) == 1) Then
		If $stealthing == 0 Then
			If Not $sprinting Then
				ControlSend($windowName, "", "", $sprintKey) ; Sprint
				Sleep(500)
			EndIf
		EndIf
	EndIf
WEnd
