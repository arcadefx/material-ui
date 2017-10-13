--[[
    A loosely based Material UI module

    mui-button.lua : This is for creating a tableview.

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
local MySceneName = nil

function M.createTableView( options )
    M.newTableView( options )
end

function M.newTableView( options )
    -- The "onRowRender" function may go here (see example under "Inserting Rows", above)

    if options.noLines == nil then
        options.noLines = false
    end

    if options.circleColor == nil then
        options.circleColor = { 0.4, 0.4, 0.4 }
    end

    if options.touchpointColor ~= nil then
        options.circleColor = options.touchpointColor
    end

    if options.font == nil then
        options.font = native.systemFont
    end

    if options.fontSize == nil then
        options.fontSize = 18
    end

    if options.strokeWidth == nil then
        options.strokeWidth = 0
    end

    if options.strokeColor == nil then
        options.strokeColor = { 0.8, 0.8, 0.8, .4 }
    end

    if options.padding == nil then
        options.padding = 15
    end

    if options.rowAnimation == nil then
        options.rowAnimation = true
    end

    options.left, options.top = M.getSafeXY(options, options.left, options.top)

    MySceneName = M.getCurrentScene()
    muiData.sceneData[MySceneName].tableCircle = display.newCircle( 0, 0, (20 * 2.5) )
    muiData.sceneData[MySceneName].tableCircle:setFillColor( unpack(options.circleColor) )
    muiData.sceneData[MySceneName].tableCircle.isVisible = false
    muiData.sceneData[MySceneName].tableCircle.alpha = 0.55
    muiData.tableRow = nil

    -- Create the widget
    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["tableview"] = {}
    muiData.widgetDict[options.name]["type"] = "TableView"
    muiData.widgetDict[options.name]["tableRow"] = nil
    muiData.widgetDict[options.name]["options"] = options

    local tableView = widget.newTableView(
        {
            left = options.left,
            top = options.top,
            height = options.height,
            width = options.width,
            noLines = options.noLines,
            onRowRender = M.onRowRender,
            onRowTouch = M.onRowTouch,
            listener = options.scrollListener,
            isLocked = options.isLocked or false,
            hideBackground = options.hideBackground or false
        }
    )
    tableView.isVisible = false
    muiData.widgetDict[options.name]["tableview"] = tableView

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( tableView )
    end

    -- Insert the row data
    for i, v in ipairs(options.list) do

        local isCategory = false
        local rowHeight = options.rowHeight
        local rowColor = options.rowColor
        local lineColor = options.lineColor

        -- use categories
        if v.isCategory ~= nil and v.isCategory == true then
            isCategory = true
            rowHeight = (rowHeight + (rowHeight * 0.1))
            if options.categoryColor == nil then
                options.categoryColor = { default={0.8,0.8,0.8,0.8} }
            end
            if options.lineColor == nil then
                options.categoryLineColor = { 1, 1, 1, 0 }
            end

            rowColor = options.categoryColor
            lineColor = options.categoryLineColor
        end

        -- Insert a row into the tableView
        if v.backgroundColor ~= nil then
            v.fillColor = v.fillColor or v.backgroundColor
        else
            v.fillColor = v.fillColor or rowColor.default
        end

        local optionList = {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = {
                basename = options.name,
                name = options.name,
                text = v.text,
                font = v.font or options.font,
                fontSize = v.fontSize or options.fontSize,
                align = v.align or "left",
                valign = v.valign or "middle",
                value = v.value,
                width = options.width,
                columns = v.columns,
                columnOptions = options.columnOptions,
                padding = options.padding,
                noLines = options.noLines,
                lineHeight = options.lineHeight or 0,
                rowColor = v.fillColor,
                textColor = options.textColor,
                rowAnimation = options.rowAnimation,
                backgroundImage = v.backgroundImage,
                callBackData = options.callBackData,
                callBackTouch = options.callBackTouch,
                callBackRender = options.callBackRender
            }
        }
        if v.key ~= nil then
            optionList["id"] = v.key
        end
        tableView:insertRow( optionList )
    end
    tableView.isVisible = true
end

function M.getTableViewProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["tableview"] -- x,y movement
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value
    elseif propertyName == "list" then
        data = muiData.widgetDict[widgetName]["list"] -- rows and/or rows and columns
    end
    return data
end

function M.onRowRender( event )

    -- Get reference to the row group
    local row = event.row

    -- need to use the colors passed in as params here.
    noLines = false
    lineHeight = 1
    lineColor = { 0.9, 0.9, 0.9 }
    rowColor = { 1, 1, 1, 1 }
    textColor = { 0, 0, 0, 1 }
    font = native.systemFont

    if row.params ~= nil then
        if row.params.noLines ~= nil then noLines = row.params.noLines end

        if row.params.lineHeight ~= nil then
            lineHeight = row.params.lineHeight
        end

        if row.params.lineColor ~= nil then lineColor = row.params.lineColor end

        if row.params.rowColor ~= nil then
            rowColor = row.params.rowColor
        end

        if row.params.textColor ~= nil then textColor = row.params.textColor end
        if row.params.font ~= nil then font = row.params.font end
    end

    if noLines == false and lineHeight > 0 then

        -- the block above line
        row.bg1 = display.newRect( 0, 0, row.contentWidth, row.contentHeight)
        --row.bg1.anchorX = 0
        --row.bg1.anchorY = 0
        row.bg1.x = row.contentWidth * 0.5
        row.bg1.y = row.contentHeight * 0.5
        row.bg1:setFillColor( unpack( rowColor ) ) -- transparent
        row:insert( row.bg1 )

        -- line underneath label
        row.bg2 = display.newRect( 0, 0, row.contentWidth, lineHeight)
        -- row.bg2.anchorX = 0
        -- row.bg1.anchorY = 0
        row.bg2.x = row.contentWidth * 0.5
        row.bg2.y = row.contentHeight - (lineHeight * 0.5)
        row.bg2:setFillColor( unpack( lineColor ) ) -- transparent
        row:insert( row.bg2 )

    else
        row.bg1 = display.newRect( 0, 0, row.contentWidth, row.contentHeight)
        row.bg1.anchorX = 0
        row.bg1.anchorY = 0
        row.bg1:setFillColor( unpack( rowColor ) ) -- transparent
        row:insert( row.bg1 )
    end

    function row:touch (event)
        if ( event.phase == "began" ) then
            row.miscEvent = {}
            row.miscEvent.name = row.params.name
            row.miscEvent.x = event.x
            row.miscEvent.y = event.y
            row.miscEvent.minRadius = 30 * 0.25
        end
    end
    row:addEventListener( "touch", row )

    if row.params ~= nil and row.params.callBackRender ~= nil then
        -- If a background image was specified then add it before any controls
        M.attachBackgroundToRow(row, {
            image = row.params.backgroundImage
        })
        assert( row.params.callBackRender )(event)
    end
end

function M.onRowRenderDemo( event )
    local row = event.row

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    --[[-- demo attaching checkbox to table (a checklist)
    M.newCheckBox({
        name = "check"..row.index,
        text = "check_box_outline_blank",
        width = 25,
        height = 25,
        isFontIcon = true,
        font = M.materialFont,
        textColor = { 0.3, 0.3, 0.3 },
        textAlign = "center",
        value = 500,
        callBack = M.actionForCheckbox
    })
    M.attachToRow( row, {
        widgetName = "check"..row.index,
        widgetType = "IconButton",
        align = "left",  -- left | right supported
        params = row.params
    })
    --]]--

    --[[-- demo attaching widget to a row
    M.newIconButton({
        name = "plus"..row.index,
        text = "add_circle",
        width = 25,
        height = 25,
        x = 0,
        y = 0,
        font = muiData.materialFont,
        textColor = { 1, 0, 0.4 },
        textAlign = "center",
        callBack = M.actionForButton
    })
    M.attachToRow( row, {
        widgetName = "plus"..row.index,
        widgetType = "IconButton",
        align = "left",  -- left | right supported
        params = row.params
    })
    --]]--

    local colWidth = 0
    local x1 = 0
    if row.params.columns ~= nil then
        for i, v in ipairs(row.params.columns) do

            colWidth = 0
            if row.params.columnOptions ~= nil and row.params.columnOptions.widths ~= nil then
                for j, k in ipairs(row.params.columnOptions.widths) do
                    if j == i then
                        colWidth = tonumber( k )
                        colWidth = colWidth - 5
                        break
                    end
                end
            end
            local container = display.newContainer( row, colWidth, rowHeight )
            local textOptions =
            {
                parent = container,
                text = v.text,
                x = 0,
                y = 0,
                width = colWidth,
                font = font,
                fontSize = row.params.fontSize,
                align = v.align or "left"  -- Alignment parameter
            }
            local rowTitle = display.newText( textOptions )
            rowTitle:setFillColor( unpack( textColor ) )
            -- Align the label left and vertically centered
            --rowTitle.anchorX = 0
            --rowTitle.x = 0
            --rowTitle.y = rowHeight * 0.5
            x1 = x1 + colWidth
            if i < 2 then x1 = x1 * 0.5 end
            container.x = x1
            container.y = rowHeight * 0.5

            v.valign = v.valign or "middle"

            -- Pass in Font height too
            if v.valign ~= nil then
                M.setRowObjectVerticalAlign({
                    obj = container,
                    valign = v.valign,
                    rowHeight = rowHeight,
                    lineHeight = row.params.lineHeight,
                    heightOfFont = rowTitle.contentHeight
                })
            end
        end
    else
        local textOptions =
        {
            parent = row,
            text = row.params.text,
            x = 0,
            y = rowHeight * 0.5,
            width = rowWidth,
            font = font,
            fontSize = row.params.fontSize,
            align = row.params.align or "left"  -- Alignment parameter
        }
        local rowTitle = display.newText( textOptions )
        rowTitle:setFillColor( unpack( textColor ) )

        -- Align the label left and vertically centered
        rowTitle.anchorX = 0

        row.params.valign = row.params.valign or "middle"
        M.setRowObjectVerticalAlign({
            obj = rowTitle,
            valign = row.params.valign,
            rowHeight = rowHeight,
            lineHeight = row.params.lineHeight
        })
    end
end

function M.setRowObjectVerticalAlign(options)
    obj = options.obj
    objectHeight = options.obj.contentHeight
    heightOffset = options.heightOfFont or 0
    lineHeight = options.lineHeight or 0
    valign = options.valign or "middle"
    rowHeight = options.rowHeight

    if heightOffset > 0 and valign == "bottom" then
        heightDiff = mathABS(objectHeight - heightOffset)
        objectHeight = objectHeight - heightDiff
    elseif heightOffset > 0 and valign == "top" then
        objectHeight = options.heightOfFont
    end

    if valign == "top" then
        obj.y = objectHeight * 0.5
    elseif valign == "middle" then
        obj.y = (rowHeight / 2) - (lineHeight / 2)
    elseif valign == "bottom" then
        newY = rowHeight - (( objectHeight / 2) + (lineHeight))
        obj.y = newY
    else
        M.debug("M.setRowObjectVerticalAlign : unsupported valign parameter: "..valign)
    end
end

function M.attachBackgroundToRow(row, options)
    if row == nil or options == nil or options.image == nil then return end

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local name = "background-"..row.index

    M.newImageRect({
        image = options.image,
        name = name,
        width = rowWidth,
        height = rowHeight,
        x = 0,
        y = 0
    })
    if muiData.widgetDict[name]["image_rect"] == nil then
        M.debug("M.attachBackgroundToRow : cannot find image "..options.image)
        return
    end
    local backImage = M.getWidgetBaseObject( name )
    backImage.anchorX = 0
    backImage.anchorY = 0
    row:insert( backImage )
end

function M.attachToRow(row, options )
    if row == nil or options == nil or options.widgetName == nil then return end
    local newX = 0
    local newY = 0
    local widget = nil
    local basename = options.params.basename
    local widgetName = options.widgetName
    local rowName = "row" .. row.index
    local padding = options.params.padding
    local nh = row.contentHeight
    local nw = row.contentWidth

    local isTypeSupported = false
    for i, widgetType in ipairs(muiData.navbarSupportedTypes) do
        if widgetType == options.widgetType then
            isTypeSupported = true
            break
        end
    end

    if isTypeSupported == false then
        if options.widgetType == nil then options.widgetType = "unknown widget" end
        M.debug("M.attachToRow : does not support type of "..options.widgetType)
        return
    end

    widget = M.getWidgetBaseObject(widgetName)
    newY = (nh - widget.contentHeight) * 0.5

    -- keep tabs on the toolbar objects
    if muiData.widgetDict[basename]["list"] == nil then muiData.widgetDict[basename]["list"] = {} end
    if muiData.widgetDict[basename]["list"][rowName] == nil then
        muiData.widgetDict[basename]["list"][rowName] = {}
        muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] = 0
        muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] = 0
    end

    muiData.widgetDict[basename]["list"][rowName][widgetName] = options.widgetType

    if options.align == nil then
        options.align = "left"
    end

    if options.padding == nil then
        padding = 10
    end

    if options.align == "left" then
        if muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] > 0 then
            newX = newX + padding
        end
        newX = newX + muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"]
        widget.x = widget.contentWidth * 0.5 + newX
        muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] = widget.x + widget.contentWidth * 0.5
    else
        newX = nw
        if muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] > 0 then
            newX = newX - padding
        end
        newX = newX - muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"]
        widget.x = newX - widget.contentWidth * 0.5
        muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] = padding + muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] + widget.contentWidth * 0.5
    end
    widget.y = widget.contentHeight * 0.5 + newY

    if options.valign ~= nil then
        M.setRowObjectVerticalAlign({
            rowHeight = row.contentHeight,
            obj = widget,
            valign = options.valign,
            lineHeight = options.lineHeight or 0
        })
    end

    row:insert( widget, false )
    if options.finish == true then
        muiData.widgetDict[basename]["list"][rowName]["lastWidgetLeftX"] = 0
        muiData.widgetDict[basename]["list"][rowName]["lastWidgetRightX"] = 0
    end
