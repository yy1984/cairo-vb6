SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaUpdate]
GO

/*

*/

create Procedure sp_web_EncuestaUpdate (
     @@ec_id                int,
     @@ec_nombre            varchar(255),
     @@ec_descrip          varchar(255),
 
     @@ec_FechaDesde        varchar(20),
     @@ec_FechaHasta        varchar(20),
    @@ec_anonimo          smallint,
    @@activo              smallint,

    @@us_id                int,
    @@rtn                 int out
) 
as

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%%'*/
  exec sp_HistoriaUpdate 1028, @@ec_id, @@us_id, 2

   set @@ec_nombre   = isnull(@@ec_nombre,'')
  set @@ec_descrip = isnull(@@ec_descrip,'')

  if @@ec_anonimo <> 0  set @@ec_anonimo  = 1
  if @@activo <> 0       set @@activo       = 1

  if @@ec_id = 0 begin

    exec SP_DBGetNewId 'Encuesta', 'ec_id', @@ec_id out, 0

    insert into Encuesta (
                              ec_id,
                              ec_nombre,
                              ec_descrip,
                              ec_fechaDesde,
                              ec_fechaHasta,
                              ec_anonimo,
                              activo,
                              modifico

                            )
                    values  (
                              @@ec_id,
                              @@ec_nombre,
                              @@ec_descrip,
                              @@ec_FechaDesde,
                              @@ec_FechaHasta,
                              @@ec_anonimo,
                              @@activo,
                              @@us_id
                            )
  end else begin

      update Encuesta set
                              ec_nombre        = @@ec_nombre,
                              ec_descrip      = @@ec_descrip,
                              ec_fechaDesde    = @@ec_FechaDesde,
                              ec_fechaHasta    = @@ec_FechaHasta,
                              ec_anonimo      = @@ec_anonimo,
                              activo          = @@activo,
                              modifico        = @@us_id
      where ec_id = @@ec_id
  end

  set @@rtn = @@ec_id
go
set quoted_identifier off 
go
set ansi_nulls on 
go

