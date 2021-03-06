USE [cairoNT]
GO
/****** Object:  StoredProcedure [dbo].[sp_FE_GetFacturas]    Script Date: 27/04/2018 6:08:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_FE_GetFacturas] (

	@@emp_id int
)

as

begin

	set nocount on

	declare @min_fecha datetime

	set @min_fecha = getdate()
	set @min_fecha = dateadd(ms,-datepart(ms,@min_fecha),@min_fecha)
	set @min_fecha = dateadd(ss,-datepart(ss,@min_fecha),@min_fecha)
	set @min_fecha = dateadd(mi,-datepart(mi,@min_fecha),@min_fecha)
	set @min_fecha = dateadd(hh,-datepart(hh,@min_fecha),@min_fecha)
	set @min_fecha = dateadd(dd,-5,@min_fecha)

	create table #t_min_fecha (doct_id int, emp_id int, fecha datetime)
	insert into #t_min_fecha (doct_id, emp_id, fecha)
	select fv.doct_id, fv.emp_id, case when max(fv_fecha) > @min_fecha then max(fv_fecha) else @min_fecha end
	from FacturaVenta fv inner join Documento doc on fv.doc_id = doc.doc_id and doc.doc_esfacturaelectronica <> 0
	where doc.doc_esfacturaelectronica <> 0
	group by fv.doct_id, fv.emp_id

	-- Paso 1 marcar facturas a procesar (para nunca procesar dos veces)

	create table #t_fe (fvfe_id int)

	insert into #t_fe (fvfe_id)
	select fe.fvfe_id
	from FacturaElectronica fe inner join FacturaVenta fv on fe.fv_id = fv.fv_id and fv.est_id <> 7
														 inner join Cliente cli on fv.cli_id = cli.cli_id
														 inner join Empresa emp on fv.emp_id = emp.emp_id
                             left  join #t_min_fecha t on fv.emp_id = t.emp_id and fv.doct_id = t.doct_id

	where fvfe_rechazado = 0
		and fv_cae = ''
		and case when t.fecha is null then fv.fv_fecha
              when fv.fv_fecha < t.fecha then t.fecha
              else fv.fv_fecha
         end >= @min_fecha
		and fv.est_id not in (7, 4) -- anulado, pendiente de firma
		and fvfe_procesado = 0

		and fv.emp_id = @@emp_id

	update FacturaElectronica set fvfe_procesado = 1 where fvfe_id in (select fvfe_id from #t_fe)

	-- Paso 2 obtener facturas

	select fe.fv_id,
				 --'20250282010' as cuit,
				 replace(emp_cuit,'-','')                   as cuit,
		     case
						when fv_total < 1000
							and dbo.FEGetTipoCbte(fv.doct_id, fe.fv_id) in (6,8,7)
							and dbo.FEGetDocCliente(cli.cli_cuit) = ''
						then 99
						else  dbo.FEGetTipoDocCliente(cli.cli_catfiscal)
				 end as tipo_doc,
		     dbo.FEGetDocCliente(cli.cli_cuit)  				as nro_doc,
		     dbo.FEGetTipoCbte(fv.doct_id, fe.fv_id)		as tipo_cbte,
		     dbo.FEGetPuntoVta(fe.fv_id)								as punto_vta,
		     dbo.FEGetNroDoc(fv.fv_nrodoc)    					as cbt_desde,
		     dbo.FEGetNroDoc(fv.fv_nrodoc)							as cbt_hasta,

		     convert(decimal(18,2),round(fv.fv_total,2))													as imp_total,
		     0																																		as imp_tot_conc,
		     convert(decimal(18,2),round(fv.fv_neto-dbo.FEGetExento(fe.fv_id),2))	as imp_neto,
		     convert(decimal(18,2),round(fv.fv_ivari,2))							            as impto_liq,
		     convert(decimal(18,2),round(fv.fv_ivarni,2))                         as impto_liq_rni,
		     convert(decimal(18,2),round(dbo.FEGetTributos(fe.fv_id),2))          as imp_tributo,
		     convert(decimal(18,2),round(dbo.FEGetExento(fe.fv_id),2)) 						as imp_op_ex,

		     case when t.fecha is null then fv.fv_fecha
              when fv.fv_fecha < t.fecha then t.fecha
              else fv.fv_fecha
         end                                        as fecha_cbte,
		     case when t.fecha is null then fv.fv_fecha
              when fv.fv_fecha < t.fecha then t.fecha
              else fv.fv_fecha
         end																				as fecha_serv_desde,
		     case when t.fecha is null then fv.fv_fecha
              when fv.fv_fecha < t.fecha then t.fecha
              else fv.fv_fecha
         end 																				as fecha_serv_hasta,
		     case when t.fecha is null then fv.fv_fecha
              when fv.fv_fecha < t.fecha then t.fecha
              else fv.fv_fecha
         end																				as fecha_venc_pago,
				 pa_codigo                                  as pais_id,
				 cli_razonsocial,
				 mon_codigodgi2                             as mon_id,
				 fv_cotizacion                              as mon_cotizacion,
				 case when substring(fv_nrodoc,1,1) = 'E' then 1 else 0 end as es_factura_expo,

				 convert(decimal(18,2),round(fv.fv_totalorigen,2))					as imp_total_origen

	from FacturaElectronica fe inner join FacturaVenta fv on fe.fv_id = fv.fv_id and fv.est_id <> 7
														 inner join Cliente cli on fv.cli_id = cli.cli_id
														 left  join Provincia pro on cli.pro_id = pro.pro_id
														 left  join Pais pa on pro.pa_id = pa.pa_id
														 inner join Empresa emp on fv.emp_id = emp.emp_id
                             left  join #t_min_fecha t on fv.emp_id = t.emp_id and fv.doct_id = t.doct_id
														 inner join Moneda mon on fv.mon_id = mon.mon_id

	where fvfe_rechazado = 0
		and fv_cae = ''
		and case when t.fecha is null then fv.fv_fecha
              when fv.fv_fecha < t.fecha then t.fecha
              else fv.fv_fecha
         end >= @min_fecha
		and fv.est_id not in (7, 4) -- anulado, pendiente de firma

    and fvfe_id in (select fvfe_id from #t_fe) -- tiene que estar entre las elegidas en el paso 1

  and fv.emp_id = @@emp_id

	order by fvfe_id
end
