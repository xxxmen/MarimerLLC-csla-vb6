VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Project"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Event Valid(IsValid As Boolean)

Private mudtProps As ProjectProps
Private mcolStack As Collection
Private mobjParent As Projects
Private mobjTasks As Tasks

Private WithEvents mobjValid As BrokenRules
Attribute mobjValid.VB_VarHelpID = -1

Public Sub BeginEdit()
  mobjTasks.BeginEdit
  ' save object state
  mcolStack.Add GetState
End Sub

Public Sub CancelEdit()
  If mcolStack.Count = 0 Then Err.Raise 445
  
  mobjTasks.CancelEdit
  mudtProps.IsDeleted = False
  ' restore object state
  With mcolStack
    SetState .Item(.Count)
    .Remove .Count
  End With
End Sub

Public Sub ApplyEdit()
  If mcolStack.Count = 0 Then Err.Raise 445

  mobjTasks.ApplyEdit
  If Not mobjParent Is Nothing Then
    mobjParent.AddProject Me
    Set mobjParent = Nothing
  End If
  mcolStack.Remove mcolStack.Count
End Sub

Friend Sub Initialize(Parent As Projects)
  If mudtProps.IsNew Then Set mobjParent = Parent
End Sub

Private Sub Class_Initialize()
  Set mcolStack = New Collection
  Set mobjTasks = New Tasks
  Set mobjValid = New BrokenRules
  
  mudtProps.IsNew = True
  ' if we know any rules are broken on startup
  ' then add code here to initialize the list
  ' of broken rules
  '
  ' mobjValid.RuleBroken "RuleName", True
End Sub

Private Sub Class_Terminate()
  If mobjParent Is Nothing Then
    If mcolStack.Count > 0 Then _
      Err.Raise vbObjectError + 1001, , "State stack is not empty"
  End If
    
  Set mcolStack = Nothing
End Sub

Public Property Get IsValid() As Boolean
  IsValid = (mobjValid.Count = 0)
End Property

Private Sub mobjValid_BrokenRule()
  RaiseEvent Valid(False)
End Sub

Private Sub mobjValid_NoBrokenRules()
  RaiseEvent Valid(True)
End Sub

Public Sub Delete()
  If mcolStack.Count = 0 Then Err.Raise 445
  
  mudtProps.IsDeleted = True
  mudtProps.IsDirty = True
End Sub

Public Property Get IsDeleted() As Boolean
  IsDeleted = mudtProps.IsDeleted
End Property

Public Property Get IsNew() As Boolean
  IsNew = mudtProps.IsNew
End Property

Public Property Get IsDirty() As Boolean
  IsDirty = mudtProps.IsDirty Or mobjTasks.IsDirty
End Property

Friend Function GetState() As String
  Dim udtData As ProjectData
  
  LSet udtData = mudtProps
  GetState = udtData.Buffer
End Function

Friend Sub SetState(Buffer As String)
  Dim udtData As ProjectData
  
  udtData.Buffer = Buffer
  LSet mudtProps = udtData
End Sub

Public Property Get ID() As Long
  ID = mudtProps.ID
End Property

Public Property Get Name() As String
  Name = Trim$(mudtProps.Name)
End Property

Public Property Let Name(Value As String)
  If mcolStack.Count = 0 Then Err.Raise 383
  
  mudtProps.Name = Value
  mudtProps.IsDirty = True
End Property

Public Property Get Tasks() As Tasks
  Set Tasks = mobjTasks
End Property


