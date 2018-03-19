fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios tests
```
fastlane ios tests
```
Run the Xcode tests for the project.
### ios coverage
```
fastlane ios coverage
```
Gather code coverage stats for the project.

Project must be built first.
### ios lint
```
fastlane ios lint
```
Run pod lib lint on the project, using 3Squared's spec repo.
### ios release
```
fastlane ios release
```
Push the project to the 3Squared spec repo.

This command is only valid on a clean repo where HEAD is a tagged commit on master.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
