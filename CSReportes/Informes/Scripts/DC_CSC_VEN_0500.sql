/*---------------------------------------------------------------------
Nombre: Ranking de Ventas por Cliente (sin empresa) (Remitos)
---------------------------------------------------------------------*/
/*  

Para testear:

DC_CSC_VEN_0500 1, '20060501','20060531','0', '0','0','0','0','0','0',0

*/
if exists (select * from sysobjects where id = object_id(N'[dbo].[DC_CSC_VEN_0500]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DC_CSC_VEN_0500]

go
create procedure DC_CSC_VEN_0500 (

  @@us_id        int,
  @@Fini          datetime,
  @@Ffin          datetime,

  @@pro_id           varchar(255),
  @@cli_id           varchar(255),
  @@ven_id           varchar(255),
  @@cico_id           varchar(255),
  @@doc_id           varchar(255),
  @@mon_id           varchar(255),
  @@emp_id           varchar(255)

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

declare @pro_id       int
declare @cli_id       int
declare @ven_id       int
declare @cico_id      int
declare @doc_id       int
declare @mon_id       int
declare @emp_id       int

declare @ram_id_provincia        int
declare @ram_id_cliente          int
declare @ram_id_vendedor         int
declare @ram_id_circuitoContable int
declare @ram_id_documento        int
declare @ram_id_moneda           int
declare @ram_id_empresa          int

declare @clienteID int
declare @IsRaiz    tinyint

exec sp_ArbConvertId @@pro_id,       @pro_id out,        @ram_id_provincia out
exec sp_ArbConvertId @@cli_id,       @cli_id out,        @ram_id_cliente out
exec sp_ArbConvertId @@ven_id,       @ven_id out,        @ram_id_vendedor out
exec sp_ArbConvertId @@cico_id,      @cico_id out,       @ram_id_circuitoContable out
exec sp_ArbConvertId @@doc_id,       @doc_id out,        @ram_id_documento out
exec sp_ArbConvertId @@mon_id,       @mon_id out,        @ram_id_moneda out
exec sp_ArbConvertId @@emp_id,       @emp_id out,        @ram_id_empresa out

exec sp_GetRptId @clienteID out

if @ram_id_provincia <> 0 begin

--  exec sp_ArbGetGroups @ram_id_provincia, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_provincia, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_provincia, @clienteID 
  end else 
    set @ram_id_provincia = 0
end

if @ram_id_cliente <> 0 begin

--  exec sp_ArbGetGroups @ram_id_cliente, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_cliente, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_cliente, @clienteID 
  end else 
    set @ram_id_cliente = 0
end

if @ram_id_vendedor <> 0 begin

--  exec sp_ArbGetGroups @ram_id_vendedor, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_vendedor, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_vendedor, @clienteID 
  end else 
    set @ram_id_vendedor = 0
end

if @ram_id_circuitoContable <> 0 begin

--  exec sp_ArbGetGroups @ram_id_circuitoContable, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_circuitoContable, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_circuitoContable, @clienteID 
  end else 
    set @ram_id_circuitoContable = 0
end

if @ram_id_documento <> 0 begin

--  exec sp_ArbGetGroups @ram_id_documento, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_documento, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_documento, @clienteID 
  end else 
    set @ram_id_documento = 0
end

if @ram_id_moneda <> 0 begin

--  exec sp_ArbGetGroups @ram_id_moneda, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_moneda, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_moneda, @clienteID 
  end else 
    set @ram_id_moneda = 0
end

if @ram_id_empresa <> 0 begin

--  exec sp_ArbGetGroups @ram_id_empresa, @clienteID, @@us_id

  exec sp_ArbIsRaiz @ram_id_empresa, @IsRaiz out
  if @IsRaiz = 0 begin
    exec sp_ArbGetAllHojas @ram_id_empresa, @clienteID 
  end else 
    set @ram_id_empresa = 0
end


/*- //////////////////////////////////////////////////////////////////////////

  SALDO INICIAL

////////////////////////////////////////////////////////////////////////// */


  /*- ///////////////////////////////////////////////////////////////////////
  
  TABLA TEMPORAL CON TODOS LOS MOVIMIENTOS
  
  /////////////////////////////////////////////////////////////////////// */
  
  create table #t_DC_CSC_VEN_0500_S(
                                  cli_id        int,
                                  rv_neto        decimal(18,6),
                                  rv_iva        decimal(18,6),
                                  rv_total      decimal(18,6)
                                  )
  
  insert into #t_DC_CSC_VEN_0500_s
  
      /*- ///////////////////////////////////////////////////////////////////////
      
      REMITOS
      
      /////////////////////////////////////////////////////////////////////// */
          select
              cli.cli_id,
              sum (
                    case 
  
                      when     rv.doct_id = 24
                          and rv_total <> 0
                                 then  -rv_neto
  
                      when     rv.doct_id <> 24
                          and rv_total <> 0
                                 then    rv_neto       
  
                      else               0
                    end
                  )                    as Neto,
              sum (
                    case 
  
                      when     rv.doct_id = 24 
                          and rv_total <> 0      
                                  then  - rv_ivari+rv_ivarni
  
                      when     rv.doct_id <> 24 
                          and rv_total <> 0      
                                  then   rv_ivari+rv_ivarni
  
                      else              0
                    end
                  )                    as IVA,
              sum (
                    case 
  
                      when     rv.doct_id = 24      
                          and  rv_total <> 0
                                  then  - rv_total
  
  
                      when     rv.doct_id <> 24      
                          and  rv_total <> 0
                                  then    rv_total 
  
                      else                0
                    end
                  )                    as Total
          
          from 
          
            RemitoVenta rv  inner join cliente   cli         on rv.cli_id   = cli.cli_id 
                            inner join documento doc         on rv.doc_id   = doc.doc_id
          
          where 
          
                    rv_fecha < @@Fini
                and rv.est_id <> 7
          
                and (
                      exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
                    )
                and (
                      exists(select * from UsuarioEmpresa where cli_id = rv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                    )
  
          /* -///////////////////////////////////////////////////////////////////////
          
          INICIO SEGUNDA PARTE DE ARBOLES
          
          /////////////////////////////////////////////////////////////////////// */
          
          and   (cli.pro_id  = @pro_id   or @pro_id=0)
          and   (rv.cli_id   = @cli_id   or @cli_id=0)
          and   (cli.ven_id  = @ven_id   or @ven_id=0)
          and   (doc.cico_id = @cico_id  or @cico_id=0)
          and   (rv.doc_id   = @doc_id   or @doc_id=0)
          and   (doc.mon_id  = @mon_id   or @mon_id=0)
          and   (doc.emp_id  = @emp_id   or @emp_id=0)
          
          -- Arboles
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 6 
                            and  rptarb_hojaid = cli.pro_id
                           ) 
                     )
                  or 
                     (@ram_id_provincia = 0)
                 )
          
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
                     (@ram_id_cliente = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 15 
                            and  rptarb_hojaid = cli.ven_id
                           ) 
                     )
                  or 
                     (@ram_id_vendedor = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1016 
                            and  rptarb_hojaid = doc.cico_id
                           ) 
                     )
                  or 
                     (@ram_id_circuitoContable = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 4001 
                            and  rptarb_hojaid = rv.doc_id
                           ) 
                     )
                  or 
                     (@ram_id_documento = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 12 
                            and  rptarb_hojaid = doc.mon_id
                           ) 
                     )
                  or 
                     (@ram_id_moneda = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1018 
                            and  rptarb_hojaid = doc.emp_id
                           ) 
                     )
                  or 
                     (@ram_id_empresa = 0)
                 )
          
          group by
          
              cli.cli_id
      
      union all
      
      /*- ///////////////////////////////////////////////////////////////////////
      
      NOTAS DE CREDITO / DEBITO
      
      /////////////////////////////////////////////////////////////////////// */
          select
              cli.cli_id,
              sum (
                    case fv.doct_id
                      when 7      then -fv_neto                   
                      else              fv_neto
                    end
                  )                    as Neto,
              sum (
                    case fv.doct_id
                      when 7      then  -(fv_ivari+fv_ivarni)
                      else                fv_ivari+fv_ivarni
                    end
                  )                    as IVA,
              sum (
                    case fv.doct_id
                      when 7      then  -fv_total                
                      else               fv_total
                    end
                  )                    as Total
          
          from 
          
            facturaventa fv inner join cliente   cli         on fv.cli_id   = cli.cli_id 
                            inner join documento doc         on fv.doc_id   = doc.doc_id
          
          where 
          
                    fv_fecha < @@Fini
                and fv.est_id <> 7
  
                and fv.doct_id in (7,9)
          
                and (
                      exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
                    )
                and (
                      exists(select * from UsuarioEmpresa where cli_id = fv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                    )
  
          /* -///////////////////////////////////////////////////////////////////////
          
          INICIO SEGUNDA PARTE DE ARBOLES
          
          /////////////////////////////////////////////////////////////////////// */
          
          and   (cli.pro_id  = @pro_id   or @pro_id=0)
          and   (fv.cli_id   = @cli_id   or @cli_id=0)
          and   (cli.ven_id  = @ven_id   or @ven_id=0)
          and   (doc.cico_id = @cico_id  or @cico_id=0)
          and   (fv.doc_id   = @doc_id   or @doc_id=0)
          and   (fv.mon_id   = @mon_id   or @mon_id=0)
          and   (doc.emp_id  = @emp_id   or @emp_id=0)
          
          -- Arboles
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 6 
                            and  rptarb_hojaid = cli.pro_id
                           ) 
                     )
                  or 
                     (@ram_id_provincia = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 28 
                            and  rptarb_hojaid = fv.cli_id
                           ) 
                     )
                  or 
                     (@ram_id_cliente = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 15 
                            and  rptarb_hojaid = cli.ven_id
                           ) 
                     )
                  or 
                     (@ram_id_vendedor = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1016 
                            and  rptarb_hojaid = doc.cico_id
                           ) 
                     )
                  or 
                     (@ram_id_circuitoContable = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 4001 
                            and  rptarb_hojaid = fv.doc_id
                           ) 
                     )
                  or 
                     (@ram_id_documento = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 12 
                            and  rptarb_hojaid = fv.mon_id
                           ) 
                     )
                  or 
                     (@ram_id_moneda = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1018 
                            and  rptarb_hojaid = doc.emp_id
                           ) 
                     )
                  or 
                     (@ram_id_empresa = 0)
                 )
          
          group by
          
              cli.cli_id
  
      union all
      
      /*- ///////////////////////////////////////////////////////////////////////
      
      FACTURA
      
      /////////////////////////////////////////////////////////////////////// */
          select
              cli.cli_id,
              sum (
                    case fv.doct_id
                      when 7      then -fv_neto                   
                      else              fv_neto
                    end
                  )                    as Neto,
              sum (
                    case fv.doct_id
                      when 7      then  -(fv_ivari+fv_ivarni)
                      else                fv_ivari+fv_ivarni
                    end
                  )                    as IVA,
              sum (
                    case fv.doct_id
                      when 7      then  -fv_total                
                      else               fv_total
                    end
                  )                    as Total
          
          from 
          
            facturaventa fv inner join cliente   cli         on fv.cli_id   = cli.cli_id 
                            inner join documento doc         on fv.doc_id   = doc.doc_id
          
          where 
          
                    fv_fecha < @@Fini
                and fv.est_id <> 7
  
                and fv.doct_id = 1
  
                and not exists(select * from FacturaVentaItem fvi
                                              inner join RemitoFacturaVenta rfv
                                                on   (  
                                                           fv.fv_id  = fvi.fv_id
                                                       and fv.fv_fecha >= @@Fini
                                                       and fv.fv_fecha <= @@Ffin 
                                                     )
                                                   and    fvi.fvi_id = rfv.fvi_id
  
                                                  and   (cli.pro_id  = @pro_id   or @pro_id=0)
                                                  and   (fv.cli_id   = @cli_id   or @cli_id=0)
                                                  and   (cli.ven_id   = @ven_id   or @ven_id=0)
                                                  and   (doc.cico_id = @cico_id  or @cico_id=0)
                                                  and   (fv.doc_id   = @doc_id   or @doc_id=0)
                                                  and   (fv.mon_id   = @mon_id   or @mon_id=0)
                                                  and   (doc.emp_id  = @emp_id   or @emp_id=0)
                                                  
                                                  -- Arboles
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 6 
                                                                    and  rptarb_hojaid = cli.pro_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_provincia = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 28 
                                                                    and  rptarb_hojaid = fv.cli_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_cliente = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 15 
                                                                    and  rptarb_hojaid = cli.ven_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_vendedor = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 1016 
                                                                    and  rptarb_hojaid = doc.cico_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_circuitoContable = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 4001 
                                                                    and  rptarb_hojaid = fv.doc_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_documento = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 12 
                                                                    and  rptarb_hojaid = fv.mon_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_moneda = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 1018 
                                                                    and  rptarb_hojaid = doc.emp_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_empresa = 0)
                                                         )                                        
                              )
          
                and (
                      exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
                    )
                and (
                      exists(select * from UsuarioEmpresa where cli_id = fv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                    )
  
          /* -///////////////////////////////////////////////////////////////////////
          
          INICIO SEGUNDA PARTE DE ARBOLES
          
          /////////////////////////////////////////////////////////////////////// */
          
          and   (cli.pro_id  = @pro_id   or @pro_id=0)
          and   (fv.cli_id   = @cli_id   or @cli_id=0)
          and   (cli.ven_id   = @ven_id   or @ven_id=0)
          and   (doc.cico_id = @cico_id  or @cico_id=0)
          and   (fv.doc_id   = @doc_id   or @doc_id=0)
          and   (fv.mon_id   = @mon_id   or @mon_id=0)
          and   (doc.emp_id  = @emp_id   or @emp_id=0)
          
          -- Arboles
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 6 
                            and  rptarb_hojaid = cli.pro_id
                           ) 
                     )
                  or 
                     (@ram_id_provincia = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 28 
                            and  rptarb_hojaid = fv.cli_id
                           ) 
                     )
                  or 
                     (@ram_id_cliente = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 15 
                            and  rptarb_hojaid = cli.ven_id
                           ) 
                     )
                  or 
                     (@ram_id_vendedor = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1016 
                            and  rptarb_hojaid = doc.cico_id
                           ) 
                     )
                  or 
                     (@ram_id_circuitoContable = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 4001 
                            and  rptarb_hojaid = fv.doc_id
                           ) 
                     )
                  or 
                     (@ram_id_documento = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 12 
                            and  rptarb_hojaid = fv.mon_id
                           ) 
                     )
                  or 
                     (@ram_id_moneda = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1018 
                            and  rptarb_hojaid = doc.emp_id
                           ) 
                     )
                  or 
                     (@ram_id_empresa = 0)
                 )
          
          group by
          
              cli.cli_id

