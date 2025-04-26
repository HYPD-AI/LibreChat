# ClickHouse MCP Integration with LibreChat: Troubleshooting & Setup Summary

This document summarizes all steps, configurations, and troubleshooting attempts made to integrate the ClickHouse MCP server into the LibreChat environment, both inside Docker and as an external/local service.

---

## 1. Objective
Integrate the ClickHouse MCP server so that LibreChat can query ClickHouse databases via a standardized MCP interface.

---

## 2. Docker-Based Integration Attempts

### Dockerfile Changes
- Switched from `node:20-alpine` to `node:20-slim` for better Python support.
- Installed Python 3, pip, venv, and build dependencies for cryptography and Python packages.
- Created a Python venv at build time and installed MCP dependencies:
  - `clickhouse-connect>=0.8.16`
  - `python-dotenv>=1.0.1`
  - `uvicorn>=0.34.0`
  - `pip-system-certs>=4.0`
  - `mcp[cli]>=1.3.0`
- Tried to install `mcp-clickhouse` package, but failed due to Python version constraints (requires >=3.13, but Docker ships with 3.11/3.12).

### Entrypoint Script
- Upgraded pip, setuptools, and wheel at container startup.
- Attempted to install the local ClickHouse MCP server from a bind mount (`/app/mcp-clickhouse-server`) using pip editable mode (`pip install -e`).

### Docker Compose
- Configured a bind mount for the local `mcp-clickhouse` repo.
- Ensured LibreChat API container builds from the local Dockerfile.

### Result
- **Blocker:** `clickhouse-connect` could not be found/imported at runtime (`ModuleNotFoundError`).
- **Root Cause:** PyPI version constraints and Docker Python version mismatch prevent installation of `mcp-clickhouse` and its dependencies.

---

## 3. Running ClickHouse MCP Locally (Outside Docker)

### Rationale
- Docker-based install is blocked by Python version issues.
- Running the MCP server on the host (your Mac) allows use of any Python version and direct dependency management.

### Steps
1. **Setup a venv in your `mcp-clickhouse` repo:**
   ```sh
   cd /Users/ionutciobotaru/Documents/GitHub/mcp-clickhouse
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -e .
   ```
2. **Run the server:**
   ```sh
   .venv/bin/python -m mcp_clickhouse.main
   ```
   Or use any entrypoint script provided by the repo.

3. **Configure LibreChat to connect to the local MCP:**
   - In `librechat.yaml`:
     ```yaml
     mcpServers:
       mcp-clickhouse:
         type: http  # or tcp, if supported
         url: http://host.docker.internal:8000  # Use the port your MCP server is running on
         iconPath: "https://upload.wikimedia.org/wikipedia/commons/0/0e/Clickhouse.png"
         timeout: 300000
     ```
   - `host.docker.internal` allows Docker containers to reach services running on the host Mac.
   - Make sure your MCP server is listening on the specified port.

---

## 4. Key Troubleshooting Points
- **ModuleNotFoundError:** Always means the dependency is not installed in the Python environment actually running the MCP server.
- **Python Version Constraints:** Some MCP packages (like `mcp-clickhouse`) require Python >=3.13, which is not available in most Docker base images yet.
- **Editable Installs:** Use `pip install -e .` in your local repo to ensure all dependencies from `pyproject.toml` are installed.
- **Entrypoint vs Build:** Installing dependencies at build time in Docker is not enough if you later overwrite code with a bind mount; always ensure the runtime environment has all dependencies.

---

## 5. Recommendations
- For now, run ClickHouse MCP on your Mac and connect LibreChat to it via HTTP/TCP.
- Monitor for updates to Docker base images with Python >=3.13 if you want to move everything into containers in the future.
- Document all MCP server configs and connection URLs in your `librechat.yaml` for future reference.

---

## 6. Example: Local MCP Server Launch & LibreChat Config

**Terminal:**
```sh
cd /Users/ionutciobotaru/Documents/GitHub/mcp-clickhouse
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
.venv/bin/python -m mcp_clickhouse.main  # Add --port 8000 if needed
```

**librechat.yaml:**
```yaml
mcpServers:
  mcp-clickhouse:
    type: http
    url: http://host.docker.internal:8000
    iconPath: "https://upload.wikimedia.org/wikipedia/commons/0/0e/Clickhouse.png"
    timeout: 300000
```

---

## 7. References
- [ClickHouse MCP GitHub](https://github.com/your-org/mcp-clickhouse)
- [LibreChat Documentation](https://github.com/your-org/LibreChat)
- [Docker host networking](https://docs.docker.com/desktop/networking/)

---

**Last updated:** 2025-04-26

If you encounter new issues or want to try a different approach, update this document with your findings!

---

## 8. Reference: docker-compose.yml Bind Mounts

Below is a sample of the relevant `volumes`/bind mounts for MCP servers and other assets in your `docker-compose.yml`:

```yaml
      - type: bind
        source: ./.env
        target: /app/.env
      - type: bind
        source: ./images
        target: /app/client/public/images
      - type: bind
        source: /Users/ionutciobotaru/Documents/GitHub/facebook-ads-mcp-server
        target: /app/facebook-ads-mcp-server
      - type: bind
        source: /Users/ionutciobotaru/Documents/GitHub/gaql-mcp-server
        target: /app/gaql-mcp-server
        read_only: true
      - type: bind
        source: ./uploads
        target: /app/uploads
      - type: bind
        source: ./logs
        target: /app/api/logs
```

Use this as a template for adding or removing MCP servers and other resources in your Docker setup.
