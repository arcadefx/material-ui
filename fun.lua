-----------------------------------------------------------------------------------------
--
-- fun.lua
--
-----------------------------------------------------------------------------------------

-- corona
local composer = require( "composer" )
local widget = require( "widget" )

local mui = require( "materialui.mui" )

local scene = composer.newScene()

-- mui
local muiData = require( "materialui.mui-data" )

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

local background = nil
local scrollView = nil

local function destroyDemoText( demoText )
    mui.debug("destroyDemoText called")
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

    mui.init()

    -- Gather insets (function returns these in the order of top, left, bottom, right)
    local topInset, leftInset, bottomInset, rightInset = mui.getSafeAreaInsets()

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

    mui.newRoundedRectButton({
        name = "goBack",
        text = "Go Back",
        width = 100,
        height = 30,
        x = 80,
        y = 70,
        font = native.systemFont,
        fillColor = { 0.31, 0.65, 0.03, 1 },
        textColor = { 1, 1, 1 },
        iconText = "arrow_back",
        iconFont = mui.materialFont,
        iconFontColor = { 1, 1, 1, 1 },
        -- iconImage = "1484026171_02.png",
        callBack = mui.actionSwitchScene,
        callBackData = {
            sceneDestination = "menu",
            sceneTransitionColor = { 0, 0.73, 1 },
            sceneTransitionAnimation = true
        } -- scene menu.lua
    })

    -- show a "toast" message, yes I said toast like HTML 5 Toast
    -- recommend 40 percent ratio for one liners (20 radius/50 height = 0.40)
    local showToast = function()
        mui.newToast({
            name = "toast_demo",
            text = "New Messages!",
            radius = 20,
            width = 150,
            height = 30,
            font = native.systemFont,
            fontSize = 18,
            fillColor = { 0, 0, 0, 1 },
            textColor = { 1, 1, 1, 1 },
            top = 40 + muiData.safeAreaInsets.topInset,
            easingIn = 500,
            easingOut = 500,
            callBack = mui.actionForButton
        })
    end

    mui.newRoundedRectButton({
        name = "newToast",
        text = "Show Toast",
        width = 100,
        height = 30,
        x = 80,
        y = 110,
        font = native.systemFont,
        textColor = { 1, 1, 1, 1 },
        fillColor = { 0.63, 0.81, 0.181 },
        radius = 10,
        callBack = showToast
    })

    mui.newTextField({
        name = "textfield_demo4",
        labelText = "My Topic",
        text = "Hello, World!",
        font = native.systemFont,
        width = 200,
        height = 30,
        x = 130,
        y = 190,
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack
    })

    -- horizontal slider (vertical in development)
    ---[[--
    mui.newSlider({
        name = "slider_demo",
        width = 200,
        height = 2,
        x = 130,
        y = 260,
        radius = 12,
        colorOff = { 1, 1, 1, 1 },
        color = { 0.63, 0.81, 0.181 },
        startPercent = 30,
        callBackMove = mui.sliderCallBackMove,
        callBack = mui.sliderCallBack
    })

    mui.newSlider({
        name = "slider_demo2",
        width = 200,
        height = 2,
        x = 130,
        y = 300,
        radius = 12,
        colorOff = { 1, 1, 1, 1 },
        color = { 0.31, 0.65, 0.03, 1 },
        startPercent = 60,
        callBackMove = mui.sliderCallBackMove,
        callBack = mui.sliderCallBack
    })
    --]]--

    -- Create the widget
    ---[[--
    local scrollWidth = muiData.safeAreaWidth * 0.5
    scrollView = widget.newScrollView(
        {
            top = 15,
            left = (muiData.safeAreaWidth - scrollWidth),
            width = scrollWidth,
            height = muiData.safeAreaHeight - 50,
            scrollWidth = scrollWidth,
            scrollHeight = (muiData.safeAreaHeight * 2),
            listener = scrollAListener
        }
    )

    mui.newTextField({
        name = "textfield_demo2",
        labelText = "Subject",
        text = "Hello, world!",
        font = native.systemFont,
        width = 200,
        height = 30,
        x = 120,
        y = 80,
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        scrollView = scrollView
    })

    mui.newTextField({
        name = "textfield_demo3",
        labelText = "Tweet",
        text = "Scroll away",
        font = native.systemFont,
        width = 200,
        height = 30,
        x = 120,
        y = 160,
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        scrollView = scrollView,
        isSecure = true
    })

    -- create a drop down list
    local numOfRowsToShow = 3
    mui.newSelect({
        name = "selector_demo2",
        labelText = "Favorite Food",
        text = "Apple",
        font = native.systemFont,
        textColor = { 0.4, 0.4, 0.4 },
        fieldBackgroundColor = { 1, 1, 1, 1 },
        rowColor = { default={ 1, 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } }, -- default is the highlighting
        rowBackgroundColor = { 1, 1, 1, 1 }, -- the drop down color of each row
        touchpointColor = { 0.4, 0.4, 0.4 }, -- the touchpoint color
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        strokeColor = { 0.4, 0.4, 0.4, 1 },
        strokeWidth = 2,
        width = 200,
        height = 30,
        listHeight = 30 * numOfRowsToShow,
        x = 120,
        y = 240,
        callBackTouch = mui.onRowTouchSelector,
        scrollListener = nil,
        list = { -- if 'key' use it for 'id' in the table row
            { key = "Row1", text = "Apple", value = "Apple", isCategory = false, backgroundColor = {1,1,1,1} },
            { key = "Row2", text = "Cookie", value = "Cookie", isCategory = false },
            { key = "Row3", text = "Pizza", value = "Pizza", isCategory = false },
            { key = "Row4", text = "Shake", value = "Shake", isCategory = false },
            { key = "Row5", text = "Shake 2", value = "Shake 2", isCategory = false },
            { key = "Row6", text = "Shake 3", value = "Shake 3", isCategory = false },
            { key = "Row7", text = "Shake 4", value = "Shake 4", isCategory = false },
            { key = "Row8", text = "Shake 5", value = "Shake 5", isCategory = false },
            { key = "Row9", text = "Shake 6", value = "Shake 6", isCategory = false },
        },
        scrollView = scrollView,
    })

    --[[--
    local newlist = {}
    newlist = {
        { key = "Row1", text = "Dog", value = "Puggle", isCategory = false},
        { key = "Row2", text = "Cat", value = "Tabby", isCategory = false },
        { key = "Row3", text = "Dinosaur", value = "Raptor", isCategory = false },
    }
    mui.setSelectorList("selector_demo2", newlist)
    --]]--

    mui.newTextBox({
        name = "textbox_demo1",
        labelText = "Secret Text Box",
        text = "I am hidden in view\nYes, me too!\nFood\nDrink\nDesert\n1\n2\n3\n4\n5",
        font = native.systemFont,
        fontSize = 16,
        textBoxFontSize = 16,
        width = 200,
        height = 100,
        x = 120,
        y = 355,
        trimFakeTextAt = 80, -- trim at 1..79 characters.
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        isEditable = true,
        doneButton = {
            width = 100,
            height = 30,
            fillColor = { 0.25, 0.75, 1, 1 },
            textColor = { 1, 1, 1 },
            text = "done",
            iconText = "done",
            iconFont = mui.materialFont,
            iconFontColor = { 1, 1, 1, 1 },
            radius = mui.getScaleX(8), -- set to 0 for newRectButton() instead of rounded
        },
        overlayBackgroundColor = { 1, 1, 1, 1 },
        overlayTextBoxBackgroundColor = { .9, .9, .9, 1 },
        overlayTextBoxHeight = 100,
        scrollView = scrollView
    })

    -- mui.setTextBoxValue("textbox_demo1", "toys in store")
    --[[--

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

    --]]--

    local textOptions =
    {
        --parent = textGroup,
        text = "Scroll the above",
        width = 150,
        font = native.systemFont,
        fontSize = 16,
        align = "left"  --new alignment parameter
    }
    infoText = display.newText( textOptions )
    infoText:setFillColor( 0.4, 0.4, 0.4 )
    infoText.x = scrollView.x + (scrollView.contentWidth * .1)
    infoText.y = muiData.safeAreaHeight - infoText.contentHeight * .5

    -- slide panel example
    local hideSlidePanel = function(event)
        mui.debug("home button pushed")
        -- or use close method below to close and release slider from memory
        -- mui.closeSlidePanel("slidepanel-demo")
        mui.hideSlidePanel("slidepanel-demo2")
    end

    -- slide panel example, uses navbar's "menu" icon below
    local showSlidePanel2 = function(event)
        mui.newSlidePanel({
            name = "slidepanel-demo2",
            title = "MUI Demo", -- leave blank for no panel title text
            titleAlign = "center",
            font = native.systemFont,
            width = 250,
            titleFontSize = 18,
            titleFontColor = { 1, 1, 1, 1 },
            titleFont = native.systemFont,
            titleBackgroundColor = { 0.63, 0.81, 0.181 },
            fontSize = 18,
            fillColor = { 1, 1, 1, 1 }, -- background color
            buttonToAnimate = "menu",
            callBack = nil,
            labelColor = { 0.63, 0.81, 0.181 }, -- active
            labelColorOff = { 0.5, 0.5, 0.5, 1 }, -- non-active
            buttonHeight = 36, -- fontSize * 2
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
    end

    -- put navbar on bottom. this is to stay on top of other widgets.
    -- supported widget types are : "RRectButton", "RectButton", "IconButton", "Slider", "TextField"
    mui.newNavbar({
        name = "navbar_demo",
        --width = mui.getScaleVal(500), -- defaults to display.contentWidth
        height = 40,
        left = 0,
        top = 0,
        fillColor = { 0.63, 0.81, 0.181 },
        activeTextColor = { 1, 1, 1, 1 },
        padding = 5,
    })
    mui.newIconButton({
        name = "menu",
        text = "menu",
        width = 25,
        height = 25,
        x = 0,
        y = 0,
        font = mui.materialFont,
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
        width = 25,
        height = 25,
        x = 0,
        y = 0,
        font = mui.materialFont,
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
        width = 200,
        height = 30,
        x = 0,
        y = 0,
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
        width = 25,
        height = 25,
        x = 0,
        y = 0,
        font = mui.materialFont,
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
        fontSize = 18,
        align = "left"  --new alignment parameter
    }
    local demoText = display.newText( textOptions )
    demoText:setFillColor( unpack( {1, 1,1 ,1} ) )
    mui.attachToNavBar( "navbar_demo", {
        widgetName = "demoText",
        widgetType = "Generic",
        widgetObject = demoText,
        destroyCallBack = destroyDemoText, -- user supplied method, must be defined otherwise it will not free memory
        padding = 12,
        align = "right",  -- left | right supported
    })

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
        mui.removeFocus()
        -- mui.debug( "Scroll view was released" )
    end

    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then mui.debug( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then mui.debug( "Reached top limit" )
        elseif ( event.direction == "left" ) then mui.debug( "Reached right limit" )
        elseif ( event.direction == "right" ) then mui.debug( "Reached left limit" )
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
        -- mui.actionSwitchScene({callBackData={sceneDestination="menu"}})

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

    if scrollView ~= nil then
        scrollView:removeSelf()
        scrollView = nil
    end

    if background ~= nil then
        background:removeSelf()
        background = nil
    end

    if infoText ~= nil then
        infoText:removeSelf()
        infoText = nil
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