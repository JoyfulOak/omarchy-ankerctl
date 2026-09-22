# Omarchy Ankerctl

Omarchy bar plugin for controlling the user-level `ankerctl.service` bridge used by OrcaSlicer and an AnkerMake M5.

The plugin currently appears in the bar as `justin.ankerctl`.

## Features

- Shows whether the bridge is installed, enabled, or running
- Left-click opens controls in the bar
- Right-click toggles the service
- Starts and stops `ankerctl.service`
- Opens the bridge web UI at `http://127.0.0.1:4470`
- Opens OrcaSlicer

## Requirements

- Omarchy with the Quickshell bar
- `ankerctl` installed at `~/.local/bin/ankerctl`
- A user systemd unit named `ankerctl.service`
- `jq`, `systemctl`, and `xdg-open`

For OrcaSlicer, configure the physical printer as:

- Host type: `OctoPrint`
- Hostname/IP/URL: `127.0.0.1:4470`
- API key/password: blank unless configured in ankerctl

## Install

From this repository, run:

```bash
bash install.sh
```

The installer installs the plugin, the `omarchy-ankerctl` helper command, and the user service unit. It does not install the Ankerctl binary itself.

Then reload the bar:

```bash
omarchy-shell shell rescanPlugins
```

## Uninstall

```bash
bash uninstall.sh
```

This removes the plugin and helper files but leaves the Ankerctl binary, its data, and logs untouched.
