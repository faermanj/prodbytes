#!/usr/bin/env bash
#
# make.sh — build commands for the ProdBytes SvelteKit static site.
# Invoked by the Makefile (e.g. `make build` -> `./make.sh build`).

set -euo pipefail

cd "$(dirname "$0")"

# Base path for GitHub Pages project sites: https://<user>.github.io/<repo>.
# Override by exporting BASE_PATH before running (use "" for a user/org page
# or a custom domain).
export BASE_PATH="${BASE_PATH:-/prodbytes}"

# Install dependencies if they're missing.
ensure_deps() {
	if [ ! -d node_modules ]; then
		echo ">> node_modules missing; installing dependencies..."
		install
	fi
}

install() {
	if [ -f package-lock.json ]; then
		npm ci
	else
		npm install
	fi
}

dev() {
	ensure_deps
	# Dev server runs from the root path for convenience.
	BASE_PATH="" npm run dev
}

build() {
	ensure_deps
	echo ">> Building static site with BASE_PATH='${BASE_PATH}'"
	npm run build
	echo ">> Done. Static output is in ./docs (GitHub Pages publish target)"
}

preview() {
	ensure_deps
	npm run preview
}

clean() {
	rm -rf docs .svelte-kit
	echo ">> Removed docs/ and .svelte-kit/"
}

cmd="${1:-build}"
case "$cmd" in
	install) install ;;
	dev) dev ;;
	build) build ;;
	preview) preview ;;
	clean) clean ;;
	*)
		echo "Usage: ./make.sh {install|dev|build|preview|clean}" >&2
		exit 1
		;;
esac
