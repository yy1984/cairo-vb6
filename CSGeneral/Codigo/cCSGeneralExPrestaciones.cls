VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cCSGeneralExPrestaciones"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'--------------------------------------------------------------------------------
' cCSGeneralPrestaciones
' 27-01-01

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
' enumeraciones
Public Enum csGeneralPrestacion
  csPreGNewMoneda = 1028
  csPreGEditMoneda = 1029
  csPreGDeleteMoneda = 1030
  csPreGListMoneda = 1031

  csPreGNewChequera = 1128
  csPreGEditChequera = 1129
  csPreGDeleteChequera = 1130
  csPreGListChequera = 1131
  
  csPreGNewListaPrecio = 1096
  csPreGEditListaPrecio = 1097
  csPreGDeleteListaPrecio = 1098
  csPreGListListaPrecio = 1099

  csPreGNewListaDescuento = 1152
  csPreGEditListaDescuento = 1153
  csPreGDeleteListaDescuento = 1154
  csPreGListListaDescuento = 1155
  
  csPreGModifyConfig = 1156
  csPreGModifyConfigVentas = 1173
  csPreGModifyConfigTesoreria = 1174
  csPreGModifyConfigCompras = 1175
  csPreGModifyConfigTicket = 1979
  csPreGModifyConfigUsuario = 1990
  
  csPreGEditProductoNroSerie = 1217
  
  csPreGModifyConfigStock = 1999
  
  csPreGVentaSaldoInicial = 1998
  csPreGCompraSaldoInicial = 1997
  
  csPreGVentaFacturaAnular = 1996
  
  csPreGVentaImportRemito = 1995
  
  csPreGNewStockLote = 1994
  csPreGEditStockLote = 1993
  csPreGDeleteStockLote = 1992
  csPreGListStockLote = 1991
  
  csPreGSelectSerieEx = 1989
  
  csPreGModifyConfigContabilidad = 1988
  
  csPreGContImportPercRetIIBB = 1987
  
  csPreGImportarAsientos = 1986
  
  csPreGModifyConfigPersonal = 1985
  
  csPreGListaPrecioConfig = 1984
  csPreGListaPrecioCalc = 1983
  
  csPreGContImportPadronEmbargo = 1982

  csPreGVentaImportOS = 1981

End Enum

Public Enum csMenuEnum
  csMenuConfigGeneral = 1000
  csMenuConfigTesoreria = 1001
  csMenuConfigContabilidad = 1002
  csMenuConfigStock = 1003
  csMenuConfigArticulos = 1004
  csMenuConfigCompras = 1005
  csMenuConfigVentas = 1006
  csMenuConfigTicket = 1007
  csMenuConfigMPersonal = 1008
  csMenuConfigSueldos = 1009
  csMenuConfigEdu = 1010
  
  csMenuStock = 20001
End Enum

' variables privadas
' propiedades publicas
' propiedades privadas
' funciones publicas
Public Sub Init()
  SecurityAdd csPreGNewMoneda, "Agregar Monedas", "General"
  SecurityAdd csPreGDeleteMoneda, "Borrar Monedas", "General"
  SecurityAdd csPreGEditMoneda, "Editar Monedas", "General"
  SecurityAdd csPreGListMoneda, "Listar Monedas", "General"

  SecurityAdd csPreGNewChequera, "Agregar Chequera", "Chequera"
  SecurityAdd csPreGDeleteChequera, "Borrar Chequera", "Chequera"
  SecurityAdd csPreGEditChequera, "Editar Chequera", "Chequera"
  SecurityAdd csPreGListChequera, "Listar Chequera", "Chequera"
  
  SecurityAdd csPreGNewListaPrecio, "Agregar Listas de Precio", "General"
  SecurityAdd csPreGDeleteListaPrecio, "Borrar Listas de Precio", "General"
  SecurityAdd csPreGEditListaPrecio, "Editar Listas de Precio", "General"
  SecurityAdd csPreGListListaPrecio, "Listar Listas de Precio", "General"
  
  SecurityAdd csPreGNewListaDescuento, "Agregar Listas de Descuento", "Lista de Descuento"
  SecurityAdd csPreGDeleteListaDescuento, "Borrar Listas de Descuento", "Lista de Descuento"
  SecurityAdd csPreGEditListaDescuento, "Editar Listas de Descuento", "Lista de Descuento"
  SecurityAdd csPreGListListaDescuento, "Listar Listas de Descuento", "Lista de Descuento"

  SecurityAdd csPreGModifyConfig, "Editar Configuraci�n General", "Configuraci�n general"
  SecurityAdd csPreGModifyConfigVentas, "Editar Configuraci�n General de Ventas", "Configuraci�n general"
  SecurityAdd csPreGModifyConfigTesoreria, "Editar Configuraci�n General de Tesoreria", "Configuraci�n general"
  SecurityAdd csPreGModifyConfigCompras, "Editar Configuraci�n General de Compras", "Configuraci�n general"
  SecurityAdd csPreGModifyConfigTicket, "Editar Configuraci�n General de Servicios", "Configuraci�n general"
  SecurityAdd csPreGModifyConfigContabilidad, "Editar Configuraci�n General de Contabilidad", "Configuraci�n general"
  SecurityAdd csPreGModifyConfigPersonal, "Editar Configuraci�n General de Manejo de Personal", "Configuraci�n general"
  
  SecurityAdd csPreGModifyConfigStock, "Editar Configuraci�n General de Stock", "Configuraci�n general"
  SecurityAdd csPreGModifyConfigUsuario, "Editar Configuraci�n del Usuario", "Configuraci�n general"
  
  SecurityAdd csPreGVentaSaldoInicial, "Importar Saldos Iniciales de Ventas", "Configuraci�n general"
  SecurityAdd csPreGCompraSaldoInicial, "Importar Saldos Iniciales de Compras", "Configuraci�n general"
  SecurityAdd csPreGVentaFacturaAnular, "Anular Masivamente Facturas de Venta", "Configuraci�n general"
  
  SecurityAdd csPreGVentaImportRemito, "Importar Remitos de Ventas", "Configuraci�n general"
  SecurityAdd csPreGVentaImportOS, "Importar Ordenes de Servicio", "Configuraci�n general"
  
  SecurityAdd csPreGNewStockLote, "Agregar Lote de Stock", "Configuraci�n general"
  SecurityAdd csPreGDeleteStockLote, "Borrar Lote de Stock", "Configuraci�n general"
  SecurityAdd csPreGEditStockLote, "Editar Lote de Stock", "Configuraci�n general"
  SecurityAdd csPreGListStockLote, "Listar Lote de Stock", "Configuraci�n general"
  
  SecurityAdd csPreGSelectSerieEx, "Seleccionar Numeros de Serie sin Filtro por Deposito", "Configuraci�n general"
  
  SecurityAdd csPreGContImportPercRetIIBB, "Importar Percepciones y Retenciones IIBB BS AS", "Configuraci�n general"
  SecurityAdd csPreGImportarAsientos, "Importar Asientos Contables", "Configuraci�n general"
  
  SecurityAdd csPreGListaPrecioConfig, "Configuraci�n de Listas de Precios", "Configuraci�n general"
  SecurityAdd csPreGListaPrecioCalc, "Calcular Precios de Venta", "Configuraci�n general"
  
  SecurityAdd csPreGContImportPadronEmbargo, "Importar Padron Embargo", "Configuraci�n general"
  
End Sub

' funciones privadas
' construccion - destruccion