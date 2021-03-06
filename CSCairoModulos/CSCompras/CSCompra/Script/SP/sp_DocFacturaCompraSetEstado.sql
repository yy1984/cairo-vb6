if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocFacturaCompraSetEstado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocFacturaCompraSetEstado]

/*

 sp_DocFacturaCompraSetEstado 1,1

*/

go
create procedure sp_DocFacturaCompraSetEstado (
  @@fc_id       int,
  @@Select      tinyint = 0,
  @@est_id      int = 0 out 
)
as

begin

  if @@fc_id = 0 return

  declare @est_id          int
  declare @prov_id          int
  declare @pendiente       decimal (18,6)
  declare @creditoTotal    decimal (18,6)
  declare @llevaFirma     tinyint
  declare @firmado        tinyint
  declare @deuda          decimal (18,6)
  declare @doc_id         int
  declare @doc_llevafirma tinyint

  declare @estado_pendiente         int set @estado_pendiente         =1
  declare @estado_pendienteCredito  int set @estado_pendienteCredito  =3
  declare @estado_pendienteFirma    int set @estado_pendienteFirma    =4
  declare @estado_finalizado        int set @estado_finalizado        =5
  declare @estado_anulado           int set @estado_anulado           =7

  select @prov_id = prov_id, @firmado = fc_firmado, @est_id = est_id, @doc_id = doc_id
  from FacturaCompra where fc_id = @@fc_id

  select @doc_llevafirma = doc_llevafirma from Documento where doc_id = @doc_id

  if @est_id <> @estado_anulado begin

    -- Si el documento requiere firma y el comprobante no esta firmado
    -- y no esta finalizado (puede ser que se finalizo y luego se modifico el documento
    -- para que requiera firma en cuyo caso no se exige firma para documentos finalizados)
    if @firmado = 0 and @doc_llevafirma <> 0 and @est_id <> @estado_finalizado begin             
      set @est_id = @estado_pendienteFirma 
    end
    else begin                                
      -- Se obtiene la deuda del comprobante
      select @deuda = round(sum(fcd_pendiente),2) from FacturaCompraDeuda where fc_id = @@fc_id

      -- Si el comprobante no tiene deuda se finaliza
      if IsNull(@deuda,0)<=0.01 begin
        set @est_id = @estado_finalizado          
      end else begin
        -- Se obtiene la deuda del Proveedor
        select @pendiente = sum(provcc_importe) from ProveedorCacheCredito where prov_id = @prov_id
        -- Se obtiene el credito del Proveedor
        select @creditoTotal = prov_creditototal from Proveedor where prov_id = @prov_id
        -- Si debe mas que el credito concedido al Proveedor
        if @pendiente > @creditoTotal begin  
          set @est_id = @estado_pendienteCredito 

        -- sino solo pendiente
        end else begin
          set @est_id = @estado_pendiente  
        end
      end
    end
  
    update FacturaCompra set est_id = @est_id
    where fc_id = @@fc_id
  
  end

  set @@est_id = @est_id  
  if @@Select <> 0 select @est_id

  return
ControlError:

  raiserror ('Ha ocurrido un error al actualizar el estado de la factura de compra. sp_DocFacturaCompraSetEstado.', 16, 1)

end
GO