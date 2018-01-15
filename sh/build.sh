#! /usr/bin/env bash
lsc -c -m linked lib/qr-image-bin.ls || exit $?

(
  uglifyjs \
    --output \
      lib/qr-image-bin.min.js \
    --compress \
    --source-map \
      "filename='lib/qr-image-bin.min.js.map',content='lib/qr-image-bin.js.map'" \
    -- \
      lib/qr-image-bin.js
) || exit $?

(
  echo
  echo
  echo '//# sourceMappingURL=qr-image-bin.min.js.map'
) >> lib/qr-image-bin.min.js
