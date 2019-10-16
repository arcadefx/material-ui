--[[
A loosely based Material UI module

mui-base.lua : The base module all other modules include.

The MIT License (MIT)

Copyright (C) 2016 Anedix Technologies, Inc. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

For other software and binaries included in this module see their licenses.
The license and the software must remain in full when copying or distributing.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]

-- corona
local composer = require( "composer" )
local widget = require( "widget" )

-- mui
local muiData = require( "materialui.mui-data" )
local materialFontCodePoints = require( "materialui.codepoints" )
local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs
-- local utf8 = require( "plugin.utf8" )
local MySceneName = nil

local M = {} -- for module array/table

local string_char = string.char
local utf8v1 = function(cp)
    if cp < 128 then
        return string_char(cp)
    end
    local s = ""
    local prefix_max = 32
    while true do
        local suffix = cp % 64
        s = string_char(128 + suffix)..s
        cp = (cp - suffix) / 64
        if cp < prefix_max then
            return string_char((256 - (2 * prefix_max)) + cp)..s
        end
        prefix_max = prefix_max / 2
    end
end

local function updateTheShadows( e )
    if muiData.shadowShapeDict == nil then return end
    for k,v in pairs(muiData.shadowShapeDict) do
        -- remove object etc from group and re-create!
        v.snapshot:removeSelf()
        local x = M.newShadowShape(v.shape, v.options, v.group)
        --v:invalidate()
    end
end

local function onSystemEvent( event )
    if ( event.type == "applicationExit" ) then
        --save_state()

    elseif ( event.type == "applicationOpen" ) then
        --load_saved_state()

    elseif ( event.type == "applicationResume" ) then
        timer.performWithDelay(500, function() updateTheShadows() end, 1)

    elseif (event.type == "applicationSuspend") then
        --pause_game()

    end
end

function M.debug(data)
    if not _mui_debug then return end
    print(data)
end

function M.init_base(options)
    options = options or {}
    muiData.M = M -- all modules need access to parent methods
    muiData.sceneData = {}
    MySceneName = composer.getSceneName("current")
    sceneName = composer.getSceneName("current")
    muiData.sceneData[MySceneName] = {}
    muiData.environment = system.getInfo("environment")
    muiData.androidApiLevel = system.getInfo("androidApiLevel")
    muiData.platform = string.lower(system.getInfo("platform"))
    muiData.aspectRatio = display.pixelHeight / display.pixelWidth

    print("pixelWidth "..display.pixelWidth)
    print("pixelHeight "..display.pixelHeight)

    print("display.contentScaleX "..display.contentScaleX)
    print("display.contentScaleY "..display.contentScaleY)

    muiData.isPhone = true
    if muiData.platform == "android" then
        wInch = system.getInfo( "androidDisplayWidthInInches" )
        wHeight = system.getInfo( "androidDisplayHeightInInches" )
        if wInch ~= nil and wHeight ~= nil and (wInch > 6 or wHeight > 6) then
            muiData.isPhone = false
        elseif muiData.aspectRatio < 1.7 then
            -- assuming these are tablets
            muiData.isPhone = false
        end
    elseif muiData.platform == "ios" then
        model = system.getInfo("model")
        if string.find(string.lower(model), "iphone") == nil then
            muiData.isPhone = false
        end
    else
        muiData.isPhone = false
    end

    local fontPath = ""
    if _muiPlugin == true then
        fontPath = "plugin/icon-font/"
    else
        fontPath = "icon-font/"
    end
    muiData.materialFont = fontPath .. "MaterialIcons-Regular.ttf"
    muiData.materialFontCodePoints = materialFontCodePoints
    M.materialFont = muiData.materialFont

    muiData.useSvg = options.useSvg or false

    -- utf8 support required for Android API < 23 (to be safe)
    muiData.utf8 = utf8v1
    muiData.utf8Assist = false
    if (muiData.androidApiLevel ~= nil and tonumber(muiData.androidApiLevel) < 23) then
        muiData.utf8Assist = true
        muiData.materialFont = string.gsub(muiData.materialFont, ".ttf", ".otf")
        muiData.materialFontCodePoints = materialFontCodePoints
        M.materialFont = muiData.materialFont
    end

    muiData.parent = options.parent -- to be depreciated
    muiData.sceneData[MySceneName].parent = options.parent
    muiData.sceneData[MySceneName].circleSceneSwitch = nil
    muiData.sceneData[MySceneName].circleSceneSwitchStarted = false
    muiData.sceneData[MySceneName].switchToSceneName = ""
    muiData.masterRatio = nil
    muiData.masterRemainder = nil
    muiData.sceneData[MySceneName].tableCircle = nil
    muiData.widgetDict = {}
    muiData.progressbarDict = {}
    muiData.progresscircleDict = {}
    muiData.progressarcDict = {}
    muiData.shadowShapeDict = {}
    muiData.currentNativeFieldName = ""
    muiData.currentTargetName = ""
    muiData.lastTargetName = ""
    muiData.interceptEventHandler = nil
    muiData.interceptOptions = nil
    muiData.interceptMoved = false
    muiData.dialogInUse = false
    muiData.dialogName = nil
    muiData.navbarHeight = 0
    muiData.navbarSupportedTypes = { "Text", "EmbossedText", "Image", "ImageRect", "ImageSvg", "ImageSvgStyle", "CircleButton", "RRectButton", "RectButton", "IconButton", "Slider", "TextField", "Generic" }
    muiData.onBoardData = nil
    muiData.slideData = nil
    muiData.touching = false
    muiData.currentSlide = 0
    muiData.currentControl = nil
    muiData.currentControlSubName = nil
    muiData.currentControlType = ""
    muiData.minPixelScaleWidthForPortrait = options.minPixelScaleWidthForPortrait or 320
    muiData.minPixelScaleWidthForLandscape = options.minPixelScaleWidthForLandscape or 480
    muiData.minPixelScaleHeightForPortrait = options.minPixelScaleHeightForPortrait or 480
    muiData.minPixelScaleHeightForLandscape = options.minPixelScaleHeightForLandscape or 320
    muiData.autoScale = true
    muiData.autoLayout = false

    M.setDisplayDimensions()
    M.setSafeAreaInsets() -- handle overscan areas and areas like the iPhone X notch

    muiData.focus = nil
    muiData.focusCallBack = nil

    muiData.scene = composer.getScene(composer.getSceneName("current"))
    muiData.scene.name = composer.getSceneName("current")
    Runtime:addEventListener( "touch", M.eventSuperListner )
    Runtime:addEventListener( "system", onSystemEvent )

    -- below only in Landscape w/ insets , if portrait hand topInset and bottomInset for slidePanel Menu

    local defaultBackgroundColor = display.getDefault("background")
    muiPriv = "muiPriv"
    if muiData.widgetDict[muiPriv] == nil then
        muiData.widgetDict[muiPriv] = {}
    end
    if muiData.safeAreaInsets.leftInset > 0 then
        muiData.widgetDict[muiPriv]["areaLeftInset"] = display.newRect( muiData.safeAreaInsets.leftInset * .5, display.contentHeight * .5, muiData.safeAreaInsets.leftInset, display.contentHeight )
        muiData.widgetDict[muiPriv]["areaLeftInset"].strokeWidth = 0
        muiData.widgetDict[muiPriv]["areaLeftInset"]:setFillColor( defaultBackgroundColor )
        muiData.widgetDict[muiPriv]["areaLeftInset"]:toFront()
    end
    if muiData.safeAreaInsets.rightInset > 0 then
        muiData.widgetDict[muiPriv]["areaRightInset"] = display.newRect( display.contentWidth - (muiData.safeAreaInsets.leftInset * .5), display.contentHeight * .5, muiData.safeAreaInsets.leftInset, display.contentHeight )
        muiData.widgetDict[muiPriv]["areaRightInset"].strokeWidth = 0
        muiData.widgetDict[muiPriv]["areaRightInset"]:setFillColor( defaultBackgroundColor )
        muiData.widgetDict[muiPriv]["areaRightInset"]:toFront()
    end
    if muiData.safeAreaInsets.topInset > 0 then
        local y = 0
        muiData.widgetDict[muiPriv]["areaTopInset"] = display.newRect( muiData.safeAreaWidth * .5 + (muiData.safeAreaInsets.leftInset), y, muiData.safeAreaWidth, muiData.safeAreaInsets.topInset * 2 )
        muiData.widgetDict[muiPriv]["areaTopInset"].strokeWidth = 0
        muiData.widgetDict[muiPriv]["areaTopInset"]:setFillColor( defaultBackgroundColor )
        muiData.widgetDict[muiPriv]["areaTopInset"]:toFront()
        muiData.widgetDict[muiPriv]["areaTopInset"].isVisible = false
    end
    if muiData.safeAreaInsets.bottomInset > 0 then
        local y = muiData.safeAreaHeight + muiData.safeAreaInsets.topInset + muiData.safeAreaInsets.bottomInset
        muiData.widgetDict[muiPriv]["areaBottomInset"] = display.newRect( muiData.safeAreaWidth * .5 + (muiData.safeAreaInsets.leftInset), y, muiData.safeAreaWidth, muiData.safeAreaInsets.bottomInset * 2 )
        muiData.widgetDict[muiPriv]["areaBottomInset"].strokeWidth = 0
        muiData.widgetDict[muiPriv]["areaBottomInset"]:setFillColor( defaultBackgroundColor )
        muiData.widgetDict[muiPriv]["areaBottomInset"]:toFront()
        muiData.widgetDict[muiPriv]["areaBottomInset"].isVisible = false
    end

end

function M.init_calls()
    -- perform additional calls
    M.addEventListenerForSlidePanel(M.getParent())
    -- set up scaling
    M.scaleFactorInit()
    M.scaleTableInit()
end

function M.isPhone()
    return muiData.isPhone
end

function M.getCurrentScene()
    return MySceneName
end

function M.getParent()
    return muiData.sceneData[MySceneName].parent
end

function M.addEventListenerForSlidePanel(parent)
    if parent ~= nil and M.slidePanelOut ~= nil then
        parent:addEventListener( "touch", M.slidePanelOut )
    end
end

function M.removeEventListenerForSlidePanel(parent)
    if parent ~= nil and M.slidePanelOut ~= nil then
        parent:removeEventListener( "touch", M.slidePanelOut )
    end
end

function M.setDisplayDimensions(options)
    muiData.contentWidth = display.contentWidth
    muiData.contentHeight = display.contentHeight
end

function M.processEventQueue()
    if muiData.eventQueue ~= nil then
        for k,v in pairs(muiData.eventQueue) do
            if v.methodAtEnd ~= nil then
                assert(v.methodAtEnd)(v.options)
            end
            muiData.eventQueue[k] = nil
        end
    end
end

function M.addToEventQueue( options )
    if options == nil then return end
    if muiData.eventQueue == nil then
        muiData.eventQueue = {}
    end
    local name = options.name
    if muiData.widgetDict[options.name] == nil then
        name = options.basename -- for radio buttons or grouped controls
    end
    if muiData.eventQueue[name] == nil then
        muiData.eventQueue[name] = {
            options = options
        }
        if M.stringEnds(muiData.widgetDict[name]["type"], "Button") then
            muiData.eventQueue[name].methodAtEnd = M.turnOffButton
        elseif M.stringEnds(muiData.widgetDict[name]["type"], "Toolbar") then
            muiData.eventQueue[name].methodAtEnd = M.turnOffToolbarButton
        end
    end
end

function M.removeEventFromQueue( name )
    if name ~= nil then
        if muiData.eventQueue ~= nil and muiData.eventQueue[name] ~= nil then
            muiData.eventQueue[name] = nil
        end
    end
end

function M.eventSuperListner(event)
    -- print("WAZ? "..os.clock().." phase "..event.phase)
    if (event.phase == "ended" or event.phase == "cancelled") and muiData.currentTargetName ~= nil and muiData.currentTargetName ~= muiData.lastTargetName then
        M.processEventQueue()
        muiData.lastTargetName = muiData.currentTargetName
        -- find name in list and type, if slider then force the end!
        for widget in pairs(muiData.widgetDict) do
            widgetType = muiData.widgetDict[widget]["type"]
            if widgetType == "Slider" and muiData.widgetDict[widget].name == muiData.currentTargetName then
                muiData.widgetDict[widget]["sliderrect"]:dispatchEvent(event)
                break
            elseif widgetType == "Selector" and muiData.widgetDict[widget].name == muiData.currentTargetName then
                if muiData.widgetDict[muiData.currentTargetName]["group"] ~= nil then
                    muiData.currentTargetName = nil
                    muiData.lastTargetName = ""
                    M.removeSelector(widget, "listonly")
                end
                break
            elseif widgetType == "Selector" and muiData.widgetDict[widget] ~= nil then
                if muiData.widgetDict[widget]["group"] ~= nil and muiData.widgetDict[widget]["group"].isVisible == true then
                    M.removeSelector(widget, "listonly")
                end
            end
        end
    end
end

function M.updateEventHandler( event )
    if muiData.slidePanelInUse ~= nil and muiData.slidePanelInUse == true then
        if muiData.widgetDict[muiData.slidePanelName] ~= nil then
            if muiData.widgetDict[muiData.slidePanelName]["interceptEventHandler"] ~= nil then
                local e = event
                e.target.muiOptions = muiData.widgetDict[muiData.slidePanelName].options
                assert( muiData.widgetDict[muiData.slidePanelName]["interceptEventHandler"] )(e)
            end
        end
    end
    if muiData.interceptEventHandler ~= nil then
        if type(muiData.interceptEventHandler) == "function" then
            if event.target then
                event.target.muiOptions = muiData.interceptOptions
                -- M.debug("we have a special target! ") --..event.target.muiOptions.name)
            end
            muiData.interceptEventHandler(event)
        end
    end
    if event.phase == "moved" then
        muiData.interceptMoved = true
    elseif event.phase == "ended" then
        muiData.interceptMoved = false
    end