end

function M.onRowTouch( event )
    local phase = event.phase
    local row = event.row

    if muiData.touched ~= nil and muiData.touched == true then
            muiData.touched = false
            return true
    end

    if muiData.dialogInUse == true then
        if muiData.dialogName == nil then return end
        if string.find(row.params.name, muiData.dialogName) == nil then
            return
        end
    end

    if (phase == "tap" or "press" == phase) and muiData.touching == false then
        muiData.touching = true
        local skipNameToRemove = nil
        if string.find(string.lower(row.params.basename), "-list") then
            skipNameToRemove = "__skipRemove"
        end
        M.updateUI(event, skipNameToRemove)
        --M.debug( "Touched row:", event.target.id )
        --M.debug( "Touched row:", event.target.index )
    end

    if ("release" == phase or "tap" == phase) then
        local row = event.row

        local rowAnimation = true
        if row.params ~= nil and row.params.rowAnimation ~= nil then
            rowAnimation = row.params.rowAnimation
        end

        if rowAnimation == true then
            MySceneName = M.getCurrentScene()
            muiData.sceneData[MySceneName].tableCircle:toFront()

            muiData.sceneData[MySceneName].tableCircle.alpha = 0.55
            if row.miscEvent == nil then return end
            muiData.sceneData[MySceneName].tableCircle.x = row.miscEvent.x
            muiData.sceneData[MySceneName].tableCircle.y = row.miscEvent.y
            local scaleFactor = 0.1 --2.5
            muiData.sceneData[MySceneName].tableCircle.isVisible = true
            muiData.sceneData[MySceneName].tableCircle.myCircleTrans = transition.from( muiData.sceneData[MySceneName].tableCircle, { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            row.myGlowTrans = transition.to( row, { time=300,delay=150,alpha=0.4, transition=easing.outCirc, onComplete=M.subtleGlowRect } )
        end

        M.setEventParameter(event, "basename", row.params.basename)
        M.setEventParameter(event, "muiTarget", row)
        M.setEventParameter(event, "muiTargetRowParams", row.params)
        M.setEventParameter(event, "muiTargetIndex", event.target.index)
        M.setEventParameter(event, "muiTableView", muiData.widgetDict[row.params.basename]["tableview"])
        if row.params ~= nil then
            M.setEventParameter(event, "muiTargetValue", row.params.value)
            muiData.widgetDict[row.params.name]["value"] = row.params.value
        end
        if row.params ~= nil and row.params.callBackTouch ~= nil then
            assert( row.params.callBackTouch )(event)
        end
    end
    return true -- prevent propagation to other controls
end

function M.setLastRow( event, target )
    local basename = M.getEventParameter(event, "basename")
    if basename then
        muiData.widgetDict[basename]["tableRow"] = target
    end
end

function M.getLastRow( event )
    local basename = M.getEventParameter(event, "basename")
    if basename then
        row = muiData.widgetDict[basename]["tableRow"]
    end
    return row
end

function M.onRowTouchDemo(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")
    local muiTargetIndex = M.getEventParameter(event, "muiTargetIndex")
    local muiTargetRowParams = M.getEventParameter(event, "muiTargetRowParams")
    local muiTableView = M.getEventParameter(event, "muiTableView")

    -- reset background color for all rows that are out of view.
    -- set background of selected row

    --[[-- uncomment below to demo row selected stays highlighted and prior rows do not.
    local tableViewRows = nil
    if muiTableView ~= nil then
        tableViewRows = muiTableView._view._rows
    end
    if muiTargetIndex ~= nil and tableViewRows ~= nil then
        for k, row in ipairs(tableViewRows) do
            if k == muiTargetIndex then
                row.params.rowColor = { 0, 1, 0, 1 }
            else
                row.params.rowColor = { 1, 1, 1, 1 }
            end
        end
        muiTableView:reloadData()
    end
    --]]--

    if muiTargetValue ~= nil then
        M.debug("M.onRowTouchDemo : row value: "..muiTargetValue)
    end
    -- access the columns of data
    if muiTargetRowParams ~= nil and muiTargetRowParams.columns ~= nil then
        M.debug("M.onRowTouchDemo : columns of data are:")
        for i, v in ipairs(muiTargetRowParams.columns) do
            M.debug("\tcolumn "..i.." text "..v.text)
            M.debug("\tcolumn "..i.." value "..v.value)
            M.debug("\tcolumn "..i.." align "..(v.align or "left"))
        end
    end

end

function M.insertRowsTableView(widgetName, list)
    if widgetName == nil or rows == nil then return end
    tableView = muiData.widgetDict[widgetName]["tableview"]
    options = muiData.widgetDict[widgetName]["options"]
    for i, v in ipairs(list) do

        local isCategory = false
        local rowHeight = options.rowHeight
        local rowColor = options.rowColor
        local lineColor = options.lineColor

        -- use categories
        if v.isCategory ~= nil and v.isCategory == true then
            isCategory = true
            rowHeight = (rowHeight + (rowHeight * 0.1))
            if options.categoryColor == nil then
                options.categoryColor = { default={0.8,0.8,0.8,0.8} }
            end
            if options.lineColor == nil then
                options.categoryLineColor = { 1, 1, 1, 0 }
            end

            rowColor = options.categoryColor
            lineColor = options.categoryLineColor
        end

        -- Insert a row into the tableView
        if v.backgroundColor ~= nil then
            v.fillColor = v.fillColor or v.backgroundColor
        else
            v.fillColor = v.fillColor or rowColor.default
        end

        local optionList = {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = {
                basename = options.name,
                name = options.name,
                text = v.text,
                font = v.font or options.font,
                fontSize = v.fontSize or options.fontSize,
                align = v.align or "left",
                valign = v.valign or "middle",
                value = v.value,
                width = options.width,
                columns = v.columns,
                columnOptions = options.columnOptions,
                padding = options.padding,
                noLines = options.noLines,
                lineHeight = options.lineHeight or 0,
                rowColor = v.fillColor,
                textColor = options.textColor,
                rowAnimation = options.rowAnimation,
                backgroundImage = v.backgroundImage,
                callBackData = options.callBackData,
                callBackTouch = options.callBackTouch,
                callBackRender = options.callBackRender
            }
        }
        if v.key ~= nil then
            optionList["id"] = v.key
        end
        tableView:insertRow( optionList )
    end
end

function M.removeAllRowsFromTableView(widgetName)
    if muiData.widgetDict[widgetName]["tableview"] == nil then return end
    muiData.widgetDict[widgetName]["tableview"]:deleteAllRows()
end

function M.removeWidgetTableView(widgetName)
    M.removeTableView(widgetName)
end

function M.removeTableView(widgetName)
    if widgetName == nil then
        return
    end
    if muiData.widgetDict[widgetName] == nil then return end
    if muiData.widgetDict[widgetName]["tableview"] == nil then return end
    muiData.widgetDict[widgetName]["tableview"]:deleteAllRows()
    muiData.widgetDict[widgetName]["tableview"]:removeSelf()
    muiData.widgetDict[widgetName]["tableview"] = nil
end

return M
