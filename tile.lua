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

-- mui
local muiData = require( "materialui.mui-data" )

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

    mui.init(nil, { parent=self.view })

    -- tile grid example
    mui.newTileGrid({
        parent = mui.getParent(),
        name = "grid_demo",
        width = muiData.safeAreaWidth,
        height = muiData.safeAreaHeight,
        tileHeight = 100,
        tilesPerRow = 4,
        x = 0,
        y = 0,
        fontIsScaled = false, -- default is true for scaling font to fit tile size width or false to not scale.
        iconFont = mui.materialFont, -- use pre-defined font
        fontSize = 40,
        labelFont = native.systemFont,
        textColor = { 1, 1, 1 },
        labelColor = { 1, 1, 1 },
        fillColor = { 0.8, 0.8, 0.8, 0.8 }, -- background color overall
        tileFillColor = { 1, 0.5, 0, 1 }, -- #F47B00 background color of tiles
        touchpoint = true,
        callBack = mui.tileCallBack,
        clickAnimation = {
        	style = "highlight", -- highlight, spin, rubberband
            highlightColor = { 0, 0.5, 1 },
	        highlightColorAlpha = 0.5,
            time = 400,
        },
        list = {
            { key = "Home", value = "1", icon="home", labelText="Home", tileFillColor = {1,0.6,0.19,1}, tileHighlightColor = { 1, 1, 1, 1}, tileHighlightColorAlpha = 0.5, isActive = true },
            { key = "Newsroom", value = "2", size = "2x", image="cloud-in-blue-sky855.jpg", iconImage="1484026171_02.png", padding=mui.getScaleVal(30), align="right", icon="wb_sunny", labelText="70 deg", tileFillColor = {0,0.34,0.6,1}, isActive = false },
            { key = "Location", value = "3", icon="location_searching", labelText="Location", tileFillColor = {0.36,0.81,0.42,1}, isActive = false },
            { key = "To-do", value = "4", icon="watch", tileFillColor = {0.36,0.81,0.42,1}, isActive = false },
            { key = "To-do 2", value = "5", labelText="Simple Walk", tileFillColor = {0,0.6,1,1}, isActive = false },
            { key = "To-do 3", value = "6", icon="whatshot", labelText="Hot Idea", tileFillColor = {1,0,0.2,1}, isActive = false },
            { key = "To-do 4", value = "7", icon="weekend", labelText="Weekend", tileFillColor = {0.95,0.47,0.6,1}, isActive = false },
            { key = "To-do 5", value = "8", icon="view_list", labelText="To-do 5", tileFillColor = {1,0,0.2,1}, isActive = false },
            { key = "To-do 6", value = "9", icon="view_list", labelText="To-do 6", tileFillColor = {0.47,0.76,0.95,1}, isActive = false },
            { key = "To-do 7", value = "10", icon="view_list", labelText="To-do 7", tileFillColor = {0,0.6,1,1}, isActive = false },
            { key = "To-do 8", value = "11", icon="view_list", labelText="To-do 8", tileFillColor = {0.36,0.81,0.42,1}, isActive = false },
            { key = "To-do 9", value = "12", icon="view_list", labelText="To-do 9", tileFillColor = {0,0.6,1,1}, isActive = false },
            { key = "To-do 10", value = "13", icon="view_list", labelText="To-do 10", tileFillColor = {1,0,0.2,1}, isActive = false },
            { key = "To-do 11", value = "14", icon="view_list", labelText="To-do 11", tileFillColor = {1,0.8,0,1}, isActive = false },
            { key = "To-do 12", value = "15", icon="view_list", labelText="To-do 12", isActive = false },
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
    mui.destroy()
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