end

function M.turnOffControlHandler()
    if muiData.currentControlSubName ~= nil then
        if muiData.currentControlType == "mui-button" then
            if M.isCurrentControlDisabled( muiData.currentControl ) then return end
            M.turnOffButtonByName( muiData.currentControlSubName, muiData.currentControl )
        elseif muiData.currentControlType == "mui-toolbar" then
            if M.isCurrentControlDisabled( muiData.currentControl ) then return end
            M.turnOffToolbarButtonByName( muiData.currentControlSubName, muiData.currentControl )
        elseif muiData.currentControlType == "mui-slider" then
            if M.isCurrentControlDisabled( muiData.currentControl ) then return end
            M.turnOffSliderByName( muiData.currentControlSubName, muiData.currentControl )
        elseif muiData.currentControlType == "mui-switch" then
            if M.isCurrentControlDisabled( muiData.currentControl ) then return end
            M.turnOffToggleSwitchByName( muiData.currentControlSubName, muiData.currentControl )
        end
    else
        if M.isCurrentControlDisabled( muiData.currentControl ) then return end
        if muiData.currentControlType == "mui-button" then
            M.turnOffButtonByName( muiData.currentControl )
        elseif muiData.currentControlType == "mui-toolbar" then
            M.turnOffToolbarButtonByName( muiData.currentControl )
        elseif muiData.currentControlType == "mui-slider" then
            M.turnOffSliderByName( muiData.currentControl )
        elseif muiData.currentControlType == "mui-switch" then
            M.turnOffToggleSwitchByName( muiData.currentControl )
        end
    end
