# Change Log

All notable changes to this project will be documented in this file.

## [0.3.3] - 2018-01-11
### Changes
- Added SVG graphic support module. It's being integrated into the widgets. This will allow the developer
to support SVG images for Icons. Material font codepoints will remain as-is and SVG will be an option per widget. Currently only newIconButton() uses it.
- Fixed newTextBox() issue when less text is put into the box when prior text existed. It would push the text down on the screen.
- Turn on Svg support, activate the 'nanosvg' plugin from CoronaLabs Marketplace. Supply the flag 'useSvg' set to true in the initialization call. Example: mui.init(nil, {parent=self.view, useSvg = true})

## [0.3.2] - 2017-11-13
### Changes
- Added 'ignoreTap' to all buttons to 'ignore' tap event.
- Improved support for inset settings for display (iPhone X)
- Detecting if Phone or Tablet using mui.isPhone() returns boolean true/false.
- Fixed Cards

## [0.3.1] - 2017-10-13
### Changes
- Added insertRowsTableView() appends rows to an existing table view. Arguments are name of tableView and a list of entries. See documentation for newTableView with Helpers.
- Added removeAllRowsFromTableView() remove all rows from an existing table view.  Argument is the name of the tableView. See documentation for newTableView with Helpers.
- Created a Pagination demo of sqlite database entries using the above methods. See http://www.anedix.com/fileshare/table-paginator.zip and look at file table-paginator.lua.  Note it includes a small database abstraction layer I created. Feel free to use it for other things and it will be improved with caching, etc.
- Updated demo for showing how to attach things to a tableView too. See http://www.anedix.com/fileshare/checklist.zip

## [0.3.0] - 2017-10-05
### Changes
- WARNING: getScaleVal() has been depreciated. Scaling is now fixed and works with config.lua.  See config.lua for more information in demo.  Any existing code based on it needs updated to adjust sizes and placement (x, y). Sorry, it was for the better.
- With scaling fixed, the material design font letters show up and such on various devices now. There was an issue where these did not show correctly.
- Requires Corona SDK build 2017.3135.
- Supports safe zone insets and iPhone X display area.
- Safe area/zone implemented.
- mui-data must be included at the top of your scene file as it needs it for safeArea values. See menu.lua for example.

	-- mui, place below mui require
	local muiData = require( "materialui.mui-data" )
- For iOS devices, please add to you "plist": UILaunchStoryboardName = "LaunchScreen",
- For iOS devices, copy the folder "LaunchScreen.storyboardc" to your project ONLY if it doesn't already exist. If it exist skip this step!
- To place a background in the safe zone be sure to look at the top of the menu.lua file for an example.
- See menu.lua and fun.lua for examples using the new methods.
- Fixed newSelect() to render correctly.
- Fixed some demo code.
- All instances of getScaleVal() have been removed.

## [0.1.99] - 2017-08-02
### Changes
- newTableView() - Added parameter "valign" to attachToRow(). Allows you to vertically align the object.
- newTableView() - Added parameter "valign" to 'list' and 'columns' which allows you to vertically align the text.
- newTableView() - Documentation updated for the "valign" addition.
- newTableView() - Added parameter "align" to documentation.

## [0.1.98] - 2017-07-21
### Changes
- newTableView() - Added internal method attachBackgroundToRow(..). if the newTableView() options in attribute list now supports 'backgroundImage' which you specify the image to use for the row's background.  Each row has to be set and if not it will use the normal color scheme.

### Fixes
- Adding controls to left / right align on a row didn't work correctly.
- Added return "true" to avoid propagation to other controls for buttons. Added a special case for "newTableView()" which avoids the row's callback being used if a button event occurs on top.

## [0.1.97] - 2017-06-12
### Fixes
- newSelect() - Fixed issue where value was being used in the 'selected' text instead of the text for the button.  Now after choosing a drop down item the 'text' for the item is shown.

## [0.1.96] - 2017-05-05
### Fixes
- newTableView() - Tapping repeatly did not register an event. This is fixed now. Which was an issue on all devices and simulator.

## [0.1.93] - 2017-04-23
### Fixes
- newSlidePanel() - Slide panel would not always slide out fully. This is fixed now.

