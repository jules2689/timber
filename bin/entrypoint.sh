#!/bin/bash

set -e

# Server for while we're waiting for ES
ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => ENV["PORT"], :DocumentRoot => "/app/public/es-wait").start' &

# Elasticsearch
/usr/share/elasticsearch/bin/elasticsearch -d
echo "Waiting for Elasticsearch to launch on 9200..."
timeout 30 sh -c 'until curl http://localhost:9200 > /dev/null 2>&1; do sleep 1; echo "Attempting to connect"; done'
echo "Elasticsearch launched"

# Kill the waiting server 
echo "Attempting to shutoff ES Wait server..."
pid=$(lsof -t -i :$PORT)
echo "Found process running on $PORT at PID $pid, killing it"
kill -9 $pid

# Start the real Server
rm -f /app/tmp/pids/server.pid
bin/rails server -b 0.0.0.0 -p $PORT
