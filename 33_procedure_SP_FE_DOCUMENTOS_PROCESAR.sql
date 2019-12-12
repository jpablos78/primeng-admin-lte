USE [BIZ_FAC]
GO

IF OBJECT_ID('DBO.SP_FE_DOCUMENTOS_PROCESAR') IS NOT NULL
	DROP PROCEDURE DBO.SP_FE_DOCUMENTOS_PROCESAR
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- AUTHOR......: JUAN PABLO SANCHEZ
-- CREATE DATE.: 29-NOV-2018
-- VERSION.....: 1.0.01
-- DESCRIPTION.: PROCEDIMIENTO QUE DE ACUERDO A LOS PARAMETROS TRAE LOS 
--               DOCUMENTOS QUE VAN A SER PROCESADOS EN LAS DISTINTAS ETAPAS
--               DEL PROCESO DE FACTURACION ELECTRONICA
-- MODIFICACION: 29-NOV-2018
-- COMENTARIOS.: 
-- ============================================================================
-- PARAMETROS
-- @IN_OPERACION.: OPERACION A SER EJECUTADA
-- ============================================================================
CREATE PROCEDURE [dbo].[SP_FE_DOCUMENTOS_PROCESAR]
(
	@IN_CCI_EMPRESA VARCHAR(3) = NULL,
	@IN_CCI_SUCURSAL VARCHAR(6) = NULL,
	@IN_CCI_TIPOCMPR VARCHAR(5) = NULL,
	@IN_NCI_DOCUMENTO NUMERIC = NULL,
	@IN_CES_FE CHAR(1) = NULL,
	@IN_ENVIAR_MAIL CHAR(1) = NULL,
	@IN_GENERAR_PDF CHAR(1) = NULL,
	@IN_OPERACION VARCHAR(3)
)	
AS

DECLARE @W_DFM_FECHA_INICIO DATETIME

SELECT @W_DFM_FECHA_INICIO = DFM_FECHA_INICIO 
FROM BIZ_FAC..TB_FAC_FE_PARAMETROS
WHERE CCI_EMPRESA = @IN_CCI_EMPRESA

-- ============================================================================
-- QFP: QUERY FACTURAS PENDIENTES, VER TODAS LAS FACTURAS PENDIENTES DE UNA 
--      EMPRESA
-- ============================================================================
IF @IN_OPERACION = 'QFP'
BEGIN		
	SELECT F.CCI_EMPRESA,
	F.CCI_SUCURSAL,
	(SELECT TOP 1 DIRECCION FROM BIZ_GEN..TB_SEG_SUCURSAL WHERE CCI_SUCURSAL = F.CCI_SUCURSAL) AS CTX_DIRECCION_SUCURSAL,
	F.NCI_FACTURA AS NCI_DOCUMENTO,
	
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_FACTURA, 'E') AS ESTAB,
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_FACTURA, 'P') AS PTOEMI, 
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_FACTURA, 'SEC') AS SECUENCIAL,
	
	BIZ_FAC.DBO.FU_RETORNA_GUIA_REMISION_FACTURA(F.CCI_EMPRESA, F.CCI_SUCURSAL, F.NCI_FACTURA) AS NCI_GUIA_REM,
	
	RIGHT(REPLICATE('0', 2)+ CAST(DAY(DFM_FECHA) AS VARCHAR(2)), 2) + 
	RIGHT(REPLICATE('0', 2)+ CAST(MONTH(DFM_FECHA) AS VARCHAR(2)), 2) + 
	CAST(YEAR(DFM_FECHA) AS VARCHAR(4)) AS DFM_FECHA_AUX,
	F.CCI_RUC,
	CONVERT(CHAR(10), DFM_FECHA, 103) AS DFM_FECHA,
	REPLACE(REPLACE(LTRIM(RTRIM(C.CTX_DIRECCION)), CHAR(13), ''), CHAR(10), '') AS CTX_DIRECCION,
	ISNULL(C.CTX_TELEFONO, '') AS CTX_TELEFONO,
	ISNULL(C.CTX_MAIL, '') AS CTX_MAIL,
	CASE F.CCI_RUC WHEN '9999999999999' THEN '07' ELSE 
											  CASE C.CTX_SRITDOC WHEN '1' THEN '04'
											  WHEN '2' THEN '05' 
											  WHEN '3' THEN '06' END
											END AS TIPO_IDENTIFICACION,
	F.CCI_CLIENTE,                                            
	CNO_CLIENTE,
	CAST(F.NVA_SUBTOTAL AS NUMERIC(18, 2)) AS NVA_SUBTOTAL,
	CAST(F.NVA_DESCUENTO AS NUMERIC(18, 2)) AS NVA_DESCUENTO,
	CAST(NQT_PORC_IVA AS NUMERIC) AS NQT_PORC_IVA,
	CAST(F.NVA_IVA AS NUMERIC(18, 2)) AS NVA_IVA,
	CAST(F.NVA_TOTAL AS NUMERIC(18, 2)) AS NVA_TOTAL,
	CASE NQT_PORC_IVA WHEN 0 THEN 0 WHEN 12 THEN 2 WHEN 14 THEN 3 END AS CODIGO_PORCENTAJE_IVA,
	F.CES_FE
	FROM BIZ_FAC..TB_FAC_FACTURA F INNER JOIN BIZ_GEN..TB_GEN_CLIPROV C ON
	F.CCI_EMPRESA = C.CCI_EMPRESA
	--AND F.CCI_SUCURSAL = C.CCI_SUCURSAL
	AND F.CCI_CLIENTE = C.CCI_CLIPROV
	WHERE F.CCI_EMPRESA = @IN_CCI_EMPRESA
	--AND F.CCI_SUCURSAL = @IN_CCI_SUCURSAL
	AND F.CCI_TIPOCMPR = 'FAC'
	AND F.NCI_FACTURA = ISNULL(@IN_NCI_DOCUMENTO, F.NCI_FACTURA)
	AND F.DFM_FECHA >= @W_DFM_FECHA_INICIO 
	AND F.CES_FACTURA IS NULL	
	AND F.CES_FE = 'P'	
	ORDER BY F.DFX_REG_FECHA
