SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_DepartamentoGetXUsId]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_DepartamentoGetXUsId]
GO

/*

select * from usuario
update persona set dpto_id = 1
select * from departamento

sp_web_DepartamentoGetXUsId 397

*/

create Procedure sp_web_DepartamentoGetXUsId
(
  @@us_id int  
) 
as

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%%'*/
  exec sp_HistoriaUpdate 1015, 0, @@us_id, 2

  select 
      Departamento.dpto_id,
      dpto_nombre

  from Usuario  inner join Persona      on Usuario.prs_id  = Persona.prs_id
                inner join Departamento on Persona.dpto_id = Departamento.dpto_id

  where us_id = @@us_id

go
set quoted_identifier off 
go
set ansi_nulls on 
go

