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
    mui.createRRectButton({
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
* In the scene destroy function add in the remove method to destroy all user-interface elements in the scene
```
    mui.removeWidgets()
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
![Alt text](http://www.anedix.com/images/github/materialui-sample-view-3.png "Controls including text input")
- Note: The text input is the "Hello, world!"
- Video: https://youtu.be/6fqhrwtdcvg

Available Methods
-------------
Please read Lua code to find all parameters and see example in the repo call menu.lua.  All methods below implement a callback and lots of configuration options.

- `createDialog` - Create a dialog (modal) with content. Supports up to two buttons (Okay, Cancel) with callbacks. See menu.lua for an example.
- `createIconButton` - Create an icon button using the material design icon font.  The demo shows a 'checkbox' as an example.
- `createProgressBar` - Create an animated progress bar using "determinate" from Material Design. See menu.lua for an example. Includes linear call back (callBack) and later will support a repeating call back (repeatCallBack).
- `createRadioGroup` - Create a radio group with associated buttons.  It will automatically layout in vertical or horizontal formats with a series of radio buttons.
- `createRectButton` - Create a rectangle button
- `createRRectButton` - Create a rounded rectangle button
- `createSelect` - Create a select drop down list (dropdown list). Colors, dimensions and fonts can be specified.  See fun.lua for an example. Run the demo and tap "Switch Scene" button.
- `createSlider()` - Create a slider for doing percentages 0..100. Calculate amount in call backs: callBackMove (called during movement) and callBack = at the end phase.  Values are in percent (0.20, 0.90 and 1 for 100%). Limitations: horizontal only and no labels (both to be addressed).  See mui.lua and method sliderCallBackMove() to get current value of slider.
- `createTableView` - Create a scrollable table view
- `createTextBox` - Create a text box with label above (for now) and includes "scrollView" support. See fun.lua for an example.
- `createTextField` - Create a text field with label above (for now) and includes "scrollView" support.  See fun.lua for an example.
- `createToast` - Create simple "toast" notifications on screen. Colors, dimensions and fonts can be specified.  See fun.lua for an example run the demo and tap "Switch Scene" button. Tap "Show Toast"
- `createToggleSwitch` - Create a toggle switch. See menu.lua for an example.
- `createToolbar` - Create a horizontal toolbar with icon buttons using the material design icon font. Each toolbar button supports either material design icon or use "labelText" to use a normal text/word instead of icon. Mixing both on the same toolbar is supported.  To specify alternate font use "labelFont" attribute.  See menu.lua example (1 option is commented out, uncomment to see it work).
Usage of Icon and Text together is supported (Icon on top and text beneath).

Helper Methods
-------------
- `closeDialog` - closes an open dialog and releases memory
- `getScaleVal` - returns integer scaled value to fit resolution. Useful for dimensions and coordinates.
- `getWidgetByName` - returns the array of a named widget.
- `getWidgetBaseObject` - returns the base object of a named widget created with one of the above methods. It can be inserted into another container, group, scrollview and moved around, etc.  Example: rectangle_surface:insert( mui.getWidgetBaseObject("okay_button") )
- `getEventParameter` - returns the event MUI widget parameters for the current widget.  Get the event target, widget name, widget value ( ex: getEventParameter(event, "muiTargetValue") ).  The value is set when creating a widget.  See menu.lua for setting the values and mui.lua callBacks for getting values (example would be actionForSwitch() method).

Remove widget methods - these will remove the widget by name and release memory:
- `removeWidgetDialog`
- `removeWidgetIconButton`
- `removeWidgetProgressBar`
- `removeWidgetRadioButton`
- `removeWidgetRectButton`
- `removeWidgetRRectButton`
- `removeWidgetSelect`
- `removeWidgetSlider`
- `removeWidgetSwitch`
- `removeWidgetTableView`
- `removeWidgetTextField`
- `removeWidgetTextBox`
- `removeWidgetToast`
- `removeWidgetToggleSwitch`
- `removeWidgetToolbar`
- `removeWidgetToolbarButton`

Built-In Callbacks
-------------

- `actionSwitchScene` - This is built-in callback for handle scene switching for a button. The color of the switch can be changed.  See menu.lua for an example.

Special Considerations
-------------
* Scroll views must contain the method mui.updateEventHandler( event ) before the check for event began. See fun.lua for an example.
* Scroll views must contain the method mui.updateUI(event) in "moved" phase. See fun.lua for an example.

Additional Features
-------------
* Touchpoints are included in several controls, but can be turned off.
* Built-in callBacks are defined but can be overridden easily to do other tasks.
* All widgets support a "value" and can be accessed in the callBacks by getEventParameter() method. See mui.lua for examples.
* Scroll view support for widgets (widget.newScrollView()). Use parameter: scrollView = scroll_view
* Colors can be adjusted and some controls support gradients.
* Adjusts native widgets into scrollView visible area automatically.
* To use Material font icons, refer to 'icon-font/codepoints' and place the codepoint as the 'text' of a button.  See http://google.github.io/material-design-icons/ for more information.

Contributing
-------------
* Feel free to contribute code, testing and feedback.
* Once we get additional authors they will be included in the repo and get recognition for their efforts.
* Please follow the licensing terms for any software included.

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