END

-- ============================================================================
-- QFX: QUERY FACTURAS ELECTRONICAS X PROCESAR, VER INFORMACION DE LAS FACTURAS 
--      DE ACUERDO A SU ESTADO_FE -> CES_FE PARA PROCESARLAS
--      @IN_CES_FE = 'G': TRAER LAS FACTURAS GENERADAS PARA FIRMARLAS
--      @IN_CES_FE = 'F': TRAER LAS FACTURAS FIRMADAS PARA ENVIARLAS
--      @IN_CES_FE = 'E': TRAER LAS FACTURAS ENVIADAS PARA AUTORIZARLAS
--      @IN_CES_FE = 'A': TRAER LAS FACTURAS AUTORIZADAS
-- ============================================================================
IF @IN_OPERACION = 'QFX'
BEGIN
	SELECT F.CCI_EMPRESA,
	F.CCI_SUCURSAL,
	F.CCI_CLIENTE,
	F.NCI_FACTURA AS NCI_DOCUMENTO,
	F.CCI_CLAVE_ACCESO,
	F.CES_FE
	FROM BIZ_FAC..TB_FAC_FACTURA F 
	WHERE F.CCI_EMPRESA = @IN_CCI_EMPRESA	
	AND F.CCI_TIPOCMPR = 'FAC'
	AND F.NCI_FACTURA = ISNULL(@IN_NCI_DOCUMENTO, F.NCI_FACTURA)
	AND F.DFM_FECHA >= @W_DFM_FECHA_INICIO 
	AND F.CES_FACTURA IS NULL	
	AND F.CES_FE = @IN_CES_FE	
	ORDER BY F.DFX_REG_FECHA
END

-- ============================================================================
-- QFD: QUERY FACTURAS GENERAR PDF, VER LAS FACTURAS QUE ESTEN AUTORIZADAS Y 
--      QUE TENGAN EN CAMPO "GENERAR_PDF" IGUAL A "S" PARA GENERAR EL PDF DE 
--      ESE DOCUMENTO
-- ============================================================================
IF @IN_OPERACION = 'QFD'
BEGIN
	SELECT F.CCI_EMPRESA,
	F.CCI_SUCURSAL,
	F.CCI_CLIENTE,
	F.NCI_FACTURA AS NCI_DOCUMENTO,
	F.CCI_CLAVE_ACCESO,
	F.CES_FE,
	F.GENERAR_PDF
	FROM BIZ_FAC..TB_FAC_FACTURA F 
	WHERE F.CCI_EMPRESA = @IN_CCI_EMPRESA	
	AND F.CCI_TIPOCMPR = 'FAC'
	AND F.NCI_FACTURA = ISNULL(@IN_NCI_DOCUMENTO, F.NCI_FACTURA)
	AND F.DFM_FECHA >= @W_DFM_FECHA_INICIO 
	AND F.CES_FACTURA IS NULL	
	--AND F.CES_FE = @IN_CES_FE	
	AND F.GENERAR_PDF = 'S'
	ORDER BY F.DFX_REG_FECHA
END

-------------------------------------------------------------------------------

-- ============================================================================
-- QNP: QUERY NOTAS CREDITO PENDIENTES, VER INFORMACION DE LAS NOTAS DE CREDITO 
--      PENDIENTES PARA PROCEDER A GENERARLAS
-- ============================================================================
IF @IN_OPERACION = 'QNP'
BEGIN
	SELECT F.CCI_EMPRESA,
	F.CCI_SUCURSAL,
	(SELECT TOP 1 DIRECCION FROM BIZ_GEN..TB_SEG_SUCURSAL WHERE CCI_SUCURSAL = F.CCI_SUCURSAL) AS CTX_DIRECCION_SUCURSAL,
	F.NCI_FACTURA AS NCI_DOCUMENTO,		
	
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_FACTURA, 'E') AS ESTAB,
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_FACTURA, 'P') AS PTOEMI, 
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_FACTURA, 'SEC') AS SECUENCIAL, 	
	
	RIGHT(REPLICATE('0', 2)+ CAST(DAY(DFM_FECHA) AS VARCHAR(2)), 2) + 
	RIGHT(REPLICATE('0', 2)+ CAST(MONTH(DFM_FECHA) AS VARCHAR(2)), 2) + 
	CAST(YEAR(DFM_FECHA) AS VARCHAR(4)) AS DFM_FECHA_AUX,
	F.CCI_RUC,
	CONVERT(CHAR(10), DFM_FECHA, 103) AS DFM_FECHA,
	REPLACE(REPLACE(LTRIM(RTRIM(C.CTX_DIRECCION)), CHAR(13), ''), CHAR(10), '') AS CTX_DIRECCION,
	ISNULL(F.CTX_DESCRIPCION, 'DEVOLUCION') AS CTX_DESCRIPCION,
	ISNULL(C.CTX_TELEFONO, '') AS CTX_TELEFONO,
	ISNULL(C.CTX_MAIL, '') AS CTX_MAIL,
	CASE F.CCI_RUC WHEN '9999999999999' THEN '07' ELSE 
											  CASE C.CTX_SRITDOC WHEN '1' THEN '04'
											  WHEN '2' THEN '05' 
											  WHEN '3' THEN '06' END 
											END AS TIPO_IDENTIFICACION,
	F.CCI_CLIENTE,                                            
	CNO_CLIENTE,
	
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_COMPR_ORIGEN, 'S-N') AS NCI_COMPR_ORIGEN,	
	
	CONVERT(CHAR(10), DFI_FECHA_ORIGEN, 103) AS DFI_FECHA_ORIGEN,
	CAST(F.NVA_SUBTOTAL AS NUMERIC(18, 2)) AS NVA_SUBTOTAL,
	CAST(F.NVA_DESCUENTO AS NUMERIC(18, 2)) AS NVA_DESCUENTO,
	CAST(NQT_PORC_IVA AS NUMERIC) AS NQT_PORC_IVA,
	CAST(F.NVA_IVA AS NUMERIC(18, 2)) AS NVA_IVA,
	CAST(F.NVA_TOTAL AS NUMERIC(18, 2)) AS NVA_TOTAL,
	CASE NQT_PORC_IVA WHEN 0 THEN 0 WHEN 12 THEN 2 WHEN 14 THEN 3 END AS CODIGO_PORCENTAJE_IVA
	FROM BIZ_FAC..TB_FAC_FACTURA F INNER JOIN BIZ_GEN..TB_GEN_CLIPROV C ON
	F.CCI_EMPRESA = C.CCI_EMPRESA
	--AND F.CCI_SUCURSAL = C.CCI_SUCURSAL
	AND F.CCI_CLIENTE = C.CCI_CLIPROV
	WHERE F.CCI_EMPRESA = @IN_CCI_EMPRESA	
	AND F.CCI_TIPOCMPR = 'NC'
	AND F.NCI_FACTURA = ISNULL(@IN_NCI_DOCUMENTO, F.NCI_FACTURA)
	AND F.DFM_FECHA >= @W_DFM_FECHA_INICIO 
	AND F.CES_FACTURA IS NULL
	AND F.CES_FE = 'P'
	ORDER BY F.DFX_REG_FECHA
