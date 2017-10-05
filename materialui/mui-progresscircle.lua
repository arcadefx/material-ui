--[[
    A loosely based Material UI module

    mui-progresscircle.lua : This is for creating progress circles. Percentage based (0..100%)

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
-- createProgressCircle
--
--[[
  params:
    name = <name of widget>
    radius = <val>,
    x = display.contentCenterX,
    y = display.contentCenterY,
    foregroundColor = { 0, 0.78, 1, 1 },
    backgroundColor = { 0.82, 0.95, 0.98, 0.8 },
    startPercent = 20,
    fillType = "outward", -- "outward" or "inward"
    iterations = 1,
    labelText = "20%",
    labelFont = native.systemFont,
    labelFontSize = 18,
    labelColor = {  0.4, 0.4, 0.4, 1 },
    labelAlign = "center",
    labelStyle = "basic", -- "basic" or "embossed"
    labelEmbossedHighlight = { R,G,B,A},
    labelEmbossedShadow = { R,G,B,A},
    callBack = mui.postProgressCallBack,
    --repeatCallBack = <your method here>,
    hideBackdropWhenDone = false
--]]--
function M.createProgressCircle(options)
    M.newProgressCircle(options)
end

function M.newProgressCircle(options)
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

    options.backgroundStrokeWidth = options.backgroundStrokeWidth or 5
    options.backgroundStrokeColor = options.backgroundStrokeColor or { 0, 0, 0 }

    if options.iterations == nil then
        options.iterations = 1
    end

    if options.fillType == nil then
        options.fillType = "outward" -- or "inward"
        -- options.iterations = -1
    end

    if options.delay == nil then
        options.delay = 500
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

    local objectSize = (options.radius or 100)
    objectSize = objectSize * 2

    muiData.widgetDict[options.name]["mygroup"] = display.newContainer(objectSize, objectSize)
    muiData.widgetDict[options.name]["mygroup"].x = x
    muiData.widgetDict[options.name]["mygroup"].y = y
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
    muiData.widgetDict[options.name]["type"] = "ProgressCircle"
    muiData.widgetDict[options.name]["progressbackdrop"] = display.newCircle( 0, 0, options.radius - options.backgroundStrokeWidth)
    muiData.widgetDict[options.name]["progressbackdrop"]:setFillColor( unpack(options.backgroundColor) )
    muiData.widgetDict[options.name]["progressbackdrop"].strokeWidth = options.backgroundStrokeWidth
    muiData.widgetDict[options.name]["progressbackdrop"]:setStrokeColor( unpack(options.backgroundStrokeColor) )
    muiData.widgetDict[options.name]["progresscircle"] = display.newCircle( 0, 0, options.radius - options.backgroundStrokeWidth)
    muiData.widgetDict[options.name]["progresscircle"]:setFillColor( unpack(options.foregroundColor) )
    muiData.widgetDict[options.name]["progresscircle"].name = options.name
    muiData.widgetDict[options.name]["progresscircle"].percentComplete = 0

    if options.fillType == "outward" then
        transition.from(muiData.widgetDict[options.name]["progresscircle"], {xScale=0.01,yScale=0.01,time=0})
    else
        transition.to(muiData.widgetDict[options.name]["progresscircle"], {xScale=1,yScale=1,time=0})
    end
    muiData.widgetDict[options.name]["fillType"] = options.fillType

    if options.callBack ~= nil then
        muiData.widgetDict[options.name]["progresscircle"].callBack = options.callBack
    end
    if options.onComplete ~= nil then
        muiData.widgetDict[options.name]["progresscircle"].onComplete = options.onComplete
    end
    if options.repeatCallBack ~= nil then
        muiData.widgetDict[options.name]["progresscircle"].repeatCallBack = options.repeatCallBack
    end
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["progressbackdrop"])
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["progresscircle"])

    if options.labelText ~= nil and options.labelFontSize ~= nil then
        if options.labelAlign == nil then
            options.labelAlign = "center"
        end
        local textOptions =
        {
            text = "",
            x = 0,
            y = 0,
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

    muiData.widgetDict[options.name]["progresscircle"].percentComplete = 0
    M.increaseProgressCircle( options.name, startPercent )
end

function M.getProgressCircleProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetName]["label"] -- the progress text
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["progresscircle"].percentComplete
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["progressbackdrop"] -- backdrop of whole bar
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["progresscircle"] -- the bar that gets sized horizontally
    end
    return data
end

