# Copyright(c) 2012 Matias Meno <m@tias.me>

Tail = require "./tail"
require "buffertools"


class LogReporter

  defaultOptions:
    # How long the reporter should wait and merge content before actually
    # submitting it
    poolTimeLimit: 5 # s

    # If the size of the pool exceeds this limit, it gets submitted before the
    # timeout
    poolSizeLimit: 500 # kB



  constructor: (@reporter, @fileUri, @options = { }) ->
    @poolSize = 0
    for name, value of @defaultOptions
      @options[name] = value unless @options[name]?


  start: ->
    console.log "Starting to report on file #{@fileUri}"
    @pool = [ ]
    @poolSize = 0
    @timeoutId = undefined

    @tail = new Tail @fileUri

    @tail.on "data", (data) =>
      @newChunkReceived data

    @tail.on "error", (err) =>
      @reporter.error err.message, file: @fileUri


  stop: ->
    @tail.stop()

  newChunkReceived: (chunk) ->
    unless @timeoutId?
      @timeoutId = setTimeout (=> @submitPool()), @options.poolTimeLimit * 1000

    @poolSize += chunk.length
    @pool.push chunk

    if @poolSize >= (@options.poolSizeLimit * 1000)
      @submitPool()


  submitPool: ->
    console.log "Submitting log pool (#{@fileUri})."

    poolToSubmit = Buffer.concat @pool
    @pool = [ ]

    @timeoutId = undefined
    @reporter.submit "log", poolToSubmit



module.exports = LogReporter