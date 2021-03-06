if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_reporteGetParametros]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_reporteGetParametros]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
-- select * from informe where inf_nombre like '%valid%'
-- select * from reporte where inf_id = 34
-- sp_col reporteparametro
-- sp_reporteGetParametros 34,85
create procedure sp_reporteGetParametros (
  @@inf_id int,
  @@rpt_id int
)
as
begin
  set nocount on

  select  i.infp_id,
          infp_nombre,
          infp_orden,
          infp_tipo,
          infp_default,
          infp_visible,
          infp_sqlstmt,
          i.inf_id,
          i.tbl_id,
          rptp_id,
          rptp_valor,
          rptp_visible,
          rpt_id
 
  from informeparametro i left join reporteparametro r on   i.infp_id = r.infp_id 
                                                        and (     r.rpt_id = @@rpt_id 
                                                              or r.rpt_id is null
                                                            )
  where 
        i.inf_id = @@inf_id 
    
  order by infp_orden

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

