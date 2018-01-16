#! /usr/bin/env bash

function build () (
  name=$1

  lsc -c -m linked lib/$name.ls || exit $?

  (
    uglifyjs \
      --output \
        lib/$name.min.js \
      --compress \
      --source-map \
        "filename='lib/$name.min.js.map',content='lib/$name.js.map'" \
      -- \
        lib/$name.js
  ) || exit $?

  (
    echo
    echo
    echo '//# sourceMappingURL=$name.min.js.map'
  ) >> lib/$name.min.js
)

list=(qr-image-bin)
for name in $list
do
  {
    build $name
    ((stcode+=$?))
  } &
done
wait
exit $stcode
