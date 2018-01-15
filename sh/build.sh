#! /usr/bin/env bash
lsc -o bin/ -m linked bin/qr-image-bin.ls || exit $?
chmod +x bin/*.js || exit $?
