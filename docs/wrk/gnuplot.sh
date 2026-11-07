#!/usr/bin/env bash

set -euo pipefail

export APP_GNUPLOT="${APP_GNUPLOT:-gnuplot}"

do_single()
{
    local m_dir
    local m_gp
    m_dir=$(dirname "${1}")
    m_gp=$(basename "${1}")
    (
        cd "${m_dir}"
        set -x
        "${APP_GNUPLOT}" "${m_gp}"
        set +x
    )
}

echo "GNUPLOT INFO: execution within $(pwd -P)"
echo "GNUPLOT INFO: gnuplot: $(command -v "${APP_GNUPLOT}" || true)"
echo "GNUPLOT INFO: find: $(command -v find || true)"
echo "GNUPLOT INFO: dirname: $(command -v dirname || true)"
echo "GNUPLOT INFO: basename: $(command -v basename || true)"

while IFS= read -r -d '' gp_file; do
    do_single "${gp_file}"
done < <(find .. -path ../archive -prune -o -name "*.gp" -print0)
