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

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local background = nil
local scrollView = nil
local infoText = nil

local function destroyDemoText( demoText )
    print("destroyDemoText called")
    if demoText ~= nil then
        demoText:removeSelf()
        demoText = nil
    end
end

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
    mui.newRoundedRectButton({
        scrollView = scrollView,
        name = "goBack",
        text = "Go Back",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(120),
        font = native.systemFont,
        fillColor = { 0.31, 0.65, 0.03, 1 },
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
        mui.newToast({
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

    mui.newRoundedRectButton({
        name = "newToast",
        text = "Show Toast",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(60),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(210),
        font = native.systemFont,
        textColor = { 1, 1, 1, 1 },
        fillColor = { 0.63, 0.81, 0.181 },
        radius = 10,
        callBack = showToast
    })

    -- create a drop down list
    local numOfRowsToShow = 3
    mui.newSelect({
        name = "selector_demo1",
        labelText = "Favorite Food",
        text = "Apple",
        font = native.systemFont,
        textColor = { 0.4, 0.4, 0.4 },
        fieldBackgroundColor = { 1, 1, 1, 1 },
        rowColor = { default={ 1, 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } }, -- default is the highlighting
        touchpointColor = { 0.4, 0.4, 0.4 }, -- the touchpoint color
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        strokeColor = { 0.4, 0.4, 0.4, 1 },
        strokeWidth = 2,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        listHeight = mui.getScaleVal(46) * numOfRowsToShow,
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(350),
        callBackTouch = mui.onRowTouchSelector,
        scrollListener = nil,
        list = { -- if 'key' use it for 'id' in the table row
            { key = "Row1", text = "Apple", value = "Apple", isCategory = false },
            { key = "Row2", text = "Cookie", value = "Cookie", isCategory = false },
            { key = "Row3", text = "Pizza", value = "Pizza", isCategory = false },
            { key = "Row4", text = "Shake", value = "Shake", isCategory = false },
            { key = "Row5", text = "Shake 2", value = "Shake 2", isCategory = false },
            { key = "Row6", text = "Shake 3", value = "Shake 3", isCategory = false },
            { key = "Row7", text = "Shake 4", value = "Shake 4", isCategory = false },
            { key = "Row8", text = "Shake 5", value = "Shake 5", isCategory = false },
            { key = "Row9", text = "Shake 6", value = "Shake 6", isCategory = false },
        },
    })

    -- horizontal slider (vertical in development)
    ---[[--
    mui.newSlider({
        name = "slider_demo",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(4),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(440),
        radius = mui.getScaleVal(12),
        colorOff = { 1, 1, 1, 1 },
        color = { 0.63, 0.81, 0.181 },
        startPercent = 30,
        callBackMove = mui.sliderCallBackMove,
        callBack = mui.sliderCallBack
    })
    mui.newSlider({
        name = "slider_demo2",
        width = mui.getScaleVal(200),
        height = mui.getScaleVal(4),
        x = mui.getScaleVal(160),
        y = mui.getScaleVal(490),
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

    mui.newTextField({
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

    mui.newTextField({
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
        scrollView = scrollView,
        isSecure = true
    })

    mui.newTextField({
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

    mui.newTextField({
        name = "textfield_demo5",
        labelText = "Numbers Only",
        text = "12345",
        font = native.systemFont,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        x = mui.getScaleVal(240),
        y = mui.getScaleVal(530),
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        scrollView = scrollView,
        inputType = "number"
    })

    mui.newTextBox({
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

    -- slide panel example, uses navbar's "menu" icon below
    local showSlidePanel2 = function(event)
        mui.newSlidePanel({
            name = "slidepanel-demo2",
            title = "MUI Demo", -- leave blank for no panel title text
            titleAlign = "center",
            font = native.systemFont,
            width = mui.getScaleVal(400),
            titleFontSize = mui.getScaleVal(30),
            titleFontColor = { 1, 1, 1, 1 },
            titleFont = native.systemFont,
            titleBackgroundColor = { 0.63, 0.81, 0.181 },
            fontSize = mui.getScaleVal(20),
            fillColor = { 1, 1, 1, 1 }, -- background color
            buttonToAnimate = "menu",
            callBack = nil,
            labelColor = { 0.3, 0.3, 0.3, 1 }, -- active
            labelColorOff = { 0.5, 0.5, 0.5, 1 }, -- non-active
            buttonHeight = mui.getScaleVal(60),
            buttonHighlightColor = { 0.5, 0.5, 0.5 },
            buttonHighlightColorAlpha = 0.5,
             touchpoint = true,
            list = {
                { key = "Home", value = "1", icon="home", labelText="Home", isActive = true },
                { key = "Newsroom", value = "2", icon="new_releases", labelText="News", isActive = false },
                { key = "Location", value = "3", icon="location_searching", labelText="Location Information", isActive = false },
                { key = "To-do", value = "4", icon="view_list", labelText="To-do", isActive = false },
            },
        })
        -- add some buttons to the menu!

    end

    -- put navbar on bottom. this is to stay on top of other widgets.
    -- supported widget types are : "RRectButton", "RectButton", "IconButton", "Slider", "TextField"
    mui.newNavbar({
        name = "navbar_demo",
        --width = mui.getScaleVal(500), -- defaults to display.contentWidth
        height = mui.getScaleVal(70),
        left = 0,
        top = 0,
        fillColor = { 0.63, 0.81, 0.181 },
        activeTextColor = { 1, 1, 1, 1 },
        padding = mui.getScaleVal(10),
    })
    mui.newIconButton({
        name = "menu",
        text = "menu",
        width = mui.getScaleVal(50),
        height = mui.getScaleVal(50),
        x = mui.getScaleVal(0),
        y = mui.getScaleVal(0),
        font = "MaterialIcons-Regular.ttf",
        textColor = { 1, 1, 1 },
        textAlign = "center",
        callBack = showSlidePanel2
    })
    mui.attachToNavBar( "navbar_demo", {
        widgetName = "menu",
        widgetType = "IconButton",
        align = "left",  -- left | right supported
    })
    mui.newIconButton({
        name = "refresh",
        text = "refresh",
        width = mui.getScaleVal(50),
        height = mui.getScaleVal(50),
        x = mui.getScaleVal(0),
        y = mui.getScaleVal(0),
        font = "MaterialIcons-Regular.ttf",
        textColor = { 1, 1, 1 },
        textAlign = "center",
        callBack = mui.actionForButton
    })
    mui.attachToNavBar( "navbar_demo", {
        widgetName = "refresh",
        widgetType = "IconButton",
        align = "left",  -- left | right supported
    })
    mui.newTextField({
        name = "textfield_nav",
        text = "",
        placeholder = "Search",
        font = native.systemFont,
        width = mui.getScaleVal(400),
        height = mui.getScaleVal(46),
        x = mui.getScaleVal(0),
        y = mui.getScaleVal(0),
        activeColor = { 1, 1, 1, 1 },
        inactiveColor = { 1, 1, 1, 0.8 },
        fillColor = { 0.63, 0.81, 0.181 },
        callBack = mui.textfieldCallBack
    })
    mui.attachToNavBar( "navbar_demo", {
        widgetName = "textfield_nav",
        widgetType = "TextField",
        align = "left",  -- left | right supported
    })
    mui.newIconButton({
        name = "help",
        text = "help",
        width = mui.getScaleVal(50),
        height = mui.getScaleVal(50),
        x = mui.getScaleVal(0),
        y = mui.getScaleVal(0),
        font = "MaterialIcons-Regular.ttf",
        textColor = { 1, 1, 1 },
        textAlign = "center",
        callBack = mui.actionForButton
    })
    mui.attachToNavBar( "navbar_demo", {
        widgetName = "help",
        widgetType = "IconButton",
        align = "right",  -- left | right supported
    })

    --
    -- create a Generic User-defined widget and attach to navbar
    --
    local textOptions =
    {
        --parent = textGroup,
        text = "Ready",
        x = 0,
        y = 0,
        font = native.systemFont,
        fontSize = mui.getScaleVal(40) * 0.55,
        align = "left"  --new alignment parameter
    }
    local demoText = display.newText( textOptions )
    demoText:setFillColor( unpack( {1, 1,1 ,1} ) )
    mui.attachToNavBar( "navbar_demo", {
        widgetName = "demoText",
        widgetType = "Generic",
        widgetObject = demoText,
        destroyCallBack = destroyDemoText, -- user supplied method, must be defined otherwise it will not free memory
        padding = mui.getScaleVal(20),
        align = "right",  -- left | right supported
    })

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

    mui.destroy()

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