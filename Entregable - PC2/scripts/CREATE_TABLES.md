# Scripts de creación de tablas

## 1️⃣ Tabla `fisico`

```sql
CREATE EXTERNAL TABLE fisico (
    Sector STRING,
    tarifa STRING,
    categoria INT,
    descripcion STRING,
    clavedocu STRING,
    sucursal INT,
    clientes INT,
    clicarfijo INT,
    clienergia INT,
    clienhp INT,
    clienefp INT,
    clirefac INT,
    clidemfac INT,
    clidemfacfp INT,
    clidemfachp INT,
    clidemleida INT,
    clidemfacfp INT,
    clidemfachp INT,
    climalfacpot DOUBLE,
    consactivo DOUBLE,
    conenehp DOUBLE,
    promdia DOUBLE,
    conreact DOUBLE,
    demfacfp DOUBLE,
    demlifp DOUBLE,
    demfachp DOUBLE,
    demleihp DOUBLE,
    potcontr DOUBLE,
    potcontfp DOUBLE,
    potcontrhp DOUBLE,
    potinstfp DOUBLE,
    potinsthp DOUBLE,
    califica_o_no_califica STRING,
    DemandaGen INT,
    SectorTipico INT,
    zona_concesion INT,
    area_demanda INT,
    area_demanda_comp INT,
    Add STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ","   -- CSV con comas
STORED AS TEXTFILE
LOCATION '/lab/fisico'
TBLPROPERTIES ("skip.header.line.count"="1");


CREATE EXTERNAL TABLE soles (
    id INT,
    Tarifa STRING,
    nivel_tension STRING,
    Categoria INT,
    Grupo INT,
    Fose DOUBLE,
    Cargo INT,
    Desc_Cargo STRING,
    Clave_Docu STRING,
    Clave_Lec STRING,
    Consumo DOUBLE,
    Consumo_SI DOUBLE,
    IGV DOUBLE,
    IGV_SI DOUBLE,
    Califica STRING,
    Sector_Tipico INT,
    Contabilizable STRING,
    Lugar_Contable STRING,
    Tipo_Cliente STRING,
    Zona_de_Concesion STRING,
    Area_de_Demanda INT,
    sist_electrico STRING,
    Area_de_Demanda_comp INT,
    Add STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ","            -- CSV con comas
STORED AS TEXTFILE
LOCATION '/lab/soles'
TBLPROPERTIES ("skip.header.line.count"="1");

```sql