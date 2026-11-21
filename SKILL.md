---
name: project-context
description: ES — Memoria de proyecto para Claude Code con registro automático de decisiones, en tres modos. init, para un proyecto nuevo o vacío. migrate, para un proyecto que ya va andando, con chats anteriores, su propio CLAUDE.md u otra estructura. handoff, para pasar un chat normal a un proyecto. Crea .claude-context/ y la regla de registro continuo en CLAUDE.md, de modo que cada decisión, corrección o preferencia se anote sola y cualquier chat nuevo continúe sin empezar de cero. Activar con /project-context, "inicializa el contexto", "deja el proyecto listo para otra sesión", "migra este proyecto", "este proyecto ya tiene varios chats", "rescata las decisiones de los chats anteriores", "pasa este chat a un proyecto", "prepara el handoff". EN — Persistent project memory for Claude Code with automatic decision logging. Three modes: init (new project), migrate (in-flight project with prior sessions or its own structure), handoff (move a regular chat into a project). Trigger on "init context", "set up project memory", "migrate this project", "prepare a handoff".
---

# project-context

Deja un proyecto preparado para que cualquier sesión futura de Claude Code continúe sin empezar desde cero, y para que las decisiones y cambios importantes queden anotados en el momento en que ocurren, sin que el usuario lo pida. Lo segundo es lo más importante: el usuario no va a acordarse de pedirlo y las sesiones se cortan sin aviso, así que lo que no se anota en el momento se pierde.

Se corre una sola vez por proyecto. Después, cada chat nuevo se entera solo, por CLAUDE.md y por el hook de inicio de sesión.

Las rutas de este documento son relativas a la carpeta de esta skill.

## Elegir el modo

Si el usuario pasó un argumento (init, migrate o handoff), usa ese modo. Si no, decide así, en este orden, y dilo en una línea antes de empezar:

1. handoff: el usuario pide el prompt para sacar el contexto de un chat normal, o habla de un chat que está fuera de Claude Code. Lee references/handoff.md.
2. Ya inicializado: existe .claude-context/ en el proyecto. No reinicialices. Si hay chats anteriores o archivos HANDOFF sin procesar, sigue references/migrate.md en su forma incremental; si no, solo actualiza lo que haya cambiado.
3. migrate: el proyecto ya va andando. Señales: CLAUDE.md con contenido propio; archivos de notas, estado o decisiones con otra estructura; o chats anteriores además de este, según `bash scripts/list-sessions.sh "<raíz del proyecto>"`. Lee references/migrate.md.
4. init: nada de lo anterior. Lee references/init.md.

Los modos init y migrate usan además references/structure.md, que define los seis archivos, el bloque exacto para CLAUDE.md y las reglas de escritura. Léelo antes de escribir.

## Reglas comunes a todos los modos

- Si esta sesión no está en la carpeta del proyecto, pregunta la ruta antes de escribir nada.
- No resumas de memoria. Revisa el estado real del proyecto y las fuentes. Si no hay información para una sección, escribe "Sin entradas todavía" en vez de inventarla.
- Solo hechos verificables en el proyecto o acordados explícitamente. Las suposiciones van marcadas [to confirm].
- Nunca copies credenciales, tokens ni API keys, aunque aparezcan en las fuentes.
- No hagas commit hasta que el usuario valide el resultado.

## Hooks

La skill trae dos hooks globales que refuerzan el registro. En proyectos sin .claude-context/ no hacen nada.

- hooks/claude-context-session.sh, evento SessionStart: avisa a cada chat nuevo que el proyecto tiene memoria y dónde está.
- hooks/claude-context-check.sh, evento Stop: si en el turno cambiaron archivos del proyecto y no se actualizó el registro, pide a Claude revisar y anotar lo que falte.

Antes de terminar cualquier modo, comprueba que estén instalados:

```bash
grep -c "claude-context-" ~/.claude/settings.json
```

Si el resultado es 0, dile al usuario que los hooks no están instalados y pregúntale si los instalas. Solo con su sí, corre:

```bash
bash hooks/install.sh
```

El instalador modifica ~/.claude/settings.json, deja una copia de respaldo al lado y se puede revertir con `bash hooks/install.sh --uninstall`.
