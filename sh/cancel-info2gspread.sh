#! /usr/bin/env bash


###PARAMETER###
ABSOLUTE_PATH="$(cd $(dirname ${0}) && pwd)"

###PATH###
export PATH="$(echo ${ABSOLUTE_PATH} | sed 's/sh/script/'):$PATH"

###API###
END_URL="$(cat $(echo ${ABSOLUTE_PATH} | sed 's/sh/assets/')/api_url.txt)"

###FUNCTIONS###
function GET_DATA(){
    {
     curl -sS https://www.kyoto-art.ac.jp/student/ \
     | grep -B 1 -A 5 '<p class="time">' \
     | sed 's#<[^>]*>##g;s# #/#g' \
     | sed 's#^/*##g' \
     | sed '/^$/d;s/--//g' \
     | sed '/曜/s/^/(/;s/曜/) /' \
     | sed '/：/s/\n/ /g' \
     | tr \\n ' ' \
     | sed 's/  /\n/g;s/$/\n/' \
     | sed 's#担当教員：# #g;s#・#~#g;s#　##g;y#１２３４５６#123456#;s#／#/#g' \
     | awk '{printf("%s%s %s [%s]%s %s\n",$1,$2,$3,$4,$5,$6)}' \
     | sed 's# /# #g'
    }
}
function DATA2CSV(){
    ##PARAMERTER##
    LINE="${@}"
    function yearsDecision(){
        todayMonth="$(LANG="C" date "+%-m")"
        inputMonth="$(LANG="C" date -d $(echo ${LINE} | awk '{print $1}') "+%-m")"
        if [[ "${inputMonth}" -lt "${todayMonth}" ]]; then
          year="$(LANG="C" date -d "1 years" "+%Y")"
        else
          year="$(LANG="C" date "+%Y")"
        fi
    }
    title="$(echo ${LINE} | awk '{print $3}')"
    date="$(yearsDecision && LANG="C" date -d $(echo ${LINE} | awk '{print $1}') "+%m/%d" | sed "s#^#${year}/#g")"
    description="$(echo ${LINE} | awk '{print $2,$4}')"
    ##MAIN##
    {
     echo "${title},${date},${description}"
    }
}
function MAIN(){
    {
     export -f DATA2CSV && \
     cat <(GET_DATA) \
     | xargs -I@ bash -c 'DATA2CSV "@" | gspreadwrite.py' && \
     curl -sSL "${END_URL}" > /dev/null
    }
}


###MAIN###
{
 MAIN
}

