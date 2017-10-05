--[[
    A loosely based Material UI module

    mui-slider.lua : This is for creating horizontal sliders (0..100 in percent or 0.20 = 20%).

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

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.createSlider(options)
    M.newSlider(options)
end

function M.newSlider(options)
    if options == nil then return end

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    if options.width == nil then
        options.width = 100
    end

    if options.height == nil then
        options.height = 2
    end

    if options.position == nil then
        options.position = "horizontal"
    end

    if options.radius == nil then
        options.radius = 8
    end

    if options.color == nil then
        options.color = { 1, 0, 0, 1 }
    end

    if options.colorOff == nil then
        options.colorOff = { 1, 1, 1, 1 }
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "Slider"
    muiData.widgetDict[options.name]["touching"] = false

    local circleWidth = options.radius * 2.5

    -- fix x to be correct
    x = x - options.width * 0.5

    if options.position == "horizontal" then
        muiData.widgetDict[options.name]["sliderrect"] = display.newRect( x + options.width * 0.5, y, options.width, circleWidth)
    else
        muiData.widgetDict[options.name]["sliderrect"] = display.newRect( 0, 0, circleWidth, options.height + (circleWidth + (circleWidth * 0.5)))
    end
    muiData.widgetDict[options.name]["sliderrect"]:setStrokeColor( unpack(options.color) )
    muiData.widgetDict[options.name]["sliderrect"].strokeWidth = 0
    muiData.widgetDict[options.name]["sliderrect"].name = options.name

    muiData.widgetDict[options.name]["circleWidth"] = circleWidth
    muiData.widgetDict[options.name]["circleRadius"] = options.radius
    muiData.widgetDict[options.name]["container"] = display.newGroup()
    muiData.widgetDict[options.name]["container"].x = x
    muiData.widgetDict[options.name]["container"].y = y
    --muiData.widgetDict[options.name]["container"]:translate( x, y ) -- center the container

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["container"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["container"] )
    end

    -- the bar
    if options.position == "horizontal" then
        muiData.widgetDict[options.name]["sliderbar"] = display.newLine( 0, 0, options.width, 0 )
    else
        muiData.widgetDict[options.name]["sliderbar"] = display.newLine( 0, 0, 0, options.height )
    end
    muiData.widgetDict[options.name]["sliderbar"]:setStrokeColor( unpack(options.color) )
    muiData.widgetDict[options.name]["sliderbar"].strokeWidth = options.height
    muiData.widgetDict[options.name]["sliderbar"].isVisible = true

    -- the circle which line goes thru center (vertical|horizontal)
    muiData.widgetDict[options.name]["slidercircle"] = display.newCircle( 0, options.height * 0.5, options.radius )
    muiData.widgetDict[options.name]["slidercircle"]:setStrokeColor( unpack(options.color) )
    muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )

    if options.position == "horizontal" then
        muiData.widgetDict[options.name]["slidercircle"].strokeWidth = options.height
    else
        muiData.widgetDict[options.name]["slidercircle"].strokeWidth = options.width
    end
    --muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["sliderrect"] )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["sliderbar"] )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["slidercircle"] )

    muiData.widgetDict[options.name]["value"] = 0

    if options.startPercent ~= nil and options.startPercent > -1 then
        local event = {}
        local percent = options.startPercent / 100
        local diffX = muiData.widgetDict[options.name]["container"].x - muiData.widgetDict[options.name]["container"].contentWidth
        event.x = x + mathABS(diffX * percent)
        muiData.widgetDict[options.name]["value"] = percent
        M.sliderPercentComplete(event, options)
    end

    local sliderrect = muiData.widgetDict[options.name]["sliderrect"]

    sliderrect.muiOptions = options
    sliderrect:addEventListener( "touch", M.sliderTouch )
end

function M.getSliderProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- clickable area
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["sliderrect"] -- clickable area
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["sliderbar"] -- progress indicator
    elseif propertyName == "layer_3" then
        data = muiData.widgetDict[widgetName]["slidercircle"] -- draggable circle 
    end
    return data
end

