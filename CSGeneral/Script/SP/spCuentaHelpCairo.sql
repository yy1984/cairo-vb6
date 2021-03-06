if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spCuentaHelpCairo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spCuentaHelpCairo]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

  spCuentaHelpCairo 1,1,1,'sp%',0,0

  spCuentaHelpCairo 1,1,0, '',0,0,'(cuec_id = 4 or cuec_id = 19)and (emp_id = 1 or emp_id is null)'

  select * from usuario where us_nombre like '%ahidal%'

*/
create procedure spCuentaHelpCairo (
  @@emp_id          int,
  @@us_id           int,
  @@bForAbm         tinyint,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0,
  @@cue_id          int,
  @@filter2          varchar(5000) = ''
)
as
begin

  set nocount on
  declare @sqlstmt varchar(8000)

  if @@check <> 0 begin

    set @sqlstmt =  'select  cue_id,
                            cue_nombre        as Nombre,
                            cue_codigo         as Codigo
                
                    from Cuenta
                
                    where (     cue_nombre = ''' + @@filter + ''' or cue_codigo = ''' + @@filter + '''
                            or (    cue_identificacionexterna = '''+@@filter+''' 
                                and cue_identificacionexterna <> '''')
                          )
                      and activo <> 0 
                      and (cue_id = '+ convert(varchar,@@cue_id) +' or '+ convert(varchar,@@cue_id) +'=0)'

  end else begin

    set @sqlstmt =  'select top 50
                            cue_id,
                            cue_nombre                    as Nombre,
                            cue_codigo                    as Codigo,
                            cue_identificacionexterna      as Codigo2,
                            cue_descrip                   as Descripcion
                
                      from Cuenta
                
                      where (cue_codigo like ''%'+@@filter+'%'' or cue_nombre like ''%'+@@filter+'%'' 
                              or (cue_identificacionexterna like ''%'+@@filter+'%'' and cue_identificacionexterna <> '''')
                              or (cue_descrip like ''%'+@@filter+'%'' and cue_descrip <> ''''))
                      and ('+ convert(varchar,@@bForAbm) +' <> 0 or activo <> 0)'
  end

  if @@filter2 <> '' set @sqlstmt = @sqlstmt + ' and ('+@@filter2+')'

  exec (@sqlstmt)

end

GO
