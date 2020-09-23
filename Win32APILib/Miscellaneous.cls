VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Miscellaneous"
Attribute VB_GlobalNameSpace = True
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Const HWND_TOPMOST = -1
Const HWND_NOTTOPMOST = -2
Const SWP_NOMOVE = &H2
Const SWP_NOSIZE = &H1
Const SWP_NOACTIVATE = &H10
Const SWP_SHOWWINDOW = &H40
Const TOPMOST_FLAGS = SWP_NOMOVE Or SWP_NOSIZE

Public Enum BrowseForFolderFlags
      BIF_RETURNONLYFSDIRS = &H1
      BIF_DONTGOBELOWDOMAIN = &H2
      BIF_STATUSTEXT = &H4
      BIF_BROWSEFORCOMPUTER = &H1000
      BIF_BROWSEFORPRINTER = &H2000
      BIF_BROWSEINCLUDEFILES = &H4000
      BIF_EDITBOX = &H10
      BIF_RETURNFSANCESTERS = &H8
End Enum

Public Type BROWSEINFO
      hwndOwnder As Long
      pIDLRoot As Long
      pszDisplayName As Long
      lpszTitle As Long
      ulFlags As Long
      lpfnCallback As Long
      lParam As Long
      iImage As Long
End Type

Public Type RECT
        Left As Long
        Top As Long
        Right As Long
        Bottom As Long
End Type

Public Type POINTAPI
        x As Long
        y As Long
End Type

Public Type WINDOWPLACEMENT
        Length As Long
        Flags As Long
        showCmd As Long
        ptMinPosition As POINTAPI
        ptMaxPosition As POINTAPI
        rcNormalPosition As RECT
End Type

Private Declare Function GetWindowPlacement Lib "user32" (ByVal hwnd As Long, _
      lpwndpl As WINDOWPLACEMENT) As Long
Private Declare Function SetWindowPlacement Lib "user32" (ByVal hwnd As Long, _
      lpwndpl As WINDOWPLACEMENT) As Long
Private Declare Function SHBrowseForFolder Lib "shell32" (lpbi As BROWSEINFO) As Long
Private Declare Function SHGetPathFromIDList Lib "shell32" (ByVal pidList As Long, _
      ByVal lpBuffer As String) As Long
Private Declare Function lstrcat Lib "kernel32" Alias "lstrcatA" (ByVal lpString1 As String, _
      ByVal lpString2 As String) As Long
Private Declare Function SetWindowPos Lib "user32" (ByVal hwnd As Long, _
      ByVal hWndInsertAfter As Long, ByVal x As Long, ByVal y As Long, ByVal cx As Long, _
      ByVal cy As Long, ByVal wFlags As Long) As Long
Private Declare Sub RtlZeroMemory Lib "kernel32" (dest As Any, ByVal numBytes As Long)

'********************************************************************************
'
' FUNCTION: TrimNull()
'
' RETURN: String
'
' PARAMS: item As String
'
' USE: Trims item to first null char
'
'********************************************************************************
Public Function TrimNull(item As String) As String
    Dim pos As Integer
    pos = InStr(item, Chr$(0))
    If pos Then item = Left$(item, pos - 1)
    TrimNull = item
End Function

'********************************************************************************
'
' FUNCTION: ZeroMemory()
'
' RETURN: None
'
' PARAMS: pDst, ByteLen As Long
'
' USE: resets the memory of the associated pointer pDst to Zero
'
' NOTES: Fixed bug in ZeroMemory function, function caused a fatal
'              exception error, this has now bee resolved
'
'********************************************************************************
Public Sub ZeroMemory(pDst, ByVal ByteLen As Long)
    RtlZeroMemory pDst, ByteLen
End Sub

'********************************************************************************
'
' FUNCTION: ErrorHandler()
'
' RETURN: None
'
' PARAMS: err As ErrObject, Optional Buttons As VbMsgBoStyle
'                 Optional Title, Optional Source, Optional LineNumber As Long
'
' USE: Custom routine, formats the error message then displays
'          it to the user in the style specified
'
'********************************************************************************
Public Sub ErrorHandler(ByVal err As ErrObject, Optional Buttons As VbMsgBoxStyle = vbCritical Or vbOKOnly, Optional Title, Optional ByVal source, Optional ByVal LineNumber As Long)
    Dim msg As String
    
    If IsMissing(source) Then source = err.source
    If IsMissing(LineNumber) Then LineNumber = 0
    If IsMissing(Title) Then Title = IIf(err.Number > 30000, "Application Error!", "Visual Basic Error!")
    
    msg = "The following " & IIf(err.Number > 30000, "Application ", "Visual Basic ")
    msg = msg & "error has occurred:" & nl(2)
    
    msg = msg & "Error Number:" & vbTab & err.Number & nl(1)
    msg = msg & "Description:" & vbTab & err.Description & nl(1)
    msg = msg & "Source:" & vbTab & vbTab & source & nl(1)
    msg = msg & "Line Number:" & vbTab & LineNumber & nl(1)
    
    msg = msg & nl(1)
    msg = msg & "Contact your system administrator or your local support desk, and quote the message above." & nl(1)
    
    MsgBox msg, Buttons, Title
