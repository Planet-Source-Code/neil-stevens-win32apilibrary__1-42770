VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "INetConnect"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'********************************************************************************************************
'
' Internet Connection state, collection of function to determine if a computer is connected
' to the internet and by what method the computer is connected
'
' Author: Neil Stevens
' Revision: 1.0
' Released: 01/28/2003
' Revised:
'       Class created
'
'********************************************************************************************************
Option Explicit

Enum NetConnectedConstants
      ncLan
      ncModem
      ncProxy
End Enum

Const INTERNET_CONNECTION_MODEM As Long = &H1
Const INTERNET_CONNECTION_LAN As Long = &H2
Const INTERNET_CONNECTION_PROXY As Long = &H4
Const INTERNET_CONNECTION_MODEM_BUSY As Long = &H8
Const INTERNET_RAS_INSTALLED As Long = &H10
Const INTERNET_CONNECTION_OFFLINE As Long = &H20
Const INTERNET_CONNECTION_CONFIGURED As Long = &H40

Private Declare Function InternetGetConnectedState Lib "wininet.dll" (ByRef lpdwFlags As Long, _
      ByVal dwReserved As Long) As Long

Public Function IsConnected(ByVal Connection As NetConnectedConstants) As Boolean
      Dim dwFlags As Long
      
      InternetGetConnectedState dwFlags, 0&
      
      Select Case Connection
            Case ncLan
                  IsConnected = dwFlags And INTERNET_CONNECTION_LAN
            Case ncModem
                  IsConnected = dwFlags And INTERNET_CONNECTION_MODEM
            Case ncProxy
                  IsConnected = dwFlags And INTERNET_CONNECTION_PROXY
      End Select
End Function

Private Function IsOnline() As Boolean
      IsOnline = InternetGetConnectedState(0&, 0&)
End Function

Private Function IsRASInstalled() As Boolean
      Dim dwFlags As Long
      
      InternetGetConnectedState dwFlags, 0&
      
      IsRASInstalled = dwFlags And INTERNET_RAS_INSTALLED
End Function

Public Function GetConnectedString() As String
      Dim dwFlags As Long
      Dim msg As String
      Dim g As New Miscellaneous
      
      If InternetGetConnectedState(dwFlags, 0&) Then
            If dwFlags And INTERNET_CONNECTION_CONFIGURED Then
                  msg = msg & "You have a network connection configured." & g.nl(1)
            End If
            
            If dwFlags And INTERNET_CONNECTION_LAN Then
                  msg = msg & "The local system connects to the internet via the Local Area Network"
            End If
            
            If dwFlags And INTERNET_CONNECTION_PROXY Then
                  msg = msg & ", and uses a proxy server. "
            Else
                  msg = msg & "."
            End If
            
            If dwFlags And INTERNET_CONNECTION_MODEM Then
                  msg = msg & "The local system uses a modem to connect to the internet. "
            End If
            
            If dwFlags And INTERNET_CONNECTION_OFFLINE Then
                  msg = msg & "The connection is currently offline. "
            End If
            
            If dwFlags And INTERNET_CONNECTION_MODEM_BUSY Then
                  msg = msg & "The local system's modem is busy with a non-internet connection. "
            End If
            
            If dwFlags And INTERNET_RAS_INSTALLED Then
                  msg = msg & "Remote Access Services are installed on this system."
            End If
      Else
            msg = "Not connected to the internet now."
      End If
      
      GetConnectedString = msg
End Function
