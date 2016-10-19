# Change Log

All notable changes to this project will be documented in this file.

## [0.1.48] - 2016-10-19
### Changes
- Refactored shadows for buttons, cards, shadow shapes.  newShadowShape() has been refactored. Added system event to handle re-creating the opengl textures that make up the shadows per widget. This is run automatically on device resume.

## [0.1.47] - 2016-10-14
### Changes
- 'arcX' and 'arcY' removed from newProgressArc(..) as parameters.  Instead uses 'x' and 'y' for corrdinates.

## [0.1.46] - 2016-10-07
### Added
- 'isLocked' parameter to newTableView(..). Boolean to lock/unlock scrolling of table.
- 'newPopover()' method to create popover menu lists.  See menu.lua for an example.

## [0.1.45] - 2016-09-28
### Added
- Support for 'parent' parameter for all controls (buttons, cards, date, time, image, slider, etc).  It will insert the mui object into the 'parent' or group.  This will help adding to the current view's group for one.

## [0.1.44] - 2016-09-26
### Added
- newCard() method to create a basic card that can contain up to two colors for top and bottom area. The card can be defined in a Corona SDK group or container.
- newCardObject() method to attach MUI library objects or non-mui library objects like Corona newText(..) for example.
- removeWidgetByName() method to remove a widget by name.

## [0.1.43] - 2016-08-30
### Added
- newProgressArc() parameter "hideProgressText" a boolean.  Enables or disables the progress text (100%) used in the arc.

## [0.1.42] - 2016-08-29
### Added
- newProgressArc() method with "endpoint" and "continuous" indicators. Multiple callBacks and parameters.  See demo at http://www.anedix.com/fileshare/progress-arc.zip and API documentation.
- Bug fixes.

## [0.1.41] - 2016-08-22
### Added
- 'onComplete' parameter to newProgressCircle() method. This is a function and if set it will be called on each step interval minus 100%. On 100% the 'callBack' method if defined will be called.  See demo at http://www.anedix.com/fileshare/progress-circle.zip
- Bug fixes.

## [0.1.40] - 2016-08-22
### Added
- newProgressCircle() method to create a "determinate" fill circle. It can contain text which is either normal or embossed text.  See demo at http://www.anedix.com/fileshare/progress-circle.zip
- Bug fixes.

## [0.1.39] - 2016-08-19
### Added
- Updated README to point to *new* API Documentation at http://www.anedix.com/docs/mui/
- Updated Wiki to reflect the new documentation.
- Bug fixes.

## [0.1.39] - 2016-08-17
### Added
- "newShadowShape()" method -- create a shadow shape for rectangle (rect), rounded rectangle (rounded_rect) and circle (circle).
- shadow support to newRectButton, newRoundedRectButton and newCircleButton. See wiki https://github.com/arcadefx/material-ui/wiki/Buttons for more information.

## [0.1.38] - 2016-08-15
### Added
- "value" property to all buttons, user input and such. Use getWidgetProperty() to get the value of the widget.

## [0.1.37] - 2016-08-15
### Added
- support for display.newImage() and display.newImageRect() via wrappers. See mui-image.lua for options. For an example usage see http://www.anedix.com/fileshare/login-form.zip
- "value" to both newTextField and newTextBox properties. This allows pulling the information later in another method.  Example: local email = mui.getWidgetProperty("textfield_email", "value")

### Change
- Bug fix for newRoundedRect() method so it won't have the "white" outline on it if gradient shadows are not used.
- Bug fixes.

## [0.1.36] - 2016-08-11
### Added
- Image buttons. These can be specified using a single image or two images for on/off states.  See menu.lua and look for "Open Dialog" for an example. See project wiki too https://github.com/arcadefx/material-ui/wiki/Buttons for more information.

## [0.1.35] - 2016-08-03
### Added
- tile widget method newTileGrid() supports "getWidgetProperty and child property"

### Change
- fixed bug in slider widget

## [0.1.34] - 2016-08-03
### Added
- tile widget method newTileGrid() supports "touch points". It's enabled in the demo. See tile.lua for an example and to view demo, click on last circle button in main scene. Next version will support dynamic changing tiles.

## [0.1.33] - 2016-08-02
### Added
- tile widget method newTileGrid(). See tile.lua for an example and to view demo, click on last circle button in main scene. Next version will support dynamic changing tiles.

### Change
- Bug fixes and optimizations

## [0.1.32] - 2016-07-29
### Added
- All widgets minus date/time and onboarding have getWidgetProperty() now available.

## [0.1.31] - 2016-07-29
### Added
- getWidgetProperty() method to get a widget's property. This allows the widget text, icon and layer properties change on the fly.  For example, change the 'alpha' of a rectangle button do: mui.getWidget( 'name of widget', 'layer_1' ).alpha = 0.2 or local obj = mui.getWidget( 'name of widget', 'layer_1' ) and then obj.alpha = 0.2 .  This only works for "buttons" for now and other widgets will be available soon.

