if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocCobranzaGetCuentaDeudor]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocCobranzaGetCuentaDeudor]

go

/*

select * from cuentacategoria

exec sp_DocCobranzaGetCuentaDeudor '13,14,19,20,21,22,23,24,25,26,27,28'

*/

create procedure sp_DocCobranzaGetCuentaDeudor (
  @@strIds             varchar(5000)
)
as

begin

  declare @cue_deudoresXvta int 
  set @cue_deudoresXvta = 4

  declare @timeCode datetime
  set @timeCode = getdate()
  exec sp_strStringToTable @timeCode, @@strIds, ','

  select

      fv_id,
      c.cue_id,
      c.cue_nombre

  from AsientoItem inner join FacturaVenta             on AsientoItem.as_id    = FacturaVenta.as_id
                   inner join TmpStringToTable        on FacturaVenta.fv_id   = convert(int,TmpStringToTable.tmpstr2tbl_campo)
                   inner join Cuenta c                on AsientoItem.cue_id   = c.cue_id
  where 
          asi_debe       <> 0
    and   tmpstr2tbl_id =  @timeCode
    and   cuec_id       =  @cue_deudoresXvta

  group by fv_id,c.cue_id,cue_nombre

end
go