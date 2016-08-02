# material-ui
Material Design UI for Corona Labs SDK

This README is just an overview document. You can find more detailed documentation within the repo in future updates.

What is material-ui?
--------------

material-ui is a loosely based Material UI module for Corona Labs SDK.  It is written in Lua using the free edition of the SDK.  The module will help build a UI based on Material Design.

Using material-ui
--------------

* Clone the repo or download archive
```bash
git clone git://github.com/arcadefx/material-ui.git
```
* Copy the required files and folders into your project:
```bash
MaterialIcons-Regular.ttf
materialui (folder)
icon-font (folder)
```
* Edit your scene file and be sure to include at the top:
```
local mui = require( "materialui.mui" )
```
* In the scene create function add in the initializer and any user-interface elements
```
    mui.init()
    mui.newRoundedRectButton({
        name = "newGame",
        text = "New Game",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(220),
        font = native.systemFont,
        fillColor = { 0, 0.82, 1 },
        textColor = { 1, 1, 1 },
        callBack = mui.actionForButton
    })
```
* In the scene destroy function add in the destroy method to remove all user-interface elements in the scene.
```
    mui.destroy()
```

Building for Device
-------------
Due to device keyboard possibly covering up input fields, be sure to include "coronaWindowMovesWhenKeyboardAppears=true" into iOS settings->iphone->plist table and Android settings.

For an example, see build.settings file included.


Try a Demo
-------------
Using Corona Simulator open up the "main.lua" file in the folder.

