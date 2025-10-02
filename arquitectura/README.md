# Arquitectura Data Mart – Problema 2: Cobro Excesivo de Factura

Este entregable incluye el diagrama de arquitectura en formato *PowerPoint* con nombre:  
*Arquitectura_DM.pptx*  

El diagrama refleja el flujo de datos desde las fuentes hasta el consumo en dashboards, pasando por procesos ETL y las capas de la arquitectura Medallion (Bronze–Silver–Gold).

## Justificación de la arquitectura elegida
Se adoptó una arquitectura *Data Mart Comercial* bajo el enfoque *Kimball* complementada con el modelo de capas *Medallion*.  
- El problema a resolver (cobros excesivos de factura) requiere rapidez y foco en el área comercial.  
- La separación en capas garantiza trazabilidad (Bronze), limpieza y conformado (Silver) y resultados analíticos (Gold).  
- El modelo dimensional facilita los cálculos de KPIs de facturación y consumos atípicos.  
- La solución es escalable y aprovecha tecnologías de análisis y visualización modernas.

## Roles de las herramientas
- *Excel (.xlsb, .xlsx)*: Archivos fuente de facturación, consumos y conceptos.  
- *PySpark*: Motor de procesos ETL para limpieza, validación (IGV, FOSE, lecturas), normalización y calidad de datos.  
- *PostgreSQL / Hadoop*: Almacenamiento del Data Warehouse y soporte al Data Mart.  
- *Power BI*: Herramienta de consumo de datos para dashboards y monitoreo de KPIs.  
- *Gobernanza (catálogo, linaje, accesos)*: Eje transversal que asegura control, seguridad y trazabilidad.  
- *VirtualBox + Hortonworks Data Platform (HDP)*: Entorno de pruebas desplegado en una máquina virtual, que integra el ecosistema 
- *Hadoop (HDFS, YARN)*: Infraestructura Big Data que provee almacenamiento distribuido (HDFS) y orquestación de recursos/procesos (YARN), base para la gestión del Data Mart en entornos masivos.
- *Ambari*: Herramienta de administración y monitoreo del clúster Hadoop/HDP, utilizada para crear y gestionar tablas (ej. prueba con dataset *“flights”*).

## Riesgos identificados y mitigaciones
- *Calidad de datos*: Inconsistencias en FOSE, IGV o lecturas estimadas.  
  Mitigación: Reglas de validación en PySpark y auditorías periódicas.  
- *Integración de tarifas reguladas*: Desfase con actualizaciones normativas.  
  Mitigación: Ingesta programada y control de versiones.  
- *Escalabilidad*: Crecimiento de registros históricos de facturación.  
  Mitigación: Uso de Hadoop/Parquet y particionado por fechas.  
- *Gobernanza*: Riesgo de accesos indebidos o pérdida de trazabilidad.  
  Mitigación: Catálogo de datos, linaje documentado y control de accesos por rol.  
- *Dependencia de archivos planos (.xlsb/.xlsx)*: Errores manuales en cargas.  
  Mitigación: Automatización de ingestas y alertas de errores.

## Próximos pasos
- *Docker*: Contenerizar el pipeline ETL y el Data Mart para portabilidad entre entornos.  
- *Automatización de cargas*: Implementar programación de ingestas y validaciones.  
- *KPIs adicionales*: Integrar métricas regulatorias (ej. calidad de servicio) en el Data Mart.
- *Consolidación de entorno Big Data*: Aprovechar el uso de *VirtualBox*, *Hortonworks Data Platform (HDP)*, *Hadoop* y *Ambari* como base para el desarrollo y pruebas del proyecto de BI, asegurando escalabilidad y administración centralizada del clúster  

---

Este documento corresponde al entregable de la *Semana del 15/09* del curso SI807 – Sistemas de Inteligencia de Negocios.

# Hechos y Dimensiones - Entregable 2 (29/09/2025)

# Luz del Sur · Data Warehouse (PostgreSQL) — Star Schema

Repositorio de scripts SQL para crear y poblar un esquema estrella (**DW**) en PostgreSQL.

## Requisitos
- PostgreSQL 13+
- Usuario con permisos para crear esquemas/tablas e insertar datos

## Estructura
```
SI807---Inteligencia-de-Negocios/Entregable - PC2/scripts/Hechos_y_Dimensiones/
└── scripts/
    ├── 01_create_dimensions_and_facts.sql   # Crea esquema, dimensiones y hechos (DDL)
    └── 02_insert_seed_data.sql        # Inserta datos mínimos y hace quick checks (DML)
```

## Ejecución (en orden)
```bash
# 1) Crear esquema y tablas (DDL)
psql -U <usuario> -d <basedatos> -f scripts/01_create_dimensions_and_facts.sql

# 2) Semillas mínimas + verificaciones (DML)
psql -U <usuario> -d <basedatos> -f scripts/02_insert_seed_data.sql 
```

### ¿Qué crea el DDL?
- Esquema `dw`
- **Dimensiones:** `dim_tiempo`, `dim_suministro` (SCD2), `dim_tarifa` (SCD2),
  `dim_segmento` (SCD2), `dim_sucursalsector` (SCD2), `dim_concepto`, `dim_eventocorte`
- **Hechos:** `hecho_facturacion`, `hecho_consumo`, `hecho_cobranza`, `hecho_correcciones`, `hecho_cortes`
- Índices operativos y `CHECK` de calidad de datos

### ¿Qué hace el DML?
- Inserta **registros mínimos** en todas las dimensiones (para pruebas).
- Usa `WITH ids AS (...)` para capturar SKs recientes y crear filas de hechos consistentes.
- Incluye una **vista rápida** de conteos por tabla (UNION ALL) para validar el insert.

## Convenciones
- `snake_case`
- Claves sustitutas `*_sk` (`BIGSERIAL`)
- SCD2 en dimensiones operativas (`vigente_desde`, `vigente_hasta`, `scd2_actual_flag`)

## Siguientes pasos útiles
- Poblar `dim_tiempo` completa (años/meses requeridos).
- Cargar catálogos reales de `dim_concepto`, `dim_tarifa`, `dim_segmento`.
- Crear **vistas de KPIs** (divergencia de FT vs FR, mora, consumos atípicos).
- Agregar FKs con `ON UPDATE/DELETE` según reglas de negocio.