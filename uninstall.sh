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
    if grep -qE 'exe: .*/GRYPHLINK/Launcher\.exe' "$candidate"; then lutris_config="$candidate"; break; fi
  done
fi
[[ -n "$lutris_config" && -f "$lutris_config" ]] || { echo "Could not find a GRYPHYLINK Lutris YAML. Use --lutris-config PATH." >&2; exit 1; }
if [[ -z "$game_dir" ]]; then
  launcher_path="$(sed -nE 's/^  exe: (.*)\/Launcher\.exe$/\1/p' "$lutris_config" | head -n1)"
  [[ -n "$launcher_path" ]] || { echo "Could not read launcher path. Use --game-dir PATH." >&2; exit 1; }
  game_dir="$launcher_path/games/Arknights Endfield"
fi

expected_path="$game_dir/dxvk.conf"
timestamp="$(date +%Y%m%d-%H%M%S)"
cp -a "$lutris_config" "$lutris_config.bak.$timestamp"
python3 - "$lutris_config" "$expected_path" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
expected = f'    DXVK_CONFIG_FILE: "{sys.argv[2]}"'
lines = path.read_text().splitlines()
kept = [line for line in lines if not (line.startswith("    DXVK_CONFIG_FILE:") and line == expected)]
path.write_text("\n".join(kept) + "\n")
PY

config_path="$game_dir/dxvk.conf"
if [[ -f "$config_path" ]] && [[ "$(cat "$config_path")" == 'dxgi.customDeviceDesc = "NVIDIA GeForce RTX 3060"' ]]; then
  rm -- "$config_path"
  echo "Removed project dxvk.conf."
else
  echo "Kept $config_path because it differs from the exact project file."
fi
echo "Removed this project's Lutris variable (if present). Backup: $lutris_config.bak.$timestamp"
