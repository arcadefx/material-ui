-----------------------------------------------------------------------------------------
--
-- fun.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local mui = require( "materialui.mui" )

local scene = composer.newScene()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local background = nil

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- create a grey rectangle as the backdrop
	background = display.newRect( 0, 0, screenW, screenH )
	local colorFill = { 1, 1, 1 }
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( unpack(colorFill) )

    mui.init()
    mui.createRRectButton({
        name = "goBack",
        text = "Go Back",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(220),
        font = native.systemFont,
        fillColor = { 0, 0.82, 1 },
        textColor = { 1, 1, 1 },
        callBack = mui.actionSwitchScene,
        callBackData = { 
            sceneDestination = "menu",
            sceneTransitionColor = { 1, 0.58, 0 }
        } -- scene menu.lua
    })

	
	sceneGroup:insert( background )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		--physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		--physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
    mui.removeWidgets()
    if background ~= nil then
        background:removeSelf()
        background = nil
    end
	sceneGroup:removeSelf()
	sceneGroup = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene