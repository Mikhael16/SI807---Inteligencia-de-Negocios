-- =============================================
-- LUZ DEL SUR · DW · Seeds y Quick Checks
-- PostgreSQL
-- =============================================

-- 1) Verifica que el esquema y tablas existen
SELECT n.nspname AS schema, c.relname AS table_name
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'dw' AND c.relkind='r'
ORDER BY table_name;

-- 2) Inserta mínimos en DIMENSIONES
INSERT INTO dw.dim_tiempo(anio,mes,periodo_yyyymm,trimestre,es_fin_de_mes,vigencia_pliego)
VALUES (2025, 9, 202509, 3, FALSE, 'PLIEGO-2025')                 RETURNING tiempo_sk;

INSERT INTO dw.dim_suministro(suministro_id,cliente_id,medidor_id,direccion,estado)
VALUES ('000123456','C-001','M-001','Av. Prueba 123','activo')    RETURNING suministro_sk;

INSERT INTO dw.dim_tarifa(codigo_tarifa,nivel_tension,categoria,estructura_tarifaria)
VALUES ('BT5','BT','residencial','E+P')                            RETURNING tarifa_sk;

INSERT INTO dw.dim_segmento(segmento_codigo,segmento_nombre,regla_clasificacion)
VALUES ('RES','Residencial','por giro')                            RETURNING segmento_sk;

INSERT INTO dw.dim_sucursalsector(empresa,sucursal,sector,zona_comercial)
VALUES ('LuzDelSur','LIMA','S-01','ZONA-NORTE')                    RETURNING suc_sector_sk;

INSERT INTO dw.dim_concepto(concepto_codigo,concepto_nombre,tipo_concepto,es_no_energetico,afecta_igv,version_catalogo)
VALUES ('ENER','Energía','ENERGETICO',FALSE,TRUE,'v1')             RETURNING concepto_sk;

INSERT INTO dw.dim_eventocorte(evento_id_negocio,tipo_corte,zona_afectada,motivo,umbral_anticipacion_h,fecha_inicio_prog,fecha_fin_prog)
VALUES ('EVT-001','programado','ZONA-NORTE','mantenimiento',48, NOW() + INTERVAL '2 day', NOW() + INTERVAL '2 day 2 hour')
RETURNING evento_corte_sk;

-- 3) Guarda IDs para usarlos en los hechos
WITH ids AS (
  SELECT
    (SELECT tiempo_sk        FROM dw.dim_tiempo        ORDER BY tiempo_sk DESC LIMIT 1)  AS t,
    (SELECT suministro_sk    FROM dw.dim_suministro    ORDER BY suministro_sk DESC LIMIT 1) AS s,
    (SELECT tarifa_sk        FROM dw.dim_tarifa        ORDER BY tarifa_sk DESC LIMIT 1)   AS tf,
    (SELECT segmento_sk      FROM dw.dim_segmento      ORDER BY segmento_sk DESC LIMIT 1) AS sg,
    (SELECT suc_sector_sk    FROM dw.dim_sucursalsector ORDER BY suc_sector_sk DESC LIMIT 1) AS ss,
    (SELECT concepto_sk      FROM dw.dim_concepto      ORDER BY concepto_sk DESC LIMIT 1) AS c,
    (SELECT evento_corte_sk  FROM dw.dim_eventocorte   ORDER BY evento_corte_sk DESC LIMIT 1) AS ec
)
-- 4) Inserta mínimos en HECHOS
INSERT INTO dw.hecho_facturacion (tiempo_sk,suministro_sk,tarifa_sk,segmento_sk,suc_sector_sk,concepto_sk,
  factura_id,periodo_yyyymm,lectura_tipo,kwh_total,kw_md,importe_energia,importe_potencia,
  importe_no_energeticos,importe_impuestos,importe_total,ft_sin_igv,fr_sin_igv,divergencia_pct,flag_anomalia_div)
SELECT t,s,tf,sg,ss,c,'FAC-0001',202509,'REAL',120.00,5.2,80.00,10.00,4.00,16.20,110.20,94.00,90.00,0.0444,TRUE
FROM ids;

