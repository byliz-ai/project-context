#!/bin/bash
# Hook SessionStart de Claude Code: avisa a cada sesion nueva que el proyecto
# tiene .claude-context/, para que no dependa de que el usuario lo recuerde.
# En proyectos sin .claude-context/ no hace nada.
#
# Para desactivarlo: corre: bash hooks/install.sh --uninstall.

command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$PWD

# Buscar hacia arriba la carpeta que contiene .claude-context/ (sin llegar a HOME)
root=""
dir=$cwd
while [ -n "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "$HOME" ]; do
  if [ -d "$dir/.claude-context" ]; then
    root=$dir
    break
  fi
  dir=$(dirname "$dir")
done
[ -n "$root" ] || exit 0

msg="Este proyecto ya tiene memoria de proyecto en $root/.claude-context/ (creada con /project-context). No hace falta volver a inicializarla ni migrarla. Antes de trabajar, lee 00_README_FIRST.md de esa carpeta si no esta ya en tu contexto: indica que archivo cumple cada rol (estado, decisiones, preferencias, lecciones, pendientes), que puede estar en .claude-context/ o en otra ruta del proyecto. Lee tambien el estado y las preferencias, y consulta el registro de decisiones antes de proponer cambiar algo ya decidido. Registro continuo, sin que el usuario lo pida: cuando haya una correccion del usuario, una decision entre alternativas, una preferencia nueva, un enfoque que fallo, un bloqueo o un hito completado, anotalo de inmediato en el archivo que 00_README_FIRST.md indique para ese rol y avisa en una linea que anotaste y donde."

# Si CLAUDE.md no tiene el bloque de registro continuo, decirlo para que se repare
if ! grep -q "Registro continuo" "$root/CLAUDE.md" 2>/dev/null; then
  msg="$msg Aviso: $root/CLAUDE.md no existe o no contiene la seccion Registro continuo. Dile al usuario en una linea que conviene correr /project-context una vez para repararlo."
fi

jq -n --arg m "$msg" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $m
  }
}'
exit 0
