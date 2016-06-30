-----------------------------------------------------------------------------------------
--
-- fun.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local mui = require( "materialui.mui" )
local widget = require( "widget" )

local scene = composer.newScene()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local background = nil
local scrollView = nil
local infoText = nil

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
        scrollView = scrollView,
        name = "goBack",
        text = "Go Back",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(100),
        font = native.systemFont,
        fillColor = { 0, 0.82, 1 },
        textColor = { 1, 1, 1 },
        callBack = mui.actionSwitchScene,
        callBackData = { 
            sceneDestination = "menu",
            sceneTransitionColor = { 0, 0.73, 1 }
        } -- scene menu.lua
    })

    -- show a "toast" message, yes I said toast like HTML 5 Toast
    -- recommend 40 percent ratio for one liners (20 radius/50 height = 0.40)
    local showToast = function()
        mui.createToast({
            name = "toast_demo",
            text = "New Messages!",
            radius = 20,
            width = mui.getScaleVal(220),
            height = mui.getScaleVal(50),
            font = native.systemFont,
            fontSize = mui.getScaleVal(24),
            fillColor = { 0, 0, 0, 1 },
            textColor = { 1, 1, 1, 1 },
            top = mui.getScaleVal(80),
            easingIn = 500,
            easingOut = 500,
            callBack = mui.actionForButton
        })
    end

    mui.createRRectButton({
        name = "newToast",
        text = "Show Toast",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(220),
        font = native.systemFont,
        textColor = { 1, 1, 1, 1 },
        fillColor = { 0.26, 0.71, 0.68, 1 },
        radius = 10,
        callBack = showToast
    })

    -- horizontal slider (vertical in development)
    ---[[--
    mui.createSlider({
        name = "slider_demo",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(4),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(400),
        radius = mui.getScaleVal(12),
        colorOff = { 1, 1, 1, 1 },
        color = { 1, 0, 0, 1 },
        startPercent = 30,
        callBackMove = mui.sliderCallBackMove,
        callBack = mui.sliderCallBack
    })
    mui.createSlider({
        name = "slider_demo2",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(4),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(450),
        radius = mui.getScaleVal(12),
        colorOff = { 1, 1, 1, 1 },
        color = { 0.31, 0.65, 0.03, 1 },
        startPercent = 60,
        callBackMove = mui.sliderCallBackMove,
        callBack = mui.sliderCallBack
    })
    --]]--

	-- Create the widget
    ---[[--
	local scrollWidth = display.contentWidth * 0.5
	scrollView = widget.newScrollView(
	    {
	        top = mui.getScaleVal(30),
	        left = (display.contentWidth - scrollWidth),
	        width = scrollWidth,
	        height = mui.getScaleVal(450),
	        scrollWidth = scrollWidth,
	        scrollHeight = (display.contentHeight * 2),
	        listener = scrollAListener
	    }
	)

    mui.createTextField({
        name = "textfield_demo2",
        labelText = "Subject",
        text = "Hello, world!",
        font = native.systemFont,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(100),
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        scrollView = scrollView
    })
    --]]--

    mui.createTextField({
        name = "textfield_demo3",
        labelText = "Tweet",
        text = "Scroll away",
        font = native.systemFont,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(230),
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        scrollView = scrollView
    })

    mui.createTextField({
        name = "textfield_demo4",
        labelText = "My Topic",
        text = "Hello, World!",
        font = native.systemFont,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(380),
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        scrollView = scrollView
    })

    mui.createTextField({
        name = "textfield_demo5",
        labelText = "My Topic 2",
        text = "Hello from below!",
        font = native.systemFont,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(530),
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        scrollView = scrollView
    })

    mui.createTextBox({
        name = "textbox_demo1",
        labelText = "Secret Text Box",
        text = "I am hidden in view\nYes, me too!\nFood\nDrink\nDesert",
        font = native.systemFont,
        fontSize = mui.getScaleVal(46),
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(200),
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(750),
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        isEditable = true,
        scrollView = scrollView
    })

    local textOptions =
    {
        --parent = textGroup,
        text = "Scroll the above",
        x = display.contentWidth * 0.75,
        y = display.contentHeight * 0.95,
        width = mui.getScaleVal(400),
        font = native.systemFont,
        fontSize = (mui.getScaleVal(46) * 0.75),
        align = "left"  --new alignment parameter
    }
    infoText = display.newText( textOptions )
    infoText:setFillColor( 0.4, 0.4, 0.4 )
	
	sceneGroup:insert( background )
end

--
-- a generic scroll to hold ui elements
--

-- ScrollView listener
function scrollAListener( event )

    local phase = event.phase
    if event.phase == nil then return end

    mui.updateEventHandler( event )

    if ( phase == "began" ) then
        -- skip it
    elseif ( phase == "moved" ) then
        mui.updateUI(event)
    elseif ( phase == "ended" ) then
        -- print( "Scroll view was released" )
    end

    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then print( "Reached top limit" )
        elseif ( event.direction == "left" ) then print( "Reached right limit" )
        elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end

    return true
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

    scrollView:removeSelf()
    scrollView = nil

    infoText:removeSelf()
    infoText = nil

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