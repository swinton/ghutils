#!/bin/bash


function get_token() {
    echo "$( grep GITHUB_TOKEN ~/.extra | cut -d = -f 2 )"
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
        '{"title": $t, "body": $b, "assignees": [$a]}' )

    # Create issue
    curl --request POST \
      --url https://api.github.com/repos/${owner}/${repo}/issues \
      --header "authorization: token ${token}" \
      --header 'content-type: application/json' \
      --data "${data}"
}


# Create weekly one-on-one issue
create_one_on_one_issue