END

-- ============================================================================
-- QNX: QUERY NC ELECTRONICAS X PROCESAR, VER INFORMACION DE LAS NOTAS CREDITO 
--      DE ACUERDO A SU ESTADO_FE -> CES_FE PARA PROCESARLAS
--      @IN_CES_FE = 'G': TRAER LAS NOTAS DE CREDITO GENERADAS PARA FIRMARLAS
--      @IN_CES_FE = 'F': TRAER LAS NOTAS DE CREDITO FIRMADAS PARA ENVIARLAS
--      @IN_CES_FE = 'E': TRAER LAS NOTAS DE CREDITO ENVIADAS PARA AUTORIZARLAS
--      @IN_CES_FE = 'A': TRAER LAS NOTAS DE CREDITO AUTORIZADAS
-- ============================================================================
IF @IN_OPERACION = 'QNX'
BEGIN			
	SELECT F.CCI_EMPRESA,
	F.CCI_SUCURSAL,
	F.CCI_CLIENTE,
	F.NCI_FACTURA AS NCI_DOCUMENTO,
	F.CCI_CLAVE_ACCESO,
	F.CES_FE
	FROM BIZ_FAC..TB_FAC_FACTURA F 
	WHERE F.CCI_EMPRESA = @IN_CCI_EMPRESA	
	AND F.CCI_TIPOCMPR = 'NC'
	AND F.NCI_FACTURA = ISNULL(@IN_NCI_DOCUMENTO, F.NCI_FACTURA)
	AND F.DFM_FECHA >= @W_DFM_FECHA_INICIO 
	AND F.CES_FACTURA IS NULL	
	AND F.CES_FE = @IN_CES_FE	
	ORDER BY F.DFX_REG_FECHA
END

-- ============================================================================
-- QND: QUERY NC GENERAR PDF, VER LAS NC QUE ESTEN AUTORIZADAS Y 
--      QUE TENGAN EN CAMPO "GENERAR_PDF" IGUAL A "S" PARA GENERAR EL PDF DE 
--      ESE DOCUMENTO
-- ============================================================================
IF @IN_OPERACION = 'QND'
BEGIN			
	SELECT F.CCI_EMPRESA,
	F.CCI_SUCURSAL,
	F.CCI_CLIENTE,
	F.NCI_FACTURA AS NCI_DOCUMENTO,
	F.CCI_CLAVE_ACCESO,
	F.CES_FE
	FROM BIZ_FAC..TB_FAC_FACTURA F 
	WHERE F.CCI_EMPRESA = @IN_CCI_EMPRESA	
	AND F.CCI_TIPOCMPR = 'NC'
	AND F.NCI_FACTURA = ISNULL(@IN_NCI_DOCUMENTO, F.NCI_FACTURA)
	AND F.DFM_FECHA >= @W_DFM_FECHA_INICIO 
	AND F.CES_FACTURA IS NULL	
	--AND F.CES_FE = @IN_CES_FE
	AND F.GENERAR_PDF = 'S'	
	ORDER BY F.DFX_REG_FECHA
END

-------------------------------------------------------------------------------

