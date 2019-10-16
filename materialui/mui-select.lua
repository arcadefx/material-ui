--[[
A loosely based Material UI module

mui-select.lua : This is for creating select drop-downs (pick lists)

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

-- corona
local widget = require( "widget" )

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.createSelect(options)
    M.newSelect(options)
end

function M.newSelect(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    if options.text == nil then
        options.text = ""
    end

    if options.font == nil then
        options.font = native.systemFont
    end

    if options.fieldBackgroundColor == nil then
        options.fieldBackgroundColor = { 1, 1, 1, 1 }
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "Selector"

    muiData.widgetDict[options.name]["container"] = display.newContainer(options.width+4, options.height + options.listHeight)
    muiData.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["container"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["container"] )
    end

    if options.inactiveColor == nil then
        options.inactiveColor = { 0.4, 0.4, 0.4, 1 }
    end

    if options.activeColor == nil then
        options.activeColor = { 0.12, 0.67, 0.27, 1 }
    end

    if options.strokeWidth == nil then
        options.strokeWidth = 1
    end

    if options.strokeColor == nil then
        options.strokeColor = { 0.4, 0.4, 0.4, 1 }
    end

    if options.state == nil then options.state = {} end
    options.state.value = options.state.value or "off"

    muiData.widgetDict[options.name].list = nil
    if options.list ~= nil then
        muiData.widgetDict[options.name].list = options.list
    end

    muiData.widgetDict[options.name]["rect"] = display.newRect( 0, 0, options.width, options.height )
    muiData.widgetDict[options.name]["rect"]:setFillColor( unpack( options.fieldBackgroundColor ) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rect"] )

    local rect = muiData.widgetDict[options.name]["rect"]

    if options.backgroundFake ~= nil and options.backgroundFake.off.image == nil and options.backgroundFake.off.svg == nil then
        muiData.widgetDict[options.name]["line"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
        muiData.widgetDict[options.name]["line"].strokeWidth = 2
        muiData.widgetDict[options.name]["line"]:setStrokeColor( unpack(options.inactiveColor) )
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["line"] )
    elseif options.backgroundFake ~= nil and options.backgroundFake.off ~= nil and options.backgroundFake.off.svg ~= nil then
        muiData.widgetDict[options.name]["backgroundFake"] = M.newSvgImageWithStyle({
                name = options.name.."backgroundFakeSvgOff",
                path = options.backgroundFake.off.svg.path,
                width = options.width+5,
                height = options.height,
                fillColor = options.backgroundFake.off.svg.fillColor or options.backgroundFake.off.color,
                strokeWidth = options.backgroundFake.off.svg.strokeWidth or 1,
                strokeColor = options.backgroundFake.off.svg.strokeColor or options.backgroundFake.off.color,
                x = 0,
                y = 0,
            })
        if options.state.value == "disabled" then
            muiData.widgetDict[options.name]["backgroundFake"].isVisible = false
        end
    else
        muiData.widgetDict[options.name]["backgroundFake"] = display.newImageRect(options.backgroundFake.off.image, options.width+5, options.height)
        muiData.widgetDict[options.name]["backgroundFake"].x = 0
        muiData.widgetDict[options.name]["backgroundFake"].y = 0
        if options.state.value == "disabled" then
            muiData.widgetDict[options.name]["backgroundFake"].isVisible = false
        end
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["backgroundFake"] )
        options.rowColor = { default={ 1, 1, 1, 0.01 }, over={ 1, 0.5, 0, 0.2 } }
    end

    if options.backgroundFake ~= nil and options.backgroundFake.disabled.image ~= nil then
        muiData.widgetDict[options.name]["backgroundFakeDisabled"] = display.newImageRect(options.backgroundFake.disabled.image, options.width+5, options.height)
        muiData.widgetDict[options.name]["backgroundFakeDisabled"].x = 0
        muiData.widgetDict[options.name]["backgroundFakeDisabled"].y = 0
        if options.state.value == "off" then
            muiData.widgetDict[options.name]["backgroundFakeDisabled"].isVisible = false
        end
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["backgroundFakeDisabled"] )
    elseif options.backgroundFake ~= nil and options.backgroundFake.disabled ~= nil and options.backgroundFake.disabled.svg ~= nil then
        muiData.widgetDict[options.name]["backgroundFakeDisabled"] = M.newSvgImageWithStyle({
                name = options.name.."backgroundFakeDisabledSvgOff",
                path = options.backgroundFake.disabled.svg.path,
                width = options.width+5,
                height = options.height,
                fillColor = options.backgroundFake.disabled.svg.fillColor or options.backgroundFake.disabled.color,
                strokeWidth = options.backgroundFake.disabled.svg.strokeWidth or 1,
                strokeColor = options.backgroundFake.disabled.svg.strokeColor or options.backgroundFake.disabled.color,
                x = 0,
                y = 0,
            })
        if options.state.value == "off" then
            muiData.widgetDict[options.name]["backgroundFakeDisabled"].isVisible = false
        end
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["backgroundFakeDisabled"] )
    end

    local labelOptions =
    {
        --parent = textGroup,
        text = options.labelText or "",
        x = -(rect.contentWidth * 0.25),
        y = -(rect.contentHeight * 0.95),
        width = rect.contentWidth * 0.5, --required for multi-line and alignment
        font = options.font,
        fontSize = options.height * 0.55,
        align = "left" --new alignment parameter
    }
    muiData.widgetDict[options.name]["textlabel"] = display.newText( labelOptions )
    muiData.widgetDict[options.name]["textlabel"]:setFillColor( unpack(options.inactiveColor) )
    muiData.widgetDict[options.name]["textlabel"].inactiveColor = options.inactiveColor
    muiData.widgetDict[options.name]["textlabel"].activeColor = options.activeColor
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["textlabel"] )

    local scaleFontSize = 1
    if muiData.environment == "simulator" then
        scaleFontSize = 0.75
    end

    local textOptions =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        width = options.width,
        font = options.font,
        fontSize = options.height * 0.55,
        align = "left" --new alignment parameter
    }
    muiData.widgetDict[options.name]["selectorfieldfake"] = display.newText( textOptions )
    muiData.widgetDict[options.name]["selectorfieldfake"]:setFillColor( unpack(muiData.widgetDict[options.name]["textlabel"].inactiveColor) )
    muiData.widgetDict[options.name]["selectorfieldfake"]:addEventListener("touch", M.selectorListener)
    muiData.widgetDict[options.name]["selectorfieldfake"].name = options.name
    muiData.widgetDict[options.name]["selectorfieldfake"].dialogName = options.dialogName
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["selectorfieldfake"] )

    -- use codepoints like keyboard_arrow_down
    textOptions =
    {
        --parent = textGroup,
        text = M.getMaterialFontCodePointByName("keyboard_arrow_down"),
        x = 0,
        y = 0,
        width = options.width,
        font = muiData.materialFont,
        fontSize = options.height * 0.55,
        align = "right" --new alignment parameter
    }

    -- normal arrow
    local fieldWidth = muiData.widgetDict[options.name]["selectorfieldfake"].contentWidth
    if options.arrow ~= nil and options.arrow.off ~= nil and options.arrow.off.image ~= nil then
        muiData.widgetDict[options.name]["selectorfieldarrow"] = display.newImageRect(options.arrow.off.image, options.height, options.height)
        muiData.widgetDict[options.name]["selectorfieldarrow"].x = (fieldWidth / 2) - (muiData.widgetDict[options.name]["selectorfieldarrow"].contentWidth / 2)
        if options.state.value == "disabled" then
            muiData.widgetDict[options.name]["selectorfieldarrow"].isVisible = false
        end
    elseif options.arrow ~= nil and options.arrow.off ~= nil and options.arrow.off.svg ~= nil then
        muiData.widgetDict[options.name]["selectorfieldarrow"] = M.newSvgImageWithStyle({
                name = options.name.."arrowSvgOff",
                path = options.arrow.off.svg.path,
                width = options.height,
                height = options.height,
                fillColor = options.arrow.off.svg.fillColor or options.arrow.off.color,
                strokeWidth = options.arrow.off.svg.strokeWidth or 1,
                strokeColor = options.arrow.off.svg.strokeColor or options.arrow.off.color,
                x = (fieldWidth / 2) - (options.height / 2),
                y = 0,
            })
        if options.state.value == "disabled" then
            muiData.widgetDict[options.name]["selectorfieldarrow"].isVisible = false
        end
    else
        muiData.widgetDict[options.name]["selectorfieldarrow"] = display.newText( textOptions )
        muiData.widgetDict[options.name]["selectorfieldarrow"]:setFillColor( unpack(muiData.widgetDict[options.name]["textlabel"].inactiveColor) )
        muiData.widgetDict[options.name]["selectorfieldarrow"].name = options.name
        muiData.widgetDict[options.name]["selectorfieldarrow"].dialogName = options.dialogName
    end
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["selectorfieldarrow"] )

    -- disabled arrow
    if options.arrow ~= nil and options.arrow.disabled ~= nil and options.arrow.disabled.image ~= nil then
        muiData.widgetDict[options.name]["selectorfieldarrowDisabled"] = display.newImageRect(options.arrow.off.image, options.height, options.height)
        muiData.widgetDict[options.name]["selectorfieldarrowDisabled"].x = (fieldWidth / 2) - (muiData.widgetDict[options.name]["selectorfieldarrow"].contentWidth / 2)
    elseif options.arrow ~= nil and options.arrow.disabled ~= nil and options.arrow.disabled.svg ~= nil then
        muiData.widgetDict[options.name]["selectorfieldarrowDisabled"] = M.newSvgImageWithStyle({
                name = options.name.."arrowSvgDisabled",
                path = options.arrow.disabled.svg.path,
                width = options.height,
                height = options.height,
                fillColor = options.arrow.disabled.svg.fillColor or options.arrow.disabled.color,
                strokeWidth = options.arrow.disabled.svg.strokeWidth or 1,
                strokeColor = options.arrow.disabled.svg.strokeColor or options.arrow.disabled.color,
                x = (fieldWidth / 2) - (options.height / 2),
                y = 0,
            })
    end
    if muiData.widgetDict[options.name]["selectorfieldarrowDisabled"] ~= nil then
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["selectorfieldarrowDisabled"] )
        if options.state.value == "off" then
            muiData.widgetDict[options.name]["selectorfieldarrowDisabled"].isVisible = false
        end
    end


    if options.listHeight > muiData.contentHeight then
        options.listHeight = muiData.contentHeight * 0.75
    end

    muiData.widgetDict[options.name]["options"] = options
