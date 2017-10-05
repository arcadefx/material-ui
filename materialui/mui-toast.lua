--[[
    A loosely based Material UI module

    mui-toast.lua : This is for creating "toast" notifications.

    The MIT License (MIT)

    Copyright (C) 2016 Anedix Technologies, Inc.  All Rights Reserved.

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

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.removeToastNow( event )
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
            transition.to(muiData.widgetDict[options.name]["container"],{time=options.easingOut, y=-(options.top), transition=easing.inOutCubic, onComplete=M.removeMyToast})

            event.target = muiData.widgetDict[options.name]["rrect"]
            event.callBackData = options.callBackData

            M.setEventParameter(event, "muiTargetValue", options.value)
            M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rrect"])

            if options.callBack ~= nil then
                assert( options.callBack )(event)
            end
        end
    end
end

function M.createToast( options )
    M.newToast( options )
end

function M.newToast( options )
    if options == nil then return end

    if muiData.widgetDict[options.name] ~= nil then return end

    if options.width == nil then
        options.width = 200
    end

    if options.height == nil then
        options.height = 4
    end

    if options.radius == nil then
        options.radius = 15
    end

    local left,top = (muiData.contentWidth-options.width) * 0.5, muiData.contentHeight * 0.5
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

    if options.top == nil then
        options.top = 80
    end

    if options.useTimeOut == nil then
        options.useTimeOut = true
    end

    if options.timeOut == nil then
        options.timeOut = 2000 -- microseconds, 2 seconds
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "Toast"
    muiData.widgetDict[options.name]["removeInProgress"] = false

    muiData.widgetDict[options.name]["container"] = widget.newScrollView(
        {
            top = -options.height,
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

    muiData.widgetDict[options.name]["myText"] = display.newText( options.text, newX, newY, font, fontSize )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(options.textColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myText"], true )

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
            muiData.widgetDict[options.name]["removeInProgress"] = true
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
                    transition.to(muiData.widgetDict[options.name]["container"],{time=options.easingOut, y=-(options.top), transition=easing.inOutCubic, onComplete=M.removeMyToast})
                    event.target = muiData.widgetDict[options.name]["rrect"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rrect"])

                    if options.callBack ~= nil then
                        assert( options.callBack )(event)
                    end
                end
            end
            muiData.interceptEventHandler = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
        return true -- prevent propagation to other controls
    end
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", muiData.widgetDict[options.name]["rrect"] )

    if options.easingIn == nil then
        options.easingIn = 500
    end
    transition.to(muiData.widgetDict[options.name]["container"],{time=options.easingIn, y=options.top, transition=easing.inOutCubic})
    muiData.widgetDict[options.name]["options"] = options

    if options.useTimeOut == true then
        muiData.widgetDict[options.name]["removeTimer"] = timer.performWithDelay(options.timeOut + options.easingIn, M.removeToastNow, 1)
        muiData.widgetDict[options.name]["removeTimer"].params = { name = options.name }
    end
end

function M.getToastProperty(widgetName, propertyName)
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

function M.removeMyToast(event)
    local muiName = event.name
    if muiName ~= nil then
        M.removeToast(muiName)
    end
end

function M.removeWidgetToast(widgetName)
    M.removeToast(widgetName)
end

function M.removeToast(widgetName)
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
