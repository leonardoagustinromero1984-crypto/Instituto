# Encuesta sociocomunitaria · ISFT N.º 93

Aplicación independiente de los módulos existentes de Instituto.

## Enlaces publicados
- Carga: https://leonardoagustinromero1984-crypto.github.io/Instituto/encuesta-comunitaria/
- Reportes: https://leonardoagustinromero1984-crypto.github.io/Instituto/encuesta-comunitaria/reporte.html

## Infraestructura
- GitHub Pages publica desde `master` (carpeta raíz).
- Proyecto Supabase: `tueivdkqbgzsybxxqnhr`.
- Configuración pública en `config.js` (solo URL y publishable key; **jamás** contraseñas ni service_role).
- Esquema de referencia en `schema.sql`, migraciones aplicadas en Supabase.

## Funcionalidad
- Encuesta sin nombres, DNI ni identificación directa. Aceptación voluntaria, fecha requerida y preguntas opcionales.
- Basada en el documento entregado `ENCUESTA 26(1).docx`. La pregunta 18 traía «Cena» repetida: se sustituyó provisionalmente una por «Almuerzo»; validar con docente.
- Enfermedades, servicios, alimentos y contaminación admiten varias opciones.
- Reportes públicos **sin inicio de sesión**: filtros por edad, enfermedad y fechas, pregunta/sección, torta, barras, CSV de resultados agregados.
- Seguridad: usuarios anónimos pueden insertar encuestas, **no** leer, modificar ni borrar registros individuales. Una función PostgreSQL privilegiada devuelve solo conteos permitidos.
- Los resultados se muestran desde una sola encuesta, incluyendo rangos de edad y categorías de una respuesta.

## Importante
El reporte es accesible para cualquier persona con la dirección web. **Con una sola encuesta, las estadísticas pueden revelar información de salud de esa persona.** Antes de recopilar información real, revisar con la institución y restringir el acceso al reporte. Implementar medidas contra cargas maliciosas, revisión de tratamiento de datos de salud, respaldo y política de conservación. No usar nombres ni datos identificables en textos libres.

## Pruebas
- Comprobada migración y configuración de permisos SQL.
- Comprobado el despliegue exitoso de GitHub Pages.
- Pendiente prueba manual de extremo a extremo con un navegador real y al menos una encuesta de prueba.

## Limpieza de registros ficticios (2026-10-24)
Se eliminaron las 25 encuestas ficticias que pertenecían al lote `ISFT93-DEMO-20261024-01` y tenían `es_prueba=true`. Se verificó que quedaba **1 encuesta sin marca de prueba**; el lote ficticio quedó vacío.

El reporte final ya no muestra avisos ni contadores de pruebas. Desde el 24/10/2026 se muestran estadísticas desde una sola encuesta, conforme a la indicación del usuario.

## Tablero visual (2026-10-24)
- **Vista general:** enfermedades, contaminación ambiental y cobertura médica en tres tortas; edades en barras a la derecha de enfermedades.
- **Vista filtrada:** al seleccionar una pregunta, enfermedad, edad o fechas, se muestra una sola torta y las barras de edades del mismo segmento.
- Franjas sin doble contabilización: 0–19, 20–39, 40–59, 60–79 y 80–100; 101–120 solo si existen encuestados.
- Colores vivos por categoría, leyendas, porcentaje de menciones y desglose CSV.
- Migración principal: `reporte_dashboard.sql`, aplicada a Supabase; llama a la RPC existente `reporte_encuesta` para las tortas.
- Las 25 encuestas ficticias se eliminaron el 24/10/2026; ninguna fue conservada como dato real.
