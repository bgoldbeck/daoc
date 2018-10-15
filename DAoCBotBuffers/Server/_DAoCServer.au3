#RequireAdmin

TCPStartup()
Opt("TCPTimeout", 0)

Global $Timer = 600001
Global $TimerDifference = 600000 ;10 mins
Global $TimerTimeSpan   = 600000 ;10 mins

Global $allClientReturnMsg = ""
Global Const $VERSION = 0.89

#region ;Safe-to-edit things are below
Global $BindIP = "0.0.0.0"  ;Listen on all addresses
Global $BindPort = 61707        ;Listen on port
Global $Timeout = 45000        ;Max idle time is 45 seconds before calling a connection "dead"
Global $PacketSize = 128    ;Max packet size per-check is 2KB
Global $MaxClients = 50        ;Max simultaneous clients is 50
#endregion ;Stuff you shouldn't touch is below

Global $Listen
Global $Clients[1][5] ;[Index][Socket, IP, Timestamp, Buffer]
Global $Ws2_32 = DllOpen("Ws2_32.dll") ;Open Ws2_32.dll, it might get used a lot
Global $NTDLL = DllOpen("ntdll.dll") ;Open ntdll.dll, it WILL get used a lot
Global $CleanupTimer = TimerInit() ;This is used to time when things should be cleaned up

OnAutoItExitRegister("Close") ;Register this function to be called if the server needs to exit

$Clients[0][0] = 0
$Listen = TCPListen($BindIP, $BindPort, $MaxClients) ;Start listening on the given IP/port
If @error Then Exit 1 ;Exit with return code 1 if something was already bound to that IP and port

While 1
    $TimerDifference = TimerDiff($Timer)
	If $TimerDifference > $TimerTimeSpan Then
	    $allClientReturnMsg = "SERVER: Running ANTI-AFK Program"
        Run("AntiAFK.exe", "")
		$Timer = TimerInit()
    EndIf
    USleep(3000, $NTDLL) ;This is needed because TCPTimeout is disabled. Without this it will run one core at ~100%.
    ;The USleep function takes MICROseconds, not milliseconds, so 1000 = 1ms delay.
    ;When working with this granularity, you have to take in to account the time it takes to complete USleep().
    ;1000us (1ms) is about as fast as this should be set. If you need more performance, set this from 5000 to 1000,
    ;but doing so will make it consume a bit more CPU time to get that extra bit of performance.
    Check() ;Check recv buffers and do things
    If TimerDiff($CleanupTimer) > 30000 Then ;If it has been more than 1000ms since Cleanup() was last called, call it now
        $CleanupTimer = TimerInit() ;Reset $CleanupTimer, so it is ready to be called again
        Cleanup() ;Clean up the dead connections
    EndIf
    Local $iSock = TCPAccept($Listen) ;See if anything wants to connect
    If $iSock = -1 Then ContinueLoop ;If nothing wants to connect, restart at the top of the loop
    Local $iSize = UBound($Clients, 1) ;Something wants to connect, so get the number of people currently connected here
    If $iSize - 1 > $MaxClients And $MaxClients > 0 Then ;If $MaxClients is greater than 0 (meaning if there is a max connection limit) then check if that has been reached
        TCPCloseSocket($iSock) ;It has been reached, close the new connection and continue back at the top of the loop
        ContinueLoop
    EndIf
    ReDim $Clients[$iSize + 1][5] ;There is room for a new connection, allocate space for it here
    $Clients[0][0] = $iSize ;Update the number of connected clients
    $Clients[$iSize][0] = $iSock ;Set the socket ID of the connection
    $Clients[$iSize][1] = SocketToIP($iSock, $Ws2_32) ;Set the IP Address the connection is from
    $Clients[$iSize][2] = TimerInit() ;Set the timestamp for the last known activity timer
    $Clients[$iSize][3] = "" ;Blank the recv buffer
    $Clients[$iSize][4] = "" ;Blank the recv buffer
WEnd

