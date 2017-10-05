--[[
    A loosely based Material UI module

    mui-popover.lua : This is for creating popover menus (pick lists)

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

function M.createPopover(options)
    M.newPopOver(options)
end

function M.newPopover(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    if options.text == nil then
        options.text = ""
    end

    if options.font == nil then
        options.font = native.systemFont
    end

    if options.fieldBackgroundColor == nil then
        options.fieldBackgroundColor = { 1, 1, 1, 1 }
    end

    x, y = M.getSafeXY(options, x, y)

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "Popover"

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

    options.rowColor = options.backgroundColor

    muiData.dialogInUse = true
    muiData.dialogName = options.name
    muiData.widgetDict[options.name]["options"] = options
    M.revealTableViewForPopover(options.name, muiData.widgetDict[options.name]["options"])
end

function M.getPopoverProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    end

    return data
end

function M.revealTableViewForPopover(name, options)
    muiData.widgetDict[options.name]["rectback"] = display.newRect( display.contentCenterX, display.contentCenterY, muiData.contentWidth, muiData.contentHeight)
    muiData.widgetDict[options.name]["rectback"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectback"]:setStrokeColor( 1 )
    muiData.widgetDict[options.name]["rectback"].alpha = 0.01
    muiData.widgetDict[options.name]["rectback"].muiName = options.name
    muiData.widgetDict[options.name]["rectback"]:addEventListener( "touch", M.touchPopoverBack )

    muiData.widgetDict[options.name]["mygroup"] = display.newGroup() -- options.width+4, options.height + options.listHeight)

    local x = options.x
    local y = options.y
    if muiData.widgetDict[options.name]["calculated"] ~= nil and muiData.widgetDict[options.name]["calculated"].y ~= nil then
        x = muiData.widgetDict[options.name]["calculated"].x
        y = muiData.widgetDict[options.name]["calculated"].y
    end

    x, y = M.getSafeXY(options, x, y)

    options.leftMargin = options.leftMargin or 10

    muiData.widgetDict[options.name]["mygroup"].x = x
    muiData.widgetDict[options.name]["mygroup"].y = y

    M.newTableView({
        name = options.name.."-List",
        width = options.width - (options.leftMargin * 2),
        height = options.listHeight,
        font = options.font,
        top = 30,
        left = -(options.leftMargin),
        textColor = options.textColor,
        strokeColor = options.inactiveColor,
        strokeWidth = 1,
        lineHeight = 0,
        noLines = true,
        isLocked = true,
        rowColor = options.rowColor,
        rowHeight = options.height,
        callBackTouch = options.callBackTouch,
        callBackRender = M.onRowRenderPopover,
        scrollListener = options.listener,
        categoryColor = options.categoryColor,
        categoryLineColor = options.categoryLineColor,
        touchpointColor = options.touchpointColor,
        list = options.list
    })

    muiData.widgetDict[options.name]["rect2"] = display.newRect( muiData.widgetDict[options.name.."-List"]["tableview"].x, muiData.widgetDict[options.name.."-List"]["tableview"].y, options.width - (options.leftMargin), options.listHeight + (options.height * 0.5))
    muiData.widgetDict[options.name]["rect2"].strokeWidth = options.strokeWidth
    muiData.widgetDict[options.name]["rect2"]:setStrokeColor( unpack( options.strokeColor ) )
    muiData.widgetDict[options.name]["rect2"]:setFillColor( unpack( options.backgroundColor ) )
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["rect2"] )

    if muiData.widgetDict[options.name]["calculated"] == nil then
        muiData.widgetDict[options.name]["calculated"] = {}
        muiData.widgetDict[options.name]["mygroup"].x = muiData.widgetDict[options.name]["mygroup"].x - options.width * 0.5

        local dy = mathABS(muiData.widgetDict[options.name.."-List"]["tableview"].contentHeight - muiData.widgetDict[options.name]["mygroup"].y)
        local h = muiData.widgetDict[options.name.."-List"]["tableview"].contentHeight + muiData.widgetDict[options.name]["mygroup"].y
        local maxHeight =  muiData.contentHeight - muiData.navbarHeight
        if h > maxHeight then
            local hd = mathABS(maxHeight - h)
            if options.scrollView ~= nil then
                maxHeight =  muiData.contentHeight - muiData.navbarHeight
                hd = mathABS(maxHeight - h)
            end
            dy = muiData.widgetDict[options.name]["mygroup"].y - (hd + options.height)
            muiData.widgetDict[options.name]["mygroup"].y = dy
        else
            dy = muiData.widgetDict[options.name]["mygroup"].y - options.height
        end
        muiData.widgetDict[options.name]["mygroup"].y = dy
        muiData.widgetDict[options.name]["calculated"].x = muiData.widgetDict[options.name]["mygroup"].x
        muiData.widgetDict[options.name]["calculated"].y = muiData.widgetDict[options.name]["mygroup"].y
    end
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name.."-List"]["tableview"] )
end

function M.touchPopoverBack( event )
    if event.target.muiName ~= nil then

        if ( event.phase == "ended" ) then
            M.removePopover(event.target.muiName)
            muiData.dialogInUse = false
            muiData.dialogName = nil
        end
    end
    return true -- prevent propagation to other controls
end

function M.onRowRenderPopover( event )
    local row = event.row

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local fontSize = row.contentHeight

    local rowTitle = display.newText( row, row.params.text, 0, 0, font, fontSize )
    rowTitle:setFillColor( unpack( textColor ) )

    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    rowTitle.x = 0
    rowTitle.y = rowHeight * 0.5
end

function M.onRowTouchPopover(event)
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
        timer.performWithDelay(500, function() M.finishPopover(parentName) end, 1)
    end
    muiData.dialogInUse = false
    muiData.dialogName = nil
    return true -- prevent propagation to other controls
end

function M.finishPopover(parentName)
    if muiData.widgetDict[parentName] == nil then return end
    M.removePopover(parentName, "listonly")
end

function M.removeWidgetPopover(widgetName, listonly)
    M.removePopover(widgetName, listonly)
end

function M.removePopover(widgetName, listonly)

    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["menuactive"] = false

    if listonly ~= nil then
        M.removeTableView(widgetName .. "-List")
        M.removePopoverGroup(widgetName)
        return
    else
        M.removeTableView(widgetName .. "-List")
    end

    M.removePopoverGroup(widgetName)
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removePopoverGroup(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if muiData.widgetDict[widgetName]["rect2"] ~= nil then
        muiData.widgetDict[widgetName]["rect2"]:removeSelf()
        muiData.widgetDict[widgetName]["rect2"] = nil
    end

    muiData.widgetDict[widgetName]["rectback"]:removeEventListener("touch", M.touchPopoverBack)
    if muiData.widgetDict[widgetName]["rectback"] ~= nil then
        muiData.widgetDict[widgetName]["rectback"]:removeSelf()
        muiData.widgetDict[widgetName]["rectback"] = nil
    end

    if muiData.widgetDict[widgetName]["mygroup"] ~= nil then
        muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
        muiData.widgetDict[widgetName]["mygroup"] = nil
    end
end

return M
