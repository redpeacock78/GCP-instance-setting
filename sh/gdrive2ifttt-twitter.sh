#!/usr/bin/env bash



###PARAMETERS###
TARGET_DIR="/home/redpeacock78/gdrive/handouts"
IGNORE_DIR="/home/redpeacock78/gdrive/handouts/.git"
GDRIVE_URL="https://drive.google.com/open?id=1wf0wE1dMbZU2fQfHGz1L1YK8HjAZpXYc"
WEBHOOK_URL="$(cat /home/redpeacock78/gcp-instance-setting/assets/webhooks.txt | grep 'maker.ifttt.com')"


###TEXT###
while true; do
    function dir_watch(){
        inotifywait -r \
	            -e CREATE \
		    -e MODIFY \
		    -e DELETE \
		    --exclude "${IGNORE_DIR}" \
		    "${TARGET_DIR}"
    }
    dir_watch && \
    {
    TIME_STAMP="$(date -d "$(git log -1 --pretty=format:'%cD' -C ${TARGET_DIR})" +%s)"
    GIT_HASH="$(git log -1 --pretty=format:'%h' -C ${TARGET_DIR})"
    GIT_MESSAGE="$(git log -1 --pretty=format:'%s' -C ${TARGET_DIR})"
    } && \
    /usr/bin/echo '{ "value1" : "<br>'${GIT_HASH}': '${GIT_MESSAGE}'", "value2" : "<br>'${TIME_STAMP}'", "value3" : "<br>'${GDRIVE_URL}'" }' \
    | curl -X POST \
           -H "Content-Type: application/json" \
	   -d @- \
	   "${WEBHOOK_URL}"
done
