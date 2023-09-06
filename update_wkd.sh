#!/bin/bash
WKD_USER_FILE=./wkd_users.json

WKD_USERS=$(cat ${WKD_USER_FILE} | jq -c '.users[]' )
DOMAIN=chimbosonic.com


mkdir -p ".well-known/openpgpkey/hu/" ".well-known/openpgpkey/${DOMAIN}/hu/"

for user in ${WKD_USERS}
do
    user_id=$(echo ${user} | jq -cr '.id')
    user_wkd_hash=$(echo ${user} |  jq -cr '.wkd_hash')
    user_key_fingerprint=$(echo ${user} |  jq -cr '.key_fingerprint')

    gpg --no-armor --export ${user_key_fingerprint} > ".well-known/openpgpkey/hu/${user_wkd_hash}"
    gpg --no-armor --export ${user_key_fingerprint} > ".well-known/openpgpkey/${DOMAIN}/hu/${user_wkd_hash}"
done
