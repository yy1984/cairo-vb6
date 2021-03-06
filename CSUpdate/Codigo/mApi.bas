Attribute VB_Name = "mApi"
Option Explicit

    Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long
    Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long

    ' Microsoft' s answers to associating files are:
    ' 1. HOWTO: Associate a File Extension with Your Application
    ' http://support.microsoft.com/default.aspx?scid=KB;en-us;q185453
    '
    ' 2. HOWTO: Associate a Custom Icon with a File Extension
    ' http://support.microsoft.com/default.aspx?scid=kb;en-us;247529
    ' ========Read registry key values
    '
    Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
    Private Declare Function RegOpenKey Lib "advapi32.dll" Alias "RegOpenKeyA" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long
    Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, ByVal lpData As String, lpcbData As Long) As Long
    
    ' Note that if you declare the lpData parameter as String,
    ' you must pass it By Value. (In RegQueryValueEx)
    '
    Private phkResult As Long
    Private lpSubKey As String
    Private lpData As String
    Private lpcbData As Long
    Private RC As Long
    
    ' Root Key Constants ...................................
    '
    Private Const HKEY_CLASSES_ROOT = &H80000000
    
    ' Reg DataType Constants ...............................
    '
    Private Const REG_SZ = 1 '  Unicode null terminated string
    
    ' ===============Create and delete key in registry
    '
    Private Declare Function RegDeleteKey Lib "advapi32.dll" Alias "RegDeleteKeyA" (ByVal hKey As Long, ByVal lpSubKey As String) As Long
    Private Declare Function RegCreateKey Lib "advapi32.dll" Alias "RegCreateKeyA" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long
    Private Declare Function RegSetValue Lib "advapi32.dll" Alias "RegSetValueA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal dwType As Long, ByVal lpData As String, ByVal cbData As Long) As Long
          
          '  Return codes from Registration functions.
          '
          Const ERROR_SUCCESS = 0&
          Const ERROR_BADDB = 1&
          Const ERROR_BADKEY = 2&
          Const ERROR_CANTOPEN = 3&
          Const ERROR_CANTREAD = 4&
          Const ERROR_CANTWRITE = 5&
          Const ERROR_OUTOFMEMORY = 6&
          Const ERROR_INVALID_PARAMETER = 7&
          Const ERROR_ACCESS_DENIED = 8&
          Private Const MAX_PATH = 260&
          
          ' ==included in Read registry key values
          ' Private Const HKEY_CLASSES_ROOT = &H80000000
          ' Private Const REG_SZ = 1
          
    ' This sub puts new default icon on associated files or off if unassociated
    '
    Private Declare Sub SHChangeNotify Lib "shell32.dll" (ByVal wEventId As Long, ByVal uFlags As Long, dwItem1 As Any, dwItem2 As Any)
    Private Const SHCNE_ASSOCCHANGED = &H8000000
    Private Const SHCNF_IDLIST = &H0&

    Private Declare Function GetLongPathName Lib "kernel32" Alias "GetLongPathNameA" (ByVal lpszShortPath As String, ByVal lpszLongPath As String, ByVal cchBuffer As Long) As Long
    Private Declare Function LoadLibrary Lib "kernel32" Alias "LoadLibraryA" (ByVal lpLibFileName As String) As Long
    Private Declare Function GetProcAddress Lib "kernel32" (ByVal hModule As Long, ByVal lpProcName As String) As Long
    Private Declare Function FreeLibrary Lib "kernel32" (ByVal hLibModule As Long) As Long
    Private Declare Function FindExecutable Lib "shell32.dll" Alias "FindExecutableA" (ByVal lpFile As String, ByVal lpDirectory As String, ByVal lpResult As String) As Long

    Public Enum SpecialFolderIDs
        sfidDESKTOP = &H0
        sfidPROGRAMS = &H2
        sfidPERSONAL = &H5
        sfidFAVORITES = &H6
        sfidSTARTUP = &H7
        sfidRECENT = &H8
        sfidSENDTO = &H9
        sfidSTARTMENU = &HB
        sfidDESKTOPDIRECTORY = &H10
        sfidNETHOOD = &H13
        sfidFONTS = &H14
        sfidTEMPLATES = &H15
        sfidCOMMON_STARTMENU = &H16
        sfidCOMMON_PROGRAMS = &H17
        sfidCOMMON_STARTUP = &H18
        sfidCOMMON_DESKTOPDIRECTORY = &H19
        sfidAPPDATA = &H1A
        sfidPRINTHOOD = &H1B
        sfidPROGRAMS_FILES = &H26
        sfidProgramFiles = &H10000
        sfidCommonFiles = &H10001
    End Enum
    
    Public Declare Function SHGetSpecialFolderLocation Lib "shell32" (ByVal hwndOwner As Long, ByVal nFolder As SpecialFolderIDs, ByRef pIdl As Long) As Long
    Public Declare Function SHGetPathFromIDListA Lib "shell32" (ByVal pIdl As Long, ByVal pszPath As String) As Long
    
    Public Const NOERROR = 0

