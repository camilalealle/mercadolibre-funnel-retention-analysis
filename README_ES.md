# MercadoLibre | Embudo de conversión y retención por cohortes

**SQL (SQLite) · Python · Pandas · Matplotlib · HTML**

🌐 [English](README.md) · **Español**

Caso de estudio educativo inspirado en MercadoLibre sobre el recorrido de compra (enero–agosto de 2025) y la actividad de los usuarios durante sus primeros 28 días después del registro. El objetivo es identificar dónde dejan de avanzar los usuarios, describir patrones de retención y proponer áreas de investigación.

**[Explorar el dashboard interactivo](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html)**

---

## Resumen ejecutivo

- **Principal cuello de botella:** solo **104 de 845 usuarios (12,31 %)** avanzaron de la selección de producto al carrito en el embudo cronológico estricto: una caída del **87,69 %**.
- **Finalización del embudo:** **11 de 1.204 usuarios (0,91 %)** con un evento `first_visit` completaron las siete etapas en secuencia. Esta **no** es la tasa global de conversión a compra de la plataforma.
- **Baja retención temprana:** entre **12.000 usuarios registrados**, la actividad en días específicos pasó de **24,23 % en D7** a **2,60 % en D28**.

**Prioridad empresarial:** investigar la fricción entre selección y carrito, validar el registro de eventos y probar iniciativas de participación temprana. Son prioridades de investigación, no causas demostradas ni incrementos de ventas previstos.

## Preguntas de negocio

1. ¿En qué etapas dejan de avanzar los usuarios durante el recorrido de compra?
2. ¿Cómo difiere el recorrido de compra observado del conteo total de eventos?
3. ¿Cómo cambia la retención después del registro, según cohortes y dispositivos?

## Dashboard

**[Abrir el dashboard ejecutivo interactivo](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html)** · [Archivo HTML](dashboard/mercadolibre_dashboard_ejecutivo.html)

*Los datos de embudo y retención representan poblaciones diferentes; no deben interpretarse como un único recorrido de clientes.*

## Hallazgos clave

### 1. Embudo de conversión

**Período:** 1 de enero–31 de agosto de 2025. Las dos vistas miden conceptos distintos: usuarios que registraron cada evento en cualquier orden y usuarios que alcanzaron todas las etapas anteriores en orden cronológico (posiblemente en varias sesiones).

| Etapa | Usuarios con el evento (cualquier orden) | Usuarios en secuencia estricta | Conversión entre etapas |
|---|---:|---:|---:|
| `first_visit` | 1.204 | 1.204 | — |
| `select_item / select_promotion` | 1.309 | 845 | 70,18 % |
| `add_to_cart` | 174 | 104 | **12,31 %** |
| `begin_checkout` | 60 | 37 | 35,58 % |
| `add_shipping_info` | 40 | 23 | 62,16 % |
| `add_payment_info` | 33 | 19 | 82,61 % |
| `purchase` | 17 | **11** | 57,89 % |

- **Mayor caída observada:** selección de producto → carrito (**741 usuarios; 87,69 %** de quienes llegaron a la etapa anterior en la secuencia estricta).
- **Otra caída relevante:** carrito → inicio del checkout (**64,42 %**).
- **Distinción entre compras y recorridos:** **17 usuarios** registraron `purchase`; **11** completaron toda la secuencia estricta. Los eventos fuera de orden o no observados pueden afectar el conteo. No avanzar en el embudo observado no demuestra abandono definitivo.
- La conversión por país es **exploratoria**: se observaron solo 11 conversiones de primera visita a compra y las muestras por país son pequeñas. Estas tasas no permiten establecer clasificaciones concluyentes de mercados.

### 2. Retención

**Población:** 12.000 usuarios registrados; cohortes de enero–agosto de 2025, con observaciones de D0 a D28.

| Día después del registro | D7 | D14 | D21 | D28 |
|---|---:|---:|---:|---:|
| Usuarios activos ese día | 2.908 | 1.389 | 606 | 312 |
| Retención | **24,23 %** | **11,57 %** | **5,05 %** | **2,60 %** |

