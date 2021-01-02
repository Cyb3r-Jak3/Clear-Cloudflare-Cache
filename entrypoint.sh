#!/bin/sh

set -e

uses() {
    [ -n "${1}" ]
}

usesBoolean() {
  [ -n "${1}" ] && [ "${1}" = "true" ]
}

main() {
    if ! uses "$ZONE"; then
        echo "ZONE is not set. Quitting."
        exit 1
    fi

    if uses "$GLOBAL_KEY"; then
        if uses "$EMAIL"; then
            method="legacy"
        else
            echo "Need email when using Cloudflare Global Key"
            exit 1
        fi
    elif uses "$API_TOKEN"; then
        method="token"
    else
        echo "No Authentication Method was given."
    fi

    if uses "$URLS"; then
        set -- --data '{"files":'"${URLS}"'}'
    else
        set -- --data '{"purge_everything":true}'
    fi
    if [ "$method" = "legacy" ]; then
        RESPONSE=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${ZONE}/purge_cache" \
                      -H "Content-Type: application/json" \
                      -H "X-Auth-Email: ${EMAIL}" \
                      -H "X-Auth-Key: ${GLOBAL_KEY}" \
                      -w "HTTP_STATUS:%{http_code}" \
                      "$@")
    elif [ "$API_METHOD" -eq 2 ]; then
        RESPONSE=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${ZONE}/purge_cache" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer ${API_TOKEN}" \
                      -w "HTTP_STATUS:%{http_code}" \
                      "$@")
    fi
    BODY=$(echo "${RESPONSE}" | sed -E 's/HTTP_STATUS\:[0-9]{3}$//')
    STATUS=$(echo "${RESPONSE}" | tr -d '\n' | sed -E 's/.*HTTP_STATUS:([0-9]{3})$/\1/')

    if [ "${STATUS}" -eq "200" ]; then
        echo "Successfully purged!"
        exit 0
    else
        echo "Purge failed. HTTP Code: ${STATUS} API response was: "
        echo "${BODY}"
        exit 1
    fi
}

