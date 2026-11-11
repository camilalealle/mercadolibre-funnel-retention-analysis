# MercadoLibre | Análisis de embudo de conversión y retención por cohortes

**SQL (SQLite) · Python · Pandas · Visualización de datos**

🌐 [English](README.md) · **Español**

Análisis del comportamiento de usuarios en un conjunto de datos educativo inspirado en MercadoLibre: recorrido de compra entre enero y agosto de 2025 y actividad durante los 28 días posteriores al registro. El proyecto reúne validación de datos, análisis con SQL y recomendaciones de negocio.

---

## Índice

1. [Resumen ejecutivo](#resumen-ejecutivo)
2. [Preguntas de negocio](#preguntas-de-negocio)
3. [Dashboard](#dashboard)
4. [Hallazgos principales](#hallazgos-principales)
5. [Calidad y validación de datos](#calidad-y-validación-de-datos)
6. [Recomendaciones](#recomendaciones)
7. [Metodología](#metodología)
8. [Limitaciones](#limitaciones)
9. [Estructura del repositorio](#estructura-del-repositorio)
10. [Cómo ejecutar el proyecto](#cómo-ejecutar-el-proyecto)
11. [Acerca del proyecto](#acerca-del-proyecto)

---

## Resumen ejecutivo

- **La mayor pérdida observada ocurre entre selección y carrito.** En el embudo cronológico estricto, los usuarios pasan de **845** en `select_item / select_promotion` a **104** en `add_to_cart`: un **87,69 %** no avanzó a la siguiente etapa exigida.
- **La finalización del embudo estricto es del 0,91 %.** **11 de 1.204** usuarios con `first_visit` completaron las siete etapas en orden. **No es la conversión general de ventas** de la plataforma.
- **Hay muy pocas compras para comparar países con solidez.** **17 usuarios** registraron `purchase`; **11** realizaron una compra posterior a su `first_visit` observado en el período. Las tasas por país son exploratorias.
- **La retención de actividad cae durante el primer mes.** Entre **12.000 usuarios registrados**, la retención D7 es del **24,23 %**, frente al **2,60 % en D28**.
- **El descenso aparece en cohortes y dispositivos.** Las cohortes mensuales muestran patrones similares. Los usuarios móviles presentan una mayor retención D7 observada (**25,25 %**) que los de escritorio (**21,23 %**), sin que esto demuestre causalidad.
- **La calidad de datos fue relevante.** La tabla de retención contiene **348.000 registros distintos, cada uno repetido dos veces**; también fue necesario normalizar fechas de eventos.

---

## Preguntas de negocio

| # | Pregunta | Respuesta en |
|---|---|---|
| 1 | ¿Podemos confiar en los datos? | [Calidad y validación de datos](#calidad-y-validación-de-datos) |
| 2 | ¿Dónde dejan de avanzar los usuarios en el proceso de compra? | [Embudo de conversión](#1-embudo-de-conversión) |
| 3 | ¿Cómo varía la conversión entre países? | [Conversión por país](#2-conversión-por-país) |
| 4 | ¿Cómo cambia la actividad después del registro? | [Retención general](#3-retención-general-de-usuarios) |
| 5 | ¿Qué diferencias existen entre cohortes y segmentos? | [Cohortes y segmentos](#4-retención-por-cohortes-y-segmentos) |

---

## Dashboard

📊 [Ver dashboard interactivo](https://camilalealle.github.io/mercadolibre-funnel-retention-analysis/dashboard/mercadolibre_dashboard_ejecutivo.html)

El dashboard reúne un resumen ejecutivo, el embudo de conversión y la retención D7–D28. Para visualizarlo, abre el archivo HTML en un navegador después de descargar o clonar el repositorio. Cuando se configure GitHub Pages, se podrá añadir un enlace de visualización pública.

*Las métricas de funnel y retención provienen de datasets diferentes y no deben interpretarse como si describieran un único recorrido de clientes conectado.*

---

## Hallazgos principales

### 1. Embudo de conversión

**Período:** del 1 de enero al 31 de agosto de 2025, inclusive.

| Evento | Usuarios únicos que registraron el evento | Usuarios que alcanzaron la etapa en orden cronológico estricto |
|---|---:|---:|
| `first_visit` | 1.204 | 1.204 |
| `select_item / select_promotion` | 1.309 | 845 |
| `add_to_cart` | 174 | 104 |
| `begin_checkout` | 60 | 37 |
| `add_shipping_info` | 40 | 23 |
| `add_payment_info` | 33 | 19 |
| `purchase` | 17 | **11 (0,91 %)** |

- **Mayor caída entre etapas:** `select_item / select_promotion` → `add_to_cart`: **741 usuarios**, equivalentes al **87,69 %** de los 845 usuarios que habían completado las etapas anteriores.
- **Otra transición importante:** `add_to_cart` → `begin_checkout`: **64,42 %** no alcanzó la siguiente etapa requerida.
- **Validación de los compradores:** 17 registraron `purchase`; 15 registraron los siete tipos de evento sin importar el orden; 11 completaron la secuencia cronológica. Los cuatro compradores con cobertura completa que quedaron fuera del embudo estricto no registraron un `add_to_cart` *posterior a la selección válida* dentro de esa secuencia.

*El embudo permite eventos entre sesiones diferentes. No avanzar en la secuencia observada no demuestra que alguien haya abandonado definitivamente su compra.*

### 2. Conversión por país

La **conversión de primera visita a compra** mide usuarios con un `purchase` posterior a su primer `first_visit` observado durante el período. Se asigna el país de esa primera visita y no se exigen los eventos intermedios.

| País | Usuarios con `first_visit` | Usuarios convertidos | Tasa de conversión |
|---|---:|---:|---:|
| Uruguay | 22 | 1 | 4,55 % |
| Bolivia | 31 | 1 | 3,23 % |
| Perú | 110 | 2 | 1,82 % |
| México | 245 | 4 | 1,63 % |
| Brasil | 292 | 2 | 0,68 % |
| Argentina | 160 | 1 | 0,63 % |
| Paraguay | 21 | 0 | 0,00 % |
| Ecuador | 59 | 0 | 0,00 % |
| Colombia | 166 | 0 | 0,00 % |
| Chile | 98 | 0 | 0,00 % |

**11 de 1.204** usuarios compraron bajo esta definición (**0,91 %** en total). La cifra coincide numéricamente con la finalización del embudo estricto, pero **son métricas distintas** y no deben confundirse.

Uruguay tiene la tasa *observada* más alta, basada en **un solo comprador**. La muestra no permite establecer rankings confiables ni tomar decisiones comerciales importantes por país.

### 3. Retención general de usuarios

**Registros:** del 1 de enero al 25 de agosto de 2025. **Seguimiento:** D0–D28.

| Día después del registro | Usuarios activos | Tasa de retención |
|---|---:|---:|
| D7 | 2.908 | **24,23 %** |
| D14 | 1.389 | **11,57 %** |
| D21 | 606 | **5,05 %** |
| D28 | 312 | **2,60 %** |

La retención mide actividad **en un día específico**, no actividad continua durante todos los días anteriores. La mayor caída en puntos porcentuales entre los días mostrados ocurre de D7 a D14: **12,66 puntos porcentuales**.

### 4. Retención por cohortes y segmentos

- **Cohortes mensuales:** D7 oscila entre **22,48 % y 26,07 %**; D28 entre **2,02 % y 3,04 %**. No se observa una mejora sostenida entre las ocho cohortes.
- **Países:** México presenta la mayor retención D28 observada (**3,32 %**) y Colombia la menor (**1,83 %**). Todos los países muestran actividad baja en D28.
- **Dispositivos:** Mobile agrupa **8.963 de 12.000 usuarios** (aproximadamente **74,7 %**) y presenta mayor retención observada en D7 y D28.

| Dispositivo | Usuarios | D7 | D28 |
|---|---:|---:|---:|
| Mobile | 8.963 | 25,25 % | 2,76 % |
| Desktop | 2.421 | 21,23 % | 2,11 % |
| Tablet | 616 | 21,27 % | 2,27 % |

Estas comparaciones son descriptivas. No demuestran que el país o el dispositivo causen diferencias en la retención.

---

## Calidad y validación de datos

**Comprobaciones y decisiones**

- **Funnel:** 61.235 registros originales y 2.901 usuarios únicos en todo el historial; se identificaron **6 filas exactamente duplicadas**. Para enero–agosto de 2025 analizamos **26.695 eventos y 1.755 usuarios únicos**.
- **Retención:** 696.000 filas originales, **348.000 distintas** y 12.000 usuarios. Cada fila distinta aparece dos veces. Se excluyen las copias exactas adicionales en los cálculos, sin modificar la fuente.
- **Campos clave:** no se encontraron valores NULL ni vacíos en los identificadores, países y demás campos fundamentales revisados.
- **Seguimiento:** los 12.000 usuarios de retención tienen observaciones diarias de D0 a D28; `active` solo contiene valores válidos (0 y 1).
- **Fechas:** `event_times` está expresado en microsegundos y tiene precisión limitada. **25.684** valores de `event_date` fallaron inicialmente al interpretarse en SQLite por horas de un solo dígito; la normalización resolvió esos casos.

La base SQLite original permanece sin modificaciones. La limpieza necesaria se aplica dentro de las consultas SQL.

---

## Recomendaciones

1. **Investigar la transición entre selección y carrito.** Revisar información de productos, claridad de precios, expectativas de envío y usabilidad antes de decidir cambios.
2. **Revisar el paso de carrito a checkout.** Investigar posibles obstáculos y validar los eventos antes de atribuir diferencias de conteos a abandonos reales.
3. **Priorizar la actividad temprana.** Explorar mejoras de incorporación y reactivación, y comprobar mediante experimentos si elevan D7, D14 y D28.
4. **Monitorear cohortes y segmentos.** Observar tendencias antes de actuar por diferencias descriptivas pequeñas.
5. **Recoger más observaciones de compra.** Se necesita un mayor número de conversiones para comparar países con más confianza.

---

## Metodología

| Paso | Pregunta | Herramientas | Notebook / SQL |
|---|---|---|---|
| 1 | ¿Podemos confiar en los datos? | Python, SQLite, Pandas | [01_data_exploration](notebooks/01_data_exploration.ipynb) |
| 2 | ¿Dónde dejan de avanzar los usuarios? | SQL (CTEs, joins, funciones de ventana), Python | [02_funnel_analysis](notebooks/02_funnel_analysis.ipynb) · [SQL de funnel](sql/01_funnel_analysis.sql) |
| 3 | ¿Siguen activos los usuarios después del registro? | SQL, Pandas, Matplotlib | [03_retention_analysis](notebooks/03_retention_analysis.ipynb) · [SQL de retención](sql/02_retention_analysis.sql) |
| 4 | ¿Cómo comunicamos los resultados? | HTML, visualizaciones interactivas | [Dashboard](dashboard/mercadolibre_dashboard_ejecutivo.html) |

Los notebooks y consultas utilizan una fuente SQLite local. Los resultados de SQL se contrastaron entre los notebooks y las consultas independientes.

---

## Limitaciones

- **Datos educativos:** es un caso de estudio educativo inspirado en MercadoLibre, **no un análisis oficial encargado por la empresa**.
- **Pocas compras:** solo 17 usuarios registraron `purchase` en el período de funnel seleccionado. Las comparaciones geográficas son exploratorias.
- **Embudo estricto:** exige las siete etapas en orden, incluso entre sesiones distintas. Eventos ausentes o fuera de orden reducen el conteo aunque haya una compra registrada.
- **Calidad temporal:** `event_date` requirió normalización y `event_times` tiene precisión limitada; el orden registrado depende de esas limitaciones.
- **Poblaciones distintas:** las tablas de funnel y retención presentan cantidades y períodos diferentes; no se validó su relación usuario a usuario.
- **Significado de retención:** D7, D14, D21 y D28 miden actividad en días puntuales, no participación continua ni recompra.
- **Causalidad:** las diferencias observadas no explican sus causas; las acciones sugeridas requieren investigación y pruebas adicionales.

---

## Estructura del repositorio

```text
mercadolibre-funnel-retention-analysis/
├── dashboard/
│   └── mercadolibre_dashboard_ejecutivo.html
├── data/
│   └── raw/           # Base SQLite local (excluida de Git)
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_funnel_analysis.ipynb
│   └── 03_retention_analysis.ipynb
├── sql/
│   ├── 01_funnel_analysis.sql
│   └── 02_retention_analysis.sql
├── .gitignore
├── requirements.txt
├── README.md          # Versión en inglés
└── README_ES.md       # Versión en español
```

---

## Cómo ejecutar el proyecto

<details>
<summary>Instrucciones de configuración</summary>

### 1. Preparar el entorno

Clona el repositorio e instala las dependencias:

```bash
python -m pip install -r requirements.txt
```

### 2. Preparar la base de datos

La base de datos SQLite original (`tripleten.db`) no está incluida en este repositorio. Para reproducir el análisis, crea `data/raw/` si es necesario y coloca una copia autorizada que contenga las tablas `mercadolibre_funnel` y `mercadolibre_retention` en `data/raw/tripleten.db`.

### 3. Explorar el análisis

Ejecuta los notebooks en orden numérico (con `notebooks/` como directorio de trabajo) o consulta sus resultados guardados:

- [Exploración de datos](notebooks/01_data_exploration.ipynb)
- [Análisis del embudo de conversión](notebooks/02_funnel_analysis.ipynb)
- [Análisis de retención](notebooks/03_retention_analysis.ipynb)

Las [consultas SQL](sql/) se pueden ejecutar por separado en SQLite, una sentencia a la vez. El [dashboard interactivo](dashboard/mercadolibre_dashboard_ejecutivo.html) se puede abrir en un navegador sin acceder a la base de datos.

</details>

---

## Acerca del proyecto

Desarrollado por **Camila Leal Ledesma** como proyecto educativo de portafolio de Data Analytics basado en un ejercicio de TripleTen, ampliado con validaciones de datos, análisis cronológico del embudo y presentación de resultados.

[LinkedIn](https://www.linkedin.com/in/camila-leal-ledesma/) · [GitHub](https://github.com/camilalealle)