WITH ids AS (
  SELECT
    (SELECT tiempo_sk        FROM dw.dim_tiempo        ORDER BY tiempo_sk DESC LIMIT 1)  AS t,
    (SELECT suministro_sk    FROM dw.dim_suministro    ORDER BY suministro_sk DESC LIMIT 1) AS s,
    (SELECT tarifa_sk        FROM dw.dim_tarifa        ORDER BY tarifa_sk DESC LIMIT 1)   AS tf,
    (SELECT segmento_sk      FROM dw.dim_segmento      ORDER BY segmento_sk DESC LIMIT 1) AS sg,
    (SELECT suc_sector_sk    FROM dw.dim_sucursalsector ORDER BY suc_sector_sk DESC LIMIT 1) AS ss
)
INSERT INTO dw.hecho_consumo (tiempo_sk,suministro_sk,tarifa_sk,segmento_sk,suc_sector_sk,
  periodo_yyyymm,lectura_tipo,kwh,kvarh,kva,z_robusto,flag_consumo_atipico)
SELECT t,s,tf,sg,ss,202509,'REAL',120.00,10.00,2.5,2.1,TRUE
FROM ids;

WITH ids AS (
  SELECT
    (SELECT tiempo_sk        FROM dw.dim_tiempo        ORDER BY tiempo_sk DESC LIMIT 1)  AS t,
    (SELECT suministro_sk    FROM dw.dim_suministro    ORDER BY suministro_sk DESC LIMIT 1) AS s
)
INSERT INTO dw.hecho_cobranza (tiempo_sk,suministro_sk,factura_id,periodo_yyyymm,fecha_emision,fecha_vencimiento,fecha_pago,dias_mora,importe_pendiente,flag_morosidad)
SELECT t,s,'FAC-0001',202509,CURRENT_DATE,CURRENT_DATE + 15, NULL, 5, 20.20, TRUE
FROM ids;

WITH ids AS (
  SELECT
    (SELECT tiempo_sk        FROM dw.dim_tiempo        ORDER BY tiempo_sk DESC LIMIT 1)  AS t,
    (SELECT suministro_sk    FROM dw.dim_suministro    ORDER BY suministro_sk DESC LIMIT 1) AS s
)
INSERT INTO dw.hecho_correcciones (tiempo_sk,suministro_sk,caso_id,factura_id,fecha_deteccion,fecha_correccion,motivo_correccion,proactiva_flag,dias_regularizacion)
SELECT t,s,'CASO-001','FAC-0001',CURRENT_DATE, CURRENT_DATE + 3,'ajuste lectura',TRUE,3
FROM ids;

WITH ids AS (
  SELECT
    (SELECT tiempo_sk        FROM dw.dim_tiempo        ORDER BY tiempo_sk DESC LIMIT 1)  AS t,
    (SELECT suc_sector_sk    FROM dw.dim_sucursalsector ORDER BY suc_sector_sk DESC LIMIT 1) AS ss,
    (SELECT evento_corte_sk  FROM dw.dim_eventocorte   ORDER BY evento_corte_sk DESC LIMIT 1) AS ec
)
INSERT INTO dw.hecho_cortes (tiempo_sk,evento_corte_sk,suc_sector_sk,clientes_afectados,clientes_notificados,anticipacion_horas_min,notificacion_oportuna)
SELECT t,ec,ss,100,95,48,TRUE
FROM ids;

-- 5) Quick checks
SELECT 'dim_tiempo' tbl, COUNT(*) FROM dw.dim_tiempo
UNION ALL SELECT 'dim_suministro', COUNT(*) FROM dw.dim_suministro
UNION ALL SELECT 'dim_tarifa', COUNT(*) FROM dw.dim_tarifa
UNION ALL SELECT 'dim_segmento', COUNT(*) FROM dw.dim_segmento
UNION ALL SELECT 'dim_sucursalsector', COUNT(*) FROM dw.dim_sucursalsector
UNION ALL SELECT 'dim_concepto', COUNT(*) FROM dw.dim_concepto
UNION ALL SELECT 'dim_eventocorte', COUNT(*) FROM dw.dim_eventocorte
UNION ALL SELECT 'hecho_facturacion', COUNT(*) FROM dw.hecho_facturacion
UNION ALL SELECT 'hecho_consumo', COUNT(*) FROM dw.hecho_consumo
UNION ALL SELECT 'hecho_cobranza', COUNT(*) FROM dw.hecho_cobranza
UNION ALL SELECT 'hecho_correcciones', COUNT(*) FROM dw.hecho_correcciones
UNION ALL SELECT 'hecho_cortes', COUNT(*) FROM dw.hecho_cortes;
