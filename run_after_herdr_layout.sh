#!/bin/sh
# A running Herdr window keeps its shown layout in memory and does not re-read
# shared.json, so the layout pinned by dot_config/herdr-app/modify_shared.json
# only takes effect at its next start, and the app may save its own choice back
# over it before then. Switching an open window keeps the two in step.
#
# No-op where Herdr is not installed (Codespaces) or no window is open; never
# fails the apply.

command -v herdr-app >/dev/null 2>&1 || exit 0
herdr-app status >/dev/null 2>&1 || exit 0
herdr-app do layout.switch '{"name":"tokyo"}' >/dev/null 2>&1 || true
exit 0
