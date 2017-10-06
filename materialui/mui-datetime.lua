--[[
    A loosely based Material UI module

    mui-datetime.lua : This is for creating date and time picker widgets.

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
local mathCeil = math.ceil

local M = muiData.M -- {} -- for module array/table

-- define methods here
function M.createDatePicker(options)
    M.newDatePicker(options)
end

function M.newDatePicker(options)
	if options == nil then return end
    if muiData.widgetDict[options.name] ~= nil then return end

    options = M.pickerSetDefaultOptions( options )

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "DatePicker"
    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()

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

    if options.fromYear == nil then
        options.fromYear = 1969
    end

    if options.toYear == nil then
        options.toYear = 2019
    end

    options.width = options.width or 600
    options.height = options.height or 400

    local textToMeasure = display.newText( "September", 0, 0, options.font, options.fontSize )
    local width = textToMeasure.contentWidth
    local rowHeight = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil
    options.rowHeight = rowHeight

    local fromYear = options.fromYear
    local yearCount = mathABS(options.toYear - options.fromYear)

    -- Set up the picker column data
    local startYearIndex = 1

    muiData.widgetDict[options.name]["months"] = {}
    muiData.widgetDict[options.name]["days"] = {}
    muiData.widgetDict[options.name]["years"] = {}

    local months = muiData.widgetDict[options.name]["months"]
    local days = muiData.widgetDict[options.name]["days"]
    local years = muiData.widgetDict[options.name]["years"]

    -- months
    options.start = 1
    options.value = ""
    options.tm_name = "months"
    local rowOffset = M.pickerAddExtraRows(months, options)
    muiData.widgetDict[options.name]["monthsExtraRows"] = rowOffset
    local tempMonths = {
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
    }
    for i, v in ipairs(tempMonths) do
        months[i+rowOffset] = v
    end
    options.start = #months + 1
    options.value = ""
    M.pickerAddExtraRows(months, options)

    -- days
    options.start = 1
    options.value = ""
    options.tm_name = "days"
    local rowOffset = M.pickerAddExtraRows(days, options)
    muiData.widgetDict[options.name]["daysExtraRows"] = rowOffset
    for i = 1,31 do days[i + rowOffset] = string.format("%02d", i) end
    options.start = #days + 1
    options.value = ""
    M.pickerAddExtraRows(days, options)

    options.start = 1
    options.value = ""
    options.tm_name = "years"
    local rowOffset = M.pickerAddExtraRows(years, options)
    muiData.widgetDict[options.name]["yearsExtraRows"] = rowOffset
    for j = 1,yearCount do
        years[j + rowOffset] = fromYear + j
        if options.startYear == years[j + rowOffset] then
            startYearIndex = j
        end
    end
    options.start = #years + 1
    options.value = ""
    M.pickerAddExtraRows(years, options)

    if options.startMonth == nil then
        options.startMonth = 1
    end

    if options.startDay == nil then
        options.startDay = 1
    end

    if options.startYear == nil then
        options.startYear = options.fromYear
    end

    if options.startMonth < 1 or options.startMonth > 12 then options.startMonth = 1 end
    if options.startDay < 1 or options.startDay > 31 then options.startDay = 1 end
    if options.startYear < options.fromYear or options.startYear > options.toYear then options.startYear = options.fromYear end

    local columnData = { 
        {
            align = "right",
            startIndex = options.startMonth,
            width = width,
            labels = months,
            labelCount = 12,
            key = "months",
        },
        {
            align = "center",
            startIndex = options.startDay,
            labels = days,
            labelCount = 31,
            key = "days",
        },
        {
            align = "center",
            startIndex = startYearIndex,
            labels = years,
            labelCount = yearCount,
            key = "years",
        },
    }

    -- Create a new Picker Wheel
    local pickerOptions= {
        name = options.name,
        x = 0,
        y = 0,
        width = options.width,
        height = options.height,
        columns = columnData,
        font = options.font,
        fontSize = options.fontSize,
        fontColor = options.fontColor,
        fontColorSelected = options.fontColorSelected,
        columnColor = options.columnColor,
        strokeColor = options.strokeColor,
        strokeWidth = options.strokeWidth,
        gradientBorderShadowColor1 = options.gradientBorderShadowColor1,
        gradientBorderShadowColor2 = options.gradientBorderShadowColor2,
        cancelButtonText = options.cancelButtonText,
        cancelButtonFillColor = options.cancelButtonFillColor,
        cancelButtonTextColor = options.cancelButtonTextColor,
        submitButtonText = options.submitButtonText,
        submitButtonFillColor = options.submitButtonFillColor,
        submitButtonTextColor = options.submitButtonTextColor,
        callBack = options.callBack,
    }

    M.newPickerWheel(options.x, options.y, pickerOptions)
end

function M.datePickerCallBack( event )
    -- Retrieve the current values from the picker
    local callBackData = M.getEventParameter(event, "muiTargetCallBackData")
    if callBackData == nil then return end

    local muiName = callBackData.targetName

    if muiData.widgetDict[muiName] ~= nil then
        local value = M.pickerGetCurrentValue(muiName)

        local text = "Date Column 1 Value: " .. (value.month or "") .. "\nColumn 2 Value: " .. (value.day or "") .. "\nColumn 3 Value: " .. (value.year or "")
        M.debug("text: "..text)
    end
    M.removeDateTimePicker(event)

    return true
end

function M.pickerAddExtraRows(list, options)
    if list == nil or options == nil then return nil end
    if options.value == nil then return list end
    if options.start == nil then options.start = 1 end

    local rowHeight = options.rowHeight
    local widgetHeight = options.height
    local visible = (mathCeil(widgetHeight / rowHeight)) -- approx rows on screen
    local extraRows = mathCeil(visible * 0.5)
    -- M.debug("visible rows: "..(visible) .. " widgetHeight: "..widgetHeight.. " rowHeight: "..rowHeight)
    muiData.visibleRows = visible
    local i
    local maxnum = (options.start+extraRows)
    maxnum = maxnum - 1

    for i=options.start, maxnum do
        list[i] = options.value
    end

    return extraRows
end

function M.pickerGetYOffset(options)
    local sizeLeft = options.tableViewHeight - options.rowHeight
    local amountLeft = sizeLeft * 0.5
    local rowsCount = amountLeft / options.rowHeight
    local remainder = rowsCount - mathFloor(rowsCount)
    local yOffset = options.rowHeight * remainder
    return yOffset
end

function M.pickerGetRowCountOffset(options)
    local sizeLeft = options.tableViewHeight - options.rowHeight
    local amountLeft = sizeLeft * 0.5
    local rowFitCount = mathCeil(amountLeft / options.rowHeight)
    local offset = 0
    local extraRowCount = muiData.widgetDict[options.name][options.tm_name .. "ExtraRows"]
    if rowFitCount < extraRowCount then
        offset = 1
    end
    return offset
end

-- define methods here
function M.createTimePicker(options)
    M.newTimePicker(options)
end

function M.newTimePicker(options)
    if options == nil then return end
    if muiData.widgetDict[options.name] ~= nil then return end

    options = M.pickerSetDefaultOptions( options )

    if options.militaryTime == nil then
        options.militaryTime = false
    end

    local useAMPM = true
    if options.militaryTime == false then
        options.hours = 12
    else
        options.hours = 23
        useAMPM = false
    end

    options.width = options.width or 300
    options.height = options.height or 200

    -- Insert the row data
    local textToMeasure = display.newText( "X", 0, 0, options.font, options.fontSize )
    local rowHeight = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil
    options.rowHeight = rowHeight

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "TimePicker"
    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()

    if options.callBack ~= nil then
        muiData.widgetDict[options.name]["callBack"] = options.callBack
    end

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    -- Set up the picker column data

    muiData.widgetDict[options.name]["hours"] = {}
    muiData.widgetDict[options.name]["minutes"] = {}
    muiData.widgetDict[options.name]["seconds"] = {}
    muiData.widgetDict[options.name]["ampm"] = {}

    local hours = muiData.widgetDict[options.name]["hours"]
    local minutes = muiData.widgetDict[options.name]["minutes"]
    local seconds = muiData.widgetDict[options.name]["seconds"]
    local ampm = muiData.widgetDict[options.name]["ampm"]

    local i
    local hourCount = 12

    options.start = 1
    options.value = ""
    options.tm_name = "hours"
    local rowOffset = M.pickerAddExtraRows(hours, options)
    muiData.widgetDict[options.name]["hoursExtraRows"] = rowOffset

    muiData.widgetDict[options.name]["rowOffset"] = rowOffset
    if options.hours == 12 then
        for i = 1, 12 do hours[i+rowOffset] = string.format("%02d", i) end
    else
        for i = 0, options.hours do hours[i+rowOffset+1] = i end
        hourCount = 24
    end
    options.start = #hours + 1
    options.value = ""
    M.pickerAddExtraRows(hours, options)

    options.start = 1
    options.value = ""
    options.tm_name = "minutes"
    rowOffset = M.pickerAddExtraRows(minutes, options)
    muiData.widgetDict[options.name]["minutesExtraRows"] = rowOffset
    for i = 0, 59 do minutes[i+1+rowOffset] = string.format("%02d", i) end
    options.start = #minutes + 1
    options.value = ""
    M.pickerAddExtraRows(minutes, options)

    options.start = 1
    options.value = ""
    options.tm_name = "ampm"
    rowOffset = M.pickerAddExtraRows(ampm, options)
    muiData.widgetDict[options.name]["ampmExtraRows"] = rowOffset
    ampm[#ampm + 1] = "am"
    ampm[#ampm + 1] = "pm"
    options.start = #ampm + 1
    options.value = ""
    M.pickerAddExtraRows(ampm, options)

    if options.startHour == nil then
        options.startHour = 1 + rowOffset
    end

    if options.startMinute == nil then
        options.startMinute = 1 + rowOffset
    end

    if options.startHour < 1 or options.startHour > options.hours then options.startHour = 9 end
    if options.startMinute < 0 or options.startMinute > 59 then options.startMinute = 14 end

    if options.militaryTime == true then options.startHour = options.startHour + 1 end

    local columnData = {
        {
            align = "center",
            startIndex = options.startHour,
            labels = hours,
            labelCount = hourCount,
            key = "hours",
        },
        {
            align = "center",
            startIndex = options.startMinute + 1,
            labels = minutes,
            labelCount = 60,
            key = "minutes",
        },
    }
    if useAMPM then
        table.insert(columnData, {
            align = "center",
            startIndex = 1,
            labels = ampm,
            labelCount = 2,
            key = "ampm",
        })
    end

    -- Create a new Picker Wheel
    local pickerOptions = {
        name = options.name,
        x = 0,
        y = 0,
        width = options.width,
        height = options.height,
        columns = columnData,
        font = options.font,
        fontSize = options.fontSize,
        fontColor = options.fontColor,
        fontColorSelected = options.fontColorSelected,
        columnColor = options.columnColor,
        strokeColor = options.strokeColor,
        strokeWidth = options.strokeWidth,
        gradientBorderShadowColor1 = options.gradientBorderShadowColor1,
        gradientBorderShadowColor2 = options.gradientBorderShadowColor2,
        cancelButtonText = options.cancelButtonText,
        cancelButtonFillColor = options.cancelButtonFillColor,
        cancelButtonTextColor = options.cancelButtonTextColor,
        submitButtonText = options.submitButtonText,
        submitButtonFillColor = options.submitButtonFillColor,
        submitButtonTextColor = options.submitButtonTextColor,
        callBack = options.callBack,
    }
    M.newPickerWheel(options.x, options.y, pickerOptions)
end

function M.pickerSetDefaultOptions(options)
    if options.font == nil then options.font = native.systemFont end
    if options.fontSize == nil then options.fontSize = 18 end
    if options.fontColor == nil then options.fontColor = { 0.7, 0.7, 0.7, 1 } end
    if options.fontColorSelected == nil then options.fontColorSelected = { 0, 0, 0, 1 } end
    if options.columnColor == nil then options.columnColor = { 1, 1, 1, 1 } end
    if options.strokeWidth == nil then options.strokeWidth = 1 end
    if options.strokeColor == nil then options.strokeColor = { 0, 0, 0, 1 } end

    return options
end

function M.newPickerWheel( x, y, options )
    if options == nil then return end
    if options.name == nil then return end

    local newX = display.contentCenterX
    local newY = display.contentCenterY
    if x ~= nil then
        newX = x
    end
    if y ~= nil then
        newY = y
    end

    local nW, nH

    nW = options.width or 300
    nH = options.height or 200

    muiData.widgetDict[options.name]["rect"] = display.newRect( 0, 0, nW, nH )
    muiData.widgetDict[options.name]["rect"].strokeWidth = options.strokeWidth
    muiData.widgetDict[options.name]["rect"]:setStrokeColor( unpack(options.strokeColor) )
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["rect"] )

    if options.ignoreInsets == nil then
        options.ignoreInsets = false
    end

    local centerX, centerY
    if options.ignoreInsets == false then
        local offsetY = muiData.safeAreaInsets.topInset + muiData.safeAreaInsets.bottomInset
        -- adjust picker
        centerX = display.contentCenterX
        centerY = display.contentCenterY - offsetY
        -- adjust buttons
        newX = newX - muiData.safeAreaInsets.leftInset
        newY = newY - offsetY
    end

    muiData.widgetDict[options.name]["mygroup"].x = centerX
    muiData.widgetDict[options.name]["mygroup"].y = centerY

    -- Insert the row data
    local textToMeasure = display.newText( "XX", 0, 0, options.font, options.fontSize )
    local rowHeight = textToMeasure.contentHeight
    local rowWidth = textToMeasure.contentWidth
    textToMeasure:removeSelf()
    textToMeasure = nil
    muiData.widgetDict[options.name]["rowHeight"] = rowHeight
    muiData.widgetDict[options.name]["rowWidth"] = rowWidth

    local columnCount = #options.columns

    if muiData.widgetDict[options.name]["type"] == "TimePicker" then
        local theWidth = ( nW / columnCount )
        M.pickerCreateColumn({
            startIndex = options.columns[1].startIndex,
            name = options.name,
            pickerName = "hours",
            rowTextColor = { 0, 0, 0, 1 },
            nH = nH,
            nW = nW,
            left = -( theWidth + (theWidth * 0.5) ),
            rowHeight = rowHeight,
            rowWidth = ( nW / columnCount ),
            column = options.columns[1],
            font = options.font,
            fontSize = options.fontSize,
            callBackData = options.callBackData,
            callBackTouch = options.callBackTouch,
            callBackRender = options.callBackRender,
        })

        M.pickerCreateColumn({
            startIndex = options.columns[2].startIndex,
            name = options.name,
            pickerName = "minutes",
            rowTextColor = { 0, 0, 0, 1 },
            nH = nH,
            nW = nW,
            left = -(theWidth * 0.5),
            rowHeight = rowHeight,
            rowWidth = ( nW / columnCount ),
            column = options.columns[2],
            font = options.font,
            fontSize = options.fontSize,
            callBackData = options.callBackData,
            callBackTouch = options.callBackTouch,
            callBackRender = options.callBackRender,
        })

        M.pickerCreateColumn({
            startIndex = options.columns[3].startIndex,
            name = options.name,
            pickerName = "ampm",
            rowTextColor = { 0, 0, 0, 1 },
            nH = nH,
            nW = nW,
            left = nW * 0.25,
            rowHeight = rowHeight,
            rowWidth = (theWidth * 0.5),
            column = options.columns[3],
            font = options.font,
            fontSize = options.fontSize,
            callBackData = options.callBackData,
            callBackTouch = options.callBackTouch,
            callBackRender = options.callBackRender,
        })
    else
        local theWidth = ( nW / columnCount )
        M.pickerCreateColumn({
            startIndex = options.columns[1].startIndex,
            name = options.name,
            pickerName = "months",
            rowTextColor = { 0, 0, 0, 1 },
            nH = nH,
            nW = nW,
            left = -( theWidth + (theWidth * 0.5) ),
            rowHeight = rowHeight,
            rowWidth = theWidth,
            column = options.columns[1],
            font = options.font,
            fontSize = options.fontSize,
            callBackData = options.callBackData,
            callBackTouch = options.callBackTouch,
            callBackRender = options.callBackRender,
        })

        M.pickerCreateColumn({
            startIndex = options.columns[2].startIndex,
            name = options.name,
            pickerName = "days",
            rowTextColor = { 0, 0, 0, 1 },
            nH = nH,
            nW = nW,
            left = -(theWidth * 0.5),
            rowHeight = rowHeight,
            rowWidth = theWidth,
            column = options.columns[2],
            font = options.font,
            fontSize = options.fontSize,
            callBackData = options.callBackData,
            callBackTouch = options.callBackTouch,
            callBackRender = options.callBackRender,
        })

        M.pickerCreateColumn({
            startIndex = options.columns[3].startIndex,
            name = options.name,
            pickerName = "years",
            rowTextColor = { 0, 0, 0, 1 },
            nH = nH,
            nW = nW,
            left = (theWidth * 0.5),
            rowHeight = rowHeight,
            rowWidth = theWidth,
            column = options.columns[3],
            font = options.font,
            fontSize = options.fontSize,
            callBackData = options.callBackData,
            callBackTouch = options.callBackTouch,
            callBackRender = options.callBackRender,
        })
    end

    local rect = muiData.widgetDict[options.name]["rect"]
    local rY = mathCeil( rowHeight * 0.5 )
    local cw = rect.contentWidth
    local ch = rect.contentHeight

    muiData.widgetDict[options.name]["line-top"] = display.newLine( -(rect.contentWidth * 0.5), -(rY), rect.contentWidth * 0.5, -(rY))
    muiData.widgetDict[options.name]["line-top"].strokeWidth = 2
    muiData.widgetDict[options.name]["line-top"]:setStrokeColor( unpack(options.strokeColor) )
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["line-top"] )
    muiData.widgetDict[options.name]["line-bot"] = display.newLine( -(rect.contentWidth * 0.5), (rY), rect.contentWidth * 0.5, (rY))
    muiData.widgetDict[options.name]["line-bot"].strokeWidth = 2
    muiData.widgetDict[options.name]["line-bot"]:setStrokeColor( unpack(options.strokeColor) )
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["line-bot"] )

    -- paint normal or use gradient?
    local paint = nil
    if options.gradientBorderShadowColor1 ~= nil and options.gradientBorderShadowColor2 ~= nil then
        options.gradientDirection = "up"
        paint = {
            type = "gradient",
            color1 = options.gradientBorderShadowColor1,
            color2 = options.gradientBorderShadowColor2,
            direction = options.gradientDirection
        }
    end

    muiData.widgetDict[options.name]["mygroup"]["rect2"] = display.newRect( 0, -(rect.contentHeight * 0.25), rect.contentWidth, rect.contentHeight * 0.5)
    if paint ~= nil then
        local object = muiData.widgetDict[options.name]["mygroup"]["rect2"]
       object.fill = paint

        object.fill.effect = "filter.vignetteMask"
        object.fill.effect.innerRadius = 1
        object.fill.effect.outerRadius = 0.1
        muiData.widgetDict[options.name]["mygroup"]:insert( object )
    end

    muiData.widgetDict[options.name]["mygroup"]["rect3"] = display.newRect( 0, (rect.contentHeight * 0.25), rect.contentWidth, rect.contentHeight * 0.5)
    local paint2 = nil
    if options.gradientBorderShadowColor1 ~= nil and options.gradientBorderShadowColor2 ~= nil then
        options.gradientDirection = "down"
        paint2 = {
            type = "gradient",
            color1 = options.gradientBorderShadowColor1,
            color2 = options.gradientBorderShadowColor2,
            direction = options.gradientDirection
        }
    end
    if paint2 ~= nil then
        local object = muiData.widgetDict[options.name]["mygroup"]["rect3"]
       object.fill = paint2

        object.fill.effect = "filter.vignetteMask"
        object.fill.effect.innerRadius = 1
        object.fill.effect.outerRadius = 0.1
        muiData.widgetDict[options.name]["mygroup"]:insert( object )
    end

    muiData.dialogInUse = true

    -- attach the cancel button
    M.newRectButton({
        name = options.name .. "-datetime-button-cancel",
        dialogName = options.name,
        text = (options.cancelButtonText or "Cancel"),
        width = (cw * 0.5),
        height = 35,
        x = newX,
        y = newY,
        font = native.systemFont,
        fillColor = (options.cancelButtonFillColor or { 0, 0, 1, 1 }),
        textColor = (options.cancelButtonTextColor or { 1, 1, 1 }),
        touchpoint = true,
        callBack = M.removeDateTimePicker,
        callBackData = {
            targetName = options.name,
            buttonName = options.name .. "-datetime-button-cancel"
        }
    })
    local cancelWidget = M.getWidgetBaseObject( options.name .. "-datetime-button-cancel" )
    cancelWidget.x = (cancelWidget.x - ((cw - cancelWidget.contentWidth) * 0.5)) - (options.strokeWidth * 0.5)
    cancelWidget.y = cancelWidget.y + ((ch - cancelWidget.contentHeight) * 0.5)
    cancelWidget.y = cancelWidget.y + (cancelWidget.contentHeight * 0.95)

    -- attach the set button
    M.newRectButton({
        name = options.name .. "-datetime-button-set",
        dialogName = options.name,
        text = (options.submitButtonText or "Set"),
        width = (cw * 0.5),
        height = 35,
        x = newX,
        y = newY,
        font = native.systemFont,
        fillColor = (options.submitButtonFillColor or { 0, 0, 1, 1 }),
        textColor = (options.submitButtonTextColor or { 1, 1, 1 }),
        touchpoint = true,
        callBack = options.callBack,
        callBackData = {
            targetName = options.name,
            buttonName = options.name .. "-datetime-button-set"
        }
    })

    local setWidget = M.getWidgetBaseObject( options.name .. "-datetime-button-set" )
    setWidget.x = (setWidget.x + ((cw - setWidget.contentWidth) * 0.5)) + (options.strokeWidth * 0.5)
    setWidget.y = setWidget.y + ((ch - setWidget.contentHeight) * 0.5)
    setWidget.y = setWidget.y + (setWidget.contentHeight * 0.95)
end

function M.pickerCreateColumn(options)
    local index = options.index
    local nH = options.nH
    local nW = options.nW
    local rowHeight = options.rowHeight
    local rowWidth = options.rowWidth
    local left = options.left -- -( (nH * 0.5) + rowHeight )
    local tableView = widget.newTableView(
        {
            left = left,
            top = -(nH * 0.5),
            height = nH,
            width = rowWidth,
            noLines = true,
            hideScrollBar = true,
            onRowRender = M.pickerOnRowRender,
            onRowTouch = M.pickerOnRowTouch,
            listener = M.pickerScrollListener,
        }
    )
    tableView.isVisible = true
    tableView.muiName = options.name
    tableView.pickerName = options.pickerName
    muiData.widgetDict[options.name][tableView.pickerName.."TableView"] = tableView
    muiData.widgetDict[options.name][tableView.pickerName.."LastMoveY"] = 0
    muiData.widgetDict[options.name][tableView.pickerName.."Touching"] = false
    muiData.widgetDict[options.name][tableView.pickerName.."Moving"] = false
    muiData.widgetDict[options.name][tableView.pickerName.."MoveTime"] = system.getTimer()

    local column = options.column
    local isCategory = false
    local rowColor = { 1, 1, 1 , 1 }
    local lineColor = { 0.4, 0.4, 0.4, 1 }
    for j, label in ipairs(column.labels) do
        local optionList = {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowWidth = rowWidth,
            rowColor = rowColor,
            lineColor = lineColor,
            params = {
                basename = options.name,
                name = options.name,
                column = column.key,
                text = label,
                font = options.font,
                fontSize = options.fontSize,
                value = label,
                rowHeight = rowHeight,
                rowWidth = rowWidth,
                rowColor = rowColor,
                textColor = {0, 0, 0, 1},
                callBackData = options.callBackData,
                callBackTouch = options.callBackTouch,
                callBackRender = options.callBackRender
            }
        }
        if column.key ~= nil then
            optionList["id"] = column.key .. "-" .. j .. "-" .. label
        end
        tableView:insertRow( optionList )
    end

    local yOffset = M.pickerGetYOffset({
        tableViewHeight = tableView.contentHeight,
        rowHeight = rowHeight
    })
    muiData.widgetDict[options.name]["yOffset"] = yOffset
    muiData.widgetDict[options.name][tableView.pickerName.."RowCountOffset"] = M.pickerGetRowCountOffset({
        name = options.name,
        tm_name = tableView.pickerName,
        tableViewHeight = tableView.contentHeight,
        rowHeight = rowHeight
    })
    M.pickerGoToRow({
        muiName = options.name,
        listName = tableView.pickerName,
        index = (options.startIndex or 1),
        animate = false, 
    })

    muiData.widgetDict[options.name]["mygroup"]:insert( tableView )
end

function M.pickerGoToRow(options)
    local value = nil
    if options == nil then return value end
    local muiName = options.muiName
    local listName = options.listName
    local index = options.index
    local animate = options.animate
    if muiName == nil or listName == nil or index == nil then return value end

    if muiData.widgetDict[muiName][listName] ~= nil and index <= #muiData.widgetDict[muiName][listName] then
        local y = muiData.widgetDict[muiName]["rowHeight"] - muiData.widgetDict[muiName]["yOffset"]
        if muiData.widgetDict[muiName][listName.."RowCountOffset"] == 1 then
            y = y + (muiData.widgetDict[muiName]["rowHeight"] * index)
        else
            y = y + (muiData.widgetDict[muiName]["rowHeight"] * (index-1))
        end
        if options.animate == nil then options.animate = false end
        local animateTime = 50 -- bug in scrollToY, value cannot be 0
        if options.animate == true then animateTime = 600 end
        muiData.widgetDict[muiName][listName.."CurrentRowIndex"] = index
        local extraRows = muiData.widgetDict[muiName][listName.."ExtraRows"]
        muiData.widgetDict[muiName][listName.."CurrentRowData"] = muiData.widgetDict[muiName][listName][index + extraRows]
        muiData.widgetDict[muiName][listName.."TableView"]:scrollToY({ y=-(y), time=50 })
    end
    return value
end

function M.pickerGetCurrentValue(muiName)
    if muiName == nil then return nil end
    local value = {}

    if muiData.widgetDict[muiName]["type"] == 'DatePicker' then
        value = { 
            month = muiData.widgetDict[muiName]["monthsCurrentRowData"],
            day = muiData.widgetDict[muiName]["daysCurrentRowData"],
            year = muiData.widgetDict[muiName]["yearsCurrentRowData"],
        }
    else
        value = { 
            hour = muiData.widgetDict[muiName]["hoursCurrentRowData"],
            minute = muiData.widgetDict[muiName]["minutesCurrentRowData"],
            ampm = muiData.widgetDict[muiName]["ampmCurrentRowData"],
        }
    end

    return value
end

function M.pickerGetColumnValue(muiName, listName, index)
    local value = nil
    if muiName == nil or listName == nil or index == nil then return value end

    if muiData.widgetDict[muiName][listName] ~= nil and index <= #muiData.widgetDict[muiName][listName] then
        value = muiData.widgetDict[muiName][listName][index]
    end
    return value
end

function M.pickerAdjustColumn( event )
    local moving = false
    local touching = false
    local params = nil
    local muiName = nil
    local pickerName = nil
    if event ~= nil and event.source ~= nil and event.source.params ~= nil then
        params = event.source.params
        muiName = params.name
        pickerName = params.pickerName
        if muiData.widgetDict[muiName] ~= nil and muiData.widgetDict[muiName][pickerName.."Touching"] ~= nil then
            touching = muiData.widgetDict[muiName][pickerName.."Touching"]
        end
        if muiData.widgetDict[muiName] ~= nil and muiData.widgetDict[muiName][pickerName.."Moving"] ~= nil then
            moving = muiData.widgetDict[muiName][pickerName.."Moving"]
        end
    end
    if moving == true and touching == false and (system.getTimer() - muiData.widgetDict[muiName][pickerName.."MoveTime"]) >= 600 then
        muiData.widgetDict[muiName][pickerName.."Moving"] = false
        timer.cancel( muiData.widgetDict[muiName][pickerName.."TableTimer"] )
        muiData.widgetDict[muiName][pickerName.."TableTimer"] = nil
        local tableView = muiData.widgetDict[muiName][pickerName.."TableView"]
        tableView:setIsLocked(true)
        local lastMoveY = muiData.widgetDict[muiName][pickerName.."LastMoveY"]
        local rowHeight = muiData.widgetDict[muiName]["rowHeight"]
        local row = -mathCeil( mathABS(lastMoveY / rowHeight) )
        local yOffset = muiData.widgetDict[muiName]["yOffset"]
        trow = -(mathABS(row) - muiData.widgetDict[muiName][pickerName.."RowCountOffset"])
        muiData.widgetDict[muiName][pickerName.."CurrentRowIndex"] = mathABS(trow)
        local extraRowOffset = muiData.widgetDict[muiName][pickerName.."ExtraRows"]
        local rowData = M.pickerGetColumnValue(muiName, pickerName, (mathABS(trow) + extraRowOffset))
        if rowData ~= nil then
            muiData.widgetDict[muiName][pickerName.."CurrentRowData"] = rowData 
        end
        if row == 0 or row > -2 then
            tableView:scrollToY( { y=-(rowHeight-yOffset), time=300 } )
        else
            local destY = mathABS(row * rowHeight)
            tableView:scrollToY( { y=-(destY-yOffset), time=300 } )            
        end
    end
end

function M.pickerOnRowRender( event )
    local row = event.row

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added

    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    row.muiName = row.params.name
    row.pickerName = row.params.column
    row.pickerValue = row.params.text

    local options = 
    {
        parent = row,
        --x = display.contentCenterX,
        --y = display.contentCenterY,
        text = ""..row.params.text,
        font = native.systemFont,
        fontSize = row.params.fontSize,
        width = rowWidth,
        height = 0,
        align = "center"  -- alignment parameter
    }

    local y = muiData.widgetDict[row.muiName][row.params.column.."TableView"]:getContentPosition()
    local rowTitle = display.newText( options )
    rowTitle:setFillColor( unpack( {0, 0, 0, 1} ) )

    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    --rowTitle.anchorY = 0
    rowTitle.x = (rowWidth * 0.5) - (rowTitle.contentWidth * 0.5)
    rowTitle.y = rowHeight * 0.5
    row:insert(rowTitle)

    muiData.widgetDict[row.muiName][row.pickerName.."Moving"] = true
    muiData.widgetDict[row.muiName][row.pickerName.."MoveTime"] = system.getTimer()

    muiData.widgetDict[row.muiName][row.pickerName.."LastMoveY"] = y

end

function M.pickerScrollListener( event )

    local y = nil
    if event.target ~= nil and event.target.muiName ~= nil then
        y = muiData.widgetDict[event.target.muiName][event.target.pickerName.."TableView"]:getContentPosition()
    end

    if event.phase == "began" then
        if muiData.widgetDict[event.target.muiName][event.target.pickerName.."TableTimer"] == nil then
            muiData.widgetDict[event.target.muiName][event.target.pickerName.."touching"] = true
            muiData.widgetDict[event.target.muiName][event.target.pickerName.."TableView"]:setIsLocked(false)
            muiData.widgetDict[event.target.muiName][event.target.pickerName.."TableTimer"] = timer.performWithDelay(300, M.pickerAdjustColumn, -1)
            muiData.widgetDict[event.target.muiName][event.target.pickerName.."TableTimer"].params = {
                name=event.target.muiName,
                pickerName = event.target.pickerName,
            }
        end
    elseif event.phase == "moved" then
        lastMoveY = event.y
    elseif event.phase == "ended" and event.target ~= nil and event.target.muiName ~= nil then
        local tableView = muiData.widgetDict[event.target.muiName][event.target.pickerName.."TableView"]
        if not (muiData.widgetDict[event.target.muiName][event.target.pickerName.."LastMoveY"] == y) then
            local lastY = muiData.widgetDict[event.target.muiName][event.target.pickerName.."LastMoveY"]

            --[[--
            # Starts 0 and use negative number to move down
            # Use positive numbers to move up?
            --]]--
            if lastY < y then
                muiData.movingDirection = "down"
            end
            if lastY > y then 
                muiData.movingDirection = "up"
            end
            muiData.widgetDict[event.target.muiName][event.target.pickerName.."LastMoveY"] = y
            muiData.widgetDict[event.target.muiName][event.target.pickerName.."touching"] = false
        end
    end

    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then M.debug( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then M.debug( "Reached top limit" )
        elseif ( event.direction == "left" ) then M.debug( "Reached right limit" )
        elseif ( event.direction == "right" ) then M.debug( "Reached left limit" )
        end
    end

    if event.target ~= nil and event.target.muiName ~= nil then
        muiData.widgetDict[event.target.muiName][event.target.pickerName.."Moving"] = true
        muiData.widgetDict[event.target.muiName][event.target.pickerName.."MoveTime"] = system.getTimer()
        -- muiData.moving = true
        -- muiData.moveTime = system.getTimer()
    end
    return true
end

function M.pickerOnRowTouch( event )
    local phase = event.phase
 
    if muiData.dialogInUse == true then return end
    local row = event.row

    if "press" == phase then
        --M.debug( "Touched row:", event.target.id )
        --M.debug( "Touched row:", event.target.index )
        --M.debug( "Touched row:", event.target.x )
    elseif "release" == phase or "cancelled" == phase then
        local row = event.row
    end
end

function M.timePickerCallBack( event )
    -- Retrieve the current values from the picker
    local callBackData = M.getEventParameter(event, "muiTargetCallBackData")
    if callBackData == nil then return end

    local muiName = callBackData.targetName

    if muiData.widgetDict[muiName] ~= nil then
        local value = M.pickerGetCurrentValue(muiName)

        local text = "Time Column 1 Value: " .. (value.hour or "") .. "\nColumn 2 Value: " .. (value.minute or "") .. "\nColumn 3 Value: " .. (value.ampm or "")
        M.debug("text: "..text)

    end
    M.removeDateTimePicker(event)

    return true
end

function M.removeWidgetDateTimePicker( event )
    M.removeDateTimePicker( event )
end

function M.removeDateTimePicker( event )
    local callBackData = M.getEventParameter(event, "muiTargetCallBackData")
    if callBackData == nil then return end

    local widgetName = callBackData.targetName
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    M.removeRectButton(widgetName .. "-datetime-button-cancel")
    M.removeRectButton(widgetName .. "-datetime-button-set")

    muiData.widgetDict[widgetName]["line-top"]:removeSelf()
    muiData.widgetDict[widgetName]["line-top"] = nil
    muiData.widgetDict[widgetName]["line-bot"]:removeSelf()
    muiData.widgetDict[widgetName]["line-bot"] = nil
    if muiData.widgetDict[widgetName]["rect2"] ~= nil then
        muiData.widgetDict[widgetName]["rect2"]:removeSelf()
        muiData.widgetDict[widgetName]["rect2"] = nil
    end
    if muiData.widgetDict[widgetName]["rect3"] ~= nil then
        muiData.widgetDict[widgetName]["rect3"]:removeSelf()
        muiData.widgetDict[widgetName]["rect3"] = nil
    end
    muiData.widgetDict[widgetName]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["rect"] = nil
    local tableViewList = { "hours", "minutes", "seconds", "ampm", "month", "day", "year" }
    for i, v in ipairs(tableViewList) do
        if v ~= nil and muiData.widgetDict[widgetName][v.."TableView"] ~= nil then
            muiData.widgetDict[widgetName][v.."TableView"]:deleteAllRows()
            muiData.widgetDict[widgetName][v.."TableView"]:removeSelf()
            muiData.widgetDict[widgetName][v.."TableView"] = nil
        end
        -- cancel timers
        if muiData.widgetDict[widgetName][v.."TableTimer"] ~= nil then
            timer.cancel( muiData.widgetDict[widgetName][v.."TableTimer"] )
            muiData.widgetDict[widgetName][v.."Moving"] = false
            muiData.widgetDict[widgetName][v.."TableTimer"] = nil
        end
        muiData.widgetDict[widgetName][v] = nil
    end
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
    muiData.dialogName = nil
    muiData.dialogInUse = false
end

return M
