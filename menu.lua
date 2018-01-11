-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local mui = require( "materialui.mui" )

local scene = composer.newScene()

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

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

    mui.init(nil, { parent=self.view })

    -- Gather insets (function returns these in the order of top, left, bottom, right)
    local topInset, leftInset, bottomInset, rightInset = mui.getSafeAreaInsets()
    -- Create a vector rectangle sized exactly to the "safe area"
    background = display.newRect(
        display.screenOriginX + leftInset, 
        display.screenOriginY + topInset, 
        display.viewableContentWidth - ( leftInset + rightInset ), 
        display.viewableContentHeight - ( topInset + bottomInset )
    )
    background:setFillColor( 1 )
    background:translate( background.contentWidth*0.5, background.contentHeight*0.5 )
    sceneGroup:insert( background )

    mui.newIconButton({
        parent = mui.getParent(),
        name = "plus",
        text = "help",
        width = 25,
        height = 25,
        x = 30,
        y = 30,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 0.25, 0.75, 1, 1 },
        callBack = mui.actionSwitchScene,
        callBackData = {
            sceneDestination = "onboard",
            sceneTransitionColor = { 0.08, 0.9, 0.31 }
        } -- scene fun.lua
        -- callBack = mui.actionForPlus
    })

    -- radio button group example
    mui.newRadioGroup({
        parent = mui.getParent(),
        name = "radio_demo",
        width = 18,
        height = 18,
        x = 60,
        y = 30,
        layout = "horizontal",
        labelFont = native.systemFont,
        textColor = { 0, 0, 0 },
        labelColor = { 0, 0, 0 },
        callBack = mui.actionForRadioButton,
        list = {
            { key = "Cookie", value = "1", isChecked = false },
            { key = "Fruit Snack", value = "2", isChecked = false },
            { key = "Grape", value = "3", isChecked = true }
        }
    })

    mui.newRectButton({
        parent = mui.getParent(),
        name = "switchSceneButton",
        text = "Go Scene",
        width = 100,
        height = 30,
        x = 70,
        y = 80,
        font = native.systemFont,
        fontSize = 16,
        fillColor = { 0.25, 0.75, 1, 1 },
        textColor = { 1, 1, 1 },
        iconText = "picture_in_picture",
        iconFont = mui.materialFont,
        iconFontColor = { 1, 1, 1, 1 },
        --iconImage = "1484026171_02.png",
        touchpoint = true,
        callBack = mui.actionSwitchScene,
        callBackData = {
            sceneDestination = "fun",
            sceneTransitionColor = { 0, 0.73, 1 },
            sceneTransitionAnimation = true
        } -- scene fun.lua
    })


    -- dialog box example
    -- use mui.getWidgetBaseObject("dialog_demo") to get surface to add more content
    local showDialog = function(e)
        local muiTargetValue = mui.getEventParameter(e, "muiTargetValue")
        local muiTargetCallBackData = mui.getEventParameter(e, "muiTargetCallBackData")
        mui.debug("data passed: "..muiTargetCallBackData.food)
            mui.newDialog({
            name = "dialog_demo",
            width = 350,
            height = 200,
            text = "Do you want to continue?",
            textX = 0,
            textY = 0,
            textColor = { 0, 0, 0, 1 },
            font = native.systemFont,
            fontSize = 18,
            fillColor = { 1, 1, 1, 1 },
            gradientBorderShadowColor1 = { 1, 1, 1, 0.4 },
            gradientBorderShadowColor2 = { 0, 0, 0, 0.4 },
            easing = easing.inOutCubic, -- this is default if omitted
            buttons = {
                font = native.systemFont,
                okayButton = {
                    text = "Okay",
                    textColor = { 0, 0.46, 1 },
                    fillColor = { 1, 1, 1 },
                    width = 100,
                    height = 35,
                    callBackOkay = mui.actionForOkayDialog,
                    clickAnimation = {
                        fillColor = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                },
                cancelButton = {
                    text = "Cancel",
                    textColor = { 0, 0.46, 1 },
                    fillColor = { 1, 1, 1 },
                    width = 100,
                    height = 35,
                    clickAnimation = {
                        fillColor = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                }
            }
        })
    end

    --[[--
    -- below is a rounded button with a shadow from put Corona no static image
    mui.newRoundedRectButton({
        name = "newDialog",
        text = "Open Dialog",
        width = 100,
        height = 30,
        x = 70,
        y = 130,
        font = native.systemFont,
        fontSize = 16,
        gradientShadowColor1 = { 0.9, 0.9, 0.9, 255 },
        gradientShadowColor2 = { 0.9, 0.9, 0.9, 0 },
        gradientDirection = "up",
        textColor = { 1, 1, 1 },
        radius = 10,
        callBack = showDialog,
        callBackData = {food="cookie"}, -- demo passing data to an event
    })
    --]]--

    -- below is a rounded button with static image with two states (off/on)
    -- tap or click and "hold" to see shadow and release to see it fade to original image
    ---[[--
    mui.newRoundedRectButton({
        parent = mui.getParent(),
        name = "newDialog",
        text = "Open Dialog",
        width = 150,
        height = 40,
        x = 70,
        y = 130,
        font = native.systemFont,
        gradientShadowColor1 = { 0.9, 0.9, 0.9, 255 },
        gradientShadowColor2 = { 0.9, 0.9, 0.9, 0 },
        gradientDirection = "up",
        textColor = { 1, 1, 1 },
        radius = 10,
        callBack = showDialog,
        callBackData = {food="cookie"}, -- demo passing data to an event
        image = {
            src = "button-sheet-demo@2x.png", -- source image file
            -- Below is optional if you have buttons on a sheet
            -- The 'sheetOptions' is directly from Corona sheets
            sheetIndex = 1, -- which frame to show for image from sheet
            touchIndex = 2, -- which frame to show for touch event
            touchFadeAnimation = true, -- helpful with shadows
            touchFadeAnimationSpeedOut = 500,
            sheetOptions = {
                -- The params below are required by Corona

                width = 252,
                height = 98,
                numFrames = 2,

                -- The params below are optional (used for dynamic image sheet selection)

                sheetContentWidth = 504,  -- width of original 1x size of entire sheet
                sheetContentHeight = 98  -- height of original 1x size of entire sheet

            }
        }
    })
    --]]--

    -- checkbox example
    mui.newCheckBox({
        parent = mui.getParent(),
        name = "check",
        text = "check_box_outline_blank",
        width = 25,
        height = 25,
        x = 180,
        y = 80,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 0.3, 0.3, 0.3 },
        textAlign = "center",
        value = 500,
        callBack = mui.actionForCheckbox
    })

    -- toggle switch example
    mui.newToggleSwitch({
        parent = mui.getParent(),
        name = "switch_demo",
        size = 40,
        x = 175,
        y = 125,
        textColorOff = { 0.57, 0.85, 1, 1 },
        textColor = { 0.25, 0.75, 1, 1 },
        backgroundColor = { 0.74, 0.88, 0.99, 1 },
        backgroundColorOff = { 0.82, 0.95, 0.98, 1 },
        isChecked = true,
        value = 100, -- if switch is in the on position it's 100 else nil
        callBack = mui.actionForSwitch
    })

    -- get widget and change the color of the text
    local widgetData = mui.getWidgetProperty( "switchSceneButton", "text" )
    if widgetData ~= nil then
        widgetData:setFillColor( 1, 1 ,1 ,1 )
    end
    -- get widget and change the color of the layer that sits beneath text
    widgetData = mui.getWidgetProperty( "switchSceneButton", "layer_1" )
    if widgetData ~= nil then
        widgetData:setFillColor( 0.25, 0.75, 1, 1 )
    end

    -- date picker example
    local showDatePicker = function(event)
        mui.newDatePicker({
            parent = mui.getParent(),
            name = "datepicker-demo",
            font = native.systemFont,
            fontSize = 18,
            width = 300,
            height = 200,
            fontColor = { 0.7, 0.7, 0.7, 1 }, -- non-select items
            fontColorSelected = { 0, 0, 0, 1 }, -- selected items
            columnColor = { 1, 1, 1, 1 }, -- background color for columns
            strokeColor = { 0.25, 0.75, 1, 1 }, -- the border color around widget
            gradientBorderShadowColor1 = { 1, 1, 1, 0.2 },
            gradientBorderShadowColor2 = { 1, 1, 1, 1 },
            fromYear = 1969,
            toYear = 2020,
            startMonth = 11,
            startDay = 15,
            startYear = 2015,
            cancelButtonText = "Cancel",
            cancelButtonTextColor = { 1, 1, 1, 1 },
            cancelButtonFillColor = { 0.25, 0.75, 1, 1 },
            submitButtonText = "Set",
            submitButtonFillColor = { 0.25, 0.75, 1, 1 },
            submitButtonTextColor = { 1, 1, 1, 1 },
            callBack = mui.datePickerCallBack,
        })
    end
    mui.newCircleButton({
        parent = mui.getParent(),
        name = "alice-button",
        text = "date_range",
        radius = 30,
        x = 260,
        y = 80,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 1, 1, 1, 1 },
        fillColor = { 0.25, 0.75, 1, 1 },
        callBack = showDatePicker -- do not like wheel picker on native device.
    })

    -- time picker example
    local showTimePicker = function(event)
        mui.newTimePicker({
            parent = mui.getParent(),
            name = "timepicker-demo",
            font = native.systemFont,
            width = 300,
            height = 200,
            fontSize = 18,
            fontColor = { 0.7, 0.7, 0.7, 1 }, -- non-select items
            fontColorSelected = { 0, 0, 0, 1 }, -- selected items
            columnColor = { 1, 1, 1, 1 }, -- background color for columns
            strokeColor = { 0.25, 0.75, 1, 1 }, -- the border color around widget
            gradientBorderShadowColor1 = { 1, 1, 1, 0.2 },
            gradientBorderShadowColor2 = { 1, 1, 1, 1 },
            startHour = 11,
            startMinute = 15,
            startAMPM = "am",
            cancelButtonText = "Cancel",
            cancelButtonTextColor = { 1, 1, 1, 1 },
            cancelButtonFillColor = { 0.25, 0.75, 1, 1 },
            submitButtonText = "Set",
            submitButtonFillColor = { 0.25, 0.75, 1, 1 },
            submitButtonTextColor = { 1, 1, 1, 1 },
            callBack = mui.timePickerCallBack,
        })
    end
    mui.newCircleButton({
        parent = mui.getParent(),
        name = "bueler-button",
        text = "access_time",
        radius = 30,
        x = 260,
        y = 130,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 1, 1, 1, 1 },
        fillColor = { 0, 0.46, 1 },
        textAlign = "center",
        callBack = showTimePicker -- do not like wheel picker on native device.
    })

    -- tile widget example
    mui.newCircleButton({
        parent = mui.getParent(),
        name = "tile-button",
        text = "view_list",
        radius = 30,
        x = 260,
        y = 180,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 1, 1, 1, 1 },
        fillColor = { 0.25, 0.75, 1, 1 },
        callBack = mui.actionSwitchScene, -- do not like wheel picker on native device.
        callBackData = {
            sceneDestination = "tile",
            sceneTransitionColor = { 0, 0.73, 1 }
        } -- scene tile.lua
    })


    -- Demo of how to switch scenes and avoid using the built-in animated switching.
    local switchToDemoMoreScene = function(event)
        mui.setSceneToSwitchToAfterDestroy( "fun" )
        composer.removeScene( mui.getCurrentScene() )
    end

    -- slide panel example
    local hideSlidePanel = function(event)
        mui.debug("home button pushed")
        -- or use close method below to close and release slider from memory
        -- mui.closeSlidePanel("slidepanel-demo")
        mui.hideSlidePanel("slidepanel-demo")
    end

    local showSlidePanel = function(event)
        if mui.getWidgetBaseObject("slidepanel-demo") ~= nil then
            mui.showSlidePanel("slidepanel-demo")
            mui.debug("slidePanel exists, show it")
        else
            mui.debug("slidePanel is new")
            mui.newSlidePanel({
                parent = mui.getParent(),
                name = "slidepanel-demo",
                title = "MUI Demo", -- leave blank for no panel title text
                titleAlign = "center",
                font = native.systemFont,
                width = 300,
                titleFontSize = 20,
                titleFontColor = { 1, 1, 1, 1 },
                titleFont = native.systemFont,
                titleBackgroundColor = { 0.25, 0.75, 1, 1 },
                fontSize = 18,
                fillColor = { 1, 1, 1, 1 }, -- background color
                headerImage = "creative-blue-abstract-background-header-4803_0.jpg",
                buttonToAnimate = "slidepanel-button",
                callBack = mui.actionForSlidePanel,
                callBackData = {
                    item = "cake"
                },
                labelColor = { 0.3, 0.3, 0.3, 1 }, -- active
                labelColorOff = { 0.5, 0.5, 0.5, 1 }, -- non-active
                buttonHeight = 36,  -- fontSize * 2
                buttonHighlightColor = { 0.5, 0.5, 0.5 },
                buttonHighlightColorAlpha = 0.5,
                lineSeparatorHeight = 1,
                list = {
                    { key = "Home", value = "1", icon="home", iconImage="1484022678_go-home.png", labelText="Home", isActive = false, callBack = hideSlidePanel },
                    { key = "Newsroom", value = "2", icon="new_releases", iconImage="1484026171_02.png", labelText="News", isActive = true },
                    { key = "Location", value = "3", icon="location_searching", labelText="Location Information", isActive = false, iconColor = { 1, 0, 0, 1 }, iconColorOff = { 0.26, 0.52, 0.96, 1 } },
                    { key = "To-do", value = "4", icon="view_list", labelText="To-do", isActive = false, iconColor = { 1, 0, 0, 1 }, iconColorOff = { 0.92, 0.26, 0.21, 1 } },
                    { key = "LineSeparator" },
                    { key = "Onboard Demo", value = "Onboard Demo", icon="view_list", labelText="Onboard Demo", isActive = false, callBack = mui.actionSwitchScene, callBackData = { sceneDestination = "onboard", sceneTransitionColor = { 0.08, 0.9, 0.31 } } },
                    { key = "Tile Demo", value = "Tile Demo", icon="view_list", labelText="Tile Demo", isActive = false, callBack = mui.actionSwitchScene, callBackData = { sceneDestination = "tile", sceneTransitionColor = { 0, 0.73, 1 } } },
                    { key = "Demo More Widgets", value = "Demo More Widgets", icon="view_list", labelText="Demo More Widgets", isActive = false, callBack = switchToDemoMoreScene },
                    { key = "To-do 4", value = "To-do 4", icon="view_list", labelText="To-do 4", isActive = false },
                    { key = "To-do 5", value = "To-do 5", icon="view_list", labelText="To-do 5", isActive = false },
                    { key = "LineSeparator" },
                    { key = "To-do 6", value = "To-do 6", icon="view_list", labelText="To-do 6", isActive = false },
                    { key = "To-do 7", value = "To-do 7", icon="view_list", labelText="To-do 7", isActive = false },
                    { key = "To-do 8", value = "To-do 8", icon="view_list", labelText="To-do 8", isActive = false },
                    { key = "To-do 9", value = "To-do 9", icon="view_list", labelText="To-do 9", isActive = false },
                    { key = "To-do 10", value = "To-do 10", icon="view_list", labelText="To-do 10", isActive = false },
                    { key = "LineSeparator" },
                    { key = "To-do 11", value = "To-do 11", icon="view_list", labelText="To-do 11", isActive = false },
                    { key = "To-do 12", value = "To-do 12", icon="view_list", labelText="To-do 12", isActive = false },
                },
                isVisible = false, -- do show immediately but create the menu
            })
        end
        -- add some buttons to the menu!
    end

    mui.newCircleButton({
        parent = mui.getParent(),
        name = "slidepanel-button",
        text = "menu",
        radius = 30,
        x = 260,
        y = 230,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 1, 1, 1, 1 },
        fillColor = { 0, 0.46, 1 },
        textAlign = "center",
        callBack = showSlidePanel -- do not like wheel picker on native device.
    })

    -- SnackBar example
    local function showSnackBar( ... )
        mui.newSnackBar({
            parent = mui.getParent(),
            name = "snackbar_demo1",
            text = "Updated Demo",
            radius = 10,
            width = 220,
            height = 40,
            font = native.systemFont,
            fontSize = 18,
            fillColor = { 0, 0, 0, 1 },
            textColor = { 1, 1, 1, 1 },
            bottom = 80,
            easingIn = 1000,
            easingOut = 1000,
            timeOut = 3000,
            buttonFont = native.systemFontBold,
            buttonText = "UNDO",
            buttonTextColor = { 1, 0.23, 0.5, 1 },
            callBack = mui.actionForButton
        })
    end

    mui.newIconButton({
        parent = mui.getParent(),
        name = "snackbar_button",
        text = "local_cafe",
        width = 30,
        height = 30,
        x = muiData.safeAreaWidth - 150,
        y = 200,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 0, 0, 0, 1 },
        fillColor = { 0, 0.46, 1 },
        textAlign = "center",
        callBack = showSnackBar
    })

    local function showPopover( ... )
        local button = mui.getWidgetBaseObject( "vertical-menu-button" )

        mui.newPopover({
            parent = mui.getParent(),
            name = "popovermenu_demo1",
            font = native.systemFont,
            textColor = { 0.4, 0.4, 0.4 },
            backgroundColor = {0.94,0.94,0.94,1},
            touchpointColor = { 0.4, 0.4, 0.4 }, -- the touchpoint color
            activeColor = { 0.12, 0.67, 0.27, 1 },
            inactiveColor = { 0.8, 0.8, 0.8, 1 },
            strokeColor = { 0.8, 0.8, 0.8, 1 },
            strokeWidth = 0,
            leftMargin = 10,
            width = 200,
            height = 18,
            listHeight = 18 * 4,
            x = button.x - (200 * 0.55),
            y = button.y - button.contentHeight,
            callBackTouch = mui.onRowTouchPopover,
            list = { -- if 'key' use it for 'id' in the table row
                { key = "Row1", text = "Popover Item 1", value = "Popover Item 1", },
                { key = "Row2", text = "Popover Item 2", value = "Popover Item 2", },
                { key = "Row3", text = "Popover Item 3", value = "Popover Item 3", },
                { key = "Row4", text = "Popover Item 4", value = "Popover Item 4", },
            },
        })
    end

    mui.newIconButton({
        parent = mui.getParent(),
        name = "vertical-menu-button",
        text = "more_vert",
        width = 30,
        height = 30,
        x = muiData.safeAreaWidth - 50,
        y = 200,
        isFontIcon = true,
        font = mui.materialFont,
        textColor = { 0, 0, 0, 1 },
        fillColor = { 0, 0.46, 1 },
        textAlign = "center",
        callBack = showPopover
    })

    ---[[--
    mui.newTableView({
        parent = mui.getParent(),
        name = "tableview_demo",
        width = 180,
        height = 100,
        top = 10,
        left = muiData.safeAreaWidth - 190,
        font = native.systemFont,
        fontSize = 8,
        textColor = { 0, 0, 0, 1 },
        lineColor = { 1, 1, 1, 1 },
        lineHeight = 2,
        rowColor = {1, 1, 1, 1}, --{ default={1,1,1}, over={1,0.5,0,0.2} },
        rowHeight = 20,
        -- rowAnimation = false, -- turn on rowAnimation
        noLines = false,
        callBackTouch = mui.onRowTouchDemo,
        callBackRender = mui.onRowRenderDemo,
        scrollListener = mui.scrollListener,  -- needed if using buttons, etc within the row!
        list = { -- if 'key' use it for 'id' in the table row
            { key = "Row1", text = "Row 1", value = "1", isCategory = false, valign = "middle" },
            { key = "Row2", text = "Row 2", value = "2", isCategory = false, valign = "middle" },
            { key = "Row3", text = "Row 3", value = "3", isCategory = false, valign = "middle" },
            { key = "Row4", text = "Row 4", value = "4", isCategory = false },
            { key = "Row5", text = "Row 5", value = "5", fontSize = 8, isCategory = false, columns = {
                    { text = "Row 5C1", value = "5A", align = "left", valign = "top" },
                    { text = "Row 5C2", value = "5B", align = "left", valign = "middle" },
                    { text = "Row 5C3", value = "5C", align = "left", valign = "bottom" },
                },
            },
            { key = "Row6", text = "Row 6", value = "6", fontSize = 8, isCategory = false, columns = {
                    { text = "Row 6 Col 1", value = "6A", align = "center" },
                    { text = "Row 6 Col 2", value = "6B", align = "center" },
                    { text = "Row 6 Col 3", value = "6C", align = "center" },
                },
            },
            { key = "Row7", text = "Row 7", value = "7", fontSize = 8, isCategory = false, columns = {
                    { text = "Row 7 Col 1", value = "7A", align = "right" },
                    { text = "Row 7 Col 2", value = "7B", align = "right" },
                    { text = "Row 7 Col 3", value = "7C", align = "right" },
                },
            },
            { key = "Row8", text = "Row 8", value = "8", isCategory = false, fillColor = { 0, 0, 1, 0.2 }, valign = "top" },
            -- below are rows with different colors
            -- set "noLines" to true above to omit line border
            -- { key = "Row5", text = "Row 5", value = "5", isCategory = false, fillColor = { 0.67, 0.98, 0.65, 0.2 } },
            -- { key = "Row6", text = "Row 6", value = "6", isCategory = false, fillColor = { 1, 0, 0, 0.2 }  },
        },
        columnOptions = {
            widths = { 60, 60, 60 }, -- must supply each else "auto" is assumed.
        },
        categoryColor = { default={0.8,0.8,0.8,0.8} },
        categoryLineColor = { 1, 1, 1, 0 },
        touchpointColor = { 0.4, 0.4, 0.4 },
    })
    --]]--

    mui.newTextField({
        parent = mui.getParent(),
        name = "textfield_demo",
        labelText = "Subject",
        text = "Hello, world!",
        font = native.systemFont,
        width = 200,
        height = 24,
        x = 120,
        y = 190,
        trimAtLength = 30,
        activeColor = { 0, 0, 0, 1 },
        inactiveColor = { 0.5, 0.5, 0.5, 1 },
        callBack = mui.textfieldCallBack
    })

    mui.newTextField({
        parent = mui.getParent(),
        name = "textfield_demo_with_placeholder",
        labelText = "Test Placeholder",
        placeholder = "You see me when text is empty",
        text = "",
        font = native.systemFont,
        width = 200,
        height = 24,
        x = 120,
        y = 250,
        activeColor = { 0, 0, 0, 1 },
        inactiveColor = { 0.5, 0.5, 0.5, 1 },
        callBack = mui.textfieldCallBack
    })

    -- create and animate the intial value (1% is always required due to scaling method)
    mui.newProgressBar({
        parent = mui.getParent(),
        name = "progressbar_demo",
        width = 150,
        height = 4,
        x = muiData.safeAreaWidth - 180,
        y = 160,
        foregroundColor = { 0, 0.78, 1, 1 },
        backgroundColor = { 0.82, 0.95, 0.98, 0.8 },
        startPercent = 20,
        barType = "determinate",
        iterations = 1,
        labelText = "Determinate progress",
        labelFont = native.systemFont,
        labelFontSize = 14,
        labelColor = {  0.4, 0.4, 0.4, 1 },
        labelAlign = "left",
        callBack = mui.postProgressCallBack,
        --repeatCallBack = <your method here>,
        hideBackdropWhenDone = false
    })

    -- show how to increase progress bar by percent using a timer or method after the above creation
    local function increaseMyProgressBar()
        mui.debug("increaseMyProgressBar")
        mui.increaseProgressBar( "progressbar_demo", 80 )
    end
    timer.performWithDelay(3000, increaseMyProgressBar, 1)
    -- increaseMyProgressBar() -- will be queued if already processing an increase

    -- on bottom and stay on top of other widgets.
    ---[[--
    local buttonHeight = 40
    mui.newToolbar({
        parent = mui.getParent(),
        name = "toolbar_demo",
        height = buttonHeight,
        buttonHeight = buttonHeight,
        x = 0,
        y = (muiData.safeAreaHeight - (buttonHeight * 0.5)),
        layout = "horizontal",
        labelFont = native.systemFont,
        color = { 0, 0.46, 1, 1 },
        fillColor = { 0, 0.46, 1, 1 },
        labelColor = { 1, 1, 1 },
        labelColorOff = { 0, 0, 0 },
        callBack = mui.actionForToolbarDemo,
        sliderColor = { 1, 1, 1 },
        list = {
            -- note use iconImage="<filename of jpg/png>" for custom graphic icons
            { key = "Home", value = "1", icon="home", labelText="Home", isActive = true, iconColor = { 1, 1, 1 }, iconColorOff = { 0,0,0,1 } },
            { key = "Newsroom", value = "2", icon="new_releases", labelText="News", isActive = false, iconColor = { 1, 1, 1 }, iconColorOff = { 0,0,0,1 } },
            { key = "Location", value = "3", icon="location_searching", labelText="Location", isActive = false },
            { key = "To-do", value = "4", icon="view_list", labelText="To-do", isActive = false },
            -- { key = "Viewer", value = "4", labelText="View", isActive = false } -- uncomment to see View as text
        }
    })
    --]]--

    showSlidePanel() -- create but do not show panel demo

    --local bTest = mui.getChildWidgetProperty("toolbar_demo", "text", 1)
    --bTest:setFillColor(1, 0, 0, 1)

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
        -- mui.actionSwitchScene({callBackData={sceneDestination="fun"}})
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