end

function M.turnSelectorOff(widgetName)
    options.state.value = "off"
    if muiData.widgetDict[options.name]["backgroundFake"] ~= nil then
        muiData.widgetDict[options.name]["backgroundFake"].isVisible = true
        muiData.widgetDict[options.name]["backgroundFakeDisabled"].isVisible = false
    else
        muiData.widgetDict[options.name]["rect"]:setFillColor( unpack( options.fieldBackgroundColor ) )
    end
end

function M.turnSelectorDisabled(widgetName)
    options.state.value = "disabled"
    if muiData.widgetDict[options.name]["backgroundFake"] ~= nil then
        muiData.widgetDict[options.name]["backgroundFake"].isVisible = false
        muiData.widgetDict[options.name]["backgroundFakeDisabled"].isVisible = true
    else
        local color = options.fieldBackgroundColor
        if color == nil then color = {1,1,1,1} end
        if options.state.disabled ~= nil and options.state.disabled.fieldBackgroundColor ~= nil then
            color = options.state.disabled.fieldBackgroundColor
        end
        muiData.widgetDict[options.name]["rect"]:setFillColor( unpack( color ) )
    end
end

function M.getSelectorProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetName]["textlabel"] -- label
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rect"] -- clickable area
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["selectorfieldarrow"] -- icon arrow
    elseif propertyName == "layer_3" then
        data = muiData.widgetDict[widgetName]["line"] -- line beneath control
    elseif propertyName == "layer_4" then
        data = muiData.widgetDict[widgetName]["group"]
    end
    return data
