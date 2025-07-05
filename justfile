#!/usr/bin/env just --justfile

default:
    @just --list

dev-static:
    #!/usr/bin/env bash
    set -euo pipefail
    cd examples
    elixir static.exs
    npx http-server . -p 8000

dev-live-view:
    #!/usr/bin/env bash
    set -euo pipefail
    cd examples
    elixir live_view.exs
