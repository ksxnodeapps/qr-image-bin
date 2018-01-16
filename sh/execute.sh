#! /usr/bin/env bash

{
  bash ./sh/build.sh
} && {
  node -r source-map-support/register lib/qr-image-bin.js $@
}
