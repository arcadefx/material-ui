--[[
    A loosely based Material UI module

    mui-progressarc.lua : This is for creating progress arcs. Percentage based (0..100%)

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

--
-- createProgressArc
--
function M.createProgressArc(options)
    M.newProgressArc(options)
end

function M.newProgressArc(options)
    if options == nil then return end

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    if options.foregroundColor == nil then
        options.foregroundColor = { 0, 0, 1, 0, 1 }
    end

    if options.backgroundColor == nil then
        options.backgroundColor = { 0, 0, 1, 0, 0.8 }
    end

    if options.angle == nil then options.angle = 180 end
    if options.outer == nil then options.outer = 100 end
    if options.inner == nil then options.inner = 40 end
    if options.fromAngle == nil then options.fromAngle = 0 end
    if options.range == nil then options.range = 1 end
    if options.time == nil then options.time = 2000 end
    if options.progressIndicator == nil then options.progressIndicator = "endpoint" end
    options.strokerColor = options.backgroundStrokeColor or { 0, 0, 0 }

    if options.iterations == nil then
        options.iterations = 1
    end

    local startPercent = 1
    if options.startPercent == nil then
        options.startPercent = 1
    else
        if options.startPercent < 1 then options.startPercent = 1 end
        if options.startPercent > 100 then options.startPercent = 100 end
    end
    startPercent = options.startPercent
    options.startPercent = options.startPercent / 100

    if options.hideBackdropWhenDone == nil then
        options.hideBackdropWhenDone = false
    end

    options.embossedColor = nil
    if options.labelStyle == "embossed" then
        options.labelEmbossedHighlight = options.labelEmbossedHighlight or { r=1, g=1, b=1 }
        options.labelEmbossedShadow = options.labelEmbossedShadow or { r=0.3, g=0.3, b=0.3 }

        options.embossedColor = 
        {
            highlight = options.labelEmbossedHighlight,
            shadow = options.labelEmbossedShadow
        }
    end

    muiData.widgetDict[options.name] = {}

    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"].x = 0
    muiData.widgetDict[options.name]["mygroup"].y = 0
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    muiData.widgetDict[options.name]["busy"] = false
    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name]["type"] = "ProgressArc"

    local arc_options = {
        x = options.x or 0,
        y = options.y or 0,
        angle = options.angle,
        inner = options.inner, -- inner - outer is arc thinkness
        outer = options.outer,
        fromAngle = options.fromAngle, -- start angle at
        range = options.range, -- range to start rendering using time delay below
        time = options.time,
        strokeColor = options.backgroundColor, -- color of the Arc
    }
    muiData.widgetDict[options.name]["progressbackdrop"] = M.newArc(arc_options)

    muiData.widgetDict[options.name]["progressarc"] = display.newGroup()
    muiData.widgetDict[options.name]["progressarc"].arc_options = {
        group = muiData.widgetDict[options.name]["progressarc"],
        name = options.name,
        x = options.x or 0,
        y = options.y or 0,
        angle = options.angle,
        inner = options.inner, -- inner - outer is arc thinkness
        outer = options.outer,
        fromAngle = options.fromAngle, -- start angle at
        toAngle = (options.angle * options.startPercent),
        range = options.range, -- range to start rendering using time delay below
        time = options.time,
        strokeColor = options.foregroundColor, -- color of the Arc
        updatePercent = options.updatePercent,
        lastUpdatePercent = 0,
        lastPercent = 0,
        callBackUpdate = M.updatePercent,
        onCycle = options.onCycle,
        onComplete = options.onComplete, -- if needed, call the function when percentage is completed.
        onCompleteInternal = M.processQueue, -- internal usage only
    }
    --muiData.widgetDict[options.name]["progressarc"] = M.newArcByRenderTime(arc_options)

    muiData.widgetDict[options.name]["progressarc"].name = options.name
    muiData.widgetDict[options.name]["progressIndicator"] = options.progressIndicator
    muiData.widgetDict[options.name]["progressarc"].percentComplete = 0

    if options.callBack ~= nil then
        muiData.widgetDict[options.name]["progressarc"].callBack = options.callBack
    end
    if options.onComplete ~= nil then
        muiData.widgetDict[options.name]["progressarc"].onComplete = options.onComplete
    end
    if options.repeatCallBack ~= nil then
        muiData.widgetDict[options.name]["progressarc"].repeatCallBack = options.repeatCallBack
    end
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["progressbackdrop"])
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["progressarc"])

    if options.hideProgressText == false then
        if options.labelText ~= nil and options.labelFontSize ~= nil then
            if options.labelAlign == nil then
                options.labelAlign = "center"
            end
            local textOptions =
            {
                text = "",
                x = options.labelTextX or 0,
                y = options.labelTextY or 0,
                width = options.width,
                font = options.labelFont,
                fontSize = options.labelFontSize,
                align = options.labelAlign,  --new alignment parameter
            }
            if options.embossedColor == nil then
                muiData.widgetDict[options.name]["label"] = display.newText( textOptions )
            else
                muiData.widgetDict[options.name]["label"] = display.newEmbossedText( textOptions )
            end
            muiData.widgetDict[options.name]["label"]:setFillColor( unpack(options.labelColor) )
            if options.embossedColor ~= nil then
                muiData.widgetDict[options.name]["label"]:setEmbossColor( options.embossedColor )
            end
            muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["label"] )
        end
    end
    muiData.widgetDict[options.name]["progressarc"].percentComplete = 0
    if options.hideProgressText == false and muiData.widgetDict[options.name]["progressIndicator"] == "endpoint" then
        muiData.widgetDict[options.name]["label"].text = muiData.widgetDict[options.name]["progressarc"].percentComplete .. "%"
    end
    M.increaseProgressArc( options.name, startPercent )