## [0.1.92] - 2017-04-13
### Changes
- newSelect() displays correctly now using a scrollView. It resides within the scrollView. The drop down shows below or just above the select input area depending on visible scroll area.
- newSlidePanel() demo updated on menu.lua.  It demos a custom callback to avoid the default animation when scene switching. It demos using the animated switching.

## [0.1.90] - 2017-04-12
### Changes
- Plugin - The library will soon be a plug-in on Corona Marketplace. Free of course! Stay tuned for the release. The documenation has been updated to reflect this change.  The GitHub repo will continue to work as it did before, so either grab it by Plugin or Github. The GitHub will contain latest changes and once approved they will be migrated into the Plugin.
- Copying the font files to your project's main directory is no longer required. It now uses the "icon-font" directory.
- mui.init(module_list, options) has been changed. You No longer need to pre-append "materialui." to each module. Just name them like "mui-button" for example.

## [0.1.88] - 2017-04-04
### Changes
- Event handler added to method newRadioButton() "label" text.  This allows the user to touch/click on the radio button or the label text.

## [0.1.87] - 2017-03-30
### Changes
- Event handlers updated with "return true" where needed. Prevent event propagation to other controls.
- Added global debug variable "_mui_debug" and if true will use 'mui.debug()' else do not output debugging information.  Just defined it to true/false in your main.lua at top. It defaults to "false" or debugging off.
- Added method mui.debug(<string>) to output debug information. See _mui_debug above for more information.

### Fixes
- onboard.lua example arrow button was non-responsive due to missing callback.

## [0.1.86] - 2017-03-18
### Changes
- newTextBox() options for "doneButton", options for overlay.  Due to mobile devices not having an easy way to edit textareas an overlay w/ "done" button (on right of textbox) has been added.  The overlay and button is "not" used on non-mobile devices.  Please see documentation and fun.lua for a complete example.  This makes editing in a textbox easier on mobile.

## [0.1.84] - 2017-03-17
### Changes
- setSelectorList() method added to set the named drop-down selector with the contents of a list. This makes it easier to dynamically update the list after declaration.  See commented out example in fun.lua.
- setSelectorValue() method added to set the named drop-down selector's current text and value content.

### Fixes
- Fixed newTextBox() contents overflowing out of defined area. The text is now in a container and the text is always around to the top (shows first line of content on down).

## [0.1.80] - 2017-03-16
### Changes
- getOrientation() gets the current orientation as locked. mui only supports Portrait or Landscape. It cannot be both at this time.
- setSceneToSwitchToAfterDestroy([name]) to override what scene to go to after mui.destroy() executes.
- 'sceneTransitionAnimation' parameter for scene transitions. Is boolean and if "true" (default) it will animate before going to next scene.  If "false" it will not animate and go to next scene immediately.  See menu.lua for an example.
- muiData.parent variable is replaced with mui.getParent() method. muiData.parent is still supported but will be deprecated in the future.

### Fixes
- Fixed getScaleVal() and orientation issues. This was causing issues on device and in emulator. Issues like crashing since the device could be rotated, flipped etc messing up the calculations. Again use a locked position for now in "mui" and go with Portrait or Landscape. These in any "portait" or "landscape" orientation, but not both "portrait" and "landscape"
- Using a new animation for switching between scenes. It's smoother.
- Re-did the order of mui.destroy() and now it will cancel all "transitions" before proceeding to destroy.


## [0.1.77] - 2017-02-23
### Changes
- newSlidePanel() supports swipe gestures to open and close the menu.
- newSlidePanel() 'isVisible' added to options of slide panel. If present, hide the slide panel and reveal once a button is touched or swipe gestures. See main.lua for demo.

## [0.1.76] - 2017-02-20
### Changes
- newNavbar() added method support for getWidgetBaseObject() and 'parent' object support in options for newNavbar().

## [0.1.75] - 2017-02-20
### Changes
- Fixed issue with newSlidePanel() labelColor, labelColorOff and iconColor and iconColorOff not setting correctly when selected and de-selected.

## [0.1.74] - 2017-02-17
### Changes
- Fixed issue with newSlidePanel() not hiding and showing correctly. Custom methods to hide/show the menu are optional.

