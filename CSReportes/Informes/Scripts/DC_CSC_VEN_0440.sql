/*
---------------------------------------------------------------------
Nombre: Documentos de Venta Pendientes
---------------------------------------------------------------------


DC_CSC_VEN_0440 1,'20000101','20100101',0,0,0,0,0,0,0,0,0,0,0,0,0,0

*/

if exists (select * from sysobjects where id = object_id(N'[dbo].[DC_CSC_VEN_0440]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DC_CSC_VEN_0440]


go

create procedure DC_CSC_VEN_0440 (

  @@us_id    int,
  @@Fini      datetime,
  @@FFin      datetime,

@@cli_id         varchar(255),
@@suc_id         varchar(255), 
@@emp_id        varchar(255),
@@trans_id      varchar(255),
@@chof_id       varchar(255),
@@cam_id        varchar(255),
@@bConSaldos    smallint,
@@bSaldosCero   smallint

)as 

begin

set nocount on

/*- ///////////////////////////////////////////////////////////////////////

SEGURIDAD SOBRE USUARIOS EXTERNOS

/////////////////////////////////////////////////////////////////////// */

declare @us_empresaEx tinyint
select @us_empresaEx = us_empresaEx from usuario where us_id = @@us_id

/*- ///////////////////////////////////////////////////////////////////////

INICIO PRIMERA PARTE DE ARBOLES

/////////////////////////////////////////////////////////////////////// */

declare @cli_id   int
declare @suc_id   int
declare @emp_id   int 
declare @trans_id int
declare @chof_id  int
declare @cam_id   int

declare @ram_id_Cliente       int
declare @ram_id_Sucursal      int
declare @ram_id_Empresa       int 
declare @ram_id_Transporte    int
declare @ram_id_Chofer        int
declare @ram_id_Camion        int

declare @clienteID int
declare @IsRaiz    tinyint

exec sp_ArbConvertId @@cli_id,   @cli_id out,   @ram_id_Cliente out
exec sp_ArbConvertId @@suc_id,   @suc_id out,   @ram_id_Sucursal out
exec sp_ArbConvertId @@emp_id,   @emp_id out,   @ram_id_Empresa out 
exec sp_ArbConvertId @@trans_id, @trans_id out, @ram_id_Transporte out 
exec sp_ArbConvertId @@chof_id,  @chof_id out,  @ram_id_Chofer out 
exec sp_ArbConvertId @@cam_id,   @cam_id out,   @ram_id_Camion out 

exec sp_GetRptId @clienteID out

if @ram_id_Cliente <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Cliente, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Cliente, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Cliente, @clienteID 
  end else 
    set @ram_id_Cliente = 0
end

if @ram_id_Sucursal <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Sucursal, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Sucursal, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Sucursal, @clienteID 
  end else 
    set @ram_id_Sucursal = 0
end


if @ram_id_Empresa <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Empresa, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Empresa, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Empresa, @clienteID 
  end else 
    set @ram_id_Empresa = 0
end

if @ram_id_Transporte <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Transporte, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Transporte, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Transporte, @clienteID 
  end else 
    set @ram_id_Transporte = 0
end

if @ram_id_Chofer <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Chofer, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Chofer, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Chofer, @clienteID 
  end else 
    set @ram_id_Chofer = 0
end

if @ram_id_Camion <> 0 begin

--  exec sp_ArbGetGroups @ram_id_Camion, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_Camion, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_Camion, @clienteID 
  end else 
    set @ram_id_Camion = 0
end

/*- ///////////////////////////////////////////////////////////////////////

FIN PRIMERA PARTE DE ARBOLES

/////////////////////////////////////////////////////////////////////// */

create table #saldo (  cli_id     int, 
                      emp_id     int, 
                      trans_id   int, 
                      chof_id   int, 
                      cam_id     int, 
                      pendiente decimal(18,6)
                    )

if @@bConSaldos <> 0 begin

      insert into #saldo
      
      select 
      
        cli_id,
        emp_id,
        trans_id,
        chof_id,
        cam_id,
        sum(case rv.doct_id
                when 24 then -rv_pendiente
                else          rv_pendiente
            end)
      
      from 
      
        RemitoVenta rv 
      where 
      
                rv_fecha < @@Fini 

            and rv.est_id <> 7
            and round(rv_pendiente,2) > 0
      
            and (
                  exists(select * from EmpresaUsuario where emp_id = rv.emp_id and us_id = @@us_id) or (@@us_id = 1)
                )
            and (
                  exists(select * from UsuarioEmpresa where cli_id = rv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                )

      /* -///////////////////////////////////////////////////////////////////////
      
      INICIO SEGUNDA PARTE DE ARBOLES
      
      /////////////////////////////////////////////////////////////////////// */
      
      and   (rv.cli_id  = @cli_id  or @cli_id=0)
      and   (rv.suc_id  = @suc_id  or @suc_id=0)
      and   (rv.emp_id  = @emp_id  or @emp_id=0) 

      and   (rv.trans_id = @trans_id or @trans_id=0) 
      and   (rv.chof_id  = @chof_id  or @chof_id=0) 
      and   (rv.cam_id   = @cam_id   or @cam_id=0) 
      
      -- Arboles
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
       rptarb_cliente = @clienteID
                        and  tbl_id = 28 
                        and  rptarb_hojaid = rv.cli_id
                       ) 
                 )
              or 
                 (@ram_id_Cliente = 0)
             )
      
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 1007 
                        and  rptarb_hojaid = rv.suc_id
                       ) 
                 )
              or 
                 (@ram_id_Sucursal = 0)
             )
      
      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 1018 
                        and  rptarb_hojaid = rv.emp_id
                       ) 
                 )
              or 
                 (@ram_id_Empresa = 0)
             )

      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 34
                        and  rptarb_hojaid = rv.trans_id
                       ) 
                 )
              or 
                 (@ram_id_Transporte = 0)
             )

      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 1001
                        and  rptarb_hojaid = rv.chof_id
                       ) 
                 )
              or 
                 (@ram_id_Chofer = 0)
             )

      and   (
                (exists(select rptarb_hojaid 
                        from rptArbolRamaHoja 
                        where
                             rptarb_cliente = @clienteID
                        and  tbl_id = 1004
                        and  rptarb_hojaid = rv.cam_id
                       ) 
                 )
              or 
                 (@ram_id_Camion = 0)
             )

      group by
            emp_id,
            cli_id,
            trans_id,
            chof_id,
            cam_id      
