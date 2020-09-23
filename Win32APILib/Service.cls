VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Service"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private Const SERVICE_WIN32_OWN_PROCESS = &H10&
Private Const SERVICE_WIN32_SHARE_PROCESS = &H20&
Private Const SERVICE_WIN32 = SERVICE_WIN32_OWN_PROCESS + SERVICE_WIN32_SHARE_PROCESS

Private Const SC_MANAGER_CONNECT = &H1
Private Const SC_MANAGER_CREATE_SERVICE = &H2
Private Const SC_MANAGER_ENUMERATE_SERVICE = &H4
Private Const SC_MANAGER_LOCK = &H8
Private Const SC_MANAGER_QUERY_LOCK_STATUS = &H10
Private Const SC_MANAGER_MODIFY_BOOT_CONFIG = &H20

Private Const SERVICE_QUERY_CONFIG = &H1
Private Const SERVICE_CHANGE_CONFIG = &H2
Private Const SERVICE_QUERY_STATUS = &H4
Private Const SERVICE_ENUMERATE_DEPENDENTS = &H8
Private Const SERVICE_START = &H10
Private Const SERVICE_STOP = &H20
Private Const SERVICE_PAUSE_CONTINUE = &H40
Private Const SERVICE_INTERROGATE = &H80
Private Const SERVICE_USER_DEFINED_CONTROL = &H100
Private Const STANDARD_RIGHTS_REQUIRED = &HF0000
Private Const SERVICE_ALL_ACCESS = (STANDARD_RIGHTS_REQUIRED Or SERVICE_QUERY_CONFIG Or SERVICE_CHANGE_CONFIG Or SERVICE_QUERY_STATUS Or SERVICE_ENUMERATE_DEPENDENTS Or SERVICE_START Or SERVICE_STOP Or SERVICE_PAUSE_CONTINUE Or SERVICE_INTERROGATE Or SERVICE_USER_DEFINED_CONTROL)

Private Const SERVICE_CONTROL_CONTINUE = &H3
Private Const SERVICE_CONTROL_INTERROGATE = &H4
Private Const SERVICE_CONTROL_PAUSE = &H2
Private Const SERVICE_CONTROL_SHUTDOWN = &H5
Private Const SERVICE_CONTROL_STOP = &H1

Private Const SERVICE_STOPPED = &H1
Private Const SERVICE_START_PENDING = &H2
Private Const SERVICE_STOP_PENDING = &H3
Private Const SERVICE_RUNNING = &H4
Private Const SERVICE_CONTINUE_PENDING = &H5
Private Const SERVICE_PAUSE_PENDING = &H6
Private Const SERVICE_PAUSED = &H7
Private Const SERVICE_ACCEPT_STOP = &H1
Private Const SERVICE_ACCEPT_PAUSE_CONTINUE = &H2
Private Const SERVICE_ACCEPT_SHUTDOWN = &H4

Private Const SERVICE_DISABLED As Long = &H4
Private Const SERVICE_DEMAND_START As Long = &H3
Private Const SERVICE_AUTO_START  As Long = &H2
Private Const SERVICE_SYSTEM_START As Long = &H1
Private Const SERVICE_BOOT_START As Long = &H0

Private Const GENERIC_READ = &H80000000

Private Const ERROR_INSUFFICIENT_BUFFER = 122
Private Const ERROR_INVALID_SERVICE_CONTROL = &H41C
Private Const ERROR_SERVICE_CANNOT_ACCEPT_CONTROL = &H425
Private Const ERROR_SERVICE_NOT_ACTIVE = &H426
Private Const ERROR_ACCESS_DENIED = &H5
Private Const ERROR_DEPENDENT_SERVICES_RUNNING = &H41B
Private Const ERROR_INVALID_HANDLE = &H6
Private Const ERROR_INVALID_PARAMETER = &H57
Private Const ERROR_SERVICE_REQUEST_TIMEOUT = &H41D
Private Const ERROR_SHUTDOWN_IN_PROGRESS = &H45B
Private Const ERROR_MORE_DATA = &HEA
Private Const ERROR_PATH_NOT_FOUND = &H3
Private Const ERROR_SERVICE_ALREADY_RUNNING = &H420
Private Const ERROR_SERVICE_LOGON_FAILED = &H42D
Private Const ERROR_CIRCULAR_DEPENDENCY = &H423
Private Const ERROR_DUP_NAME = &H34
Private Const ERROR_INVALID_SERVICE_ACCOUNT = &H421
Private Const ERROR_SERVICE_MARKED_FOR_DELETE = &H430

