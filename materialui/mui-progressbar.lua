--[[
    A loosely based Material UI module

    mui-progresbar.lua : This is for creating progress bars. Percentage based (0..100%)

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
-- createProgressBar
--
--[[
  params:
    name = <name of widget>
    width = <val>,
    height = <val>,
    x = <val>,
    y = <val>,
    foregroundColor = { 0, 0.78, 1, 1 },
    backgroundColor = { 0.82, 0.95, 0.98, 0.8 },
    startPercent = 20,
    barType = "determinate",
    iterations = 1,
    labelText = "Determinate: progress bar",
    labelFont = native.systemFont,
    labelFontSize = 16,
    labelColor = {  0.4, 0.4, 0.4, 1 },
    labelAlign = "center",
    callBack = mui.postProgressCallBack,
    --repeatCallBack = <your method here>,
    hideBackdropWhenDone = false
--]]--
function M.createProgressBar(options)
    M.newProgressBar(options)
end

function M.newProgressBar(options)
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
        options.width = muiData.contentWidth * 0.70
    end

    if options.height == nil then
        options.height = 4
    end

    if options.foregroundColor == nil then
        options.foregroundColor = { 0, 0, 1, 0, 1 }
    end

    if options.backgroundColor == nil then
        options.backgroundColor = { 0, 0, 1, 0, 0.8 }
    end

    if options.iterations == nil then
        options.iterations = 1
    end

    if options.barType == nil then
        -- options.type = "indeterminate"
        -- options.iterations = -1
    end

    if options.delay == nil then
        options.delay = 1500
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

    muiData.widgetDict[options.name] = {}

    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
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

    if options.labelText ~= nil and options.labelFontSize ~= nil then
        if options.labelAlign == nil then
            options.labelAlign = "center"
        end
        local textOptions =
        {
            text = options.labelText,
            x = options.width * 0.5,
            y = -(options.height + options.labelFontSize),
            width = options.width,
            font = options.labelFont,
            fontSize = options.labelFontSize,
            align = options.labelAlign  --new alignment parameter
        }
        muiData.widgetDict[options.name]["label"] = display.newText( textOptions )
        muiData.widgetDict[options.name]["label"]:setFillColor( unpack(options.labelColor) )
        muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["label"] )
    end

    muiData.widgetDict[options.name]["busy"] = false
    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name]["type"] = "ProgressBar"
    muiData.widgetDict[options.name]["progressbackdrop"] = display.newLine( 1, 0, 1+options.width, 0)
    muiData.widgetDict[options.name]["progressbackdrop"].strokeWidth = options.height
    muiData.widgetDict[options.name]["progressbackdrop"]:setStrokeColor( unpack(options.backgroundColor) )
    muiData.widgetDict[options.name]["progressbackdrop"].hideBackdropWhenDone = options.hideBackdropWhenDone
    muiData.widgetDict[options.name]["progressbar"] = display.newLine( 1, 0, 1+(options.width * 0.01), 0)
    muiData.widgetDict[options.name]["progressbar"].strokeWidth = options.height
    muiData.widgetDict[options.name]["progressbar"]:setStrokeColor( unpack(options.foregroundColor) )
    muiData.widgetDict[options.name]["progressbar"].name = options.name
    muiData.widgetDict[options.name]["progressbar"].percentComplete = 0
    if options.callBack ~= nil then
        muiData.widgetDict[options.name]["progressbar"].callBack = options.callBack
    end
    if options.onComplete ~= nil then
        muiData.widgetDict[options.name]["progressbar"].onComplete = options.onComplete
    end
    if options.repeatCallBack ~= nil then
        muiData.widgetDict[options.name]["progressbar"].repeatCallBack = options.repeatCallBack
    end
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["progressbackdrop"])
    muiData.widgetDict[options.name]["mygroup"]:insert(muiData.widgetDict[options.name]["progressbar"])

    muiData.widgetDict[options.name]["progressbar"].percentComplete = 1
    M.increaseProgressBar( options.name, startPercent )
end

function M.getProgressBarProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetName]["label"] -- the progress text
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["progressbar"].percentComplete
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["progressbackdrop"] -- backdrop of whole bar
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["progressbar"] -- the bar that gets sized horizontally
    end
    return data
