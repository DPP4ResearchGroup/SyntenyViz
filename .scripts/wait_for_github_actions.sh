#!/usr/bin/env bash

set -euo pipefail

# This script waits for all GitHub Actions workflow runs for the current commit
# to complete successfully before allowing the Travis CI job to proceed.
#
# Requirements:
# - env: TRAVIS_COMMIT (set by Travis)
# - env: orgName, packageName (available in .travis.yml env.global)
# - env: GITHUB_TOKEN (recommended, to avoid rate limiting)
# - tool: jq (installed in Travis before_install)

OWNER=${GITHUB_OWNER:-${orgName:-}}
REPO=${GITHUB_REPO:-${packageName:-}}
SHA=${GITHUB_SHA:-${TRAVIS_COMMIT:-}}

if [[ -z "${OWNER}" || -z "${REPO}" || -z "${SHA}" ]]; then
  echo "[wait_for_github_actions] Missing OWNER/REPO/SHA; skipping wait. OWNER='${OWNER}' REPO='${REPO}' SHA='${SHA}'" >&2
  exit 0
fi

API_URL="https://api.github.com/repos/${OWNER}/${REPO}/actions/runs?head_sha=${SHA}"

AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
else
  echo "[wait_for_github_actions] GITHUB_TOKEN not set; proceeding unauthenticated (may be rate-limited)." >&2
fi

echo "[wait_for_github_actions] Waiting for GitHub Actions runs on ${OWNER}/${REPO}@${SHA} to finish successfully..."

# Max wait: 60 minutes (3600 seconds) with 15s interval => 240 iterations
MAX_ITERATIONS=240
SLEEP_SECONDS=15

iteration=0
while (( iteration < MAX_ITERATIONS )); do
  iteration=$((iteration + 1))

  http_code=$(curl -sS -o /tmp/gha_runs.json -w "%{http_code}" "${API_URL}" "${AUTH_HEADER[@]}" -H "Accept: application/vnd.github+json") || true
  if [[ "${http_code}" != "200" ]]; then
    echo "[wait_for_github_actions] GitHub API returned HTTP ${http_code}; response follows:" >&2
    cat /tmp/gha_runs.json >&2 || true
    echo "[wait_for_github_actions] Will retry in ${SLEEP_SECONDS}s..." >&2
    sleep "${SLEEP_SECONDS}"
    continue
  fi

  total_count=$(jq -r '.total_count // 0' /tmp/gha_runs.json)

  if [[ "${total_count}" -eq 0 ]]; then
    # No Actions runs found for this commit yet. Keep waiting for a short period
    # because workflows may be queued.
    echo "[wait_for_github_actions] No GitHub Actions runs found yet for this commit. Retrying in ${SLEEP_SECONDS}s..."
    sleep "${SLEEP_SECONDS}"
    continue
  fi

  # Collect statuses and conclusions for runs on this commit (ignore this script's environment)
  statuses=$(jq -r '.workflow_runs[] | .status' /tmp/gha_runs.json | tr '\n' ' ')
  conclusions=$(jq -r '.workflow_runs[] | .conclusion' /tmp/gha_runs.json | tr '\n' ' ')

  # Determine if any run is still in_progress/queued/waiting
  any_incomplete=$(jq -r '[.workflow_runs[] | select(.status != "completed")] | length' /tmp/gha_runs.json)

  if [[ "${any_incomplete}" -gt 0 ]]; then
    echo "[wait_for_github_actions] Runs pending. statuses=[${statuses}] Retrying in ${SLEEP_SECONDS}s..."
    sleep "${SLEEP_SECONDS}"
    continue
  fi

  # All completed; ensure all have conclusion == success
  any_failed=$(jq -r '[.workflow_runs[] | select(.conclusion != "success")] | length' /tmp/gha_runs.json)

  if [[ "${any_failed}" -gt 0 ]]; then
    echo "[wait_for_github_actions] Some GitHub Actions runs did not succeed. conclusions=[${conclusions}]" >&2
    # Print summary table
    jq -r '.workflow_runs[] | "- \(.name) (#\(.run_number)) status=\(.status) conclusion=\(.conclusion) url=\(.html_url)"' /tmp/gha_runs.json >&2
    exit 1
  fi

  echo "[wait_for_github_actions] All GitHub Actions runs completed successfully. Proceeding."
  exit 0
done

echo "[wait_for_github_actions] Timed out after $((MAX_ITERATIONS * SLEEP_SECONDS)) seconds waiting for GitHub Actions. Failing build." >&2
exit 1


