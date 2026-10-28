#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
PYTHONPATH=src python -m gbt_tentacle_arm info
PYTHONPATH=src python -m gbt_tentacle_arm check --payload '{}'
PYTHONPATH=src python -m gbt_tentacle_arm run   --payload '{}'
