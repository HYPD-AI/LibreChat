#!/usr/bin/env sh
# Install Facebook Ads MCP dependencies at startup
if [ -f /app/facebook-ads-mcp-server/requirements.txt ]; then
  pip3 install --no-cache-dir -r /app/facebook-ads-mcp-server/requirements.txt
fi

# Launch backend
exec npm run backend
