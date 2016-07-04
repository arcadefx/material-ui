-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local mui = require( "materialui.mui" )

local scene = composer.newScene()
local background = nil
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    --Hide status bar from the beginning
    display.setStatusBar( display.HiddenStatusBar )

    display.setDefault("background", 1, 1, 1)

    background = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
    background.anchorX = 0
    background.anchorY = 0
    background.x, background.y = 0, 0
    background:setFillColor( 1 )

    sceneGroup:insert( background )

    mui.init()

    -- dialog box example
    -- use mui.getWidgetBaseObject("dialog_demo") to get surface to add more content
    local showDialog = function()
        mui.createDialog({
            name = "dialog_demo",
            width = mui.getScaleVal(450),
            height = mui.getScaleVal(300),
            text = "Do you want to continue?",
            textX = 0,
            textY = 0,
            textColor = { 0, 0, 0, 1 },
            font = systemFont,
            fontSize = mui.getScaleVal(32),
            backgroundColor = { 1, 1, 1, 1 },
            gradientBorderShadowColor1 = { 1, 1, 1, 0.4 },
            gradientBorderShadowColor2 = { 0, 0, 0, 0.4 },
            easing = easing.inOutCubic, -- this is default if omitted
            buttons = {
                font = native.systemFont,
                okayButton = {
                    text = "Okay",
                    textColor = { 0.01, 0.65, 0.08 },
                    fillColor = { 1, 1, 1 },
                    width = mui.getScaleVal(100),
                    height = mui.getScaleVal(50),
                    callBackOkay = mui.actionForOkayDialog,
                    clickAnimation = {
                        colorBackground = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                },
                cancelButton = {
                    text = "Cancel",
                    textColor = { 0.01, 0.65, 0.08 },
                    fillColor = { 1, 1, 1 },
                    width = mui.getScaleVal(100),
                    height = mui.getScaleVal(50),
                    clickAnimation = {
                        colorBackground = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                }
            }
        })
    end

    mui.createRRectButton({
        name = "newDialog",
        text = "Open Dialog",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(220),
        font = native.systemFont,
        gradientShadowColor1 = { 0.9, 0.9, 0.9, 255 },
        gradientShadowColor2 = { 0.9, 0.9, 0.9, 0 },
        gradientDirection = "up",
        textColor = { 1, 1, 1 },
        radius = 10,
        callBack = showDialog
    })

    mui.createRectButton({
        name = "scene2",
        text = "Switch Scene",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(120),
        font = native.systemFont,
        fillColor = { 0.17, 0.88, 0.12 },
        textColor = { 1, 1, 1 },
        touchpoint = true,
        callBack = mui.actionSwitchScene,
        callBackData = { 
            sceneDestination = "fun",
            sceneTransitionColor = { 0, 0.73, 1 }
        } -- scene fun.lua
    })

    mui.createIconButton({
        name = "plus",
        text = "add_circle",
        width = mui.getScaleVal(50),
        height = mui.getScaleVal(50),
        x = mui.getScaleVal(60),
        y = mui.getScaleVal(40),
        font = "MaterialIcons-Regular.ttf",
        textColor = { 1, 0, 0.4 },
        textAlign = "center",
        callBack = mui.actionForPlus
    })

    -- simulates a checkbox but can be other toggle buttons too!
    mui.createIconButton({
        name = "check",
        text = "check_box_outline_blank",
        width = mui.getScaleVal(50),
        height = mui.getScaleVal(50),
        x = mui.getScaleVal(360),
        y = mui.getScaleVal(120),
        font = "MaterialIcons-Regular.ttf",
        textColor = { 0.17, 0.88, 0.12 },
        textAlign = "center",
        value = 500,
        callBack = mui.actionForCheckbox
    })

    mui.createToggleSwitch({
        name = "switch_demo",
        size = mui.getScaleVal(55),
        x = mui.getScaleVal(360),
        y = mui.getScaleVal(220),
        textColorOff = { 0.57, 0.85, 1, 1 },
        textColor = { 0.25, 0.75, 1, 1 },
        backgroundColor = { 0.74, 0.88, 0.99, 1 },
        backgroundColorOff = { 0.82, 0.95, 0.98, 1 },
        isChecked = true,
        value = 100, -- if switch is in the on position it's 100 else nil
        callBack = mui.actionForSwitch
    })

    mui.createRadioGroup({
        name = "radio_demo",
        width = mui.getScaleVal(30), --+ (getScaleVal(30)*1.2),
        height = mui.getScaleVal(30),
        x = mui.getScaleVal(120),
        y = mui.getScaleVal(40),
        layout = "horizontal",
        labelFont = native.systemFont,
        textColor = { 1, 0, 0.4 },
        labelColor = { 0, 0, 0 },
        callBack = mui.actionForRadioButton,
        list = {
            { key = "Cookie", value = "1", isChecked = false },
            { key = "Fruit Snack", value = "2", isChecked = false },
            { key = "Grape", value = "3", isChecked = true }
        }
    })

    ---[[--
    mui.createTableView({
        name = "tableview_demo",
        width = mui.getScaleVal(300),
        height = mui.getScaleVal(300),
        top = mui.getScaleVal(40),
        left = display.contentWidth - mui.getScaleVal(315),
        font = native.systemFont,
        textColor = { 0, 0, 0, 1 },
        lineColor = { 1, 1, 1, 1 },
        lineHeight = mui.getScaleVal(4),
        rowColor = { default={1,1,1}, over={1,0.5,0,0.2} },
        rowHeight = mui.getScaleVal(60),
        -- rowAnimation = false, -- turn on rowAnimation
        noLines = false,
        callBackTouch = mui.onRowTouchDemo,
        callBackRender = mui.onRowRenderDemo,
        scrollListener = mui.scrollListener,  -- needed if using buttons, etc within the row!
        list = { -- if 'key' use it for 'id' in the table row
            { key = "Row1", text = "Row 1", value = "1", isCategory = false },
            { key = "Row2", text = "Row 2", value = "2", isCategory = false },
            { key = "Row3", text = "Row 3", value = "3", isCategory = false },
            { key = "Row4", text = "Row 4", value = "4", isCategory = false },
            -- below are rows with different background colors
            -- set "noLines" to true above to omit line border
            -- { key = "Row2", text = "Row 2", value = "5", isCategory = false, backgroundColor = { 0.67, 0.98, 0.65, 0.2 } },
            -- { key = "Row3", text = "Row 3", value = "6", isCategory = false, backgroundColor = { 1, 0, 0, 0.2 }  },
        },
        categoryColor = { default={0.8,0.8,0.8,0.8} },
        categoryLineColor = { 1, 1, 1, 0 },
        touchpointColor = { 0.4, 0.4, 0.4 },
    })
    --]]--

    mui.createTextField({
        name = "textfield_demo",
        labelText = "Subject",
        text = "Hello, world!",
        font = native.systemFont,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(400),
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack
    })

    -- create and animate the intial value (1% is always required due to scaling method)
    mui.createProgressBar({
        name = "progressbar_demo",
        width = mui.getScaleVal(290),
        height = mui.getScaleVal(8),
        x = mui.getScaleVal(650),
        y = mui.getScaleVal(400),
        foregroundColor = { 0, 0.78, 1, 1 },
        backgroundColor = { 0.82, 0.95, 0.98, 0.8 },
        startPercent = 20,
        barType = "determinate",
        iterations = 1,
        labelText = "Determinate progress",
        labelFont = native.systemFont,
        labelFontSize = mui.getScaleVal(24),
        labelColor = {  0.4, 0.4, 0.4, 1 },
        labelAlign = "left",
        callBack = mui.postProgressCallBack,
        --repeatCallBack = <your method here>,
        hideBackdropWhenDone = false
    })

    -- show how to increase progress bar by percent using a timer or method after the above creation
    local function increaseMyProgressBar()
        print("increaseMyProgressBar")
        mui.increaseProgressBar( "progressbar_demo", 80 )
    end
    timer.performWithDelay(3000, increaseMyProgressBar, 1)
    -- increaseMyProgressBar() -- will be queued if already processing an increase

    -- on bottom and stay on top of other widgets.
    local buttonHeight = mui.getScaleVal(70)
    mui.createToolbar({
        name = "toolbar_demo",
        --width = mui.getScaleVal(500), -- defaults to display.contentWidth
        height = mui.getScaleVal(70),
        buttonHeight = buttonHeight,
        x = 0,
        y = (display.contentHeight - (buttonHeight * 0.5)),
        layout = "horizontal",
        labelFont = native.systemFont,
        color = { 0.67, 0, 1 },
        fillColor = { 0.67, 0, 1 },
        labelColor = { 1, 1, 1 },
        labelColorOff = { 0.41, 0.03, 0.49 },
        callBack = mui.actionForToolbarDemo,
        sliderColor = { 1, 1, 1 },
        list = {
            { key = "Home", value = "1", icon="home", labelText="Home", isActive = true },
            { key = "Newsroom", value = "2", icon="new_releases", labelText="News", isActive = false },
            { key = "Location", value = "3", icon="location_searching", labelText="Location", isActive = false },
            { key = "To-do", value = "4", icon="view_list", labelText="To-do", isActive = false },
            -- { key = "Viewer", value = "4", labelText="View", isActive = false } -- uncomment to see View as text
        }
    })

end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.

    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
    mui.removeWidgets()
    if background ~= nil then
        background:removeSelf()
        background = nil
    end
    sceneGroup:removeSelf()
    sceneGroup = nil

end

-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
