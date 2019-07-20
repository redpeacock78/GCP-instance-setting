#!/usr/bin/env bash



###PARAMETERS###
TARGET_DIR="/home/redpeacock78/gdrive/handouts"
IGNORE_DIR="/home/redpeacock78/gdrive/handouts/.git"
AUTHOR_NAME="$(cd ${TARGET_DIR} && git log -1 --pretty=format:'%aN')"
GIT_MESSAGE="$(cd ${TARGET_DIR} && git log -1 --pretty=format:'%s')"
GIT_HASH="$(cd ${TARGET_DIR} && git log -1 --pretty=format:'%h')"
TIME_STAMP="$(cd ${TARGET_DIR} && date -d "$(git log -1 --pretty=format:'%cD')" +%s)"
AUTHOR_LINK="https://github.com/redpeacock78"
ICON_LINK="https://avatars0.githubusercontent.com/u/31413765?s=460&v=4"
GDRIVE_URL="https://drive.google.com/open?id=1wf0wE1dMbZU2fQfHGz1L1YK8HjAZpXYc"
WEBHOOK_URL="$(cat /home/redpeacock78/gcp-instance-setting/assets/webhooks.txt | grep 'discordapp.com')"


###TEXT###
while true; do
    inotifywait -r \
	        --exclude "${IGNORE_DIR}" \
		-e CREATE \
		-e MODIFY \
		-e DELETE \
		"${TARGET_DIR}" \
    && sleep 60 \
    && /usr/bin/echo -e '{ "attachments": [ { "fallback": "Required plain-text summary of the attachment.", "color": "#36a64f", "title": "[handouts] Update", "title_link": "'${GDRIVE_URL}'", "author_name": "'${AUTHOR_NAME}'", "author_link": "'${AUTHOR_LINK}'", "author_icon": "'${ICON_LINK}'", "text": "`'${GIT_HASH}'`: '${GIT_MESSAGE}'\\n- '${AUTHOR_NAME}'", "mrkdwn_in": [ "text" ], "ts": "'${TIME_STAMP}'" } ] }' \
    | curl -H "Accept: application/json" \
           -H "Content-type: application/json" \
	   -X POST \
	   "${WEBHOOK_URL}" \
	   -d @-
done
