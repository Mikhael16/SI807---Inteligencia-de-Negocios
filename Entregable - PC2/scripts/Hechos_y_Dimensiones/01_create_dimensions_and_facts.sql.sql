-- =============================================
-- LUZ DEL SUR · DATA WAREHOUSE · STAR SCHEMA
-- PostgreSQL (compatibilidad amplia)
-- =============================================

-- 0) Esquema
CREATE SCHEMA IF NOT EXISTS dw;

-- 1) Drop seguro (hechos -> dimensiones)
DROP TABLE IF EXISTS dw.hecho_cortes        CASCADE;
DROP TABLE IF EXISTS dw.hecho_correcciones  CASCADE;
DROP TABLE IF EXISTS dw.hecho_cobranza      CASCADE;
DROP TABLE IF EXISTS dw.hecho_consumo       CASCADE;
DROP TABLE IF EXISTS dw.hecho_facturacion   CASCADE;

DROP TABLE IF EXISTS dw.dim_eventocorte     CASCADE;
DROP TABLE IF EXISTS dw.dim_concepto        CASCADE;
DROP TABLE IF EXISTS dw.dim_sucursalsector  CASCADE;
DROP TABLE IF EXISTS dw.dim_segmento        CASCADE;
DROP TABLE IF EXISTS dw.dim_tarifa          CASCADE;
DROP TABLE IF EXISTS dw.dim_suministro      CASCADE;
DROP TABLE IF EXISTS dw.dim_tiempo          CASCADE;

-- 2) DIMENSIONES

CREATE TABLE dw.dim_tiempo (
  tiempo_sk       BIGSERIAL PRIMARY KEY,
  anio            INTEGER NOT NULL CHECK (anio BETWEEN 1900 AND 2999),
  mes             INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
  periodo_yyyymm  INTEGER NOT NULL,
  trimestre       INTEGER NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
  es_fin_de_mes   BOOLEAN NOT NULL DEFAULT FALSE,
  vigencia_pliego TEXT,
  UNIQUE (periodo_yyyymm)
);

