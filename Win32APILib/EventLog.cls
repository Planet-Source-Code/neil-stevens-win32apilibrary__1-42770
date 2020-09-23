VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "EventLog"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'********************************************************************************************************
'
' Windows Event Logging object, allows the developer to log events directly to the Windows
' Event Log, rather than using the VB facility
'
' Author: Neil Stevens
' Revision: 1.0
' Released: 01/28/2003
' Revised:
'       Class created
'
'********************************************************************************************************
Option Explicit

Private Declare Function ReportEvent Lib "advapi32.dll" Alias "ReportEventA" (ByVal hEventLog As Long, _
    ByVal wType As Long, ByVal wCategory As Long, ByVal dwEventID As Long, lpUserSid As Any, _
    ByVal wNumStrings As Long, ByVal dwDataSize As Long, ByVal lpStrings As Long, lpRawData As Any) As Long
Private Declare Function RegisterEventSource Lib "advapi32.dll" Alias "RegisterEventSourceA" (ByVal lpUNCServerName As String, _
    ByVal lpSourceName As String) As Long
Private Declare Function DeregisterEventSource Lib "advapi32.dll" (ByVal hEventLog As Long) As Long

Private MyRegistry As Registry          ' Used to make sure we have a message DLL
Private hLog As Long
Private mApp As String
Dim tGlobal As Miscellaneous

' Enum - Which event log to log to
Public Enum EvtLog
    evtApplication
    evtSecurity
    evtSystem
End Enum

Private Log As EvtLog
Private mMessageDLL As String

Public Enum EvtLogType
    EVENTLOG_SUCCESS = &H0
    EVENTLOG_ERROR_TYPE = &H1
    EVENTLOG_WARNING_TYPE = &H2
    EVENTLOG_INFORMATION_TYPE = &H4
    EVENTLOG_AUDIT_SUCCESS = &H8
    EVENTLOG_AUDIT_FAILURE = &H10
End Enum

Public Enum EvtCategoryType
    catDevices = 1
    catDisk = 2
    catPrinters = 3
    catServices = 4
    catShell = 5
    catSystemEvent = 6
    catNetwork = 7
End Enum

Public Property Let AppName(strVal As String)
    mApp = Trim(strVal)
    
    ' Insert your application name here
    ' WARNING:- Keep the sub key paths the same
    
    If Log = evtApplication Then
        MyRegistry.SubKey = "CurrentControlSet\Services\EventLog\Application\" & mApp
    End If
    
    If Log = evtSecurity Then
        MyRegistry.SubKey = "CurrentControlSet\Services\EventLog\Security\" & mApp
    End If
    
    If Log = evtSystem Then
        MyRegistry.SubKey = "CurrentControlSet\Services\EventLog\System\" & mApp
    End If
End Property

Public Property Get AppName() As String
    AppName = mApp
End Property

Public Sub Connect()
    ' Routine to check if the key exists or not
    ' Doing this ensures that everything else works ok
    If Not MyRegistry.KeyExists Then
        MyRegistry.CreateKey
        MyRegistry.SetRegistryValue "EventMessageFile", mMessageDLL, REG_EXPAND_SZ
        MyRegistry.SetRegistryValue "TypesSupported", 7, REG_DWORD
    End If
    
    Dim TheName As String
    Set tGlobal = New Win32APILib.Miscellaneous
    Dim t As New Win32APILib.System
    TheName = t.GetComputerName
    TheName = tGlobal.TrimNull(TheName)
    
    ' Now we can go ahead and get a handle to the log file
    hLog = RegisterEventSource(TheName, mApp)
End Sub

Public Property Get MessageDLL() As String
    MessageDLL = mMessageDLL
End Property

Public Property Let MessageDLL(strVal As String)
    mMessageDLL = Trim(strVal)
End Property

Public Property Get UseLog() As EvtLog
    UseLog = Log
End Property

Public Property Let UseLog(LogToUse As EvtLog)
    Log = LogToUse
End Property

Public Sub WriteToLog(MessageID As Long, LogType As EvtLogType, LogCategory As EvtCategoryType, _
                                Optional wNumStrings As Long, Optional ByVal lpStrings As Long)
    ReportEvent hLog, LogType, LogCategory, MessageID, ByVal 0, wNumStrings, 0, ByVal lpStrings, ByVal 0
End Sub

Private Sub Class_Initialize()
    Set MyRegistry = New Registry
    mApp = ""
    Log = evtApplication
    MyRegistry.hKey = HKEY_LOCAL_MACHINE
    MyRegistry.KeyRoot = "System"
End Sub

Private Sub Class_Terminate()
    Set MyRegistry = Nothing
    DeregisterEventSource hLog
End Sub