- La retención D7 osciló entre **22,48 % y 26,07 %** en ocho cohortes mensuales, sin una tendencia sostenida de mejora.
- En D7, **móvil: 25,25 %** (8.963 usuarios) frente a **escritorio: 21,23 %** (2.421 usuarios). Es una diferencia descriptiva, no evidencia de un efecto causal del dispositivo.
- Estas tasas miden **actividad en un día específico**, no uso continuo ni recompra.

## Calidad de datos y validación

- **Embudo:** 61.235 eventos originales con **6 duplicados exactos**; el período seleccionado contiene **26.695 eventos** de **1.755 usuarios únicos**.
- **Retención:** **696.000 filas originales** se reducen a **348.000 registros distintos**; cada registro distinto aparecía dos veces. Los 12.000 usuarios tienen observaciones completas de D0 a D28.
- **Validación de fechas:** fue necesario normalizar **25.684** valores de `event_date` con horas de un solo dígito para que SQLite pudiera interpretarlos; el campo separado `event_times` no era apropiado para reconstruir con precisión el orden de eventos.
- La deduplicación y normalización se realizaron dentro del análisis, sin modificar la base de datos original.

## Recomendaciones

1. **Investigar selección → carrito:** revisar claridad de la ficha de producto, precios, información de entrega y usabilidad, y probar hipótesis específicas sin asumir una causa.
2. **Auditar el registro del embudo y carrito → checkout:** confirmar que los eventos se capturen consistentemente antes de interpretar etapas faltantes como abandono.
3. **Probar iniciativas de participación temprana:** evaluar experimentos de incorporación o reactivación y monitorear D7, D14 y D28 por cohorte.

## Metodología

| Paso | Enfoque | Evidencia |
|---|---|---|
| 1 | Exploración y validación de datos | [Notebook 01](notebooks/01_data_exploration.ipynb) |
| 2 | Alcance de eventos y embudo cronológico (CTE de SQL) | [Notebook 02](notebooks/02_funnel_analysis.ipynb) · [SQL](sql/01_funnel_analysis.sql) |
| 3 | Retención por cohortes, países y dispositivos | [Notebook 03](notebooks/03_retention_analysis.ipynb) · [SQL](sql/02_retention_analysis.sql) |
| 4 | Comunicación empresarial | [Dashboard público](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html) |

Se contrastaron los resultados de las consultas SQL independientes con los de los notebooks.

## Limitaciones

- **Datos educativos:** no es un análisis oficial de MercadoLibre.
- **Muestra pequeña de compras:** 17 usuarios con evento de compra en el período del embudo limitan las conclusiones de conversión y por país.
- **Definición estricta del recorrido:** los eventos deben ocurrir en orden; pueden abarcar varias sesiones, y fallas o cambios de orden en el registro reducen el número de recorridos completos.
- **Poblaciones diferentes:** embudo y retención emplean tablas y períodos distintos; no se estableció una conexión individual entre usuarios.
- **Evidencia observacional:** las diferencias por dispositivo y las caídas del embudo no explican sus causas.

## Estructura del repositorio

```text
mercadolibre-funnel-retention-analysis/
├── dashboard/    # Dashboard HTML interactivo
├── data/raw/     # Base SQLite local; excluida de Git
├── notebooks/    # Exploración, embudo y retención
├── sql/          # Consultas SQLite independientes
├── .gitignore
├── requirements.txt
├── README.md
└── README_ES.md
```

## Cómo ejecutar el proyecto

<details>
<summary>Instrucciones de configuración</summary>

1. Instala las dependencias: `python -m pip install -r requirements.txt`.
2. Coloca una copia autorizada de `tripleten.db`, con las tablas `mercadolibre_funnel` y `mercadolibre_retention`, en `data/raw/`. **La base de datos no está incluida en este repositorio.**
3. Ejecuta los notebooks en orden numérico desde la carpeta `notebooks/` o consulta sus resultados guardados. Los archivos `.sql` pueden ejecutarse por separado con SQLite. El [dashboard público](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html) no necesita la base de datos.

</details>

## Acerca del proyecto

Desarrollado por **Camila Leal Ledesma** como proyecto de portafolio de Data Analytics basado en un ejercicio de TripleTen, ampliado con validación de datos, análisis cronológico del embudo y presentación ejecutiva.

[LinkedIn](https://www.linkedin.com/in/camila-leal-ledesma/) · [GitHub](https://github.com/camilalealle)
