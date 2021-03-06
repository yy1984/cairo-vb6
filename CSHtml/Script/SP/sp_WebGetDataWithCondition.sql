SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_WebGetDataWithCondition]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_WebGetDataWithCondition]
GO

/*

select * from reporte

sp_WebGetDataWithCondition 'tbl_nombre','tabla','tbl_id = 1'

*/

create procedure sp_WebGetDataWithCondition
(
  @@field        varchar(255),
  @@table        varchar(255),
  @@condition    varchar(255)
) 
as
begin

  declare @sqlstmt varchar(255)
  
  set @sqlstmt = 'select ' + @@field + ' from ' + @@table + ' where (' + @@condition + ')'

  exec (@sqlstmt)
  
end
go
set quoted_identifier off 
go
set ansi_nulls on 
go

