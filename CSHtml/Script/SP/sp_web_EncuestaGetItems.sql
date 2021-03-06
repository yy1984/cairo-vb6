SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaGetItems]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaGetItems]
GO

/*

sp_web_EncuestaGetItems 7

*/

create Procedure sp_web_EncuestaGetItems
(
  @@ecp_id     int
) 
as

  select ecpi_id, ecpi_texto
  from EncuestaPreguntaItem
  where ecp_id = @@ecp_id
  order by ecpi_orden, ecpi_texto

go
set quoted_identifier off 
go
set ansi_nulls on 
go

