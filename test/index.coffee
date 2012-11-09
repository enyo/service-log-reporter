
sinon = require "sinon"
fs = require "fs"

reporter = new(require "service-reporter")

LogReporter = require "../index"


describe "Log reporter", ->

  before ->
    sinon.stub console, "log"
  after ->
    console.log.restore()

  beforeEach ->
    sinon.stub reporter
  afterEach ->
    reporter[prop]?.restore?() for own prop of reporter


  it "should have default options set", ->
    localReporter = new -> @test = 1
    logReporter = new LogReporter(localReporter, "some file uri")
    logReporter.options.should.eql
      poolTimeLimit: 5
      poolSizeLimit: 500


  it "should properly set the options", ->
    localReporter = new -> @test = 1
    logReporter = new LogReporter(localReporter, "some file uri",
      poolTimeLimit: 99
      poolSizeLimit: 999
    )

    localReporter.should.equal logReporter.reporter

    logReporter.fileUri.should.eql "some file uri"

    logReporter.options.should.eql
      poolTimeLimit: 99
      poolSizeLimit: 999


  describe "observing the file", ->
    tmpFile = "#{__dirname}/testfile"
    fs.writeFileSync tmpFile, "", "utf-8"

    afterEach ->
      fs.unlink tmpFile

    it "should properly bundle and notify on file change", (done) ->
      logReporter = new LogReporter reporter, tmpFile, poolTimeLimit: 0.05
      logReporter.start()
      reporter.submit.callCount.should.eql 0
      fs.writeFileSync tmpFile, "abcdefslkdjfsldkfj", "utf-8"
      setTimeout ->
        reporter.submit.callCount.should.eql 0
        fs.writeFileSync tmpFile, "abcdefslkdjfsldkfj22", "utf-8"
      , 10
      setTimeout ->
        reporter.submit.callCount.should.eql 1
        reporter.submit.args[0][1].toString("utf8").should.eql "abcdefslkdjfsldkfj" + "abcdefslkdjfsldkfj22"
        logReporter.stop()
        done()
      , 100

    it "should send buffer when exceeding poolSizeLimit", (done) ->
      logReporter = new LogReporter reporter, tmpFile, { poolTimeLimit: 500, poolSizeLimit: 0.05 }
      logReporter.start()

      fs.writeFileSync tmpFile, "abcdef\nslkdjfsldkfj", "utf-8"
      setTimeout ->
        reporter.submit.callCount.should.eql 0
        fs.writeFileSync tmpFile, "ääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääää", "utf-8"
      , 10
      setTimeout ->
        reporter.submit.callCount.should.eql 1
        reporter.submit.args[0][1].toString("utf8").should.eql "abcdef\nslkdjfsldkfj" + "ääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääääää"
        logReporter.stop()
        done()
      , 20

    # it "should send the data only when timeLimit is reached", (done) ->
    #   logReporter = new LogReporter null, tmpFile, poolTimeLimit: 0.5
    #   logReporter.start()
    #   logReporter.submitPool.callCount.should.eql 0
    #   fs.writeFileSync tmpFile, "abcdef\nslkdjfsldkfj", "utf-8"
    #   setTimeout ->
    #     logReporter.submitPool.callCount.should.eql 0
    #     fs.writeFileSync tmpFile, "abcdef\nslkdjfsldkfj22", "utf-8"
    #   , 10
    #   setTimeout ->
    #     logReporter.submitPool.callCount.should.eql 1
    #     done()
    #   , 100

    # it "should properly bundle and notify on file change", (done) ->
    #   logReporter = new LogReporter null, tmpFile
    #   logReporter.start()
    #   logReporter.submitPool.callCount.should.eql 0
    #   fs.writeFileSync tmpFile, "abcdef\nslkdjfsldkfj", "utf-8"
    #   setTimeout ->
    #     fs.writeFileSync tmpFile, "abcdef\nslkdjfsldkfj22", "utf-8"
    #   , 10
    #   setTimeout ->
    #     logReporter.submitPool.callCount.should.eql 1
    #   , 100

  # describe "working with reporter", ->
  #   

  #   it "should use the reporter on file change", ->
  #     true.should.equal true
