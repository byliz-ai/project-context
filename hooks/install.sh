#!/bin/bash
# Instala (o quita) los dos hooks de project-context en la configuracion global
# de Claude Code. Se puede correr varias veces: no duplica entradas.
#
# Uso:
#   bash hooks/install.sh              instala o actualiza
#   bash hooks/install.sh --uninstall  quita los hooks
#
# Deja una copia de respaldo en settings.json.bak-project-context.

set -e
command -v jq >/dev/null 2>&1 || { echo "Falta jq. En macOS: brew install jq" >&2; exit 1; }

dir=$(cd "$(dirname "$0")" && pwd)
settings=${CLAUDE_SETTINGS_FILE:-$HOME/.claude/settings.json}

mkdir -p "$(dirname "$settings")"
[ -f "$settings" ] || echo '{}' > "$settings"
jq -e 'type == "object"' "$settings" >/dev/null 2>&1 || {
  echo "$settings no es un JSON valido. No se modifico nada." >&2
  exit 1
}

# Escribir la ruta con $HOME para que el ajuste no dependa del nombre de usuario
case "$dir" in
  "$HOME"/*) shown="\$HOME${dir#"$HOME"}" ;;
  *) shown=$dir ;;
esac
ses_cmd="bash \"$shown/claude-context-session.sh\""
chk_cmd="bash \"$shown/claude-context-check.sh\""

mode=install
[ "${1:-}" = "--uninstall" ] && mode=uninstall

cp "$settings" "$settings.bak-project-context"
tmp=$(mktemp)

jq --arg ses "$ses_cmd" --arg chk "$chk_cmd" --arg mode "$mode" '
  # Quita de un evento cualquier hook cuyo comando mencione el script dado
  def strip($ev; $needle):
    if (.hooks[$ev] | type) == "array" then
      .hooks[$ev] |= ( map(.hooks |= map(select(((.command // "") | contains($needle)) | not)))
                       | map(select((.hooks | length) > 0)) )
      | if (.hooks[$ev] | length) == 0 then del(.hooks[$ev]) else . end
    else . end;

  .hooks = (.hooks // {})
  | strip("SessionStart"; "claude-context-session.sh")
  | strip("Stop"; "claude-context-check.sh")
  | if $mode == "install" then
      .hooks.SessionStart = ((.hooks.SessionStart // []) + [{hooks: [{type: "command", command: $ses, timeout: 10}]}])
      | .hooks.Stop = ((.hooks.Stop // []) + [{hooks: [{type: "command", command: $chk, timeout: 20}]}])
    else . end
  | if (.hooks | length) == 0 then del(.hooks) else . end
' "$settings" > "$tmp"

jq -e 'type == "object"' "$tmp" >/dev/null
cat "$tmp" > "$settings"   # conserva los permisos del archivo original
rm -f "$tmp"

if [ "$mode" = "install" ]; then
  echo "Hooks instalados en $settings"
  echo "  SessionStart: $ses_cmd"
  echo "  Stop:         $chk_cmd"
  echo "Las sesiones ya abiertas pueden necesitar reiniciarse para tomarlos."
else
  echo "Hooks quitados de $settings"
fi
echo "Respaldo: $settings.bak-project-context"