-- ============================================================================
-- QRP: QUERY RETENCIONES PENDIENTES, VER INFORMACION DE LAS RETENCIONES 
--      PENDIENTES PARA PROCEDER A GENERARLAS
-- ============================================================================
IF @IN_OPERACION = 'QRP'
BEGIN		
	SELECT DISTINCT R.CCI_EMPRESA, 
	R.CCI_SUCURSAL, 
	(SELECT TOP 1 DIRECCION FROM BIZ_GEN..TB_SEG_SUCURSAL WHERE CCI_SUCURSAL = R.CCI_SUCURSAL) AS CTX_DIRECCION_SUCURSAL,
	CMPR.COD_PROV, 
	R.NCI_RETENCION AS NCI_DOCUMENTO,

	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_RETENCION, 'E') AS ESTAB,
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_RETENCION, 'P') AS PTOEMI, 
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_RETENCION, 'SEC') AS SECUENCIAL,

	RIGHT(REPLICATE('0', 2)+ CAST(DAY(R.DFM_RETENCION) AS VARCHAR(2)), 2) + 
	RIGHT(REPLICATE('0', 2)+ CAST(MONTH(R.DFM_RETENCION) AS VARCHAR(2)), 2) + 
	CAST(YEAR(R.DFM_RETENCION) AS VARCHAR(4)) AS DFM_RETENCION_AUX,

	RIGHT(REPLICATE('0', 2)+ CAST(MONTH(R.DFM_RETENCION) AS VARCHAR(2)), 2) + '/' +
	CAST(YEAR(R.DFM_RETENCION) AS VARCHAR(4)) AS PERIODO_FISCAL,

	CONVERT(CHAR(10), R.DFM_RETENCION, 103) AS DFM_RETENCION,

	REPLACE(REPLACE(LTRIM(RTRIM(C.CTX_DIRECCION)), CHAR(13), ''), CHAR(10), '') AS CTX_DIRECCION,
	ISNULL(C.CTX_TELEFONO, '') AS CTX_TELEFONO,
	ISNULL(C.CTX_MAIL, '') AS CTX_MAIL,
	CASE C.CCI_RUC WHEN '9999999999999' THEN '07' ELSE 
										  CASE C.CTX_SRITDOC WHEN '1' THEN '04'
										  WHEN '2' THEN '05' 
										  WHEN '3' THEN '06' END 
										END AS TIPO_IDENTIFICACION,
	C.CNO_CLIPROV  AS CNO_CLIENTE,
	C.CCI_RUC
	FROM BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION R INNER JOIN BIZ_CNT..TB_BAN_PRO_CMPR CMPR ON
	R.CCI_EMPRESA = CMPR.CCI_EMPRESA
	AND R.CCI_SUCURSAL = CMPR.CCI_SUCURSAL
	AND R.CMP_CODIGO = CMPR.CMP_CODIGO INNER JOIN BIZ_GEN..TB_GEN_CLIPROV C ON
	CMPR.CCI_EMPRESA = C.CCI_EMPRESA
	AND CMPR.COD_PROV = C.CCI_CLIPROV
	WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA
	AND R.NCI_RETENCION = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_RETENCION)
	AND R.DFM_RETENCION >= @W_DFM_FECHA_INICIO	
	AND R.CES_FE = 'P'
END

-- ============================================================================
-- QRX: QUERY RETENCIONES ELECTRONICAS X PROCESAR, VER INFORMACION DE  
--      RETENCIONES DE ACUERDO A SU ESTADO_FE -> CES_FE PARA PROCESARLAS
--      @IN_CES_FE = 'G': TRAER LAS RETENCIONES GENERADAS PARA FIRMARLAS
--      @IN_CES_FE = 'F': TRAER LAS RETENCIONES FIRMADAS PARA ENVIARLAS
--      @IN_CES_FE = 'E': TRAER LAS RETENCIONES ENVIADAS PARA AUTORIZARLAS
--      @IN_CES_FE = 'A': TRAER LAS RETENCIONES AUTORIZADAS
-- ============================================================================
IF @IN_OPERACION = 'QRX'
BEGIN			
	SELECT DISTINCT R.CCI_EMPRESA,
	R.CCI_SUCURSAL,
	CMPR.COD_PROV AS CCI_CLIENTE,
	R.NCI_RETENCION AS NCI_DOCUMENTO,
	R.CCI_CLAVE_ACCESO,
	R.CES_FE
	FROM BIZ_CNT..TB_BAN_PRO_CMPR CMPR INNER JOIN BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION R ON
	CMPR.CCI_EMPRESA = R.CCI_EMPRESA
	AND CMPR.CCI_SUCURSAL = R.CCI_SUCURSAL
	AND CMPR.CMP_CODIGO = R.CMP_CODIGO
	WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA		
	AND R.NCI_RETENCION = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_RETENCION)
	AND R.DFM_RETENCION >= @W_DFM_FECHA_INICIO 	
	AND R.CES_FE = @IN_CES_FE		
END

-- ============================================================================
-- QRD: QUERY RETENCIONES GENERAR PDF, VER LAS RET QUE ESTEN AUTORIZADAS Y 
--      QUE TENGAN EN CAMPO "GENERAR_PDF" IGUAL A "S" PARA GENERAR EL PDF DE 
--      ESE DOCUMENTO
-- ============================================================================
IF @IN_OPERACION = 'QRD'
BEGIN			
	SELECT DISTINCT R.CCI_EMPRESA,
	R.CCI_SUCURSAL,
	CMPR.COD_PROV AS CCI_CLIENTE,
	R.NCI_RETENCION AS NCI_DOCUMENTO,
	R.CCI_CLAVE_ACCESO,
	R.CES_FE
	FROM BIZ_CNT..TB_BAN_PRO_CMPR CMPR INNER JOIN BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION R ON
	CMPR.CCI_EMPRESA = R.CCI_EMPRESA
	AND CMPR.CCI_SUCURSAL = R.CCI_SUCURSAL
	AND CMPR.CMP_CODIGO = R.CMP_CODIGO
	WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA		
	AND R.NCI_RETENCION = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_RETENCION)
	AND R.DFM_RETENCION >= @W_DFM_FECHA_INICIO 	
	--AND R.CES_FE = @IN_CES_FE	
	AND R.GENERAR_PDF = 'S'	
END

-------------------------------------------------------------------------------