## [0.1.73] - 2017-02-17
### Changes
- newRoundedRectButton() and newRectButton() can now show a icon from material font or an image (jpg/png) to the left of the button text. See docs, example and list of options includes: iconText, iconFont, iconFontColor, iconImage.
- newTableView() - bug fixes and example updated to show multi-columns. Example of highlighting a row is also been given but is commented out.

## [0.1.72] - 2017-02-05
### Changes
- Fixed bug in newTileGrid() when using composer to switch scenes and not using the built-in library method actionSwitchScene().

## [0.1.71] - 2017-02-03
### Changes
- 'newTableView()' added support for multiple columns. See menu.lua and options for a row called "columns" which defines the columns (text, value, align).  Each row supports: text, value, font, fontSize, fillColor, isCategory.
- 'newTableView()' see 'columnOptions' in options to set the width per column.
- 'getTableViewProperty()' added 'list' to be able to access the list table (list = {}) for the rows or rows and columns.
- 'onRowTouchDemo()' added example of pulling column data.
- 'onRowTouchDemo()' added 'hidden' example of changing a rows color when clicked.
- bugs fixes

## [0.1.70] - 2017-02-02
### Changes
- 'newSlidePanel()' events fixed. Now the menu stays resident and hides/shows instead of destroying the menu. Menu is destroyed when switching scenes or when removeSlidePanel("name") is called.  It will also highlight the current selected item.

## [0.1.69] - 2017-02-01
### Changes
- removed dependency of utf8 plugin. This may be added back in future versions.  For now it simplifies the installation and not requiring Internet access to build in simulator.  A pure lua utf8 method was put in place to handle the requirements.  Feel free to use the utf8 plugin as the method here will not conflict with it. uft8 plugin is awesome for internationalization.
- "newSlidePanel" now will highlight the last menu item selected. This requires the methods hideSlidePanel() and showSlidePanel(). If not it will 'destroy' the menu after an item is selected. Just use these in your callbacks.
- Fixed some bugs.

## [0.1.68] - 2017-01-28
### Added
- "mui.materialFont" variable. The font is mapped to use "MaterialIcons-Regular.ttf" or "MaterialIcons-Regular.otf" font icons.  The font is automatically assigned to the variable and is  determined by mobile OS compability.  This is optional usage, but can help so there are no 'hard coded' fonts to replace.

## [0.1.67] - 2017-01-27
### Changes
- fixed issue with attachToNavBar() when attaching a custom widget and supplying a destroy method was crashing.

## [0.1.66] - 2017-01-27
### Added
- UTF-8 string plugin from Corona Labs is now "required" and must be installed to use this version.  See updated README or online documentation for installation.  This was done to support UTF-8 in material icon font and for future UTF-8 support.  
- MaterialIcons-Regular.otf font file to support older devices. This is partially implemented but required now for installation.  Be sure to copy it to the same folder where "MaterialIcons-Regular.ttf" resides.
- 'isFontIcon' a boolean for newIconButton, newCircleButton, newToolbarButton, basically where there is an Icon this is needed.  Backwards compatibility included.  Use "isFontIcon" in the options for the methods and if true it will use the codepoint for the Material icon font.

### Changes
- fixed issues with fonts and Material design font.
- many bug fixes and now supports Android KitKat 4.4.4 - Nougat 7.x. Android Icecream and Jelly Bean should work.  However, anything older than Android 4.x is "not" supported at this time.

## [0.1.65] - 2017-01-25
### Changes
- fixed fontSize issue with newIconButton() and newCircleButton and newToolbarButton().
- fixed newTextBox() on focus issue, it now uses the full width x height of textbox fake area.

## [0.1.64] - 2017-01-25
### Added
- 'rowBackgroundColor' parameter to newTableView() and newSelect().  If no background color is specified per row use this color for background.

## [0.1.63] - 2017-01-24
### Added
- 'trimFakeTextAt' parameter to newTextField() and newTextBox() options. Trim the text displayed when not editing to 1..Number and add ".." on end.

## [0.1.62] - 2017-01-24
### Added
- 'textFieldFontSize' parameter to newTextField() options. Sets font size used in text field.
- 'textBoxFontSize' parameter to newTextBox() options. Sets font size used in text box.
- 'fontSize' parameter added to both newTextField() and newTextBox() to set the label size.
### Fixed
- Font size of textboxes were really small. Now it sets the font and the size appropriately.