Private Const FORMAT_MESSAGE_FROM_SYSTEM = &H1000
Private Const FORMAT_MESSAGE_IGNORE_INSERTS = &H200
Private Const FORMAT_MESSAGE_MAX_WIDTH_MASK = &HFF
Private Const FORMAT_MESSAGE_ARGUMENT_ARRAY = &H2000

Private Const SERVICE_NO_CHANGE = &HFFFFFFFF

Private Const SERVICE_KERNEL_DRIVER = &H1
Private Const SERVICE_FILE_SYSTEM_DRIVER = &H2
Private Const SERVICE_INTERACTIVE_PROCESS = &H100

Private Const SERVICE_ERROR_IGNORE As Long = &H0
Private Const SERVICE_ERROR_NORMAL As Long = &H1
Private Const SERVICE_ERROR_SEVERE As Long = &H2
Private Const SERVICE_ERROR_CRITICAL As Long = &H3

Private Const MAX_PATH = 260

Public Enum SERVICE_STATES
    ssSTOPPED = &H1
    ssSTART_PENDING = &H2
    ssSTOP_PENDING = &H3
    ssRUNNING = &H4
    ssCONTINUE_PENDING = &H5
    ssPAUSE_PENDING = &H6
    ssPAUSED = &H7
End Enum

Public Enum eServiceType
    stServiceType_Disabled = 4
    stServiceType_Manual = 3
    stServiceType_Automatic = 2
    stServiceType_SystemStart = 1
    stServiceType_BootTime = 0
End Enum

Public Enum eServiceControl
   scServiceControl_Stop = &H1
   scServiceControl_Pause = &H2
   scServiceControl_Continue = &H3
   scServiceControl_Interrogate = &H4
   scServiceControl_Shutdown = &H5
End Enum

Public Enum eServiceState
   ssServiceState_Stopped = &H1
   ssServiceState_StartPending = &H2
   ssServiceState_StopPending = &H3
   ssServiceState_Running = &H4
   ssServiceState_ContinuePending = &H5
   ssServiceState_PausePending = &H6
   ssServiceState_Paused = &H7
End Enum

Private Type SERVICE_TABLE_ENTRY
   lpServiceName As String
   lpServiceProc As Long
   lpServiceNameNull As Long
   lpServiceProcNull As Long
End Type

Private Type SERVICE_STATUS
   dwServiceType As Long
   dwCurrentState As Long
   dwControlsAccepted As Long
   dwWin32ExitCode As Long
   dwServiceSpecificExitCode As Long
   dwCheckPoint As Long
   dwWaitHint As Long
End Type

Private Type QUERY_SERVICE_CONFIG
   dwServiceType As Long
   dwStartType As Long
   dwErrorControl As Long
   lpBinaryPathName As Long 'String
   lpLoadOrderGroup As Long ' String
   dwTagId As Long
   lpDependencies As Long 'String
   lpServiceStartName As Long 'String
   lpDisplayName As Long  'String
End Type

Private Type ENUM_SERVICE_STATUS
        lpServiceName As Long
        lpDisplayName As Long
        ServiceStatus As SERVICE_STATUS
End Type