-- ============================================================================
-- QGP: QUERY GUIAS PENDIENTES, VER INFORMACION DE LAS GUIAS DE REMISION 
--      PENDIENTES PARA PROCEDER A GENERARLAS
-- ============================================================================
IF @IN_OPERACION = 'QGP'
BEGIN			
	--SELECT R.CCI_EMPRESA, 
	--R.CCI_SUCURSAL, 
	--R.NCI_GUIA AS NCI_DOCUMENTO,

	--BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_GUIA, 'E') AS ESTAB,
	--BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_GUIA, 'P') AS PTOEMI, 
	--BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_GUIA, 'SEC') AS SECUENCIAL,

	--RIGHT(REPLICATE('0', 2)+ CAST(DAY(R.DFM_EMISION) AS VARCHAR(2)), 2) + 
	--RIGHT(REPLICATE('0', 2)+ CAST(MONTH(R.DFM_EMISION) AS VARCHAR(2)), 2) + 
	--CAST(YEAR(R.DFM_EMISION) AS VARCHAR(4)) AS DFM_EMISION_AUX,

	--CONVERT(CHAR(10), R.DFM_EMISION, 103) AS DFM_EMISION,

	--REPLACE(REPLACE(LTRIM(RTRIM(R.CTX_PTO_PARTIDA)), CHAR(13), ''), CHAR(10), '') AS CTX_PTO_PARTIDA,
	
	--LTRIM(RTRIM(ISNULL(R.CNO_PERSONA_TRANSP, ''))) AS CNO_PERSONA_TRANSP,
		
	--CASE 
	--	(SELECT TOP 1 ID_IDENTIFICACION FROM BIZ_GEN..TB_GEN_CHOFER WHERE IDENTIFICACION_CHOFER = R.CTX_RUC_TRANSP) 
	--	WHEN 1 THEN '04'
	--	WHEN 2 THEN '05'
	--	WHEN 3 THEN '06' 
	--END AS TIPO_IDENTIFICACION_TRANSPORTISTA,
	
	--LTRIM(RTRIM(ISNULL(R.CTX_RUC_TRANSP, ''))) AS CTX_RUC_TRANSP,
	--CONVERT(CHAR(10), R.DFM_INI_TRASLADO, 103) AS DFM_INI_TRASLADO,
	--CONVERT(CHAR(10), R.DFM_TER_TRASLADO, 103) AS DFM_TER_TRASLADO,
	--ISNULL(CTX_PLACA_TRANSP, '') AS CTX_PLACA_TRANSP,
	--R.CNO_DESTINATARIO,
	--R.CTX_PTO_LLEGADA,
	
	--ISNULL(C.CTX_TELEFONO, '') AS CTX_TELEFONO,
	--ISNULL(C.CTX_MAIL, '') AS CTX_MAIL,
	--CASE C.CCI_RUC WHEN '9999999999999' THEN '07' ELSE 
	--									  CASE C.CTX_SRITDOC WHEN '1' THEN '04'
	--									  WHEN '2' THEN '05' 
	--									  WHEN '3' THEN '06' END 
	--									END AS TIPO_IDENTIFICACION,
	--C.CNO_CLIPROV  AS CNO_CLIENTE,
	--C.CCI_RUC,
	--REPLACE(REPLACE(LTRIM(RTRIM(C.CTX_DIRECCION)), CHAR(13), ''), CHAR(10), '') AS CTX_DIRECCION,
	--'por definir' AS MOTIVO_TRASLADO,
	--'NO ES OBLIGATORIO' AS RUTA 
	--FROM BIZ_INV_REP..TB_INV_GUIA_REMISION R INNER JOIN BIZ_INV_REP..TB_INV_SALIDAS S ON
	--R.CCI_EMPRESA = S.CCI_EMPRESA
	--AND R.CCI_SUCURSAL = S.CCI_SUCURSAL
	--AND R.NCI_SALIDA = S.NCI_SALIDA INNER JOIN BIZ_GEN..TB_GEN_CLIPROV C ON
	--S.CCI_EMPRESA = C.CCI_EMPRESA
	--AND S.CCI_CLIENTE = C.CCI_CLIPROV
	--WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA
	--AND R.NCI_GUIA = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_GUIA)
	--AND R.DFM_EMISION >= @W_DFM_FECHA_INICIO	
	--AND R.CES_FE = 'P'
		
	
	SELECT R.CCI_EMPRESA, 
	R.CCI_SUCURSAL, 
	(SELECT TOP 1 DIRECCION FROM BIZ_GEN..TB_SEG_SUCURSAL WHERE CCI_SUCURSAL = R.CCI_SUCURSAL) AS CTX_DIRECCION_SUCURSAL,
	R.NCI_GUIA AS NCI_DOCUMENTO,

	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_GUIA, 'E') AS ESTAB,
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_GUIA, 'P') AS PTOEMI, 
	BIZ_FAC.DBO.FU_RETORNA_SERIE_NUMERO_DOCUMENTO(NCI_GUIA, 'SEC') AS SECUENCIAL,

	RIGHT(REPLICATE('0', 2)+ CAST(DAY(R.DFM_EMISION) AS VARCHAR(2)), 2) + 
	RIGHT(REPLICATE('0', 2)+ CAST(MONTH(R.DFM_EMISION) AS VARCHAR(2)), 2) + 
	CAST(YEAR(R.DFM_EMISION) AS VARCHAR(4)) AS DFM_EMISION_AUX,

	CONVERT(CHAR(10), R.DFM_EMISION, 103) AS DFM_EMISION,

	REPLACE(REPLACE(LTRIM(RTRIM(R.CTX_PTO_PARTIDA)), CHAR(13), ''), CHAR(10), '') AS CTX_PTO_PARTIDA,

	LTRIM(RTRIM(ISNULL(R.CNO_PERSONA_TRANSP, ''))) AS CNO_PERSONA_TRANSP,
		
	CASE 
		(SELECT TOP 1 ID_IDENTIFICACION FROM BIZ_GEN..TB_GEN_CHOFER WHERE IDENTIFICACION_CHOFER = R.CTX_RUC_TRANSP) 
		WHEN 1 THEN '04'
		WHEN 2 THEN '05'
		WHEN 3 THEN '06' 
	END AS TIPO_IDENTIFICACION_TRANSPORTISTA,

	LTRIM(RTRIM(ISNULL(R.CTX_RUC_TRANSP, ''))) AS CTX_RUC_TRANSP,
	CONVERT(CHAR(10), R.DFM_INI_TRASLADO, 103) AS DFM_INI_TRASLADO,
	CONVERT(CHAR(10), R.DFM_TER_TRASLADO, 103) AS DFM_TER_TRASLADO,
	ISNULL(CTX_PLACA_TRANSP, '') AS CTX_PLACA_TRANSP,
	R.CNO_DESTINATARIO,
	R.CTX_PTO_LLEGADA,

	ISNULL(C.CTX_TELEFONO, '') AS CTX_TELEFONO,
	ISNULL(C.CTX_MAIL, '') AS CTX_MAIL,
	CASE C.CCI_RUC WHEN '9999999999999' THEN '07' ELSE 
										  CASE C.CTX_SRITDOC WHEN '1' THEN '04'
										  WHEN '2' THEN '05' 
										  WHEN '3' THEN '06' END 
										END AS TIPO_IDENTIFICACION,
	C.CNO_CLIPROV  AS CNO_CLIENTE,
	C.CCI_RUC,
	REPLACE(REPLACE(LTRIM(RTRIM(C.CTX_DIRECCION)), CHAR(13), ''), CHAR(10), '') AS CTX_DIRECCION,
	'por definir' AS MOTIVO_TRASLADO,
	'NO ES OBLIGATORIO' AS RUTA 
	FROM BIZ_INV_REP..TB_INV_GUIA_REMISION R 
	INNER JOIN BIZ_GEN..TB_GEN_CLIPROV C ON
	R.CCI_EMPRESA = C.CCI_EMPRESA
	AND R.CCI_CLIENTE = C.CCI_CLIPROV
	WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA
	AND R.NCI_GUIA = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_GUIA)
	AND R.DFM_EMISION >= @W_DFM_FECHA_INICIO
	AND ISNULL(R.CES_ESTADO, '') = 'A'	
	AND R.CES_FE = 'P'
