SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_Web_ReportsGetParams]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_Web_ReportsGetParams]
GO

/*

select * from reporte

sp_Web_ReportsGetParams 136

*/

create procedure sp_Web_ReportsGetParams
(
  @@rpt_id           int
) 
as
begin

  declare @inf_id int

  select @inf_id = inf_id from Reporte where rpt_id = @@rpt_id

  select 
        i.infp_id      ,
        i.infp_nombre  ,
        i.infp_orden   ,
        i.infp_tipo    ,
        i.infp_default ,
        i.infp_visible ,
        i.infp_sqlstmt ,
        i.inf_id       ,
        i.tbl_id       ,
        i.creado       ,
        i.modificado   ,
        i.modifico     ,
        r.rptp_id      ,
        IsNull(r.rptp_valor,i.infp_default)   as  rptp_valor,
        IsNull(r.rptp_visible,i.infp_visible) as  rptp_visible,
        r.rpt_id       ,
        r.creado       ,
        r.modificado   ,
        r.modifico

  from 
        InformeParametro i left join ReporteParametro r on i.infp_id = r.infp_id
                                                      and  r.rpt_id = @@rpt_id
  where 
        i.inf_id = @inf_id

  order by infp_orden

end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

