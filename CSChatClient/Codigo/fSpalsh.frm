VERSION 5.00
Begin VB.Form fSpalsh 
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Acerca de CSChat Client"
   ClientHeight    =   3690
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   8070
   Icon            =   "fSpalsh.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3690
   ScaleWidth      =   8070
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.PictureBox picHand 
      Height          =   495
      Left            =   7320
      Picture         =   "fSpalsh.frx":058A
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   0
      Top             =   -120
      Visible         =   0   'False
      Width           =   495
   End
   Begin VB.Image Image3 
      Height          =   750
      Left            =   240
      Picture         =   "fSpalsh.frx":0894
      Top             =   240
      Width           =   3120
   End
   Begin VB.Label LbVersion 
      Alignment       =   1  'Right Justify
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "exe: 10.0.10"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00808080&
      Height          =   270
      Left            =   2325
      TabIndex        =   7
      Top             =   1260
      Width           =   1230
   End
   Begin VB.Shape Shape1 
      BackColor       =   &H00FF8080&
      BackStyle       =   1  'Opaque
      BorderStyle     =   0  'Transparent
      Height          =   375
      Left            =   3960
      Top             =   0
      Width           =   6315
   End
   Begin VB.Label lbLink 
      BackStyle       =   0  'Transparent
      Caption         =   "http://www.crowsoft.com.ar"
      BeginProperty Font 
         Name            =   "Microsoft Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00808080&
      Height          =   315
      Left            =   360
      TabIndex        =   6
      Top             =   2640
      Width           =   2835
   End
   Begin VB.Label lbCopyRight01 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "Copyright � 2003-2005 Crowsoft."
      BeginProperty Font 
         Name            =   "Microsoft Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   3660
      TabIndex        =   5
      Top             =   2160
      Width           =   4215
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "Programa protegido por las leyes de derecho de autor."
      BeginProperty Font 
         Name            =   "Microsoft Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   2820
      TabIndex        =   4
      Top             =   2400
      Width           =   5055
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Right Justify
      BackStyle       =   0  'Transparent
      Caption         =   "Queda prohibida toda copia NO autorizada."
      BeginProperty Font 
         Name            =   "Microsoft Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   3660
      TabIndex        =   3
      Top             =   2640
      Width           =   4215
   End
   Begin VB.Shape Shape2 
      BackColor       =   &H00FF8080&
      BackStyle       =   1  'Opaque
      BorderStyle     =   0  'Transparent
      Height          =   135
      Left            =   0
      Top             =   1620
      Width           =   7695
   End
   Begin VB.Label lbLinkAccelerator 
      BackStyle       =   0  'Transparent
      Caption         =   "This product includes software developed by vbAccelerator (http://vbaccelerator.com/)."
      BeginProperty Font 
         Name            =   "Microsoft Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   1680
      TabIndex        =   2
      Top             =   3120
      Width           =   6795
   End
   Begin VB.Image imgLink 
      Height          =   720
      Left            =   1020
      Picture         =   "fSpalsh.frx":0CB2
      Top             =   1860
      Width           =   1200
   End
   Begin VB.Line Line1 
      BorderColor     =   &H8000000F&
      X1              =   180
      X2              =   7980
      Y1              =   3060
      Y2              =   3060
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Portions Copyright � 1998 Kirk Stowell."
      ForeColor       =   &H00808080&
      Height          =   255
      Left            =   1680
      TabIndex        =   1
      Top             =   3360
      Width           =   4575
   End
   Begin VB.Shape Shape3 
      BackColor       =   &H000080FF&
      BackStyle       =   1  'Opaque
      BorderStyle     =   0  'Transparent
      Height          =   4215
      Left            =   7500
      Top             =   180
      Width           =   675
   End
End
Attribute VB_Name = "fSpalsh"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim m_inicio        As Boolean
Dim m_leftVersion   As Integer
Dim m_IsSplash      As Boolean

Private Const C_Module = "fSplash"

Public Property Let IsSplash(ByVal rhs As Boolean)
  m_IsSplash = rhs
End Property

Private Sub Image1_Click()
  Form_Click
End Sub

Private Sub Image3_Click()
  Form_Click
End Sub

Private Sub Form_Unload(Cancel As Integer)
  Screen.MousePointer = vbDefault
End Sub

Private Sub Form_Click()
  If Not m_IsSplash Then
    Unload Me
  End If
End Sub

Private Sub lbLink_Click()
  On Error Resume Next
  SwhowPage lbLink.Caption, Me.hWnd
End Sub

Private Sub lbLink_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
  On Error Resume Next
  Screen.MousePointer = vbCustom
  Screen.MouseIcon = picHand.Picture
End Sub

Private Sub SwhowPage(ByVal strFile As String, ByVal hWnd As Long)
  CSKernelClient2.EditFile strFile, Me.hWnd
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
  Screen.MousePointer = vbDefault
End Sub

Private Sub imgLink_Click()
  lbLink_Click
End Sub

Private Sub imgLink_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
  lbLink_MouseMove Button, Shift, x, y
End Sub

Private Sub lbLinkAccelerator_Click()
  On Error Resume Next
  SwhowPage "http://www.vbaccelerator.com", Me.hWnd
End Sub

Private Sub lbLinkAccelerator_MouseMove(Button As Integer, Shift As Integer, x As Single, y As Single)
  On Error Resume Next
  Screen.MousePointer = vbCustom
  Screen.MouseIcon = picHand.Picture
End Sub

Private Sub Form_Initialize()
#If PREPROC_DEBUG Then
  gdbInitInstance C_Module
#End If
  m_IsSplash = True
End Sub

#If PREPROC_DEBUG Then
Private Sub Form_Terminate()
  gdbTerminateInstance C_Module
End Sub
#End If

Private Sub Form_Load()
  If m_IsSplash Then
    Top = (Screen.Height - Height) * 0.25
    Left = (Screen.Width - Width) * 0.5
    m_inicio = True
    LbVersion.Caption = App.Major & "." & App.Minor & "." & App.Revision
    m_leftVersion = LbVersion.Left
    LbVersion.Left = -LbVersion.Width
  Else
    CSKernelClient2.CenterForm Me, fMain
    LbVersion.Caption = "exe: " & GetExeVersion
  End If
End Sub