Sample Screenshot
-------------
![Alt text](http://www.anedix.com/images/github/material-ui-main.png "Controls including text input")
- Note: The text input is the "Hello, world!"
- Video: https://youtu.be/c8p3DMA6PzU

Available Methods
-------------
Please read Lua code to find all parameters and see example in the repo call menu.lua.  All methods below implement a callback and lots of configuration options.  Please see project [Wiki](https://github.com/arcadefx/material-ui/wiki) for more information on method, example and properties.

*Initialize and Destroy*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `init` | Initialize the library and settings. init() has two parameters: {} of modules to include, {} of options). Example: muiData.init( nil, {useActualDimensions = true} ) and specifying 'nil' for modules loads all modules | menu.lua/fun.lua |
| `destroy` | Destroy all widgets and resources and free memory | menu.lua/fun.lua |

*Buttons*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `newCircleButton` | Create a circle button with a single character or even a word.| menu.lua |
| `newIconButton`      | Create an icon button using the material design icon font. Use this to create check boxes and more. | menu.lua |
| `newRectButton` | Create a rectangle button      |    menu.lua/fun.lua |
| `newRoundedRectButton` | Create a rounded rectangle button     |    menu.lua/fun.lua |

*Date/Time*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `newDatePicker` | Create a date picker. Use pickerGetCurrentValue() method to get current value in a table format. | menu.lua / mui-datetime.lua |
| `newTimePicker` | Create a time picker. Use pickerGetCurrentValue() method to get current value in a table format. | menu.lua / mui-datetime.lua |

*Dialogs / Notifications*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `newDialog` | Create a dialog (modal) with content. Supports up to two buttons (Okay, Cancel) with callbacks.       | menu.lua |
| `newToast` | Create simple "toast" notifications on screen. Colors, dimensions and fonts can be specified.      |    fun.lua |

*Input*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `newCheckBox` | Create a check box. | menu.lua |
| `newTextBox` | Create a text box with label above (for now)      |    fun.lua |
| `newTextField` | Create a text field with label above (for now)      |    menu.lua/fun.lua |
| `newRadioGroup` | Create a radio group with associated buttons.  It will automatically layout in vertical or horizontal formats with a series of radio buttons.      |    menu.lua |
| `newSelect` | Create a select drop down list (dropdown list). Colors, dimensions and fonts can be specified.      |    fun.lua |
| `newSlider` | Create a slider for doing percentages 0..100. Calculate amount in call backs: callBackMove (called during movement) and callBack = at the end phase.  Values are in percent (0.20, 0.90 and 1 for 100%). See method sliderCallBackMove() to get current value of slider.       |    fun.lua |
| `newToggleSwitch` | Create a toggle switch.      |    menu.lua |

*Menu / Navigation*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `newNavbar`      | Create a navigation bar. Allows left and right alignment of attached widgets. Supports widget types: Text, EmbossedText, CircleButton, IconButton, RRectButton, RectButton, Slider, TextField. Additional widget types will be added. | fun.lua |
| `newSlidePanel` | Create a slide out menu (see hamburger icon) | menu.lua/fun.lua |
| `newToolbar` | Create a horizontal toolbar with icon, text or icon + text (icon on top, text on bottom) buttons      |    menu.lua |
| `newTileGrid` | Create a tile menu board and tiles can be up to 2x in size, be careful. See demo tile.lua and it's the last icon on bottom of first scene.| tile.lua |

*Text*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `newEmossedText` | Create embossed text. A wrapper to make it easier to attach 'newEmbossedText' to navbar, menu, etc (see Corona newEmossedText for options) | n/a |
| `newText` | Create text. A wrapper to make it easier to attach 'newText' to navbar, menu, etc (see Corona newText for options) | menu.lua/fun.lua |

*Misc*

| Method        | Short Description | Example  |
| ------------- | ------------- | :-----:|
| `newProgressBar` | Create an animated progress bar using "determinate" from Material Design.      |    menu.lua |
| `newTableView` | Create a scrollable table view      |    menu.lua/fun.lua |
| `newParentOnBoard` | Create an "onboarding" scene. The onboarding/walkthrough screens for first-time users. Introduce the app and demonstrate what it does. Used in conjunction with `addChildOnBoard`. Tap "?" in the demo's first scene. Supports progress indicators (rectangle and circles) Please "read" the comments near the top of the example. |    onboard.lua |

Helper Methods
-------------
- `attachToNavBar` - attaches widget to navigation bar.
- `attachToRow` - attaches widget to table view row.
- `closeDialog` - closes an open dialog and releases memory
- `getScaleVal` - returns integer scaled value to fit resolution. Useful for dimensions and coordinates.
- `getWidgetProperty` - returns the widget property by name. The property can be the text or layer of the widget (like a button).
- `getWidgetByName` - returns the array of a named widget.
- `getWidgetBaseObject` - returns the base object of a named widget created with one of the above methods. It can be inserted into another container, group, scrollview and moved around, etc.  Example: rectangle_surface:insert( mui.getWidgetBaseObject("okay_button") )
- `getEventParameter` - returns the event MUI widget parameters for the current widget.  Get the event target, widget name, widget value ( ex: getEventParameter(event, "muiTargetValue") ).  The value is set when creating a widget.  See menu.lua for setting the values and mui.lua callBacks for getting values (example would be actionForSwitch() method).
- `hideWidget` - hide a widget by name. It will hide/show a widget by setting the isVisible attribute.
- `setDisplayToActualDimensions` - Set the display dimensions to use display.actualContentWidth and height or display.contentWidth and height.  Apply this when calling muiData.init(...), example: muiData.init( nil, {useActualDimensions = true} ).

Remove widget methods - these will remove the widget by name and release memory:
- `remove[widget name]("widget name to remove")` from above, example: `removeCircleButton("demo-circle-button")`

Built-In Callbacks
-------------

- `actionSwitchScene` - This is built-in callback for handle scene switching for a button. The color of the switch can be changed.  See menu.lua for an example.

Special Considerations
-------------
* Scroll views must contain the method mui.updateEventHandler( event ) before the check for event began. See fun.lua for an example.
* Scroll views must contain the method mui.updateUI(event) in "moved" phase. See fun.lua for an example.
* Navigation bars should be added last so they reside on top of most elements/widgets. This follows Corona SDK.
* Use 'minPixelScaleWidthForPortrait' and 'minPixelScaleWidthForLandscape' with init(nil, {minPixelScaleWidthForPortrait=[value],minPixelScaleWidthForLandscape=[value]} to override the base scale of MUI elements. Defaults to 640 portrait and 960 landscape.

Additional Features
-------------
* All methods can be accessed from other modules (methods are shared through one end point). See menu.lua and any module in the "materialui/" folder.
* Touchpoints are included in several controls, but can be turned off.
* Built-in callBacks are defined but can be overridden easily to do other tasks.
* All widgets support a "value" and can be accessed in the callBacks by getEventParameter() method. See mui.lua for examples.
* Scroll view support for widgets (widget.newScrollView()). Use parameter: scrollView = scroll_view
* Colors can be adjusted and some controls support gradients.
* Adjusts native widgets into scrollView visible area automatically.
* Generic/User defined widgets can be added to navigation bars. See fun.lua for an example.
* To use Material font icons, refer to 'icon-font/codepoints' and place the codepoint as the 'text' of a button.  See http://google.github.io/material-design-icons/ for more information.
* Ability to create additional modules using a simple template. materialui/mui-example.lua is the template.
* Ability to specify which modules are needed by a scene. Include a table ({}) in the mui.init() for the modules needed. If "none" are specified then all modules are loaded. See mui.lua for sample list.

Contributing
-------------
* Feel free to contribute code, testing and feedback.
* Once we get additional authors they will be included in the repo and get recognition for their efforts.
* Please follow the licensing terms for any software included.
* See materialui/mui-example.lua for creating additional modules or review any mui-<name>.lua module to see the format.

Change Log
-------------
* Please see "CHANGELOG.md" in this repo for information on latest changes.

To-Do
-------------
* Expand the module (new widgets: switches, hamburger menu, input fields, etc)
* Develop a layout engine 
* Develop a palette engine

Summary
-------------
There are also many other files not described here,  please review the .lua files for additional information. :-)

Enjoy!
