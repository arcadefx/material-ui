-----------------------------------------------------------------------------------------
--
-- fun.lua
--
-----------------------------------------------------------------------------------------

-- corona
local composer = require( "composer" )
local widget = require( "widget" )

-- mui
local mui = require( "materialui.mui" )

local scene = composer.newScene()

--------------------------------------------

-- mui
local muiData = require( "materialui.mui-data" )

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

    mui.init()

    -- Gather insets (function returns these in the order of top, left, bottom, right)
    local topInset, leftInset, bottomInset, rightInset = mui.getSafeAreaInsets()

    screenW, screenH, halfW = muiData.safeAreaWidth, muiData.safeAreaHeight, muiData.safeAreaWidth*0.5

    --[[--
    -- Create a vector rectangle sized exactly to the "safe area"
    local background = display.newRect(
        display.screenOriginX + leftInset, 
        display.screenOriginY + topInset, 
        display.contentWidth - ( leftInset + rightInset ), 
        display.contentHeight - ( topInset + bottomInset )
    )
    background:setFillColor( 1 )
    background:translate( background.width*0.5, background.height*0.5 )
    sceneGroup:insert( background )
    --]]--

    --[[--
    Instructions..

    Onboarding is done by creating a "parent" group and adding children to it. 
    Adding mui widgets is allowed and is shown below.
    Currently only transitions allowed are "to" and "fade" (fade in/out)

    Note: All the "removing" and "freeing" memory happens automatically.
    --]]--

    --
    -- GROUP 1
    --

    local group1 = mui.newParentOnBoard({
        name = "group1",
        object = display.newGroup()
    })
    group1:translate(0, 0)

	-- create a backdrop for the top
    local background = mui.addChildOnBoard({
        parent = "group1",
        name = "background",
        object = display.newRect(
        display.screenOriginX + leftInset, 
        display.screenOriginY + topInset, 
        display.contentWidth - ( leftInset + rightInset ), 
        display.contentHeight - ( topInset + bottomInset ))
    })
	local colorFill = { 0.08, 0.9, 0.31 }
    background.anchorX = 0
    background.anchorY = 0
    background:setFillColor( unpack( colorFill ) )
    group1:insert( background )

    local textWidth = muiData.safeAreaWidth
    local options =
    {
        --parent = textGroup,
        name = "intro-text",
        text = "Welcome to Material UI.\n\n- Onboarding Demo\n\n- Bring users onboard with instructions.",
        x = 0,
        y = (background.contentHeight - (screenH * 0.4))  * 0.5,
        width = textWidth,     --required for multi-line and alignment
        font = native.systemFont,
        fontSize = 18,
        fillColor = { 1, 1, 1, 1 },
        align = "left"  --new alignment parameter
    }
    textWidth = mui.getTextWidth( options )
    options.width = textWidth
    mui.newText( options )
    local introText = mui.getWidgetBaseObject("intro-text")
    introText.x = (background.contentWidth * 0.5)
    group1:insert( introText )

    --
    -- GROUP 2
    --

    local group2 = mui.newParentOnBoard({
        name = "group2",
        object = display.newGroup()
    })
    group2:translate(0, 0)

    -- create a backdrop for the bottom
    local background2 = mui.addChildOnBoard({
        parent = "group2",
        name = "background2",
        object = display.newRect(
        display.screenOriginX + leftInset, 
        display.screenOriginY + topInset, 
        display.contentWidth - ( leftInset + rightInset ), 
        display.contentHeight - ( topInset + bottomInset ))
    })
    colorFill = { 0, 0.46, 1 }
    background2.anchorX = 0
    background2.anchorY = 0
    background2:setFillColor( unpack( colorFill ) )
    group2:insert( background2 )

    textWidth = display.contentWidth
    options =
    {
        --parent = textGroup,
        name = "intro-text2",
        text = "Thank You for Watching.\n\n-Sit back\n\n-Let's get started.",
        x = 0,
        y = (background2.contentHeight - (screenH * 0.4))  * 0.5,
        width = textWidth,     --required for multi-line and alignment
        font = native.systemFont,
        fontSize = 18,
        fillColor = { 1, 1, 1, 1 },
        align = "left"  --new alignment parameter
    }
    textWidth = mui.getTextWidth( options )
    options.width = textWidth
    mui.newText( options )
    local introText2 = mui.getWidgetBaseObject("intro-text2")
    introText2.x = (background2.contentWidth * 0.5)
    group2:insert( introText2 )

    --
    -- Prepare Slides. The config is used by the button below
    --
    slideConfig = {
        transition = "to", -- to or fade (which is fadeIn/fadeOut)
        direction = "left", -- left, right, up, down ("left" only supported at this time)
        easing = easing.outExpo,
        time = 1500,
        onComplete = mui.goToScene,
        onCompleteData = {
            sceneDestination = "menu",
            sceneTransitionColor = { 0, 0.73, 1 }
        }, -- scene menu.lua
        slides = { -- list of groups, containers or just big photos :)
            group1,
            group2
        }
    }
    mui.prepareSlidesForOnBoarding( slideConfig )

    --
    -- BOTTOM GROUP of Onboarding
    --

    local groupBottom = mui.newParentOnBoard({
        name = "groupBottom",
        object = display.newGroup()
    })
    groupBottom:translate(0, 0)

    -- create a backdrop for the bottom
    local backgroundBottom = mui.addChildOnBoard({
        parent = "groupBottom",
        name = "backgroundBottom",
        object = display.newRect( display.screenOriginX + leftInset, screenH, screenW, screenH * 0.4)
    })
    colorFill = { 1, 1, 1 }
    backgroundBottom.anchorX = 0
    backgroundBottom.anchorY = 0
    backgroundBottom:setFillColor( unpack( colorFill ) )
    groupBottom:insert( backgroundBottom )

    function forwardHandler( event )
        mui.toFrontSafeArea()
        if event.phase == "ended" or event.phase == "onTarget" then
            mui.switchSlideForOnBoard( { callBackData = slideConfig } )
        end
    end
    mui.newIconButton({
        name = "continue-button",
        text = "arrow_forward",
        width = 25,
        height = 25,
        x = backgroundBottom.contentWidth * 0.5,
        y = screenH + 100,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 0, 0, 0 },
        textAlign = "center",
        callBack = forwardHandler,
        callBackData = slideConfig
    })
    function backgroundBottom:touch( event )
        forwardHandler( event )
    end
    backgroundBottom:addEventListener( "touch", backgroundBottom )
    groupBottom:insert( mui.getWidgetBaseObject("continue-button") )

    --
    -- Elipses / progress indicator
    --
    mui.newElipsesForProgress({
        parent = "groupBottom",
        group = groupBottom,
        slides = 2, -- number of slides
        shape = "circle", -- rect or circle
        size = 18,
        fillColor = { 0, 0, 0 },
        y = screenH + 30
    })

    transition.to( groupBottom, { time=800, y=-(screenH * 0.4), transition=easing.outExpo } )

    --sceneGroup:insert( groupBottom )
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

    mui.destroy()

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