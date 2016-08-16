--[[
    A loosely based Material UI module

    mui-slidepanel.lua : This is for creating slide out panel widgets.

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

function M.newSlidePanel(options)
	if options == nil then return end

    if muiData.widgetDict[options.name] ~= nil then
        M.touchSlidePanelBarrier({target={muiOptions=options}})
        return
    end

    local x, y = 0, 0
    local buttonWidth = 1
    local buttonOffset = 0
    local activeX = 0

    if options.isChecked == nil then
        options.isChecked = false
    end

    options.width = options.width or ( muiData.contentWidth * 0.5 )

    muiData.dialogName = options.name
    muiData.dialogInUse = true
    muiData.slidePanelName = options.name
    muiData.slidePanelInUse = true

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "SlidePanel"
    muiData.widgetDict[options.name]["options"] = options

    -- animate the menu button
    if options.buttonToAnimate ~= nil then
        local animateButton = M.getWidgetBaseObject(options.buttonToAnimate)
        transition.to( animateButton, { rotation=90, time=300, transition=easing.inOutCubic } )
        muiData.widgetDict[options.name]["buttonToAnimate"] = animateButton
    end

    -- place on main display
    muiData.widgetDict[options.name]["rectbackdrop"] = display.newRect( muiData.contentWidth * 0.5, muiData.contentHeight * 0.5, muiData.contentWidth, muiData.contentHeight)
    muiData.widgetDict[options.name]["rectbackdrop"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectbackdrop"]:setFillColor( unpack( {0.4, 0.4, 0.4, 0.3} ) )
    muiData.widgetDict[options.name]["rectbackdrop"].isVisible = true

    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"].x = 0
    muiData.widgetDict[options.name]["mygroup"].y = muiData.contentHeight * 0.5
    muiData.widgetDict[options.name]["mygroup"].muiOptions = options

    -- put menu on a scrollview
    local scrollWidth = muiData.contentWidth * 0.5
    scrollView = widget.newScrollView(
        {
            top = 0,
            left = -(options.width),
            width = options.width,
            height = muiData.contentHeight,
            scrollWidth = scrollWidth,
            scrollHeight = muiData.contentHeight,
            hideBackground = false,
            isBounceEnabled = false,
            backgroundColor = options.fillColor,
            listener = M.sliderScrollListener
        }
    )

    scrollView.muiOptions = options
    muiData.widgetDict[options.name]["scrollview"] = scrollView

    local rectclickWidth = muiData.contentWidth - options.width
    muiData.widgetDict[options.name]["rectclick"] = display.newRect( 0, 0, rectclickWidth, muiData.contentHeight)
    muiData.widgetDict[options.name]["rectclick"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectclick"]:setFillColor( unpack( { 1, 1, 1, 0.01 } ) )
    muiData.widgetDict[options.name]["rectclick"].isVisible = true
    muiData.widgetDict[options.name]["rectclick"]:addEventListener( "touch", M.touchSlidePanelBarrier )
    muiData.widgetDict[options.name]["rectclick"].muiOptions = options
    muiData.widgetDict[options.name]["rectclick"].x = options.width + (rectclickWidth * 0.5)
    muiData.widgetDict[options.name]["rectclick"].y = muiData.contentHeight * 0.5


    -- put in title text and background if specified

    -- measure text
    local textToMeasure = display.newText( options.title, 0, 0, options.titleFont, options.titleFontSize )
    local tw = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil

    if options.titleBackgroundColor ~= nil then
        local backgroundHeight = tw * 2
        muiData.widgetDict[options.name]["rect"] = display.newRect( options.width * 0.5, backgroundHeight * 0.5, options.width, backgroundHeight)
        muiData.widgetDict[options.name]["rect"]:setFillColor( unpack( options.titleBackgroundColor ) )
        muiData.widgetDict[options.name]["scrollview"]:insert( muiData.widgetDict[options.name]["rect"] )
    end

    textOptions = {
        y = tw,
        x = ((options.width - tw) * 0.5),
        name = options.name .. "header-text",
        text = (options.title or "Hello!"),
        align = (options.titleAlign or "center"),
        width = options.width,
        font = (options.titleFont or native.systemFontBold),
        fontSize = (options.titleFontSize or M.getScaleVal(30)),
        fillColor = (options.titleFontColor or { 1, 1, 1, 1 }),
    }
    M.newText(textOptions)
    muiData.widgetDict[options.name]["scrollview"]:insert( M.getWidgetBaseObject(options.name .. "header-text") )


    -- add the buttons

    if options.list ~= nil then
        local count = #options.list
        muiData.widgetDict[options.name]["slidebar"] = {}
        y = muiData.widgetDict[options.name]["rect"].contentHeight + muiData.widgetDict[options.name]["rect"].contentHeight * 0.5
        for i, v in ipairs(options.list) do
            if v.key ~= "LineSeparator" then
            M.newSlidePanelButton({
                index = i,
                name = options.name .. "_" .. i,
                basename = options.name,
                label = v.key,
                value = v.value,
                text = v.icon,
                textOn = v.icon,
                width = options.width,
                height = options.height,
                buttonHeight = options.buttonHeight,
                x = options.buttonHeight * 0.5,
                y = y,
                touchpoint = options.touchpoint,
                isChecked = v.isChecked,
                isActive = v.isActive,
                font = "MaterialIcons-Regular.ttf",
                labelText = v.labelText,
                labelFont = options.labelFont,
                labelFontSize = options.labelFontSize,
                textAlign = "center",
                labelColor = options.labelColor,
                labelColorOff = options.labelColorOff,
                backgroundColor = options.fillColor,
                buttonHighlightColor = options.buttonHighlightColor,
                buttonHighlightColorAlpha = (options.buttonHighlightColorAlpha or 0.5),
                numberOfButtons = count,
                callBack = options.callBack,
                callBackData = options.callBackData
            })
            else
                M.newSlidePanelLineSeparator({
                index = i,
                name = options.name .. "_" .. i,
                basename = options.name,
                width = options.width,
                height = options.height,
                buttonHeight = options.buttonHeight,
                x = options.buttonHeight * 0.5,
                y = y,
                labelColorOff = options.labelColorOff,
            })
            end
            local button = muiData.widgetDict[options.name]["slidebar"][options.name.."_"..i]
            buttonWidth = button["buttonWidth"]
            if i == 1 then buttonOffset = button["buttonOffset"] end

            y = y + button["buttonHeight"] + button["buttonOffset"]

            if v.isChecked == true or v.isActive == true then
                activeX = button["mygroup"].x
            end
        end
    end

    -- animate the menu for display

    transition.fadeIn(muiData.widgetDict[options.name]["rectclick"],{time=300})
    transition.fadeIn(muiData.widgetDict[options.name]["rectbackdrop"],{time=300})
    transition.to( muiData.widgetDict[options.name]["scrollview"], { time=300, x=(options.width * 0.5), transition=easing.linear } )
end

function M.getSlidePanelProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "title" then
        data = muiData.widgetDict[widgetName .. "header-text"] -- the header/title text of menu
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rectbackdrop"] -- backdrop of whole widget
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["rectclick"] -- the right side area that 
    end
    return data
end

function M.newSlidePanelLineSeparator( options )
    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    local barWidth = muiData.contentWidth
    if options.width ~= nil then
        barWidth = options.width
    end
    barWidth = muiData.widgetDict[options.basename]["scrollview"].contentWidth

    local lineSeparatorHeight = options.lineSeparatorHeight or M.getScaleVal(1)

    muiData.widgetDict[options.basename]["slidebar"][options.name] = {}
    muiData.widgetDict[options.basename]["slidebar"]["type"] = "slidebarLineSeparator"

    local button =  muiData.widgetDict[options.basename]["slidebar"][options.name]
    button["mygroup"] = display.newGroup()
    button["mygroup"].x = x
    button["mygroup"].y = y

    if options.labelColorOff == nil then
        options.labelColorOff = { 0, 0, 0 }
    end

    local lineSeparator = display.newRect( 0, 0, barWidth * 2, M.getScaleVal(lineSeparatorHeight) )
    lineSeparator:setFillColor( unpack(options.labelColorOff) )
    button["lineSeparator"] = lineSeparator
    button["buttonWidth"] = lineSeparator.contentWidth
    button["buttonHeight"] = options.buttonHeight
    button["buttonOffset"] = lineSeparator.contentHeight * 0.5
    button["mygroup"]:insert( lineSeparator, true ) -- insert and center bkgd

    muiData.widgetDict[options.basename]["scrollview"]:insert( button["mygroup"] )
end

function M.newSlidePanelButton( options )
    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    local barWidth = muiData.contentWidth
    if options.width ~= nil then
        barWidth = options.width
    end

    muiData.widgetDict[options.basename]["slidebar"][options.name] = {}
    muiData.widgetDict[options.basename]["slidebar"]["type"] = "slidebarButton"

    local button =  muiData.widgetDict[options.basename]["slidebar"][options.name]
    button["mygroup"] = display.newGroup()
    button["mygroup"].x = x
    button["mygroup"].y = y
    button["touching"] = false

    -- label colors
    if options.labelColorOff == nil then
        options.labelColorOff = { 0, 0, 0 }
    end
    if options.labelColor == nil then
        options.labelColor = { 1, 1, 1 }
    end
    muiData.widgetDict[options.basename]["slidebar"]["labelColorOff"] = options.labelColorOff
    muiData.widgetDict[options.basename]["slidebar"]["labelColor"] = options.labelColor

    local fontSize = options.buttonHeight
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end
    fontSize = mathFloor(tonumber(fontSize))

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local useBothIconAndText = false
    if options.text ~= nil and options.labelText ~= nil then
        useBothIconAndText = true
    end

    if useBothIconAndText == false and options.labelFont ~= nil and options.labelText ~= nil then
        font = options.labelFont
    end

    if useBothIconAndText == false and options.labelFont ~= nil and options.labelText ~= nil then
        options.text = options.labelText
    end

    local labelColor = { 0, 0, 0 }
    if options.labelColor ~= nil then
        labelColor = options.labelColor
    end

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end
    if options.isActive ~= nil then
        isChecked = options.isActive
    end

    button["font"] = font
    button["fontSize"] = fontSize
    button["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given field's height
    local field = {contentHeight=options.buttonHeight, contentWidth=options.buttonHeight}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    local fontSize = fontSize * ( ( field.contentHeight ) / textToMeasure.contentHeight )
    local textWidth = textToMeasure.contentWidth
    local textHeight = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil

    local buttonWidth = textWidth
    local buttonHeight = textHeight
    local rectangle = display.newRect( buttonWidth * 0.5, 0, buttonWidth, buttonHeight )
    rectangle:setFillColor( unpack({1,1,1,0}) ) -- options.backgroundColor
    button["rectangle"] = rectangle
    button["rectangle"].value = options.value
    button["buttonWidth"] = rectangle.contentWidth
    button["buttonHeight"] = rectangle.contentHeight
    button["buttonOffset"] = rectangle.contentHeight * 0.5
    button["mygroup"]:insert( rectangle, true ) -- insert and center bkgd

    button["buttonOffset"] = options.buttonSpacing or M.getScaleVal(10)

    local textY = 0
    local textSize = fontSize
    if useBothIconAndText == true then
        textY = 0
        textSize = fontSize * 0.9
    end

    local options2 =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = textY,
        font = font,
        fontSize = textSize,
        align = "left"
    }

    button["myButton"] = display.newRect( (options.width * 0.5) - textHeight * 0.5, textY, options.width, textHeight )
    button["myButton"]:setFillColor( unpack( options.backgroundColor ) )
    button["mygroup"]:insert( button["myButton"] )

    button["myText"] = display.newText( options2 )
    button["myText"]:setFillColor( unpack(options.labelColorOff) )
    button["myText"].isVisible = true
    if isChecked then
        button["myText"]:setFillColor( unpack(options.labelColor) )
        button["myText"].isChecked = isChecked
    else
        button["myText"]:setFillColor( unpack(options.labelColorOff) )
        button["myText"].isChecked = false
    end
    button["mygroup"]:insert( button["myText"], false )

    local maxWidth = field.contentWidth * 2.5

    if useBothIconAndText == true then
        local labelWidth = options.width - button["rectangle"].contentWidth
        local options3 =
        {
            --parent = textGroup,
            text = options.labelText,
            x = 0,
            y = 0,
            width = labelWidth,
            font = options.labelFont,
            fontSize = fontSize * 0.45,
            align = "left"
        }
        button["myText2"] = display.newText( options3 )
        button["myText2"]:setFillColor( unpack(textColor) )
        button["myText2"].x = (labelWidth * 0.5) + button["rectangle"].contentWidth
        button["myText2"].isVisible = true
        if isChecked then
            button["myText2"]:setFillColor( unpack(options.labelColor) )
            button["myText2"].isChecked = isChecked
        else
            button["myText2"]:setFillColor( unpack(options.labelColorOff) )
            button["myText2"].isChecked = false
        end
        button["mygroup"]:insert( button["myText2"], false )
    end

    thebutton = button["rectangle"]
    field = button["myText"]
    thebutton.name = options.name
    field.name = options.name

    thebutton.muiOptions = options
    thebutton.muiButton = button

    button["myButton"].muiOptions = options
    button["myButton"].name = options.name

    muiData.widgetDict[options.basename]["scrollview"]:insert( button["mygroup"] )
    muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"]:addEventListener( "touch", M.slidePanelEventButton )
end

function M.getSlidePanelButtonProperty(widgetParentName, propertyName, index)
    local data = nil

    if widgetParentName == nil or propertyName == nil then return data end

    if index < 1 then index = 1 end
    local widgetName = widgetParentName .. "_" .. index

    if muiData.widgetDict[widgetParentName]["slidebar"][widgetName] == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetParentName]["slidebar"][widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetParentName]["slidebar"][widgetName]["rectangle"] -- transparent button background
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetParentName]["slidebar"][widgetName]["myButton"] -- button background
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetParentName]["slidebar"][widgetName]["myText"] -- icon/text
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetParentName]["slidebar"][widgetName]["myText2"] -- text for icon
    end
    return data
