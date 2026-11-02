#!/usr/bin/env bash
# Compares the public API of each package with its latest release on pub.dev
# and fails when something an app may use was removed or changed, unless the
# version in pubspec.yaml is a new major. Renames go through @Deprecated.
#
#   tool/api_check.sh                 every package
#   tool/api_check.sh brix brix_ui    only these
set -euo pipefail

APITOOL_VERSION="0.23.2"
root="$(cd "$(dirname "$0")/.." && pwd)"
packages=("$@")
if [ ${#packages[@]} -eq 0 ]; then
  packages=(brix_cli brix_ui brix_getx brix_network brix_storage brix)
fi

if ! dart pub global list | grep -q "^dart_apitool $APITOOL_VERSION$"; then
  dart pub global activate dart_apitool "$APITOOL_VERSION" > /dev/null
fi

failed=()
for package in "${packages[@]}"; do
  released="$(curl -fsS "https://pub.dev/api/packages/$package" \
    | sed -E 's/.*"latest":\{"version":"([^"]+)".*/\1/')"
  echo "::group::$package: $released on pub.dev → this repo"
  if dart pub global run dart_apitool:main diff \
    --old "pub://$package/$released" \
    --new "$root/packages/$package" \
    --version-check-mode=onlyBreakingChanges; then
    echo "::endgroup::"
  else
    echo "::endgroup::"
    failed+=("$package")
  fi
done

if [ ${#failed[@]} -gt 0 ]; then
  echo "Public API break in: ${failed[*]}"
  echo "Keep the old name with @Deprecated, or give a new option a default."
  exit 1
fi
echo "No public API breaks."
