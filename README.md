# material-ui
Material Design UI for Corona Labs SDK

This README is just an overview document. You can find more detailed documentation within the repo in future updates.

What is material-ui?
--------------

material-ui is a loosely based Material UI module for Corona Labs SDK.  It is written in Lua using the free edition of the SDK.  The module will help build a UI based on Material Design.  Due note a layout engine and improved palette engine are being developed.

Using material-ui
--------------

* Clone the repo
```bash
git clone git://github.com/arcadefx/material-ui.git
```
* Copy the required files and folders into your project:
```bash
materialui.lua
icon-font (folder)
```
* Edit your scene file and be sure to include at the top:
```
local mui = require( "materialui" )
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

Available Methods
-------------
Please read Lua code to find all parameters and see example in the repo call menu.lua.  All methods below implement a callback and lots of configuration options.  Touchpoints are included.

`createRRectButton` - Create a rounded rectangle button
`createRectButton` - Create a rectangle button
`createIconButton` - Create an icon button using the material design icon font
`createRadioGroup` - Create a radio group with associated buttons.  It will automatically layout in vertical or horizontal formats with a series of radio buttons.
`createToolbar` - Create a horizontal toolbar with icon buttons using the material design icon font. You can override the font.
`createTableView` - Create a scrollable table view
`actionSwitchScene` - This is built-in callback for handle scene switching for a button. The color of the switch can be changed.

Available Methods
-------------
* Touchpoints are included in all controls, but can be turned off.
* Built-in callBacks are defined but can be overridden easily to do other tasks.
* Colors can be adjusted and some controls support gradients.

Contributing
-------------
* Feel free to contribute code, testing and feedback.
* Once we get additional authors they will be included in the repo and get recognition for their efforts.

To-Do
-------------
* Expand the module
* Get help from fellow developers to improve and enhance the module

Summary
-------------
There are also many other files not described here,  please review the .lua files for additional information. :-)

Enjoy!
