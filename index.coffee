# Copyright(c) 2012 Matias Meno <m@tias.me>

{Tail} = require "tail"

class LogReporter

  defaultOptions:
    # How long the reporter should wait and merge content before actually
    # submitting it
    poolTimeLimit: 5 # s

    # If the size of the pool exceeds this limit, it gets submitted before the
    # timeout
    poolSizeLimit: 500 # kB



  constructor: (@reporter, @fileUri, @options = { }) ->
    for name, value of @defaultOptions
      @options[name] = value unless @options[name]?

    @startReporting()



  startReporting: ->

    tail = new Tail @fileUri

    tail.on "line", (data) ->
      console.log data


module.exports = LogReporter