## [0.1.30] - 2016-07-27
### Added
- Options to init() call 'minPixelScaleWidthForPortrait' and 'minPixelWidthForLandscape' with init(nil, {minPixelScaleWidthForLandscape=[value],minPixelScaleWidthForLandscape=[value]} to override the base scale of MUI elements (defaults to 640 portrait and 960 landscape).

## [0.1.29] - 2016-07-26
### Added
- setDisplayToActualDimensions() method. Set the display dimensions to use display.actualContentWidth and height or display.contentWidth and height. If true it uses actual content width and height.

### Change
- Documentation updates.
- Bug fixes.

## [0.1.28] - 2016-07-25
### Added
- LineSeparator option to newSlidePanel list of menu entries.

## [0.1.27] - 2016-07-25
### Added
- newEmbossedText and newText wrappers to ease adding to navbar, toolbar, menu, etc.

### Change
- Documentation updates.
- Bug fixes.

## [0.1.26] - 2016-07-24
### Change
- Fixed label colors for active/in-active states of Slide Out menu entries.
- Bug fixes.

## [0.1.25] - 2016-07-23
### Added
- new methods newSlidePanel() and removeSlidePanel() - Create a slide out menu via hamburger icon. :)  See hamburger icons.  Will be adding more features to the Slide Panel/Menu.

## [0.1.24] - 2016-07-22
### Added
- new methods newCheckBox() and removeCheckBox()

## [0.1.23] - 2016-07-22
### Change
- Put back the toggle switch in the demo.
- Renamed all methods with prefix 'create' to 'new'. Example newDialog() instead of createDialog(). Backwards compatibility will remain for a while. Any new methods will use 'new' prefix.
- Renamed all methods with prefix 'removeWidget' to 'remove'.  Example removeDialog() instead of removeWidgetDialog(). Backwards compatibility will remain for a while. Any new methods will use 'remove' prefix.
- Renamed removeWidgets() to destroy() and includes backwards compatibility

## [0.1.22] - 2016-07-20
### Added
- Added date and time pickers. This took a while to develop and will be improved.  There will be a another date and time picker following material lite design.  In the end there will be two sets to choose from.  See main scene with circle button icons for date and time.  Use method 'pickerGetCurrentValue(<control name>)' to get current date / time.

### Change
- Reduced number of event methods for all widgets, etc.  One internal event method to handle Rectangle buttons for example.
- Bug fixes and stability improvements.

## [0.1.21] - 2016-07-12
### Change
- Fixed button action not firing when previously on TableView or ScrollView.
- Deprecated the prior event variable storage. Use the methods 'setEventParameter' and 'getEventParameter' for variables.
- Moved all remove widget calls into the appropriate mui-<name>.lua modules.

## [0.1.20] - 2016-07-12
### Added
- Added textfield animation when activating a field (fade in).

### Change
- Fixed placeholder text being empty after editing and leaving entry blank.
- Fixed scene switch issue where circle would be present on next scene.

## [0.1.19] - 2016-07-11
### Added
- Added touchpoint to toolbar.

### Change
- Fixed touchpoint scaling for smoother/crisper animation.

## [0.1.18] - 2016-07-09
### Added
- Onboarding - The onboarding/walkthrough screens for first-time users. Introduce the app and demonstrate what it does.  Go to the Demo and on the first scene tap the "?" to see it in action.
- 'createParentOnBoard', 'addChildOnBoard' and other supported onboarding methods.
- 'createCircleButton' - Create a circle button with a single character or even a word

### Change
- Applied a single theme to each scene. Instead of mashing colors. :)
- Fixed callBacks. If a callBack is omitted it won't crash.
- Bug fixes.

## [0.1.17] - 2016-07-07
### Added
- Generic/User defined widgets can be added to navigation bars. See fun.lua for an example.

### Change
- Fixed bugs.

## [0.1.16] - 2016-07-06
### Added
- Re-factored the layout of the modules. Widgets are now in separate .lua files to help with maintainability.  New files (.lua assumed): mui-button, mui-dialog, mui-navbar, mui-progressbar, mui-select, mui-slider, mui-switch, mui-tableview, mui-textinput, mui-toast, mui-toolbar
- Added mui-data.lua to be the internal global space.
- Ability to create additional modules using a simple template. mui-example.lua is the template.
- Ability to specify which modules are needed by a scene. Include a table ({}) in the mui.init() for the modules needed. If "none" are specified then all modules are loaded. See mui.lua for sample list.

### Change
- createDialog - fixed fadeOut when dialog is closed.