end

function M.resetCurrentControlVars()
    muiData.currentControl = nil
    muiData.currentControlSubName = nil
    muiData.currentControlType = ""
end

function M.isCurrentControlDisabled()
    local val = false
    if muiData.currentControl == nil then return val end
    if muiData.widgetDict[muiData.currentControl] ~= nil and muiData.widgetDict[muiData.currentControl].disabled ~= nil and muiData.widgetDict[muiData.currentControl].disabled == true then
        val = true
    end
    return val
end

function M.updateUI(event, skipName)
    local widgetType = ""

    for widget in pairs(muiData.widgetDict) do
        if widget ~= skipName or skipName == nil then
            widgetType = muiData.widgetDict[widget]["type"]
            if (widgetType == "TextField" or widgetType == "TextBox") and muiData.widgetDict[widget]["textfield"] ~= nil and muiData.widgetDict[widget]["textfield"].isVisible == true then
                -- hide the native field
                timer.performWithDelay(100, function() native.setKeyboardFocus(nil) end, 1)
                muiData.widgetDict[widget]["textfieldfake"].isVisible = true
                muiData.widgetDict[widget]["textfield"].isVisible = false
            end
        end
    end
    if skipName == nil or (skipName ~= nil and skipName ~= "__skipRemove") then
        M.removeFocus(skipName)
    end
end

function M.setFocus(widgetName, callBack)
    if widgetName ~= nil and callBack ~= nil then
        muiData.focus = widgetName
        muiData.focusCallBack = callBack
    end
end

function M.removeFocus(skipName)
    if skipName ~= nil and muiData.focus ~= nil and skipName == muiData.focus then
        return
    end
    if muiData.focus ~= nil and muiData.focusCallBack ~= nil then
        assert( muiData.focusCallBack )( muiData.focus )
        muiData.focus = nil
        muiData.focusCallBack = nil
    end
end

function M.addBaseEventParameters(event, options)
    if event == nil or options == nil or event.muiDict ~= nil then return end
    M.setEventParameter(event, "name", options.name)
    M.setEventParameter(event, "basename", options.basename)
    M.setEventParameter(event, "muiTargetName", options.name)
    M.setEventParameter(event, "muiCallBackData", options.callBackData)
    muiData.currentTargetName = options.name
    muiData.lastTargetName = ""
end

function M.setEventParameter(event, key, value)
    if event == nil or key == nil then return end
    if event.muiDict == nil then event.muiDict = {} end
    event.muiDict[key] = value
end

function M.getEventParameter(event, key)
    if event ~= nil and event.muiDict ~= nil and key ~= nil then
        return event.muiDict[key]
    else
        M.debug("nothing for key "..key)
    end
    return nil
end

function M.getWidgetByName(name)
    if name ~= nil and string.len(name) > 1 then
        return muiData.widgetDict[name]
    end
    return nil
end

function M.getWidgetBaseObject(name)
    local widgetData = nil

    if name ~= nil and string.len(name) > 1 then
        for widget in pairs(muiData.widgetDict) do
            local widgetType = muiData.widgetDict[widget]["type"]
            if widgetType ~= nil and widget == name then
                if widgetType == "Text" then
                    widgetData = muiData.widgetDict[widget]["text"]
                elseif widgetType == "CircleButton" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "Card" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "Image" then
                    widgetData = muiData.widgetDict[widget]["image"]
                elseif widgetType == "ImageRect" then
                    widgetData = muiData.widgetDict[widget]["image_rect"]
                elseif widgetType == "ImageSvg" then
                    widgetData = muiData.widgetDict[widget]["image_svg"]
                elseif widgetType == "ImageSvgStyle" then
                    widgetData = muiData.widgetDict[widget]["image_svg"]
                elseif widgetType == "DatePicker" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "EmbossedText" then
                    widgetData = muiData.widgetDict[widget]["text"]
                elseif widgetType == "RRectButton" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "RectButton" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "IconButton" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "RadioButton" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "Toolbar" then
                    -- widgetData = muiData.widgetDict[widget]["container"]
                    M.debug("getWidgetForInsert: Toolbar not supported at this time.")
                elseif widgetType == "TableView" then
                    widgetData = muiData.widgetDict[widget]["tableview"]
                elseif widgetType == "TextField" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "TextBox" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "TileGrid" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "TimePicker" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "Navbar" or widgetType == "NavBar" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "ProgressArc" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "ProgressBar" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "Popover" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "ToggleSwitch" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "Dialog" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "SlidePanel" then
                    widgetData = muiData.widgetDict[widget]["group"]
                elseif widgetType == "Slider" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "SnackBar" then
                    widgetData = muiData.widgetDict[widget]["container"]
                elseif widgetType == "Toast" then
                    widgetData = muiData.widgetDict[widget]["container"]
                end
            end
        end
    end
    return widgetData
end

function M.getWidgetProperty( widgetName, propertyName )
    local widgetData = nil

    if widgetName == nil or propertyName == nil then return widgetData end
    if muiData.widgetDict[widgetName] == nil then return widgetData end

    if muiData.widgetDict[widgetName]["type"] == "Card" then
        widgetData = M.getCardProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "CircleButton" then
        widgetData = M.getCircleButtonProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "Dialog" then
        widgetData = M.getDialogProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "DatePicker" then
        widgetData = M.pickerGetCurrentValue( widgetName )
    elseif muiData.widgetDict[widgetName]["type"] == "IconButton" then
        widgetData = M.getIconButtonProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "Image" then
        widgetData = M.getImageProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "ImageRect" then
        widgetData = M.getImageRectProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "Navbar" or muiData.widgetDict[widgetName]["type"] == "NavBar" then
        widgetData = M.getNavBarProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "ImageSvg" or muiData.widgetDict[widgetName]["type"] == "ImageSvgStyle" then
        widgetData = M.getImageSvgProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "Popover" then
        widgetData = M.getPopoverProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "ProgressArc" then
        widgetData = M.getProgressArcProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "ProgressBar" then
        widgetData = M.getProgressBarProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "RectButton" then
        widgetData = M.getRectButtonProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "RRectButton" then
        widgetData = M.getRoundedRectButtonProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "Selector" then
        widgetData = M.getSelectorProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "Slider" then
        widgetData = M.getSliderProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "SlidePanel" then
        widgetData = M.getSlidePanelProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "SnackBar" then
        widgetData = M.getSnackBarProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "EmbossedText" or muiData.widgetDict[widgetName]["type"] == "Text" then
        widgetData = M.getTextProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "TableView" then
        widgetData = M.getTableViewProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "TextField" or muiData.widgetDict[widgetName]["type"] == "TextBox" then
        widgetData = M.getTextFieldProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "TileGrid" then
        widgetData = M.getTileProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "TimePicker" then
        widgetData = M.pickerGetCurrentValue( widgetName )
    elseif muiData.widgetDict[widgetName]["type"] == "Toast" then
        widgetData = M.getToastProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "ToggleSwitch" then
        widgetData = M.getToggleSwitchProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "Toolbar" then
        widgetData = M.getToolBarProperty( widgetName, propertyName )
    elseif muiData.widgetDict[widgetName]["type"] == "ToolbarButton" then
        widgetData = M.getToolBarProperty( widgetName, propertyName )
    end
    return widgetData
end