end

--
-- expects: widget name and percent to increase the progress bar by.
--
-- example: M.increaseProgressBar("foo", 20) -- increase progress bar widget named "foo" by 20%
--
-- note: queue any additional increases if already processing one
--
function M.increaseProgressBar( widgetName, percent, __forceprocess__ )
    if percent < 1 and __forceprocess__ == nil then return end
    if muiData.widgetDict[widgetName] == nil then return end

    local options = muiData.widgetDict[widgetName]["options"]

    if muiData.widgetDict[widgetName]["transition"] ~= nil and options.iterations == -1 then
        return
    end

    if muiData.widgetDict[widgetName]["busy"] == true then
        -- queue the percent increase for later processing
        table.insert(muiData.progressbarDict, {name=widgetName, value=percent})
        return
    elseif #muiData.progressbarDict > 0 then
        -- find entry
        local idx = 0
        for i, v in ipairs(muiData.progressbarDict) do
           if v.name == widgetName then
                idx = i
                percent = v.value
                break
           end
        end
        if idx > 0 then table.remove(muiData.progressbarDict, idx) end
    end

    muiData.widgetDict[widgetName]["busy"] = true

    muiData.widgetDict[widgetName]["progressbar"].percentComplete = muiData.widgetDict[widgetName]["progressbar"].percentComplete + percent

    muiData.widgetDict[options.name]["transition"] = transition.to( muiData.widgetDict[options.name]["progressbar"], {
        time = options.delay,
        xScale = muiData.widgetDict[widgetName]["progressbar"].percentComplete,
        transition = easing.linear,
        iterations = options.iterations,
        onComplete = M.completeProgressBarCallBack,
        onRepeat = M.repeatProgressBarCallBack
    } )

end

function M.repeatProgressBarCallBack( object )
    -- M.debug("repeatProgressBarCallBack")
    if object.callBack ~= nil then
        assert(object.callBack)( object )
    end
end

function M.completeProgressBarCallBack( object )
    -- M.debug("completeProgressBarCallBack")
    if object.name == nil then return end
    if muiData.widgetDict[object.name] == nil then return end

    muiData.widgetDict[object.name]["busy"] = false

    if object.noFinishAnimation == nil and object.percentComplete >= 99 then
        transition.to( muiData.widgetDict[object.name]["progressbar"], {
            time = 300,
            yScale = 0.01   ,
            transition = easing.linear,
            iterations = 1,
            onComplete = M.completeProgressBarFinalCallBack,
        } )
        if muiData.widgetDict[object.name]["progressbackdrop"].hideme ~= nil then
            transition.to( muiData.widgetDict[object.name]["progressbackdrop"], {
                time = 300,
                yScale = 0.01,
                transition = easing.linear,
                iterations = 1
            } )
        end
    elseif #muiData.progressbarDict > 0 then
        M.increaseProgressBar( object.name, 1, "__forceprocess__")
    else
        M.postProgressCircleCompleteCallBack( object )
    end
end

function M.postProgressCircleCompleteCallBack( object )
    if object.name ~= nil then
        if muiData.widgetDict[object.name] == nil then return end
        if object.onComplete ~= nil then
            assert(object.onComplete)( object )
        end
    end
end

function M.completeProgressBarFinalCallBack(object)
    if object.name ~= nil then
        if muiData.widgetDict[object.name] == nil then return end
        muiData.widgetDict[object.name]["progressbar"].isVisible = false
        if object.callBack ~= nil then
            assert(object.callBack)( object )
        end
    end
end

function M.postProgressCallBack( object )
    M.debug("postProgressCallBack")
end

function M.removeWidgetProgressBar(widgetName)
    M.removeProgressBar(widgetName)
end

function M.removeProgressBar(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["progressbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["progressbackdrop"] = nil
    muiData.widgetDict[widgetName]["progressbar"]:removeSelf()
    muiData.widgetDict[widgetName]["progressbar"] = nil
    if muiData.widgetDict[widgetName]["label"] ~= nil then
        muiData.widgetDict[widgetName]["label"]:removeSelf()
        muiData.widgetDict[widgetName]["label"] = nil
    end
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

return M
