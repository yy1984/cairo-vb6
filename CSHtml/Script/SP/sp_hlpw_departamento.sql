if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_hlpw_departamento]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_hlpw_departamento]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

        select dpto_id,
               dpto_nombre   as Nombre,
               dpto_codigo   as Codigo
        from departamento 
  
        where (exists (select * from Empresadepartamento where dpto_id = departamento.dpto_id) or 1 = 1)

  select us_empresaex from usuario

 sp_hlpw_departamento 1,3,'',-1,1

 sp_hlpw_departamento 2,3,'',0,0

*/

create procedure sp_hlpw_departamento (
  @@us_id           int,
  @@emp_id          int,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0
)
as
begin
  set nocount on

  if @@check <> 0 begin
  
    select   dpto_id,
            dpto_nombre        as [Nombre],
            dpto_codigo       as [Codigo]

    from Departamento

    where (dpto_nombre = @@filter or dpto_codigo = @@filter)
      and activo <> 0
      and (
                exists (select * from UsuarioDepartamento where dpto_id = Departamento.dpto_id and us_id = @@us_id) 
            or  @@us_id = 1
            or  exists (select * from Permiso 
                        where pre_id = Departamento.pre_id_vertareas 
                          and (
                                us_id = @@us_id
                                or exists(select * from UsuarioRol where rol_id = Permiso.rol_id and us_id = @@us_id)
                              )
                       ) 
          )

  end else begin

      select top 50
             dpto_id,
             dpto_nombre   as Nombre,
             dpto_codigo   as Codigo

      from Departamento 

      where (dpto_codigo like '%'+@@filter+'%' or dpto_nombre like '%'+@@filter+'%' or @@filter = '')
      and (
                exists (select * from UsuarioDepartamento where dpto_id = Departamento.dpto_id and us_id = @@us_id)
            or  @@us_id = 1
            or  exists (select * from Permiso 
                        where pre_id = Departamento.pre_id_vertareas 
                          and (
                                us_id = @@us_id
                                or exists(select * from UsuarioRol where rol_id = Permiso.rol_id and us_id = @@us_id)
                              )
                       ) 
          )
  end    

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

