# Estructura, bloques de CLAUDE.md y reglas de escritura

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

## Bloque de registro para CLAUDE.md

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

## Bloque de pautas de trabajo para CLAUDE.md

Cuatro pautas para que Claude no suponga, no sobrecomplique y cambie solo lo pedido. Están adaptadas de https://github.com/multica-ai/andrej-karpathy-skills (licencia MIT), basado en las observaciones de Andrej Karpathy sobre los errores típicos de los modelos al programar.

- Agrégalo a CLAUDE.md después del bloque de registro, o reemplázalo si ya existe una versión anterior (se reconoce por el título "## Cómo trabajar").
- Si CLAUDE.md ya trae estas pautas en otra forma, por ejemplo el CLAUDE.md original de ese repositorio en inglés (empieza con "Behavioral guidelines to reduce common LLM coding mistakes" o tiene la sección "Think Before Coding"), no las dupliques: deja las que hay y no agregues este bloque.

Copia el contenido que está entre las etiquetas, sin las etiquetas.

<bloque_pautas>
## Cómo trabajar
Pautas para evitar los errores más comunes al programar o editar archivos, adaptadas de las observaciones de Andrej Karpathy (github.com/multica-ai/andrej-karpathy-skills). Favorecen la cautela sobre la velocidad: en tareas triviales, usa criterio. Si una preferencia de este proyecto contradice una pauta, manda la preferencia.

### 1. Pensar antes de programar
No supongas, no escondas la confusión, muestra las alternativas.
- Di tus suposiciones de forma explícita. Si dudas, pregunta.
- Si la petición admite varias interpretaciones, preséntalas; no elijas una en silencio.
- Si hay un enfoque más simple, dilo. Contradice al usuario cuando haga falta.
- Si algo no está claro, detente, nombra qué te confunde y pregunta.

### 2. Simplicidad primero
El mínimo código que resuelve el problema. Nada especulativo.
- Ninguna funcionalidad que no se haya pedido.
- Ninguna abstracción para código que se usa una sola vez.
- Ninguna flexibilidad ni opción de configuración que no se haya pedido.
- Ningún manejo de errores para escenarios imposibles.
- Si escribiste 200 líneas y podían ser 50, reescríbelo.

Pregúntate si un ingeniero senior diría que está sobrecomplicado. Si la respuesta es sí, simplifica.

### 3. Cambios quirúrgicos
Toca solo lo necesario. Limpia solo tu propio desorden.
- No "mejores" el código, los comentarios ni el formato vecinos.
- No refactorices lo que no está roto.
- Sigue el estilo existente, aunque tú lo harías distinto.
- Si ves código muerto ajeno a la tarea, menciónalo; no lo borres.
- Quita los imports, variables o funciones que tus cambios dejaron sin uso. El código muerto que ya existía no se borra salvo que te lo pidan.

Prueba: cada línea cambiada debe responder directamente a lo que pidió el usuario.

### 4. Ejecución guiada por metas
Define criterios de éxito. Repite hasta verificarlos.

Convierte cada tarea en una meta verificable:
- "Agrega validación": escribe pruebas con entradas inválidas y luego haz que pasen.
- "Arregla el error": escribe una prueba que lo reproduzca y luego haz que pase.
- "Refactoriza X": asegúrate de que las pruebas pasen antes y después.

En tareas de varios pasos, plantea un plan breve:
```
1. [Paso] → verificar: [comprobación]
2. [Paso] → verificar: [comprobación]
3. [Paso] → verificar: [comprobación]
```

Con criterios claros puedes avanzar solo; con criterios vagos ("que funcione") hay que pedir aclaraciones a cada rato.

Señales de que las pautas funcionan: diffs sin cambios innecesarios, menos reescrituras por sobrecomplicación, y preguntas aclaratorias antes de implementar, no después de equivocarse.
</bloque_pautas>

## Reglas de escritura

Aplica al escribir los archivos de .claude-context/ las mismas reglas de escritura del bloque de registro, y fecha cada archivo con la fecha de hoy.

## Proyectos que conservan su propia estructura

Cuando en el modo migrate el usuario elige conservar sus archivos existentes como fuente de verdad:

- 00_README_FIRST.md contiene el mapa: para cada rol (estado, decisiones, preferencias, lecciones, pendientes), la ruta del archivo que lo cumple.
- En el bloque de registro de CLAUDE.md, las rutas de los @ y de cada evento del registro continuo se cambian por las del mapa.
- .claude-context/log_paths.txt lista, una por línea y relativas a la raíz, las rutas de los archivos o carpetas existentes que funcionan como registro. El hook de cierre lo usa para reconocer que el registro sí se actualizó.