Func Check() ;Function for processing
    If $Clients[0][0] < 1 Then Return ;If there are no clients connected, stop the function right now
    For $i = 1 To $Clients[0][0] ;Loop through all connected clients
        $sRecv = TCPRecv($Clients[$i][0], $PacketSize) ;Read $PacketSize bytes from the current client's buffer
        If $sRecv <> "" Then $Clients[$i][3] &= $sRecv ;If there was more data sent from the client, add it to the buffer
        If $Clients[$i][3] = "" Then ContinueLoop ;If the buffer is empty, stop right here and check more clients
        $Clients[$i][2] = TimerInit() ;If it got this far, there is data to be parsed, so update the activity timer
        #region ;Example packet processing stuff here. This is handling for a simple "echo" server with per-packet handling

            ;This does NOT pull the first complete packet, this pulls ALL complete packets, leaving only potentially incomplete packets in the buffer
            If $sRecv = "" Then ContinueLoop ;Check if there were any complete "packets"
            $Clients[$i][3] = StringTrimLeft($Clients[$i][3], StringLen($sRecv) + 1) ;remove what was just read from the client's buffer
            $sPacket = StringSplit($sRecv, ",", 1) ;Split all complete packets up in to an array, so it is easy to work with them
            For $j = 1 To $sPacket[0] ;Loop through each complete packet; This is where any packet processing should be done
			   Select
				  Case $sPacket[1] = "usernameRequest"
					 Local $retMsg = UsernameRequest($sPacket[2])
					 TCPSend($Clients[$i][0], $retMsg) ;Echo back the packet the client sent
					 $Clients[$i][4] = $sPacket[2]
					 $allClientReturnMsg = "User:" & $sPacket[2] & " Connecting..."

				  Case StringInStr($sPacket[1], "buffMelee", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("BuffMelee.exe", "")

				  Case StringInStr($sPacket[1], "buffMyAssistMelee", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("BuffAssistMelee.exe", "")

				  Case StringInStr($sPacket[1], "buffMyAssistCaster", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("BuffAssistCaster.exe", "")

				  Case StringInStr($sPacket[1], "buffMyAssistSkeleton", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("BuffAssistSkeleton.exe", "")

				  Case StringInStr($sPacket[1], "buffCaster", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("BuffCaster.exe", "")

				  Case StringInStr($sPacket[1], "buffDexQui", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("DexQuick.exe", "")

				  Case StringInStr($sPacket[1], "buffDQSC", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("DexQuickStrCon.exe", "")

				  Case StringInStr($sPacket[1], "vamp", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("BuffVamp.exe", "")

				  Case StringInStr($sPacket[1], "necro", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("BuffNecro.exe", "")

				  Case StringInStr($sPacket[1], "CureRez1", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("CureRez1.exe", "")

				  Case StringInStr($sPacket[1], "CureRez2", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("CureRez2.exe", "")

				  Case StringInStr($sPacket[1], "buffFullSpecs", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("FullSpecs.exe", "")

				  Case StringInStr($sPacket[1], "StickMe", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("Stick.exe", "")

				  Case StringInStr($sPacket[1], "HealMe", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("HealMe.exe", "")

				  Case StringInStr($sPacket[1], "Talk1", 0)
					 Local $msg = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Say", $msg)
					 $allClientReturnMsg = $sPacket[4] & " -" & $msg
		             $Timer = TimerInit()
					 Run("Talk1.exe", "")

				  Case StringInStr($sPacket[1], "Talk2", 0)
					 Local $msg = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Say", $msg)
					 $allClientReturnMsg = $sPacket[4] & " -" & $msg
		             $Timer = TimerInit()
					 Run("Talk2.exe", "")

				  Case StringInStr($sPacket[1], "aoeBuffs", 0)
					 Local $username = $sPacket[2]
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("AOEBuffs.exe", "")

				  Case StringInStr($sPacket[1], "buffResist", 0)
					 Local $username = $sPacket[2]
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("Resists.exe", "")

				  Case StringInStr($sPacket[1], "Recall", 0)
					 Local $username = $sPacket[2]
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("Recall.exe", "")

				  Case StringInStr($sPacket[1], "Recharge", 0)
					 Local $username = $sPacket[2]
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("Recharge.exe", "")

				  Case StringInStr($sPacket[1], "Guild", 0)
					 Local $username = $sPacket[2]
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("GRecall.exe", "")

				  Case StringInStr($sPacket[1], "haste", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("haste.exe", "")

				  Case StringInStr($sPacket[1], "af", 0)
					 Local $username = $sPacket[2]
					 IniWrite(@SCRIPTDIR & "\usermsg.ini", "User", "Name", $username)
					 $allClientReturnMsg = $sPacket[3] & " -" & $username
		             $Timer = TimerInit()
					 Run("AF.exe", "")
			   EndSelect
            Next
			For $i = 1 To $Clients[0][0] ;Loop through all connected clients
			   If $allClientReturnMsg <> "" Then
				  TCPSend($Clients[$i][0], $allClientReturnMsg)
			   EndIf
			Next
	        $allClientReturnMsg = ""
		 ;$differ = TimerDiff($stopwatch)
		 ;MsgBox(1, "", $differ)
        #endregion ;Example
    Next
EndFunc

Func Cleanup() ;Clean up any disconnected clients to regain resources
    If $Clients[0][0] < 1 Then
	  Return ;If no clients are connected then return
    EndIf
    Local $iNewSize = 0
    For $i = 1 To $Clients[0][0] ;Loop through all connected clients
        $Clients[$i][3] &= TCPRecv($Clients[$i][0], $PacketSize) ;Dump any data not-yet-seen in to their recv buffer
        If @error Or TimerDiff($Clients[$i][2]) > $Timeout Then ;Check to see if the connection has been inactive for a while or if there was an error
            TCPCloseSocket($Clients[$i][0]) ;If yes, close the connection
            $Clients[$i][0] = -1 ;Set the socket ID to an invalid socket
			$allClientReturnMsg = "User:" & $Clients[$i][4] & " Disconnected.."
        Else
            $iNewSize += 1
        EndIf
    Next
    If $iNewSize < $Clients[0][0] Then ;If any dead connections were found, drop them from the client array and resize the array
        Local $iSize = UBound($Clients, 2) - 1
        Local $aTemp[$iNewSize + 1][$iSize + 1]
        Local $iCount = 1
        For $i = 1 To $Clients[0][0]
            If $Clients[$i][0] = -1 Then ContinueLoop
            For $j = 0 To $iSize
                $aTemp[$iCount][$j] = $Clients[$i][$j]
            Next
            $iCount += 1
        Next
        $aTemp[0][0] = $iNewSize
        $Clients = $aTemp
	 EndIf
EndFunc

Func Close()
    DllClose($Ws2_32) ;Close the open handle to Ws2_32.dll
    DllClose($NTDLL) ;Close the open handle to ntdll.dll
    For $i = 1 To $Clients[0][0] ;Loop through the connected clients
        TCPCloseSocket($Clients[$i][0]) ;Force the client's connection closed
    Next
    TCPShutdown() ;Shut down networking stuff
EndFunc

Func SocketToIP($iSock, $hDLL = "Ws2_32.dll") ;A rewrite of that _SocketToIP function that has been floating around for ages
    Local $structName = DllStructCreate("short;ushort;uint;char[8]")
    Local $sRet = DllCall($hDLL, "int", "getpeername", "int", $iSock, "ptr", DllStructGetPtr($structName), "int*", DllStructGetSize($structName))
    If Not @error Then
        $sRet = DllCall($hDLL, "str", "inet_ntoa", "int", DllStructGetData($structName, 3))
        If Not @error Then Return $sRet[0]
    EndIf
    Return "0.0.0.0" ;Something went wrong, return an invalid IP
EndFunc

Func USleep($iUsec, $hDLL = "ntdll.dll") ;A rewrite of the _HighPrecisionSleep function made by monoceres (Thanks!)
    Local $hStruct = DllStructCreate("int64")
    DllStructSetData($hStruct, 1, -1 * ($iUsec * 10))
    DllCall($hDLL, "dword", "ZwDelayExecution", "int", 0, "ptr", DllStructGetPtr($hStruct))
EndFunc

Func UsernameRequest($name)
   If $name = "" Then
	  Return "Kill"
   EndIf
   For $i = 1 To $Clients[0][0] ;Loop through all connected clients
	  If $Clients[$i][4] = $name Then
		 ;Return "Kill"
	  EndIf
   Next
   Return "userAck," & $name & "," & $VERSION & ","
EndFunc
