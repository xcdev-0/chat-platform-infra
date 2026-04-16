#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <values-file> <image-repository> <image-tag>" >&2
  exit 1
fi

VALUES_FILE="$1"
IMAGE_REPOSITORY="$2"
IMAGE_TAG="$3"
TMP_FILE="$(mktemp)"

awk -v repo="$IMAGE_REPOSITORY" -v tag="$IMAGE_TAG" '
BEGIN {
  in_image = 0
}
{
  if ($0 ~ /^image:[[:space:]]*$/) {
    in_image = 1
    print
    next
  }

  if (in_image && $0 ~ /^[^[:space:]]/) {
    in_image = 0
  }

  if (in_image && $0 ~ /^  repository:[[:space:]]*/) {
    print "  repository: " repo
    next
  }

  if (in_image && $0 ~ /^  tag:[[:space:]]*/) {
    print "  tag: " tag
    next
  }

  print
}
' "$VALUES_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$VALUES_FILE"
