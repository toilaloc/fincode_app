#!/bin/bash
set -e

# For development: Check if gems need installation
# For production: Gems are baked into the image during build
if [ "$RAILS_ENV" != "production" ]; then
  echo "Development mode: Checking gems..."
  bundle check || bundle install --jobs 4 --retry 3
fi

rm -f /app/tmp/pids/server.pid

exec "$@"