function M.getChildWidgetProperty(parentWidgetName, propertyName, index)
    local widgetData = nil
    if parentWidgetName == nil or propertyName == nil then return widgetData end

    if muiData.widgetDict[parentWidgetName] == nil then return widgetData end

    if muiData.widgetDict[parentWidgetName]["type"] == "Toolbar" then
        if muiData.widgetDict[parentWidgetName]["toolbar"]["type"] == "ToolbarButton" then
            widgetData = M.getToolBarButtonProperty( parentWidgetName, propertyName, index )
        end
    elseif muiData.widgetDict[widgetName]["type"] == "RadioButton" then
        widgetData = M.getRadioButtonProperty( parentWidgetName, propertyName, index )
    elseif muiData.widgetDict[parentWidgetName]["type"] == "SlidePanel" then
        if muiData.widgetDict[parentWidgetName]["slidebar"]["type"] == "slidebarButton" then
            widgetData = M.getSlidePanelButtonProperty( parentWidgetName, propertyName, index )
        end
    elseif muiData.widgetDict[parentWidgetName]["type"] == "TileGrid" then
        if muiData.widgetDict[parentWidgetName]["tile"]["type"] == "TileGridButton" then
            widgetData = M.getTileButtonProperty( parentWidgetName, propertyName, index )
        end
    end
    return widgetData
end

function M.getWidgetValue(widgetName)
    if widgetName == nil then return end
    return muiData.widgetDict[widget]["value"]
end

function M.showInsetOverlay()
    local muiPriv = "muiPriv"
    if muiData.safeAreaInsets.topInset > 0 then
        muiData.widgetDict[muiPriv]["areaTopInset"].isVisible = true
        muiData.widgetDict[muiPriv]["areaTopInset"]:toFront()
    end
    if muiData.safeAreaInsets.bottomInset > 0 then
        muiData.widgetDict[muiPriv]["areaBottomInset"].isVisible = true
        muiData.widgetDict[muiPriv]["areaBottomInset"]:toFront()
    end
end

function M.hideInsetOverlay()
    local muiPriv = "muiPriv"
    if muiData.safeAreaInsets.topInset > 0 then
        muiData.widgetDict[muiPriv]["areaTopInset"].isVisible = false
    end
    if muiData.safeAreaInsets.bottomInset > 0 then
        muiData.widgetDict[muiPriv]["areaBottomInset"].isVisible = false
    end
end

function M.toFrontSafeArea()
    muiPriv = "muiPriv"
    if muiData.widgetDict[muiPriv] ~= nil then
        if muiData.widgetDict[muiPriv]["areaLeftInset"] ~= nil then
            muiData.widgetDict[muiPriv]["areaLeftInset"]:toFront()
        end
        if muiData.widgetDict[muiPriv]["areaRightInset"] ~= nil then
            muiData.widgetDict[muiPriv]["areaRightInset"]:toFront()
        end
    end
end

function M.getSafeAreaInsets()
    -- Gather insets (function returns these in the order of top, left, bottom, right)
    local topInset, leftInset, bottomInset, rightInset = 0, 0, 0, 0
    if display.getSafeAreaInsets ~= nil then
        topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()
    end

    return topInset, leftInset, bottomInset, rightInset
end

function M.setSafeAreaInsets()
    local topInset, leftInset, bottomInset, rightInset = M.getSafeAreaInsets()
    muiData.safeAreaInsets = {
        topInset = topInset,
        bottomInset = bottomInset,
        leftInset = leftInset,
        rightInset = rightInset
    }
    muiData.safeAreaWidth = muiData.contentWidth - ( leftInset + rightInset )
    muiData.safeAreaHeight = muiData.contentHeight - ( topInset + bottomInset )
    muiData.masterRatio = muiData.aspectRatio
end

function M.getSafeXY(options, x, y)
    if options.ignoreInsets == nil then
        options.ignoreInsets = false
    end

    if options.ignoreInsets then
        return x, y
    end

    if options ~= nil and x ~= nil and y ~= nil then
        x = display.screenOriginX + muiData.safeAreaInsets.leftInset + x
        y = display.screenOriginY + muiData.safeAreaInsets.topInset + y
    end
    return x, y
end

function M.getOrientation()
    local orientation
    if display.contentWidth < display.contentHeight then
        orientation = "portrait"
    else
        orientation = "landscape"
    end
    return orientation
end

-- imageSuffix in config
function M.getImageSuffixName(imageSrc)
    if imageSrc == nil or (string.find(imageSrc, "@") ~= nil) then return imageSrc end

    local ext = string.match(imageSrc, "[^.]+$")
    local filebase = string.gsub(imageSrc, "."..ext, "")

    local suffix = display.imageSuffix
    if suffix == nil or (suffix ~= nil and string.len(suffix) < 3) then
        local sf = display.pixelWidth / display.contentWidth
        if sf > 3.0 then
            -- use @4x
            suffix = "@4x"
        elseif sf > 1.5 then
            -- use @2x
            suffix = "@2x"
        else
            -- use 1x
            suffix = ""
        end
    end

    local filename = ""
    if string.len(suffix) > 0 then
        filename = filebase .. suffix .. "." .. ext
    else
        filename = imageSrc
    end

    return filename
end

function M.createButtonsFromList(options, rect, container)
    local result = false
    if options == nil or rect == nil or container == nil then return result end

    if options.image ~= nil then
        local image = options.image
        if image.src ~= nil and string.len( image.src ) > 0 then
            local imageButton = nil
            local imageSheet = nil
            if image.sheetIndex ~= nil then
                imageSheet = graphics.newImageSheet( image.src, image.sheetOptions )
                if muiData.widgetDict[options.name] == nil then
                    muiData.widgetDict[options.name] = {}
                end
                muiData.widgetDict[options.name]["imageSheet"] = imageSheet
                muiData.widgetDict[options.name]["imageSheetIndex"] = image.sheetIndex
                muiData.widgetDict[options.name]["imageTouchIndex"] = image.touchIndex
                muiData.widgetDict[options.name]["imageTouchFadeAnim"] = image.touchFadeAnimation or false
                muiData.widgetDict[options.name]["imageTouchFadeAnimSpeed"] = image.touchFadeAnimationSpeedOut or 300
                muiData.widgetDict[options.name]["imageSheetOptions"] = image.sheetOptions
                imageButton = display.newImage( imageSheet, image.sheetIndex )
            else
                imageButton = display.newImage( image.src )
            end
            if imageButton == nil then
                M.debug("imageButton is nil for "..image.src)
                return result
            else
                result = true
            end
            local hPadding, vPadding = 0, 0
            if image.hPadding ~= nil then
                hPadding = image.hPadding
            end
            if image.vPadding ~= nil then
                vPadding = image.vPadding
            end
            if image.alpha ~= nil then
                image.alpha = image.alpha
            end
            M.fitImage(imageButton, rect.contentWidth - hPadding, rect.contentHeight - vPadding, true)
            if muiData.widgetDict[options.name] == nil then
                muiData.widgetDict[options.name] = {}
            end
            muiData.widgetDict[options.name]["image"] = imageButton
            if type(container) == "string" then
                muiData.widgetDict[options.name][container]:insert( muiData.widgetDict[options.name]["image"] )
            else
                container:insert( muiData.widgetDict[options.name]["image"] )
            end

            -- now the touch Image
            if imageSheet ~= nil and image.touchIndex ~= nil and image.touchIndex > 0 then
                imageTouch = display.newImage( imageSheet, image.touchIndex )
                M.fitImage(imageTouch, rect.contentWidth, rect.contentHeight, true)
                imageTouch.isVisible = false
                muiData.widgetDict[options.name]["imageTouch"] = imageTouch
                if type(container) == "string" then
                    muiData.widgetDict[options.name][container]:insert( muiData.widgetDict[options.name]["imageTouch"] )
                else
                    container:insert( muiData.widgetDict[options.name]["imageTouch"] )
                end
                --muiData.widgetDict[options.name][container]:insert( muiData.widgetDict[options.name]["imageTouch"] )
            end
            if imageSheet ~= nil and image.disabledIndex ~= nil and image.disabledIndex > 0 then
                imageDisabled = display.newImage( imageSheet, image.disabledIndex )
                M.fitImage(imageTouch, rect.contentWidth, rect.contentHeight, true)
                imageTouch.isVisible = false
                muiData.widgetDict[options.name]["imageDisabled"] = imageDisabled
                if type(container) == "string" then
                    muiData.widgetDict[options.name][container]:insert( muiData.widgetDict[options.name]["imageDisabled"] )
                else
                    container:insert( muiData.widgetDict[options.name]["imageDisabled"] )
                end
            end
        end
    end
    return result