end

function M.setSelectorList(widgetName, list)
    if widgetName == nil or list == nil then return end
    if muiData.widgetDict[widgetName]["type"] == "Selector" then
        muiData.widgetDict[widgetName].list = list
        local text = ""
        local value = ""
        for k, v in pairs(list) do
            text = v.text
            value = v.value
            break
        end
        M.setSelectorValue(widgetName, text, value)
    end
end

function M.setSelectorValue(widgetName, text, value)
    if widgetName == nil or text == nil or value == nil then return end
    if muiData.widgetDict[widgetName]["type"] == "Selector" then
        muiData.widgetDict[widgetName]["selectorfieldfake"].text = text
        muiData.widgetDict[widgetName]["value"] = value
    end
end

function M.revealTableViewForSelector(name, options)
    -- table view to hold pick list keyboard_arrow_down
    muiData.widgetDict[options.name]["group"] = display.newGroup() -- options.width+4, options.height + options.listHeight)

    M.setFocus( options.name, M.finishSelector )

    local x = options.x
    local y = options.y

    x, y = M.getSafeXY(options, x, y)

    if muiData.widgetDict[options.name]["calculated"] ~= nil and muiData.widgetDict[options.name]["calculated"].y ~= nil then
        x = muiData.widgetDict[options.name]["calculated"].x
        y = muiData.widgetDict[options.name]["calculated"].y
    end

    muiData.widgetDict[options.name]["group"].x = x
    muiData.widgetDict[options.name]["group"].y = y

    M.newTableView({
            name = options.name.."-List",
            width = options.width * .9,
            height = options.listHeight,
            font = options.font,
            top = 25,
            left = 10,
            ignoreInsets = true,
            textColor = options.textColor,
            strokeColor = options.inactiveColor,
            strokeWidth = 1,
            lineHeight = 0,
            noLines = true,
            rowColor = options.rowColor,
            rowHeight = options.height,
            rowBackgroundColor = options.rowBackgroundColor, -- default if backgroundColor not in list below
            hideBackground = options.hideBackground or false,
            callBackTouch = options.callBackTouch,
            callBackRender = M.onRowRenderSelect,
            scrollListener = options.listener,
            categoryColor = options.categoryColor,
            categoryLineColor = options.categoryLineColor,
            touchpointColor = options.touchpointColor,
            list = muiData.widgetDict[options.name].list
        })

    if options.background.image == nil and options.background.svg == nil then
        muiData.widgetDict[options.name]["rect2"] = display.newRect( options.width * 0.5, (options.listHeight * 0.45) + options.height, options.width, options.listHeight + (options.height * 0.5))
        muiData.widgetDict[options.name]["rect2"].strokeWidth = options.strokeWidth
        muiData.widgetDict[options.name]["rect2"]:setStrokeColor( unpack( options.strokeColor ) )
        muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["rect2"] )
    elseif options.background ~= nil and options.background.image ~= nil then
        muiData.widgetDict[options.name]["rect2"] = display.newImageRect(options.background.image, options.width, options.listHeight + (options.height * 0.5))
        muiData.widgetDict[options.name]["rect2"].x = options.width * 0.5
        muiData.widgetDict[options.name]["rect2"].y = (options.listHeight * 0.45) + options.height
        muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["rect2"] )
    end

    if muiData.widgetDict[options.name]["calculated"] == nil then
        muiData.widgetDict[options.name]["calculated"] = {}
        muiData.widgetDict[options.name]["group"].x = muiData.widgetDict[options.name]["group"].x - options.width * 0.5

        local dy = mathABS(muiData.widgetDict[options.name.."-List"]["tableview"].contentHeight - muiData.widgetDict[options.name]["group"].y)
        local h = muiData.widgetDict[options.name.."-List"]["tableview"].contentHeight + muiData.widgetDict[options.name]["group"].y
        local maxHeight = muiData.contentHeight - muiData.navbarHeight
        if h > maxHeight then
            local hd = mathABS(maxHeight - h)
            if options.scrollView ~= nil then
                maxHeight = muiData.contentHeight - muiData.navbarHeight
                hd = mathABS(maxHeight - h)
            end
            dy = muiData.widgetDict[options.name]["group"].y - (hd + options.height)
            muiData.widgetDict[options.name]["group"].y = dy
        else
            dy = muiData.widgetDict[options.name]["group"].y - options.height
        end

        muiData.widgetDict[options.name]["group"].y = dy
        muiData.widgetDict[options.name]["calculated"].x = muiData.widgetDict[options.name]["group"].x
        muiData.widgetDict[options.name]["calculated"].y = muiData.widgetDict[options.name]["group"].y

        -- adjust position for scrollView if present
        if false and muiData.widgetDict[options.name]["scrollView"] ~= nil then
            local newX = muiData.widgetDict[options.name]["scrollView"].x - (muiData.widgetDict[options.name]["scrollView"].contentWidth * .5)
            newX = (newX + muiData.widgetDict[options.name]["container"].x) - (muiData.widgetDict[options.name]["container"].contentWidth * .5)
            muiData.widgetDict[options.name]["calculated"].x = newX
            muiData.widgetDict[options.name]["group"].x = muiData.widgetDict[options.name]["calculated"].x
        end
    end

    -- adjust position for scrollView if present
    if muiData.widgetDict[options.name]["scrollView"] ~= nil then
        local scroller = muiData.widgetDict[options.name]["scrollView"]
        local xView, yView = scroller:getContentPosition()
        local scroll_height = muiData.widgetDict[options.name]["scrollView"].contentHeight
        local table_height = muiData.widgetDict[options.name.."-List"]["tableview"].contentHeight
        local widget_y = muiData.widgetDict[options.name]["group"].y
        local widget_height = muiData.widgetDict[options.name]["group"].contentHeight
        local sY = (yView)

        if sY == 0 then
            if table_height < (widget_y + widget_height) then
                local newY = (widget_y + widget_height) - table_height
                newY = muiData.widgetDict[options.name]["group"].y - ( widget_height - options.height )
                muiData.widgetDict[options.name]["group"].y = newY
            end
        end
    end

    muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name.."-List"]["tableview"], false )
    muiData.widgetDict[options.name]["group"].isVisible = true -- false
    if muiData.widgetDict[options.name]["scrollView"] ~= nil then
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["group"] )
    end
