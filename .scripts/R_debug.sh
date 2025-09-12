#!/bin/bash

###
# secure:
#   robqbot_TOKEN
#   robqbot_EMAIL
#   robqbot_NAME
###

# Include git publish framework
# shellcheck source=/dev/null
# Use GITHUB_WORKSPACE if available, fallback to TRAVIS_BUILD_DIR for compatibility
WORKSPACE_DIR="${GITHUB_WORKSPACE:-${TRAVIS_BUILD_DIR}}"
source "${WORKSPACE_DIR}/.scripts/R_publish_framework.sh" --source-only

commit_R_debug() {
  # Build/run number fallback
  BUILD_NUMBER="${GITHUB_RUN_NUMBER:-${TRAVIS_BUILD_NUMBER}}"

  if [ -z "${robqbot_TOKEN}" ]; then
    echo "❌ ERROR: robqbot_TOKEN is not set; cannot create gist"
    return 1
  fi

  # Preflight: verify token has required scope/permission for Gists
  # Classic PAT must include 'gist' scope. Fine-grained PAT must grant 'Gists: Read and write'.
  HEADER_CHECK=$(curl -sSI -H "Authorization: Bearer ${robqbot_TOKEN}" https://api.github.com/user || true)
  OAUTH_SCOPES=$(printf "%s" "$HEADER_CHECK" | tr -d '\r' | grep -i '^x-oauth-scopes:' | cut -d':' -f2- | sed 's/^ *//')
  if ! printf "%s" "$OAUTH_SCOPES" | grep -qi 'gist'; then
    echo "⚠️  robqbot_TOKEN may be missing 'gist' scope/permission (X-OAuth-Scopes: ${OAUTH_SCOPES:-none})."
    echo "   Create a token with Gist access:"
    echo "   - Classic PAT: enable 'gist' scope"
    echo "   - Fine-grained PAT: Resource owner = your user; Permissions → Gists = Read and write"
    echo "   See: https://docs.github.com/en/rest/gists/gists?apiVersion=2022-11-28#create-a-gist"
  fi

  # Find the first Rcheck directory
  RCHECK_DIR=$(ls -d ./*.Rcheck 2>/dev/null | head -n 1 || true)
  if [ -z "$RCHECK_DIR" ]; then
    echo "⚠️  No .Rcheck directory found; will upload summary only"
  else
    echo "✅ Found Rcheck directory: $RCHECK_DIR"
  fi

  # Create a temporary working area
  TMP_DIR=$(mktemp -d)
  SUMMARY_FILE="$TMP_DIR/debug_summary.txt"

  # Compose summary
  {
    echo "SyntenyViz Debug Summary"
    echo "Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo "Repository: ${GITHUB_REPOSITORY:-unknown}"
    echo "Workflow Run: ${GITHUB_RUN_ID:-unknown}"
    echo "Build Number: ${BUILD_NUMBER:-unknown}"
    echo "Commit SHA: ${GITHUB_SHA:-unknown}"
    echo "Ref: ${GITHUB_REF:-unknown}"
    echo
    echo "Runner Info:"
    uname -a || true
    echo
    if [ -n "$RCHECK_DIR" ]; then
      echo "Rcheck directory: $RCHECK_DIR"
      echo "Rcheck tree (top level):"
      (cd "$RCHECK_DIR" && ls -la) || true
      echo
      # Include tails of common files if present
      for f in 00install.out 00check.log; do
        if [ -f "$RCHECK_DIR/$f" ]; then
          echo "===== BEGIN $f (tail -n 400) ====="
          tail -n 400 "$RCHECK_DIR/$f" || true
          echo "===== END $f ====="
          echo
        fi
      done
    fi
  } > "$SUMMARY_FILE"

  # Helper to JSON-escape file content using Python (available on GitHub runners)
  json_escape_file() {
    python3 - "$1" << 'PY'
import json,sys
p=sys.argv[1]
with open(p,'r',errors='ignore') as fh:
    print(json.dumps(fh.read()))
PY
  }

  SUMMARY_JSON=$(json_escape_file "$SUMMARY_FILE")

  # Create the gist with the summary file
  CREATE_PAYLOAD=$(cat <<EOF
{ "description": "SyntenyViz debug artifacts (build ${BUILD_NUMBER})", "public": false, "files": { "debug_summary.txt": { "content": ${SUMMARY_JSON} } } }
EOF
)

  RESPONSE=$(curl -sS -H "Accept: application/vnd.github+json" \
                  -H "Authorization: Bearer ${robqbot_TOKEN}" \
                  -H "X-GitHub-Api-Version: 2022-11-28" \
                  -d "$CREATE_PAYLOAD" \
                  https://api.github.com/gists)

  GIST_ID=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('id',''))" <<< "$RESPONSE")
  GIST_URL=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('html_url',''))" <<< "$RESPONSE")
  STATUS_CODE=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('status',''))" <<< "$RESPONSE" 2>/dev/null || echo "")

  if [ -z "$GIST_ID" ]; then
    echo "❌ Failed to create gist"
    echo "$RESPONSE"
    if printf "%s" "$RESPONSE" | grep -q 'Resource not accessible by personal access token'; then
      echo "👉 The token used does not have permission to access Gists."
      echo "   Fix by using a token with Gist write access:"
      echo "   - Classic PAT: include 'gist' scope"
      echo "   - Fine-grained PAT: grant 'Gists: Read and write'"
      echo "   Then set robqbot_TOKEN accordingly (repository/organization secret or environment)."
    fi
    rm -rf "$TMP_DIR"
    return 1
  fi

  echo "✅ Created gist: $GIST_URL"

  # Attach selected Rcheck files if present and reasonably sized
  if [ -n "$RCHECK_DIR" ]; then
    attach_file() {
      local src="$1"
      local name="$2"
      if [ ! -f "$src" ]; then return 0; fi
      local sz
      sz=$(wc -c < "$src" 2>/dev/null || echo 0)
      local tmp="$TMP_DIR/$name"
      if [ "$sz" -gt 900000 ]; then
        tail -c 900000 "$src" > "$tmp" || cp "$src" "$tmp"
      else
        cp "$src" "$tmp"
      fi
      local content_json
      content_json=$(json_escape_file "$tmp")
      local patch_payload
      patch_payload=$(cat <<EOF
{ "files": { "${name}": { "content": ${content_json} } } }
EOF
)
      curl -sS -X PATCH -H "Accept: application/vnd.github+json" \
           -H "Authorization: Bearer ${robqbot_TOKEN}" \
           -H "X-GitHub-Api-Version: 2022-11-28" \
           -d "$patch_payload" \
           "https://api.github.com/gists/${GIST_ID}" > /dev/null || true
    }

    attach_file "$RCHECK_DIR/00install.out" "00install.out"
    attach_file "$RCHECK_DIR/00check.log" "00check.log"
    # Common additional logs
    for extra in "tests/testthat.Rout" "examples/examples.out"; do
      [ -f "$RCHECK_DIR/$extra" ] && attach_file "$RCHECK_DIR/$extra" "$(basename "$extra")"
    done
  fi

  echo "🔗 Debug artifacts uploaded to: $GIST_URL"

  # Cleanup
  rm -rf "$TMP_DIR"
}

setup_git
commit_R_debug
# No repo commit/push for debug; leave upload step out intentionally
