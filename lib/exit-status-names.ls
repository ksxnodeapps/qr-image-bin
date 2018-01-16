require! 'number-enum'

export const names =
  * 'success'
  * 'generic'
  * 'arguments'
  * 'input'
  * 'stdin'
  * 'qr'

export const enums = number-enum names

export const exit =
  (name, message) ->
    const code = enums[name]

    if code is 0
      message and console.info "[SUCCESS] #{message}"
      require('process').exit(0)

    message and console.error "[ERROR] [#{name.to-upper-case!}] #{message}"
    require('process').exit(if is-finite code then code else -1)
