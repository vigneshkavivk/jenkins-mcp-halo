# Production Dockerfile for mcp-jenkins
# Builds from pyproject.toml using uv and runs the installed console script

FROM python:3.13-slim AS base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git \
 && rm -rf /var/lib/apt/lists/*

# uv for fast installs
RUN pip install --no-cache-dir uv

# Copy dependency metadata first for better caching
COPY pyproject.toml uv.lock ./

# Install only production dependencies
RUN uv sync --frozen --no-dev

# Copy source and metadata
COPY . .

# Install the package (editable keeps live paths inside container)
RUN uv pip install -e . && chmod +x run.sh

# Create non-root user
RUN useradd --create-home --shell /bin/bash appuser \
 && chown -R appuser:appuser /app
USER appuser

# Default SSE port used by the server when transport=sse
EXPOSE 9887

# Healthcheck to validate import
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD python -c "import mcp_jenkins; print('OK')" || exit 1

# Entry: use uv to run the console script defined in pyproject ([project.scripts])
ENTRYPOINT ["bash", "/app/run.sh"]

