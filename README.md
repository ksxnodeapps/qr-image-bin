# QR Image Bin

Command-line for [qr-image](https://goo.gl/56XvdK)

## Requirements

* Node.js ≥ 8.9.0

## Installation

### Using NPM

```sh
npm install --global qr-image-bin
```

### Using Yarn

```sh
yarn global add qr-image-bin
```

## Usage

```
Usage:
  $ qr-image-bin.js [options] [input] -o [output file]
  $ qr-image-bin.js [options] -f [output format] < [input file] > [output file]

Options:
  --version                                 Show version number        [boolean]
  --output, -o                              Output filename, default to stdout
                                            if not provided             [string]
  --format, -f                              Output format, optional if --output
                                            is determined, otherwise mandatory
                                            Possible values: svg, png, pdf, eps
                                                                        [string]
  --error-correction-level, --ec-level,     One of L, M, Q, H
  --eclv, -e                                             [string] [default: "M"]
  --size                                    Image Size (when --format=png or
                                            --format=svg)               [number]
  --margin                                  White space around QR image in
                                            modules                     [number]
  --parse-url                               Try to optimize QR-code for URLs
                                                      [boolean] [default: false]
  --help                                    Show help                  [boolean]

Examples:
  $ qr-image-bin.js -o output.svg 'Hello, World!!'
  $ qr-image-bin.js -f svg 'Hello, World!!' > output.svg
```
