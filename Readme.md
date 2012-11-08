# Service log reporter

![Build status](https://api.travis-ci.org/enyo/service-log-reporter.png)

Using the `service-reporter`, this lib reports logs to a `servicer-report-manager`.



## API

Create a `LogReporter` and pass it an instance of a reporter.

```coffee
reporter = new ServiceReporter config
logReporter = new ServiceLogReporter reporter
```