END

-- ============================================================================
-- QGX: QUERY GUIAS ELECTRONICAS X PROCESAR, VER INFORMACION DE LAS GUIAS DE 
--      ACUERDO A SU ESTADO_FE -> CES_FE PARA PROCESARLAS
--      @IN_CES_FE = 'G': TRAER LAS GUIAS GENERADAS PARA FIRMARLAS
--      @IN_CES_FE = 'F': TRAER LAS GUIAS FIRMADAS PARA ENVIARLAS
--      @IN_CES_FE = 'E': TRAER LAS GUIAS ENVIADAS PARA AUTORIZARLAS
--      @IN_CES_FE = 'A': TRAER LAS GUIAS AUTORIZADAS
-- ============================================================================
IF @IN_OPERACION = 'QGX'
BEGIN			
	--SELECT R.CCI_EMPRESA,
	--R.CCI_SUCURSAL,	
	--S.CCI_CLIENTE,
	--R.NCI_GUIA AS NCI_DOCUMENTO,
	--R.CCI_CLAVE_ACCESO,
	--R.CES_FE
	--FROM BIZ_INV_REP..TB_INV_GUIA_REMISION R INNER JOIN BIZ_INV_REP..TB_INV_SALIDAS S ON
	--R.CCI_EMPRESA = S.CCI_EMPRESA
	--AND R.CCI_SUCURSAL = S.CCI_SUCURSAL
	--AND R.NCI_SALIDA = S.NCI_SALIDA
	--WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA	
	--AND R.NCI_GUIA = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_GUIA)
	--AND R.DFM_EMISION >= @W_DFM_FECHA_INICIO 
	--AND R.CES_FE = @IN_CES_FE	
	--ORDER BY R.DFM_REGISTRO
	
	SELECT R.CCI_EMPRESA,
	R.CCI_SUCURSAL,	
	R.CCI_CLIENTE,
	R.NCI_GUIA AS NCI_DOCUMENTO,
	R.CCI_CLAVE_ACCESO,
	R.CES_FE
	FROM BIZ_INV_REP..TB_INV_GUIA_REMISION R
	WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA	
	AND R.NCI_GUIA = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_GUIA)
	AND R.DFM_EMISION >= @W_DFM_FECHA_INICIO 
	AND R.CES_FE = @IN_CES_FE	
	ORDER BY R.DFM_REGISTRO
END

-- ============================================================================
-- QGD: QUERY GUIAS GENERAR PDF, VER LAS GUIAS QUE ESTEN AUTORIZADAS Y 
--      QUE TENGAN EN CAMPO "GENERAR_PDF" IGUAL A "S" PARA GENERAR EL PDF DE 
--      ESE DOCUMENTO
-- ============================================================================
IF @IN_OPERACION = 'QGD'
BEGIN			
	--SELECT R.CCI_EMPRESA,
	--R.CCI_SUCURSAL,	
	--S.CCI_CLIENTE,
	--R.NCI_GUIA AS NCI_DOCUMENTO,
	--R.CCI_CLAVE_ACCESO,
	--R.CES_FE
	--FROM BIZ_INV_REP..TB_INV_GUIA_REMISION R INNER JOIN BIZ_INV_REP..TB_INV_SALIDAS S ON
	--R.CCI_EMPRESA = S.CCI_EMPRESA
	--AND R.CCI_SUCURSAL = S.CCI_SUCURSAL
	--AND R.NCI_SALIDA = S.NCI_SALIDA
	--WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA	
	--AND R.NCI_GUIA = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_GUIA)
	--AND R.DFM_EMISION >= @W_DFM_FECHA_INICIO 
	--AND R.CES_FE = @IN_CES_FE	
	--AND R.GENERAR_PDF = 'S'
	--ORDER BY R.DFM_REGISTRO
	
	SELECT R.CCI_EMPRESA,
	R.CCI_SUCURSAL,	
	R.CCI_CLIENTE,
	R.NCI_GUIA AS NCI_DOCUMENTO,
	R.CCI_CLAVE_ACCESO,
	R.CES_FE
	FROM BIZ_INV_REP..TB_INV_GUIA_REMISION R 
	WHERE R.CCI_EMPRESA = @IN_CCI_EMPRESA	
	AND R.NCI_GUIA = ISNULL(@IN_NCI_DOCUMENTO, R.NCI_GUIA)
	AND R.DFM_EMISION >= @W_DFM_FECHA_INICIO 
	--AND R.CES_FE = @IN_CES_FE	
	AND R.GENERAR_PDF = 'S'
	ORDER BY R.DFM_REGISTRO
