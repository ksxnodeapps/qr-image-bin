#! /usr/bin/env lsc
const {enums, exit} = require './exit-status-names'

const argv = let
  const usage = """
    Usage:
      $ $0 [options] [input] -o [output file]
      $ $0 [options] -f [output format] < [input file] > [output file]

    Exit Status Codes:
      #{enums
        |> Object.entries
        |> (.map ([name, code]) -> "#{code} → #{name}")
        |> (.join '\n  ')
      }
  """

  const example = '''
    $ $0 -o output.svg 'Hello, World!!'
    $ $0 -f svg 'Hello, World!!' > output.svg
  '''

  const options = do
    'help':
      alias: 'h'

    'input':
      alias: 'i'
      describe: 'Input filename (optional)'
      type: 'string'

    'output':
      alias: 'o'
      describe: 'Output filename, default to stdout if not provided'
      type: 'string'

    'format':
      alias: 'f'
      describe: '''
        Output format, optional if --output is determined, otherwise mandatory
        Possible values: svg, png, pdf, eps
      '''
      type: 'string'

    'error-correction-level':
      alias:
        * 'ec-level'
        * 'eclv'
        * 'e'
      describe: 'One of L, M, Q, H'
      type: 'string'
      default: 'M'

    'size':
      describe: 'Image Size (when --format=png or --format=svg)'
      type: 'number'

    'margin':
      describe: 'White space around QR image in modules'
      type: 'number'

    'parse-url':
      describe: 'Try to optimize QR-code for URLs'
      type: 'boolean'
      default: false

  return 'yargs'
    |> require
    |> (.usage usage)
    |> (.example example)
    |> (.env 'QR_IMAGE')
    |> (.options options)
    |> (.help!)
    |> (.argv)

const {input, output, format, _: rest} = argv

const actual-format = if format
  then format
  else if output
    then require('path').extname(output).slice(1) or 'svg'
    else exit 'arguments', '--output and --format cannot be both empty.'

const actual-output = if output
  then 'fs' |> require |> (.create-write-stream output)
  else 'process' |> require |> (.stdout)

const actual-input = if input
  then let
    if rest.length
      then exit 'arguments', '--input and arguments cannot be both present.'
      else require('fs-extra').read-file(input, 'utf-8')
  else let
    switch rest.length
      case 0 then 'get-stdin' |> require |> (.call!)
      case 1 then Promise.resolve rest[0]
      default then exit 'arguments', 'Too many arguments.'

const options = let
  const base = do
    ec_level: argv.error-correction-level or undefined
    type: actual-format
    size: argv.size or undefined
    margin: argv.margin or undefined
    parse_url: argv.parse-url

  return base
    |> Object.entries
    |> (.filter (.1))
    |> (.reduce (obj, [key, val]) -> {...obj, (key): val}, {})

const main = (text) ->
  require('qr-image').image(text, options).pipe(actual-output)

const handle-stdin-error = (error) ->
  console.error error
  exit 'stdin', 'Failed to read from stdin.'

const handle-qr-error = (error) ->
  console.error error
  exit 'qr'

actual-input
  |> (.then main, handle-stdin-error)
  |> (.catch handle-qr-error)