Private Declare Function StartServiceCtrlDispatcher Lib "advapi32.dll" Alias "StartServiceCtrlDispatcherA" (lpServiceStartTable As SERVICE_TABLE_ENTRY) As Long
Private Declare Function RegisterServiceCtrlHandler Lib "advapi32.dll" Alias "RegisterServiceCtrlHandlerA" (ByVal lpServiceName As String, ByVal lpHandlerProc As Long) As Long
Private Declare Function SetServiceStatus Lib "advapi32.dll" (ByVal hServiceStatus As Long, lpServiceStatus As SERVICE_STATUS) As Long
Private Declare Function OpenSCManager Lib "advapi32.dll" Alias "OpenSCManagerA" (ByVal lpMachineName As String, ByVal lpDatabaseName As String, ByVal dwDesiredAccess As Long) As Long
Private Declare Function CreateService Lib "advapi32.dll" Alias "CreateServiceA" (ByVal hSCManager As Long, ByVal lpServiceName As String, ByVal lpDisplayName As String, ByVal dwDesiredAccess As Long, ByVal dwServiceType As Long, ByVal dwStartType As Long, ByVal dwErrorControl As Long, ByVal lpBinaryPathName As String, ByVal lpLoadOrderGroup As String, ByVal lpdwTagId As String, ByVal lpDependencies As String, ByVal lp As String, ByVal lpPassword As String) As Long
Private Declare Function DeleteService Lib "advapi32.dll" (ByVal hService As Long) As Long
Private Declare Function QueryServiceConfig Lib "advapi32.dll" Alias "QueryServiceConfigA" (ByVal hService As Long, lpServiceConfig As Byte, ByVal cbBufSize As Long, pcbBytesNeeded As Long) As Long
Private Declare Function QueryServiceStatus Lib "advapi32.dll" (ByVal hService As Long, lpServiceStatus As SERVICE_STATUS) As Long
Private Declare Function CloseServiceHandle Lib "advapi32.dll" (ByVal hSCObject As Long) As Long
Private Declare Function OpenService Lib "advapi32.dll" Alias "OpenServiceA" (ByVal hSCManager As Long, ByVal lpServiceName As String, ByVal dwDesiredAccess As Long) As Long
Private Declare Function EnumServicesStatus Lib "advapi32.dll" Alias "EnumServicesStatusA" (ByVal hSCManager As Long, ByVal dwServiceType As Long, ByVal dwServiceState As Long, lpBufAddress As ENUM_SERVICE_STATUS, ByVal cbBufSize As Long, pcbBytesNeeded As Long, lpServicesReturned As Long, lpResumeHandle As Long) As Long
Private Declare Function StartServiceLP Lib "advapi32.dll" Alias "StartServiceA" (ByVal hService As Long, ByVal dwNumServiceArgs As Long, ByVal lpServiceArgVectors As String) As Long
Private Declare Function ControlService Lib "advapi32.dll" (ByVal hService As Long, ByVal dwControl As Long, ByRef lpServiceStatus As SERVICE_STATUS) As Long
Private Declare Function ChangeServiceConfig Lib "advapi32.dll" Alias "ChangeServiceConfigA" (ByVal hService As Long, ByVal dwServiceType As Long, ByVal dwStartType As Long, ByVal dwErrorControl As Long, ByVal lpBinaryPathName As String, ByVal lpLoadOrderGroup As String, ByRef lpdwTagId As Long, ByVal lpDependencies As String, ByVal lpServiceStartName As String, ByVal lpPassword As String, ByVal lpDisplayName As String) As Long

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (hpvDest As Any, hpvSource As Any, ByVal cbCopy As Long)
Private Declare Function lstrcpy Lib "kernel32" Alias "lstrcpyA" (ByVal lpString1 As String, ByVal lpString2 As Long) As Long
Private Declare Function lstrlen Lib "kernel32" Alias "lstrlenA" (ByVal lpString As String) As Long

Private Declare Function GetLastError Lib "kernel32" () As Long
Private Declare Function FormatMessage Lib "kernel32" Alias "FormatMessageA" (ByVal dwFlags As Long, lpSource As Long, ByVal dwMessageId As Long, ByVal dwLanguageId As Long, ByVal lpBuffer As String, ByVal nSize As Long, Arguments As Any) As Long

Private hServiceStatus As Long
Private ServiceStatus As SERVICE_STATUS

Dim mvarServiceName As String

