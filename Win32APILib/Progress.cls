VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Progress"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private prjBar As Object
Private prjLbl As Object

Private m_lMinValue As Long
Private m_lMaxValue As Long
Private m_lStep As Long

Private m_lPrevPosition As Long
Private m_lPrevPercent As Long

Public Property Set ProgressBar(ByVal vData As Object)
    Set prjBar = vData
End Property

Public Property Get ProgressBar() As Object
    Set ProgressBar = prjBar
End Property

Public Property Set ProgressLabel(ByVal vData As Object)
    Set prjLbl = vData
End Property

Public Property Get ProgressLabel() As Object
    Set ProgressLabel = prjLbl
End Property

Public Sub SetRange(ByVal Min As Long, ByVal Max As Long, Optional ByVal step As Long = 1)
    m_lMinValue = Min
    m_lMaxValue = Max
    m_lStep = step
    
    prjBar.Min = Min
    prjBar.Max = Max
End Sub

Public Function StepIt() As Long
    StepIt = SetPos(m_lPrevPosition + m_lStep)
End Function

Private Function SetPos(lPos As Long)
    Dim strTitle As String
    Dim lPercentage As Long
    
    m_lPrevPosition = lPos
    
    If m_lMaxValue > m_lMinValue Then
        lPercentage = (lPos * 100) / (m_lMaxValue - m_lMinValue)
    Else
        lPercentage = 0
    End If
    
    If m_lPrevPercent <> lPercentage Then
        m_lPrevPercent = lPercentage
        strTitle = lPercentage & "%"
        If Not prjLbl Is Nothing Then
            prjLbl.Caption = strTitle
        End If
    End If
    
    prjBar.Value = lPos
End Function
