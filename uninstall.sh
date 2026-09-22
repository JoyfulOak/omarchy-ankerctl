#!/usr/bin/env bash
set -euo pipefail

systemctl --user disable --now ankerctl.service 2>/dev/null || true
rm -f "$HOME/.config/omarchy/plugins/justin.ankerctl/BarWidget.qml" \
      "$HOME/.config/omarchy/plugins/justin.ankerctl/manifest.json" \
      "$HOME/.local/bin/omarchy-ankerctl" \
      "$HOME/.config/systemd/user/ankerctl.service"
rmdir "$HOME/.config/omarchy/plugins/justin.ankerctl" 2>/dev/null || true
systemctl --user daemon-reload
omarchy-shell shell rescanPlugins
printf 'Omarchy Ankerctl plugin removed. Ankerctl data and binary were kept.\n'