## [0.1.15] - 2016-07-03
### Added
- `onRowRenderDemo` - this is used to render the createTableView and add all the content on a row. 
- `attachToRow` - For createTableView it will attach a MUI widget to a row. Supports widget types: RRectButton, RectButton, IconButton, Slider, TextField. Additional widget types will be added. See onRowRenderDemo for an example.
- createTableView has option "rowAnimation = false" to turn off touchpoint and row fade.

### Change
- createSelect no longer needs onRowRender as param. It will handle rendering internally.
- improved removal of widgets

## [0.1.14] - 2016-07-02
### Added
- `createNavbar` - Create a navigation bar. Allows left and right alignment of attached widgets. See fun.lua for an example. Supports widget types: RRectButton, RectButton, IconButton, Slider, TextField. Additional widget types will be added.

### Change
- createTextField improved password field handling.
- createTextField background color can be set by fillColor. It was hard coded to be white.

## [0.1.13] - 2016-07-01
### Added
- `createSelect` - Create a select drop down list (dropdown list). Colors, dimensions and fonts can be specified.  See fun.lua for an example. Run the demo and tap "Switch Scene" button.

### Change
- createTextField supports inputType from Corona SDK. Example password fields.
- createTableView supports row colors, line separator and color and many bug fixes.

## [0.1.12] - 2016-06-30
### Added
- `createToast` - Create simple "toast" notifications on screen. Colors, dimensions and fonts can be specified.  See fun.lua for an example run the demo and tap "Switch Scene" button. Tap "Show Toast"

## [0.1.11] - 2016-06-30
### Change
- Fixed createSlider() event issue with not always firing the "ended" event.

## [0.1.10] - 2016-06-29
### Added
- `getEventParameter` - returns the event MUI widget parameters for the current widget.  Get the event target, widget name, widget value ( ex: getEventParameter(event, "muiTargetValue") ).  The value is set when creating a widget.  See menu.lua for setting the values and mui.lua callBacks for getting values (example would be actionForSwitch() method).
- All widgets support a "value" and can be accessed in the callBacks by getEventParameter() method. See mui.lua for examples.

## [0.1.9] - 2016-06-29
### Added
- "labelFont" option to createToolbar
- "labelText" option to createToolbar "list" of buttons. Allows a button to contain: Icon only, Text only or Icon with Text beneath.

### Change
- "x" option to createToolbar now works as expected. Set to 0 if wanting to use a toolbar that is 100% width of display.
- "width" option to createToolbar now works as expected. If width is omitted the toolbar width defaults to 100% or display.contentWidth
- "touchpoint" option to createToolbar now works as expected.
- "callBack" for createToolbar works as expected. It will do the animation and then call the user-defined callBack.

## [0.1.8] - 2016-06-28
### Added
- "labelFont" option to createToolbar
- "labelText" option to createToolbar "list" attribute. Allows the mix of Material icon font and text/word
font.  Label a button as "View" the button contain the text "View"

## [0.1.8] - 2016-06-27
### Added
- "easing" option to createDialog and use easing library built-in corona sdk.
- createSlider() - Create a slider for doing percentages 0..100. Calculate amount in call backs: callBackMove (call during movement) and callBack = at the end phase.  Values are in percent (0.20, 0.90 and 1 for 100%). Limitations: horizontal only and no labels (both to be addressed).  See fun.lua for two examples (2nd scene). See mui.lua and method sliderCallBackMove() to get current value of slider.

### Change
- dialogClose() has a new method closeDialog() which will phase out dialogClose() in later releases.

## [0.1.7] - 2016-06-26
### Added
- "clickAnimation" options to createRect and createRRect methods to fadeOut darken background when button is tapped. Choose darker color and when the button is tapped it will highlight in that color and fadeOut See menu.lua for an example.

### Change
- README documentation updated.

## [0.1.6] - 2016-06-25
### Added
- createDialog() - Create a dialog window with content. Supports up to two buttons (Okay, Cancel) with callbacks. See menu.lua for an example.

### Change
- Fixed some bugs and refactored parts of the code

## [0.1.5] - 2016-06-23
### Added
- getWidgetByName("name_of_widget") - Returns the array of a named widget.
- getWidgetBaseObject("name_of_widget") returns the base object of a named widget from one of the create methods. It can be inserted into another container, group, scrollview, etc.
- More documentation on methods and helper methods.

### Changed
- Re-factored the event handling. There will be another round of refactoring.
- Renamed method "removeWidgetSwitch" to "removeWidgetToggleSwitch"

## [0.1.4] - 2016-06-22
### Added
- scrollView support to widgets. Specify it in the parameters as: scrollView = scroll_view
- createToggleSwitch() - Create toggle switch. See menu.lua for an example.

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