end

function M.slidePanelEventButton (event)
    local options = nil
    local button = nil
    if event.target ~= nil then
        options = event.target.muiOptions
        button = event.target.muiButton
    end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.slidePanelEventButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
            muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"]:setFillColor( unpack( options.buttonHighlightColor ) )
            muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"].alpha = options.buttonHighlightColorAlpha
        end
    elseif ( event.phase == "cancelled" or event.phase == "moved" ) then
        M.sliderButtonResetColor( muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"] )
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- print("Its out of the button area")
        else
            event.phase = "onTarget"
            if muiData.interceptMoved == false then
                transition.to(muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"],{time=400, alpha=0.01, onComplete=M.sliderButtonResetColor})

                transition.to(muiData.widgetDict[options.basename]["slidebar"]["slider"],{time=350, xScale=1.03, yScale=1.03, transition=easing.inOutCubic})

                event.myTargetName = options.name
                event.myTargetBasename = options.basename
                event.altTarget = muiData.widgetDict[options.basename]["slidebar"][options.name]["myText"]
                event.altTarget2 = muiData.widgetDict[options.basename]["slidebar"][options.name]["myText2"]
                event.callBackData = options.callBackData

                muiData.widgetDict[options.basename]["value"] = options.value
                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.basename]["slidebar"][options.name]["myText"])
                M.setEventParameter(event, "muiTarget2", muiData.widgetDict[options.basename]["slidebar"][options.name]["myText2"])
                M.setEventParameter(event, "muiTargetCallBackData", options.callBackData)
                if options.callBack ~= nil then
                    assert( options.callBack ) (options, event)
                else
                    M.actionForSlidePanel(options, event)
                end
            else
                M.sliderButtonResetColor( muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"] )
            end
        end
        muiData.interceptEventHandler = nil
        muiData.interceptOptions = nil
        muiData.interceptMoved = false
        muiData.touching = false
    end
end

function M.sliderButtonResetColor( e )
    e:setFillColor( unpack(e.muiOptions.backgroundColor) )
    e.alpha = 0.01
end

function M.actionForSlidePanel( options, e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")
    local muiTargetCallBackData = M.getEventParameter(e, "muiTargetCallBackData")

    if muiTargetValue ~= nil then
        print("slide panel value: "..muiTargetValue)
    end
    if muiTargetCallBackData ~= nil then
        print("Item from callBackData: "..muiTargetCallBackData.item)
    end
end

function M.touchSlidePanelBarrier( event )
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if ( event.phase == "began" ) then

        muiData.widgetDict[options.name]["interceptEventHandler"] = M.touchSlidePanelBarrier
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
        end
    elseif ( event.phase == "ended" ) then
        local width = muiData.widgetDict[options.name]["width"]

        transition.fadeOut(muiData.widgetDict[options.name]["rectclick"],{time=200})
        transition.fadeOut(muiData.widgetDict[options.name]["rectbackdrop"],{time=300})
        muiData.widgetDict[options.name]["scrollview"].muiOptions = options
        transition.to( muiData.widgetDict[options.name]["scrollview"], { time=300, x=-(options.width * 0.5), transition=easing.linear, onComplete=M.sliderPanelFinish } )
        -- animate the menu button
        if muiData.widgetDict[options.name]["buttonToAnimate"] ~= nil then
            transition.to( muiData.widgetDict[options.name]["buttonToAnimate"], { rotation=0, time=300, transition=easing.inOutCubic } )
        end
        muiData.touching = false
        muiData.interceptEventHandler = nil
        muiData.widgetDict[options.name]["interceptEventHandler"] = nil
    end
end

function M.sliderPanelFinish( event )
  if event ~= nil and event.muiOptions ~= nil then
    M.removeSlidePanel(event.muiOptions.name)
  end
end

function M.sliderScrollListener( event )

    local phase = event.phase
    if event.phase == nil then return end

    M.updateEventHandler( event )

    if ( phase == "began" ) then
        -- skip it
    elseif ( phase == "moved" ) then
        M.updateUI(event)
    elseif ( phase == "ended" ) then
        -- print( "Scroll view was released" )
    end

    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then print( "Reached top limit" )
        elseif ( event.direction == "left" ) then print( "Reached right limit" )
        elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end

    return true
end


function M.removeSlidePanel(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    -- remove the header if used
    if muiData.widgetDict[widgetName]["rect"] ~= nil then
        muiData.widgetDict[widgetName]["rect"]:removeSelf()
        muiData.widgetDict[widgetName]["rect"] = nil
    end

    if muiData.widgetDict[widgetName .. "header-text"] ~= nil then
        M.removeText( widgetName .. "header-text" )
    end

    -- remove the list of buttons
    for name in pairs(muiData.widgetDict[widgetName]["slidebar"]) do
        M.removeSlidePanelButton(muiData.widgetDict, widgetName, name)
        if name ~= "slider" and name ~= "rectBak" then
            muiData.widgetDict[widgetName]["slidebar"][name] = nil
        end
    end

    muiData.widgetDict[widgetName]["rectclick"]:removeSelf()
    muiData.widgetDict[widgetName]["rectclick"] = nil
    muiData.widgetDict[widgetName]["scrollview"]:removeSelf()
    muiData.widgetDict[widgetName]["scrollview"] = nil
    muiData.widgetDict[widgetName]["rectbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["rectbackdrop"] = nil
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil

    muiData.dialogName = nil
    muiData.dialogInUse = false
    muiData.slidePanelName = nil
    muiData.slidePanelInUse = false
end

function M.removeSlidePanelLineSeparator(widgetDict, slidePanelName, name)
    if slidePanelName == nil then
        return
    end
    if name == nil then
        return
    end
    if widgetDict[slidePanelName]["slidebar"][name] == nil then
        return
    end
    if type(widgetDict[slidePanelName]["slidebar"][name]) == "table" then
        if widgetDict[slidePanelName]["slidebar"][name]["lineSeparator"] ~= nil then
            widgetDict[slidePanelName]["slidebar"][name]["lineSeparator"]:removeSelf()
            widgetDict[slidePanelName]["slidebar"][name]["lineSeparator"] = nil
        end
    end
end

function M.removeSlidePanelButton(widgetDict, slidePanelName, name)
    if slidePanelName == nil then
        return
    end
    if name == nil then
        return
    end
    if widgetDict[slidePanelName]["slidebar"][name] == nil then
        return
    end
    if type(widgetDict[slidePanelName]["slidebar"][name]) == "table" then
        if widgetDict[slidePanelName]["slidebar"][name]["type"] == "slidebarButton" then
            widgetDict[slidePanelName]["slidebar"][name]["myButton"]:removeEventListener( "touch", M.slidePanelEventButton )
            widgetDict[slidePanelName]["slidebar"][name]["myButton"]:removeSelf()
            widgetDict[slidePanelName]["slidebar"][name]["myButton"] = nil
            widgetDict[slidePanelName]["slidebar"][name]["rectangle"]:removeSelf()
            widgetDict[slidePanelName]["slidebar"][name]["rectangle"] = nil
            widgetDict[slidePanelName]["slidebar"][name]["myText"]:removeSelf()
            widgetDict[slidePanelName]["slidebar"][name]["myText"] = nil
            if widgetDict[slidePanelName]["slidebar"][name]["myText2"] ~= nil then
                widgetDict[slidePanelName]["slidebar"][name]["myText2"]:removeSelf()
                widgetDict[slidePanelName]["slidebar"][name]["myText2"] = nil
            end
        else
            if widgetDict[slidePanelName]["slidebar"][name]["lineSeparator"] ~= nil then
                widgetDict[slidePanelName]["slidebar"][name]["lineSeparator"]:removeSelf()
                widgetDict[slidePanelName]["slidebar"][name]["lineSeparator"] = nil
            end
        end
        if widgetDict[slidePanelName]["slidebar"][name]["mygroup"] ~= nil then
            widgetDict[slidePanelName]["slidebar"][name]["mygroup"]:removeSelf()
            widgetDict[slidePanelName]["slidebar"][name]["mygroup"] = nil
            widgetDict[slidePanelName]["slidebar"][name] = nil
        end
    end
end
return M
