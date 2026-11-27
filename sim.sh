#!/usr/bin/env bash
# Simuliert eine Testbench mit GHDL.
#
# Nutzung:  ./sim.sh <testbench-entity> <datei1.vhd> [datei2.vhd ...]
# Beispiel: ./sim.sh tb_halbaddierer meine_dateien/halbaddierer.vhd am_rechner/L01/tb_halbaddierer.vhd
#
# Wichtig: Dateien in Abhaengigkeits-Reihenfolge angeben
# (erst die Bausteine, dann die Testbench).
# Die Wellenform landet in build/<testbench>/<testbench>.ghw (ansehen mit: gtkwave build/<tb>/<tb>.ghw)
set -e
if [ $# -lt 2 ]; then
  sed -n '2,9p' "$0"; exit 1
fi
tb=$1; shift
w="build/$tb"; rm -rf "$w"; mkdir -p "$w"
ghdl -a --std=08 --workdir="$w" "$@"
ghdl -e --std=08 --workdir="$w" "$tb"
ghdl -r --std=08 --workdir="$w" "$tb" --stop-time=100us --ieee-asserts=disable-at-0 --wave="$w/$tb.ghw"
