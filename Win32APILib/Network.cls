VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Network"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'********************************************************************************************************
'
' Windows networking, Map and Disconnect network drives, Get the network username
' Or display the MapNetworkDrive dialog to the user
'
' Author: Neil Stevens
' Revision: 1.0
' Released: 01/29/2003
' Revised:
'       Class created
'
'********************************************************************************************************
Option Explicit

Const RESOURCE_CONNECTED As Long = &H1&
Const RESOURCE_GLOBALNET As Long = &H2&
Const RESOURCE_REMEMBERED As Long = &H3&

Public Enum ResourceTypeConstants
      rtRESOURCETYPE_ANY = &H0&
      rtRESOURCETYPE_DISK = &H1&
      rtRESOURCETYPE_PRINT = &H2&
      rtRESOURCETYPE_UNKNOWN = &HFFFF&
End Enum

Const RESOURCEDISPLAYTYPE_DOMAIN As Long = &H1&
Const RESOURCEDISPLAYTYPE_FILE As Long = &H4&
Const RESOURCEDISPLAYTYPE_GENERIC As Long = &H0&
Const RESOURCEDISPLAYTYPE_GROUP As Long = &H5&
Const RESOURCEDISPLAYTYPE_SERVER As Long = &H2&
Const RESOURCEDISPLAYTYPE_SHARE As Long = &H3&

Const RESOURCEUSAGE_ALL As Long = &H0&
Const RESOURCEUSAGE_CONNECTABLE As Long = &H1&
Const RESOURCEUSAGE_CONTAINER As Long = &H2&
Const RESOURCEUSAGE_RESERVED As Long = &H80000000

Const WN_ACCESS_DENIED = ERROR_ACCESS_DENIED
Const WN_ALREADY_CONNECTED = ERROR_ALREADY_ASSIGNED
Const WN_BAD_HANDLE = ERROR_INVALID_HANDLE
Const WN_BAD_LOCALNAME = ERROR_BAD_DEVICE
Const WN_BAD_NETNAME = ERROR_BAD_NET_NAME
Const WN_BAD_PASSWORD = ERROR_INVALID_PASSWORD
Const WN_BAD_POINTER = ERROR_INVALID_ADDRESS
Const WN_BAD_PROFILE = ERROR_BAD_PROFILE
Const WN_BAD_PROVIDER = ERROR_BAD_PROVIDER
Const WN_BAD_USER = ERROR_BAD_USERNAME
Const WN_BAD_VALUE = ERROR_INVALID_PARAMETER
Const WN_BAD_DEV_TYPE = ERROR_BAD_DEV_TYPE
Const WN_CANNOT_OPEN_PROFILE = ERROR_CANNOT_OPEN_PROFILE
Const WN_CONNECTION_CLOSED = ERROR_CONNECTION_UNAVAIL
Const WN_DEVICE_ERROR = ERROR_GEN_FAILURE
Const WN_DEVICE_IN_USE = ERROR_DEVICE_IN_USE
Const WN_EXTENDED_ERROR = ERROR_EXTENDED_ERROR
Const WN_FUNCTION_BUSY = ERROR_BUSY
Const WN_MORE_DATA = ERROR_MORE_DATA
Const WN_NET_ERROR = ERROR_UNEXP_NET_ERR
Const WN_NO_ERROR = NO_ERROR
Const WN_NO_MORE_ENTRIES = ERROR_NO_MORE_ITEMS
Const WN_NO_NET_OR_BAD_PATH = ERROR_NO_NET_OR_BAD_PATH
Const WN_NO_NETWORK = ERROR_NO_NETWORK
Const WN_NOT_CONNECTED = ERROR_NOT_CONNECTED
Const WN_NOT_CONTAINER = ERROR_NOT_CONTAINER
Const WN_NOT_SUPPORTED = ERROR_NOT_SUPPORTED
Const WN_OPEN_FILES = ERROR_OPEN_FILES
Const WN_OUT_OF_MEMORY = ERROR_NOT_ENOUGH_MEMORY
Const WN_SUCCESS = NO_ERROR
Const WN_WINDOWS_ERROR = ERROR_UNEXP_NET_ERR

Public Enum ConnectionOptionConstants
      coCONNECT_UPDATE_PROFILE = &H1
      coCONNECT_UPDATE_RECENT = &H2
      coCONNECT_TEMPORARY = &H4
      coCONNECT_INTERACTIVE = &H8
      coCONNECT_PROMPT = &H10
      coCONNECT_NEED_DRIVE = &H20
      coCONNECT_REFCOUNT = &H40
      coCONNECT_REDIRECT = &H80
      coCONNECT_LOCALDRIVE = &H100
      coCONNECT_CURRENT_MEDIA = &H200
      coCONNECT_DEFERRED = &H400
End Enum

Private Type NETRESOURCE
        dwScope As Long
        dwType As Long
        dwDisplayType As Long
        dwUsage As Long
        lpLocalName As String
        lpRemoteName As String
        lpComment As String
        lpProvider As String
End Type

Private Declare Function WNetAddConnection2 Lib "mpr.dll" Alias "WNetAddConnection2A" _
      (lpNetResource As NETRESOURCE, ByVal lpPassword As String, ByVal lpUsername As String, _
      ByVal dwFlags As Long) As Long
