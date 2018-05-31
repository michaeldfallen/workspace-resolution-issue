#!/usr/bin/env bash

versionFor() {
  path="${1}"
  humanReadable="$(echo "$path" | sed "s/\.\///g" | sed "s/\// > /g")"
  packageJson="$path/package.json"
  if [[ -f "$packageJson" ]]; then
    version="$(cat "$packageJson" | grep "version\":" | sed "s/ *\"version\": \"//" | sed "s/\",$//")"
    echo "$humanReadable $version"
  fi
}

findModules() {
  path="$1"
  shift
  for module in "$@"; do
    find . -path "./${path}/*" -name "$module" -type d
  done
}

listModulesIn() {
  path="$1"
  modules="$(findModules "$path" "mobx" "mobx-react" | sort)"
  echo "$path: "
  for module in $modules; do
    versionFor "$module"
  done
}

listModulesIn node_modules
echo ""
listModulesIn workspace-a
echo ""
listModulesIn workspace-b
