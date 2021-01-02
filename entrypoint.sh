#!/bin/sh

set -e

uses() {
    [ -n "${1}" ]
}

usesBoolean() {
  [ -n "${1}" ] && [ "${1}" = "true" ]
}

main() {
    if ! uses "${INPUT_ZONE}"; then
        echo "Zone is not set and is required."
        exit 1
    fi

    if uses "${INPUT_GLOBAL_TOKEN}"; then
        if uses "${INPUT_EMAIL}"; then
            method="legacy"
        else
            echo "Need email when using Cloudflare Global Key"
            exit 1
        fi
    elif uses "${INPUT_API_TOKEN}"; then
        method="token"
    else
        echo "No Authentication Method was given."
        exit 1
    fi

    if uses "${INPUT_URLS}"; then
        urlInput='{"files":'"${INPUT_URLS}"'}'
    else
        urlInput='{"purge_everything":true}'
    fi
    if [ "$method" = "legacy" ]; then
        RESPONSE=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${INPUT_ZONE}/purge_cache" \
                      -H "Content-Type: application/json" \
                      -H "X-Auth-Email: ${INPUT_EMAIL}" \
                      -H "X-Auth-Key: ${INPUT_GLOBAL_TOKEN}" \
                      -w "HTTP_STATUS:%{http_code}" \
                      --data "${urlInput}"
                      )
    elif [ "$method" = "token" ]; then
        RESPONSE=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${INPUT_ZONE}/purge_cache" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer ${INPUT_API_TOKEN}" \
                      -w "HTTP_STATUS:%{http_code}" \
                      --data "${urlInput}"
                      )
    fi
    BODY=$(echo "${RESPONSE}" | sed -E 's/HTTP_STATUS\:[0-9]{3}$//')
    STATUS=$(echo "${RESPONSE}" | tr -d '\n' | sed -E 's/.*HTTP_STATUS:([0-9]{3})$/\1/')

    if [ "${STATUS}" -eq "200" ]; then
        echo "Successfully cleared!"
        exit 0
    else
        echo "Purge failed. HTTP Code: ${STATUS} API response was: "
        echo "${BODY}"
        exit 1
    fi
}

main
