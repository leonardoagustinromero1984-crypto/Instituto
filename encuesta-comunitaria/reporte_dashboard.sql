-- SQL de función dashboard (ya aplicada a Supabase).
-- Incluye tres indicadores, gráfico de edades y filtros de segmento.
-- El acceso público recibe únicamente estadísticas agregadas.

CREATE OR REPLACE FUNCTION public.reporte_dashboard(p_campo text DEFAULT NULL::text, p_edad_desde integer DEFAULT NULL::integer, p_edad_hasta integer DEFAULT NULL::integer, p_enfermedad text DEFAULT NULL::text, p_fecha_desde date DEFAULT NULL::date, p_fecha_hasta date DEFAULT NULL::date)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_campo text := coalesce(nullif(p_campo,''),'enfermedades');
  v_principal jsonb;
  v_edades jsonb;
  v_tortas jsonb;
begin
  if v_campo not in (
    'sexo','estado_civil','situacion_laboral','vivienda','educacion','educacion_estado',
    'accesibilidad','atencion_adecuada','calidad','informacion_centro',
    'ambiente','enfermedades','medicacion','informacion_prevencion','vacunas',
    'automedicacion','dificultad_traslado','controles','cobertura','actividad_fisica',
    'servicios','alimentos','comidas_diarias','comida_principal','contaminacion'
  ) then raise exception 'Campo inválido'; end if;
  v_principal := public.reporte_encuesta(v_campo,p_edad_desde,p_edad_hasta,
                                         p_enfermedad,p_fecha_desde,p_fecha_hasta);
  if v_principal->>'mensaje' is not null then
    return jsonb_build_object('mensaje',v_principal->>'mensaje',
      'total',null,'total_pruebas',null,'edades','[]'::jsonb,'tortas','{}'::jsonb);
  end if;
  with franjas(pos,etiqueta,edad_min,edad_max) as (
    values (1,'0–19 años',0,19),(2,'20–39 años',20,39),
           (3,'40–59 años',40,59),(4,'60–79 años',60,79),
           (5,'80–100 años',80,100),(6,'101–120 años',101,120)
  ),
  conteos as (
    select f.pos,f.etiqueta,count(e.id)::integer cantidad
    from franjas f left join public.encuesta_comunitaria e
    on e.edad between f.edad_min and f.edad_max
    and (p_edad_desde is null or e.edad >= p_edad_desde)
    and (p_edad_hasta is null or e.edad <= p_edad_hasta)
    and (p_enfermedad is null or p_enfermedad = any(e.enfermedades))
    and (p_fecha_desde is null or e.fecha >= p_fecha_desde)
    and (p_fecha_hasta is null or e.fecha <= p_fecha_hasta)
    group by f.pos,f.etiqueta
  )
  select jsonb_agg(jsonb_build_object('etiqueta',etiqueta,
    'cantidad',case when cantidad in (1,2) then null else cantidad end,
    'oculto',cantidad in (1,2)) order by pos)
  into v_edades from conteos
  where pos<=5 or cantidad>0;
  if p_campo is null or p_campo='' then
    v_tortas := jsonb_build_object(
       'enfermedades',v_principal,
       'contaminacion',public.reporte_encuesta('contaminacion',p_edad_desde,p_edad_hasta,p_enfermedad,p_fecha_desde,p_fecha_hasta),
       'cobertura',public.reporte_encuesta('cobertura',p_edad_desde,p_edad_hasta,p_enfermedad,p_fecha_desde,p_fecha_hasta)
    );
  else
    v_tortas := jsonb_build_object('seleccion',v_principal);
  end if;
  return jsonb_build_object(
    'total',v_principal->'total',
    'total_pruebas',v_principal->'total_pruebas',
    'mensaje',v_principal->'mensaje',
    'edades',coalesce(v_edades,'[]'::jsonb),
    'tortas',v_tortas
  );
end
$function$
;

revoke all on function public.reporte_dashboard(text,integer,integer,text,date,date) from public,anon,authenticated;
grant execute on function public.reporte_dashboard(text,integer,integer,text,date,date) to anon,authenticated;
