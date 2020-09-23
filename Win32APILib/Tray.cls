VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Tray"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private Declare Function Shell_NotifyIcon Lib "shell32.dll" Alias "Shell_NotifyIconA" _
    (ByVal dwMessage As Long, ByRef pnid As NOTIFYICONDATA) As Long

Private Type NOTIFYICONDATA
    cbSize            As Long
    hWnd              As Long
    uID               As Long
    uFlags            As Long
    uCallbackMessage  As Long
    hIcon             As Long
    szTip         As String * 128
    dwState       As Long
    dwStateMask   As Long
    szInfo        As String * 256
    uTimeoutOrVersion As Long
    szInfoTitle   As String * 64
    dwInfoFlags   As Long
End Type

Public Enum TRAY_STYLE
    tsSimple = &H0
    tsBalloon = &H1
End Enum

Public Enum TRAY_MESSAGE_ICON
    tmiNone = &H0
    tmiInfo = &H1
    tmiWarning = &H2
    tmiError = &H3
End Enum

Public Enum MOUSEMESSAGES
    mmMouseOver = &H200
    mmLeftButtonDoubleClick = &H203
    mmLeftButtonUp = &H202
    mmLeftButtonDown = &H201
    mmMiddleButtonDoubleClick = &H209
    mmMiddleButtonUp = &H207
    mmMiddleButtonDown = &H208
    mmRightButtonDoubleClick = &H206
    mmRightButtonUp = &H204
    mmRightButtonDown = &H205
End Enum

Public Enum TRAY_MESSAGES
    tmAdd = &H0
    tmDelete = &H2
    tmModify = &H1
    tmSetFocus = &H4
    tmSetVersion = &H8
End Enum

Public Enum TRAY_ICONFLAGS
    tiIcon = &H2
    tiMessage = &H1
    tiTip = &H4
    tiInfo = &H10
    tiState = &H8
End Enum

Const NOTIFYICON_VERSION = 3
Const NOTIFYICON_OLDVERSION = 0

Private mvarKey As Variant

Public Sub AddNew(hWnd As Long, ByVal uID As Long, _
                            Optional ByVal Icon As stdole.IPictureDisp, _
                            Optional ByVal TrayStyle As TRAY_STYLE = tsSimple, _
                            Optional ByVal Message As String, Optional ByVal Title As String, _
                            Optional ByVal MessageIcon As TRAY_MESSAGE_ICON = tmiNone, _
                            Optional ByVal CallbackMessage As MOUSEMESSAGES = mmMouseOver, _
                            Optional ByVal Delay As Long = &H0)
    TrayIcon tmAdd, hWnd, uID, Icon, TrayStyle, Message, Title, _
        MessageIcon, CallbackMessage, Delay
        
    Key = hWnd
End Sub

Public Sub Update(hWnd As Long, ByVal uID As Long, _
                            Optional ByVal Icon As stdole.IPictureDisp, _
                            Optional ByVal TrayStyle As TRAY_STYLE = tsSimple, _
                            Optional ByVal Message As String, Optional ByVal Title As String, _
                            Optional ByVal MessageIcon As TRAY_MESSAGE_ICON = tmiNone, _
                            Optional ByVal CallbackMessage As MOUSEMESSAGES = mmMouseOver, _
                            Optional ByVal Delay As Long = &H0)
    TrayIcon tmModify, hWnd, uID, Icon, TrayStyle, Message, Title, _
        MessageIcon, CallbackMessage, Delay
    
    Key = hWnd
End Sub

Public Sub Remove(ByVal uID As Long)
    TrayIcon tmDelete, Key, uID
End Sub

Private Sub TrayIcon(ByVal TrayMessage As TRAY_MESSAGES, _
                            hWnd As Long, ByVal uID As Long, _
                            Optional ByVal Icon As stdole.IPictureDisp, _
                            Optional ByVal TrayStyle As TRAY_STYLE = tsSimple, _
                            Optional ByVal Message As String, Optional ByVal Title As String, _
                            Optional ByVal MessageIcon As TRAY_MESSAGE_ICON = tmiNone, _
                            Optional ByVal CallbackMessage As MOUSEMESSAGES = mmMouseOver, _
                            Optional ByVal Delay As Long = &H0)
    Dim nid As NOTIFYICONDATA
    Dim Result As Long
    
    With nid
        .cbSize = Len(nid)
        .hWnd = hWnd
        .uID = uID
        .uFlags = (tiIcon Or tiMessage)
        If Not Icon Is Nothing Then .hIcon = Icon
        .uCallbackMessage = CallbackMessage
        .dwState = 0
        .dwStateMask = 0
        
        Select Case TrayStyle
            Case tsSimple
                .uFlags = (.uFlags Or tiTip)
                .szTip = Message & vbNullChar
            Case tsBalloon
                .uFlags = (.uFlags Or tiTip Or tiInfo)
                .szInfo = Message & vbNullChar
                .szInfoTitle = Title & vbNullChar
                .uTimeoutOrVersion = (Delay)
                .dwInfoFlags = MessageIcon
        End Select
    End With
    
    Result = Shell_NotifyIcon(TrayMessage, nid)
    If TrayMessage = tmModify And Result = 0 Then
        Result = Shell_NotifyIcon(tmAdd, nid)
    End If
End Sub

Public Property Get Key() As Variant
    Key = mvarKey
End Property

Public Property Let Key(vData As Variant)
    mvarKey = vData
End Property
