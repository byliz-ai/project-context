# Modo init: proyecto nuevo o vacío

Para un proyecto sin historia previa: sin chats anteriores, sin CLAUDE.md propio y sin archivos de notas o estado. Si aparece alguna de esas cosas, cambia al modo migrate.

## Fuentes, en orden de confianza

1. El estado real del proyecto: archivos existentes, y git log y git status si es un repositorio. Si no lo es, usa la lista de archivos y sus fechas de modificación.
2. El historial de esta conversación.
3. Material que el usuario pegue, pase como argumento o que esté en la carpeta, por ejemplo un HANDOFF.md salido del modo handoff. Contrástalo con los archivos reales; lo que no puedas verificar va marcado [to confirm].

## Pasos

1. Lee references/structure.md.
2. Crea .claude-context/ con los seis archivos y llénalos con lo que conste en las fuentes.
3. Crea o actualiza CLAUDE.md con los dos bloques de references/structure.md: registro continuo y pautas de trabajo.
4. Comprueba los hooks como indica SKILL.md.
5. Muestra para validar, sin hacer commit:
   - La sección "Where we left off" de project_status.md.
   - La lista de archivos creados o modificados.
   - Todo lo que quedó marcado [to confirm], en una sola lista.

Desde este momento aplica el registro continuo también en esta sesión.
