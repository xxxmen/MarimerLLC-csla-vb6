VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Videos"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mcolDisplay As Collection

Private Sub Class_Initialize()

  Set mcolDisplay = New Collection

End Sub

Public Sub Load(Optional Title As String, Optional Studio As String)

  ' load data from database

End Sub

Public Function Item(ByVal Index As Variant) As VideoDisplay
Attribute Item.VB_UserMemId = 0

  ' find or build a VideoDisplay object
  ' then return it as a result

End Function

Public Function Count() As Long

  Count = mcolDisplay.Count

End Function

' NewEnum must return the IUnknown interface of a
' collection's enumerator.
Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"

  Set NewEnum = mcolDisplay.[_NewEnum]

End Function


