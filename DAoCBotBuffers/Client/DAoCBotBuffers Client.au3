#include <Misc.au3>
if _Singleton("ClientBot",1) = 0 Then
   Exit
EndIf

#include <GUICONSTANTS.AU3>
#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <WINDOWSCONSTANTS.AU3>
#include <STATICCONSTANTS.AU3>
#include <EDITCONSTANTS.AU3>
#Include <GuiEdit.au3>
#Include <WinAPI.au3>
#Include <DATE.au3>
#include <inet.au3>
#include <ComboConstants.au3>
#RequireAdmin

Global $DAoCCharsFileName = @ScriptDir & "\data\DAoCChars.ini"
Global $Timer = TimerInit()
Global $LastTime = 5000

Global $DiscTimer = TimerInit()
Global $DiscLastTime = 19000

If Not FileExists($DAoCCharsFileName) Then
	$file = FileOpen($DAoCCharsFileName, 10)
	IniWrite($DAoCCharsFileName, "Chars", "numChars", "1")
	IniWrite($DAoCCharsFileName, "Chars", "name1", "Daoc Name Here")
	FileClose($file)
 EndIf

If Not FileExists(@ScriptDir & "\data\user.ini") Then
	$file = FileOpen(@ScriptDir & "\data\user.ini", 10)
	IniWrite(@ScriptDir & "\data\user.ini", "settings", "name", "")
	$input = InputBox("Enter Username", "Please enter your desired username")
	IniWrite(@ScriptDir & "\data\user.ini", "settings", "name", $input)
	IniWrite(@ScriptDir & "\data\user.ini", "settings", "ip", "192.168.1.201")
	IniWrite(@ScriptDir & "\data\user.ini", "settings", "port", "61707")
	FileClose($file)
 EndIf

Global $numChars = IniRead($DAoCCharsFileName, "Chars", "numChars", "")
Global $DAoCCharNames[99]

For $i = 0 to ($numChars - 1)
	$DAoCCharNames[$i] = IniRead($DAoCCharsFileName, "Chars", "name" & ($i + 1), "")
Next

Global $ServerVersion
Global $version = "0.89"
Global $username = ""
$GUIStyle = BitOR($WS_DLGFRAME,$WS_POPUP, $WS_VISIBLE)
$GUIStyleEx = BitOR ($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE)
$EditStyle = BitOR($ES_MULTILINE,$WS_VSCROLL)
$EditStyleEx = BitOR($EditStyle, $ES_READONLY)

$W = 0xFFFFFF
$B = 0x0
$Titleb = 0x7F7F7F
TCPStartup()
$0 = 0
$00 = 0
$000 = 0

$ip = TCPNameToIP(IniRead(@ScriptDir & "\data\user.ini", "settings", "ip", "thefarm.dyndns.biz"))

Opt("TCPTimeout", 1000)

;The servers IP address... default is your @IPADDRESS1. MUST BE THE SERVERS IP ADDRESS CANNOT BE YOUR CLIENTS!!!
$port = IniRead(@ScriptDir & "\data\user.ini", "settings", "port", "61706")

