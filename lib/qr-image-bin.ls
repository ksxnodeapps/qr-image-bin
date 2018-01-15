#! /usr/bin/env lsc

const argv = let
  const usage = '''
    Usage:
      $ $0 [options] [input] -o [output file]
      $ $0 [options] -f [output format] < [input file] > [output file]
  '''

  const example = '''
    $ $0 -o output.svg 'Hello, World!!'
    $ $0 -f svg 'Hello, World!!' > output.svg
  '''

  const options = do
    'help':
      alias: 'h'

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

const {output, format, _: input} = argv

const exit = let
  require! 'process'
  require! 'number-enum'

  const names =
    * 'success'
    * 'generic'
    * 'arguments'
    * 'input'
    * 'stdin'
    * 'qr'

  const enums = number-enum names

  return (name, message) ->
    const code = enums[name]

    if code is 0
      message and console.info "[SUCCESS] #{message}"
      process.exit 0

    message and console.error "[ERROR] [#{name.to-upper-case!}] #{message}"
    process.exit if is-finite code then code else -1

const actual-format = if format
  then format
  else if output
    then require('path').extname(output).slice(1) or 'svg'
    else exit 'arguments', '--output and --format cannot be both empty.'

const actual-output = if output
  then 'fs' |> require |> (.create-write-stream output)
  else 'process' |> require |> (.stdout)

const actual-input = switch input.length
  case 0 then 'get-stdin' |> require |> (.call!)
  case 1 then Promise.resolve input[0]
  default then exit 'inpupt', 'No input'

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
  exit 'stdin', 'Failed to read from stdin'

const handle-qr-error = (error) ->
  console.error error
  exit 'qr'

actual-input
  |> (.then main, handle-stdin-error)
  |> (.catch handle-qr-error)
