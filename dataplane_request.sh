#!/bin/bash
# Description: Use DataPlane API to get All HAproxy Frontends and their associated Backends
# Author: DeedWark <github.com/DeedWark>
# Date: 2022-06-20
# Version: 1.0.0

set -eo pipefail +x

CONFIG_FILE="./config"

setup() {
    #-- Check if config file is present then username and pass then IP --#
    if [[ -f "${CONFIG_FILE}" ]] && [[ -s "${CONFIG_FILE}" ]]; then
        source "${CONFIG_FILE}" || printf "[ERROR] - Config file error!\nTry env var\n" >&2
        if [[ -z "${DP_USERNAME}" ]] && [[ -z "${DP_PASSWORD}" ]]; then
            printf "[ERROR] - I cannot find any username or password, sorry sir!\n" >&2
            exit 2
        else
            if [[ -z "${DP_URL}" ]]; then
                printf "[ERROR] - No IP provided\n" >&2
                exit 2
            fi
        fi
    else
        printf "[ERROR] - Config file error!\n" >&2
        exit 2
    fi

    #-- Convert value to base64 to get token --#
    _token=$(printf "%s:%s" "${DP_USERNAME}" "${DP_PASSWORD}" | base64)

    #-- Get all IPs presents in the config file --#
    declare -ag DATAPLANE_URL
    #-- Check if there is comma --#
    if [[ "${DP_URL}" == *,* ]]; then
        for url in $(tr ',' '\n' <<<"${DP_URL}"); do
            DATAPLANE_URL+=("${ip}")
        done
        #-- Check if there is whitespace --#
    elif [[ "${DP_URL}" =~ \  ]]; then
        for url in $(tr ' ' '\n' <<<"${DP_URL}"); do
            DATAPLANE_URL+=("${ip}")
        done
    elif [[ "${DP_URL}" == *$'\n'* ]]; then
        while read -r ip; do
            DATAPLANE_URL+=("${ip}")
        done <<<"${DP_URL}"
    else
        DATAPLANE_URL+=("${DP_URL}")
    fi
}

dataplane_request() {
    curl -s -X GET \
        -H "Content-Type: application/json" \
        -H "Authorization: Basic ${_token}" \
        "http://${1}/v2/services/haproxy/configuration/${2}"
}

get_frontend_backend() {

    #-- Arrays --#
    declare -a frontend_list
    declare -a backend_list

    #-- Reach all dataplane_url and  get frontend and backend list --#
    for ha_url in "${DATAPLANE_URL[@]}"; do

        #-- Get all frontends --#
        frontend_list+=($(dataplane_request "${ha_url}" "frontends" | jq -r '.data[] | .name' | sort -u))
        #-- Get all backends --#
        backend_list+=($(dataplane_request "${ha_url}" "backends" | jq -r '.data[] | .name' | sort -u))
    done

    #-- sort and uniq frontend and backend list --#
    frontend_list_sorted=$(tr ' ' '\n' <<<"${frontend_list[@]}" | sort -u)
    backend_list_sorted=$(tr ' ' '\n' <<<"${backend_list[@]}" | sort -u)

    for ha_url in "${DATAPLANE_URL[@]}"; do
        while read -r frontend; do
            #-- Get only address:port of frontend's info --#
            dataplane_request "${ha_url}" "binds?frontend=${frontend}" |
                jq -r '.data[] | "\nFrontend: '"${frontend}"' -> \(.address // empty):\(.port // empty)"'

            while read -r backend; do
                #-- Get only address:port of backend's info ONLY with the associated frontend --#
                dataplane_request "${ha_url}" "servers?backend=${backend}" |
                    jq -r '.data[] | if (.name == "'"${frontend}"'") then "- Backend: '"${backend}"' -> \(.address // empty):\(.port // empty)" else empty end'
            done <<<"${backend_list_sorted}"
        done <<<"${frontend_list_sorted}"
    done
}

main() {
    setup
    get_frontend_backend
}

main
