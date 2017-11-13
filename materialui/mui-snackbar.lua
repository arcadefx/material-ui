--[[
    A loosely based Material UI module

    mui-snackbar.lua : This is for creating "snackbar" notifications.

    The MIT License (MIT)

    Copyright (C) 2017 Anedix Technologies, Inc.  All Rights Reserved.

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

--]]--

-- corona
local widget = require( "widget" )
local composer = require( "composer" )

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.removeSnackBarNow( event )
    local options = nil
    local params = event.source.params

    if params.name ~= nil and muiData.widgetDict[params.name]["removeInProgress"] == false then
        local options = muiData.widgetDict[params.name]["options"]
        muiData.widgetDict[params.name]["removeInProgress"] = true

        if muiData.interceptMoved == false then
            if options.easingOut == nil then
                options.easingOut = 500
            end
            muiData.widgetDict[options.name]["container"].name = options.name
            event.target = muiData.widgetDict[options.name]["rrect"]
            event.callBackData = options.callBackData

            M.setEventParameter(event, "muiTargetValue", options.value)
            M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rrect"])

            if params.touched ~= nil and params.touched == true then
                assert( options.callBack )(event)
            end
            M.moveSnackBarParentView(options.name, "down")
        end
    end
end

function M.createSnackBar( options )
    M.newSnackBar( options )
end

