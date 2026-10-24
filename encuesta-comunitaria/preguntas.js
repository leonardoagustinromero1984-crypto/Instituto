window.ENCUESTA_SECCIONES = [
 {titulo:"Datos personales",preguntas:[
  ["sexo","Sexo",["Masculino","Femenino","Otro"]],
  ["nacionalidad","Nacionalidad","texto"],
  ["estado_civil","Estado civil",["Casado/a","Divorciado/a","Conviviente","Soltero/a","Viudo/a"]],
  ["hijos","Número de hijos","numero"],
  ["situacion_laboral","Situación laboral",["Empleado/a","Desempleado/a","Trabajo independiente"]],
  ["vivienda","Situación de vivienda",["Propietario/a","Alquiler","Otra"]],
  ["educacion","Nivel de educación alcanzado",["Primario","Secundario","Universitario","Otro"]],
  ["educacion_estado","Estado del nivel educativo",["Completo","Incompleto"]]
 ]},
 {titulo:"Accesibilidad y atención del centro de salud",preguntas:[
  ["accesibilidad","1. Accesibilidad",["Muy accesible","Accesible","Poco accesible","Muy poco accesible"]],
  ["atencion_adecuada","2. ¿Considera adecuada la atención?",["Sí","No"]],
  ["calidad","3. Calidad de atención",["Muy buena","Buena","Regular","Mala","Muy mala"]],
  ["informacion_centro","4. ¿Recibe información de prevención y promoción?",["Sí","No"]]
 ]},
 {titulo:"Ambiente y salud",preguntas:[
  ["ambiente","5. Condiciones ambientales del barrio",["Muy buenas","Buenas","Regulares","Malas","Muy malas"]],
  ["enfermedades","6. Enfermedades",["Hipertensión","Diabetes","Enfermedades respiratorias","Oncológicas","Otras"],"multiple"],
  ["enfermedad_otra","Si seleccionó otras, especifique","texto"],
  ["medicacion","7. ¿Consume medicación?",["Sí","No"]],
  ["medicacion_cual","¿Cuál medicación?","texto"],
  ["informacion_prevencion","8. ¿Recibe información sobre prevención en el centro?",["Sí","No"]],
  ["vacunas","9. ¿Tiene esquema de vacunación completo?",["Sí","No"]],
  ["automedicacion","10. ¿Suele automedicarse?",["Sí","No"]],
  ["dificultad_traslado","11. ¿Tiene dificultades para trasladarse al centro?",["Sí","No"]],
  ["controles","12. ¿Se realiza controles periódicos?",["Sí","No","A veces"]],
  ["cobertura","13. Cobertura médica",["Obra social","Prepaga","Prestación pública","Ninguna"]],
  ["actividad_fisica","14. ¿Realiza actividad física?",["Sí","No"]],
  ["actividad_cual","¿Cuál actividad?","texto"],
  ["servicios","15. Servicios disponibles en el hogar",["Gas natural","Gas envasado","Agua de red","Agua de pozo","Recolección de residuos","Electricidad"],"multiple"]
 ]},
 {titulo:"Nutrición y contaminación",preguntas:[
  ["alimentos","16. Alimentos consumidos",["Carne","Pollo","Proteínas","Verdura / fruta","Lácteos","Pescado"],"multiple"],
  ["comidas_diarias","17. ¿Cuántas comidas realiza al día?",["1","2","3","4"]],
  ["comida_principal","18. ¿Qué comidas considerás más importantes? (Podés elegir varias)",["Desayuno","Almuerzo","Merienda","Cena"],"multiple"],
  ["contaminacion","19. Focos de contaminación",["Basura a cielo abierto","Basura acumulada en las calles","Aguas estancadas / cloacas desbordadas","No identifica focos"],"multiple"]
 ]}
];
window.ENCUESTA_CAMPOS_REPORTE=window.ENCUESTA_SECCIONES.flatMap(s=>s.preguntas.filter(p=>!["hijos","enfermedad_otra","medicacion_cual","actividad_cual"].includes(p[0])&&p[2]!=="texto").map(p=>({value:p[0],label:s.titulo+" · "+p[1]})));
