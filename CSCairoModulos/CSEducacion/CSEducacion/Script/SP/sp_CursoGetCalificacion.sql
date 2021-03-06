SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_CursoGetCalificacion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_CursoGetCalificacion]
GO

/*

sp_CursoGetCalificacion 2

*/

create procedure sp_CursoGetCalificacion
(
  @@cur_id   int
)
as
begin

  select   curic.*,
          curi.alum_id,
          curi_calificacion,
          cure_fecha,
          cure_desde,
          palum.prs_apellido + ', ' + palum.prs_nombre   as alum_nombre

  from  CursoItem curi        
                       left  join CursoItemCalificacion curic on curi.curi_id   = curic.curi_id
                       left  join Alumno alum                 on curi.alum_id   = alum.alum_id
                       left  join Persona palum               on alum.prs_id    = palum.prs_id
                       left  join CursoExamen cure            on curic.cure_id  = cure.cure_id

  where curi.cur_id = @@cur_id

  order by alum_nombre, curi.alum_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go