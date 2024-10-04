#!/bin/sh

source .env

OPENOBSERVE="http://127.0.0.1:5080"

openobserve_status() {
    curl --silent -X "GET" \
        "${OPENOBSERVE}/healthz" \
        -H "accept: application/json" \
    | jq -r -j .status
}

openobserve_api_get() {
    curl --silent -X "GET" \
        "${OPENOBSERVE}/api/$1/$2" \
        -H "accept: application/json" \
        -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
}

openobserve_api_post() {
    curl --silent -X "POST" \
        "${OPENOBSERVE}/api/$1/$2" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD} \
        --output /dev/null \
        --data "$3"
}

echo "Wait until OpenObserve is ready..."
while [[ $(openobserve_status) != "ok" ]]; do
    sleep 1
done

echo "Create OpenObserve functions..."
openobserve_api_post lab functions ParseWinEvtLog.function.json

echo "Create OpenObserve saved views..."
# Lab user
openobserve_api_post lab savedviews @openobserve/WordPress.view.json
openobserve_api_post lab savedviews @openobserve/SuricataAlerts.view.json
openobserve_api_post lab savedviews @openobserve/SuricataFlows.view.json
openobserve_api_post lab savedviews @openobserve/WindowsEventLog.view.json
openobserve_api_post lab savedviews @openobserve/WindowsLogon.view.json
openobserve_api_post lab savedviews @openobserve/WindowsProcess.view.json

# Admin user
openobserve_api_post admin savedviews @openobserve/Docker.view.json

echo "Create OpenObserve dashboards..."
openobserve_api_post lab dashboards @openobserve/LabDashboard.dashboard.json

echo "Create OpenObserve users..."
openobserve_api_post lab users "{
    \"email\": \"${ZO_STUDENT_USER_EMAIL}\",
    \"password\": \"${ZO_STUDENT_USER_PASSWORD}\",
    \"first_name\": \"Student\",
    \"last_name\": \"User\",
    \"is_external\": false,
    \"role\": \"member\"
}"
