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
    ##FUNCTION##
    function yearsDecision(){
        declare extractedDate="$(echo ${LINE} | awk '{print $1}')"
	declare dueDate="$(LANG="C" date -d "${extractedDate}" "+%m/%d")"
        declare todayMonth="$(LANG="C" date "+%-m")"
        declare inputMonth="$(LANG="C" date -d "${extractedDate}" "+%-m")"
        if [[ "${inputMonth}" -lt "${todayMonth}" ]]; then
          declare nextYear="$(LANG="C" date -d "1 years" "+%Y")"
          {
           echo "${nextYear}/${dueDate}"
          }
        else
          declare currentYear="$(LANG="C" date "+%Y")"
          {
           echo "${currentYear}/${dueDate}"
          }
        fi
    }
    ##PAREMETER##
    declare LINE="${@}"
    declare title="$(echo ${LINE} | awk '{print $3}')"
    declare date="$(yearsDecision)"
    declare description="$(echo ${LINE} | awk '{print $2,$4}')"
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