/*- //////////////////////////////////////////////////////////////////////////

  VENTAS DEL PERIODO

////////////////////////////////////////////////////////////////////////// */

  /*- ///////////////////////////////////////////////////////////////////////
  
  TABLA TEMPORAL CON TODOS LOS MOVIMIENTOS
  
  /////////////////////////////////////////////////////////////////////// */
  
  create table #t_DC_CSC_VEN_0500(
                                  cli_id        int,
                                  cli_codigo     varchar(50),
                                  cli_nombre    varchar(255),
                                  rv_neto        decimal(18,6),
                                  rv_iva        decimal(18,6),
                                  rv_total      decimal(18,6)
                                  )
  
  insert into #t_DC_CSC_VEN_0500
  
      /*- ///////////////////////////////////////////////////////////////////////
      
      REMITOS
      
      /////////////////////////////////////////////////////////////////////// */
          select
              cli.cli_id,
              cli_codigo               as Codigo,
              cli_nombre              as Cliente,
              sum (
                    case 
  
                      when     rv.doct_id = 24
                          and rv_total <> 0
                                 then  -rv_neto
  
                      when     rv.doct_id <> 24
                          and rv_total <> 0
                                 then    rv_neto       
  
                      else               0
                    end
                  )                    as Neto,
              sum (
                    case 
  
                      when     rv.doct_id = 24 
                          and rv_total <> 0      
                                  then  - rv_ivari+rv_ivarni
  
                      when     rv.doct_id <> 24 
                          and rv_total <> 0      
                                  then   rv_ivari+rv_ivarni
  
                      else              0
                    end
                  )                    as IVA,
              sum (
                    case 
  
                      when     rv.doct_id = 24      
                          and  rv_total <> 0
                                  then  - rv_total
  
  
                      when     rv.doct_id <> 24      
                          and  rv_total <> 0
                                  then    rv_total 
  
                      else                0
                    end
                  )                    as Total
          
          from 
          
            RemitoVenta rv  inner join cliente   cli         on rv.cli_id   = cli.cli_id 
                            inner join documento doc         on rv.doc_id   = doc.doc_id
          
          where 
          
                    rv_fecha >= @@Fini
                and  rv_fecha <= @@Ffin 
                and rv.est_id <> 7
          
                and (
                      exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
                    )
                and (
                      exists(select * from UsuarioEmpresa where cli_id = rv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                    )
  
          /* -///////////////////////////////////////////////////////////////////////
          
          INICIO SEGUNDA PARTE DE ARBOLES
          
          /////////////////////////////////////////////////////////////////////// */
          
          and   (cli.pro_id  = @pro_id   or @pro_id=0)
          and   (rv.cli_id   = @cli_id   or @cli_id=0)
          and   (cli.ven_id  = @ven_id   or @ven_id=0)
          and   (doc.cico_id = @cico_id  or @cico_id=0)
          and   (rv.doc_id   = @doc_id   or @doc_id=0)
          and   (doc.mon_id  = @mon_id   or @mon_id=0)
          and   (doc.emp_id  = @emp_id   or @emp_id=0)
          
          -- Arboles
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 6 
                            and  rptarb_hojaid = cli.pro_id
                           ) 
                     )
                  or 
                     (@ram_id_provincia = 0)
                 )
          
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
                     (@ram_id_cliente = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 15 
                            and  rptarb_hojaid = cli.ven_id
                           ) 
                     )
                  or 
                     (@ram_id_vendedor = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1016 
                            and  rptarb_hojaid = doc.cico_id
                           ) 
                     )
                  or 
                     (@ram_id_circuitoContable = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 4001 
                            and  rptarb_hojaid = rv.doc_id
                           ) 
                     )
                  or 
                     (@ram_id_documento = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 12 
                            and  rptarb_hojaid = doc.mon_id
                           ) 
                     )
                  or 
                     (@ram_id_moneda = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1018 
                            and  rptarb_hojaid = doc.emp_id
                           ) 
                     )
                  or 
                     (@ram_id_empresa = 0)
                 )
          
          group by
          
              cli.cli_id,
              cli_codigo,
              cli_nombre
      
      union all
      
      /*- ///////////////////////////////////////////////////////////////////////
      
      NOTAS DE CREDITO / DEBITO
      
      /////////////////////////////////////////////////////////////////////// */
          select
              cli.cli_id,
              cli_codigo               as Codigo,
              cli_nombre              as Cliente,
              sum (
                    case fv.doct_id
                      when 7      then -fv_neto                   
                      else              fv_neto
                    end
                  )                    as Neto,
              sum (
                    case fv.doct_id
                      when 7      then  -(fv_ivari+fv_ivarni)
                      else                fv_ivari+fv_ivarni
                    end
                  )                    as IVA,
              sum (
                    case fv.doct_id
                      when 7      then  -fv_total                
                      else               fv_total
                    end
                  )                    as Total
          
          from 
          
            facturaventa fv inner join cliente   cli         on fv.cli_id   = cli.cli_id 
                            inner join documento doc         on fv.doc_id   = doc.doc_id
          
          where 
          
                    fv_fecha >= @@Fini
                and  fv_fecha <= @@Ffin 
                and fv.est_id <> 7
  
                and fv.doct_id in (7,9)
          
                and (
                      exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
                    )
                and (
                      exists(select * from UsuarioEmpresa where cli_id = fv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                    )
  
          /* -///////////////////////////////////////////////////////////////////////
          
          INICIO SEGUNDA PARTE DE ARBOLES
          
          /////////////////////////////////////////////////////////////////////// */
          
          and   (cli.pro_id  = @pro_id   or @pro_id=0)
          and   (fv.cli_id   = @cli_id   or @cli_id=0)
          and   (cli.ven_id  = @ven_id   or @ven_id=0)
          and   (doc.cico_id = @cico_id  or @cico_id=0)
          and   (fv.doc_id   = @doc_id   or @doc_id=0)
          and   (fv.mon_id   = @mon_id   or @mon_id=0)
          and   (doc.emp_id  = @emp_id   or @emp_id=0)
          
          -- Arboles
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 6 
                            and  rptarb_hojaid = cli.pro_id
                           ) 
                     )
                  or 
                     (@ram_id_provincia = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 28 
                            and  rptarb_hojaid = fv.cli_id
                           ) 
                     )
                  or 
                     (@ram_id_cliente = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 15 
                            and  rptarb_hojaid = cli.ven_id
                           ) 
                     )
                  or 
                     (@ram_id_vendedor = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1016 
                            and  rptarb_hojaid = doc.cico_id
                           ) 
                     )
                  or 
                     (@ram_id_circuitoContable = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 4001 
                            and  rptarb_hojaid = fv.doc_id
                           ) 
                     )
                  or 
                     (@ram_id_documento = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 12 
                            and  rptarb_hojaid = fv.mon_id
                           ) 
                     )
                  or 
                     (@ram_id_moneda = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1018 
                            and  rptarb_hojaid = doc.emp_id
                           ) 
                     )
                  or 
                     (@ram_id_empresa = 0)
                 )
          
          group by
          
              cli.cli_id,
              cli_codigo,
              cli_nombre
  
      union all
      
      /*- ///////////////////////////////////////////////////////////////////////
      
      FACTURA
      
      /////////////////////////////////////////////////////////////////////// */
          select
              cli.cli_id,
              cli_codigo               as Codigo,
              cli_nombre              as Cliente,
              sum (
                    case fv.doct_id
                      when 7      then -fv_neto                   
                      else              fv_neto
                    end
                  )                    as Neto,
              sum (
                    case fv.doct_id
                      when 7      then  -(fv_ivari+fv_ivarni)
                      else                fv_ivari+fv_ivarni
                    end
                  )                    as IVA,
              sum (
                    case fv.doct_id
                      when 7      then  -fv_total                
                      else               fv_total
                    end
                  )                    as Total
          
          from 
          
            facturaventa fv inner join cliente   cli         on fv.cli_id   = cli.cli_id 
                            inner join documento doc         on fv.doc_id   = doc.doc_id
          
          where 
          
                    fv_fecha >= @@Fini
                and  fv_fecha <= @@Ffin 
                and fv.est_id <> 7
  
                and fv.doct_id = 1
  
                and not exists(select * from FacturaVentaItem fvi
                                              inner join RemitoFacturaVenta rfv
                                                on   (  
                                                           fv.fv_id  = fvi.fv_id
                                                       and fv.fv_fecha >= @@Fini
                                                       and fv.fv_fecha <= @@Ffin 
                                                     )
                                                   and    fvi.fvi_id = rfv.fvi_id
  
                                                  and   (cli.pro_id  = @pro_id   or @pro_id=0)
                                                  and   (fv.cli_id   = @cli_id   or @cli_id=0)
                                                  and   (cli.ven_id   = @ven_id   or @ven_id=0)
                                                  and   (doc.cico_id = @cico_id  or @cico_id=0)
                                                  and   (fv.doc_id   = @doc_id   or @doc_id=0)
                                                  and   (fv.mon_id   = @mon_id   or @mon_id=0)
                                                  and   (doc.emp_id  = @emp_id   or @emp_id=0)
                                                  
                                                  -- Arboles
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 6 
                                                                    and  rptarb_hojaid = cli.pro_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_provincia = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 28 
                                                                    and  rptarb_hojaid = fv.cli_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_cliente = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 15 
                                                                    and  rptarb_hojaid = cli.ven_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_vendedor = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 1016 
                                                                    and  rptarb_hojaid = doc.cico_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_circuitoContable = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 4001 
                                                                    and  rptarb_hojaid = fv.doc_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_documento = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 12 
                                                                    and  rptarb_hojaid = fv.mon_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_moneda = 0)
                                                         )
                                                  
                                                  and   (
                                                            (exists(select rptarb_hojaid 
                                                                    from rptArbolRamaHoja 
                                                                    where
                                                                         rptarb_cliente = @clienteID
                                                                    and  tbl_id = 1018 
                                                                    and  rptarb_hojaid = doc.emp_id
                                                                   ) 
                                                             )
                                                          or 
                                                             (@ram_id_empresa = 0)
                                                         )                                        
                              )
          
                and (
                      exists(select * from EmpresaUsuario where emp_id = doc.emp_id and us_id = @@us_id) or (@@us_id = 1)
                    )
                and (
                      exists(select * from UsuarioEmpresa where cli_id = fv.cli_id and us_id = @@us_id) or (@us_empresaEx = 0)
                    )
  
          /* -///////////////////////////////////////////////////////////////////////
          
          INICIO SEGUNDA PARTE DE ARBOLES
          
          /////////////////////////////////////////////////////////////////////// */
          
          and   (cli.pro_id  = @pro_id   or @pro_id=0)
          and   (fv.cli_id   = @cli_id   or @cli_id=0)
          and   (cli.ven_id   = @ven_id   or @ven_id=0)
          and   (doc.cico_id = @cico_id  or @cico_id=0)
          and   (fv.doc_id   = @doc_id   or @doc_id=0)
          and   (fv.mon_id   = @mon_id   or @mon_id=0)
          and   (doc.emp_id  = @emp_id   or @emp_id=0)
          
          -- Arboles
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 6 
                            and  rptarb_hojaid = cli.pro_id
                           ) 
                     )
                  or 
                     (@ram_id_provincia = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 28 
                            and  rptarb_hojaid = fv.cli_id
                           ) 
                     )
                  or 
                     (@ram_id_cliente = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 15 
                            and  rptarb_hojaid = cli.ven_id
                           ) 
                     )
                  or 
                     (@ram_id_vendedor = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1016 
                            and  rptarb_hojaid = doc.cico_id
                           ) 
                     )
                  or 
                     (@ram_id_circuitoContable = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 4001 
                            and  rptarb_hojaid = fv.doc_id
                           ) 
                     )
                  or 
                     (@ram_id_documento = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 12 
                            and  rptarb_hojaid = fv.mon_id
                           ) 
                     )
                  or 
                     (@ram_id_moneda = 0)
                 )
          
          and   (
                    (exists(select rptarb_hojaid 
                            from rptArbolRamaHoja 
                            where
                                 rptarb_cliente = @clienteID
                            and  tbl_id = 1018 
                            and  rptarb_hojaid = doc.emp_id
                           ) 
                     )
                  or 
                     (@ram_id_empresa = 0)
                 )
          
          group by
          
              cli.cli_id,
              cli_codigo,
              cli_nombre


