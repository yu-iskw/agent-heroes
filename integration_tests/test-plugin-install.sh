#!/usr/bin/env bash

# Copyright 2026 yu-iskw
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Test plugin installation via Claude CLI (install + list)
set -euo pipefail

# Check if Claude CLI is available
if ! command -v claude >/dev/null 2>&1; then
	echo "WARNING: Claude CLI not found. Skipping plugin install tests."
	echo "Install with: npm install -g @anthropic-ai/claude-code"
	exit 0
fi

# Default plugin directory (resolve to absolute for install)
PLUGIN_DIR="${1:-.}"
if [[ -d ${PLUGIN_DIR} ]]; then
	PLUGIN_DIR="$(cd "${PLUGIN_DIR}" && pwd)"
fi
MANIFEST_PATH="${PLUGIN_DIR}/.claude-plugin/plugin.json"

if [[ ! -f ${MANIFEST_PATH} ]]; then
	echo "ERROR: Manifest not found: ${MANIFEST_PATH}"
	exit 1
fi

# Get plugin name from manifest
if command -v jq >/dev/null 2>&1; then
	plugin_name="$(jq -r '.name' "${MANIFEST_PATH}")"
elif command -v node >/dev/null 2>&1; then
	plugin_name="$(node -p "require('${MANIFEST_PATH}').name")"
else
	echo "ERROR: Cannot read manifest. Neither jq nor node is available."
	exit 1
fi

if [[ -z ${plugin_name} ]] || [[ ${plugin_name} == "null" ]]; then
	echo "ERROR: Unable to resolve plugin name from ${MANIFEST_PATH}"
	exit 1
fi

# Skip if install subcommand is not available (e.g. older CLI)
if ! claude plugin install --help >/dev/null 2>&1; then
	echo "Skipping plugin install test: 'claude plugin install' not available"
	exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "Testing plugin installation for: ${plugin_name}"

# Install from path (project scope so .claude/settings.json is used).
# Some CLIs only support marketplace install; if so, skip without failing.
echo "Running: claude plugin install --scope project ${PLUGIN_DIR}"
install_out="${tmp_dir}/install-out.txt"
install_err="${tmp_dir}/install-err.txt"
if ! claude plugin install --scope project "${PLUGIN_DIR}" >"${install_out}" 2>"${install_err}"; then
	if grep -q "not found in any configured marketplace" "${install_err}" 2>/dev/null || grep -q "not found in any configured marketplace" "${install_out}" 2>/dev/null; then
		echo "Skipping plugin install test: this CLI only supports marketplace install (path install not available)"
		exit 0
	fi
	echo "ERROR: Plugin installation failed: 'claude plugin install --scope project ${PLUGIN_DIR}' exited non-zero"
	cat "${install_out}" "${install_err}" 2>/dev/null
	exit 1
fi
echo "Plugin installed successfully"

# Assert plugin appears in list
if ! claude plugin list >"${tmp_dir}/plugin-list.txt" 2>&1; then
	echo "ERROR: Failed to run 'claude plugin list' after install"
	cat "${tmp_dir}/plugin-list.txt"
	exit 1
fi

if ! grep -F "${plugin_name}" "${tmp_dir}/plugin-list.txt" >/dev/null; then
	echo "ERROR: Installed plugin '${plugin_name}' was not found in 'claude plugin list' output"
	cat "${tmp_dir}/plugin-list.txt"
	exit 1
fi
echo "Plugin list check passed"

# Optional cleanup: uninstall so repeated local runs start clean
if claude plugin uninstall --help >/dev/null 2>&1; then
	if claude plugin uninstall --scope project "${plugin_name}" >/dev/null 2>&1; then
		echo "Uninstalled plugin for cleanup"
	else
		echo "Note: Uninstall skipped or failed (non-fatal)"
	fi
fi

echo "Plugin install test passed for: ${plugin_name}"
