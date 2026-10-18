#!/usr/bin/env bash
#
# Regenerate the layout diagram shown in README.md from the actual keymap.
#
#   ./scripts/gen-layout.sh
#
# Outputs (both are committed, so the diagram stays reviewable):
#   docs/sweep-layout.yaml  intermediate keymap-drawer representation
#   docs/sweep-layout.svg   the diagram linked from README.md
#
# The toolchain is run through `uvx`, so no manual install is needed (only uv).
# Versions are pinned because keymap-drawer 0.21.0 calls `Language.query`, which
# tree-sitter 0.25 removed, while tree-sitter-devicetree 0.15 requires
# tree-sitter 0.25; that combination crashes while parsing config/cradio.keymap
# with `AttributeError: 'tree_sitter.Language' object has no attribute 'query'`.
# The ZMK physical layout for `cradio` is resolved from keymap-drawer's bundled
# layout table, so generation works offline and is reproducible.

set -euo pipefail

cd "$(dirname "$0")/.."

KEYMAP_YAML=docs/sweep-layout.yaml
DIAGRAM_SVG=docs/sweep-layout.svg
CONFIG=docs/keymap_drawer.config.yaml

keymap() {
	local -a cmd=(
		uvx
		--with 'tree-sitter<0.25'
		--with 'tree-sitter-devicetree==0.14.0'
		--from 'keymap-drawer==0.21.0'
		keymap
		--config "$CONFIG"
	)
	"${cmd[@]}" "$@"
}

echo "==> parsing config/cradio.keymap"
keymap parse --zmk-keymap config/cradio.keymap --output "$KEYMAP_YAML"

# keymap-drawer draws the YAML layer keys as the layer headers, and it has no
# option to relabel them, so rename them here to the uppercase layer names used
# elsewhere in this repository. Transparent keys keep pointing at the layers.
sed \
	-e 's/^  default:/  BASE:/' \
	-e 's/^  lower:/  LOWER:/' \
	-e 's/^  raise:/  RAISE:/' \
	-e 's/^  adjust:/  ADJUST:/' \
	"$KEYMAP_YAML" > "$KEYMAP_YAML.tmp"
mv "$KEYMAP_YAML.tmp" "$KEYMAP_YAML"

echo "==> drawing $DIAGRAM_SVG"
keymap draw --zmk-keyboard cradio "$KEYMAP_YAML" --output "$DIAGRAM_SVG"

echo "==> done"