/*- ///////////////////////////////////////////////////////////////////////

VENTAS TOTALES POR EMPRESA

/////////////////////////////////////////////////////////////////////// */

create table #t_DC_CSC_VEN_0500_t (
                              
                              rv_neto   decimal(18,6),
                              rv_iva    decimal(18,6),
                              rv_total   decimal(18,6)
                            )

insert into #t_DC_CSC_VEN_0500_t 

  select

      sum (rv_neto)            as Neto,
      sum (rv_iva)            as IVA,
      sum (rv_total)          as Total
  
  from #t_DC_CSC_VEN_0500

  
/*- ///////////////////////////////////////////////////////////////////////

VENTAS TOTALES POR VENDEDOR 

/////////////////////////////////////////////////////////////////////// */

  select
      c.ven_id,
      1                         as orden_id,
      ven_nombre                as Vendedor,
      t1.cli_codigo              as Codigo,
      t1.cli_nombre              as Cliente,

      -- Saldo
      --
      IsNull(( select sum(rv_total) from #t_DC_CSC_VEN_0500_s
        where cli_id = t1.cli_id),0)
      - IsNull(( select sum(cobz_total) from Cobranza
          where cli_id = t1.cli_id
          and  cobz_fecha < @@Fini),0)      as Saldo,

      ------------------------------------------------

      sum (t1.rv_neto)        as Neto,
      sum (t1.rv_iva)          as IVA,
      0                       as [Otros Impuestos],

      sum (t1.rv_total)        as Ventas,

      ( select sum(cobz_total) from Cobranza
        where cli_id = t1.cli_id
          and  cobz_fecha between @@Fini and @@Ffin)          
                                          as Cobrado,

      ( select cli_creditoctacte from Cliente
        where cli_id = t1.cli_id)          as Credito,

      -- Deuda
      --
      IsNull(( select sum(rv_total) from #t_DC_CSC_VEN_0500_s
        where cli_id = t1.cli_id),0)
      - IsNull(( select sum(cobz_total) from Cobranza
          where cli_id = t1.cli_id
          and  cobz_fecha < @@Fini),0)

      + sum(t1.rv_total)

      - ( select sum(cobz_total) from Cobranza
          where cli_id = t1.cli_id
          and  cobz_fecha between @@Fini and @@Ffin)
                                          as Deuda,

      ------------------------------------------------

      sum (t1.rv_neto)/t2.rv_neto          as [Neto %],
      case 
          when t2.rv_iva = 0 then 0
          else                    sum (t1.rv_iva)/t2.rv_iva            
      end                                 as [IVA %],
      0                                   as [Otros Impuestos %],
      sum (t1.rv_total)/t2.rv_total        as [Total %]
  
  from   #t_DC_CSC_VEN_0500 t1 inner join Cliente c     on t1.cli_id = c.cli_id
                              inner join Vendedor ven  on c.ven_id  = ven.ven_id,
        #t_DC_CSC_VEN_0500_t t2

  group by
    
        t1.cli_id,
        t1.cli_codigo,
        t1.cli_nombre,
        c.ven_id,
        ven_nombre,
        t2.rv_neto,
        t2.rv_iva,
        t2.rv_total

  order by Ventas desc

end
go

