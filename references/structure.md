# Estructura, bloque de CLAUDE.md y reglas de escritura

Común a los modos init y migrate.

## Carpeta .claude-context/

```
<project root>/
├── CLAUDE.md
└── .claude-context/
    ├── 00_README_FIRST.md
    ├── project_status.md
    ├── decisions_log.md
    ├── preferences.md
    ├── lessons_learned.md
    └── open_issues.md
```

Archivos de estado (reflejan el presente, se reescriben):

- 00_README_FIRST.md: propósito del proyecto en 3 líneas, stack, rutas clave, cómo correrlo y orden de lectura de los demás archivos.
- project_status.md: qué está terminado, qué está a medias (archivo y función exactos) y la sección "Where we left off" con la última acción completada, el siguiente paso concreto y el comando exacto para retomarlo.
- preferences.md: preferencias vigentes (estilo de código, formato de respuesta, herramientas, convenciones, qué no hacer), redactadas como reglas accionables. Si una nueva contradice una anterior, reemplázala y anota el cambio en decisions_log.md.
- open_issues.md: bloqueos, preguntas sin resolver y dependencias externas. Lo que se resuelve sale de aquí y entra a decisions_log.md.

Archivos de historial (solo se agrega al final, nunca se edita ni se borra una entrada):

- decisions_log.md: una entrada por decisión o corrección, con formato fecha | qué estaba mal o qué se decidió | qué se cambió y en qué archivos | por qué | alternativa descartada, si hubo. Incluye los errores de Claude que el usuario corrigió. Si una decisión reemplaza a otra, agrega una entrada nueva que cite la anterior.
- lessons_learned.md: enfoques que fallaron y por qué, atajos que funcionaron, qué harías distinto.

Si los archivos ya existen, actualízalos sin perder historial.

## Bloque para CLAUDE.md

Conserva lo que CLAUDE.md ya tenga. Agrega el bloque siguiente completo, o reemplázalo si ya existe una versión anterior. Este bloque es lo que vuelve automático el registro, porque CLAUDE.md se carga en cada sesión. Copia el contenido que está entre las etiquetas, sin las etiquetas.

<bloque_claude_md>
## Contexto del proyecto
@.claude-context/00_README_FIRST.md
@.claude-context/project_status.md
@.claude-context/preferences.md

Antes de proponer cambiar algo ya establecido, revisa .claude-context/decisions_log.md. No reabras una decisión registrada sin decir que la estás reabriendo.

## Registro continuo (obligatorio, sin que el usuario lo pida)
Este proyecto debe poder retomarse desde cero en cualquier momento y las sesiones se cortan sin aviso. Por eso el registro se hace en el momento, no al final.

Anota de inmediato, antes de pasar a la siguiente tarea y sin pedir permiso, cuando ocurra cualquiera de estos eventos:
- El usuario te corrige o rechaza algo que hiciste: decisions_log.md, y lessons_learned.md si deja una lección reutilizable.
- Se elige entre alternativas o se descarta un enfoque (librería, método, estructura de datos o de carpetas, alcance, nombres, fuente de datos): decisions_log.md.
- El usuario expresa una preferencia o regla ("siempre", "nunca", "prefiero", "no hagas"): preferences.md.
- Un enfoque falla y se cambia por otro: lessons_learned.md.
- Aparece un bloqueo, una pregunta sin resolver o una dependencia externa: open_issues.md. Al resolverse, pasa a decisions_log.md.
- Se completa un hito o cambia el siguiente paso: project_status.md, sección "Where we left off".

Criterio: anótalo si una sesión nueva, sin este historial, tomaría una decisión distinta o repetiría el error. No anotes typos, formato ni pasos intermedios de una tarea. En caso de duda, anótalo en una línea.

Después de anotar, avisa en una sola línea qué registraste y dónde, para que el usuario pueda corregirlo.

Antes de cada commit, y cuando el usuario diga que va a parar, verifica que project_status.md refleje el estado real.

Reglas de escritura para .claude-context/:
- Solo hechos verificables en el proyecto o acordados explícitamente. Las suposiciones van marcadas [to confirm].
- Rutas, nombres de funciones y comandos exactos, nada genérico.
- Nunca credenciales, tokens ni API keys.
- Sin negritas ni guiones largos.
- Cada entrada con fecha en formato YYYY-MM-DD.
</bloque_claude_md>

## Reglas de escritura

Aplica al escribir los archivos de .claude-context/ las mismas reglas de escritura del bloque, y fecha cada archivo con la fecha de hoy.

## Proyectos que conservan su propia estructura

Cuando en el modo migrate el usuario elige conservar sus archivos existentes como fuente de verdad:

- 00_README_FIRST.md contiene el mapa: para cada rol (estado, decisiones, preferencias, lecciones, pendientes), la ruta del archivo que lo cumple.
- En el bloque de CLAUDE.md, las rutas de los @ y de cada evento del registro continuo se cambian por las del mapa.
- .claude-context/log_paths.txt lista, una por línea y relativas a la raíz, las rutas de los archivos o carpetas existentes que funcionan como registro. El hook de cierre lo usa para reconocer que el registro sí se actualizó.