end

function M.updatePercent( group, range )
    local widgetName = group.name
    percent = 0
    if range > 0 then
        percent = mathFloor(mathFloor(range) / group.muiArcOptions.angle * 100)
    end
    if range > 0 and group.muiArcOptions.onComplete ~= nil and group.muiArcOptions.lastPercent ~= percent then
        local p = mathFloor((range / group.muiArcOptions.angle) * 100)
        muiData.widgetDict[widgetName]["progressarc"].percentComplete = p
        muiData.widgetDict[widgetName]["progressarc"].range = range
        if muiData.widgetDict[widgetName]["label"] ~= nil and muiData.widgetDict[widgetName]["progressIndicator"] == "continuous" then
            muiData.widgetDict[widgetName]["label"].text = muiData.widgetDict[widgetName]["progressarc"].percentComplete .. "%"
        end
    end
    group.muiArcOptions.lastPercent = percent
    if group.muiArcOptions.onCycle ~= nil then
        assert(group.muiArcOptions.onCycle)( group, range )
    end
end

function M.getProgressArcProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetName]["label"] -- the progress text
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["progressarc"].percentComplete
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["progressbackdrop"] -- backdrop of whole bar
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["progressarc"] -- the bar that gets sized horizontally
    end
    return data
end


--
--
--
function M.processQueue(data)
    if data == nil then return end
    local widgetName = data.name
    muiData.widgetDict[widgetName]["busy"] = false
    if #muiData.progressarcDict > 0 then
        M.increaseProgressArc(widgetName, 1, true) -- force processing
    end
    if muiData.widgetDict[widgetName]["label"] ~= nil and muiData.widgetDict[widgetName]["progressIndicator"] == "endpoint" then
        muiData.widgetDict[widgetName]["label"].text = muiData.widgetDict[widgetName]["progressarc"].percentComplete .. "%"
    end
end

--
-- expects: widget name and percent to increase the progress bar by.
--
-- example: M.increaseProgressArc("foo", 20) -- increase progress bar widget named "foo" by 20%
--
-- note: queue any additional increases if already processing one
--
function M.increaseProgressArc( widgetName, percent, __forceprocess__ )
    if percent < 1 and __forceprocess__ == nil then return end
    if muiData.widgetDict[widgetName] == nil then return end

    local options = muiData.widgetDict[widgetName]["options"]
    if muiData.widgetDict[widgetName]["transition"] ~= nil and options.iterations == -1 then
        return
    end
    if muiData.widgetDict[widgetName]["busy"] == true and percent ~= nil and percent > -1 then
        -- queue the percent increase for later processing
        table.insert(muiData.progressarcDict, {name=widgetName, value=percent})
        return
    elseif #muiData.progressarcDict > 0 then
        -- find entry
        local idx = 0
        for i, v in ipairs(muiData.progressarcDict) do
           if v.name == widgetName then
                idx = i
                percent = v.value
                percent = percent + muiData.widgetDict[widgetName]["progressarc"].percentComplete
                break
           end
        end
        if idx > 0 then table.remove(muiData.progressarcDict, idx) end
    end

    muiData.widgetDict[widgetName]["busy"] = true
    muiData.widgetDict[widgetName]["progressarc"].arc_options.toAngle = muiData.widgetDict[widgetName]["progressarc"].arc_options.angle * (percent / 100)
    if muiData.widgetDict[widgetName]["progressarc"].range ~= nil then
        muiData.widgetDict[widgetName]["progressarc"].arc_options.range = muiData.widgetDict[widgetName]["progressarc"].range + 1
    end
    M.newArcByRenderTime(muiData.widgetDict[widgetName]["progressarc"].arc_options)
end

function M.repeatProgressArcCallBack( object )
    -- M.debug("repeatProgressArcCallBack")
    if object.callBack ~= nil then
        assert(object.callBack)( object )
    end
end

function M.postProgressArcCompleteCallBack( object )
    if object.name ~= nil then
        if muiData.widgetDict[object.name] == nil then return end
        if object.onComplete ~= nil then
            assert(object.onComplete)( object )
        end
    end
end

function M.completeProgressArcFinalCallBack(object)
    if object.name ~= nil then
        if muiData.widgetDict[object.name] == nil then return end
        muiData.widgetDict[object.name]["progressarc"].isVisible = false
        if object.callBack ~= nil then
            assert(object.callBack)( object )
        end
    end
end

function M.postProgressArcCallBack( object )
    M.debug("postProgressCallBack")
end

function M.removeWidgetProgressArc(widgetName)
    M.removeProgressArc(widgetName)
end

function M.removeProgressArc(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    M.removeNewArcByRenderTime( muiData.widgetDict[widgetName]["progressbackdrop"] )
    -- muiData.widgetDict[widgetName]["progressbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["progressbackdrop"] = nil

    M.removeNewArcByRenderTime( muiData.widgetDict[widgetName]["progressarc"] )
    -- muiData.widgetDict[widgetName]["progressarc"]:removeSelf()
    muiData.widgetDict[widgetName]["progressarc"] = nil

    if muiData.widgetDict[widgetName]["label"] ~= nil then
        muiData.widgetDict[widgetName]["label"]:removeSelf()
        muiData.widgetDict[widgetName]["label"] = nil
    end
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

return M
