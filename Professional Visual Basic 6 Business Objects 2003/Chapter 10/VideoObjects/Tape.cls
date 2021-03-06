VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Tape"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Event Valid(IsValid As Boolean)

Private mudtProps As TapeProps
Private mudtSave As TapeProps
Private mudtChild As TapeProps
Private mobjParent As Tapes
Private mflgNew As Boolean
Private mflgDeleted As Boolean
Private mflgDirty As Boolean
Private mflgEditing As Boolean
Private mflgChild As Boolean
Private mflgChildEditing As Boolean
Private WithEvents mobjValid As BrokenRules
Attribute mobjValid.VB_VarHelpID = -1

Public Sub BeginEdit()

  If mflgChild Then If Not mflgChildEditing Then Err.Raise 445
  If mflgEditing Then Err.Raise 445
  
  ' save object state
  LSet mudtSave = mudtProps
  mflgEditing = True

End Sub

Public Sub CancelEdit()

  If mflgChild Then If Not mflgChildEditing Then Err.Raise 445
  If Not mflgEditing Then Err.Raise 445
  
  mflgEditing = False
  mflgDeleted = False
  mflgDirty = False
  ' restore object state
  LSet mudtProps = mudtSave
  
End Sub

Public Sub ApplyEdit()

  Dim objPersist As TapePersist
  
  If mflgChild Then If Not mflgChildEditing Then Err.Raise 445
  If Not mflgChild And mflgNew Then Err.Raise 445
  If Not mflgEditing Then Err.Raise 445

  Set objPersist = CreateObject("VideoServer.TapePersist", PERSIST_SERVER)
  
  If Not mflgChild Then
    If mflgDeleted And Not mflgNew Then
      ' code to delete the object's data goes here
      objPersist.DeleteObject mudtProps.TapeID
      mflgNew = True
      mflgDeleted = False

    ElseIf mflgDirty Or mflgNew Then
      If Not IsValid Then Err.Raise 445
      ' save object to database if appropriate
      SetState objPersist.Save(GetState)
      ' save object state
      LSet mudtSave = mudtProps
      mflgNew = False

    End If
    
    mflgDirty = False

  ElseIf mflgNew Then
    If Not mobjParent Is Nothing Then
      mobjParent.AddTape Me
      Set mobjParent = Nothing
    End If

  
  End If
    
  Set objPersist = Nothing
  mflgEditing = False

End Sub

Private Sub Class_Initialize()

  mflgNew = True
  Set mobjValid = New BrokenRules
 ' if we know any rules are broken on startup
  ' then add code here to initialize the list
  ' of broken rules
  '
  ' mobjValid.RuleBroken "RuleName", True
  mobjValid.RuleBroken "DateAcquired", True
  
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

Public Sub Load(TapeID As Long)

  Dim objPersist As TapePersist
  
  If mflgChild Then Err.Raise 445
  If mflgEditing Then Err.Raise 445
  If Not mflgNew Then Err.Raise 445
  
 ' code to load the object goes here
  Set objPersist = CreateObject("VideoServer.TapePersist", PERSIST_SERVER)
  SetState objPersist.Fetch(TapeID)
  Set objPersist = Nothing
  
  mflgNew = False

End Sub

Public Sub Delete()

  If mflgChild Then If Not mflgChildEditing Then Err.Raise 445
  If Not mflgEditing Then Err.Raise 445
  
  mflgDeleted = True
  mflgDirty = True
  
End Sub

Public Property Get IsDeleted() As Boolean

  IsDeleted = mflgDeleted

End Property

Public Property Get IsNew() As Boolean

  IsNew = mflgNew

End Property

Public Property Get IsDirty() As Boolean

  IsDirty = mflgDirty Or mflgNew

End Property

Friend Sub SetAsChild(objTapes As Tapes)

  If mflgNew Then Set mobjParent = objTapes
  mflgChild = True

End Sub

Friend Sub ChildBeginEdit()

  If mflgChildEditing Then Err.Raise 445
  
  ' save object state
  LSet mudtChild = mudtProps
  mflgChildEditing = True

End Sub

Friend Sub ChildCancelEdit()

  If Not mflgChildEditing Then Err.Raise 445
  
  mflgChildEditing = False
  mflgDeleted = False
  ' restore object state
  LSet mudtProps = mudtChild

End Sub

Public Property Get TapeID() As Long

  TapeID = mudtProps.TapeID

End Property

Public Property Get Title() As String

  If mflgNew Then Err.Raise 445
  
  Title = Trim$(mudtProps.Title)

End Property

Public Property Get CheckedOut() As Boolean

  CheckedOut = mudtProps.CheckedOut

End Property

Public Property Let DateAcquired(Value As Variant)

  If Not mflgEditing Then Err.Raise 383
  If Not mflgNew Then Err.Raise 383
  
  If Len(Trim(Value)) = 0 Then
    mudtProps.DateAcquired = ""
    mobjValid.RuleBroken "DateAcquired", True

  ElseIf IsDate(Value) Then
    mudtProps.DateAcquired = CVDate(Value)
    mobjValid.RuleBroken "DateAcquired", False

  Else
    mobjValid.RuleBroken "DateAcquired", True

  End If

  mflgDirty = True

End Property

Public Property Get DateAcquired() As Variant

  With mudtProps
    DateAcquired = IIf(.DateAcquired = 0, "", .DateAcquired)
  End With

End Property

Public Property Get Invoice() As Invoice

  Dim objInvoice As Invoice
  
  If Not mudtProps.CheckedOut Then Err.Raise 445
  
  Set objInvoice = New Invoice
  objInvoice.Load mudtProps.InvoiceID
  Set Invoice = objInvoice
  Set Invoice = Nothing

End Property

Public Sub CheckIn()

  If Not mflgEditing Then Err.Raise 445
  
  With mudtProps
    .CheckedOut = False
    If DateDiff("d", .DateDue, Now) > 0 Then _
      .LateFee = True
 
  End With

  mflgDirty = True

End Sub

Public Property Get DateDue() As Variant

  If Not mudtProps.CheckedOut Then Err.Raise 438
  
  DateDue = mudtProps.DateDue

End Property

Friend Function GetState() As String

  Dim udtData As TapeData
  
  With mudtProps
    .IsNew = mflgNew
    .IsDeleted = mflgDeleted
    .IsDirty = mflgDirty
  End With

  LSet udtData = mudtProps
  GetState = udtData.Buffer
  mflgNew = False

End Function

Friend Sub SetState(Buffer As String)

  Dim udtData As TapeData

  udtData.Buffer = Buffer
  LSet mudtProps = udtData
  mflgNew = False
  mobjValid.RuleBroken "DateAcquired", False

End Sub

