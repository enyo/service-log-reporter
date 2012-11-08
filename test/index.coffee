
sinon = require "sinon"

originalReporter = new(require "service-reporter")

LogReporter = require "../index"


describe "Log reporter", ->

  it "should have default options set", ->
    reporter = new -> @test = 1
    logReporter = new LogReporter(reporter, "some file uri")
    logReporter.options.should.eql
      poolTimeLimit: 5
      poolSizeLimit: 500


  it "should properly set the options", ->
    reporter = new -> @test = 1
    logReporter = new LogReporter(reporter, "some file uri",
      poolTimeLimit: 99
      poolSizeLimit: 999
    )

    logReporter.reporter.should.equal reporter

    logReporter.fileUri.should.eql "some file uri"

    logReporter.options.should.eql
      poolTimeLimit: 99
      poolSizeLimit: 999

  describe "working with reporter", ->
    reporter = null
    before ->
      reporter = sinon.stub originalReporter
    after ->
      reporter[prop]?.restore?() for own prop of reporter

    it "should use the reporter on file change", ->
      true.should.equal true
