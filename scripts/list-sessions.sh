#!/bin/bash
# Lista los chats anteriores de Claude Code de un proyecto.
#
# Uso: list-sessions.sh "<raiz del proyecto>"
#
# Incluye toda sesion cuyo directorio de trabajo fue la raiz del proyecto o una
# subcarpeta. Salida en columnas separadas por tabulador, de la mas antigua a
# la mas reciente:
#   inicio  ultima_actividad  tamano  prompts_usuario  id_sesion  primer_prompt  archivo
# Al final, lineas que empiezan con "#" indican carpetas de memoria automatica.

command -v jq >/dev/null 2>&1 || { echo "falta jq" >&2; exit 1; }

root=${1:-$PWD}
root=${root%/}
real=$(cd "$root" 2>/dev/null && pwd -P) || { echo "no existe: $root" >&2; exit 1; }
base=${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}

rows=""
memdirs=""
for f in "$base"/*/*.jsonl; do
  [ -f "$f" ] || continue

  # La sesion cuenta si en algun momento trabajo en la raiz o en una subcarpeta.
  # No basta el primer registro: una sesion puede empezar en otra carpeta y
  # moverse al proyecto despues.
  hit=""
  for r in "$root" "$real"; do
    j=$(jq -rn --arg r "$r" '$r | tojson')   # ruta con comillas y escapes de JSON
    j=${j%\"}
    if LC_ALL=C grep -qF "\"cwd\":$j\"" "$f" 2>/dev/null || LC_ALL=C grep -qF "\"cwd\":$j/" "$f" 2>/dev/null; then
      hit=1
      break
    fi
  done
  [ -n "$hit" ] || continue

  info=$(jq -rRn '
    def utext:
      if (.message.content|type) == "string" then .message.content
      elif (.message.content|type) == "array"
           and ([.message.content[] | select(.type == "tool_result")] | length) == 0
        then ([.message.content[] | select(.type == "text") | .text] | join(" "))
      else "" end;
    reduce (inputs | fromjson? | objects) as $l ({n: 0, first: null, start: null};
      (if .start == null and ($l.timestamp != null) then .start = $l.timestamp else . end)
      | if $l.type == "user" and ($l.isSidechain | not) and ($l.isMeta | not) and ($l.isCompactSummary | not)
        then ($l | utext) as $t
          | if $t != "" and ($t | test("^\\s*<(system-reminder|local-command|task-notification)") | not)
            then .n += 1 | (if .first == null then .first = $t else . end)
            else . end
        else . end)
    | [((.start // "") | .[0:10]), .n, ((.first // "") | gsub("[\\n\\t\\r]+"; " ") | .[0:90])] | @tsv
  ' "$f" 2>/dev/null)

  start=$(printf '%s' "$info" | cut -f1)
  n=$(printf '%s' "$info" | cut -f2)
  first=$(printf '%s' "$info" | cut -f3)
  last=$(stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null)
  size=$(du -h "$f" 2>/dev/null | cut -f1 | tr -d ' ')
  id=$(basename "$f" .jsonl)

  rows="$rows$start	$last	$size	$n	$id	$first	$f
"

  d=$(dirname "$f")
  if [ -d "$d/memory" ]; then
    case "$memdirs" in
      *"$d/memory"*) ;;
      *) memdirs="$memdirs$d/memory
" ;;
    esac
  fi
done

printf 'inicio\tultima_actividad\ttamano\tprompts_usuario\tid_sesion\tprimer_prompt\tarchivo\n'
printf '%s' "$rows" | sort

printf '%s' "$memdirs" | while IFS= read -r m; do
  [ -n "$m" ] || continue
  c=$(find "$m" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  echo "# memoria automatica: $m ($c archivos .md)"
done
exit 0
