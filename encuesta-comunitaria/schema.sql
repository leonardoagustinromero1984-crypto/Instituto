-- Ejecutar en Supabase SQL Editor. Este script crea tablas nuevas, no modifica otras apps.
create extension if not exists pgcrypto;
create table if not exists public.encuesta_comunitaria (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  fecha date not null default current_date,
  edad integer check (edad between 0 and 120),
  enfermedades text[] not null default '{}',
  respuestas jsonb not null default '{}'::jsonb
);
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
  jsonb_typeof(respuestas) = 'object'
  and jsonb_array_length(to_jsonb(enfermedades)) <= 12
);
-- Sólo usuarios autenticados pueden ejecutar el reporte agregado.
-- No permite seleccionar columnas arbitrarias: lista blanca de preguntas.
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
begin
  if auth.uid() is null or not exists (select 1 from public.encuesta_reporteros r where r.user_id = auth.uid()) then
    raise exception 'Acceso al reporte no autorizado';
  end if;
  if p_campo not in (
    'sexo','nacionalidad','estado_civil','situacion_laboral','vivienda','educacion','educacion_estado',
    'accesibilidad','atencion_adecuada','calidad','informacion_centro',
    'ambiente','enfermedades','medicacion','informacion_prevencion','vacunas',
    'automedicacion','dificultad_traslado','controles','cobertura','actividad_fisica',
    'servicios','alimentos','comidas_diarias','comida_principal','contaminacion'
  ) then raise exception 'Campo no permitido'; end if;
  with filtradas as (
    select * from public.encuesta_comunitaria e
    where (p_edad_desde is null or e.edad >= p_edad_desde)
      and (p_edad_hasta is null or e.edad <= p_edad_hasta)
      and (p_enfermedad is null or p_enfermedad = any(e.enfermedades))
      and (p_fecha_desde is null or e.fecha >= p_fecha_desde)
      and (p_fecha_hasta is null or e.fecha <= p_fecha_hasta)
  ), valores as (
    select case when p_campo = 'enfermedades'
      then to_jsonb(f.enfermedades)
      else coalesce(f.respuestas -> p_campo, 'null'::jsonb) end as valor
    from filtradas f
  ), etiquetas as (
    select coalesce(nullif(trim(z.etiqueta),''),'Sin respuesta') as etiqueta
    from valores v cross join lateral (
      select jsonb_array_elements_text(v.valor) as etiqueta where jsonb_typeof(v.valor) = 'array'
      union all
      select case when jsonb_typeof(v.valor) = 'string' then v.valor #>> '{}'
             else 'Sin respuesta' end where jsonb_typeof(v.valor) <> 'array'
    ) z
  ), grupos as (
    select etiqueta, count(*)::integer cantidad from etiquetas group by etiqueta
  )
  select jsonb_build_object(
    'total', (select count(*) from filtradas),
    'datos', coalesce((select jsonb_agg(jsonb_build_object('etiqueta',etiqueta,'cantidad',cantidad) order by cantidad desc)
                       from grupos where cantidad >= 3), '[]'::jsonb),
    'suprimidos', coalesce((select sum(cantidad) from grupos where cantidad < 3),0)
  ) into resultado;
  return resultado;
end $$;
revoke all on function public.reporte_encuesta(text,int,int,text,date,date) from public, anon;
grant execute on function public.reporte_encuesta(text,int,int,text,date,date) to authenticated;
-- Nota: para producción, añadir CAPTCHA/rate limiting y limitar el acceso de reportes
-- a usuarios autorizados (la autenticación por sí sola no define qué compañeros pueden verlos).