function M.newSnackBar( options )
    if options == nil then return end

    if muiData.widgetDict[options.name] ~= nil then return end

    if options.width == nil then
        options.width = 100
    end

    if options.height == nil then
        options.height = 2
    end

    if options.radius == nil then
        options.radius = 15
    end

    local left,bottom = (muiData.contentWidth-options.width) * 0.5, muiData.contentHeight * 0.5
    if options.left ~= nil then
        left = options.left
    end

    if options.textColor == nil then
        options.textColor = { 1, 1, 1, 1 }
    end

    if options.fillColor == nil then
        options.fillColor = { 0.06, 0.56, 0.15, 1 }
    end

    if options.font == nil then
        options.font = native.systemFont
    end

    if options.bottom == nil then
        options.bottom = 80
    end

    if options.useTimeOut == nil then
        options.useTimeOut = true
    end

    if options.timeOut == nil then
        options.timeOut = 2000 -- microseconds, 2 seconds
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "SnackBar"
    muiData.widgetDict[options.name]["removeInProgress"] = false

    -- determine if there is a toolbar along the bottom, if so handle the offset of Y position
    local yOffset = 0
    local widgetType = nil
    local widgetLayout = nil
    for widget in pairs(muiData.widgetDict) do
        widgetType = muiData.widgetDict[widget]["type"]
        widgetLayout = muiData.widgetDict[widget]["layout"]
        if widgetType ~= nil and widgetLayout ~= nil and widgetType == "Toolbar" and widgetLayout == "horizontal" then
            yOffset = M.getToolBarButtonProperty(widget, "buttonHeight", 1)
            local ty = muiData.widgetDict[widget]["y_position"]
            if ty ~= nil then
                local percent = (ty / muiData.contentHeight)
                if percent <= 0.89 then
                    yOffset = 0
                end
            end
            local object = M.getToolBarProperty(widget, "object")
            if object ~= nil then
                -- todo: make toolbar grouped!
            end
            break
        end
    end

    insetOffset = muiData.contentHeight - muiData.safeAreaHeight
    muiData.widgetDict[options.name]["container"] = widget.newScrollView(
        {
            top = muiData.safeAreaHeight - yOffset,
            left = left,
            width = options.width + (options.width * 0.10),
            height = options.height + (options.height * 0.10),
            scrollWidth = options.width,
            scrollHeight = options.height,
            hideBackground = true,
            hideScrollBar = true,
            isLocked = true
        }
    )
    muiData.widgetDict[options.name]["container"].isVisible = true

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["container"] )
        M.moveSnackBarParentView(options.name, "up")
    end

    muiData.widgetDict[options.name]["touching"] = false

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local newX = muiData.widgetDict[options.name]["container"].contentWidth * 0.5
    local newY = muiData.widgetDict[options.name]["container"].contentHeight * 0.5

    muiData.widgetDict[options.name]["rrect"] = display.newRoundedRect( newX, newY, options.width, options.height, radius )
    muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )

    local rrect = muiData.widgetDict[options.name]["rrect"]

    local fontSize = 24
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize

    local options_for_text = 
    {
        text = options.text,
        x = 0,
        y = newY,
        font = font or native.systemFontBold,
        fontSize = fontSize
    }
    muiData.widgetDict[options.name]["myText"] = display.newText( options_for_text )
    local newTextX = (muiData.widgetDict[options.name]["myText"].contentWidth * 0.5) + 20
    muiData.widgetDict[options.name]["myText"].x = newTextX
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(options.textColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myText"], true )

    options.buttonText = options.buttonText or "UNDO"
    options_for_text = 
    {
        text = options.buttonText,
        x = 0,
        y = newY,
        font = buttonFont,
        fontSize = fontSize
    }
    muiData.widgetDict[options.name]["myTextButton"] = display.newText( options_for_text )
    local newTextX = mathABS(options.width - (muiData.widgetDict[options.name]["myTextButton"].contentWidth * 0.5))
    muiData.widgetDict[options.name]["myTextButton"].x = newTextX
    options.buttonTextColor = options.buttonTextColor or { 1, 0.23, 0.5, 1 }
    muiData.widgetDict[options.name]["myTextButton"]:setFillColor( unpack(options.buttonTextColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myTextButton"], true )

    function rrect:touch (event)
        if muiData.dialogInUse == true and options.dialogName == nil then return end

        if muiData.widgetDict[options.name]["removeInProgress"] == true then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            if options.useTimeOut == true and muiData.widgetDict[options.name]["removeTimer"] ~= nil then
                timer.cancel( muiData.widgetDict[options.name]["removeTimer"] )
                muiData.widgetDict[options.name]["removeTimer"] = nil
            end
            --event.target:takeFocus(event)
            -- if scrollView then use the below
            muiData.interceptEventHandler = rrect
            M.updateUI(event)
            if muiData.touching == false then
                muiData.touching = true
            end
        elseif ( event.phase == "ended" ) then
            if muiData.widgetDict[options.name]["removeInProgress"] == true then return end
            if M.isTouchPointOutOfRange( event ) then
                  event.phase = "offTarget"
                  -- M.debug("Its out of the button area")
                  -- event.target:dispatchEvent(event)
            else
                event.phase = "onTarget"
                if muiData.interceptMoved == false then
                    if options.easingOut == nil then
                        options.easingOut = 500
                    end
                    muiData.widgetDict[options.name]["container"].name = options.name
                    event.source = {}
                    event.source.params = { name = options.name, touched = true }
                    M.removeSnackBarNow(event)
                end
            end
            muiData.interceptEventHandler = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
        return true
    end
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", muiData.widgetDict[options.name]["rrect"] )

    M.showInsetOverlay()

    if options.easingIn == nil then
        options.easingIn = 500
    end
    transition.to(muiData.widgetDict[options.name]["container"],{time=options.easingIn, y=options.top, transition=easing.inOutCubic})
    muiData.widgetDict[options.name]["options"] = options

    if options.useTimeOut == true then
        muiData.widgetDict[options.name]["removeTimer"] = timer.performWithDelay(options.timeOut + options.easingIn, M.removeSnackBarNow, 1)
        muiData.widgetDict[options.name]["removeTimer"].params = { name = options.name }
    end

end

function M.moveSnackBarParentView(widgetName, position)
    local newY = 0
    if position == "up" then
        newY = muiData.widgetDict[widgetName]["parent"].y - muiData.widgetDict[widgetName]["container"].contentHeight
        newY = newY - (muiData.safeAreaInsets.bottomInset * 2)
        transition.moveTo(muiData.widgetDict[widgetName]["parent"], {y=newY,time=500})
    else
        newY = muiData.widgetDict[widgetName]["parent"].y + muiData.widgetDict[widgetName]["container"].contentHeight
        newY = newY + (muiData.safeAreaInsets.bottomInset * 2)
        muiData.widgetDict[widgetName]["parent"].name = widgetName
        transition.moveTo(muiData.widgetDict[widgetName]["parent"], {y=newY,time=500,onComplete=M.removeMySnackBar})
    end
end

function M.getSnackBarProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["myText"] -- button text
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rrect"] -- button face
    end
    return data
end

function M.removeMySnackBar(event)
    local muiName = event.name
    if muiName ~= nil then
        M.removeSnackBar(muiName)
        M.hideInsetOverlay()
    end
end

function M.removeWidgetSnackBar(widgetName)
    M.removeSnackBar(widgetName)
end

function M.removeSnackBar(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    local options = muiData.widgetDict[widgetName]["options"]
    if options.useTimeOut == true and muiData.widgetDict[widgetName]["removeTimer"] ~= nil then
        timer.cancel( muiData.widgetDict[widgetName]["removeTimer"] )
        muiData.widgetDict[widgetName]["removeTimer"] = nil
    end

    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", muiData.widgetDict[widgetName]["sliderrect"])
    muiData.widgetDict[widgetName]["myTextButton"]:removeSelf()
    muiData.widgetDict[widgetName]["myTextButton"] = nil    
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    muiData.widgetDict[widgetName]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName]["removeInProgress"] = false
    muiData.widgetDict[widgetName] = nil
end

return M
