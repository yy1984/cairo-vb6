VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cITableSecurity"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'--------------------------------------------------------------------------------
' cITableSecurity
' 04-01-00

'--------------------------------------------------------------------------------
' notas:

'--------------------------------------------------------------------------------
' api win32
    ' constantes
    ' estructuras
    ' funciones

'--------------------------------------------------------------------------------

' constantes
' estructuras
' variables privadas
' propiedades publicas
' propiedades privadas
' funciones publicas
Public Function Add(ByVal o As cIItemSecurity, Optional Key As Variant) As cIItemSecurity
End Function
Public Sub Remove(ByVal kItem As Variant)
End Sub
Public Function Count() As Long
End Function
Public Function Item(ByVal kItem As Variant) As cIItemSecurity
Attribute Item.VB_UserMemId = 0
End Function
Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
End Function
Public Sub Clear()
End Sub

' funciones privadas
' construccion - destruccion




