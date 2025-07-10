# ClickHouse MCP Patches & Startup Guide

This file collects all required patches and commands to run the ClickHouse MCP server.

---
## 1. Patch `mcp_server.py`
Add the missing `logging` import so the module loads and `app = mcp.sse_app()` is exposed.

```diff
--- a/mcp_clickhouse/mcp_clickhouse/mcp_server.py
+++ b/mcp_clickhouse/mcp_clickhouse/mcp_server.py
@@
 import concurrent.futures
 import atexit
+import logging
 import clickhouse_connect
 ```

---
## 2. Install Python 3.13 (macOS)

```bash
brew install python@3.13
```

---
## 3. Create & activate virtualenv

```bash
cd ~/Documents/GitHub/mcp-clickhouse
python3.13 -m venv .venv
source .venv/bin/activate
```

---
## 4. Install dependencies

```bash
pip install --upgrade pip setuptools wheel
pip install -e .
pip install "mcp[cli]"
pip install "uvicorn[standard]"
```

---
## 5. Launch the server

Open a new terminal and run:

```bash
cd ~/Documents/GitHub/mcp-clickhouse
source .venv/bin/activate
export $(grep -v '^#' .env | xargs)
# SSE endpoint will be exposed at /sse
uvicorn mcp_clickhouse.mcp_server:app --host 0.0.0.0 --port 8001
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8001
INFO:     127.0.0.1:… - "GET /sse HTTP/1.1" 200 OK
```

Now LibreChat (configured to `url: http://host.docker.internal:8001/sse`) will connect successfully.
