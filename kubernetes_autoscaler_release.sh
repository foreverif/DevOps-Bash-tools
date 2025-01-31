#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2021-11-26 11:19:24 +0000 (Fri, 26 Nov 2021)
#
#  https://github.com/HariSekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds the latest Kubernetes Autoscaler release that matches your local kubnernetes cluster version using kubectl and the GitHub API

Useful to populate eks-cluster-autoscaler-kustomization.yaml image override in https://github.com/HariSekhon/Kubernetes-configs


Requires Kubectl to be installed and configured, as well as jq
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<major.minor version>]"

help_usage "$@"

version="${1:-}"

if [ -n "$version" ]; then
    if ! [[ "$version" =~ ^[[:digit:]]+\.[[:digit:]]+$ ]]; then
        usage "invalid kubernetes major.minor version given"
    fi
else
    version="$( kubectl version -o json | jq -r '.serverVersion | .major + "." + .minor | gsub("[+]"; "")' )"
fi

curl -sS https://api.github.com/repos/kubernetes/autoscaler/releases |
jq -r 'first(.[] | select(.tag_name | test("cluster-autoscaler-'"$version"'")) | .tag_name) | gsub("cluster-autoscaler-"; "v")'