;Makes the port # can be anything between 1 and 60000.
;(the maximum is a guess i don't know how many ports there are butits close).
;and ONLY if the port is not already being used.
;MUST BE SERVER OPENED PORT NOT ONE ON YOUR COMPUTER!!!
SplashTextOn("DAoCBot Client", "Connecting.." & @CRLF & "IP: " & $ip & @CRLF & "Port: " & $port, 500, 200)

$Socket = TCPConnect($ip, $port)
;Connects to an open socket on the server...


If $Socket == -1 Then
   SplashTextOn("DAoCBot Client", "Connecting.." & @CRLF & "IP: " & "192.168.1.201" & @CRLF & "Port: " & $port, 500, 200)
   $Socket = TCPConnect(TCPNameToIP("192.168.1.201"), $port)
EndIf

If $Socket == -1 Then
   SplashTextOn("DAoCBot Client", "Failed to connect!", 500, 200)
   Sleep(1000)
   Exit
EndIf

SplashTextOn("DAoCBot Client", "Requesting Username " & IniRead(@ScriptDir & "\data\user.ini", "settings", "name", ""), 500, 200)
TCPSend($Socket, "usernameRequest," & IniRead(@ScriptDir & "\data\user.ini", "settings", "name", ""))
While 1

	$Recv = TCPRecv($Socket, 10000000)

	If StringInStr($Recv, "userAck", 1) Then
		 $split = StringSplit($Recv, ",", 1)
		 SplashOff()
		 $username = $split[2]
		 $ServerVersion = $split[3]
		 ExitLoop

	 EndIf
	 If StringInStr($Recv, "Kill", 1) Then
	    SplashTextOn("DAoCBot Client", "Could not connect this user: " & IniRead(@ScriptDir & "\data\user.ini", "settings", "name", ""), 500, 200)
		Sleep(2000)
		SplashOff()
		Exit
	  EndIf
	Sleep(100)
WEnd

SplashOff()
If $username = "" Then
   SplashTextOn("DAoCBot Client", "Username ERROR!", 500, 200)
   Sleep(1500)
   Exit
EndIf

$GUI = GUICreate (@ScriptName & " - " & $username, 525, 280)
$Console = GUICtrlCreateEdit ('',0,0,300,150,$EditStyleEx)
$daocNameCombo = GUICtrlCreateCombo(IniRead($DAoCCharsFileName, "Chars", "name1", ""),0,205,100,25, BitOR($GUI_SS_DEFAULT_COMBO,$CBS_DROPDOWNLIST))
For $i = 0 To ($numChars - 1)
	If Not $i = 0 Then
		GUICtrlSetData($daocNameCombo, IniRead($DAoCCharsFileName, "Chars", "name" & ($i + 1), ""))
	EndIf
 Next



$daocNameInput = GUICtrlCreateInput("", 300,203,150,25)
$Send = GUICtrlCreateEdit ('',0,150,225,50,$EditStyle)
$btnAddChar = GUICtrlCreateButton("<-- Add",235,203,50,25)
$btnRemoveChar = GUICtrlCreateButton("Remove",0,230,50,25)
$btnSend = GUICtrlCreateButton("Send",225,150,75,50)
$btnAoeBuffs = GUICtrlCreateButton("AoE Buffs",300,0,75,25)
$btnBuffCaster = GUICtrlCreateButton("Buff Caster",300,30,75,25)
$btnBuffMelee = GUICtrlCreateButton("Buff Melee",300,60,75,25)
$btnBuffFullSpecs = GUICtrlCreateButton("Full Specs",375,60,75,25)
$btnBuffDexQui = GUICtrlCreateButton("Dex/Qui",375,0,75,25)
$btnBuffDexQStrC = GUICtrlCreateButton("Dex/Q Str/C",375,30,75,25)
$btnBuffResists = GUICtrlCreateButton("Resists",450,0,75,25)
$btnBuffCureRez1 = GUICtrlCreateButton("Bot1 Cure Rez",450,30,75,25)
$btnBuffCureRez2 = GUICtrlCreateButton("Bot2 Cure Rez",450,60,75,25)
$btnHealMe = GUICtrlCreateButton("Heal Me",450,120,75,25)
$btnStickToMe = GUICtrlCreateButton("Stick Me",300, 120, 75, 25)

$btnTalk1 = GUICtrlCreateButton("Talk1",300, 150, 75, 25)
$btnTalk2 = GUICtrlCreateButton("Talk2",450, 150, 75, 25)

$btnBuffAssistMelee = GUICtrlCreateButton("Buff My Assist (Melee)",300, 230, 150, 25)
$btnBuffAssistCaster = GUICtrlCreateButton("Buff My Assist (Caster)",300, 255, 150, 25)
$btnBuffAssistSkeleton = GUICtrlCreateButton("Buff My Skeleton",200, 255, 100, 25)

;$btnSpa1  = GUICtrlCreateButton("Spa1", 300, 90, 75, 25)
$btnHaste = GUICtrlCreateButton("Haste", 375, 90, 75, 25)
$btnAF = GUICtrlCreateButton("AF", 375, 120, 75, 25)
;$btnVamp = GUICtrlCreateButton("Vamp", 375, 150, 75, 25)
$btnRecharge = GUICtrlCreateButton("Recharge", 375, 175, 75, 25)
;$btnNecro = GUICtrlCreateButton("Necro",300, 175, 75, 25)

;$btnSpa2  = GUICtrlCreateButton("Spa2", 450, 90, 75, 25)

$btnRecall  = GUICtrlCreateButton("Recall", 100, 230, 50, 25)
$btnGRecall = GUICtrlCreateButton("G-Recall", 155, 230, 50, 25)

_GUICtrlEdit_AppendText ($Console,_NowTime () & ' -- ' & " Welcome " & $username & @CRLF & "You are running -v." & $version & @CRLF & "While server is ---v." & $ServerVersion & @CRLF)

guisetstate(@SW_SHOW) ; Make GUI Show up

Sleep(500)

While 1
	Local $msg = GUIGetMsg()

    _Recv_From_Server ()
	Sleep(15)

	If $msg = $GUI_EVENT_CLOSE Then _Exit()

   Select
	  Case $msg = $btnAddChar
		  $daocName = GUICtrlRead($daocNameInput)

		  If Not $daocName = "" Then
			  GUICtrlSetData($daocNameCombo, $daocName)
			  GUICtrlSetData($daocNameInput, "")
			  $numChars += 1
			  $DAoCCharNames[$numChars - 1] = $daocName
		  EndIf

	  Case $msg = $btnRemoveChar
		  $daocName = GUICtrlRead($daocNameCombo)
		  If Not $daocName = "" Then
			  For $i = 0 To ($numChars - 1)
				  $match = StringCompare($daocName, $DAoCCharNames[$i], 1)
				  If $match = 0 Then
					  ;Erase char name from array
					  $DAoCCharNames[$i] = ""
					  $numChars -= 1
					  GUICtrlDelete($daocNameCombo)

					  $daocNameCombo = GUICtrlCreateCombo("",0,205,100,25, BitOR($GUI_SS_DEFAULT_COMBO,$CBS_DROPDOWNLIST))
				  EndIf
			  Next
		  EndIf
		  ;Refill combo from array
		  For $j = 0 to ($numChars)
			  If Not $DAoCCharNames[$j] = "" Then
				  GUICtrlSetData($daocNameCombo, $DAoCCharNames[$j], "")
			  EndIf
		  Next
	  Case $msg = $btnSend
		  _Send()

	  Case $msg = $btnAoeBuffs
		  GUICtrlSetData ($Send, "aoeBuffs")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffCaster
		  GUICtrlSetData ($Send,  "buffCaster")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffMelee
		  GUICtrlSetData ($Send,  "buffMelee")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffFullSpecs
		  GUICtrlSetData ($Send,  "buffFullSpecs")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffDexQui
		  GUICtrlSetData ($Send,  "buffDexQui")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffDexQStrC
		  GUICtrlSetData ($Send,  "buffDQSC")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffResists
		  GUICtrlSetData ($Send,  "buffResist")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffCureRez1
		  GUICtrlSetData ($Send,  "CureRez1")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffCureRez2
		  GUICtrlSetData ($Send,  "cureRez2")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnHealMe
		  GUICtrlSetData ($Send,  "HealMe")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnStickToMe
		  GUICtrlSetData ($Send,  "StickMe")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnTalk1
		  $typed = GUICtrlRead($Send)
		  GUICtrlSetData ($Send, '')
		  GUICtrlSetData ($Send,  "TALK1, " & $typed)
		  _Send()
		  Sleep(100)

	  Case $msg = $btnTalk2
		  $typed = GUICtrlRead($Send)
		  GUICtrlSetData ($Send, '')
		  GUICtrlSetData ($Send,  "TALk2, " & $typed)
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffAssistMelee
		  GUICtrlSetData ($Send,  "BuffMyAssistMelee")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffAssistCaster
		  GUICtrlSetData ($Send,  "BuffMyAssistCaster")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnBuffAssistSkeleton
		  GUICtrlSetData ($Send,  "BuffMyAssistSkeleton")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnHaste
		  GUICtrlSetData ($Send,  "haste")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnAF
		  GUICtrlSetData ($Send,  "af")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnRecall
		  GUICtrlSetData ($Send,  "Recall")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnGRecall
		  GUICtrlSetData ($Send,  "Guild")
		  _Send()
		  Sleep(100)

	  Case $msg = $btnRecharge
		  GUICtrlSetData ($Send,  "Recharge")
		  _Send()
		  Sleep(100)

   EndSelect

WEnd

Func _Send ()
   $cmd = GUICtrlRead($Send)
   ;Make sure msg sent isnt nothing.
   If $cmd = '' Then Return
   TCPSend($Socket, $cmd & "," & GUICtrlRead($daocNameCombo) & "," & $username & ": " & $cmd)
   ;Clear the type box for chat
   GUICtrlSetData ($Send, '')
   Sleep(50)
EndFunc   ;==>_send_

Func _Recv_From_Server ()

   $LastTime = TimerDiff($Timer)
   $Recv = ''
   If $LastTime > 1200 Then

	  $Recv = TCPRecv($Socket, 128)
	  TCPSend($Socket, "StillAlive")

	  $Timer = TimerInit()

   EndIf
   If $Recv = '' Then Return


   If StringInStr($Recv, "userAck", 1) Then Return

   _GUICtrlEdit_AppendText ($Console, _NowTime () & ' -- ' & $Recv & @CRLF)

   Sleep(100)
EndFunc   ;==>_Recv_From_Server_

Func _Minn ()
    WinSetState ($GUI, '', @SW_MINIMIZE)
EndFunc

Func _Exit ()
    TCPCloseSocket ($Socket)
    TCPShutdown()
	;Save Daoc Chars on normal exit only.
	$file = FileOpen($DAoCCharsFileName, 10)
	FileClose($file)

	IniWrite($DAoCCharsFileName, "Chars", "numChars", $numChars)
	$y = 0
	For $i = 0 To 98
		If $DAoCCharNames[$i] = "" Then
			$y += 1
		Else
			IniWrite($DAoCCharsFileName, "Chars", "name" & (($i + 1) - $y), $DAoCCharNames[$i])
		EndIf
	Next
	SplashOff()
   IniWrite($DAoCCharsFileName, "Chars", "Class", GUICtrlRead($daocClassCombo))
    Exit
EndFunc   ;==>_Exit_