END

-- ============================================================================
-- QDP: QUERY DOCUMENTOS PROCESABLES, TRAER TODOS LOS DOCUMENTOS PROCESABLES
-- ============================================================================ 
IF @IN_OPERACION = 'QDP'
BEGIN

	--SE BUSCA SI HAY DOCUMENTOS QUE NO SE ENVIARON POR UN ERROR DE CONEXION CON EL SERVIDOR SMTP

	SELECT ROW_NUMBER() OVER( PARTITION BY CCI_EMPRESA, CCI_TIPOCMPR, NCI_DOCUMENTO ORDER BY DFX_REGISTRO DESC ) AS RN ,
	CCI_EMPRESA, 
	CCI_TIPOCMPR, 
	NCI_DOCUMENTO, 
	CTX_MAIL, 
	ENVIADO, 
	DETALLE_ENVIO, 
	DFX_REGISTRO
	INTO #TMP
	FROM BIZ_FAC..TB_FAC_FE_MAIL_LOG


	UPDATE BIZ_FAC..TB_FAC_FACTURA
	SET ENVIAR_MAIL = 'S'
	FROM #TMP CTE INNER JOIN BIZ_FAC..TB_FAC_FACTURA F ON
	CTE.CCI_EMPRESA = F.CCI_EMPRESA
	AND CTE.CCI_TIPOCMPR = F.CCI_TIPOCMPR
	AND CTE.NCI_DOCUMENTO = F.NCI_FACTURA
	WHERE RN = 1
	AND ENVIADO = 'N'
	AND DETALLE_ENVIO LIKE '%Exc%'
	AND DETALLE_ENVIO like '%SMTP%'
	AND DFX_REGISTRO > '20191106'


	UPDATE BIZ_INV_REP..TB_INV_GUIA_REMISION
	SET ENVIAR_MAIL = 'S'
	FROM #TMP CTE INNER JOIN BIZ_INV_REP..TB_INV_GUIA_REMISION G ON
	CTE.CCI_EMPRESA = G.CCI_EMPRESA
	AND CTE.NCI_DOCUMENTO = G.NCI_GUIA
	WHERE RN = 1
	AND CTE.CCI_TIPOCMPR = 'GUI'
	AND ENVIADO = 'N'
	AND DETALLE_ENVIO LIKE '%Exc%'
	AND DETALLE_ENVIO LIKE '%SMTP%'
	AND DFX_REGISTRO > '20191106'


	UPDATE BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION
	SET ENVIAR_MAIL = 'S'
	FROM #TMP CTE INNER JOIN BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION R ON
	CTE.CCI_EMPRESA = R.CCI_EMPRESA
	AND CTE.NCI_DOCUMENTO = R.NCI_RETENCION
	WHERE RN = 1
	AND CTE.CCI_TIPOCMPR = 'RET'
	AND ENVIADO = 'N'
	AND DETALLE_ENVIO LIKE '%Exc%'
	and DETALLE_ENVIO like '%SMTP%'
	AND DFX_REGISTRO > '20191106'


	DROP TABLE #TMP


	SELECT DISTINCT F.CCI_EMPRESA,
	F.CCI_SUCURSAL,
	F.CCI_TIPOCMPR,
	F.NCI_DOCUMENTO
	FROM (
		SELECT F.CCI_EMPRESA, 
		F.CCI_SUCURSAL, 
		F.CCI_CLIENTE, 
		F.DFM_FECHA,
		F.CCI_TIPOCMPR, 
		F.NCI_FACTURA AS NCI_DOCUMENTO,
		F.ID_LOG_FE,
		F.CCI_USUARIO,
		F.DFX_REG_FECHA,
		F.CES_FE,
		F.GENERAR_PDF,
		F.ENVIAR_MAIL
		FROM BIZ_FAC..TB_FAC_FACTURA F
		WHERE F.CCI_TIPOCMPR = 'FAC'
		AND F.CES_FACTURA IS NULL

		UNION

		SELECT F.CCI_EMPRESA, 
		F.CCI_SUCURSAL, 
		F.CCI_CLIENTE, 
		F.DFM_FECHA,
		F.CCI_TIPOCMPR, 
		F.NCI_FACTURA,
		F.ID_LOG_FE,
		F.CCI_USUARIO,
		F.DFX_REG_FECHA,
		F.CES_FE,
		F.GENERAR_PDF,
		F.ENVIAR_MAIL
		FROM BIZ_FAC..TB_FAC_FACTURA F
		WHERE F.CCI_TIPOCMPR = 'NC'
		AND F.CES_FACTURA IS NULL

		UNION

		SELECT DISTINCT R.CCI_EMPRESA,
		R.CCI_SUCURSAL,
		CMPR.COD_PROV AS CCI_CLIENTE,
		R.DFM_RETENCION,
		'RET' AS CCI_TIPOCMPR,
		R.NCI_RETENCION AS NCI_DOCUMENTO,
		R.ID_LOG_FE,
		R.CCI_USUARIO,
		R.DFM_PROCESO,
		R.CES_FE,
		R.GENERAR_PDF,
		R.ENVIAR_MAIL
		FROM BIZ_CNT..TB_BAN_PRO_CMPR CMPR WITH(NOLOCK) INNER JOIN BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION R WITH(NOLOCK) ON
		CMPR.CCI_EMPRESA = R.CCI_EMPRESA
		AND CMPR.CCI_SUCURSAL = R.CCI_SUCURSAL
		AND CMPR.CMP_CODIGO = R.CMP_CODIGO

		UNION

		SELECT R.CCI_EMPRESA,
		R.CCI_SUCURSAL,	
		R.CCI_CLIENTE,
		R.DFM_EMISION,
		'GUI' AS CCI_TIPOCMPR,
		R.NCI_GUIA AS NCI_DOCUMENTO,
		R.ID_LOG_FE,
		R.CCI_USUARIO,
		R.DFM_REGISTRO,
		R.CES_FE,
		R.GENERAR_PDF,
		R.ENVIAR_MAIL
		FROM BIZ_INV_REP..TB_INV_GUIA_REMISION R
		) F INNER JOIN BIZ_GEN..TB_GEN_CLIPROV C ON 
	F.CCI_EMPRESA = C.CCI_EMPRESA
	AND F.CCI_CLIENTE = C.CCI_CLIPROV INNER JOIN BIZ_FAC..TB_FAC_FE_PARAMETROS PFE ON
	C.CCI_EMPRESA = PFE.CCI_EMPRESA	
	WHERE F.CCI_EMPRESA = ISNULL(@IN_CCI_EMPRESA, F.CCI_EMPRESA)
	AND F.CCI_TIPOCMPR = ISNULL(@IN_CCI_TIPOCMPR, F.CCI_TIPOCMPR)
	AND F.DFM_FECHA >= PFE.DFM_FECHA_INICIO
	AND (F.CES_FE IN('P', 'G', 'F', 'E') OR F.GENERAR_PDF = 'S' OR F.ENVIAR_MAIL = 'S')
	ORDER BY F.CCI_EMPRESA, F.CCI_SUCURSAL,	F.CCI_TIPOCMPR,	F.NCI_DOCUMENTO
