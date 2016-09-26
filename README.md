# material-ui
Material Design UI for Corona Labs SDK

This README is just an overview document. You can find more detailed documentation within the repo in future updates.

What is material-ui?
--------------

material-ui is a loosely based Material UI library for Corona Labs SDK.  It is written in Lua using the free edition of the SDK.  The library will help build a UI based on Material Design.

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

Available Methods and Documentation
-------------
* See Documentation. [View Documentation](http://www.anedix.com/docs/mui/) for more information on methods, examples and properties.

Contributing
-------------
* Feel free to contribute code, testing and feedback.
* Once we get additional authors they will be included in the repo and get recognition for their efforts.
* Please follow the licensing terms for any software included.
* See materialui/mui-example.lua for creating additional modules or review any mui-[name].lua module to see the format.

Change Log
-------------
* Please see "CHANGELOG.md" in this repo for information on latest changes.

To-Do
-------------
* Expand the library (new widgets: card, clock, calendar, etc)
* Develop a layout engine 
* Develop a palette engine

Summary
-------------
There are also many other files not described here,  please review the .lua files for additional information. :-)

Enjoy!