end

/*-///////////////////////////////////////////////////////////////////////

  SELECT DE RETORNO

/////////////////////////////////////////////////////////////////////// */

/*-///////////////////////////////////////////////////////////////////////

  SALDO

/////////////////////////////////////////////////////////////////////// */

    select 
    
      0                          as comp_id,
      0                         as doct_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      emp_nombre                as Empresa, 
      IsNull(trans_nombre,'Sin Transporte')              
                                as Transporte,
      trans_codigo              as [Codigo Trans.],
      IsNull(chof_nombre,'Sin Chofer')                
                                as Chofer,
      chof_codigo               as [Codigo Chofer],
      IsNull(cam_patente,'Sin Camion')                
                                as Camion,
      cam_codigo                as [Codigo Camion],
    
      null                      as Fecha,
      'Saldo Inicial'           as Documento,
      ''                        as Comprobante,
      0                         as Numero,
      ''                        as Moneda,
      0                         as Total,
      sum(pendiente)             as Pendiente,
      ''                        as Legajo,
    
      0                         as Orden
    
    from #saldo s         inner join Cliente cli                     on s.cli_id   = cli.cli_id
                          inner join Empresa emp                    on s.emp_id   = emp.emp_id 
                          left  join Transporte trans               on s.trans_id = trans.trans_id 
                          left  join Chofer chof                    on s.chof_id  = chof.chof_id 
                          left  join Camion cam                     on s.cam_id   = cam.cam_id     
    group by
    
    trans_nombre,
    trans_codigo,
    chof_nombre,
    chof_codigo,
    cam_patente,
    cam_codigo,
    emp_nombre,
    cli_nombre,
    cli_codigo

    having (sum(pendiente) <> 0 or @@bSaldosCero <> 0)
    