Private Declare Function WNetCancelConnection2 Lib "mpr.dll" Alias "WNetCancelConnection2A" _
      (ByVal lpName As String, ByVal dwFlags As Long, ByVal fForce As Long) As Long
Private Declare Function WNetGetUser Lib "mpr.dll" Alias "WNetGetUserA" _
      (ByVal lpName As String, ByVal lpUsername As String, lpnLength As Long) As Long
Private Declare Function WNetGetConnection Lib "mpr.dll" Alias "WNetGetConnectionA" _
      (ByVal lpszLocalName As String, ByVal lpszRemoteName As String, _
      cbRemoteName As Long) As Long
Private Declare Function WNetConnectionDialog Lib "mpr.dll" _
      (ByVal hwnd As Long, ByVal dwType As Long) As Long
Private Declare Function WNetDisconnectDialog Lib "mpr.dll" _
      (ByVal hwnd As Long, ByVal dwType As Long) As Long

Private g As New Miscellaneous

'********************************************************************************
'
' FUNCTION: MapNetworkDrive()
'
' RETURN: Long
'
' PARAMS: LocalName As String, RemoteName As String,
'                 Username As String, Password As String,
'                 Flags As ConnectionOptionConstants
'
' USE: Maps a network share to a local path resource, the local resource
'          must be available otherwise you will get a WN_ALREADY_CONNECTED
'          error, if Username and Password as Null then the user will be promted
'          to enter them
'
'********************************************************************************
Public Function MapNetworkDrive(ByVal LocalName As String, ByVal RemoteName As String, ByVal Username As String, ByVal Password As String, Optional ByVal Flags As ConnectionOptionConstants = coCONNECT_INTERACTIVE) As Long
      Dim lRet As Long
      Dim lpnr As NETRESOURCE
      
      With lpnr
            .dwScope = RESOURCE_CONNECTED Or RESOURCE_REMEMBERED
            .dwType = rtRESOURCETYPE_DISK
            .dwDisplayType = RESOURCEDISPLAYTYPE_GENERIC
            .dwUsage = RESOURCEUSAGE_ALL
            .lpLocalName = LocalName
            .lpRemoteName = RemoteName
      End With
      
      lRet = WNetAddConnection2(lpnr, Password, Username, Flags)
      MapNetworkDrive = lRet
End Function

'********************************************************************************
'
' FUNCTION: DisconnectNetworkDrive()
'
' RETURN: Long
'
' PARAMS: Name As String, Flags As ConnectionOptionConstants,
'                 Force As Long
'
' USE: Disconnects a local named resource
'
'********************************************************************************
Public Function DisconnectNetworkDrive(ByVal Name As String, ByVal Flags As ConnectionOptionConstants, ByVal Force As Long) As Long
      DisconnectNetworkDrive = WNetCancelConnection2(Name, Flags, Force)
End Function

'********************************************************************************
'
' FUNCTION: GetNetUser()
'
' RETURN: Long
'
' PARAMS: Name As String, Username As String, Length As Long
'
' USE: Returns the network username for the resource named in Name,
'          if Name is Null then this function returns the active username.
'
'********************************************************************************
Public Function GetNetUser(ByVal Name As String, Username As String, ByVal Length As Long) As Long
      Username = Space$(Length + 1)
      GetNetUser = WNetGetUser(Name, Username, Length)
      Username = g.TrimNull(Username)
End Function

'********************************************************************************
'
' FUNCTION: NetConnectDialog()
'
' RETURN: Long
'
' PARAMS: hwnd As Long, dwType As ResourceTypeConstants
'
' USE: Displays the MapNetworkDrive dialog to the user
'
'********************************************************************************
Public Function NetConnectDialog(ByVal hwnd As Long, ByVal dwType As ResourceTypeConstants) As Long
      NetConnectDialog = WNetConnectionDialog(hwnd, dwType)
End Function

'********************************************************************************
'
' FUNCTION: DisconnectConnectDialog()
'
' RETURN: Long
'
' PARAMS: hwnd As Long, dwType As ResourceTypeConstants
'
' USE: Displays the DisconnectNetworkDrive dialog to the user
'
'********************************************************************************
Public Function NetDisconnectDialog(ByVal hwnd As Long, ByVal dwType As ResourceTypeConstants) As Long
      NetDisconnectDialog = WNetDisconnectDialog(hwnd, dwType)
End Function

'********************************************************************************
'
' FUNCTION: GetNetConnection()
'
' RETURN: Long
'
' PARAMS: LocalName As String, RemoteName As String,
'                  cbRemoteName As Long
'
' USE: Returns the Remote name for the resource specified in
'          LocalName, remote name will be a network path to a server share
'          in the format \\server\share
'
'********************************************************************************
Public Function GetNetConnection(ByVal lpszLocalName As String, lpszRemoteName As String, cbRemoteName As Long) As Long
      lpszRemoteName = Space$(cbRemoteName + 1)
      GetNetConnection = WNetGetConnection(lpszLocalName, lpszRemoteName, cbRemoteName)
      lpszRemoteName = g.TrimNull(lpszRemoteName)
End Function