end

function M.setObjectVisible(widgetName, subName, isVisible)
    if widgetName ~= nil and subName ~= nil and isVisible ~= nil then
        if muiData.widgetDict[widgetName] ~= nil and muiData.widgetDict[widgetName][subName] ~= nil then
            muiData.widgetDict[widgetName][subName].isVisible = isVisible
        end
    end
end

function M.setGroupObjectVisible(widgetName, widgetGroup, widgetChildName, subName, isVisible)
    if widgetName ~= nil and widgetGroup ~= nil and widgetChildName ~= nil and subName ~= nil and isVisible ~= nil then
        if muiData.widgetDict[widgetName] ~= nil and muiData.widgetDict[widgetName][widgetGroup] ~= nil and muiData.widgetDict[widgetName][widgetGroup][widgetChildName] ~= nil and muiData.widgetDict[widgetName][widgetGroup][widgetChildName][subName] ~= nil then
            muiData.widgetDict[widgetName][widgetGroup][widgetChildName][subName].isVisible = isVisible
        end
    end
end

function M.setObjectStrokeColor(widgetName, subName, colorpack)
    if widgetName ~= nil and subName ~= nil and colorpack ~= nil then
        if muiData.widgetDict[widgetName] ~= nil and muiData.widgetDict[widgetName][subName] ~= nil then
            muiData.widgetDict[widgetName][subName]:setStrokeColor( unpack( colorpack ) )
        end
    end
end

function M.setObjectFillColor(widgetName, subName, colorpack)
    if widgetName ~= nil and subName ~= nil and colorpack ~= nil then
        if muiData.widgetDict[widgetName] ~= nil and muiData.widgetDict[widgetName][subName] ~= nil then
            muiData.widgetDict[widgetName][subName]:setFillColor( unpack( colorpack ) )
        end
    end
end

function M.setGroupObjectFillColor(widgetName, widgetGroup, widgetChildName, subName, colorpack)
    if widgetName ~= nil and widgetGroup ~= nil and widgetChildName ~= nil and subName ~= nil and colorpack ~= nil then
        if muiData.widgetDict[widgetName] ~= nil and muiData.widgetDict[widgetName][widgetGroup] ~= nil and muiData.widgetDict[widgetName][widgetGroup][widgetChildName] ~= nil and muiData.widgetDict[widgetName][widgetGroup][widgetChildName][subName] ~= nil then
            muiData.widgetDict[widgetName][widgetGroup][widgetChildName][subName]:setFillColor( unpack( colorpack ) )
        end
    end
end

function M.transitionCircleSwitch(params)
    local length = params.time or 900
    local duration = length * 10
    local startTime = system.getTimer()
    local newScaleX, newScaleY = 0.01, 0.01

    local circleColor = params.circleColor
    local callBackData = params.callBackData

    muiData.sceneData[MySceneName].circleSceneSwitch = display.newCircle( 0, 0, muiData.contentWidth + (muiData.contentWidth * 0.25))
    muiData.sceneData[MySceneName].circleSceneSwitch:setFillColor( unpack(circleColor) )
    muiData.sceneData[MySceneName].circleSceneSwitch.alpha = 1
    muiData.sceneData[MySceneName].circleSceneSwitch.callBackData = callBackData
    muiData.sceneData[MySceneName].circleSceneSwitch.width = M.getScaleVal(100)
    muiData.sceneData[MySceneName].circleSceneSwitch.height = M.getScaleVal(100)

    local function circleSceneSwitchAnimFunc(event)
        local runTime = system.getTimer()
        if(startTime + length > runTime) then
            local percentInc = (runTime - startTime) / duration
            newScaleX = newScaleX + percentInc
            newScaleY = newScaleY + percentInc
            muiData.sceneData[MySceneName].circleSceneSwitch.xScale = newScaleX
            muiData.sceneData[MySceneName].circleSceneSwitch.yScale = newScaleY
        else
            -- do it one last time to make sure we have the final size
            Runtime:removeEventListener("enterFrame", circleSceneSwitchAnimFunc)
            muiData.sceneData[MySceneName].circleSceneSwitch.xScale = 2
            muiData.sceneData[MySceneName].circleSceneSwitch.yScale = 2
            muiData.sceneData[MySceneName].circleSceneSwitch.isVisible = false
            muiData.sceneData[MySceneName].circleSceneSwitch:removeSelf()
            muiData.sceneData[MySceneName].circleSceneSwitch = nil
            M.finalActionForSwitchScene({callBackData=callBackData})
        end
    end

    M.showInsetOverlay()
    M.toFrontSafeArea()

    Runtime:addEventListener("enterFrame", muiData.sceneData[MySceneName].circleSceneSwitch.runFunc)
end

function M.transitionColor(displayObj, params)
    if(params and params.startColor and params.endColor) then
        local length = params.time or 1000

        local startTime = system.getTimer()

        local easingFunc = params.transition or easing.inOutExpo
        local function colorInterpolate(a,b,i,t)
            colourTable = {
                easingFunc(i,t,a[1],b[1]-a[1]),
                easingFunc(i,t,a[2],b[2]-a[2]),
                easingFunc(i,t,a[3],b[3]-a[3]),
            }
            if(b[4] and a[4]) then
                easingFunc(i,t,a[4],b[4]-a[4])
            end

            return colourTable
        end

        displayObj.runFunc = function(event)
            local runTime = system.getTimer()
            if(startTime + length > runTime) then
                if params.fillType == nil then
                    displayObj:setFillColor(unpack(colorInterpolate(params.startColor, params.endColor, runTime-startTime, length)))
                else
                    displayObj:setStrokeColor(unpack(colorInterpolate(params.startColor, params.endColor, runTime-startTime, length)))
                end
            else
                -- do it one last time to make sure we have the correct final color
                if params.fillType == nil then
                    displayObj:setFillColor(unpack(params.endColor))
                else
                    displayObj:setStrokeColor(unpack(params.endColor))
                end
                Runtime:removeEventListener("enterFrame", displayObj.runFunc)
            end
        end

        Runtime:addEventListener("enterFrame", displayObj.runFunc)
    end
end

function M.newShadowShapev2( options )
    if (options == nil) or (options ~= nil and options.prefs == nil) then return nil end
    options.offsetX = options.prefs.xOffset
    options.offsetY = options.prefs.yOffset
    options.cornerRadius = options.prefs.cornerRadius
    options.size = options.prefs.size
    options.opacity = options.prefs.opacity
    return M.newShadowShape( options.shape, options, options.group )
end

