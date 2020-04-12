#!/bin/bash

set -e

echo $JAVA_HOME
/usr/share/elasticsearch/bin/elasticsearch -d

echo "Waiting for Elasticsearch to launch on 9200..."

timeout 30 sh -c 'until curl http://localhost:9200 > /dev/null 2>&1; do sleep 1; echo "Attempting to connect"; done'

echo "Elasticsearch launched"

rm -f /app/tmp/pids/server.pid
bin/rails server -b 0.0.0.0
