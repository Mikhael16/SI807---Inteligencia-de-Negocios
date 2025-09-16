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
- *VirtualBox + Hadoop (Ambari)*: Se configuró una máquina virtual con Hadoop para pruebas iniciales. Se subió el archivo *“flights”* y se creó la tabla en Ambari como validación del entorno de Big Data.  

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

---

Este documento corresponde al entregable de la *Semana 3 – Arquitectura Preliminar* del curso SI807 – Sistemas de Inteligencia de Negocios.

