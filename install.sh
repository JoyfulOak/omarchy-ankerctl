#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
plugin_dir="$HOME/.config/omarchy/plugins/justin.ankerctl"
mkdir -p "$plugin_dir" "$HOME/.local/bin" "$HOME/.config/systemd/user"

install -m 0644 "$source_dir/BarWidget.qml" "$plugin_dir/BarWidget.qml"
install -m 0644 "$source_dir/manifest.json" "$plugin_dir/manifest.json"

cat > "$HOME/.local/bin/omarchy-ankerctl" <<'CLI'
#!/usr/bin/env bash
set -euo pipefail
unit="ankerctl.service"
status_json() {
  local installed=false running=false enabled=false status="Stopped"
  [[ -x "$HOME/.local/bin/ankerctl" ]] && installed=true
  systemctl --user is-active --quiet "$unit" && running=true || true
  systemctl --user is-enabled --quiet "$unit" 2>/dev/null && enabled=true || true
  [[ "$running" == true ]] && status="Running"
  [[ "$installed" == false ]] && status="Not installed"
  jq -cn --argjson installed "$installed" --argjson running "$running" \
    --argjson enabled "$enabled" --arg status "$status" \
    '{installed:$installed,running:$running,enabled:$enabled,status:$status,url:"http://127.0.0.1:4470"}'
}
case "${1:-status}" in
  status) status_json ;;
  start|on) systemctl --user daemon-reload; systemctl --user enable --now "$unit"; status_json ;;
  stop|off) systemctl --user disable --now "$unit" >/dev/null; status_json ;;
  toggle) if systemctl --user is-active --quiet "$unit" || systemctl --user is-enabled --quiet "$unit" 2>/dev/null; then "$0" off; else "$0" on; fi ;;
  open) xdg-open http://127.0.0.1:4470 >/dev/null 2>&1 & ;;
  logs) exec systemctl --user status "$unit" --no-pager ;;
  *) echo "Usage: omarchy-ankerctl [status|start|stop|on|off|toggle|open|logs]" >&2; exit 2 ;;
esac
CLI
chmod 0755 "$HOME/.local/bin/omarchy-ankerctl"

cat > "$HOME/.config/systemd/user/ankerctl.service" <<'UNIT'
[Unit]
Description=Ankerctl web bridge for OrcaSlicer
After=network-online.target

[Service]
Type=simple
ExecStart=%h/.local/bin/ankerctl webserver --listen 127.0.0.1:4470
Restart=on-failure
RestartSec=5
WorkingDirectory=%h/.local/share/ankerctl
Environment=ANKERCTL_LOG_DIR=%h/.local/state/ankerctl/logs

[Install]
WantedBy=default.target
UNIT

systemctl --user daemon-reload
omarchy-shell shell rescanPlugins
printf 'Omarchy Ankerctl plugin installed.\n'
