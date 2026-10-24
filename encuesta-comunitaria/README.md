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
- Protección estadística básica: no se entregan resultados si un segmento tiene entre 1 y 4 personas y se ocultan categorías con menos de 3 menciones.

## Importante
El reporte es accesible para cualquier persona con la dirección web. La supresión de grupos pequeños **no garantiza anonimato absoluto** frente a comparaciones de múltiples filtros; revisar con la institución antes de encuestar personas reales y considerar restringir el reporte en ese escenario. Implementar medidas contra cargas maliciosas, revisión de tratamiento de datos de salud, respaldo y política de conservación. No usar nombres ni datos identificables en textos libres.

## Pruebas
- Comprobada migración y configuración de permisos SQL.
- Comprobado el despliegue exitoso de GitHub Pages.
- Pendiente prueba manual de extremo a extremo con un navegador real y al menos una encuesta de prueba.

## Registros de demostración (2026-10-24)
Se insertaron **5 encuestas ficticias** directamente en Supabase con `es_prueba=true` y `lote_prueba='ISFT93-DEMO-20261024-01'`.
No corresponden a personas reales. El reporte muestra una advertencia cuando un segmento incluye datos de prueba.

Para verificar antes de limpiar:
```sql
select count(*) from public.encuesta_comunitaria
where es_prueba is true and lote_prueba='ISFT93-DEMO-20261024-01';
```

**Solo cuando lo soliciten**, eliminarlas con:
```sql
delete from public.encuesta_comunitaria
where es_prueba is true and lote_prueba='ISFT93-DEMO-20261024-01';
```
No borrar encuestas sin marca de prueba ni otros lotes.
