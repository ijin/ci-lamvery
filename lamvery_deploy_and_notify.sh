#!/bin/bash
set -x

export SHA1=`echo ${CIRCLE_SHA1} | cut -c1-7`
export ENV=`echo $1 | rev | cut -d \- -f1 | rev`

if [$1 -eq 'production']; then
    export ENV_PREFIX=$PROD_PREFIX
    export ROLE=$PROD_ROLE
fi

lamvery deploy -s --dry-run

if [ $? -eq 0 ]; then
    export SL_COLOR="good"
    export SL_TEXT="Deploy success: $S3 - ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://s3-us-west-2.amazonaws.com/slack-files2/bot_icons/2015-08-11/8956311813_48.png"
    export EXIT=0
else
    export SL_COLOR="danger"
    export SL_TEXT="Sync failure: $S3 - ${CIRCLE_BRANCH} (<${CIRCLE_COMPARE_URL}|${SHA1}>) by ${CIRCLE_USERNAME} !!"
    export SL_ICON="https://s3-us-west-2.amazonaws.com/slack-files2/bot_icons/2015-08-11/8956311813_48.png"
    export EXIT=1
fi

curl -X POST --data-urlencode 'payload={"username": "Lambda", "icon_url": "'"$SL_ICON"'", "channel": "'"${CHANNEL:-#test}"'", "attachments": [{ "color": "'"$SL_COLOR"'", "text": "'"$SL_TEXT"'", "mrkdwn_in": ["text"] }] }' https://hooks.slack.com/services/${SLACK_HOOK}

exit $EXIT