End Sub

'********************************************************************************
'
' FUNCTION: nl()
'
' RETURN: String
'
' PARAMS: n As Long
'
' USE: Newline routine, returns vbcrlf * n
'
'********************************************************************************
Public Function nl(ByVal n As Long) As String
    Dim sCRLF As String
    Dim a As Long
    
    For a = 1 To n
        sCRLF = sCRLF & vbCrLf
    Next a
    nl = sCRLF
End Function

'********************************************************************************
'
' FUNCTION: GetWndPlacement()
'
' RETURN: Long
'
' PARAMS: hWnd As Long, lpwndpl As WINDOWPLACEMENT
'
' USE: Wrapper routine, encapsulates the API function call to
'          GetWindowPlacement
'
'********************************************************************************
Public Function GetWndPlacement(ByVal hwnd As Long, lpwndpl As WINDOWPLACEMENT) As Long
    GetWndPlacement = GetWindowPlacement(hwnd, lpwndpl)
End Function

'********************************************************************************
'
' FUNCTION: SetWndPlacement()
'
' RETURN: Long
'
' PARAMS: hWnd As Long, lpwndpl As WINDOWPLACEMENT
'
' USE: Wrapper routine, encapsulates the API function call to
'          SetWindowPlacement
'
'********************************************************************************
Public Function SetWndPlacement(ByVal hwnd As Long, lpwndpl As WINDOWPLACEMENT) As Long
    SetWndPlacement = SetWindowPlacement(hwnd, lpwndpl)
End Function

'********************************************************************************
'
' FUNCTION: BrowseForFolder()
'
' RETURN: String
'
' PARAMS: hWnd As Long, Optional Title As String,
'                 Optional flags As BrowseForFolderFlags
'
' USE: Displays the BrowseForFolder dialog and returns the folder
'          selected by the user, return blank "" string if no folder is selected
'
'********************************************************************************
Public Function BrowseForFolder(ByVal hwnd As Long, Optional ByVal Title As String, Optional ByVal Flags As BrowseForFolderFlags) As String
      Dim iNull As Integer
      Dim IDList As Long
      Dim Result As Long
      Dim Path As String
      Dim bi As BROWSEINFO
      
      If Flags = 0 Then Flags = BIF_RETURNONLYFSDIRS
      
      With bi
            .hwndOwnder = hwnd
            .lpszTitle = lstrcat(Title, "")
            .ulFlags = Flags
      End With
      
      IDList = SHBrowseForFolder(bi)
      
      If IDList Then
            Path = String$(300, 0)
            Result = SHGetPathFromIDList(IDList, Path)
            iNull = InStr(Path, vbNullChar)
            If iNull Then Path = Left$(Path, iNull - 1)
      End If
      
      BrowseForFolder = Path
End Function

'********************************************************************************
'
' FUNCTION: Center()
'
' RETURN: Long
'
' PARAMS: frm As Object, Optional Parent As Parent
'
' USE: Centers frm on the screen, if Parent is nothing then centers
'          frm to the desktop, else frm is centered to Parent
'
'********************************************************************************
Public Function Center(frm As Object, Optional Parent As Object) As Long
      If Parent Is Nothing Then
            frm.Top = (Screen.Height / 2) - frm.Height / 2
            frm.Left = (Screen.Width / 2) - frm.Width / 2
      Else
            frm.Top = (Parent.Top + (Parent.Height / 2)) - frm.Height / 2
            frm.Left = (Parent.Left + (Parent.Width / 2)) - frm.Width / 2
      End If
End Function

'********************************************************************************
'
' FUNCTION: Mod7()
'
' RETURN: Long
'
' PARAMS: value, Optional Check As Long
'
' USE: Mod7 calculator function, calculates the modular check digit
'          of any given number, this function will auto strip value to a numeric
'          value and then calculate the check digit. Returns the check
'          digit.
'
'********************************************************************************
Public Function Mod7(ByVal Value, Optional ByVal Check As Long = 7) As Long
      Dim RetVal
      Dim saryResult
      Dim i As Long
      
      For i = 1 To Len(Value)
            If IsNumeric(Mid(Value, 1, i)) Then
                  RetVal = Mid(Value, 1, i)
            End If
      Next i
      
      RetVal = Value / Check
      saryResult = Split(RetVal, ".")
      RetVal = "." & saryResult(1)
      
      If RetVal = "" Then RetVal = 0
      RetVal = RetVal * Check
      
      Mod7 = RetVal
End Function

'********************************************************************************
'
' FUNCTION: TopMost()
'
' RETURN: None
'
' PARAMS: Handle As Long
'
' USE: Sets the window pointed to by Handle to the topmost form,
'          like the task manager window
'
'********************************************************************************
Public Sub TopMost(handle As Long)
      SetWindowPos handle, HWND_TOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS
End Sub

'********************************************************************************
'
' FUNCTION: MakeNormal()
'
' RETURN: None
'
' PARAMS: Handle As Long
'
' USE: Resets a TopMost window to normal
'
'********************************************************************************
Public Sub MakeNormal(handle As Long)
      SetWindowPos handle, HWND_NOTTOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS
End Sub
