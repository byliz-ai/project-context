# project-context

Skill de Claude Code que le da memoria a un proyecto y hace que las decisiones se anoten solas.

El problema que resuelve: cada chat nuevo empieza desde cero, y lo que se decidió o corrigió en un chat anterior se pierde si nadie lo anotó. Esta skill crea una carpeta `.claude-context/` en el proyecto, agrega a `CLAUDE.md` una regla de registro continuo e instala dos hooks que la refuerzan. Se corre una vez por proyecto; después, cada chat nuevo carga la memoria sin que se lo pidas.

## Tres modos

| Modo | Para qué | Cómo se usa |
| --- | --- | --- |
| init | Proyecto nuevo o vacío | `/project-context` en la carpeta del proyecto |
| migrate | Proyecto que ya va andando: varios chats anteriores, su propio `CLAUDE.md`, notas u otra estructura | `/project-context` en la carpeta del proyecto |
| handoff | Pasar un chat normal (fuera de Claude Code) a un proyecto | `/project-context handoff` para obtener el prompt |

Sin argumento, la skill detecta sola si corresponde init o migrate.

### init

Crea los seis archivos de `.claude-context/` a partir del estado real del proyecto y agrega el bloque de registro continuo a `CLAUDE.md`.

### migrate

1. Hace inventario de lo que ya existe: `CLAUDE.md`, notas, archivos de estado, memoria automática.
2. Lista todos los chats anteriores de Claude Code del proyecto y rescata de ellos decisiones, correcciones, preferencias, enfoques fallidos y pendientes, con fecha y chat de origen.
3. Presenta un plan y espera aprobación. Hasta ahí es solo lectura. Nunca borra, mueve ni renombra archivos existentes.
4. Ofrece dos caminos: consolidar todo en `.claude-context/`, o conservar la estructura existente como fuente de verdad y agregar solo el mapa y lo que falte.

Deja constancia de las fuentes procesadas, así que volver a correrlo solo agrega chats nuevos.

### handoff

Entrega un prompt para pegar en el chat normal. La respuesta se guarda como `HANDOFF.md` en la carpeta del proyecto y los modos init o migrate la toman como fuente.

## Qué queda en el proyecto

```
<proyecto>/
├── CLAUDE.md                  # con el bloque de registro continuo
└── .claude-context/
    ├── 00_README_FIRST.md     # índice y orden de lectura
    ├── project_status.md      # estado actual y dónde quedamos
    ├── decisions_log.md       # decisiones y correcciones, con fecha y motivo
    ├── preferences.md         # preferencias acordadas
    ├── lessons_learned.md     # qué haría diferente
    └── open_issues.md         # pendientes y bloqueos
```

## Instalación

Requiere `jq` (viene con macOS 15; en otros sistemas, `brew install jq` o el gestor de paquetes que uses).

```bash
git clone https://github.com/byliz-ai/project-context.git ~/.claude/skills/project-context
```

```bash
bash ~/.claude/skills/project-context/hooks/install.sh
```

El segundo comando registra los hooks en `~/.claude/settings.json` y deja un respaldo al lado. Para quitarlos:

```bash
bash ~/.claude/skills/project-context/hooks/install.sh --uninstall
```

## Los hooks

En proyectos sin `.claude-context/` no hacen nada.

- Inicio de sesión (`hooks/claude-context-session.sh`): le avisa a cada chat nuevo que el proyecto tiene memoria y dónde está. Si a `CLAUDE.md` le falta el bloque, lo dice.
- Cierre de respuesta (`hooks/claude-context-check.sh`): si en el turno cambiaron archivos del proyecto y no se actualizó el registro, le pide a Claude revisar el turno y anotar lo que falte.

## Límites

- El hook de cierre solo detecta turnos donde cambiaron archivos. Una preferencia dicha en un turno de pura conversación depende de la regla en `CLAUDE.md`.
- Si tú o un servicio de sincronización modifican archivos entre turnos, el hook puede pedir una revisión de más.
- En carpetas muy grandes la búsqueda de cambios se corta a los 10 segundos y ese turno queda sin revisar.
- El modo migrate solo rescata chats de Claude Code que sigan en disco. Los chats normales necesitan el modo handoff.
- Los scripts están probados en macOS.

## Contenido del repositorio

```
SKILL.md                 # entrada de la skill: elige el modo
references/
  structure.md           # los seis archivos, el bloque de CLAUDE.md y las reglas de escritura
  init.md                # modo init
  migrate.md             # modo migrate
  handoff.md             # modo handoff, con el prompt
scripts/
  list-sessions.sh       # lista los chats anteriores de un proyecto
  dump-session.sh        # condensa un chat a texto legible
hooks/
  claude-context-session.sh
  claude-context-check.sh
  install.sh
```
