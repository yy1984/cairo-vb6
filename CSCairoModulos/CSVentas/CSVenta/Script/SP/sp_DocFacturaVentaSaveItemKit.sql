if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocFacturaVentaSaveItemKit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocFacturaVentaSaveItemKit]

/*
 select * from FacturaVenta
 sp_DocFacturaVentaSaveItemKit 26

*/

go
create procedure sp_DocFacturaVentaSaveItemKit (
  @@fvTMP_id        int,
  @@fvi_id          int,
  @@st_id           int,
  @@sti_orden        int out,
  @@fvi_cantidad    decimal(18,6),
  @@fvi_descrip     varchar(255),
  @@pr_id           int,
  @@depl_id_origen  int,
  @@depl_id_destino int,
  @@stl_id          int,

  @@bSuccess         tinyint out,
  @@MsgError        varchar(5000)= '' out
)
as
begin

  set nocount on

  --//////////////////////////////////////////////////////////////////////////
  --
  -- Obtengo los componentes del
  --

  create table #KitItems      (
                                pr_id int not null, 
                                nivel int not null
                              )

  create table #KitItemsSerie(
                                pr_id_kit       int null,
                                cantidad         decimal(18,6) not null,
                                pr_id           int not null, 
                                prk_id           int not null,
                                nivel           smallint not null default(0)
                              )

  exec sp_StockProductoGetKitInfo @@pr_id, 0

  --//////////////////////////////////////////////////////////////////////////////////
  -- Creo el StockItemKit
  declare @stik_orden         smallint
  declare @stik_llevanroserie int
  declare @stik_id             int

  
  exec SP_DBGetNewId 'StockItemKit','stik_id',@stik_id out, 0

  if exists(select * from #KitItemsSerie s inner join Producto p on s.pr_id = p.pr_id
                     where pr_llevanroserie <> 0) 
    
          set @stik_llevanroserie = 1
  else    set @stik_llevanroserie = 0 

  insert into StockItemKit (stik_id,stik_cantidad,pr_id,st_id,stik_llevanroserie)
                  values   (@stik_id,@@fvi_cantidad,@@pr_id,@@st_id,@stik_llevanroserie)


  declare c_KitItems insensitive cursor for select pr_id, cantidad from #KitItemsSerie

  open c_KitItems

  declare @pr_id             int
  declare @cantidad          decimal(18,6)
  declare @bLlevaNroSerie   tinyint

  fetch next from c_KitItems into @pr_id, @cantidad
  while @@fetch_status = 0 
  begin

    set @cantidad = @cantidad * @@fvi_cantidad 

    select @bLlevaNroSerie = pr_llevanroserie from Producto where pr_id = @pr_id
    if @bLlevaNroSerie <> 0 begin

        exec sp_DocFacturaVentaSaveNroSerie     @@fvTMP_id,
                                                @@fvi_id,
                                                @@st_id,
                                                @@sti_orden out,
                                                @cantidad,
                                                @@fvi_descrip,
                                                @pr_id,
                                                @@depl_id_origen,
                                                @@depl_id_destino,
                                                @stik_id,
            
                                                @@bSuccess out,
                                                @@MsgError out 
                        
        if IsNull(@@bSuccess,0) = 0 goto Validate

    end  else begin

        exec sp_DocFacturaVentaStockItemSave 
                                                0,
                                                @@st_id,
                                                @@sti_orden out,
                                                @cantidad,
                                                @@fvi_descrip,
                                                @pr_id,
                                                @@depl_id_origen,
                                                @@depl_id_destino,
                                                null,
                                                @stik_id,
                                                @@stl_id,
            
                                                @@bSuccess out,
                                                @@MsgError out 
                  
        if IsNull(@@bSuccess,0) = 0 goto Validate

    end

    fetch next from c_KitItems into @pr_id, @cantidad
  end

  close c_KitItems
  deallocate c_KitItems

  set @@bSuccess = 1
  return

ControlError:
  set @@MsgError = 'Ha ocurrido un error al grabar el item de stock de la factura de venta. sp_DocFacturaVentaSaveItemKit.'

Validate:

  set @@bSuccess = 0

end
go