END

-- ============================================================================
-- UPD: UPDATE GENERAR PDF, ACTUALIZA EL CAMPO "GENERAR PDF"
-- ============================================================================
IF @IN_OPERACION = 'UPD'
BEGIN
	IF @IN_CCI_TIPOCMPR = 'FAC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'FAC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'NC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'NC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'RET'
	BEGIN
		UPDATE BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_RETENCION = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'GUI'
	BEGIN
		UPDATE BIZ_INV_REP..TB_INV_GUIA_REMISION
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_GUIA = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE				
	END
END

-- ============================================================================
-- UEM: UPDATE ENVIAR MAIL, ACTUALIZA EL CAMPO "ENVIAR MAIL"
-- ============================================================================
IF @IN_OPERACION = 'UEM'
BEGIN
	IF @IN_CCI_TIPOCMPR = 'FAC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'FAC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'NC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'NC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'RET'
	BEGIN
		UPDATE BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_RETENCION = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'GUI'
	BEGIN
		UPDATE BIZ_INV_REP..TB_INV_GUIA_REMISION
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_GUIA = @IN_NCI_DOCUMENTO
		AND CES_FE = @IN_CES_FE				
	END
END

-- ============================================================================
-- UP2: UPDATE GENERAR PDF, ACTUALIZA EL CAMPO "GENERAR PDF" SIN TOMAR EN 
--      CUENTA EL ESTADO
-- ============================================================================
IF @IN_OPERACION = 'UP2'
BEGIN
	IF @IN_CCI_TIPOCMPR = 'FAC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'FAC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'NC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'NC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'RET'
	BEGIN
		UPDATE BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_RETENCION = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'GUI'
	BEGIN
		UPDATE BIZ_INV_REP..TB_INV_GUIA_REMISION
		SET GENERAR_PDF = @IN_GENERAR_PDF
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_GUIA = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE				
	END
END

-- ============================================================================
-- UE2: UPDATE ENVIAR MAIL, ACTUALIZA EL CAMPO "ENVIAR MAIL" SIN TOMAR EN 
--      CUENTA EL ESTADO
-- ============================================================================
IF @IN_OPERACION = 'UE2'
BEGIN
	IF @IN_CCI_TIPOCMPR = 'FAC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'FAC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'NC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'NC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'RET'
	BEGIN
		UPDATE BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_RETENCION = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE
	END
	
	IF @IN_CCI_TIPOCMPR = 'GUI'
	BEGIN
		UPDATE BIZ_INV_REP..TB_INV_GUIA_REMISION
		SET ENVIAR_MAIL = @IN_ENVIAR_MAIL
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_GUIA = @IN_NCI_DOCUMENTO
		--AND CES_FE = @IN_CES_FE				
	END
END


-- ============================================================================
-- HDR: HABILITAR DOCUMENTO RECHAZADO, HABILITA UN DOCUMENTO QUE HA SIDO  
--      RECHAZADO
-- ============================================================================
IF @IN_OPERACION = 'HDR'
BEGIN
	IF @IN_CCI_TIPOCMPR = 'FAC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET CES_FE = @IN_CES_FE
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'FAC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		AND CES_FE = 'R'
	END
	
	IF @IN_CCI_TIPOCMPR = 'NC'
	BEGIN
		UPDATE BIZ_FAC..TB_FAC_FACTURA
		SET CES_FE = @IN_CES_FE
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL
		AND CCI_TIPOCMPR = 'NC'
		AND NCI_FACTURA = @IN_NCI_DOCUMENTO
		AND CES_FE = 'R'
	END
	
	IF @IN_CCI_TIPOCMPR = 'RET'
	BEGIN
		UPDATE BIZ_CNT..TB_BAN_PRO_CMPR_RETENCION
		SET CES_FE = @IN_CES_FE
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_RETENCION = @IN_NCI_DOCUMENTO
		AND CES_FE = 'R'
	END
	
	IF @IN_CCI_TIPOCMPR = 'GUI'
	BEGIN
		UPDATE BIZ_INV_REP..TB_INV_GUIA_REMISION
		SET CES_FE = @IN_CES_FE
		WHERE CCI_EMPRESA = @IN_CCI_EMPRESA
		--AND CCI_SUCURSAL = @IN_CCI_SUCURSAL		
		AND NCI_GUIA = @IN_NCI_DOCUMENTO
		AND CES_FE = 'R'
	END
END