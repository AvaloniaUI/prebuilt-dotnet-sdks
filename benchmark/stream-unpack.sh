#!/usr/bin/env bash
#
# Streaming unpack of a prebuilt .NET SDK release straight from GitHub.
#
# Each release archive is uploaded as <2 GiB numbered parts. Rather than
# downloading the parts to disk and then extracting (double I/O), this streams
# every part sequentially from curl directly into `tar -xz`, so the bytes are
# decompressed as they arrive and nothing intermediate ever touches the disk.
#
# Usage: stream-unpack.sh <rid> <version> [dest]
#   rid      e.g. linux-x64 / osx-arm64 / win-x64
#   version  e.g. 10.0.101 (must have a published release)
#   dest     install dir (default: ./dotnet)
#
# Env:
#   REPO     owner/name (default: AvaloniaUI/prebuilt-dotnet-sdks)
#   GH_TOKEN token for `gh` (provided automatically in GitHub Actions)
#
# Output: key=value lines (rid, parts, bytes, elapsed_seconds, throughput_mib_s).

set -euo pipefail

REPO="${REPO:-AvaloniaUI/prebuilt-dotnet-sdks}"
RID="${1:?usage: stream-unpack.sh <rid> <version> [dest]}"
VERSION="${2:?usage: stream-unpack.sh <rid> <version> [dest]}"
DEST="${3:-$PWD/dotnet}"

prefix="dotnet-${RID}-${VERSION}.tar.gz.part"
base="https://github.com/${REPO}/releases/download/${VERSION}"

# Enumerate and order the parts for this RID straight from the release metadata.
parts="$(gh release view "$VERSION" -R "$REPO" --json assets \
  --jq ".assets[].name | select(startswith(\"$prefix\"))" | sort)"
total_bytes="$(gh release view "$VERSION" -R "$REPO" --json assets \
  --jq "[.assets[] | select(.name | startswith(\"$prefix\")) | .size] | add")"

if [ -z "$parts" ]; then
  echo "No parts found for '$prefix' in $REPO release $VERSION" >&2
  exit 1
fi

n="$(printf '%s\n' "$parts" | wc -l | tr -d ' ')"
echo "Streaming $n part(s) (${total_bytes} bytes) for $RID -> $DEST" >&2

rm -rf "$DEST"
mkdir -p "$DEST"

# Time only the network+decompress pipeline. SECONDS is portable across the
# bash versions on every runner (incl. macOS's bash 3.2).
SECONDS=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  curl -fsSL --retry 3 --retry-delay 2 "${base}/${p}"
done <<< "$parts" | tar -xz -C "$DEST"
elapsed=$SECONDS

mbps="$(awk -v b="$total_bytes" -v s="$elapsed" \
  'BEGIN { if (s <= 0) s = 1; printf "%.1f", (b / 1048576) / s }')"

echo "rid=$RID"
echo "parts=$n"
echo "bytes=$total_bytes"
echo "elapsed_seconds=$elapsed"
echo "throughput_mib_s=$mbps"