'////////////////////////////////////////////////////////////////
' Funciones Publicas

Public Function GetEspecialFolders(ByVal nFolder As SpecialFolderIDs) As String
  Dim sPath   As String
  Dim strPath As String
  Dim lngPos  As Long
  Dim IDL     As Long
  
  ' Fill the item id list with the pointer of each folder item, rtns 0 on success
  If SHGetSpecialFolderLocation(0, nFolder, IDL) = NOERROR Then
      sPath = String$(255, 0)
      SHGetPathFromIDListA IDL, sPath

      lngPos = InStr(sPath, Chr(0))
      If lngPos > 0 Then
          strPath = Left$(sPath, lngPos - 1)
      End If
  End If
  
  GetEspecialFolders = strPath
End Function


'------------------------------------------------------------
' Usage:    Convert short (8.3) file name to long file name
'
' Input:    FULL PATH OF A SHORT FILE NAME
'
' Returns:  LONG FILE NAME:
'
' Example:  dim sLongFile as String
'           sLongFile = GetLongFileName("C\:MyShor~1.txt")
'
' Notes:    ONLY WORKS ON WIN 98 and WIN 2000.  WILL RETURN
'           EMPTY STRING ELSEWHERE
'
Public Function GetLongFileName(ByVal FullFileName As String) As String
    
    Dim lLen    As Long
    Dim sBuffer As String
    
    ' Function only available on '98 and 2000,
    ' so we check to see if it's available before proceeding
    '
    If Not pAPIFunctionPresent("GetLongPathNameA", "kernel32") Then
        Exit Function
    End If
    
    sBuffer = String$(MAX_PATH, 0)
    lLen = GetLongPathName(FullFileName, sBuffer, Len(sBuffer))
    
    If lLen > 0 And Err.Number = 0 Then
        GetLongFileName = Left$(sBuffer, lLen)
    Else
        GetLongFileName = FullFileName
    End If
End Function

'----------------------------------------------
' Usage: Get full path of.exe assosciated
'
Public Function GetAssociatedApp(ByVal FullFileName As String) As String
    On Error GoTo ControlError
    
    Dim MyFile As String
    
    MyFile = String(MAX_PATH, " ")

    FindExecutable FullFileName, _
                   pGetFilePath(FullFileName), _
                   MyFile
    
    GetAssociatedApp = Trim(MyFile)
    
ControlError:
End Function

Public Sub AssociateFileExtension(ByVal Extension As String, _
                                  ByVal PathToExecute As String, _
                                  ByVal ApplicationName As String)
                                  
    ' Extension is three letters without the "."
    ' PathToExecute is full path to exe file
    ' Application Name is any name you want as description of Extension
    '
    Dim sKeyName    As String   ' Holds Key Name in registry.
    Dim sKeyValue   As String   ' Holds Key Value in registry.
    Dim ret         As Long     ' Holds error status, if any, from API calls.
    Dim lphKey      As Long     ' Holds created key handle from RegCreateKey.
    
    ret = InStr(1, Extension, ".")
    If ret <> 0 Then
      MsgBox "Extension has . in it. Remove and try again."
      Exit Sub
    End If
    
    ' This creates a Root entry called ' ApplicationName' .
        sKeyName = ApplicationName
        sKeyValue = ApplicationName
        ret = RegCreateKey&(HKEY_CLASSES_ROOT, sKeyName, lphKey)
        ret = RegSetValue&(lphKey, "", REG_SZ, sKeyValue, 0&)
    
    ' This creates a Root entry for the extension to be associated with ' ApplicationName' .
        sKeyName = "." & Extension
        sKeyValue = ApplicationName
        ret = RegCreateKey&(HKEY_CLASSES_ROOT, sKeyName, lphKey)
        ret = RegSetValue&(lphKey, "", REG_SZ, sKeyValue, 0&)
    
    ' This sets the command line for ' ApplicationName' .
        sKeyName = ApplicationName
        sKeyValue = """" & PathToExecute & """ %1"
        ret = RegCreateKey&(HKEY_CLASSES_ROOT, sKeyName, lphKey)
        ret = RegSetValue&(lphKey, "shell\open\command", REG_SZ, sKeyValue, MAX_PATH)
    
    ' This sets the default icon
        sKeyName = ApplicationName
        sKeyValue = """" & PathToExecute & """,0"
        ret = RegCreateKey&(HKEY_CLASSES_ROOT, sKeyName, lphKey)
        ret = RegSetValue&(lphKey, "DefaultIcon", REG_SZ, sKeyValue, MAX_PATH)
    
    ' Force Icon Refresh
      SHChangeNotify SHCNE_ASSOCCHANGED, SHCNF_IDLIST, 0, 0
