#include <Misc.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#requireadmin
#NoTrayIcon

;Local $searchKey = "{Tab}"
Local $searchKey = "4";

HotKeySet("{PAUSE}", "TogglePause")
If _Singleton("AFK",1) = 0 Then
    Exit
EndIf
$windowName = "Dark Age of Camelot © 2001-2017 Electronic Arts Inc. All Rights Reserved."

MsgBox(1,"Health Bar selection","Point at Healpoint on healthbar (Pet), % Low Health")
$Healthpos = MouseGetPos()
$Healthfull = PixelGetColor($Healthpos[0],$Healthpos[1])

MsgBox(1,"Mana", "Point at mana bar at Low %")
$ManaPos = MouseGetPos()
$Powerfull = PixelGetColor($ManaPos[0],$ManaPos[1])

$gui = GUICreate("AFKER", 280, 275,-1,-1)
;Buttons
$startButton = GUICtrlCreateButton("Start", 0, 0, 275, 45)
GUICtrlSetState($startButton, $GUI_DEFBUTTON)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
$stopButton = GUICtrlCreateButton("Stop", 0, 45, 275, 45)
GUICtrlSetState($stopButton, $GUI_DEFBUTTON)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
$statusButton = GUICtrlCreateButton("Status:  ", 0, 230, 280, 45)
GUICtrlSetState($statusButton, $GUI_DEFBUTTON)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
$pauseInfoLabel = GUICtrlCreateLabel("Pause Key will Pause  ", 65, 185, 250, 45)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
; Make GUI Show up
GUISetState(@SW_SHOW)
Global $isStarted = False

$Paused = false
$left = IniRead("config.ini", "Rectangle", "Left","")
$top = iniread("config.ini", "Rectangle", "Top","")
$right = iniread("config.ini", "Rectangle", "Right","")
$bottom = iniread("config.ini", "Rectangle", "Bottom","")
$hex = iniread("Config.ini","Color","Color''Hit''","")

Dim $timeoutLength = 30000

Dim $quickcastBegin = TimerInit()
Dim $quickcastDif  = TimerDiff($quickcastBegin)

Dim $targetTimeoutBegin = TimerInit()
Dim $targetTimeoutDif = TimerDiff($targetTimeoutBegin)

Dim $buffBegin = TimerInit()
Dim $buffDif = TimerDiff($buffBegin) + (60000 * 20)

Dim $healBegin = TimerInit()
Dim $healDif = TimerDiff($healBegin)

Dim $hasTarget = false

While True
	If Not WinActive($windowName, "") and $isStarted = False Then
		GUICtrlSetData($statusButton, "Status:  Stopped")
	EndIf
	If Not WinActive($windowName, "") and $isStarted = True Then
		GUICtrlSetData($statusButton, "Status:  Waiting for DAoC Window")
	EndIf

	sleep(5)
	$msg = Guigetmsg()

	Select
		Case $msg = $GUI_EVENT_CLOSE
			exit
		Case $msg = $stopButton
			$isStarted = False
		Case $msg = $startButton
			$isStarted = True
	EndSelect

	If WinActive($windowName, "") and $isStarted = true Then


		$coord = pixelsearch($left,$top,$right,$bottom,$hex)
		If Not @error Then
			$targetTimeoutDif = TimerDiff($targetTimeoutBegin)
			If $targetTimeoutDif > $timeoutLength Then
				ControlSend($windowName, "", "", "{ESCAPE}")
				Sleep(100)
				$targetTimeoutBegin = TimerInit()
			EndIf

			If $hasTarget = False Then
				OnTargetAqcuired()
				$hasTarget = True
			EndIf

			OnTarget()

			Select
				Case PixelGetColor($Healthpos[0],$Healthpos[1]) <> $Healthfull ; health low
					Sleep(200)
					OnHealthLow()
					Sleep(200)
				case PixelGetColor($ManaPos[0],$ManaPos[1]) <> $Powerfull ; power high enuf to claw
					Sleep(200)
			EndSelect

		Else
			;No Target stuff here.
			If $buffDif > 60000 * 19 Then
				OnBuffs()
				$buffBegin = TimerInit()
			EndIf
			$buffDif = TimerDiff($buffBegin)

			Sleep(100)

			If $hasTarget = True Then
				OnEndTarget()
			EndIf
			NoTarget()
			$hasTarget = false
		EndIf
	EndIf

WEnd

Func OnHealthLow()
    $healDif = $buffDif = TimerDiff($healBegin)
	If $healDif > 20000 Then
		OnBuffs()
		$healBegin = TimerInit()
	EndIf
	Sleep(1000)
	ControlSend($windowName, "", "", "5") ;
	Sleep(350)

EndFunc

Func OnTargetAqcuired()
	GUICtrlSetData($statusButton, "Status:  Attacking Target.")

	$targetTimeoutBegin = TimerInit()

	ControlSend($windowName, "", "", "f") ; Face
	Sleep(200)
	ControlSend($windowName, "", "", "1") ; Power tap
	Sleep(200)
	ControlSend($windowName, "", "", "1") ; Power tap
	Sleep(300)
	ControlSend($windowName, "", "", "2") ; Life tap (shade)
	Sleep(200)
	ControlSend($windowName, "", "", "2") ; Life tap (shade)
	Sleep(1200)
	ControlSend($windowName, "", "", "1") ; Power tap
	Sleep(250)
	ControlSend($windowName, "", "", "2") ; Life tap (shade)
	Sleep(450)
	ControlSend($windowName, "", "", "1") ; Power tap
	Sleep(250)
EndFunc

Func OnTarget()
	; Spells to use while you have a target
	If $quickcastDif > 32000 Then
		ControlSend($windowName, "", "", "3") ; Quickcast
		Sleep(200)
		ControlSend($windowName, "", "", "1") ; Power tap
		Sleep(1500)
		ControlSend($windowName, "", "", "1") ; Power tap
		Sleep(1500)
		$quickcastBegin = TimerInit()
	EndIf

	$quickcastDif = TimerDiff($quickcastBegin)

	ControlSend($windowName, "", "", "4") ; Assist
	Sleep(200)
	ControlSend($windowName, "", "", "2") ; Life tap (shade)
	Sleep(200)

EndFunc

Func OnEndTarget()
	GUICtrlSetData($statusButton, "Status:  Searching for Target.")
	$targetTimeoutBegin = TimerInit()
	ControlSend($windowName, "", "", "{F1}") ; This is the target group leader key by default.
	Sleep(250)
	ControlSend($windowName, "", "", "q")
	Sleep(250)
	ControlSend($windowName, "", "", "{ESC}")
	Sleep(250)
EndFunc

Func NoTarget()
	; Stuff to do while we have no target.
	ControlSend($windowName, "", "", $searchKey)
	Sleep(500)
EndFunc

Func OnBuffs()
	Sleep(500)
	ControlSend($windowName, "", "", "0") ; Target Pet
	Sleep(200)
	ControlSend($windowName, "", "", "9") ; Buff DEX
	Sleep(400)
	ControlSend($windowName, "", "", "8") ; Buff STR
	Sleep(2000)
	ControlSend($windowName, "", "", "7") ; Buff DEX/QUI
	Sleep(200)
	ControlSend($windowName, "", "", "6") ; Buff ABSORB
	Sleep(200)
	ControlSend($windowName, "", "", "{ESCAPE}")
	Sleep(2200)
EndFunc

Func TogglePause()
    $Paused = NOT $Paused
    While $Paused
        sleep(100)
        GUICtrlSetData($statusButton, "Status:  Paused")
    WEnd
    GUICtrlSetData($statusButton, "Status: ")
EndFunc