Public Function InstallService(ByVal ServiceName As String, ByVal ServiceType As eServiceType, ByVal ServicePath As String) As Boolean
    Dim hSCManager As Long
    Dim hService As Long
    Dim cmd As String
    Dim lServiceType As Long
    
    If ServiceName = "" Or ServicePath = "" Then InstallService = False: Exit Function
    
    Select Case ServiceType
        Case stServiceType_Automatic
            lServiceType = SERVICE_AUTO_START
        Case stServiceType_BootTime
            lServiceType = SERVICE_BOOT_START
        Case stServiceType_Disabled
            lServiceType = SERVICE_DISABLED
        Case stServiceType_Manual
            lServiceType = SERVICE_DEMAND_START
        Case stServiceType_SystemStart
            lServiceType = SERVICE_SYSTEM_START
    End Select
    
    hSCManager = OpenSCManager(vbNullString, vbNullString, SC_MANAGER_CREATE_SERVICE)
    hService = CreateService(hSCManager, ServiceName, ServiceName, SERVICE_ALL_ACCESS, SERVICE_WIN32_OWN_PROCESS, _
        lServiceType, SERVICE_ERROR_NORMAL, ServicePath, vbNullString, vbNullString, vbNullString, vbNullString, vbNullString)
    If hService = 0 Then
        InstallService = False
    Else
        InstallService = True
    End If
    
    CloseServiceHandle hService
    CloseServiceHandle hSCManager
End Function

Public Function UninstallService(ServiceName As String) As Boolean
    Dim hSCManager As Long
    Dim hService As Long
    Dim cmd As String
    Dim ret As Long
    
    hSCManager = OpenSCManager(vbNullString, vbNullString, SC_MANAGER_CREATE_SERVICE)
    hService = OpenService(hSCManager, ServiceName, SERVICE_ALL_ACCESS)
    ret = DeleteService(hService)
    If ret = 0 Then
        UninstallService = False
    Else
        UninstallService = True
    End If
    
    CloseServiceHandle hService
    CloseServiceHandle hSCManager
End Function

Public Function IsServiceInstalled(ByVal ServiceName As String) As Boolean
    Dim reg As New Registry
    reg.hKey = HKEY_LOCAL_MACHINE
    reg.KeyRoot = "SYSTEM\CurrentControlSet\Services"
    reg.SubKey = ServiceName
    If reg.GetRegistryValue("ImagePath", "Nothing") = "Nothing" Then
        IsServiceInstalled = False
    Else
        IsServiceInstalled = True
    End If
    Set reg = Nothing
End Function

Public Function ServiceState(ByVal ServiceName As String) As SERVICE_STATES
    Dim hSCManager As Long
    Dim hService As Long
    Dim pSS As SERVICE_STATUS
    Dim tConfig As QUERY_SERVICE_CONFIG
    Dim lRet As Long
    Dim lBytesNeeded As Long
    Dim sTemp As String
    Dim pFilename As Long
    Dim ServiceRunning As Long
    
    hSCManager = OpenSCManager(vbNullString, vbNullString, SC_MANAGER_CONNECT)
    If hSCManager = 0 Then
        ServiceState = False
    End If
    hService = OpenService(hSCManager, Trim(ServiceName), GENERIC_READ)
    If hService = 0 Then
        ServiceState = 0
        GoTo CLOSEHANDLES
    End If
    
    lRet = QueryServiceStatus(hService, pSS)
    If lRet = 0 Then
        ServiceState = 0
        GoTo CLOSEHANDLES
    End If
    
    Select Case pSS.dwCurrentState
        Case SERVICE_STOP
            ServiceRunning = ssServiceState_Stopped
        Case SERVICE_START
            ServiceRunning = ssServiceState_StartPending
        Case SERVICE_STOP_PENDING
            ServiceRunning = ssServiceState_StopPending
        Case SERVICE_RUNNING
            ServiceRunning = ssServiceState_Running
        Case SERVICE_CONTINUE_PENDING
            ServiceRunning = ssServiceState_ContinuePending
        Case SERVICE_PAUSE_PENDING
            ServiceRunning = ssServiceState_PausePending
        Case SERVICE_PAUSED
            ServiceRunning = ssServiceState_Paused
        Case SERVICE_ACCEPT_STOP
            ServiceRunning = ssServiceState_Stopped
        Case SERVICE_ACCEPT_PAUSE_CONTINUE
            ServiceRunning = ssServiceState_Paused
        Case SERVICE_ACCEPT_SHUTDOWN
            ServiceRunning = ssServiceState_StopPending
    End Select
    ServiceState = ServiceRunning
    
CLOSEHANDLES:
    CloseServiceHandle hService
    CloseServiceHandle hSCManager
End Function