function M.newShadowShape( shape, options, restoreGroup )
    local g = restoreGroup or display.newGroup()
    local style = options.style or "filter.blurGaussian"
    local width, height = options.width, options.height
    local offsetX, offsetY = (options.offsetX or 0), (options.offsetY or 0)
    local size = options.size or 8
    local cornerRadius = options.cornerRadius or 5
    local opacity = options.opacity or 0.2
    local d = nil

    if restoreGroup == nil then
        g.x, g.y = offsetX, offsetY
    end

    if shape == "rect" then
        d = display.newRect( offsetX, offsetY, width, height )
    elseif shape == "rounded_rect" then
        d = display.newRoundedRect( offsetX, offsetY, width, height, cornerRadius )
    elseif shape == "circle" then
        local radius = width * 0.5
        d = display.newCircle( offsetX, offsetY, radius )
    end

    if d ~= nil then
        d:setFillColor( unpack({0,0,0,1}) )
    end

    if d == nil then return g end
    local cW = (width+size)
    local cH = (height+size)
    local snapshot = display.newSnapshot(cW, cH )
    snapshot.group:insert(d)
    snapshot.fill.effect = "filter.blurGaussian"
    snapshot.fill.effect.horizontal.blurSize = size
    snapshot.fill.effect.horizontal.sigma = size
    snapshot.fill.effect.vertical.blurSize = size
    snapshot.fill.effect.vertical.sigma = size
    snapshot.alpha = options.opacity or 0.5
    snapshot:invalidate()
    g:insert(snapshot)

    muiData.shadowShapeDict[options.name] = {}
    muiData.shadowShapeDict[options.name]["shape"] = shape
    muiData.shadowShapeDict[options.name]["snapshot"] = snapshot
    muiData.shadowShapeDict[options.name]["options"] = options
    muiData.shadowShapeDict[options.name]["group"] = g

    -- adjust group to x,y positions
    if restoreGroup == nil then
        if options.x ~= nil then
            g.x = options.x + offsetX
        end
        if options.y ~= nil then
            g.y = options.y + offsetY
        end
    end

    return g
end

