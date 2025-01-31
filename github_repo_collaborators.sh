#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-08-16 11:15:51 +0100 (Sun, 16 Aug 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# https://docs.github.com/en/rest/reference/collaborators

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/utils.sh
. "$srcdir/lib/utils.sh"

# shellcheck source=lib/git.sh
. "$srcdir/lib/github.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Lists a GitHub repo's collaborators (users granted access via teams, or outside invited collaborators) and their role name permissions using the GitHub API

If no repo is given, infers from local repo's git remotes

Output format:

<repo>  <user1>   <permission>
<repo>  <user2>   <permission>

This is most useful for GitHub Enterprise repos that are part of an organization to audit access across repos, especially when combined with github_foreach_repo.sh.
For many personal repos you'll likely only see your own user with admin permissions
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<repo>"

help_usage "$@"

#min_args 1 "$@"

repo="${1:-}"

if [ -z "$repo" ]; then
    repo="$(get_github_repo)"
fi

"$srcdir/github_api.sh" "/repos/$repo/collaborators" |
jq -r ".[] | [\"$repo\", .login, .role_name] | @tsv" |
column -t
