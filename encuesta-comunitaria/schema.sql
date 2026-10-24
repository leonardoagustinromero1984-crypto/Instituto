-- Ejecutar en Supabase SQL Editor. Este script crea tablas nuevas, no modifica otras apps.
create extension if not exists pgcrypto;
create table if not exists public.encuesta_comunitaria (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  fecha date not null default current_date,
  edad integer check (edad between 0 and 120),
  enfermedades text[] not null default '{}',
  respuestas jsonb not null default '{}'::jsonb,
  es_prueba boolean not null default false,
  lote_prueba text
);
create index if not exists encuesta_comunitaria_pruebas_idx on public.encuesta_comunitaria(lote_prueba) where es_prueba = true;
create index if not exists encuesta_comunitaria_fecha_idx on public.encuesta_comunitaria(fecha);
create index if not exists encuesta_comunitaria_edad_idx on public.encuesta_comunitaria(edad);
create index if not exists encuesta_comunitaria_enfermedades_idx on public.encuesta_comunitaria using gin(enfermedades);
alter table public.encuesta_comunitaria enable row level security;
-- Lista privada de usuarios que pueden consultar reportes.
create table if not exists public.encuesta_reporteros (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.encuesta_reporteros enable row level security;
revoke all on public.encuesta_reporteros from public, anon, authenticated;
revoke all on public.encuesta_comunitaria from public, anon, authenticated;
grant insert on public.encuesta_comunitaria to anon, authenticated;
-- Cualquier participante puede enviar la encuesta; nadie puede consultar respuestas individuales por API.
drop policy if exists encuesta_insertar on public.encuesta_comunitaria;
create policy encuesta_insertar on public.encuesta_comunitaria for insert to anon, authenticated
with check (
  es_prueba = false
  and lote_prueba is null
  and jsonb_typeof(respuestas) = 'object'
  and cardinality(enfermedades) <= 12
);
-- Estadísticas públicas agregadas. La API no permite leer encuestas individuales.
-- Consultas agregadas por campo permitido: incluye datos con una sola encuesta.
create or replace function public.reporte_encuesta(
  p_campo text,
  p_edad_desde int default null,
  p_edad_hasta int default null,
  p_enfermedad text default null,
  p_fecha_desde date default null,
  p_fecha_hasta date default null
) returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare resultado jsonb;
declare n integer;
begin
  if p_edad_desde is not null and (p_edad_desde < 0 or p_edad_desde > 120) then raise exception 'Edad inválida'; end if;
  if p_edad_hasta is not null and (p_edad_hasta < 0 or p_edad_hasta > 120) then raise exception 'Edad inválida'; end if;
  if p_edad_desde is not null and p_edad_hasta is not null and p_edad_desde > p_edad_hasta then raise exception 'Rango inválido'; end if;
  if p_campo not in (
    'sexo','estado_civil','situacion_laboral','vivienda','educacion','educacion_estado',
    'accesibilidad','atencion_adecuada','calidad','informacion_centro',
    'ambiente','enfermedades','medicacion','informacion_prevencion','vacunas',
    'automedicacion','dificultad_traslado','controles','cobertura','actividad_fisica',
    'servicios','alimentos','comidas_diarias','comida_principal','contaminacion'
  ) then raise exception 'Campo no permitido'; end if;
  select count(*) into n from public.encuesta_comunitaria e
  where (p_edad_desde is null or e.edad >= p_edad_desde)
    and (p_edad_hasta is null or e.edad <= p_edad_hasta)
    and (p_enfermedad is null or p_enfermedad = any(e.enfermedades))
    and (p_fecha_desde is null or e.fecha >= p_fecha_desde)
    and (p_fecha_hasta is null or e.fecha <= p_fecha_hasta);
  with filtradas as (
    select * from public.encuesta_comunitaria e
    where (p_edad_desde is null or e.edad >= p_edad_desde)
      and (p_edad_hasta is null or e.edad <= p_edad_hasta)
      and (p_enfermedad is null or p_enfermedad = any(e.enfermedades))
      and (p_fecha_desde is null or e.fecha >= p_fecha_desde)
      and (p_fecha_hasta is null or e.fecha <= p_fecha_hasta)
  ), valores as (
    select case when p_campo = 'enfermedades'
      then case when cardinality(f.enfermedades)=0 then to_jsonb(array['Sin enfermedad declarada']::text[]) else to_jsonb(f.enfermedades) end
      else coalesce(f.respuestas -> p_campo, 'null'::jsonb) end as valor
    from filtradas f
  ), etiquetas as (
    select coalesce(nullif(trim(z.etiqueta),''),'Sin respuesta') as etiqueta
    from valores v cross join lateral (
      select jsonb_array_elements_text(
        case when jsonb_typeof(v.valor) = 'array' then v.valor else jsonb_build_array(v.valor) end
      ) as etiqueta
    ) z
  ), grupos as (
    select etiqueta, count(*)::integer cantidad from etiquetas group by etiqueta
  )
  select jsonb_build_object(
    'total', (select count(*) from filtradas),
    'total_pruebas', (select count(*) from filtradas where es_prueba = true),
    'datos', coalesce((select jsonb_agg(jsonb_build_object('etiqueta',etiqueta,'cantidad',cantidad) order by cantidad desc)
                       from grupos where cantidad >= 1), '[]'::jsonb),
    'suprimidos', coalesce((select sum(cantidad) from grupos where cantidad < 1),0)
  ) into resultado;
  return resultado;
end $$;
revoke all on function public.reporte_encuesta(text,int,int,text,date,date) from public, anon, authenticated;
grant execute on function public.reporte_encuesta(text,int,int,text,date,date) to anon, authenticated;
-- ADVERTENCIA: desde una encuesta, los filtros pueden revelar datos de salud individuales.
-- Para personas reales, restringir el acceso al panel y revisar la privacidad con la institución.

-- Registros de prueba: es_prueba=true y lote_prueba='ISFT93-DEMO-20261024-01'.
-- Para eliminarlos en el futuro, ejecutar de forma explícita:
-- delete from public.encuesta_comunitaria where es_prueba = true and lote_prueba = 'ISFT93-DEMO-20261024-01';
