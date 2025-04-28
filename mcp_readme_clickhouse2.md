# ClickHouse MCP Integration Guide

This document explains how to set up and run the ClickHouse MCP server locally and integrate it with LibreChat.

## Prerequisites
- Python 3.13
- Homebrew (for macOS)
- Docker & Docker Compose (for LibreChat)

## 1. Clone the MCP repository
```bash
cd ~/Documents/GitHub
git clone https://github.com/ClickHouse/mcp-clickhouse.git
cd mcp-clickhouse
```

## 2. Create and activate a Python virtual environment
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -e .[cli]
```

## 3. Configure ClickHouse connection
Create a `.env` file in the repo root with:
```env
CLICKHOUSE_HOST=sql-clickhouse.clickhouse.com
CLICKHOUSE_PORT=8443
CLICKHOUSE_USER=demo
CLICKHOUSE_PASSWORD=
CLICKHOUSE_SECURE=true
CLICKHOUSE_VERIFY=true
CLICKHOUSE_CONNECT_TIMEOUT=30
CLICKHOUSE_SEND_RECEIVE_TIMEOUT=30
```

## 4. Expose the SSE endpoint
In `mcp_clickhouse/mcp_server.py`, ensure you have:
```python
# at the bottom of the file
app = mcp.sse_app()
```

## 5. Start the ClickHouse MCP server
Open a new terminal window and run:
```bash
cd ~/Documents/GitHub/mcp-clickhouse
source .venv/bin/activate
export $(grep -v '^#' .env | xargs)
uvicorn mcp_clickhouse.mcp_server:app --host 0.0.0.0 --port 8001
```

The server will start on `http://0.0.0.0:8001` and expose the SSE endpoint at `/sse`.

## 6. Update LibreChat configuration
In your LibreChat repo, edit `librechat.yaml` under `mcpServers`:
```yaml
mcp-clickhouse:
  type: sse
  url: http://host.docker.internal:8001/sse
  iconPath: "https://upload.wikimedia.org/wikipedia/commons/0/0e/Clickhouse.png"
  timeout: 300000
```
Save and restart LibreChat:
```bash
cd ~/Documents/GitHub/LibreChat
docker compose up -d --build --force-recreate
```

## 7. Verify the integration
Run:
```bash
docker compose logs --tail 50
```
You should see:
```
[MCP][mcp-clickhouse] Capabilities: {...}
[MCP][mcp-clickhouse] Available tools: list_databases, list_tables, run_select_query
```
Open the LibreChat UI at `http://localhost:3080` and try a query, e.g. `SHOW DATABASES;`.

---

Now your ClickHouse MCP server is live and integrated with LibreChat!