## [0.1.61] - 2017-01-20
### Added
- 'iconImage' parameter to newTileGrid() list options. Allows a tile to use an image (jpg/png) instead of icon font text.
- 'fontIsScaled' parameter to newTileGrid(). Defaults to true.  If true scale the font to fit the width of the tile. If false let the user define the font to any size.
- 'fontSize' parameter to newTileGrid(). Sets the overall font size for icon and text.
- 'parent' parameter to newTileGrid().  If used it will place the newTileGrid widget into the group/parent.

## [0.1.60] - 2017-01-19
### Added
- 'hideSlidePanel()' method to hide a newSlidePanel() widget by name. This can be used in your callBacks. This keeps the slide panel in memory and hides it.
- 'showSlidePanel()' method to show a newSlidePanel() widget by name. This can be used in your callBacks. This uses the slide panel in memory and shows it.
See menu.lua for example.

## [0.1.59] - 2017-01-19
### Added
- 'closeSlidePanel()' method to close a newSlidePanel() widget by name.  This is now the default action if used the built-in callBack.  You may call this in your own callBacks.
Example: mui.closeSlidePanel("slidepanel-demo")
- 'callBack' parameter added to each menu item.  If used this callBack will be called instead of the parent callBack for the entire newSlidePanel() widget.
- 'callBackData' parameter added to each menu item. if used the data will be passed to the callBack being used.

## [0.1.58] - 2017-01-19
### Changes
- Fixed issue #143 reported by StevenWarren: "useActualDimensions" parameter to mui.init() was setting useActualDimensions to true.
- Fixed issue #142 reported by taigak: newCard demo example in documentation was incorrect. It's fixed.

## [0.1.57] - 2017-01-17
- Added else statement in mui-textinput.lua from StevenWarren
- Added new example to menu textfield_demo_with_placeholder from StevenWarren

## [0.1.56] - 2017-01-14
### Fixed
- 'newShadowShape' being used in mui-card and mui-button.  These will render as intended.

## [0.1.55] - 2017-01-11
### Added
- 'iconColor' parameter to newToolbar list {} options. Specify color in on state per icon.
- 'iconColorOff' parameter to newToolbar list {} options. Specify color in off state per icon.
- 'iconColor' parameter to newSlidePanel list {} options. Specify color in on state per icon.
- 'iconColorOff' parameter to newSlidePanel list {} options. Specify color in off state per icon.

### Fixed
- Color bugs in newSlidePanel and newToolbar methods.

## [0.1.54] - 2017-01-11
### Change
- Fixed bug where newSlidePanel forced white background on buttons, user-defined now.  It uses the background color of the whole panel by parameter "fillColor"

## [0.1.53] - 2017-01-09
### Added
- 'iconImage' parameter to newToolbar() method.  It will fit the image to the font size dimensions. This is so it will look correct. See demo and "list {}" for an example.

## [0.1.52] - 2017-01-09
### Added
- 'iconImage' parameter to newSlidePanel() method.  It will fit the image to the font size dimensions. This is so it will look correct. See demo and "list {}" for an example.

## [0.1.51] - 2017-01-09
### Added
- 'headerImage' parameter to newSlidePanel() method.  It will fit the image to the menu header dimensions.

## [0.1.50] - 2017-01-08
### Added
- Method "newSnackBar" for creating snack bar and action button text. These flow up from the bottom.  Like "Removed Msgs  UNDO" and it times out after 3 seconds.  Use "timeOut" to specify timeout in microseconds.

### Change
- Fixed all "parent" group/scene paramater for all controls.  The demo is updated using a parent for all buttons.  Click "coffee cup" to see all the controls slide up (snack bar).

## [0.1.49] - 2017-01-06
### Changes
- Added "useTimeOut" parameter to newToast(..) method.  useTimeOut is boolean.  This is used to automatically timeout and close the toast notification.  If not "timeOut" in microseconds is specified it defaults to 2000 or 2 seconds.
- Added "timeOut" parameter to newToast(..) method.  timeOut is in microseconds.  This is used to automatically timeout and close the toast notification.

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

## Omitted older changes being tracked to shorten this file.

## [0.1.1] - 2016-06-01
### Added
- This project to GitHub
