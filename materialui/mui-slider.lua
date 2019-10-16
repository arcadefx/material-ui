--[[
A loosely based Material UI module

mui-slider.lua : This is for creating horizontal sliders (0..100 in percent or 0.20 = 20%).

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

    if options.state == nil then options.state = {} end
    options.state.value = options.state.value or "off"

    options.enlargeHandle = options.enlargeHandle or false

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

    -- the background
    if options.background ~= nil and options.background.color ~= nil then
        muiData.widgetDict[options.name]["slidebackground"] = display.newRect( 0, 0, options.width, circleWidth)
        muiData.widgetDict[options.name]["slidebackground"].x = muiData.widgetDict[options.name]["slidebackground"].contentWidth / 2
        muiData.widgetDict[options.name]["slidebackground"]:setFillColor( unpack( options.background.color ) )
    end

    local tw, th = circleWidth, circleWidth
    local k, v

    -- the bar
    if options.bar.off.image == nil then
        if options.position == "horizontal" then
            muiData.widgetDict[options.name]["sliderbar"] = display.newLine( 0, 0, options.width, 0 )
        else
            muiData.widgetDict[options.name]["sliderbar"] = display.newLine( 0, 0, 0, options.height )
        end
        muiData.widgetDict[options.name]["sliderbar"]:setStrokeColor( unpack(options.color) )
        muiData.widgetDict[options.name]["sliderbar"].strokeWidth = options.height
    elseif options.bar.off.image ~= nil then
        -- bar
        local barParams = {
            {
                name = "sliderbar",
                state = "off",
                isVisible = true
            },
            {
                name = "sliderbarOn",
                state = "on",
                isVisible = false
            },
            {
                name = "slidebarDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(barParams) do
            if options.bar[v.state] ~= nil and options.bar[v.state].image ~= nil then
                muiData.widgetDict[options.name][v.name] = display.newImageRect(options.bar[v.state].image, options.width, options.height * 4)
                muiData.widgetDict[options.name][v.name].x = muiData.widgetDict[options.name][v.name].contentWidth / 2
                muiData.widgetDict[options.name][v.name].y = 0
                muiData.widgetDict[options.name][v.name].isVisible = v.isVisible
            end
        end
    elseif options.bar.off.svg ~= nil then
        local barParams = {
            {
                name = "sliderbar",
                svgName = options.name.."BarSvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "sliderbarOn",
                svgName = options.name.."BarSvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "sliderbarDisabled",
                svgName = options.name.."BarSvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(barParams) do
            if options.bar[v.state] ~= nil and options.bar[v.state].svg ~= nil then
                muiData.widgetDict[options.name][v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.bar[v.state].svg.path,
                        width = tw,
                        height = th,
                        fillColor = options.bar[v.state].svg.fillColor,
                        strokeWidth = options.bar[v.state].svg.strokeWidth or 1,
                        strokeColor = options.bar[v.state].svg.textColor or options.bar[v.state].color,
                        x = 0,
                        y = 0,
                    })
                muiData.widgetDict[options.name][v.name].isVisible = false
            end
        end
    end

    muiData.widgetDict[options.name]["sliderbar"].isVisible = true

    -- the handle circle which line goes thru center (vertical|horizontal)
    if options.handle.off.image == nil and options.handle.off.svg == nil then
        muiData.widgetDict[options.name]["slidercircle"] = display.newCircle( 0, options.height * 0.5, options.radius )
        muiData.widgetDict[options.name]["slidercircle"]:setStrokeColor( unpack(options.color) )
        muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )

        if options.position == "horizontal" then
            muiData.widgetDict[options.name]["slidercircle"].strokeWidth = options.height
        else
            muiData.widgetDict[options.name]["slidercircle"].strokeWidth = options.width
        end
    elseif options.handle.off.image ~= nil then
        local handleParams = {
            {
                name = "slidercircle",
                state = "off",
                isVisible = true
            },
            {
                name = "slidercircleOn",
                state = "on",
                isVisible = false
            },
            {
                name = "slidecircleDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(handleParams) do
            if options.handle[v.state] ~= nil and options.handle[v.state].image ~= nil then
                muiData.widgetDict[options.name][v.name] = display.newImageRect(options.handle[v.state].image, tw, th)
                muiData.widgetDict[options.name][v.name].isVisible = v.isVisible
            end
        end
    elseif options.handle.off.svg ~= nil then
        local handleParams = {
            {
                name = "slidercircle",
                svgName = options.name.."HandleSvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "slidercircleOn",
                svgName = options.name.."HandleSvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "slidercircleDisabled",
                svgName = options.name.."HandleSvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(handleParams) do
            if options.handle[v.state] ~= nil and options.handle[v.state].svg ~= nil then
                muiData.widgetDict[options.name][v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.handle[v.state].svg.path,
                        width = tw,
                        height = th,
                        fillColor = options.handle[v.state].svg.fillColor or options.handle[v.state].color,
                        strokeWidth = options.handle[v.state].svg.strokeWidth or 1,
                        strokeColor = options.handle[v.state].svg.textColor or options.handle[v.state].color,
                        x = 0,
                        y = 0,
                    })
                muiData.widgetDict[options.name][v.name].isVisible = v.isVisible
            end
        end
    end
    --muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["sliderrect"] )
    if muiData.widgetDict[options.name]["slidebackground"] then
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["slidebackground"] )
    end
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["sliderbar"] )
    if muiData.widgetDict[options.name]["sliderbarOn"] ~= nil then
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["sliderbarOn"] )
    end
    if muiData.widgetDict[options.name]["sliderbarDisabled"] ~= nil then
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["sliderbarDisabled"] )
    end

    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["slidercircle"] )
    if muiData.widgetDict[options.name]["slidercircleOn"] ~= nil then
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["slidercircleOn"] )
    end
    if muiData.widgetDict[options.name]["slidercircleDisabled"] ~= nil then
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["slidercircleDisabled"] )
    end

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

    if options.state.value == "off" then
        M.turnOffSlider( options )
    elseif options.state.value == "on" then
        M.turnOnSlider( options )
    elseif options.state.value == "disabled" then
        M.disableSlider( options )
    end
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

    if options == nil then return end
    if muiData.dialogInUse == true and options.dialogName ~= nil then return end

    if muiData.currentControl == nil then
        muiData.currentControl = options.name
        muiData.currentControlType = "mui-slider"
    end

    if M.disableSlider( options, event ) then
        if options.handle.disabled.callBackData ~= nil and event.phase == "ended" then
            M.setEventParameter(event, "muiTargetCallBackData", options.handle.disabled.callBackData)
            assert( options.handle.disabled.callBack )(event)
        end
        return
    end

    if muiData.currentControl ~= nil and muiData.currentControl ~= options.name then
        if event.phase == "ended" then
            M.turnOffControlHandler()
        end
        return
    end

    if muiData.currentControl ~= nil and muiData.currentControl ~= options.name then
        return
    end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        -- set touch focus
        display.getCurrentStage():setFocus( event.target )
        event.target.isFocus = true
        muiData.interceptEventHandler = M.sliderTouch
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end

        M.turnOnSlider( options, event )

        M.updateUI(event)
        if muiData.touching == false then
            if options.handle.off.image == nil then
                muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.color) )
            end
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true and false then
            end
        end
        if options.enlargeHandle then
            transition.to(muiData.widgetDict[options.name]["slidercircle"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
            transition.to(muiData.widgetDict[options.name]["slidercircleOn"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
        end
    elseif ( event.phase == "moved" ) then

        if muiData.widgetDict[options.name]["slidercircle"].xScale == 1 and options.enlargeHandle then
            transition.to(muiData.widgetDict[options.name]["slidercircle"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
            transition.to(muiData.widgetDict[options.name]["slidercircleOn"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
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
        if options.enlargeHandle then
            transition.to(muiData.widgetDict[options.name]["slidercircle"],{time=300, xScale=1, yScale=1, transition=easing.inOutCubic})
        end
        if muiData.interceptMoved == false then
            event.target = muiData.widgetDict[options.name]["slidercircle"]
            event.callBackData = options.callBackData
            if options.callBack ~= nil then
                event.target.name = options.name
                assert( options.callBack )(event)
            end
        end
        M.turnOffSlider( options, event )
        muiData.interceptEventHandler = nil
        muiData.interceptOptions = nil
        muiData.interceptMoved = false
        muiData.touching = false
        -- reset focus
        display.getCurrentStage():setFocus( nil )
        event.target.isFocus = false
        muiData.currentControl = nil
        M.processEventQueue()
        M.sliderPercentComplete(event, options)
    else
        M.addToEventQueue( options )
    end
    muiData.touched = true
    return true -- prevent propagation to other controls
end

function M.getOptionsForSlider( name, basename )
    if name == nil then return end
    local options = nil

    if muiData.widgetDict[name]["type"] == "Slider" then
        options = muiData.widgetDict[name]["sliderrect"].muiOptions
    end

    return options
end

function M.disableSlider( options, event )
    M.debug("M.disableSlider()")
    local val = false
    if options == nil then return val end
    if options.state.value ~= "disabled" then return val end

    val = true

    if muiData.widgetDict[options.name] == nil then return val end

    muiData.widgetDict[options.name].disabled = true

    if muiData.widgetDict[options.name]["type"] == "Slider" then
        -- change color
        if options.handle.disabled.image == nil and options.handle.disabled.svg == nil and options.handle.disabled.color ~= nil then
            M.setObjectFillColor(options.name, "slidercircle", options.handle.disabled.color)
            M.setObjectStrokeColor(options.name, "slidercircle", options.bar.disabled.strokeColor)
            M.setObjectStrokeColor(options.name, "sliderbar", options.bar.disabled.color)
        end

        -- change icon
        if muiData.widgetDict[options.name].slidercircleDisabled ~= nil then
            M.setObjectVisible(options.name, "slidercircle", false)
            M.setObjectVisible(options.name, "slidercircleOn", false)
            M.setObjectVisible(options.name, "slidercircleDisabled", true)
            M.setObjectFillColor(options.name, "text", options.state.disabled.color)
        end

        -- change image
        if muiData.widgetDict[options.name]["sliderbarDisabled"] ~= nil then
            M.setObjectVisible(options.name, "sliderbar", false)
            M.setObjectVisible(options.name, "sliderbarOn", false)
            M.setObjectVisible(options.name, "sliderbarDisabled", true)
        end
        if muiData.widgetDict[options.name]["slidercircleDisabled"] ~= nil then
            M.setObjectVisible(options.name, "slidercircle", false)
            M.setObjectVisible(options.name, "slidercircleOn", false)
            M.setObjectVisible(options.name, "slidercircleDisabled", true)
        end

    end

    if muiData.currentControl == options.name then
        M.resetCurrentControlVars()
    end

    return val
end

function M.turnOnSliderByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForSlider(name, basename)

    if options ~= nil then
        M.turnOnSlider( options )
    end
end

function M.turnOnSlider( options, event )
    -- body
    M.debug("M.turnOnSlider()")

    options.state.value = "on"
    if event ~= nil then
        if options.handle.on.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.handle.on.callBackData)
            assert( options.handle.on.callBack )(event)
        end
    end

    if muiData.widgetDict[options.name] == nil then return end

    if muiData.widgetDict[options.name]["type"] == "Slider" then

        if options.handle.on.image == nil and options.handle.on.svg == nil and options.handle.on.color ~= nil then
            M.setObjectFillColor(options.name, "slidercircle", options.handle.on.color)
            M.setObjectStrokeColor(options.name, "slidercircle", options.bar.on.strokeColor)
            M.setObjectStrokeColor(options.name, "sliderbar", options.bar.on.color)
        end

        -- change icon
        if muiData.widgetDict[options.name].slidercircleOn ~= nil then
            M.setObjectVisible(options.name, "slidercircle", false)
            M.setObjectVisible(options.name, "slidercircleOn", true)
            M.setObjectVisible(options.name, "slidercircleDisabled", false)
        end

        -- change image
        if muiData.widgetDict[options.name]["sliderOn"] ~= nil then
            M.setObjectVisible(options.name, "sliderbar", false)
            M.setObjectVisible(options.name, "sliderbarOn", true)
            M.setObjectVisible(options.name, "sliderbarDisabled", false)

            muiData.widgetDict[options.name]["slidercircleOn"].x = muiData.widgetDict[options.name]["slidercircle"].x
            M.setObjectVisible(options.name, "slidercircle", false)
            M.setObjectVisible(options.name, "slidercircleOn", true)
            M.setObjectVisible(options.name, "slidercircleDisabled", false)
        end

        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    end
end

-- params...
-- name: name of button
-- basename: only required if RadioButton
function M.turnOffSliderByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForSlider(name, basename)

    if options ~= nil then
        M.turnOffSlider( options )
    end
end

function M.turnOffSlider( options, event )
    -- body
    M.debug("M.turnOffSlider()")

    options.state.value = "off"
    if event ~= nil then
        if options.handle.off.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.handle.off.callBackData)
            assert( options.handle.off.callBack )(event)
        end
    end

    if muiData.widgetDict[options.name] == nil then return end

    if muiData.widgetDict[options.name]["type"] == "Slider" then

        if options.handle.off.image == nil and options.handle.off.svg == nil and options.handle.off.color ~= nil then
            M.setObjectFillColor(options.name, "slidercircle", options.handle.off.color)
            M.setObjectStrokeColor(options.name, "slidercircle", options.bar.off.strokeColor)
            M.setObjectStrokeColor(options.name, "sliderbar", options.bar.off.color)
        end

        -- revert to normal icon
        if muiData.widgetDict[options.name].slidercircle ~= nil then
            M.setObjectVisible(options.name, "slidercircle", true)
            M.setObjectVisible(options.name, "slidercircleOn", false)
            M.setObjectVisible(options.name, "slidercircleDisabled", false)
        end

        -- change image
        if muiData.widgetDict[options.name]["sliderbar"] ~= nil then
            M.setObjectVisible(options.name, "sliderbar", true)
            M.setObjectVisible(options.name, "sliderbarOn", false)
            M.setObjectVisible(options.name, "sliderbarDisabled", false)

            muiData.widgetDict[options.name]["slidercircle"].x = muiData.widgetDict[options.name]["slidercircle"].x
            M.setObjectVisible(options.name, "slidercircle", true)
            M.setObjectVisible(options.name, "slidercircleOn", false)
            M.setObjectVisible(options.name, "slidercircleDisabled", false)
        end

        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    end
end

function M.sliderPercentComplete(event, options)
    if event == nil or options == nil then return end

    local slideBarObj = "sliderbar"
    local slideCircleObj = "slidercircle"

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
                if percentComplete == 0 and options.handle.off.image == nil then
                    muiData.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )
                elseif options.handle.off.image == nil then
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
    if options.state.value ~= "disabled" and muiData.widgetDict[options.name]["slidercircleOn"] ~= nil then
        muiData.widgetDict[options.name]["slidercircleOn"].x = muiData.widgetDict[options.name]["slidercircle"].x
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

    if muiData.widgetDict[widgetName]["sliderbarOn"] ~= nil then
        muiData.widgetDict[widgetName]["sliderbarOn"]:removeSelf()
        muiData.widgetDict[widgetName]["sliderbarOn"] = nil
    end
    if muiData.widgetDict[widgetName]["sliderbarDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["sliderbarDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["sliderbarDisabled"] = nil
    end

    if muiData.widgetDict[widgetName]["slidercircleOn"] ~= nil then
        muiData.widgetDict[widgetName]["slidercircleOn"]:removeSelf()
        muiData.widgetDict[widgetName]["slidercircleOn"] = nil
    end
    if muiData.widgetDict[widgetName]["slidercircleDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["slidercircleDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["slidercircleDisabled"] = nil
    end

    -- remove svg data
    if muiData.widgetDict[widgetName][widgetName.."HandleSvgOff"] ~= nil then
        muiData.widgetDict[widgetName][widgetName.."HandleSvgOff"]:removeSelf()
        muiData.widgetDict[widgetName][widgetName.."HandleSvgOff"] = nil
    end
    if muiData.widgetDict[widgetName][widgetName.."HandleSvgOn"] ~= nil then
        muiData.widgetDict[widgetName][widgetName.."HandleSvgOn"]:removeSelf()
        muiData.widgetDict[widgetName][widgetName.."HandleSvgOn"] = nil
    end
    if muiData.widgetDict[widgetName][widgetName.."HandleSvgDisabled"] ~= nil then
        muiData.widgetDict[widgetName][widgetName.."HandleSvgDisabled"]:removeSelf()
        muiData.widgetDict[widgetName][widgetName.."HandleSvgDisabled"] = nil
    end

    -- remove the rest
    if muiData.widgetDict[widgetName]["slidebackground"] ~= nil then
        muiData.widgetDict[widgetName]["slidebackground"]:removeSelf()
        muiData.widgetDict[widgetName]["slidebackground"] = nil
    end
    muiData.widgetDict[widgetName]["sliderrect"]:removeSelf()
    muiData.widgetDict[widgetName]["sliderrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
    M.resetCurrentControlVars()
end

return M
