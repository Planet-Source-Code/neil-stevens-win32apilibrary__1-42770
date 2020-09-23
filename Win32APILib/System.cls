VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "System"
Attribute VB_GlobalNameSpace = True
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Enum SpecialFolderConstants
      sfProgramFilesPath
      sfCommonFilesPath
      sfTemporaryFolderPath
      sfMediaPath
      sfCommonDesktopPath
      sfCommonDocumentsPath
      sfCommonProgramsPath
      sfCommonStartMenuPath
      sfCommonStartupPath
      sfUserDesktopPath
      sfUserDocumentsPath
End Enum

Private Const ROOTPATH_CURRENTUSER = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
Private Const ROOTPATH_LOCALMACHINE = "SOFTWARE\Microsoft\Windows\CurrentVersion"
Private Const ROOTPATH_LOCALMACHINE_SHELL = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"

Private Declare Function GetComputerNameA Lib "kernel32" (ByVal lpBuffer As String, _
    nSize As Long) As Long
Private Declare Function GetWindowsDirectoryA Lib "kernel32" (ByVal lpBuffer As String, _
      ByVal nSize As Long) As Long
Private Declare Function GetSystemDirectoryA Lib "kernel32" (ByVal lpBuffer As String, _
      ByVal nSize As Long) As Long

'********************************************************************************
'
' FUNCTION: GetComputerName()
'
' RETURN: String
'
' PARAMS: None
'
' USE: Returns the current computer name, this is tha name
'          of the computer which the calling application is running on
'
'********************************************************************************
Public Function GetComputerName() As String
    Dim CName As String
    CName = Space(512)
    GetComputerNameA CName, 512
    GetComputerName = Trim(CName)
End Function

'********************************************************************************
'
' FUNCTION: GetWindowsDirectory()
'
' RETURN: Long
'
' PARAMS: lpBuffer As String, nSize As Long
'
' USE: Returns the Windows directory path.
'
'********************************************************************************
Public Function GetWindowsDirectory(lpBuffer As String, ByVal nSize As Long) As Long
    GetWindowsDirectory = GetWindowsDirectoryA(lpBuffer, nSize)
End Function

'********************************************************************************
'
' FUNCTION: GetSystemDirectory()
'
' RETURN: Long
'
' PARAMS: lpBuffer As String, nSize As Long
'
' USE: Return the windows system directory
'          System on Win95/98
'          System32 on WinNT/2K
'
'********************************************************************************
Public Function GetSystemDirectory(lpBuffer As String, ByVal nSize As Long) As Long
      GetSystemDirectory = GetSystemDirectoryA(lpBuffer, nSize)
End Function

'********************************************************************************
'
' FUNCTION: GetSpecialFolderLocation()
'
' RETURN: Long
'
' PARAMS: lpBuffer As String, nSize As Long
'
' USE: Sets lpBuffer to the path to the folder referenced in Folder
'
'********************************************************************************
Public Function GetSpecialFolderLocation(ByVal Folder As SpecialFolderConstants, lpBuffer As String, ByVal nSize As Long) As Long
      Dim reg As New Registry
      Dim strFolder As String, strRootPath As String
      Dim fsoObject As New Scripting.FileSystemObject
      
      Select Case Folder
            Case sfProgramFilesPath
                  strRootPath = ROOTPATH_LOCALMACHINE
                  strFolder = "ProgramFileDir"
            Case sfCommonFilesPath
                  strRootPath = ROOTPATH_LOCALMACHINE
                  strFolder = "CommonFileDir"
            Case sfTemporaryFolderPath
                  lpBuffer = fsoObject.GetSpecialFolder(2).Path
                  GetSpecialFolderLocation = Len(lpBuffer)
                  lpBuffer = lpBuffer & String(nSize - Len(lpBuffer), vbNullChar)
                  Exit Function
            Case sfMediaPath
                  strRootPath = ROOTPATH_LOCALMACHINE
                  strFolder = "MediaPath"
            Case sfCommonDesktopPath
                  strRootPath = ROOTPATH_LOCALMACHINE_SHELL
                  strFolder = "Common Desktop"
            Case sfCommonDocumentsPath
                  strRootPath = ROOTPATH_LOCALMACHINE_SHELL
                  strFolder = "Common Documents"
            Case sfCommonProgramsPath
                  strRootPath = ROOTPATH_LOCALMACHINE_SHELL
                  strFolder = "Common Programs"
            Case sfCommonStartMenuPath
                  strRootPath = ROOTPATH_LOCALMACHINE_SHELL
                  strFolder = "Common Start Menu"
            Case sfCommonStartupPath
                  strRootPath = ROOTPATH_LOCALMACHINE_SHELL
                  strFolder = "Common Startup"
            Case sfUserDesktopPath
                  strRootPath = ROOTPATH_CURRENTUSER
                  strFolder = "Desktop"
            Case sfUserDocumentsPath
                  strRootPath = ROOTPATH_CURRENTUSER
                  strFolder = "Personal"
      End Select
      
      reg.hKey = IIf(Folder = sfUserDesktopPath Or Folder = sfUserDocumentsPath, HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE)
      reg.KeyRoot = strRootPath
      
      lpBuffer = reg.GetRegistryValue(strFolder)
      GetSpecialFolderLocation = Len(lpBuffer)
      lpBuffer = lpBuffer & String$(nSize - Len(lpBuffer), vbNullChar)
End Function
