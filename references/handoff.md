# Modo handoff: pasar un chat normal a un proyecto

Un chat normal, fuera de Claude Code, no tiene carpeta ni archivos: su contexto solo existe en la conversación. Este modo lo saca a un archivo HANDOFF.md que luego entra al proyecto por los modos init o migrate.

## Si el usuario pide el prompt

No inicialices nada. Muéstrale este texto en un bloque de código para que lo pegue en el chat que quiere rescatar, y explícale los tres pasos de abajo.

```text
Voy a continuar este trabajo en Claude Code. Revisa toda esta conversación, no resumas de memoria, y escribe un único archivo HANDOFF.md para que otra sesión sin acceso a este chat pueda continuarlo. Secciones:

1. Propósito del proyecto en 3 líneas.
2. Estado: qué quedó terminado, qué quedó a medias y cuál es el siguiente paso concreto.
3. Decisiones y correcciones, una por línea: fecha | qué estaba mal o qué se decidió | qué se cambió | por qué. Incluye tus errores que yo corregí. Si no sabes la fecha, escribe [fecha desconocida].
4. Preferencias que expresé, redactadas como reglas accionables.
5. Enfoques que fallaron y por qué.
6. Pendientes, preguntas abiertas y dependencias externas.
7. Código, textos o archivos producidos aquí: la versión final completa de cada uno, no fragmentos, con el nombre de archivo sugerido.

Reglas: solo lo que consta en esta conversación; las suposiciones van marcadas [to confirm]; sin credenciales, tokens ni API keys; sin negritas ni guiones largos.
```

Pasos para el usuario:

1. Pegar el prompt en el chat normal y guardar la respuesta como HANDOFF.md.
2. Poner ese archivo en la carpeta del proyecto. Si son varios chats, uno por archivo: HANDOFF_<tema>.md.
3. Abrir el proyecto en Claude Code y correr /project-context.

## Si esta conversación es la que se quiere pasar a un proyecto

Cuando el usuario está en Claude Code sin carpeta de proyecto y quiere convertir esta misma conversación en uno:

1. Pregunta en qué carpeta va a vivir el proyecto y muévete a ella.
2. Guarda ahí los archivos producidos en la conversación, en su versión final.
3. Sigue references/init.md usando el historial de esta conversación como fuente principal.

## Al encontrar archivos HANDOFF en un proyecto

Los modos init y migrate los tratan como fuente: su contenido se reparte entre los seis archivos de .claude-context/, contrastado con los archivos reales del proyecto. Lo que no se pueda verificar va marcado [to confirm]. Los HANDOFF no se borran; quedan como documentos anteriores.