CREATE TABLE dw.dim_suministro (
  suministro_sk     BIGSERIAL PRIMARY KEY,
  suministro_id     TEXT NOT NULL,
  cliente_id        TEXT,
  medidor_id        TEXT,
  direccion         TEXT,
  fecha_alta        DATE,
  fecha_baja        DATE,
  estado            TEXT,
  vigente_desde     DATE NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta     DATE,
  scd2_actual_flag  BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX ix_dim_suministro_bk  ON dw.dim_suministro (suministro_id);
CREATE INDEX ix_dim_suministro_vig ON dw.dim_suministro (vigente_desde, vigente_hasta, scd2_actual_flag);

CREATE TABLE dw.dim_tarifa (
  tarifa_sk            BIGSERIAL PRIMARY KEY,
  codigo_tarifa        TEXT NOT NULL,
  nivel_tension        TEXT,
  categoria            TEXT,
  estructura_tarifaria TEXT,
  vigente_desde        DATE NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta        DATE,
  scd2_actual_flag     BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX ix_dim_tarifa_bk  ON dw.dim_tarifa (codigo_tarifa);
CREATE INDEX ix_dim_tarifa_vig ON dw.dim_tarifa (vigente_desde, vigente_hasta, scd2_actual_flag);

CREATE TABLE dw.dim_segmento (
  segmento_sk         BIGSERIAL PRIMARY KEY,
  segmento_codigo     TEXT NOT NULL,
  segmento_nombre     TEXT,
  regla_clasificacion TEXT,
  vigente_desde       DATE NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta       DATE,
  scd2_actual_flag    BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX ix_dim_segmento ON dw.dim_segmento (segmento_codigo, scd2_actual_flag);

CREATE TABLE dw.dim_sucursalsector (
  suc_sector_sk     BIGSERIAL PRIMARY KEY,
  empresa           TEXT,
  sucursal          TEXT,
  sector            TEXT,
  zona_comercial    TEXT,
  vigente_desde     DATE NOT NULL DEFAULT CURRENT_DATE,
  vigente_hasta     DATE,
  scd2_actual_flag  BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX ix_dim_sucursalsector ON dw.dim_sucursalsector (empresa, sucursal, sector);

CREATE TABLE dw.dim_concepto (
  concepto_sk      BIGSERIAL PRIMARY KEY,
  concepto_codigo  TEXT NOT NULL,
  concepto_nombre  TEXT,
  tipo_concepto    TEXT CHECK (tipo_concepto IN ('ENERGETICO','NO_ENERGETICO','IMPUESTO')),
  es_no_energetico BOOLEAN NOT NULL DEFAULT FALSE,
  afecta_igv       BOOLEAN NOT NULL DEFAULT TRUE,
  version_catalogo TEXT
);
CREATE INDEX ix_dim_concepto_cod ON dw.dim_concepto (concepto_codigo, version_catalogo);

CREATE TABLE dw.dim_eventocorte (
  evento_corte_sk         BIGSERIAL PRIMARY KEY,
  evento_id_negocio       TEXT,
  tipo_corte              TEXT,
  zona_afectada           TEXT,
  motivo                  TEXT,
  umbral_anticipacion_h   INTEGER NOT NULL DEFAULT 48 CHECK (umbral_anticipacion_h > 0),
  fecha_inicio_prog       TIMESTAMP,
  fecha_fin_prog          TIMESTAMP
);
CREATE INDEX ix_dim_eventocorte_zona ON dw.dim_eventocorte (zona_afectada);

-- 3) HECHOS

CREATE TABLE dw.hecho_facturacion (
  facturacion_sk          BIGSERIAL PRIMARY KEY,
  tiempo_sk               BIGINT NOT NULL REFERENCES dw.dim_tiempo(tiempo_sk),
  suministro_sk           BIGINT NOT NULL REFERENCES dw.dim_suministro(suministro_sk),
  tarifa_sk               BIGINT NOT NULL REFERENCES dw.dim_tarifa(tarifa_sk),
  segmento_sk             BIGINT NOT NULL REFERENCES dw.dim_segmento(segmento_sk),
  suc_sector_sk           BIGINT NOT NULL REFERENCES dw.dim_sucursalsector(suc_sector_sk),
  concepto_sk             BIGINT REFERENCES dw.dim_concepto(concepto_sk),

  factura_id              TEXT,
  periodo_yyyymm          INTEGER NOT NULL,
  lectura_tipo            TEXT CHECK (lectura_tipo IN ('REAL','ESTIMADA')),

  kwh_total               NUMERIC(18,6),
  kw_md                   NUMERIC(18,6),
  importe_energia         NUMERIC(18,6),
  importe_potencia        NUMERIC(18,6),
  importe_no_energeticos  NUMERIC(18,6),
  importe_impuestos       NUMERIC(18,6),
  importe_total           NUMERIC(18,6),

  ft_sin_igv              NUMERIC(18,6),
  fr_sin_igv              NUMERIC(18,6),
  divergencia_pct         NUMERIC(9,6),
  flag_anomalia_div       BOOLEAN DEFAULT FALSE
);
CREATE INDEX ix_hfact_periodo ON dw.hecho_facturacion (periodo_yyyymm);
CREATE INDEX ix_hfact_factura ON dw.hecho_facturacion (factura_id);
CREATE INDEX ix_hfact_flags   ON dw.hecho_facturacion (flag_anomalia_div);

CREATE TABLE dw.hecho_consumo (
  consumo_sk              BIGSERIAL PRIMARY KEY,
  tiempo_sk               BIGINT NOT NULL REFERENCES dw.dim_tiempo(tiempo_sk),
  suministro_sk           BIGINT NOT NULL REFERENCES dw.dim_suministro(suministro_sk),
  tarifa_sk               BIGINT NOT NULL REFERENCES dw.dim_tarifa(tarifa_sk),
  segmento_sk             BIGINT NOT NULL REFERENCES dw.dim_segmento(segmento_sk),
  suc_sector_sk           BIGINT NOT NULL REFERENCES dw.dim_sucursalsector(suc_sector_sk),

  periodo_yyyymm          INTEGER NOT NULL,
  lectura_tipo            TEXT CHECK (lectura_tipo IN ('REAL','ESTIMADA')),
  kwh                     NUMERIC(18,6),
  kvarh                   NUMERIC(18,6),
  kva                     NUMERIC(18,6),
  z_robusto               NUMERIC(12,6),
  flag_consumo_atipico    BOOLEAN DEFAULT FALSE
);
CREATE INDEX ix_hcons_periodo ON dw.hecho_consumo (periodo_yyyymm);
CREATE INDEX ix_hcons_flags   ON dw.hecho_consumo (flag_consumo_atipico);

CREATE TABLE dw.hecho_cobranza (
  cobranza_sk             BIGSERIAL PRIMARY KEY,
  tiempo_sk               BIGINT NOT NULL REFERENCES dw.dim_tiempo(tiempo_sk),
  suministro_sk           BIGINT NOT NULL REFERENCES dw.dim_suministro(suministro_sk),

  factura_id              TEXT,
  periodo_yyyymm          INTEGER NOT NULL,
  fecha_emision           DATE,
  fecha_vencimiento       DATE,
  fecha_pago              DATE,
  dias_mora               INTEGER,
  importe_pendiente       NUMERIC(18,6),
  flag_morosidad          BOOLEAN DEFAULT FALSE
);
CREATE INDEX ix_hcob_factura ON dw.hecho_cobranza (factura_id);
CREATE INDEX ix_hcob_periodo ON dw.hecho_cobranza (periodo_yyyymm);
CREATE INDEX ix_hcob_mora    ON dw.hecho_cobranza (flag_morosidad);

CREATE TABLE dw.hecho_correcciones (
  correccion_sk           BIGSERIAL PRIMARY KEY,
  tiempo_sk               BIGINT NOT NULL REFERENCES dw.dim_tiempo(tiempo_sk),
  suministro_sk           BIGINT NOT NULL REFERENCES dw.dim_suministro(suministro_sk),

  caso_id                 TEXT,
  factura_id              TEXT,
  fecha_deteccion         DATE,
  fecha_correccion        DATE,
  motivo_correccion       TEXT,
  proactiva_flag          BOOLEAN DEFAULT FALSE,
  dias_regularizacion     INTEGER
);
CREATE INDEX ix_hcorr_factura ON dw.hecho_correcciones (factura_id);
CREATE INDEX ix_hcorr_proact  ON dw.hecho_correcciones (proactiva_flag);

CREATE TABLE dw.hecho_cortes (
  cortes_sk               BIGSERIAL PRIMARY KEY,
  tiempo_sk               BIGINT NOT NULL REFERENCES dw.dim_tiempo(tiempo_sk),
  evento_corte_sk         BIGINT NOT NULL REFERENCES dw.dim_eventocorte(evento_corte_sk),
  suc_sector_sk           BIGINT NOT NULL REFERENCES dw.dim_sucursalsector(suc_sector_sk),

  clientes_afectados      INTEGER,
  clientes_notificados    INTEGER,
  anticipacion_horas_min  INTEGER,
  notificacion_oportuna   BOOLEAN DEFAULT FALSE
);
CREATE INDEX ix_hcortes_noti ON dw.hecho_cortes (notificacion_oportuna);

-- 4) Checks simples

ALTER TABLE dw.hecho_facturacion
  ADD CONSTRAINT ck_hfact_divergencia
  CHECK (divergencia_pct IS NULL OR divergencia_pct >= 0);

ALTER TABLE dw.hecho_cortes
  ADD CONSTRAINT ck_hcortes_clientes
  CHECK (
    clientes_notificados IS NULL
    OR clientes_afectados IS NULL
    OR clientes_notificados <= clientes_afectados
  );

-- (Opcional) comentarios
COMMENT ON TABLE dw.hecho_facturacion IS 'Incluye FT/FR sin IGV y divergencia.';
COMMENT ON TABLE dw.hecho_consumo     IS 'Medidas eléctricas y z_robusto por periodo/suministro.';
COMMENT ON TABLE dw.hecho_cobranza    IS 'Pagos y mora enlazados a factura.';
COMMENT ON TABLE dw.hecho_correcciones IS 'Casos, proactividad y días de regularización.';
COMMENT ON TABLE dw.hecho_cortes      IS 'Clientes afectados y notificación oportuna.';
