#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-01 19:08:00 +0100 (Tue, 01 Sep 2020)
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

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Queries the Jenkins Rest API

Can specify \$CURL_OPTS for options to pass to curl, or pass them as arguments to the script

Requires either \$JENKINS_URL or \$JENKINS_HOST + \$JENKINS_PORT which defaults to localhost and port 8080

If you require SSL, specify full \$JENKINS_URL

Automatically handles authentication via environment variables:

- \$JENKINS_USER_ID / \$JENKINS_USERNAME / \$JENKINS_USER
- \$JENKINS_API_TOKEN / \$JENKINS_TOKEN  / \$JENKINS_PASSWORD

If using JENKINS_PASSWORD, obtains the Jenkins-Crumb cookie from a pre-request

On Jenkins 2.176.2 onwards, you must set JENKINS_TOKEN instead of using a password, see

    https://www.jenkins.io/doc/upgrade-guide/2.176/#SECURITY-626
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="/path [<curl_options>]"

curl_api_opts "$@"

help_usage "$@"

min_args 1 "$@"

url_path="${1:-}"
url_path="${url_path##/}"

shift || :

JENKINS_URL="${JENKINS_URL:-http://${JENKINS_HOST:-localhost}:${JENKINS_PORT:-8080}}"
shopt -s nocasematch
if ! [[ "$JENKINS_URL" =~ https?:// ]]; then
    JENKINS_URL="http://$JENKINS_URL"
fi
shopt -u nocasematch
JENKINS_URL="${JENKINS_URL%%/}"

export USERNAME="${JENKINS_USER_ID:${JENKINS_USERNAME:-${JENKINS_USER:-}}}"
JENKINS_TOKEN="${JENKINS_API_TOKEN:-${JENKINS_TOKEN:-}}"
if [ -n "${JENKINS_TOKEN:-}" ]; then
    export PASSWORD="$JENKINS_TOKEN"
else
    export PASSWORD="${JENKINS_PASSWORD:-${JENKINS_TOKEN:-}}"
    crumb="$("$srcdir/curl_auth.sh" -sS --fail "$JENKINS_URL/crumbIssuer/api/json" | jq -r '.crumb')"
    CURL_OPTS+=(-H "Jenkins-Crumb: $crumb")
fi

"$srcdir/curl_auth.sh" "$JENKINS_URL/$url_path" "${CURL_OPTS[@]}" "$@"
