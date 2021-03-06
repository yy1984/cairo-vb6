SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_ArticuloChangeEstado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_ArticuloChangeEstado]
GO

/*

sp_web_ArticuloChangeEstado 

*/

create procedure sp_web_ArticuloChangeEstado (

  @@wart_id        int,
  @@warte_id      int,
  @@rtn            int out
)
as
begin

  update webArticulo set

                              warte_id = @@warte_id


  where wart_id = @@wart_id

  set @@rtn = 1

end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

