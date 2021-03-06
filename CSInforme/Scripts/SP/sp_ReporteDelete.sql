if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ReporteDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ReporteDelete]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

 sp_ReporteDelete '',-1,0,7

 sp_ReporteDelete '',0,0,7

*/

create procedure sp_ReporteDelete (
  @@rpt_id          int
)
as
begin

  begin transaction

  declare @grdv_id int

  declare c_view insensitive cursor for 
    select grdv_id from GridView where rpt_id = @@rpt_id

  open c_view
  fetch next from c_view into @grdv_id
  while @@fetch_status=0
  begin

    exec sp_GridViewDelete @grdv_id

    fetch next from c_view into @grdv_id
  end
  close c_view

  delete ReporteParametro where rpt_id = @@rpt_id
  if @@error <> 0 goto ControlError

  delete Reporte where rpt_id = @@rpt_id
  if @@error <> 0 goto ControlError

  commit transaction

  return
ControlError:

  raiserror ('Ha ocurrido un error al borrar el reporte. sp_ReporteDelete.', 16, 1)
  rollback transaction

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

