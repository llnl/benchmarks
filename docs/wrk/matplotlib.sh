#!/bin/sh

export APP_MATPLOTLIB="${APP_MATPLOTLIB:-python3}"

do_single()
{
    m_dir=`dirname "${1}"`
    m_mp=`basename "${1}"`
    cd ${m_dir}
    set -x
    "${APP_MATPLOTLIB}" "${m_mp}"
    set +x
}
export -f do_single

echo "MATPLOTLIB INFO: execution within ` pwd -P `"
echo "MATPLOTLIB INFO: python3: ` which python3 `"
echo "MATPLOTLIB INFO: find: ` which find `"
echo "MATPLOTLIB INFO: xargs: ` which xargs `"
echo "MATPLOTLIB INFO: dirname: ` which dirname `"
echo "MATPLOTLIB INFO: basename: ` which basename `"

find .. -not \( -path "./archive" -prune \) -name "*.matplotlib.py" -print0 |  xargs -0 -I file bash -c "do_single file"

exit 0