Private Sub Handler(ByVal fdwControl As Long)
    Dim b As Boolean
    
    Select Case fdwControl
        Case SERVICE_CONTROL_PAUSE
            ServiceStatus.dwCurrentState = SERVICE_PAUSED
        Case SERVICE_CONTROL_CONTINUE
            ServiceStatus.dwCurrentState = SERVICE_RUNNING
        Case SERVICE_CONTROL_STOP
            ServiceStatus.dwWin32ExitCode = 0
            ServiceStatus.dwCurrentState = SERVICE_STOP_PENDING
            ServiceStatus.dwCheckPoint = 0
            ServiceStatus.dwWaitHint = 0
            b = SetServiceStatus(hServiceStatus, ServiceStatus)
            ServiceStatus.dwCurrentState = SERVICE_STOPPED
        Case SERVICE_CONTROL_INTERROGATE
        Case Else
    End Select
    b = SetServiceStatus(hServiceStatus, ServiceStatus)
End Sub

Public Function StartService(ByVal ServiceName As String) As Boolean
    Dim hSCManager As Long
    
    hSCManager = OpenSCManager(vbNullString, vbNullString, SC_MANAGER_CONNECT)
    If hSCManager = 0 Then
    Else
        Dim hService As Long
        
        hService = OpenService(hSCManager, ServiceName, SERVICE_START)
        If hService = 0 Then
        Else
            Dim lngReturn As Long
            lngReturn = StartServiceLP(hService, ByVal &H0, vbNullString)
            If lngReturn = 0 Then
            Else
                StartService = True
            End If
        End If
    End If
    
    If Not hService = 0 Then CloseServiceHandle hService
    If Not hSCManager = 0 Then CloseServiceHandle hSCManager
End Function

Public Function StopService(ByVal ServiceName As String) As Boolean
    Dim hSCManager As Long
    
    hSCManager = OpenSCManager(vbNullString, vbNullString, SC_MANAGER_CONNECT)
    If hSCManager = 0 Then
    Else
        Dim hService As Long
        
        hService = OpenService(hSCManager, ServiceName, SERVICE_STOP)
        If hService = 0 Then
        Else
            Dim lngReturn As Long, tempStatus As SERVICE_STATUS
            
            lngReturn = ControlService(hService, SERVICE_CONTROL_STOP, tempStatus)
            
            If lngReturn = 0 Then
            Else
                StopService = True
            End If
        End If
    End If
    
    If Not hService = 0 Then CloseServiceHandle hService
    If Not hSCManager = 0 Then CloseServiceHandle hSCManager
End Function

Public Function PauseService(ByVal ServiceName As String) As Boolean
    Dim hSCManager As Long
    
    hSCManager = OpenSCManager(vbNullString, vbNullString, SC_MANAGER_CONNECT)
    If hSCManager = 0 Then
    Else
        Dim hService As Long
        
        hService = OpenService(hSCManager, ServiceName, SERVICE_PAUSE_CONTINUE)
        If hService = 0 Then
        Else
            Dim lngReturn As Long, tempStatus As SERVICE_STATUS
            
            lngReturn = ControlService(hService, SERVICE_CONTROL_PAUSE, tempStatus)
            If lngReturn = 0 Then
            Else
                PauseService = True
            End If
        End If
    End If
    
    If Not hService = 0 Then CloseServiceHandle hService
    If Not hSCManager = 0 Then CloseServiceHandle hSCManager
End Function

Public Function ContinueService(ByVal ServiceName As String) As Boolean
    Dim hSCManager As Long
    
    hSCManager = OpenSCManager(vbNullString, vbNullString, SC_MANAGER_CONNECT)
    If hSCManager = 0 Then
    Else
        Dim hService As Long
        
        hService = OpenService(hSCManager, ServiceName, SERVICE_PAUSE_CONTINUE)
        If hService = 0 Then
        Else
            Dim lngReturn As Long, tempStatus As SERVICE_STATUS
            
            lngReturn = ControlService(hService, SERVICE_CONTROL_CONTINUE, tempStatus)
            If lngReturn = 0 Then
            Else
                ContinueService = True
            End If
        End If
    End If
    
    If hService = 0 Then CloseServiceHandle hService
    If hSCManager = 0 Then CloseServiceHandle hSCManager
End Function
