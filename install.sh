#!/usr/bin/env bash
set -euo pipefail

lutris_config=""
game_dir=""
while (($#)); do
  case "$1" in
    --lutris-config) lutris_config="${2:?Missing path after --lutris-config}"; shift 2 ;;
    --game-dir) game_dir="${2:?Missing path after --game-dir}"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--lutris-config PATH] [--game-dir PATH]"
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$lutris_config" ]]; then
  shopt -s nullglob
  candidates=("$HOME"/.local/share/lutris/games/gryphylink-*.yml)
  shopt -u nullglob
  for candidate in "${candidates[@]}"; do
    if grep -qE 'exe: .*/GRYPHLINK/Launcher\.exe' "$candidate"; then
      lutris_config="$candidate"
      break
    fi
  done
fi
[[ -n "$lutris_config" && -f "$lutris_config" ]] || { echo "Could not find a GRYPHYLINK Lutris YAML. Use --lutris-config PATH." >&2; exit 1; }

if [[ -z "$game_dir" ]]; then
  launcher_path="$(sed -nE 's/^  exe: (.*)\/Launcher\.exe$/\1/p' "$lutris_config" | head -n1)"
  [[ -n "$launcher_path" ]] || { echo "Could not read launcher path. Use --game-dir PATH." >&2; exit 1; }
  game_dir="$launcher_path/games/Arknights Endfield"
fi
[[ -f "$game_dir/Endfield.exe" ]] || { echo "Endfield.exe not found in: $game_dir" >&2; exit 1; }

config_path="$game_dir/dxvk.conf"
expected='dxgi.customDeviceDesc = "NVIDIA GeForce RTX 3060"'
timestamp="$(date +%Y%m%d-%H%M%S)"
cp -a "$lutris_config" "$lutris_config.bak.$timestamp"
if [[ -e "$config_path" ]]; then
  cp -a "$config_path" "$config_path.bak.$timestamp"
  if [[ "$(cat "$config_path")" != "$expected" ]]; then
    echo "Refusing to overwrite existing custom file: $config_path" >&2
    exit 1
  fi
else
  printf '%s\n' "$expected" > "$config_path"
fi

python3 - "$lutris_config" "$config_path" <<'PY'
from pathlib import Path
import re, sys

path = Path(sys.argv[1])
config_path = sys.argv[2]
text = path.read_text()
key = "    DXVK_CONFIG_FILE:"
line = f'    DXVK_CONFIG_FILE: "{config_path}"'
if re.search(r"(?m)^\s+DXVK_CONFIG_FILE:", text):
    text = re.sub(r"(?m)^\s+DXVK_CONFIG_FILE:.*$", line, text, count=1)
elif re.search(r"(?m)^  env:\s*$", text):
    text = re.sub(r"(?m)^(  env:\s*)$", r"\1\n" + line, text, count=1)
else:
    raise SystemExit("Could not find Lutris system.env section; no Lutris config was changed.")
path.write_text(text)
PY

echo "Installed DXVK device-description workaround."
echo "Lutris config: $lutris_config"
echo "DXVK config:   $config_path"
echo "Backup:        $lutris_config.bak.$timestamp"
