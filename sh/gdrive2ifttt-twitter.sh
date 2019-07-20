#!/usr/bin/env bash



###PARAMETERS###
TARGET_DIR="/home/redpeacock78/gdrive/handouts"
IGNORE_DIR="/home/redpeacock78/gdrive/handouts/.git"
TIME_STAMP="$(cd ${TARGET_DIR} && git log -1 --pretty=format:'%cD')"
GIT_HASH="$(cd ${TARGET_DIR} && git log -1 --pretty=format:'%h')"
GIT_MESSAGE="$(cd ${TARGET_DIR} && git log -1 --pretty=format:'%s')"
GDRIVE_URL="https://drive.google.com/open?id=1wf0wE1dMbZU2fQfHGz1L1YK8HjAZpXYc"
WEBHOOK_URL="$(cat /home/redpeacock78/gcp-instance-setting/assets/webhooks.txt | grep 'maker.ifttt.com')"


###TEXT###
while true; do
    inotifywait -r \
	        -e CREATE \
                -e MODIFY \
		-e DELETE \
		--exclude "${IGNORE_DIR}" \
		"${TARGET_DIR}" \
    && sleep 60 \
    && /usr/bin/echo '{ "value1" : "<br>'${GIT_HASH}': '${GIT_MESSAGE}'", "value2" : "<br>'${TIME_STAMP}'", "value3" : "<br>'${GDRIVE_URL}'" }' \
    | curl -X POST \
           -H "Content-Type: application/json" \
	   -d @- \
	   "${WEBHOOK_URL}"
done
