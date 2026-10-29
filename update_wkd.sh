#!/bin/bash
set -euo pipefail

WKD_USER_FILE=./wkd_users.json
DOMAIN=chimbosonic.com
DIRECT_DIR=".well-known/openpgpkey/hu"
ADVANCED_DIR=".well-known/openpgpkey/${DOMAIN}/hu"

mkdir -p "${DIRECT_DIR}" "${ADVANCED_DIR}"

jq -c '.users[]' "${WKD_USER_FILE}" | while read -r user; do
    user_id=$(jq -r '.id' <<< "${user}")
    wkd_hash=$(jq -r '.wkd_hash' <<< "${user}")
    # Accept either key_fingerprints (array) or the old key_fingerprint (string)
    fingerprints=$(jq -r '(.key_fingerprints // [.key_fingerprint])[]' <<< "${user}")

    for fpr in ${fingerprints}; do
        if ! gpg --list-keys "${fpr}" > /dev/null 2>&1; then
            echo "Key ${fpr} for ${user_id} not in keyring" >&2
            exit 1
        fi
    done

    # Fingerprints contain no spaces, so word splitting here is intended
    gpg --no-armor --export ${fingerprints} > "${DIRECT_DIR}/${wkd_hash}"
    cp "${DIRECT_DIR}/${wkd_hash}" "${ADVANCED_DIR}/${wkd_hash}"
done
