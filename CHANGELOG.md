# Change Log

All notable changes to this project will be documented in this file.

## [0.1.4] - 2016-06-22
### Added
- scrollView support to widgets. Specify it in the parameters as: scrollView = scroll_view
- createSwitch() - Create toggle switch. See menu.lua for an example.

### Changed
- Fixed issue where scrollView widgets (like buttons) would not work when added to scrollView.
- Fixed bug when releasing memory for createProgressBar when not using a label.

## [0.1.3] - 2016-06-21
### Added
- createProgressBar() - An animated progress bar using "determinate" from Material Design. Please see menu.lua for an example. Includes linear call back (callBack) and later will support a repeating call back (repeatCallBack). It has a number of options.

## [0.1.2] - 2016-06-18
### Changed
- Fixed method createRRectButton()
- Renamed method createRRectButton() parameter "gradientColor1 to "gradientShadowColor1"
- Renamed method createRRectButton() parameter "gradientColor2 to "gradientShadowColor2"
- Fixed parameter "radius" for method createRRectButton()

### Added
- Added parameters "strokeWidth" and "strokeColor" to method createRRectButton().
- This CHANGELOG file

## [0.1.1] - 2016-06-01
### Added
- This project to GitHub
