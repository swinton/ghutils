#!/bin/bash


function get_token() {
    # Get the token from ~/.netrc using Python's netrc library
    # We expect an entry for api.github.com
    python - <<-END
import os, netrc
machines = netrc.netrc(os.path.expanduser("~/.netrc"))
print(machines.hosts["api.github.com"][2])
END
}


function create_one_on_one_issue() {
    token=$( get_token )
    owner="github-fieldservices-planning"
    repo="swinton-jordan"
    title="One-on-one topics for the week of $( date +%Y-%m-%d )"
    body=$(cat <<-END
## Agenda
- Check-in (\`5 minutes\`)
- This week (\`15 minutes\`)
    - Wins
    - Goals
    - Blockers
- Other topics (\`5 minutes\`)
END
)

    # Generate well-formed JSON, using jq
    data=$( /usr/local/bin/jq -n \
        --arg t "${title}" \
        --arg b "${body}" \
        --arg a "swinton" \
        --arg l "one-on-one" \
        '{"title": $t, "body": $b, "assignees": [$a], "labels": [$l]}' )

    # Create issue
    curl --request POST \
      --url https://api.github.com/repos/${owner}/${repo}/issues \
      --header "authorization: token ${token}" \
      --header 'content-type: application/json' \
      --data "${data}"
}


# Create weekly one-on-one issue
create_one_on_one_issue
