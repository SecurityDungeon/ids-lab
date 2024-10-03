#!/bin/sh

source .env

openobserve_api_post() {
    curl --silent -X "POST" \
        "http://127.0.0.1:5080/api/$1/$2" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD} \
        --output /dev/null \
        --data-binary "@openobserve/$3"
}

echo "Create OpenObserve functions..."
openobserve_api_post lab functions ParseWinEvtLog.function.json

echo "Create OpenObserve saved views..."
# Lab user
openobserve_api_post lab savedviews WordPress.view.json
openobserve_api_post lab savedviews SuricataAlerts.view.json
openobserve_api_post lab savedviews SuricataFlows.view.json
openobserve_api_post lab savedviews WindowsEventLog.view.json
openobserve_api_post lab savedviews WindowsLogon.view.json
openobserve_api_post lab savedviews WindowsProcess.view.json

# Admin user
openobserve_api_post admin savedviews Docker.view.json

echo "Create OpenObserve dashboards..."
openobserve_api_post lab dashboards LabDashboard.dashboard.json