union all

    /*-///////////////////////////////////////////////////////////////////////
    
      REMITOS DE VENTA
    
    /////////////////////////////////////////////////////////////////////// */
    
    select     

      rv.rv_id                  as comp_id,
      rv.doct_id                as doct_id,
      cli_codigo                as Codigo,
      cli_nombre                as Cliente,
      emp_nombre                as Empresa, 
      IsNull(trans_nombre,'Sin Transporte')              
                                as Transporte,
      trans_codigo              as [Codigo Trans.],
      IsNull(chof_nombre,'Sin Chofer')                
                                as Chofer,
      chof_codigo               as [Codigo Chofer],
      IsNull(cam_patente,'Sin Camion')                
                                as Camion,
      cam_codigo                as [Codigo Camion],
    
      rv_fecha                  as Fecha,
      doc_nombre                as Documento,
      rv_nrodoc                 as Comprobante,
      rv_numero                 as Numero,
      mon_nombre                as Moneda,
      case rv.doct_id 
            when 24 then -rv_total
            else          rv_total
      end                       as Total,
      case rv.doct_id 
            when 24 then -rv_pendiente
            else          rv_pendiente
      end                       as Pendiente,
      lgj_titulo                as Legajo,
    
      1                         as Orden
    
    from
    
      RemitoVenta rv           inner join Cliente cli                     on rv.cli_id       = cli.cli_id
                              inner join Sucursal                       on rv.suc_id      = Sucursal.suc_id
                              inner join Documento docrv                on rv.doc_id      = docrv.doc_id
                              inner join Empresa emp                    on docrv.emp_id   = emp.emp_id 
                              inner join Moneda m                       on docrv.mon_id   = m.mon_id
                              left  join Legajo lgjrv                   on rv.lgj_id      = lgjrv.lgj_id
                              left  join Transporte trans               on rv.trans_id     = trans.trans_id 
                              left  join Chofer chof                    on rv.chof_id      = chof.chof_id 
                              left  join Camion cam                     on rv.cam_id       = cam.cam_id     
    where 
    
              rv_fecha >= @@Fini
          and  rv_fecha <= @@Ffin 
    
          and rv.est_id <> 7
    
          and (
                exists(select * from EmpresaUsuario where emp_id = docrv.emp_id and us_id = @@us_id) or (@@us_id = 1)
              )
          and (
                exists(select * from UsuarioEmpresa where cli_id = cli.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
              )

    /* -///////////////////////////////////////////////////////////////////////
    
    INICIO SEGUNDA PARTE DE ARBOLES
    
    /////////////////////////////////////////////////////////////////////// */
    
    and   (cli.cli_id       = @cli_id   or @cli_id=0)
    and   (Sucursal.suc_id   = @suc_id   or @suc_id=0)
    and   (emp.emp_id       = @emp_id   or @emp_id=0) 

    and   (rv.trans_id = @trans_id or @trans_id=0) 
    and   (rv.chof_id  = @chof_id  or @chof_id=0) 
    and   (rv.cam_id   = @cam_id   or @cam_id=0) 
    
    -- Arboles
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 28 
                      and  rptarb_hojaid = rv.cli_id
                     ) 
               )
            or 
               (@ram_id_Cliente = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1007 
                      and  rptarb_hojaid = rv.suc_id
                     ) 
               )
            or 
               (@ram_id_Sucursal = 0)
           )
    
    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1018 
                      and  rptarb_hojaid = docrv.emp_id
                     ) 
               )
            or 
               (@ram_id_Empresa = 0)
           )

    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 34
                      and  rptarb_hojaid = rv.trans_id
                     ) 
               )
            or 
               (@ram_id_Transporte = 0)
           )

    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1001
                      and  rptarb_hojaid = rv.chof_id
                     ) 
               )
            or 
               (@ram_id_Chofer = 0)
           )

    and   (
              (exists(select rptarb_hojaid 
                      from rptArbolRamaHoja 
                      where
                           rptarb_cliente = @clienteID
                      and  tbl_id = 1004
                      and  rptarb_hojaid = rv.cam_id
                     ) 
               )
            or 
               (@ram_id_Camion = 0)
           )

--///////////////////////////////////////////////////////////////

order by

  Transporte, Chofer, Camion, Cliente, Orden, Empresa, Fecha, Comprobante

end

GO