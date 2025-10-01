# Consultas SQL para las tablas `Fisico` y `Soles`

## 1️⃣ Top 10 registros con mayor `consumo activo` de la tabla `fisico`

```sql
SELECT 
    Sector,
    tarifa,
    categoria,
    descripcion,
    clavedocu,
    sucursal,
    consactivo,
    califica_o_no_califica
FROM 
    fisico
ORDER BY 
    consactivo DESC
LIMIT 10;
```

---

## 2️⃣ Suma total de `consumo activo` por tarifa (Top 10) en la tabla `fisico`

```sql
SELECT 
    tarifa,
    SUM(consactivo) AS total_consumo
FROM 
    fisico
GROUP BY 
    tarifa
ORDER BY 
    total_consumo DESC
LIMIT 10;
```

---

## 3️⃣ Conteo de registros por `SectorTipico` en la tabla `fisico`

```sql
SELECT 
    SectorTipico, 
    COUNT(*) AS cantidad_registros
FROM 
    fisico
GROUP BY 
    SectorTipico
ORDER BY 
    cantidad_registros DESC;
```

---

## 4️⃣ Promedio de `consumo activo` por `zona_concesion` (Top 10)

```sql
SELECT 
    zona_concesion,
    AVG(consactivo) AS promedio_consumo
FROM 
    fisico
GROUP BY 
    zona_concesion
ORDER BY 
    promedio_consumo DESC
LIMIT 10;
```

---

## 5️⃣ Filtrar registros por `categoria`

```sql
SELECT 
    Sector,
    tarifa,
    categoria,
    descripcion,
    consactivo
FROM 
    fisico
WHERE 
    categoria = 0
ORDER BY 
    consactivo DESC
LIMIT 10;
```

---

## 6️⃣ Top 10 registros con mayor `Consumo`

```sql
SELECT 
    id, 
    Tarifa, 
    nivel_tension, 
    Categoria, 
    Fose, 
    Consumo, 
    Consumo_SI, 
    IGV, 
    IGV_SI, 
    Califica
FROM 
    soles
ORDER BY 
    Consumo DESC
LIMIT 10;
```

---

## 7️⃣ Suma total de `Consumo` por `Tarifa` (Top 10)

```sql
SELECT 
    Tarifa, 
    SUM(Consumo) AS total_consumo
FROM 
    soles
GROUP BY 
    Tarifa
ORDER BY 
    total_consumo DESC
LIMIT 10;
```

---

## 8️⃣ Conteo de registros por `Sector_Tipico`
```sql
SELECT 
    Sector_Tipico, 
    COUNT(*) AS cantidad_registros
FROM 
    soles
GROUP BY 
    Sector_Tipico
ORDER BY 
    cantidad_registros DESC;
```

---

## 9️⃣ Promedio de `Consumo` por `Tarifa`

```sql
SELECT 
    Tarifa, 
    AVG(Consumo) AS promedio_consumo
FROM 
    soles
GROUP BY 
    Tarifa
ORDER BY 
    promedio_consumo DESC
LIMIT 10;
```

---

