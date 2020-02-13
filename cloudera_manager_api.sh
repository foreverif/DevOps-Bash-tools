#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-01-02 16:19:20 +0000 (Thu, 02 Jan 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/cloudera_manager.sh
. "$srcdir/lib/cloudera_manager.sh"

usage(){
    cat <<EOF
Script to query Cloudera Manager API, auto-populating Cloudera Manager host address, cluster name from environment and
safely passing credentials via a file descriptor to avoid exposing them in the process list as arguments or OS logging
history

combine with jq commands to extract the info you want

Environment variables (prompts for address, cluster and password if not passed via environment variables):

\$CLOUDERA_MANAGER_HOST / \$CLOUDERA_MANAGER
\$CLOUDERA_MANAGER_CLUSTER / \$CLOUDERA_CLUSTER
\$CLOUDERA_MANAGER_SSL (any value enables and changes port from 7180 to 7183)
\$CLOUDERA_MANAGER_USER / \$CLOUDERA_USER / \$USER
\$CLOUDERA_MANAGER_PASSWORD / \$CLOUDERA_PASSWORD / \$USER

./cloudera_manager_api.sh /path

Tested on Cloudera Enterprise 5.10
EOF
    exit 3
}

if [ $# -lt 1 ]; then
    usage
fi

url_path="$1"
url_path="/${url_path##/}"

api_version="${CLOUDERA_API_VERSION:-7}"

"$srcdir/curl_auth.sh" -sS --connect-timeout 5 "$CLOUDERA_MANAGER/api/v${api_version}${url_path}"
echo
