#!/usr/bin/env bash

set -euo pipefail

export APP_MATPLOTLIB="${APP_MATPLOTLIB:-python3}"

do_single()
{
    local m_dir
    local m_mp
    m_dir=$(dirname "${1}")
    m_mp=$(basename "${1}")
    (
        cd "${m_dir}"
        set -x
        "${APP_MATPLOTLIB}" "${m_mp}"
        set +x
    )
}

echo "MATPLOTLIB INFO: execution within $(pwd -P)"
echo "MATPLOTLIB INFO: python3: $(command -v "${APP_MATPLOTLIB}" || true)"
echo "MATPLOTLIB INFO: find: $(command -v find || true)"
echo "MATPLOTLIB INFO: dirname: $(command -v dirname || true)"
echo "MATPLOTLIB INFO: basename: $(command -v basename || true)"

while IFS= read -r -d '' mp_file; do
    do_single "${mp_file}"
done < <(find .. -path ../archive -prune -o -name "*.matplotlib.py" -print0)
