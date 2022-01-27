#!/bin/bash
bundle check || bundle install

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

rails s -p 3000 -b '0.0.0.0'