function M.sliderTouch (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if muiData.dialogInUse == true and options.dialogName ~= nil then return end
    if options == nil then return end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        -- set touch focus
        display.getCurrentStage():setFocus( event.target )
        event.target.isFocus = true
        muiData.interceptEventHandler = M.sliderTouch
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        if muiData.touching == false then
            muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.color) )
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true and false then
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].y
                --muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].isVisible = true
                --muiData.widgetDict[options.basename]["radio"][options.name].myCircleTrans = transition.to( muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            end
        end
        transition.to(muiData.widgetDict[options.name]["slidercircle"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
    elseif ( event.phase == "moved" ) then

        if muiData.widgetDict[options.name]["slidercircle"].xScale == 1 then
            transition.to(muiData.widgetDict[options.name]["slidercircle"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
        end

        -- update bar with color (up/down/left/right)
        M.sliderPercentComplete(event, options)

        -- call user-defined move method
        if options.callBackMove ~= nil then
            event.target.name = options.name
            assert( options.callBackMove )(event)
        end

    elseif ( event.phase == "ended" ) then
        muiData.currentTargetName = nil
        transition.to(muiData.widgetDict[options.name]["slidercircle"],{time=300, xScale=1, yScale=1, transition=easing.inOutCubic})
        if muiData.interceptMoved == false then
            event.target = muiData.widgetDict[options.name]["slidercircle"]
            event.callBackData = options.callBackData
            if options.callBack ~= nil then
                event.target.name = options.name
                assert( options.callBack )(event)
            end
        end
        muiData.interceptEventHandler = nil
        muiData.interceptOptions = nil
        muiData.interceptMoved = false
        muiData.touching = false
        -- reset focus
        display.getCurrentStage():setFocus( nil )
        event.target.isFocus = false
        M.sliderPercentComplete(event, options)
    end
    muiData.touched = true
    return true -- prevent propagation to other controls
end

function M.sliderPercentComplete(event, options)
    if event == nil or options == nil then return end

    local circleRadius = muiData.widgetDict[options.name]["circleRadius"]
    if options.position == "horizontal" then
        local dx = event.x - muiData.widgetDict[options.name]["container"].x
        if dx > circleRadius and dx <= (muiData.widgetDict[options.name]["sliderbar"].contentWidth - circleRadius) then
            -- get percent
            local percentComplete = dx / (muiData.widgetDict[options.name]["sliderbar"].contentWidth - circleRadius)
            if percentComplete > -1 and percentComplete < 2 then
                if percentComplete >= 0 and percentComplete <= 1 then
                    muiData.widgetDict[options.name]["slidercircle"].x = dx
                end
                if percentComplete >= 1 then percentComplete = 1 end
                if percentComplete < 0 then percentComplete = 0 end
                muiData.widgetDict[options.name]["value"] = percentComplete
                if percentComplete == 0 then
                    muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )
                else
                    muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.color) )
                end
            end
        else
            if dx < circleRadius then
                muiData.widgetDict[options.name]["slidercircle"].x = circleRadius
                muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )
                muiData.widgetDict[options.name]["value"] = 0
            else
                muiData.widgetDict[options.name]["slidercircle"].x = muiData.widgetDict[options.name]["sliderbar"].contentWidth - circleRadius
                muiData.widgetDict[options.name]["value"] = 1
            end
        end
        M.setEventParameter(event, "muiTargetValue", muiData.widgetDict[options.name]["value"])
        M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["slidercircle"])
    end
end

function M.sliderCallBackMove( event )
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")

    if event.target ~= nil then
        M.debug("sliderCallBackMove is: "..muiTargetValue)
    end
end

function M.sliderCallBack( event )
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")

    if muiTarget ~= nil then
        M.debug("percentComplete is: "..muiTargetValue)
    end
end

function M.removeWidgetSlider(widgetName)
    M.removeSlider(widgetName)
end

function M.removeSlider(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["sliderrect"]:removeEventListener("touch", M.sliderTouch)
    muiData.widgetDict[widgetName]["slidercircle"]:removeSelf()
    muiData.widgetDict[widgetName]["slidercircle"] = nil
    muiData.widgetDict[widgetName]["sliderbar"]:removeSelf()
    muiData.widgetDict[widgetName]["sliderbar"] = nil
    muiData.widgetDict[widgetName]["sliderrect"]:removeSelf()
    muiData.widgetDict[widgetName]["sliderrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

return M