--
-- expects: widget name and percent to increase the progress bar by.
--
-- example: M.increaseProgressCircle("foo", 20) -- increase progress bar widget named "foo" by 20%
--
-- note: queue any additional increases if already processing one
--
function M.increaseProgressCircle( widgetName, percent, __forceprocess__ )
    if percent < 1 and __forceprocess__ == nil then return end
    if muiData.widgetDict[widgetName] == nil then return end

    local options = muiData.widgetDict[widgetName]["options"]

    if muiData.widgetDict[widgetName]["transition"] ~= nil and options.iterations == -1 then
        return
    end

    if muiData.widgetDict[widgetName]["busy"] == true then
        -- queue the percent increase for later processing
        table.insert(muiData.progresscircleDict, {name=widgetName, value=percent})
        return
    elseif #muiData.progresscircleDict > 0 then
        -- find entry
        local idx = 0
        for i, v in ipairs(muiData.progresscircleDict) do
           if v.name == widgetName then
                idx = i
                percent = v.value
                break
           end
        end
        if idx > 0 then table.remove(muiData.progresscircleDict, idx) end
    end

    muiData.widgetDict[widgetName]["busy"] = true

    muiData.widgetDict[widgetName]["progresscircle"].percentComplete = muiData.widgetDict[widgetName]["progresscircle"].percentComplete + percent

    muiData.widgetDict[options.name]["label"].text = muiData.widgetDict[widgetName]["progresscircle"].percentComplete .. "%"

    local percentComplete = muiData.widgetDict[widgetName]["progresscircle"].percentComplete
    if muiData.widgetDict[widgetName]["progresscircle"].percentComplete > 100 then
        percentComplete = 100
    end
    if options.fillType == "outward" then
        muiData.widgetDict[options.name]["transition"] = transition.to( muiData.widgetDict[options.name]["progresscircle"], {
            time = options.delay,
            xScale = percentComplete / 100,
            yScale = percentComplete / 100,
            transition = easing.linear,
            iterations = options.iterations,
            onComplete = M.completeProgressCircleCallBack,
            onRepeat = M.repeatProgressCircleCallBack,
        } )
    else
        if muiData.widgetDict[widgetName]["progresscircle"].percentComplete > 100 then
            percentComplete = 100
        end
        muiData.widgetDict[options.name]["transition"] = transition.to( muiData.widgetDict[options.name]["progresscircle"], {
            time = options.delay,
            xScale = 1 - (percentComplete / 100),
            yScale = 1 - (percentComplete / 100),
            transition = easing.linear,
            iterations = options.iterations,
            onComplete = M.completeProgressCircleCallBack,
            onRepeat = M.repeatProgressCircleCallBack,
        } )
    end
end

function M.repeatProgressCircleCallBack( object )
    -- M.debug("repeatProgressCircleCallBack")
    if object.callBack ~= nil then
        assert(object.callBack)( object )
    end
end

function M.completeProgressCircleCallBack( object )
    -- M.debug("completeProgressCircleCallBack")
    if object.name == nil then return end
    if muiData.widgetDict[object.name] == nil then return end

    muiData.widgetDict[object.name]["busy"] = false

    if object.noFinishAnimation == nil and object.percentComplete >= 99 and muiData.widgetDict[object.name]["fillType"] == "outward" then
        transition.fadeOut( muiData.widgetDict[object.name]["progresscircle"], {onComplete=M.completeProgressCircleFinalCallBack})
    elseif #muiData.progresscircleDict > 0 then
        M.increaseProgressCircle( object.name, 1, "__forceprocess__")
    else
        M.postProgressCircleCompleteCallBack(object)
    end
    muiData.widgetDict[object.name]["label"].text = object.percentComplete .. "%"
end

function M.postProgressCircleCompleteCallBack( object )
    if object.name ~= nil then
        if muiData.widgetDict[object.name] == nil then return end
        if object.onComplete ~= nil then
            assert(object.onComplete)( object )
        end
    end
end

function M.completeProgressCircleFinalCallBack(object)
    if object.name ~= nil then
        if muiData.widgetDict[object.name] == nil then return end
        muiData.widgetDict[object.name]["progresscircle"].isVisible = false
        if object.callBack ~= nil then
            assert(object.callBack)( object )
        end
    end
end

function M.postProgressCircleCallBack( object )
    M.debug("postProgressCallBack")
end

function M.removeWidgetProgressCircle(widgetName)
    M.removeProgressCircle(widgetName)
end

function M.removeProgressCircle(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["progressbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["progressbackdrop"] = nil
    muiData.widgetDict[widgetName]["progresscircle"]:removeSelf()
    muiData.widgetDict[widgetName]["progresscircle"] = nil
    if muiData.widgetDict[widgetName]["label"] ~= nil then
        muiData.widgetDict[widgetName]["label"]:removeSelf()
        muiData.widgetDict[widgetName]["label"] = nil
    end
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

return M
