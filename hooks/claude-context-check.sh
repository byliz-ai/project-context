#!/bin/bash
# Hook Stop de Claude Code: revision del registro en proyectos con .claude-context/
#
# Que hace: cuando Claude va a terminar una respuesta, mira si desde la ultima
# revision cambiaron archivos del proyecto sin que se tocara .claude-context/.
# Si es asi, le pide a Claude revisar el turno y anotar lo que falte.
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

# Marca de tiempo de la ultima revision, una por proyecto, fuera del proyecto
state_dir=${CLAUDE_CONTEXT_STATE_DIR:-$HOME/.claude/project-context-state}
mkdir -p "$state_dir" 2>/dev/null || exit 0
key=$(printf '%s' "$root" | shasum | cut -c1-16)
stamp="$state_dir/claude-context-$key.stamp"

# Primera vez en este proyecto: solo marcar el punto de partida
if [ ! -f "$stamp" ]; then
  touch "$stamp"
  exit 0
fi

# Si Claude ya esta continuando por este mismo hook, no volver a bloquear
active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
if [ "$active" = "true" ]; then
  touch "$stamp"
  exit 0
fi

# La marca nueva se crea antes de buscar, para no perder cambios hechos durante la busqueda
touch "$stamp.new"

logged=$(find "$root/.claude-context" -type f -newer "$stamp" 2>/dev/null | head -n 1)

# Proyectos que conservan su propia estructura: .claude-context/log_paths.txt
# lista, una por linea y relativas a la raiz, las rutas que tambien son registro
if [ -z "$logged" ] && [ -f "$root/.claude-context/log_paths.txt" ]; then
  while IFS= read -r p || [ -n "$p" ]; do
    p=${p%$'\r'}
    case "$p" in
      ''|'#'*|/*|*..*) continue ;;
    esac
    if [ -e "$root/$p" ]; then
      logged=$(find "$root/$p" -type f -newer "$stamp" 2>/dev/null | head -n 1)
      [ -n "$logged" ] && break
    fi
  done < "$root/.claude-context/log_paths.txt"
fi

# Limite de 10 segundos para carpetas muy grandes o sincronizadas en la nube
changed=$(perl -e 'alarm shift; exec @ARGV' 10 \
  find "$root" \
    \( -name .git -o -name .claude-context -o -name .claude -o -name node_modules \
       -o -name .venv -o -name venv -o -name __pycache__ -o -name .Rproj.user \
       -o -name renv -o -name .ipynb_checkpoints -o -name .cache -o -name .next \
       -o -name dist -o -name build -o -name target \) -prune \
    -o -type f -newer "$stamp" \
       ! -name .DS_Store ! -name '~$*' ! -name '.~lock*' ! -name '*.tmp' ! -name '.Rhistory' \
       -print 2>/dev/null | head -n 1)

mv -f "$stamp.new" "$stamp"

if [ -n "$changed" ] && [ -z "$logged" ]; then
  rel=${changed#"$root"/}
  jq -n --arg f "$rel" '{
    decision: "block",
    reason: ("Revision de registro de .claude-context/: en este turno cambiaron archivos del proyecto (por ejemplo " + $f + ") y no se actualizo .claude-context/. Revisa lo que paso en el turno. Si hubo una decision, una correccion del usuario, una preferencia nueva, un enfoque descartado, un bloqueo o un hito completado, anotalo ahora en el archivo que corresponda segun la seccion Registro continuo de CLAUDE.md y avisa en una linea que anotaste y donde. Si nada cumple el criterio, o el cambio no lo hiciste tu, responde solo: Registro al dia. No repitas tu respuesta anterior.")
  }'
fi
exit 0
