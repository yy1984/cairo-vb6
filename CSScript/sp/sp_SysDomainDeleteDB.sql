if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_SysDomainDeleteDB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_SysDomainDeleteDB]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

  select * from basedatos

  sp_SysDomainDeleteDB 7

*/
create procedure sp_SysDomainDeleteDB (
  @@id            int
)
as
begin
  set nocount on

  delete Empresa where bd_id = @@id
  delete BaseDatos where bd_id = @@id

end


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

