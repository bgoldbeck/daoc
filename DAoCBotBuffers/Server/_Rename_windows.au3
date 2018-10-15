#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>
#include <EditConstants.au3>
Opt("WinTitleMatchMode", 2)
#NoTrayIcon
#RequireAdmin
If _Singleton("Once",1) = 0 Then
	WinActivate("Double DAOC Forever")
    Exit
EndIf

$Begin = 9999999
Dim $Running = True
Dim $Gui = GUICreate("Double DAOC Forever", 350, 200,-1,-1)
; Make GUI Show up
GuiSetState(@SW_SHOW)
;Buttons
Dim $SetWindowBtn1 = GUICtrlCreateButton("Set Window 1", 5, 5, 150, 50)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
Dim $SetWindowBtn2 = GUICtrlCreateButton("Set Window 2", 195, 5, 150, 50)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
Dim $StartBtn = GUICtrlCreateButton("Start", 5, 160, 100, 30)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
Dim $StopBtn = GUICtrlCreateButton("Stop", 110, 160, 100, 30)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

;Inputs
Dim $SleepTimerSlider = GUICtrlCreateSlider(90, 120, 100, 25)
GUICtrlSetLimit(-1, 900, 1)
GUICtrlSetData($SleepTimerSlider, 30)
Dim $WindowName1Input = GUICtrlCreateInput("DAOC1", 5, 60, 150, 25)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
Dim $WindowName2Input = GUICtrlCreateInput("DAOC2", 195, 60, 150, 25)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
Dim $AfkKeyInput = GUICtrlCreateInput("9", 5, 120, 50, 25)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
GUICtrlSetLimit(-1, 1, -1)

;Labels
Dim $SleepLbl  = GUICtrlCreateLabel("Sleep(Secs) " & GUICtrlRead($SleepTimerSlider) , 80, 95, 120, 25)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
Dim $AfkKeyLbl = GUICtrlCreateLabel("Afk Key", 5, 95, 70, 25)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
Dim $StatusLbl = GUICtrlCreateLabel("...", 215, 160, 150, 30)
GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

While $Running
	$msg = GuiGetMsg()
	GUICtrlSetData($SleepLbl, "Sleep(Secs) " & GUICtrlRead($SleepTimerSlider))
	Select
		Case $msg = $GUI_EVENT_CLOSE
			$Running = False

		Case $msg = $SetWindowBtn1
			For $i = 0 to 4
				GUICtrlSetData($SetWindowBtn1, (5 - $i))
				Sleep(1000)
			Next
			$hwndl = WinGetHandle ('')
			WinSetTitle($hwndl, '', GUICtrlRead($WindowName1Input))

			GUICtrlSetData($SetWindowBtn1, "Set Window 1")

		Case $msg = $SetWindowBtn2
			For $i = 0 to 4
				GUICtrlSetData($SetWindowBtn2, (5 - $i))
				Sleep(1000)
			Next
			$hwndl = WinGetHandle ('')
			WinSetTitle($hwndl, '', GUICtrlRead($WindowName2Input))
			GUICtrlSetData($SetWindowBtn2, "Set Window 2")

		Case $msg = $StartBtn
			GUICtrlSetData($StatusLbl, "Running...")
			While 1
				$msg = GUIGetMsg()
				Sleep(15)
				If Not WinExists(GUICtrlRead($WindowName1Input)) Then
					$Begin = 9999999
					GUICtrlSetData($StatusLbl, "Missing Window.")
					ExitLoop
				ElseIf Not WinExists(GUICtrlRead($WindowName2Input)) Then
					$Begin = 9999999
					GUICtrlSetData($StatusLbl, "Missing Window.")
					ExitLoop
				EndIf

				$Dif = TimerDiff($Begin)
				If $Dif > (GUICtrlRead($SleepTimerSlider) * 1000) Then
					WinActivate(GUICtrlRead($WindowName1Input))
					Sleep(700)
					Send(GUICtrlRead($AfkKeyInput))
					Sleep(700)
					WinActivate(GUICtrlRead($WindowName2Input))
					Sleep(700)
					Send(GUICtrlRead($AfkKeyInput))
					$Begin = TimerInit()
				EndIf
				Select
					Case $msg = $StopBtn
						$Begin = 9999999
						GUICtrlSetData($StatusLbl, "Stopped.")
						ExitLoop
					Case $msg = $GUI_EVENT_CLOSE
						$Running = False
						ExitLoop
				EndSelect

				Sleep(15)
			WEnd

		EndSelect

		Sleep(15)
WEnd