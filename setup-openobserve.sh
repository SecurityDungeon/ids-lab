#!/bin/sh


source .env

echo "Create OpenObserve saved views..."
curl -X 'POST'
   'http://127.0.0.1:5080/api/lab/savedviews'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/WordPress.view.json'
curl -X 'POST'
   'http://127.0.0.1:5080/api/lab/dashboards'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/SuricataAlerts.dashboard.json'
curl -X 'POST'
   'http://127.0.0.1:5080/api/lab/dashboards'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/SuricataFlows.dashboard.json'
curl -X 'POST'
   'http://127.0.0.1:5080/api/admin/savedviews'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/WordPress.view.json'
curl -X 'POST'
   'http://127.0.0.1:5080/api/admin/dashboards'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/SuricataAlerts.dashboard.json'
curl -X 'POST'
   'http://127.0.0.1:5080/api/admin/dashboards'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/SuricataFlows.dashboard.json'
curl -X 'POST'
   'http://127.0.0.1:5080/api/admin/dashboards'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/Docker.dashboard.json'

echo "Create OpenObserve dashboards..."
curl -X 'POST'
   'http://127.0.0.1:5080/api/lab/dashboards'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/LabDashboard.dashboard.json'
curl -X 'POST'
   'http://127.0.0.1:5080/api/admin/dashboards'
   -H 'accept: application/json'
   -H 'Content-Type: application/json'
   -u ${ZO_ROOT_USER_EMAIL}:${ZO_ROOT_USER_PASSWORD}
   --data-binary '@openobserve/LabDashboard.dashboard.json'

