#include <Misc.au3>
#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#requireadmin
	if _Singleton("PixelScanner",1) = 0 Then
    Exit
EndIf
; Scans the screen for the yellow mark on screen ;
; returns x and y coords of the yellow mark;

dim $once = 0, $hex
dim $exititem, $labelOne, $closeButton
dim $dll = DllOpen("user32.dll")
$answer = msgbox(4100,"!","Do you want to use the default color for the ''H'' in Yellow as 0xFFFF00")
if $answer = 6 Then
	$rpeat = 0
	iniwrite("Config.ini","Color","Color''Hit''","0xFFFF00")
Else
	$rpeat = 1
	endif
while $rpeat = 1
	if $once = 1 then
	Splashtexton("TARGET ''Hit''","Point at the 'H' in Hit in front of the target's health and press ''F12''",@desktopwidth/6,@desktopheight/9,@desktopwidth/0,@desktopheight/0)
	$once = 0
	endif
	$Targetpos = MouseGetPos()
	$Target = PixelGetColor($Targetpos[0],$Targetpos[1])
	ToolTip("Mousecolor = " & $Target,0,0)
	If _IsPressed("7B", $dll) Then
	$Targetpos = MouseGetPos()
	$Target = PixelGetColor($Targetpos[0],$Targetpos[1])
	iniwrite("Config.ini","Color","Color''Hit''","0x"&Hex($Target, 6))
	splashoff()

	exitloop
	endif
	WEnd


_mainGUI()
winactivate("Pixel Scan")
while 1
	$msg = Guigetmsg()

	select
	Case $msg = $exititem
		exit
	Case $msg = $closeButton
	$winPos = wingetpos("Pixel Scan")
	$right = $winPos[0] + $winPos[2]
	$bottom = $winPos[1] + $winPos[3]
		guidelete()
		exitloop
	Case $msg = $GUI_EVENT_CLOSE
		exit
	endselect
wend


while 1


	$hex = iniread("Config.ini","Color","Color''Hit''","1")
	iniwrite("config.ini", "Rectangle", "Left",$winPos[0])
	iniwrite("config.ini", "Rectangle", "Top",$winPos[1])
	iniwrite("config.ini", "Rectangle", "Right",$right)
	iniwrite("config.ini", "Rectangle", "Bottom",$bottom)
	$coord = pixelsearch($winPos[0],$winPos[1],$right,$bottom,$hex)
	If Not @error Then
		mousemove($coord[0],$coord[1],3)
		iniwrite("Config.ini","Hit Position","X",$coord[0])
		iniwrite("Config.ini","Hit Position","Y",$coord[1])

		exit
    EndIf

wend

func _mainGUI()
$gui = GUICreate("Pixel Scan", 185, 155,500,500)
guisetstate(@SW_SHOW) ; Make GUI Show up
;Menusd
	$filemenu = GUICtrlCreateMenu("File")
	$exititem = GUICtrlCreateMenuItem("Exit", $filemenu)
	$labelOne = Guictrlcreatelabel("Drag This Window Over Your Health/Pow/Endo/Hit Bar and click ''Close'': Also, make sure you have a target that is of NON Yellow con",5,0,180, 100)
	GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
	$closeButton = GUICtrlCreateButton("Close", 0, 100, 185,  35)
	GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
endfunc
