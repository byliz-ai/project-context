#!/bin/bash
# Vuelca un chat de Claude Code en texto condensado, apto para leer y extraer decisiones.
#
# Uso: dump-session.sh <archivo.jsonl> [max_caracteres_por_mensaje]
#
# Conserva: lo que escribio el usuario, lo que respondio Claude en texto, los
# resumenes de compactacion y la lista de archivos que Claude modifico.
# Descarta: salidas de herramientas, razonamiento interno, subagentes e imagenes,
# que son lo que hace pesadas las transcripciones.
# Las horas estan en UTC.

command -v jq >/dev/null 2>&1 || { echo "falta jq" >&2; exit 1; }
f=$1
max=${2:-1500}
[ -f "$f" ] || { echo "no existe: $f" >&2; exit 1; }

jq -rR --argjson max "$max" '
  def clip($n):
    if length > $n
    then .[0:$n] + " [... recortado " + ((length - $n) | tostring) + " caracteres]"
    else . end;

  fromjson? | objects
  | select(.isSidechain | not)
  | select(.isMeta | not)
  | ((.timestamp // "") | .[0:16] | sub("T"; " ")) as $ts
  | if .type == "user" then
      ( if (.message.content|type) == "string" then .message.content
        elif (.message.content|type) == "array"
             and ([.message.content[] | select(.type == "tool_result")] | length) == 0
          then ([.message.content[] | select(.type == "text") | .text] | join("\n"))
        else "" end ) as $t
      | select($t != "" and ($t | test("^\\s*<(system-reminder|local-command|task-notification)") | not))
      | if .isCompactSummary
        then "[" + $ts + "] RESUMEN DE COMPACTACION:\n" + ($t | clip($max * 4)) + "\n"
        else "[" + $ts + "] USUARIO:\n" + ($t | clip($max)) + "\n"
        end
    elif .type == "assistant" then
      ( [.message.content[]? | select(.type == "text") | .text] | join("\n") ) as $t
      | ( [.message.content[]?
           | select(.type == "tool_use" and (.name == "Edit" or .name == "Write" or .name == "NotebookEdit" or .name == "MultiEdit"))
           | (.input.file_path // .input.notebook_path // "?")] ) as $files
      | ( if $t != "" then "[" + $ts + "] CLAUDE:\n" + ($t | clip($max)) + "\n" else empty end ),
        ( $files[] | "[" + $ts + "] CLAUDE modifico archivo: " + . )
    else empty end
' "$f"