end

function M.selectorListener( event )
    if event.phase == "began" then
        local name = event.target.name
        local options = muiData.widgetDict[name]["options"]
        muiData.currentTargetName = name
        if options.state ~= nil and options.state.value == "disabled" then
            if options.state.disabled ~= nil and options.state.disabled.callBackData ~= nil then
                M.setEventParameter(event, "muiTargetCallBackData", options.state.disabled.callBackData)
                assert( options.state.disabled.callBack )(event)
            end
            return
        end 
        M.revealTableViewForSelector(name, options)
        muiData.widgetDict[name]["group"].isVisible = true
    end
    return true -- prevent propagation to other controls
end

function M.onRowRenderSelect( event )
    local row = event.row

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    local rowTitle = display.newText( row, row.params.text, 0, 0, font, 18 )
    rowTitle:setFillColor( unpack( textColor ) )

    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    rowTitle.x = 0
    rowTitle.y = rowHeight * 0.5
end

function M.onRowTouchSelector(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")
    local muiTargetIndex = M.getEventParameter(event, "muiTargetIndex")

    if muiTargetIndex ~= nil then
        M.debug("row index: "..muiTargetIndex)
    end

    if muiTargetValue ~= nil then
        M.debug("row value: "..muiTargetValue)
    end

    if event.row.miscEvent ~= nil and event.row.miscEvent.name ~= nil then
        local parentName = string.gsub(event.row.miscEvent.name, "-List", "")

        if muiTargetIndex ~= nil then
            muiData.widgetDict[parentName]["selectorfieldfake"].text = muiData.widgetDict[parentName].list[muiTargetIndex].text -- was muiTargetValue
        end
        muiData.widgetDict[parentName]["value"] = muiTargetValue
        timer.performWithDelay(500, function() M.finishSelector(parentName) end, 1)
    else
        local parentName = muiData.focus

        muiData.widgetDict[parentName]["selectorfieldfake"].text = muiTargetValue
        muiData.widgetDict[parentName]["value"] = muiTargetValue
        timer.performWithDelay(500, function() M.finishSelector(parentName) end, 1)
    end
    muiData.touched = true
    return true -- prevent propagation to other controls
end

function M.finishSelector(parentName)
    if muiData.widgetDict[parentName] == nil then return end
    M.removeSelector(parentName, "listonly")
end

function M.removeWidgetSelector(widgetName, listonly)
    M.removeSelector(widgetName, listonly)
end

function M.removeSelector(widgetName, listonly)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if listonly ~= nil then
        M.removeTableView(widgetName .. "-List")
        M.removeSelectorGroup(widgetName)
        return
    else
        M.removeTableView(widgetName .. "-List")
    end

    muiData.widgetDict[widgetName]["selectorfieldfake"]:removeEventListener("touch", M.selectorListener)

    muiData.widgetDict[widgetName]["selectorfieldarrow"]:removeSelf()
    muiData.widgetDict[widgetName]["selectorfieldarrow"] = nil
    muiData.widgetDict[widgetName]["selectorfieldfake"]:removeSelf()
    muiData.widgetDict[widgetName]["selectorfieldfake"] = nil

    if muiData.widgetDict[widgetName]["backgroundFake"] ~= nil then
        muiData.widgetDict[widgetName]["backgroundFake"]:removeSelf()
        muiData.widgetDict[widgetName]["backgroundFake"] = nil
    end
    if muiData.widgetDict[widgetName]["backgroundFakeSvgOff"] ~= nil then
        muiData.widgetDict[widgetName]["backgroundFakeSvgOff"]:removeSelf()
        muiData.widgetDict[widgetName]["backgroundFakeSvgOff"] = nil
    end
    if muiData.widgetDict[widgetName]["backgroundFakeDisabledSvgOff"] ~= nil then
        muiData.widgetDict[widgetName]["backgroundFakeDisabledSvgOff"]:removeSelf()
        muiData.widgetDict[widgetName]["backgroundFakeDisabledSvgOff"] = nil
    end

    muiData.widgetDict[widgetName]["textlabel"]:removeSelf()
    muiData.widgetDict[widgetName]["textlabel"] = nil
    muiData.widgetDict[widgetName]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["rect"] = nil
    if muiData.widgetDict[widgetName]["line"] ~= nil then
        muiData.widgetDict[widgetName]["line"]:removeSelf()
        muiData.widgetDict[widgetName]["line"] = nil
    end
    M.removeSelectorGroup(widgetName)
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
    M.resetCurrentControlVars()
end

function M.removeSelectorGroup(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if muiData.widgetDict[widgetName]["rect2"] ~= nil then
        muiData.widgetDict[widgetName]["rect2"]:removeSelf()
        muiData.widgetDict[widgetName]["rect2"] = nil
    end
    if muiData.widgetDict[widgetName]["group"] ~= nil then
        muiData.widgetDict[widgetName]["group"]:removeSelf()
        muiData.widgetDict[widgetName]["group"] = nil
    end
end

return M
