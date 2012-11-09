# Copyright(c) 2012 Matias Meno <m@tias.me>

sys = require "sys"

{spawn} = require "child_process"
{EventEmitter} = require "events"


class Tail extends EventEmitter

  constructor: (filename) ->
    @tail = spawn "tail", [ "-f", filename ]

    @tail.stdout.on "data", (data) =>
      @emit "data", data

    @tail.stderr.on "data", (data) =>
      @emit "error", data.toString "utf8"

  stop: ->
    @tail.kill()

module.exports = Tail