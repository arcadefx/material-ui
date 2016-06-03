-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local mui = require( "materialui.mui" )

local scene = composer.newScene()
local background = nil

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

    mui.createRectButton({
        name = "playGame",
        text = "Play Game",
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
            sceneTransitionColor = { 1, 0.58, 0 }
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
        callBack = mui.actionForCheckbox
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
            { key = "Cookie", value = "1", isChecked = true },
            { key = "Fruit Snack", value = "2", isChecked = false },
            { key = "Grape", value = "3", isChecked = false }
        }
    })

    local buttonHeight = mui.getScaleVal(70)
    mui.createToolbar({
        name = "toolbar_demo",
        width = mui.getScaleVal(20), -- default to 100% for now
        height = mui.getScaleVal(20),
        buttonHeight = buttonHeight,
        x = 0,
        y = (display.contentHeight - (buttonHeight * 0.5)),
        layout = "horizontal",
        labelFont = native.systemFont,
        color = { 0.67, 0, 1 },
        labelColor = { 1, 1, 1 },
        labelColorOff = { 0.41, 0.03, 0.49 },
        callBack = mui.actionForToolbar,
        sliderColor = { 1, 1, 1 },
        list = {
            { key = "Home", value = "1", icon="home", isChecked = true},
            { key = "Newsroom", value = "2", icon="new_releases", isChecked = false },
            { key = "Location", value = "3", icon="location_searching", isChecked = false },
            { key = "To-do List", value = "4", icon="view_list", isChecked = false }
        }
    })

    ---[[--
    mui.createTableView({
        name = "tableview_demo",
        width = mui.getScaleVal(300),
        height = mui.getScaleVal(300),
        top = 40,
        left = display.contentWidth - mui.getScaleVal(315),
        labelFont = native.systemFont,
        color = { 0.67, 0, 1 },
        labelColor = { 1, 1, 1 },
        labelColorOff = { 0.41, 0.03, 0.49 },
        lineColor = { 1, 1, 1, 255 },
        rowColor = { default={1,1,1}, over={1,0.5,0,0.2} },
        rowHeight = mui.getScaleVal(60),
        callBackTouch = mui.onRowTouch,
        callBackRender = mui.onRowRender,
        scrollListener = nil,
        list = { -- if 'key' use it for 'id' in the table row
            { key = "Row1", value = "Row 1", isCategory = false },
            { key = "Row2", value = "Row 2", isCategory = false },
            { key = "Row3", value = "Row 3", isCategory = false },
            { key = "Row4", value = "Row 4", isCategory = false }
        },
        categoryColor = { default={0.8,0.8,0.8,0.8} },
        categoryLineColor = { 1, 1, 1, 0 },
        circleColor = { 0.4, 0.4, 0.4 }
    })
    --]]--

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