-- credit to Lostgallifreyan
--
function M.decToHex(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    if OUT == "" then OUT = "00" end
    return OUT
end

function M.colorToHex(color)
    local rgbHexColor = ""
    if color == nil then return rgbHexColor end
    local rgbHex = {}
    if color ~= nil and type(color) == "table" and next(color) ~= nil then
        rgbHex[1] = M.decToHex(color[1]*255)
        rgbHex[2] = M.decToHex(color[2]*255)
        rgbHex[3] = M.decToHex(color[3]*255)
        rgbHexColor = "#"..rgbHex[1]..rgbHex[2]..rgbHex[3]
    end
    length = string.len(rgbHexColor) - 1
    if length > 0 and length < 6 then
        for i=1,6-length do
            rgbHexColor = rgbHexColor .. "0"
        end
    end
    return rgbHexColor
end

function M.stringEnds(String,End)
    return End=='' or string.sub(String,-string.len(End))==End
end

function M.split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

function M.getTextWidth(options)
    local width = muiData.contentWidth

    if options == nil then return muiData.contentWidth end

    local lines = M.split(options.text, "\n")
    local longest = 0
    local lineLength = 0
    local text = ""
    for _,line in ipairs(lines) do
        lineLength = string.len(line)
        if lineLength > longest then
            longest = lineLength
            text = line
        end
    end
    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local textToMeasure = display.newText( text, 0, 0, options.font, options.fontSize )
    width = textToMeasure.contentWidth
    textToMeasure:removeSelf()
    textToMeasure = nil
    return width
end

function M.isMobile()
    local isMobile = false

    if muiData.platform == "ios" or muiData.platform == "android" or muiData.platform == "tvos" or muiData.platform == "winphone" then
        isMobile = true
    end

    return isMobile
end

function M.tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function M.isMaterialFont(font)
    local result = false
    if font ~= nil and string.find(font, "MaterialIcons%-Regular") ~= nil then
        result = true
    end
    return result
end

function M.getMaterialFontCodePointByName(name)
    local codepoint = nil
    if muiData.utf8Assist == true and name ~= nil then
        --if name ~= nil then
        for j,v in pairs(muiData.materialFontCodePoints) do
            if j == name and v ~= nil then
                -- codepoint = muiData.utf8.escape( "%x{"..v.."}" )
                codepoint = muiData.utf8( tonumber(v, 16) )
                break
            end
        end
    else
        codepoint = name
    end
    return codepoint
end

function M.getColor(colorArray, index)
    local color = 1
    if colorArray == nil or index == nil then return end

    if colorArray[index] ~= nil then
        color = colorArray[index]
    end

    return color
end

function M.fitImage( displayObject, fitWidth, fitHeight, enlarge )
    --
    -- first determine which edge is out of bounds
    --
    local scaleFactor = fitHeight / displayObject.height
    local newWidth = displayObject.width * scaleFactor
    if newWidth > fitWidth then
        scaleFactor = fitWidth / displayObject.width
    end
    if not enlarge and scaleFactor > 1 then
        return
    end
    displayObject:scale( scaleFactor, scaleFactor )
end

function M.subtleRadius(e)
    if e ~= nil then
        transition.fadeOut( e, { time=500, onComplete=M.subtleRadiusDone } )
    end
end

function M.subtleRadiusDone(e)
    if e ~= nil then
        e.isVisible = false
        transition.to( e, { time=0,alpha=0.3, xScale=1, yScale=1 } )
        muiData.touching = false
        if muiData.sceneData[MySceneName].tableCircle ~= nil then
            muiData.sceneData[MySceneName].tableCircle:toBack()
        end
    end
end

function M.subtleRadius2(e)
    if e ~= nil then
        transition.fadeOut( e, { time=300, onComplete=M.subtleRadiusDone2 } )
    end
end

function M.subtleRadiusDone2(e)
    if e ~= nil then
        e.isVisible = false
        transition.to( e, { time=0,alpha=0.3, xScale=1, yScale=1 } )
        muiData.touching = false
    end
end

function M.subtleGlowRect( e )
    if e ~= nil then
        transition.to( e, { time=300,alpha=1 } )
    end
end

--[[ switch scene action ]]

function M.actionSwitchScene( e )
    if e == nil or muiData.sceneData[MySceneName].circleSceneSwitchStarted == true or muiData.sceneData[MySceneName].circleSceneSwitch ~= nil then return end

    muiData.sceneData[MySceneName].circleSceneSwitchStarted = true

    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")
    local muiTargetCallBackData = M.getEventParameter(e, "muiTargetCallBackData")
    if muiTargetCallBackData == nil then
        muiTargetCallBackData = e.callBackData
    end

    local circleColor = { 1, 0.58, 0 }
    M.hideNativeWidgets()

    if muiTargetCallBackData ~= nil and muiTargetCallBackData.sceneTransitionColor ~= nil then
        circleColor = muiTargetCallBackData.sceneTransitionColor
    end
    --[[--
    muiData.sceneData[MySceneName].circleSceneSwitch = display.newCircle( 0, 0, muiData.contentWidth + (muiData.contentWidth * 0.25))
    muiData.sceneData[MySceneName].circleSceneSwitch:setFillColor( unpack(circleColor) )
    muiData.sceneData[MySceneName].circleSceneSwitch.alpha = 1
    muiData.sceneData[MySceneName].circleSceneSwitch.callBackData = muiTargetCallBackData
    muiData.sceneData[MySceneName].circleSceneSwitch.width = M.getScaleVal(100)
    muiData.sceneData[MySceneName].circleSceneSwitch.height = M.getScaleVal(100)
    muiData.sceneData[MySceneName].circleSwitchTrans = transition.to( muiData.sceneData[MySceneName].circleSceneSwitch, { time=900, xScale=2, yScale=2, onComplete=M.finalActionForSwitchScene } )
    --]]--
    -- M.finalActionForSwitchScene({callBackData=muiTargetCallBackData})
    local sceneTransitionAnimation = true
    if muiTargetCallBackData ~= nil and muiTargetCallBackData.sceneTransitionAnimation ~= nil then
        sceneTransitionAnimation = muiTargetCallBackData.sceneTransitionAnimation
    end

    if sceneTransitionAnimation == true then
        M.transitionCircleSwitch({callBackData=muiTargetCallBackData, circleColor=circleColor})
    else
        M.finalActionForSwitchScene({callBackData=muiTargetCallBackData})
    end
end

function M.finalActionForSwitchScene(e)
    -- switch to scene
    -- if muiData.sceneData[MySceneName].circleSceneSwitch == nil or M.circleSceneSwitchStarted == false then return end
    if muiData.sceneData[MySceneName].circleSceneSwitchStarted == false then return end
    --[[--
    if muiData.sceneData[MySceneName].circleSwitchTrans ~= nil then
        transition.cancel( muiData.sceneData[MySceneName].circleSwitchTrans )
    end
    muiData.sceneData[MySceneName].circleSceneSwitch.isVisible = false
    muiData.sceneData[MySceneName].circleSceneSwitch:removeSelf()
    muiData.sceneData[MySceneName].circleSceneSwitch = nil
    --]]--

    M.hideInsetOverlay()

    muiData.sceneData[MySceneName].circleSceneSwitchStarted = false
    if e.callBackData ~= nil and e.callBackData.sceneDestination ~= nil then
        M.setSceneToSwitchToAfterDestroy( e.callBackData.sceneDestination )
        composer.removeScene( MySceneName )
    end
end

function M.goToScene(callBackData)
    if muiData.sceneData[MySceneName].circleSceneSwitchStarted == true then return end
    if callBackData ~= nil and callBackData.onCompleteData ~= nil then
        local e = {
            callBackData = callBackData.onCompleteData
        }
        M.actionSwitchScene( e )
    end
end

function M.setSceneToSwitchToAfterDestroy(sceneName)
    if sceneName ~= nil and string.len(sceneName) > 0 then
        muiData.sceneData[MySceneName].switchToSceneName = sceneName
    end
end

--[[ end switch scene action ]]

function M.isTouchPointOutOfRange( event )
    local success = false

    if event ~= nil then
        if event.x < event.target.contentBounds.xMin or
        event.x > event.target.contentBounds.xMax or
        event.y < event.target.contentBounds.yMin or
        event.y > event.target.contentBounds.yMax then
            success = true
        end
    end

    return success
end

function M.getWidthForFontWithText(options)
    if options == nil then return 125 end

    local textToMeasure = display.newText( options.text, 0, 0, options.font, options.fontSize )
    local width = textToMeasure.contentWidth
    textToMeasure:removeSelf()
    textToMeasure = nil

    return width
end

function M.scrollListener( event )
    local phase = event.phase
    if event.phase == nil then return end

    M.updateEventHandler( event )

    if ( phase == "began" ) then
        -- skip it
    elseif ( phase == "moved" ) then
        M.updateUI(event)
    elseif ( phase == "ended" ) then
        -- M.debug( "Scroll view was released" )
    end

    -- In the event a scroll limit is reached...
    --[[--
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then M.debug( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then M.debug( "Reached top limit" )
        elseif ( event.direction == "left" ) then M.debug( "Reached right limit" )
        elseif ( event.direction == "right" ) then M.debug( "Reached left limit" )
        end
    end
    --]]--

    return true
end

function M.showNativeInput(event)
    local name = event.target.name
    local dialogName = event.target.dialogName
    local isTextBox = event.target.textbox
    local options = event.target.muiOptions
    if options ~= nil then
        if options.state ~= nil and options.state.value == "disabled" then
            if options.state.disabled ~= nil and options.state.disabled.callBackData ~= nil then
                M.setEventParameter(event, "muiTargetCallBackData", options.state.disabled.callBackData)
                assert( options.state.disabled.callBack )(event)
            end
            return
        end
    end
    muiData.currentNativeFieldName = name

    if muiData.dialogInUse == true and dialogName == nil then return end
    if event.phase == "began" then

        if M.isMobile() == true and isTextBox ~= nil then
            M.createTextBoxOverlay( muiData.widgetDict[name] )
        end

        local madeAdjustment = false
        if muiData.widgetDict[name]["scrollView"] ~= nil then
            madeAdjustment = M.adjustNativeInputIntoView(event)
        end

        muiData.widgetDict[name]["textfieldfake"].isVisible = false
        muiData.widgetDict[name]["textfield"].isVisible = true
        muiData.widgetDict[name]["textfield"].isSecure = muiData.widgetDict[name]["isSecure"]
        if madeAdjustment == false then
            timer.performWithDelay(100, function() native.setKeyboardFocus(muiData.widgetDict[name]["textfield"]) end, 1)
        end
    end
end

function M.adjustNativeInputIntoView(event)
    local name = event.target.name
    local height = muiData.widgetDict[name]["textfield"].contentHeight
    local scrollViewHeight = muiData.widgetDict[name]["scrollView"].contentHeight
    local topMargin = mathFloor(scrollViewHeight * 0.25)
    local bottomMargin = mathFloor(scrollViewHeight * 0.9)
    local x, y = muiData.widgetDict[name]["scrollView"]:getContentPosition()
    local scrollDuration = 500
    local destY = nil
    local scrollOptions = nil
    local madeAdjustment = false

    if event.y > bottomMargin then
        destY = y - height
        scrollOptions = {
            y = destY
        }
    elseif event.y < topMargin then
        local offset = 0
        local widgetY = muiData.widgetDict[name]["container"].y
        local diffY = mathABS(widgetY) - mathABS(y)
        local scrollAmount = height - diffY
        destY = y + scrollAmount
        if muiData.widgetDict[name]["type"] == "TextField" then
            offset = height
        end
        scrollOptions = {
            y = destY + offset
        }
    end
    if destY ~= nil then
        scrollOptions.time = scrollDuration
        scrollOptions.onComplete = M.adjustScrollViewComplete
        madeAdjustment = true
        muiData.widgetDict[name]["scrollView"]:scrollToPosition(scrollOptions)
    end

    return madeAdjustment
end

function M.adjustScrollViewComplete(event)
    local name = muiData.currentNativeFieldName
    timer.performWithDelay(100, function() native.setKeyboardFocus(muiData.widgetDict[name]["textfield"]) end, 1)
end

function M.hideWidget(widgetName, showWidget)
    if showWidget == nil then showWidget = false end
    for widget in pairs(muiData.widgetDict) do
        local widgetType = muiData.widgetDict[widget]["type"]
        if widgetType ~= nil then
            if widgetType == "CircleButton" then
                muiData.widgetDict[widget]["circlemain"].isVisible = showWidget
            elseif widgetType == "DatePicker" or widgetType == "TimePicker" then
                muiData.widgetDict[widget]["group"].isVisible = showWidget
            elseif widgetType == "Image" then
                muiData.widgetDict[widget]["image"].isVisible = showWidget
            elseif widgetType == "ImageRect" then
                muiData.widgetDict[widget]["image_rect"].isVisible = showWidget
            elseif widgetType == "ImageSvg" or widgetType == "ImageSvgStyle" then
                muiData.widgetDict[widget]["image_svg"].isVisible = showWidget
            elseif widgetType == "RRectButton" or widgetType == "RectButton" then
                muiData.widgetDict[widget]["container"].isVisible = showWidget
            elseif widgetType == "IconButton" or widgetType == "RadioButton" then
                muiData.widgetDict[widget]["group"].isVisible = showWidget
            elseif widgetType == "Toolbar" then
                -- not yet supported
            elseif widgetType == "TableView" then
                muiData.widgetDict[widget]["tableview"].isVisible = showWidget
            elseif widgetType == "TileGrid" then
                muiData.widgetDict[widget]["group"].isVisible = showWidget
            elseif widgetType == "TextField" or widgetType == "TextBox" then
                muiData.widgetDict[widget]["container"].isVisible = showWidget
            elseif widgetType == "ProgressBar" or widgetType == "ToggleSwitch" then
                muiData.widgetDict[widget]["group"].isVisible = showWidget
            elseif widgetType == "Slider" then
                muiData.widgetDict[widget]["sliderrect"].isVisible = showWidget
                muiData.widgetDict[widget]["container"].isVisible = showWidget
            elseif widgetType == "Toast" or widgetType == "Selector" or widgetType == "SnackBar" then
                muiData.widgetDict[widget]["container"].isVisible = showWidget
            end
        end
    end
end

function M.hideNativeWidgets()
    for widget in pairs(muiData.widgetDict) do
        local widgetType = muiData.widgetDict[widget]["type"]
        if widgetType ~= nil then
            if (widgetType == "TextField" or widgetType == "TextBox") and muiData.widgetDict[widget]["textfield"] ~= nil then
                muiData.widgetDict[widget]["textfield"].isVisible = false
            end
        end
    end
end

function M.removeWidgetByName(widgetName)
    if widgetName == nil then return end

    local widget = muiData.widgetDict[widgetName]
    if widget ~= nil then
        local widgetType = muiData.widgetDict[widgetName]["type"]
        if widgetType == "CircleButton" then
            M.removeCircleButton(widgetName)
        elseif widgetType == "DatePicker" then
            M.removeDatePicker(widgetName)
        elseif widgetType == "Image" then
            M.removeImage(widgetName)
        elseif widgetType == "ImageRect" then
            M.removeImageRect(widgetName)
        elseif widgetType == "ImageSvg" then
            M.removeImageSvg(widgetName)
        elseif widgetType == "ImageSvgStyle" then
            M.removeImageSvgStyle(widgetName)
        elseif widgetType == "EmbossedText" then
            M.removeEmbossedText(widgetName)
        elseif widgetType == "RRectButton" then
            M.removeRoundedRectButton(widgetName)
        elseif widgetType == "RectButton" then
            M.removeRectButton(widgetName)
        elseif widgetType == "IconButton" then
            M.removeIconButton(widgetName)
        elseif widgetType == "RadioButton" then
            M.removeRadioButton(widgetName)
        elseif widgetType == "Toolbar" then
            M.removeToolbar(widgetName)
        elseif widgetType == "TableView" then
            M.removeTableView(widgetName)
        elseif widgetType == "TextField" then
            M.removeTextField(widgetName)
        elseif widgetType == "TextBox" then
            M.removeTextBox(widgetName)
        elseif widgetType == "TimePicker" then
            M.removeTimePicker(widgetName)
        elseif widgetType == "ProgressBar" then
            M.removeProgressBar(widgetName)
        elseif widgetType == "ToggleSwitch" then
            M.removeToggleSwitch(widgetName)
        elseif widgetType == "SlidePanel" then
            M.removeSlidePanel(widgetName)
        elseif widgetType == "Slider" then
            M.removeSlider(widgetName)
        elseif widgetType == "Selector" then
            M.removeSelector(widgetName)
        elseif widgetType == "Navbar" or widgetType == "NavBar" then
            M.removeNavBar(widgetName)
        elseif widgetType == "Popover" then
            M.removePopover(widgetName)
        elseif widgetType == "Text" then
            M.removeText(widgetName)
        elseif widgetType == "Generic" then
            if muiData.widgetDict[widgetName]["destroy"] ~= nil and muiData.widgetDict[widgetName]["destroy"][widgetName] ~= nil then
                assert( muiData.widgetDict[widgetName]["destroy"][widgetName] )(event)
            end
        end
    end
end

function M.removeWidgets()
    M.destroy()
end

function M.destroy()
    -- M.debug("Removing widgets")

    -- avoid transition issues and cancel any transitions in progress
    transition.cancel()

    -- remove the insets
    muiPriv = "muiPriv"
    if muiData.widgetDict[muiPriv]["areaLeftInset"] ~= nil then
        muiData.widgetDict[muiPriv]["areaLeftInset"]:removeSelf()
        muiData.widgetDict[muiPriv]["areaLeftInset"] = nil
    end
    if muiData.widgetDict[muiPriv]["areaRightInset"] ~= nil then
        muiData.widgetDict[muiPriv]["areaRightInset"]:removeSelf()
        muiData.widgetDict[muiPriv]["areaRightInset"] = nil
    end
    if muiData.widgetDict[muiPriv]["areaTopInset"] ~= nil then
        muiData.widgetDict[muiPriv]["areaTopInset"]:removeSelf()
        muiData.widgetDict[muiPriv]["areaTopInset"] = nil
    end
    if muiData.widgetDict[muiPriv]["areaBottomInset"] ~= nil then
        muiData.widgetDict[muiPriv]["areaBottomInset"]:removeSelf()
        muiData.widgetDict[muiPriv]["areaBottomInset"] = nil
    end
    if muiData.widgetDict[muiPriv] ~= nil then
        muiData.widgetDict[muiPriv] = nil
    end

    for widget in pairs(muiData.widgetDict) do
        local widgetType = muiData.widgetDict[widget]["type"]
        if widgetType ~= nil and muiData.widgetDict[widget] ~= nil then
            if widgetType == "Text" then
                M.removeText(widget)
            elseif widgetType == "Card" then
                M.removeCard(widget)
            elseif widgetType == "CircleButton" then
                M.removeCircleButton(widget)
            elseif widgetType == "DatePicker" then
                M.removeDatePicker(widget)
            elseif widgetType == "Image" then
                M.removeImage(widget)
            elseif widgetType == "ImageRect" then
                M.removeImageRect(widget)
            elseif widgetType == "ImageSvg" then
                M.removeImageSvg(widget)
            elseif widgetType == "ImageSvgStyle" then
                M.removeImageSvgStyle(widget)
            elseif widgetType == "EmbossedText" then
                M.removeEmbossedText(widget)
            elseif widgetType == "RRectButton" then
                M.removeRoundedRectButton(widget)
            elseif widgetType == "RectButton" then
                M.removeRectButton(widget)
            elseif widgetType == "IconButton" then
                M.removeIconButton(widget)
            elseif widgetType == "RadioButton" then
                M.removeRadioButton(widget)
            elseif widgetType == "Toolbar" then
                M.removeToolbar(widget)
            elseif widgetType == "TableView" then
                M.removeTableView(widget)
            elseif widgetType == "TextField" then
                M.removeTextField(widget)
            elseif widgetType == "TextBox" then
                M.removeTextBox(widget)
            elseif widgetType == "TileGrid" then
                M.removeTileGrid(widget)
            elseif widgetType == "TimePicker" then
                M.removeTimePicker(widget)
            elseif widgetType == "ProgressBar" then
                M.removeProgressBar(widget)
            elseif widgetType == "ToggleSwitch" then
                M.removeToggleSwitch(widget)
            elseif widgetType == "SlidePanel" then
                M.removeSlidePanel(widget)
            elseif widgetType == "Slider" then
                M.removeSlider(widget)
            elseif widgetType == "SnackBar" then
                M.removeSnackBar(widget)
            elseif widgetType == "Toast" then
                M.removeToast(widget)
            elseif widgetType == "Selector" then
                M.removeSelector(widget)
            elseif widgetType == "Navbar" or widgetType == "NavBar" then
                M.removeNavBar(widget)
            elseif widgetType == "Text" then
                M.removeText(widget)
            end
        end
    end

    -- remove onBoarding if used.
    if muiData.onBoardData ~= nil then
        M.removeOnBoarding()
    end

    -- remove circle if present
    if muiData.sceneData[MySceneName].tableCircle ~= nil then
        muiData.sceneData[MySceneName].tableCircle.isVisible = false
        muiData.sceneData[MySceneName].tableCircle:removeSelf()
    end

    M.removeEventListenerForSlidePanel(M.getParent())
    Runtime:removeEventListener( "touch", M.eventSuperListner )
    Runtime:removeEventListener( "system", onSystemEvent )
    if muiData.sceneData[MySceneName].switchToSceneName ~= nil and string.len(muiData.sceneData[MySceneName].switchToSceneName) > 0 then
        timer.performWithDelay(500, composer.gotoScene( muiData.sceneData[MySceneName].switchToSceneName ), 1)
        -- sceneName = muiData.sceneData[MySceneName].switchToSceneName
        -- composer.gotoScene( sceneName )
    end
end

return M
