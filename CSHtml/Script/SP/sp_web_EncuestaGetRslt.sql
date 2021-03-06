SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaGetRslt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaGetRslt]
GO

/*

sp_web_EncuestaGetRslt 1,16

*/

create Procedure sp_web_EncuestaGetRslt
(
  @@us_id int,
  @@ec_id int
) 
as

  set nocount on

  declare @tiene_permiso int

  create table #t_info (ecp_id int, ecp_total int)

  if exists(select * from Encuesta ec
            where (
                    exists(select * 
                          from EncuestaDepartamento ecdpto 
                                inner join UsuarioDepartamento usdpto 
                                  on   ecdpto.dpto_id  = usdpto.dpto_id 
                                  and ec.ec_id       = ecdpto.ec_id
                                  and usdpto.us_id     = @@us_id
                          )
                    or not   exists(select * 
                                  from EncuestaDepartamento ecdpto 
                                  where ec.ec_id = ecdpto.ec_id
                                  )
                  )
          )

  begin
        set @tiene_permiso   = 1

        insert into #t_info(ecp_id, ecp_total)

        select   ecp.ecp_id, count(*)
        from EncuestaPregunta ecp
            inner join EncuestaPreguntaItem ecpi on ecp.ecp_id = ecpi.ecp_id
            inner join EncuestaRespuesta ecr on ecpi.ecpi_id = ecr.ecpi_id
        where ecp.ec_id = @@ec_id
        group by ecp.ecp_id

  end
  else
  begin
         set @tiene_permiso  = 0
  end

  select   ecp.ecp_id, 
          ec_FechaDesde,
          ec_FechaHasta,
          ecp_texto, 
          ecpi_texto, 
          isnull(count(ecr_id),0) as votos, 
          isnull(ecp_total,0)      as total

  from Encuesta ec  inner join EncuestaPregunta ecp       on ec.ec_id     = ecp.ec_id
                    inner join EncuestaPreguntaItem ecpi   on ecp.ecp_id   = ecpi.ecp_id
                    left join EncuestaRespuesta ecr       on ecpi.ecpi_id = ecr.ecpi_id
                    left join #t_info t                   on ecp.ecp_id   = t.ecp_id

  where ec.ec_id = @@ec_id
    and @tiene_permiso <> 0

  group by ecp.ecp_id, ecp_orden, ecp_texto, isnull(ecp_total,0), ecpi_orden, 
           ecpi_texto, ec_FechaDesde, ec_FechaHasta

  order by ecp_orden, ecp_texto, ecpi_orden, ecpi_texto


go
set quoted_identifier off 
go
set ansi_nulls on 
go