End Sub

Public Sub UnAssociateFileExtension(ByVal Extension As String, _
                                    ByVal ApplicationName As String)
                                    
    Dim sKeyName    As String   ' Finds Key Name in registry.
    Dim sKeyValue   As String   ' Finds Key Value in registry.
    Dim ret         As Long     ' Holds error status, if any, from API calls.
    
    ret = InStr(1, Extension, ".")
      If ret <> 0 Then
        MsgBox "Extension has . in it. Remove and try again."
        Exit Sub
      End If
      
    ' This deletes the default icon
        sKeyName = ApplicationName
        ret = RegDeleteKey(HKEY_CLASSES_ROOT, sKeyName & "\DefaultIcon")
    
    ' This deletes the command line for "ApplicationName".
        sKeyName = ApplicationName
        ret = RegDeleteKey(HKEY_CLASSES_ROOT, sKeyName & "\shell\open\command")
    
    ' This deletes a Root entry called "ApplicationName".
        sKeyName = ApplicationName
        ret = RegDeleteKey(HKEY_CLASSES_ROOT, sKeyName & "\shell\open")
    
    ' This deletes a Root entry called "ApplicationName".
        sKeyName = ApplicationName
        ret = RegDeleteKey(HKEY_CLASSES_ROOT, sKeyName & "\shell")
    
    ' This deletes a Root entry called "ApplicationName".
        sKeyName = ApplicationName
        ret = RegDeleteKey(HKEY_CLASSES_ROOT, sKeyName)
    
    ' This deletes the Root entry for the extension to be associated with "ApplicationName".
        sKeyName = "." & Extension
        ret = RegDeleteKey(HKEY_CLASSES_ROOT, sKeyName)
    
    ' Force Icon Refresh
      SHChangeNotify SHCNE_ASSOCCHANGED, SHCNF_IDLIST, 0, 0
End Sub

'////////////////////////////////////////////////////////////////
' Funciones Privadas

Private Function pGetFilePath(ByVal FullFileName As String) As String
    Dim i As Integer
    
    For i = Len(FullFileName) To 1 Step -1
        If Mid$(FullFileName, i, 1) = "\" Then
            pGetFilePath = Mid(FullFileName, 1, i - 1)
            Exit Function
        End If
    Next
End Function

Private Function pAPIFunctionPresent(ByVal FunctionName As String, _
                                     ByVal DllName As String) As Boolean
    Dim lHandle As Long
    Dim lAddr  As Long

    lHandle = LoadLibrary(DllName)
    If lHandle <> 0 Then
        lAddr = GetProcAddress(lHandle, FunctionName)
        FreeLibrary lHandle
    End If
    
    pAPIFunctionPresent = (lAddr <> 0)

End Function

Public Function IniGet2(ByVal lpApplicationName As String, _
                        ByVal lpKeyName As String, _
                        ByVal lpDefault As String, _
                        ByVal lpFileName As String) As String
  
  Dim lpReturnedString  As String
  Dim nSize             As Long

  lpReturnedString = String$(4096, " ")
  nSize = Len(lpReturnedString)

  nSize = GetPrivateProfileString(lpApplicationName, _
                                  lpKeyName, _
                                  lpDefault, _
                                  lpReturnedString, _
                                  nSize, _
                                  lpFileName)
  If nSize Then
    IniGet2 = Left$(lpReturnedString, nSize)
  End If
End Function
