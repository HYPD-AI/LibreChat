# MCP Docker Integration Summary

We wired up the Facebook-Ads MCP (and other stdio MCPs) inside a single Docker image:

1. **Dockerfile**
   - Installed `python3`, `pip`, and `jemalloc` via `apk`
   - Created a Python venv and prepended `/venv/bin` to `$PATH`
   - Added `entrypoint.sh` (using `COPY --chmod=0755`) to install MCP dependencies at container startup

2. **entrypoint.sh**
   - On container launch, checks for `/app/facebook-ads-mcp-server/requirements.txt` and runs `pip install` before starting the backend

3. **docker-compose.yml**
   - Bind-mounts the host `facebook-ads-mcp-server` directory into `/app/facebook-ads-mcp-server`

4. **librechat.yaml**
   - Points `fb-ads-mcp-server` command to `/app/facebook-ads-mcp-server/server.py`
   - Uses `${FB_TOKEN}` from `.env`

Now a single `docker compose up` bundles all MCP servers via stdio transport.
