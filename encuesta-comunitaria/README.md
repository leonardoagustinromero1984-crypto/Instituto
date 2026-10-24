# Encuesta sociocomunitaria · ISFT N° 93

Nueva aplicación independiente de las otras carpetas del repositorio Instituto.

## Accesos
- Carga: `/encuesta-comunitaria/`
- Reportes: `/encuesta-comunitaria/reporte.html`

## Instalación (pendiente de configurar por titular)
1. Crear un proyecto Supabase dedicado. Ejecutar `schema.sql` desde el SQL Editor.
2. Completar `config.js` con **Project URL** y **publishable/anon key**. Nunca incluir la **service_role key**.
3. Habilitar Authentication con email y contraseña y crear manualmente las cuentas de los compañeros que puedan ver reportes. Autorizar sólo a quienes puedan consultar: después de crear cada cuenta, copiar su UID desde Authentication → Users y ejecutar en SQL Editor: `insert into public.encuesta_reporteros(user_id) values ('UUID-DEL-USUARIO');`. No habilitar altas públicas para el reporte.
4. Publicar GitHub Pages de la rama principal una vez revisada la funcionalidad; esta implementación vive inicialmente en una rama de trabajo.
5. Crear dos QR distintos a partir de las URL reales de carga y reporte, una vez publicada la versión estable.

## Características
- Encuestas anónimas sin nombre ni DNI; preguntas opcionales salvo fecha y aceptación.
- Las secciones se basan en el documento `ENCUESTA 26(1).docx`. La opción repetida «Cena» en la pregunta 18 se normalizó como «Almuerzo»; verificarlo con el docente.
- Varias respuestas seleccionables para enfermedades, servicios, alimentación y contaminación.
- Filtros de reporte por edad, enfermedad y fechas; selector por pregunta/sección.
- Gráficos de torta y barras; CSV con resultados agregados.
- RLS: la API pública puede insertar, no leer ni borrar registros individuales.
- RPC de resumen para usuarios autenticados y supresión de categorías con menos de 3 ocurrencias.

## Antes de usar con personas reales
- Confirmar la revisión del formulario y consentimiento con la institución.
- Limitar quién puede crear cuentas y acceder a reportes. Los informes por filtros muy estrechos pueden revelar información incluso sin nombres; incrementar umbral y limitar filtros si hace falta.
- Añadir anti-spam/rate limiting, política de conservación/borrado de datos, respaldo y aviso de privacidad institucional.
- Validar pruebas multiusuario, móviles y operación real de base de datos.
- No se han cargado datos de personas ni activado un servicio de producción.

## Privacidad
Las respuestas incluyen posibles datos de salud; deben tratarse con controles de acceso y minimización. Este prototipo requiere endurecimiento de permisos antes de producción.
