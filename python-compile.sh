#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2015-05-25 01:38:24 +0100 (Mon, 25 May 2015)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help improve or steer this or other code I publish
#
#  http://www.linkedin.com/in/harisekhon
#

set -u
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$srcdir/utils.sh"

hr
"$srcdir/center80.sh" "Compiling all Python / Jython files"
hr
echo

for x in $(find . -maxdepth 2 -type f -iname '*.py' -o -iname '*.jy'); do
    [ -n "${isExcluded:-}" ] && isExcluded "$x" && continue
    echo "compiling $x"
    python -m py_compile $x
done
echo
echo
