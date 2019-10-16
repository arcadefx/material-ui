--[[
A loosely based Material UI module

mui-switch.lua : This is for creating simple toggle switches.

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

function M.createToggleSwitch(options)
    M.newToggleSwitch(options)
end

function M.newToggleSwitch(options)
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
        options.width = options.size
    end

    if options.height == nil then
        options.height = options.size
    end

    if options.backgroundColor == nil then
        options.backgroundColor = { 0, 0, 1, 0, 0.8 }
    end

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end

    if options.state == nil then options.state = {} end
    options.state.value = options.state.value or "off"

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name]["isChecked"] = isChecked
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "ToggleSwitch"
    muiData.widgetDict[options.name]["group"] = display.newGroup()
    muiData.widgetDict[options.name]["group"]:translate( x, y )
    muiData.widgetDict[options.name]["touching"] = false

    if options.callBack ~= nil then
        muiData.widgetDict[options.name]["callBack"] = options.callBack
    end

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["group"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["group"] )
    end

    local radius = options.height

    x = 0
    y = 0
    local barWidth = options.bar.width or 100
    local barHeight = options.bar.height or 50
    local handleWidth = options.handle.off.width or 40
    local handleHeight = options.handle.off.height or 40

    if options.handle.off.image == nil and options.handle.off.svg == nil then
        muiData.widgetDict[options.name]["group"]["rectmaster"] = display.newRect( x, y, options.width * 1.3, (options.height * 0.75))
    else
        muiData.widgetDict[options.name]["group"]["rectmaster"] = display.newRect( x, y, barWidth, barHeight)
    end
    muiData.widgetDict[options.name]["group"]["rectmaster"].strokeWidth = 0
    muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"]["rectmaster"])

    if options.handle.off.image == nil and options.handle.off.svg == nil then

        muiData.widgetDict[options.name]["group"]["rect"] = display.newRect( x, y, options.width * 0.5, options.height * 0.5)
        muiData.widgetDict[options.name]["group"]["rect"].strokeWidth = 0
        muiData.widgetDict[options.name]["group"]["rect"]:setFillColor( unpack(options.bar.off.color) )

        muiData.widgetDict[options.name]["group"]["circle1"] = display.newCircle( x - (radius * 0.20), y, radius * 0.25 )
        muiData.widgetDict[options.name]["group"]["circle1"]:setFillColor( unpack(options.bar.off.color) )

        muiData.widgetDict[options.name]["group"]["circle2"] = display.newCircle( x + (radius * 0.20), y, radius * 0.25 )
        muiData.widgetDict[options.name]["group"]["circle2"]:setFillColor( unpack(options.bar.off.color) )

        muiData.widgetDict[options.name]["group"]["circle"] = display.newCircle( x - (radius * 0.25), y, radius * 0.30 )
        muiData.widgetDict[options.name]["group"]["circle"]:setFillColor( unpack(options.handle.off.color) )

        muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"]["rect"])
        muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"]["circle1"])
        muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"]["circle2"])
        muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"]["circle"])
    elseif options.handle.off.image == nil and options.handle.off.svg ~= nil then
        -- bar
        local k, v
        local barParams = {
            {
                name = "rect",
                svgName = options.name.."rectSvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "rectOn",
                svgName = options.name.."rectSvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "rectDisabled",
                svgName = options.name.."rectSvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(barParams) do
            if options.bar[v.state] ~= nil and options.bar[v.state].svg ~= nil then
                muiData.widgetDict[options.name]["group"][v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.bar[v.state].svg.path,
                        width = barWidth,
                        height = barHeight,
                        fillColor = options.bar[v.state].svg.fillColor,
                        strokeWidth = options.bar[v.state].svg.strokeWidth or 1,
                        strokeColor = options.bar[v.state].svg.color or options.bar[v.state].color,
                        x = 0,
                        y = 0,
                    })
                muiData.widgetDict[options.name]["group"][v.name].isVisible = v.isVisible
                muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"][v.name])
            end
        end

        -- handle
        local handleParams = {
            {
                name = "circle",
                svgName = options.name.."HandleSvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "circleOn",
                svgName = options.name.."HandleSvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "circleDisabled",
                svgName = options.name.."HandleSvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(handleParams) do
            if options.handle[v.state] ~= nil and options.handle[v.state].svg ~= nil then
                muiData.widgetDict[options.name]["group"][v.name] = M.newSvgImageWithStyle({
                        name = options.name.."HandleSvgOn",
                        path = options.handle[v.state].svg.path,
                        width = handleWidth,
                        height = handleHeight,
                        fillColor = options.handle[v.state].svg.fillColor or options.handle[v.state].color,
                        strokeWidth = options.handle[v.state].svg.strokeWidth or 1,
                        strokeColor = options.handle[v.state].svg.color or options.handle[v.state].color,
                        x = 0,
                        y = 0,
                    })
                muiData.widgetDict[options.name]["group"][v.name].isVisible = false
                muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"][v.name])
            end
        end
    elseif options.handle.off.image ~= nil then
        -- bar
        local k, v
        local barParams = {
            {
                name = "rect",
                state = "off",
                isVisible = true
            },
            {
                name = "rectOn",
                state = "on",
                isVisible = false
            },
            {
                name = "rectDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(barParams) do
            muiData.widgetDict[options.name]["group"][v.name] = display.newImageRect(options.bar[v.state].image, barWidth, barHeight)
            muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"][v.name])
            muiData.widgetDict[options.name]["group"][v.name].isVisible = v.isVisible
        end

        local handleParams = {
            {
                name = "circle",
                state = "off",
                isVisible = true
            },
            {
                name = "circleOn",
                state = "on",
                isVisible = false
            },
            {
                name = "circleDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(handleParams) do
            muiData.widgetDict[options.name]["group"][v.name] = display.newImageRect(options.handle[v.state].image, handleWidth, handleHeight)
            muiData.widgetDict[options.name]["group"][v.name].isVisible = v.isVisible
            muiData.widgetDict[options.name]["group"]:insert(muiData.widgetDict[options.name]["group"][v.name])
        end
    end

    muiData.widgetDict[options.name]["group"]["circle"].name = options.name

    local rect = muiData.widgetDict[options.name]["group"]["rectmaster"]

    rect.muiOptions = options
    muiData.widgetDict[options.name]["group"]["rectmaster"]:addEventListener( "touch", M.toggleSwitchTouch )

    if (options.isChecked ~= nil and options.isChecked == true) or options.state.value == "on" then
        options.state.value = "on"
        options.isChecked = true
        muiData.widgetDict[options.name]["isChecked"] = true
    end
    if options.state.value == "off" then
        M.turnOffToggleSwitch( options )
    elseif options.state.value == "on" then
        M.turnOnToggleSwitch( options )
        M.flipSwitch(options.name, 0)
    elseif options.state.value == "disabled" then
        M.disableToggleSwitch( options )
    end
end

function M.getToggleSwitchProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["group"] -- x,y movement
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- clickable area
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rectmaster"] -- clickable area
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["rect"] -- middle area center
    elseif propertyName == "layer_3" then
        data = muiData.widgetDict[widgetName]["circle1"] -- circle area left
    elseif propertyName == "layer_4" then
        data = muiData.widgetDict[widgetName]["circle2"] -- circle area right
    elseif propertyName == "layer_5" then
        data = muiData.widgetDict[widgetName]["circle"] -- circle for moving within switch
    end
    return data
end

function M.setToggleSwitchFillColor(widgetName, widgetGroup, subName, colorpack)
    if widgetName ~= nil and widgetGroup ~= nil and subName ~= nil and colorpack ~= nil then
        if muiData.widgetDict[widgetName] ~= nil and muiData.widgetDict[widgetName][widgetGroup] ~= nil and muiData.widgetDict[widgetName][widgetGroup][subName] ~= nil then
            muiData.widgetDict[widgetName][widgetGroup][subName]:setFillColor( unpack( colorpack ) )
        end
    end
end

function M.setToggleSwitchVisible(widgetName, widgetGroup, subName, isVisible)
    if widgetName ~= nil and widgetGroup ~= nil and subName ~= nil and isVisible ~= nil then
        if muiData.widgetDict[widgetName] ~= nil and muiData.widgetDict[widgetName][widgetGroup] ~= nil  and muiData.widgetDict[widgetName][widgetGroup][subName] ~= nil then
            muiData.widgetDict[widgetName][widgetGroup][subName].isVisible = isVisible
        end
    end
end

function M.getOptionsForToggleSwitch( name, basename )
    if name == nil then return end
    local options = nil

    if muiData.widgetDict[name]["type"] == "ToggleSwitch" then
        options = muiData.widgetDict[name]["rectmaster"].muiOptions
    end

    return options
end

function M.disableToggleSwitch( options, event )
    M.debug("M.disableToggleSwitch()")
    local val = false
    if options == nil then return val end
    if options.state.value ~= "disabled" then return val end

    val = true

    if muiData.widgetDict[options.name] == nil then return val end

    muiData.widgetDict[options.name].disabled = true

    if muiData.widgetDict[options.name]["type"] == "ToggleSwitch" then
        -- change color
        if options.handle.disabled.image == nil and options.handle.disabled.svg == nil and options.handle.disabled.color ~= nil then
            -- rect, circle1, circle2, circle
            M.setToggleSwitchFillColor(options.name, "group", "circle", options.handle.disabled.color)
            M.setToggleSwitchFillColor(options.name, "group", "rect", options.bar.disabled.color)
            M.setToggleSwitchFillColor(options.name, "group", "circle1", options.bar.disabled.color)
            M.setToggleSwitchFillColor(options.name, "group", "circle2", options.bar.disabled.color)
        end

        -- change image or svg
        if options.handle.disabled.image ~= nil or options.handle.disabled.svg ~= nil then
            M.setToggleSwitchVisible(options.name, "group", "circle", false)
            M.setToggleSwitchVisible(options.name, "group", "circleOn", false)
            M.setToggleSwitchVisible(options.name, "group", "circleDisabled", true)
            M.setToggleSwitchVisible(options.name, "group", "rect", false)
            M.setToggleSwitchVisible(options.name, "group", "rectOn", false)
            M.setToggleSwitchVisible(options.name, "group", "rectDisabled", true)
        end
    end

    if muiData.currentControl == options.name then
        M.resetCurrentControlVars()
    end

    return val
end

function M.turnOnToggleSwitchByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForToggleSwitch(name, basename)

    if options ~= nil then
        M.turnOnToggleSwitch( options )
    end
end

function M.turnOnToggleSwitch( options, event )
    -- body
    M.debug("M.turnOnToggleSwitch()")

    options.state.value = "on"
    if event ~= nil then
        if options.handle.on.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.handle.on.callBackData)
            assert( options.handle.on.callBack )(event)
        end
    end

    if muiData.widgetDict[options.name] == nil then return end

    if muiData.widgetDict[options.name]["type"] == "ToggleSwitch" then

        if options.handle.on.image == nil and options.handle.on.svg == nil and options.handle.on.color ~= nil then
            -- rect, circle1, circle2, circle
            M.setToggleSwitchFillColor(options.name, "group", "circle", options.handle.on.color)
            M.setToggleSwitchFillColor(options.name, "group", "rect", options.bar.on.color)
            M.setToggleSwitchFillColor(options.name, "group", "circle1", options.bar.on.color)
            M.setToggleSwitchFillColor(options.name, "group", "circle2", options.bar.on.color)
        end

        -- change image or svg
        if options.handle.on.image ~= nil or options.handle.on.svg ~= nil then
            M.setToggleSwitchVisible(options.name, "group", "circle", false)
            M.setToggleSwitchVisible(options.name, "group", "circleOn", true)
            M.setToggleSwitchVisible(options.name, "group", "circleDisabled", false)
            M.setToggleSwitchVisible(options.name, "group", "rect", false)
            M.setToggleSwitchVisible(options.name, "group", "rectOn", true)
            M.setToggleSwitchVisible(options.name, "group", "rectDisabled", false)
        end

        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    end
end

-- params...
-- name: name of button
-- basename: only required if RadioButton
function M.turnOffToggleSwitchByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForToggleSwitch(name, basename)

    if options ~= nil then
        M.turnOffToggleSwitch( options )
    end
end

function M.turnOffToggleSwitch( options, event, skipInterfaceUpdate )
    -- body
    M.debug("M.turnOffToggleSwitch()")

    skipInterfaceUpdate = skipInterfaceUpdate or false

    options.state.value = "off"
    if event ~= nil then
        if options.handle.off.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.handle.off.callBackData)
            assert( options.handle.off.callBack )(event)
        end
    end

    if muiData.widgetDict[options.name] == nil then return end

    if muiData.widgetDict[options.name]["type"] == "ToggleSwitch" and skipInterfaceUpdate == false then

        if options.handle.off.image == nil and options.handle.off.svg == nil and options.handle.off.color ~= nil then
            -- rect, circle1, circle2, circle
            M.setToggleSwitchFillColor(options.name, "group", "circle", options.handle.off.color)
            M.setToggleSwitchFillColor(options.name, "group", "rect", options.bar.off.color)
            M.setToggleSwitchFillColor(options.name, "group", "circle1", options.bar.off.color)
            M.setToggleSwitchFillColor(options.name, "group", "circle2", options.bar.off.color)
        end

        -- revert to normal icon
        if muiData.widgetDict[options.name].slidercircle ~= nil then
            M.setObjectVisible(options.name, "slidercircle", true)
            M.setObjectVisible(options.name, "slidercircleOn", false)
            M.setObjectVisible(options.name, "slidercircleDisabled", false)
        end

        -- change image or svg
        if options.handle.off.image ~= nil or options.handle.off.svg ~= nil then
            M.setToggleSwitchVisible(options.name, "group", "circle", true)
            M.setToggleSwitchVisible(options.name, "group", "circleOn", false)
            M.setToggleSwitchVisible(options.name, "group", "circleDisabled", false)
            M.setToggleSwitchVisible(options.name, "group", "rect", true)
            M.setToggleSwitchVisible(options.name, "group", "rectOn", false)
            M.setToggleSwitchVisible(options.name, "group", "rectDisabled", false)
        end
    end
    if muiData.currentControl == options.name then
        M.resetCurrentControlVars()
    end
end

function M.toggleSwitchTouch (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if muiData.dialogInUse == true and options.dialogName ~= nil then return end

    if muiData.currentControl == nil then
        muiData.currentControl = options.name
        muiData.currentControlType = "mui-slider"
    end

    if M.disableToggleSwitch( options, event ) then
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
        muiData.interceptEventHandler = M.toggleSwitchTouch
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end

        M.turnOnToggleSwitch( options, event )

        M.updateUI(event)
        if muiData.touching == false and false then
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - muiData.widgetDict[options.basename]["radio"][options.name]["group"].x
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - muiData.widgetDict[options.basename]["radio"][options.name]["group"].y
            end
            transition.to(event.target,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
        else
            event.phase = "onTarget"
            if muiData.interceptMoved == false then
                event.target = muiData.widgetDict[options.name]["rect"]
                if muiData.widgetDict[options.name]["isChecked"] == true then
                    muiData.widgetDict[options.name]["isChecked"] = false
                    M.setEventParameter(event, "muiTargetValue", nil)
                else
                    muiData.widgetDict[options.name]["isChecked"] = true
                    M.setEventParameter(event, "muiTargetValue", options.value)
                    muiData.widgetDict[options.name]["value"] = options.value
                end
                M.setEventParameter(event, "muiTargetChecked", muiData.widgetDict[options.name]["isChecked"])
                M.flipSwitch(options.name, nil)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rect"])
                event.callBackData = options.callBackData
                assert( options.callBack )(event)
            end
            M.turnOffToggleSwitch( options, event, muiData.widgetDict[options.name]["isChecked"] )
            muiData.interceptEventHandler = nil
            muiData.interceptOptions = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
        M.processEventQueue()
        M.sliderPercentComplete(event, options)
    else
        M.addToEventQueue( options )
    end
    muiData.touched = true
    return true -- prevent propagation to other controls
end

function M.flipSwitch(widgetName, delay)
    if widgetName == nil then return end
    if delay == nil then delay = 250 end

    local options = muiData.widgetDict[widgetName].options
    local isChecked = muiData.widgetDict[widgetName]["isChecked"]
    local xR = muiData.widgetDict[widgetName]["group"]["rect"].contentWidth * 0.75
    local x = xR

    if options.handle.off.image == nil and options.handle.off.svg == nil then
        if isChecked == false then
            x = x - (xR * 2)
        end
        if isChecked == true then
            transition.to( muiData.widgetDict[widgetName]["group"]["circle"], { time=delay, x=x, onComplete=M.turnOnSwitch } )
        else
            transition.to( muiData.widgetDict[widgetName]["group"]["circle"], { time=delay, x=x, onComplete=M.turnOffSwitch } )
        end
    else
        -- get width and set 
        local rectWidth = muiData.widgetDict[widgetName]["group"]["rect"].contentWidth
        local circleWidth = muiData.widgetDict[widgetName]["group"]["circle"].contentWidth
        local dx = (rectWidth / 2) - (circleWidth / 2)
        if isChecked == true then
            transition.to( muiData.widgetDict[widgetName]["group"]["circle"], { time=delay, x=dx, onComplete=M.turnOnSwitch } )
            transition.to( muiData.widgetDict[widgetName]["group"]["circleOn"], { time=delay, x=dx } )
        else
            dx = -(dx)
            transition.to( muiData.widgetDict[widgetName]["group"]["circle"], { time=delay, x=dx, onComplete=M.turnOffSwitch } )
            transition.to( muiData.widgetDict[widgetName]["group"]["circleOn"], { time=delay, x=dx } )
        end
    end
end

function M.turnOnSwitch(e)
    local options = muiData.widgetDict[e.name].options
    if options.handle.on ~= nil then
        if options.handle.off.image == nil and options.handle.off.svg == nil then
            e:setFillColor( unpack(options.handle.on.color) )
            muiData.widgetDict[e.name]["group"]["rect"]:setFillColor( unpack(options.bar.on.color) )
            muiData.widgetDict[e.name]["group"]["circle1"]:setFillColor( unpack(options.bar.on.color) )
            muiData.widgetDict[e.name]["group"]["circle2"]:setFillColor( unpack(options.bar.on.color) )
        end
        muiData.widgetDict[e.name]["isChecked"] = true
    end
end

function M.turnOffSwitch(e)
    local options = muiData.widgetDict[e.name].options
    if options.handle.off ~= nil then
        if options.handle.off.image == nil and options.handle.off.svg == nil then
            e:setFillColor( unpack(options.handle.off.color) )
            muiData.widgetDict[e.name]["group"]["rect"]:setFillColor( unpack(options.bar.on.color) )
            muiData.widgetDict[e.name]["group"]["circle1"]:setFillColor( unpack(options.bar.on.color) )
            muiData.widgetDict[e.name]["group"]["circle2"]:setFillColor( unpack(options.bar.on.color) )
        end
        muiData.widgetDict[e.name]["isChecked"] = false
    end
end

function M.actionForSwitch(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")
    local muiTargetChecked = M.getEventParameter(event, "muiTargetChecked")

    if muiTargetValue ~= nil then
        M.debug("toggle switch value: " .. muiTargetValue)
    end

    if muiTargetChecked == nil then muiTargetChecked = false end
    if muiTargetChecked == true then
        M.debug("toggle switch on")
    else
        M.debug("toggle switch off")
    end
end

function M.removeWidgetToggleSwitch(widgetName)
    M.removeToggleSwitch(widgetName)
end

function M.removeToggleSwitch(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if muiData.widgetDict[widgetName]["group"]["rectSvgOff"] ~= nil then
        muiData.widgetDict[widgetName]["group"]["rectSvgOff"]:removeSelf()
        muiData.widgetDict[widgetName]["group"]["rectSvgOff"] = nil
    end
    if muiData.widgetDict[widgetName]["group"]["rectSvgOn"] ~= nil then
        muiData.widgetDict[widgetName]["group"]["rectSvgOn"]:removeSelf()
        muiData.widgetDict[widgetName]["group"]["rectSvgOn"] = nil
    end
    if muiData.widgetDict[widgetName]["group"]["rectSvgDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["group"]["rectSvgDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["group"]["rectSvgDisabled"] = nil
    end

    if muiData.widgetDict[widgetName]["group"]["HandleSvgOff"] ~= nil then
        muiData.widgetDict[widgetName]["group"]["HandleSvgOff"]:removeSelf()
        muiData.widgetDict[widgetName]["group"]["HandleSvgOff"] = nil
    end
    if muiData.widgetDict[widgetName]["group"]["HandleSvgOn"] ~= nil then
        muiData.widgetDict[widgetName]["group"]["HandleSvgOn"]:removeSelf()
        muiData.widgetDict[widgetName]["group"]["HandleSvgOn"] = nil
    end
    if muiData.widgetDict[widgetName]["group"]["HandleSvgDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["group"]["HandleSvgDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["group"]["HandleSvgDisabled"] = nil
    end

    muiData.widgetDict[widgetName]["group"]["circle"]:removeSelf()
    muiData.widgetDict[widgetName]["group"]["circle"] = nil
    muiData.widgetDict[widgetName]["group"]["circle2"]:removeSelf()
    muiData.widgetDict[widgetName]["group"]["circle2"] = nil
    muiData.widgetDict[widgetName]["group"]["circle1"]:removeSelf()
    muiData.widgetDict[widgetName]["group"]["circle1"] = nil
    muiData.widgetDict[widgetName]["group"]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["group"]["rect"] = nil
    muiData.widgetDict[widgetName]["group"]["rectmaster"]:removeEventListener("touch", M.toggleSwitchTouch)
    muiData.widgetDict[widgetName]["group"]["rectmaster"]:removeSelf()
    muiData.widgetDict[widgetName]["group"]["rectmaster"] = nil
    muiData.widgetDict[widgetName]["group"]:removeSelf()
    muiData.widgetDict[widgetName]["group"] = nil
    muiData.widgetDict[widgetName] = nil
    M.resetCurrentControlVars()
end

return M
