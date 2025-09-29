
#!/usr/bin/env bash
set -euo pipefail

# Required environment variables
: "${JENKINS_URL:?Set JENKINS_URL}"
: "${JENKINS_USERNAME:?Set JENKINS_USERNAME}"
: "${JENKINS_PASSWORD:?Set JENKINS_PASSWORD}"

# Optional environment variables with defaults
TRANSPORT="${TRANSPORT:-sse}"
PORT="${PORT:-9887}"

exec uv run python main.py \
  --jenkins-url "${JENKINS_URL}" \
  --jenkins-username "${JENKINS_USERNAME}" \
  --jenkins-password "${JENKINS_PASSWORD}" \
  --transport "${TRANSPORT}" \
  --port "${PORT}"