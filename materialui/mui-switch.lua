--[[
    A loosely based Material UI module

    mui-switch.lua : This is for creating simple toggle switches.

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

    local textColorOff = { 1, 1, 1 }
    if options.textColorOff ~= nil then
        textColorOff = options.textColorOff
    end

    local textColor = { 1, 1, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    if options.backgroundColor == nil then
        options.backgroundColor = { 0, 0, 1, 0, 0.8 }
    end

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name]["isChecked"] = isChecked
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "ToggleSwitch"
    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"]:translate( x, y )
    muiData.widgetDict[options.name]["touching"] = false

    if options.callBack ~= nil then
        muiData.widgetDict[options.name]["callBack"] = options.callBack
    end

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    local radius = options.height

    x = 0
    y = 0
    muiData.widgetDict[options.name]["mygroup"]["rectmaster"] = display.newRect( x, y, options.width * 1.3, (options.height * 0.75))
    muiData.widgetDict[options.name]["mygroup"]["rectmaster"].strokeWidth = 0
    muiData.widgetDict[options.name]["mygroup"]["rectmaster"]:setStrokeColor( unpack({1, 0, 0, 1}) )

    muiData.widgetDict[options.name]["mygroup"]["rect"] = display.newRect( x, y, options.width * 0.5, options.height * 0.5)
    muiData.widgetDict[options.name]["mygroup"]["rect"].strokeWidth = 0
    muiData.widgetDict[options.name]["mygroup"]["rect"]:setFillColor( unpack(options.backgroundColorOff) )

    muiData.widgetDict[options.name]["mygroup"]["circle1"] = display.newCircle( x - (radius * 0.20), y, radius * 0.25 )
    muiData.widgetDict[options.name]["mygroup"]["circle1"]:setFillColor( unpack(options.backgroundColorOff) )

    muiData.widgetDict[options.name]["mygroup"]["circle2"] = display.newCircle( x + (radius * 0.20), y, radius * 0.25 )
    muiData.widgetDict[options.name]["mygroup"]["circle2"]:setFillColor( unpack(options.backgroundColorOff) )

    muiData.widgetDict[options.name]["mygroup"]["circle"] = display.newCircle( x - (radius * 0.25), y, radius * 0.30 )
    muiData.widgetDict[options.name]["mygroup"]["circle"]:setFillColor( unpack(options.textColorOff) )

    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["mygroup"]["rectmaster"])
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["mygroup"]["rect"])
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["mygroup"]["circle1"])
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["mygroup"]["circle2"])
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["mygroup"]["circle"])

    muiData.widgetDict[options.name]["mygroup"]["circle"].name = options.name

    M.flipSwitch(options.name, 0)

    local rect = muiData.widgetDict[options.name]["mygroup"]["rectmaster"]

    rect.muiOptions = options
    muiData.widgetDict[options.name]["mygroup"]["rectmaster"]:addEventListener( "touch", M.toggleSwitchTouch )
end

function M.getToggleSwitchProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
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

function M.toggleSwitchTouch (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if muiData.dialogInUse == true and options.dialogName ~= nil then return end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.toggleSwitchTouch
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        if muiData.touching == false and false then
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].y
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
            muiData.interceptEventHandler = nil
            muiData.interceptOptions = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
    end
    muiData.touched = true
    return true -- prevent propagation to other controls
end

function M.flipSwitch(widgetName, delay)
    if widgetName == nil then return end
    if delay == nil then delay = 250 end

    local isChecked = muiData.widgetDict[widgetName]["isChecked"]
    local xR = muiData.widgetDict[widgetName]["mygroup"]["rect"].contentWidth * 0.75
    local x = xR
    if isChecked == false then
        x = x - (xR * 2)
    end
    if isChecked == true then
        transition.to( muiData.widgetDict[widgetName]["mygroup"]["circle"], { time=delay, x=x, onComplete=M.turnOnSwitch } )
    else
        transition.to( muiData.widgetDict[widgetName]["mygroup"]["circle"], { time=delay, x=x, onComplete=M.turnOffSwitch } )
    end
end

function M.turnOnSwitch(e)
    local options = muiData.widgetDict[e.name].options
    e:setFillColor( unpack(options.textColor) )
    muiData.widgetDict[e.name]["mygroup"]["rect"]:setFillColor( unpack(options.backgroundColor) )
    muiData.widgetDict[e.name]["mygroup"]["circle1"]:setFillColor( unpack(options.backgroundColor) )
    muiData.widgetDict[e.name]["mygroup"]["circle2"]:setFillColor( unpack(options.backgroundColor) )
    muiData.widgetDict[e.name]["isChecked"] = true
end

function M.turnOffSwitch(e)
    local options = muiData.widgetDict[e.name].options
    e:setFillColor( unpack(options.textColorOff) )
    muiData.widgetDict[e.name]["mygroup"]["rect"]:setFillColor( unpack(options.backgroundColorOff) )
    muiData.widgetDict[e.name]["mygroup"]["circle1"]:setFillColor( unpack(options.backgroundColorOff) )
    muiData.widgetDict[e.name]["mygroup"]["circle2"]:setFillColor( unpack(options.backgroundColorOff) )
    muiData.widgetDict[e.name]["isChecked"] = false
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

    muiData.widgetDict[widgetName]["mygroup"]["circle"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["circle"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["circle2"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["circle2"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["circle1"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["circle1"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["rect"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["rectmaster"]:removeEventListener("touch", M.toggleSwitchTouch)
    muiData.widgetDict[widgetName]["mygroup"]["rectmaster"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["rectmaster"] = nil
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

return M
