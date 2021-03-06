SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_ArticuloGetEx]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_ArticuloGetEx]
GO

/*

sp_web_ArticuloGetEx 22,0,'20041026','20041026',0

select * from Articulo

*/

create procedure sp_web_ArticuloGetEx (

  @@wartt_id              int,
  @@warte_id              int,
  @@wart_fechaDesde        datetime,
  @@wart_fechaHasta        datetime,
  @@us_id                  int

)as
begin

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%%'*/
  exec sp_HistoriaUpdate 25000, 0, @@us_id, 3

  select 
      wart_id,
      wart_titulo               as [Titulo], 
      wart_copete               as [Copete],
      wart_origen               as [Origen],
      wart_texto                as [Texto],
      wart_origenurl            as [Origen URL],
      wart_imagen                as [Imagen],
      wart_fecha                as [Fecha],
      t.wartt_nombre             as [Tipo],
      e.warte_nombre             as [Estado]

  from webArticulo a inner join webArticuloTipo  t            on a.wartt_id = t.wartt_id
                     inner join webArticuloEstado  e          on a.warte_id = e.warte_id
  where 

--      (us_id      = @@us_id    or @@us_id    = 0)
  /*and*/ (t.wartt_id = @@wartt_id or @@wartt_id = 0)
  and (e.warte_id = @@warte_id or @@warte_id = 0)
  and wart_fecha <= @@wart_fechaDesde
  and wart_fechavto >= @@wart_fechaHasta

  order by wart_fecha desc

end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

