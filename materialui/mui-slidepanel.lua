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

    if muiData.widgetDict[options.name] ~= nil and muiData.slidePanelInUse == true then
        M.touchSlidePanelBarrier({target={muiOptions=options}})
        return
    elseif muiData.widgetDict[options.name] ~= nil and muiData.slidePanelInUse == false then
        M.showSlidePanel(options.name)
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

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "SlidePanel"
    muiData.widgetDict[options.name]["options"] = options

    -- animate the menu button
    if options.buttonToAnimate ~= nil then
        local animateButton = M.getWidgetBaseObject(options.buttonToAnimate)
        muiData.widgetDict[options.name]["buttonToAnimate"] = animateButton
    end

    -- place on main display
    muiData.widgetDict[options.name]["rectbackdrop"] = display.newRect(
        display.screenOriginX + muiData.safeAreaInsets.leftInset, 
        display.screenOriginY + muiData.safeAreaInsets.topInset, 
        display.viewableContentWidth - ( muiData.safeAreaInsets.leftInset + muiData.safeAreaInsets.rightInset ), 
        display.viewableContentHeight - ( muiData.safeAreaInsets.topInset + muiData.safeAreaInsets.bottomInset )
    )
    muiData.widgetDict[options.name]["rectbackdrop"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectbackdrop"]:setFillColor( unpack( {0.4, 0.4, 0.4, 0.3} ) )
    muiData.widgetDict[options.name]["rectbackdrop"].isVisible = true
    muiData.widgetDict[options.name]["rectbackdrop"]:translate( 
            muiData.widgetDict[options.name]["rectbackdrop"].contentWidth * .5,
            muiData.widgetDict[options.name]["rectbackdrop"].contentHeight * .5
    )

    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"].x = 0
    muiData.widgetDict[options.name]["mygroup"].y = muiData.contentHeight * 0.5
    muiData.widgetDict[options.name]["mygroup"].muiOptions = options

    -- put menu on a scrollview

    -- get orientation of device
    muiData.safeAreaOffsetMenu = 0
    if muiData.safeAreaInsets.rightInset > 0 then
        options.width = options.width + muiData.safeAreaInsets.rightInset
        muiData.safeAreaOffsetMenu = muiData.safeAreaInsets.rightInset
    elseif muiData.safeAreaInsets.leftInset > 0 then
        options.width = options.width + muiData.safeAreaInsets.leftInset
        muiData.safeAreaOffsetMenu = muiData.safeAreaInsets.leftInset
    end

    local scrollWidth = muiData.contentWidth * 0.5
    local topScrollView = muiData.safeAreaInsets.topInset
    local heightScrollView = muiData.contentHeight - (muiData.safeAreaInsets.topInset + muiData.safeAreaInsets.bottomInset)

    scrollView = widget.newScrollView(
        {
            top = topScrollView,
            left = -(options.width),
            width = options.width,
            height = heightScrollView,
            scrollWidth = scrollWidth,
            scrollHeight = heightScrollView,
            hideBackground = false,
            isBounceEnabled = false,
            backgroundColor = options.fillColor,
            horizontalScrollDisabled = true,
            listener = M.sliderScrollListener
        }
    )

    scrollView.muiOptions = options
    muiData.widgetDict[options.name]["scrollview"] = scrollView

    local rectclickWidth = muiData.contentWidth - options.width
    muiData.widgetDict[options.name]["rectclick"] = display.newRect(
        display.screenOriginX + muiData.safeAreaInsets.leftInset, 
        display.screenOriginY + muiData.safeAreaInsets.topInset, 
        display.viewableContentWidth, 
        display.viewableContentHeight - ( muiData.safeAreaInsets.topInset + muiData.safeAreaInsets.bottomInset )
    )

    -- display.newRect( display.cen, 0, rectclickWidth, muiData.contentHeight)
    
    muiData.widgetDict[options.name]["rectclick"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectclick"]:setFillColor( unpack( { 1, 1, 1, 0.01 } ) )
    muiData.widgetDict[options.name]["rectclick"].isVisible = true
    muiData.widgetDict[options.name]["rectclick"]:addEventListener( "touch", M.touchSlidePanelBarrier )
    muiData.widgetDict[options.name]["rectclick"].muiOptions = options
    muiData.widgetDict[options.name]["rectclick"].x = (scrollView.x + scrollView.contentWidth) + (muiData.contentWidth - scrollView.contentWidth)
    muiData.widgetDict[options.name]["rectclick"].y = (muiData.contentHeight * 0.5) - (muiData.safeAreaInsets.bottomInset * .5)


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

    -- place header image if present
    if options.headerImage ~= nil then
        muiData.widgetDict[options.name]["header_image"] = display.newImageRect( options.headerImage, muiData.widgetDict[options.name]["rect"].contentWidth, muiData.widgetDict[options.name]["rect"].contentHeight )
        muiData.widgetDict[options.name]["scrollview"]:insert( muiData.widgetDict[options.name]["header_image"] )
        muiData.widgetDict[options.name]["header_image"].x = muiData.widgetDict[options.name]["rect"].contentWidth * 0.5
        muiData.widgetDict[options.name]["header_image"].y = muiData.widgetDict[options.name]["rect"].contentHeight * 0.5
     end

    textOptions = {
        y = tw,
        x = ((options.width - tw) * 0.5),
        name = options.name .. "header-text",
        text = (options.title or "Hello!"),
        align = (options.titleAlign or "center"),
        width = options.width,
        font = (options.titleFont or native.systemFontBold),
        fontSize = (options.titleFontSize or 15),
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
                x = (options.buttonHeight * 0.5),
                y = y,
                iconImage = v.iconImage,
                touchpoint = options.touchpoint,
                isChecked = v.isChecked,
                isActive = v.isActive,
                isFontIcon = true,
                font = muiData.materialFont,
                labelText = v.labelText,
                labelFont = options.labelFont,
                labelFontSize = options.labelFontSize,
                textAlign = "center",
                labelColor = options.labelColor,
                labelColorOff = options.labelColorOff,
                iconColor = v.iconColor or options.labelColor,
                iconColorOff = v.iconColorOff or options.labelColorOff,
                backgroundColor = options.fillColor,
                buttonHighlightColor = options.buttonHighlightColor,
                buttonHighlightColorAlpha = (options.buttonHighlightColorAlpha or 0.5),
                numberOfButtons = count,
                callBack = v.callBack or options.callBack,
                callBackData = v.callBackData or options.callBackData
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
    if options.isVisible == nil then options.isVisible = true end
    if options.isVisible == true then
        M.toFrontSafeArea()
        muiData.dialogName = options.name
        muiData.dialogInUse = true
        muiData.slidePanelName = options.name
        muiData.slidePanelInUse = true
        muiData.slideBarrierTouched = false
        transition.fadeIn(muiData.widgetDict[options.name]["rectclick"],{time=300})
        transition.fadeIn(muiData.widgetDict[options.name]["rectbackdrop"],{time=300})
        transition.to( muiData.widgetDict[options.name]["scrollview"], { time=300, x=(options.width * 0.5), transition=easing.linear } )
        transition.to( animateButton, { rotation=90, time=300, transition=easing.inOutCubic } )
    else
        muiData.slidePanelName = options.name
        muiData.widgetDict[options.name]["rectclick"].isVisible = false
        muiData.widgetDict[options.name]["rectbackdrop"].isVisible = false
        muiData.slideOut = false
    end
    muiData.widgetDict[options.name]["scrollview"].moved_object = false

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

    local lineSeparatorHeight = options.lineSeparatorHeight or 1

    muiData.widgetDict[options.basename]["slidebar"][options.name] = {}
    muiData.widgetDict[options.basename]["slidebar"]["type"] = "slidebarLineSeparator"

    local button =  muiData.widgetDict[options.basename]["slidebar"][options.name]
    button["mygroup"] = display.newGroup()
    button["mygroup"].x = x
    button["mygroup"].y = y

    if options.labelColorOff == nil then
        options.labelColorOff = { 0, 0, 0 }
    end

    local lineSeparator = display.newRect( 0, 0, barWidth * 2, lineSeparatorHeight )
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
    muiData.widgetDict[options.basename]["slidebar"][options.name]["labelColorOff"] = options.labelColorOff
    muiData.widgetDict[options.basename]["slidebar"][options.name]["labelColor"] = options.labelColor
    muiData.widgetDict[options.basename]["slidebar"][options.name]["iconColorOff"] = options.iconColorOff
    muiData.widgetDict[options.basename]["slidebar"][options.name]["iconColor"] = options.iconColor

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

    if options.isFontIcon == nil then
        options.isFontIcon = false
        -- backwards compatiblity
        if M.isMaterialFont(font) == true then
            options.isFontIcon = true
        end
    end

    button["options"] = options
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
    textWidth = fontSize
    local buttonHeight = textHeight
    -- local rectangle = display.newRect( buttonWidth * 0.5, 0, buttonWidth, buttonHeight )
    local rectangle = display.newRect( buttonWidth * 0.5, 0, buttonWidth, buttonHeight )
    options.backgroundColor = options.backgroundColor or { 1, 1, 1, 1 }
    rectangle:setFillColor( unpack( options.backgroundColor ) )
    button["rectangle"] = rectangle
    button["rectangle"].value = options.value
    button["buttonWidth"] = rectangle.contentWidth
    button["buttonHeight"] = rectangle.contentHeight
    button["buttonOffset"] = rectangle.contentHeight * 0.5
    button["mygroup"]:insert( rectangle, true ) -- insert and center bkgd

    button["buttonOffset"] = options.buttonSpacing or 5

    local textY = 0
    local textSize = fontSize
    if useBothIconAndText == true then
        textY = 0
        textSize = fontSize * 0.9
    end

    if options.isFontIcon == true then
        tw = fontSize
        if M.isMaterialFont(font) == true then
            options.text = M.getMaterialFontCodePointByName(options.text)
        end
    elseif string.len(options.text) < 2 then
        tw = fontSize
    end

    local options2 =
    {
        --parent = textGroup,
        text = options.text,
        x = muiData.safeAreaOffsetMenu,
        y = textY,
        font = font,
        width = textSize * 1.5,
        fontSize = textSize,
        align = "center"
    }

    button["myButton"] = display.newRect( ((options.width * 0.5) - textHeight * 0.5) + muiData.safeAreaOffsetMenu, textY, options.width, textHeight )
    button["myButton"]:setFillColor( unpack( options.backgroundColor ) )
    button["mygroup"]:insert( button["myButton"] )

    if options.iconImage ~= nil then
        button["myText"] = display.newImageRect( options.iconImage, textSize, textSize )
        button["myText"].x = button["myText"].x + muiData.safeAreaOffsetMenu
    else
        button["myText"] = display.newText( options2 )
        button["myText"].isVisible = true
        if isChecked then
            button["myText"]:setFillColor( unpack(options.iconColor) )
            button["myText"].isChecked = isChecked
        else
            button["myText"]:setFillColor( unpack(options.iconColorOff) )
            button["myText"].isChecked = false
        end
    end
    -- button["myText"].x = button["myText"].x + muiData.safeAreaOffsetMenu
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
            font = options.labelFont,
            fontSize = fontSize * 0.45,
        }
        button["myText2"] = display.newText( options3 )
        button["myText2"].x = fontSize + (button["myText2"].contentWidth * 0.5) + muiData.safeAreaOffsetMenu
        if isChecked then
            button["myText2"]:setFillColor( unpack(options.labelColor) )
            button["myText2"].isChecked = isChecked
        else
            button["myText2"]:setFillColor( unpack(options.labelColorOff) )
            button["myText2"].isChecked = false
        end
        -- button["myText2"].x = button["myText2"].x + muiData.safeAreaOffsetMenu
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
            for name in pairs(muiData.widgetDict[options.basename]["slidebar"]) do
                if muiData.widgetDict[options.basename]["slidebar"][name]["myButton"] ~= nil then
                  local labelColorOff
                  local opts = muiData.widgetDict[options.basename]["slidebar"][name]["options"]
                  if opts ~= nil then
                    labelColorOff = opts.iconColorOff or options.labelColorOff
                  end

                  muiData.widgetDict[options.basename]["slidebar"][name]["myButton"]:setFillColor( unpack(options.backgroundColor) )
                  muiData.widgetDict[options.basename]["slidebar"][name]["myButton"].alpha = 0.01

                  if opts.iconImage == nil then
                      muiData.widgetDict[options.basename]["slidebar"][name]["myText"]:setFillColor( unpack(labelColorOff) )
                  end
                  muiData.widgetDict[options.basename]["slidebar"][name]["myText"].isChecked = false
                  muiData.widgetDict[options.basename]["slidebar"][name]["myText2"]:setFillColor( unpack(labelColorOff) )
                  muiData.widgetDict[options.basename]["slidebar"][name]["myText2"].isChecked = false
                end
            end
            local labelColor
            local opts = muiData.widgetDict[options.basename]["slidebar"][options.name]["options"]
            if opts ~= nil then
              labelColor = opts.iconColor or options.labelColor
            end
            muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"]:setFillColor( unpack( options.buttonHighlightColor ) )
            muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"].alpha = options.buttonHighlightColorAlpha
            if opts.iconImage == nil then
               muiData.widgetDict[options.basename]["slidebar"][options.name]["myText"]:setFillColor( unpack(labelColor) )
            end
            muiData.widgetDict[options.basename]["slidebar"][options.name]["myText"].isChecked = isChecked
            muiData.widgetDict[options.basename]["slidebar"][options.name]["myText2"]:setFillColor( unpack(labelColor) )
            muiData.widgetDict[options.basename]["slidebar"][options.name]["myText2"].isChecked = isChecked
        end
    elseif event.phase == "cancelled" or event.phase == "moved" then
        if muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"] ~= nil then
            M.sliderButtonResetColor( muiData.widgetDict[options.basename]["slidebar"][options.name]["myButton"] )
        end
        muiData.touching = false
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
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
    if e.target ~= nil then
        e:setFillColor( unpack(e.muiOptions.backgroundColor) )
        e.alpha = 0.01
    end
end

function M.actionForSlidePanel( options, e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")
    local muiTargetCallBackData = M.getEventParameter(e, "muiTargetCallBackData")

    if muiTargetValue ~= nil then
        M.debug("slide panel value: "..muiTargetValue)
    end
    if muiTargetCallBackData ~= nil then
        M.debug("Item from callBackData: "..muiTargetCallBackData.item)
    end
    if e.myTargetBasename ~= nil then
        M.closeSlidePanel(e.myTargetBasename)
    end
end

function M.showSlidePanel( widgetName, slideOut )

    if widgetName ~= nil and muiData.widgetDict[widgetName] ~= nil then

        if slideOut == nil then slideOut = false end

        if muiData.slidePanelInUse == true then
            M.hideSlidePanel( widgetName )
            return
        end
        -- animate the menu button
        if muiData.widgetDict[widgetName]["buttonToAnimate"] ~= nil then
            transition.to( muiData.widgetDict[widgetName]["buttonToAnimate"], { rotation=90, time=300, transition=easing.inOutCubic } )
        end
        local options = muiData.widgetDict[widgetName]["mygroup"].muiOptions
        if slideOut == false then
            transition.to( muiData.widgetDict[widgetName]["scrollview"], { time=300, x=(options.width * 0.5), transition=easing.linear } )
            transition.fadeIn(muiData.widgetDict[widgetName]["rectclick"],{time=300})
            transition.fadeIn(muiData.widgetDict[widgetName]["rectbackdrop"],{time=300})
            muiData.widgetDict[widgetName]["rectclick"].isVisible = true
            muiData.widgetDict[widgetName]["rectbackdrop"].isVisible = true
			muiData.widgetDict[widgetName]["scrollview"]:toFront()
            M.toFrontSafeArea()
        else
            muiData.widgetDict[widgetName].isVisible = true
			--muiData.widgetDict[widgetName]["scrollview"]:toFront()
            --transition.fadeIn(muiData.widgetDict[widgetName]["rectclick"],{time=0})
            --transition.fadeIn(muiData.widgetDict[widgetName]["rectbackdrop"],{time=0})
        end
        muiData.dialogName = widgetName
        muiData.dialogInUse = true
        muiData.slidePanelName = widgetName
        muiData.slidePanelInUse = true
        muiData.widgetDict[widgetName]["scrollview"].moved_object = false
    end
    muiData.slideBarrierTouched = false
end

function M.hideSlidePanel( widgetName )
    if widgetName ~= nil and muiData.widgetDict[widgetName] ~= nil then
        local options = muiData.widgetDict[widgetName]["mygroup"].muiOptions
        transition.to( muiData.widgetDict[widgetName]["scrollview"], { time=300, x=-(options.width * 0.5), transition=easing.linear } )
        transition.fadeOut(muiData.widgetDict[widgetName]["rectbackdrop"],{time=300})
        transition.fadeOut(muiData.widgetDict[widgetName]["rectclick"],{time=300})
        muiData.widgetDict[widgetName]["scrollview"].prevEventX = nil
        muiData.widgetDict[widgetName]["scrollview"].origX = nil
        muiData.dialogName = nil
        muiData.dialogInUse = false
        --muiData.slidePanelName = nil
        muiData.slidePanelInUse = false
        muiData.slideBarrierTouched = false
        muiData.slideOut = false
        -- animate the menu button
        if muiData.widgetDict[widgetName]["buttonToAnimate"] ~= nil then
            transition.to( muiData.widgetDict[widgetName]["buttonToAnimate"], { rotation=0, time=300, transition=easing.inOutCubic } )
        end
        -- reset button background colors
        local parentOptions = muiData.widgetDict[widgetName].options
        for k in pairs(muiData.widgetDict[widgetName]["slidebar"]) do
            if k ~= "type" and muiData.widgetDict[widgetName]["slidebar"][k]["myButton"] ~= nil then
                  muiData.widgetDict[widgetName]["slidebar"][k]["myButton"]:setFillColor( unpack(parentOptions.fillColor) )
            end
        end
    end
end

function M.slidePanelOut(event)
    if event == nil then return end

    muiPriv = "muiPriv"
    if muiData.widgetDict[muiPriv]["areaLeftInset"] ~= nil then
        muiData.widgetDict[muiPriv]["areaLeftInset"]:toFront()
    end
    if muiData.widgetDict[muiPriv]["areaRightInset"] ~= nil then
        muiData.widgetDict[muiPriv]["areaRightInset"]:toFront()
    end

    -- the or condition is to avoid a bug state of 'moved'
    if (event.phase == "moved" and muiData.slideOut == false) then
        local widgetName = muiData.slidePanelName
        if widgetName ~= nil and muiData.widgetDict[widgetName]["scrollview"].x <= 0 and event.x < muiData.widgetDict[muiData.slidePanelName]["scrollview"].contentWidth * .25 then
            M.showSlidePanel( widgetName, true )
            muiData.slideOut = true
        end
    elseif muiData.slideOut == true then
        M.sliderScrollListener(event)
    end
end

function M.closeSlidePanel( widgetName )
    if widgetName ~= nil and muiData.widgetDict[widgetName] ~= nil then
        event = {}
        event.target = muiData.widgetDict[widgetName]["scrollview"]
        event.target.muiOptions = muiData.widgetDict[widgetName]["mygroup"].muiOptions
        event.phase = "ended"
        --M.touchSlidePanelBarrier( event )
        if event.target.muiOptions ~= nil and event.target.muiOptions.name ~= nil then
            M.hideSlidePanel( event.target.muiOptions.name )
        end
    end
    return true
end

function M.touchSlidePanelBarrier( event )
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if event.phase == "moved" then
        M.sliderScrollListener( event )
    end

    if options ~= nil and options.name ~= nil and muiData.widgetDict[options.name]["scrollview"].moved_object == false then
        M.hideSlidePanel( options.name )
        muiData.slideBarrierTouched = true
    elseif event.phase == "ended" then
        -- finish scroll out if object was being moved out and ran over barrier
        if muiData.widgetDict[options.name]["scrollview"].moved_object == true then
            M.sliderScrollListener( event )
        end
    end
    return true
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
    local name = muiData.slidePanelName

    if muiData.widgetDict[name] == nil then return end
    if muiData.widgetDict[name]["scrollview"] == nil then return end

    if muiData.widgetDict[name]["move_horizontal"] == nil then
        muiData.widgetDict[name]["move_horizontal"] = false
        muiData.widgetDict[name]["move_vertical"] = false
    end

    muiData.widgetDict[name]["phase"] = phase

    if ( phase == "began" ) then
        -- skip it
    elseif ( phase == "moved" ) then
        M.updateUI(event)
        if muiData.widgetDict[name]["scrollview"].origX == nil then
            muiData.widgetDict[name]["scrollview"].origX = muiData.widgetDict[name]["scrollview"].contentWidth * .5
            muiData.widgetDict[name]["scrollview"].prevEventX = event.x
            muiData.widgetDict[name]["scrollview"].prevEventY = event.y
            if muiData.widgetDict[name]["scrollview"].x <= 0 then
                muiData.widgetDict[name]["rectclick"].isVisible = true
                muiData.widgetDict[name]["rectbackdrop"].isVisible = true
                transition.fadeIn(muiData.widgetDict[name]["rectclick"],{time=0})
                transition.fadeIn(muiData.widgetDict[name]["rectbackdrop"],{time=0})
            end
        end
        if muiData.widgetDict[name]["scrollview"].prevEventX ~= nil then
            if event.x < muiData.widgetDict[name]["scrollview"].prevEventX and muiData.widgetDict[name]["move_vertical"] == false then
                muiData.widgetDict[name]["move_horizontal"] = true
                local diff = muiData.widgetDict[name]["scrollview"].prevEventX - event.x
                if math.abs(diff) > 2 then
                    muiData.widgetDict[name]["scrollview"].x = muiData.widgetDict[name]["scrollview"].x - diff
                    muiData.widgetDict[name]["scrollview"].prevEventX = event.x
                    muiData.widgetDict[name]["scrollview"].muiMoved = true
                    muiData.widgetDict[name]["scrollview"]:setIsLocked(true, "vertical")
                end
                muiData.widgetDict[name]["scrollview"].muiMove = "left"
            elseif event.x > muiData.widgetDict[name]["scrollview"].prevEventX then
                muiData.widgetDict[name]["move_horizontal"] = true
                local diff = event.x - muiData.widgetDict[name]["scrollview"].prevEventX
                if math.abs(diff) > 0 and (muiData.widgetDict[name]["scrollview"].x + diff) <= (muiData.widgetDict[name]["scrollview"].contentWidth * 0.5) then
                    if (muiData.widgetDict[name]["scrollview"].x + diff) >= (muiData.widgetDict[name]["scrollview"].contentWidth) then
                        muiData.widgetDict[name]["scrollview"].x = 0 -- muiData.widgetDict[name]["options"].width * .5
                        diff = 0
                    else
                        muiData.widgetDict[name]["scrollview"].x = muiData.widgetDict[name]["scrollview"].x + diff
                    end
                    muiData.widgetDict[name]["scrollview"].prevEventX = event.x
                    muiData.widgetDict[name]["scrollview"].muiMoved = true
                    muiData.widgetDict[name]["scrollview"]:setIsLocked(true, "vertical")
                end
                muiData.widgetDict[name]["scrollview"].muiMove = "right"
            elseif muiData.widgetDict[name]["move_horizontal"] == false and muiData.widgetDict[name]["scrollview"].prevEventY ~= event.y then
                muiData.widgetDict[name]["move_vertical"] = true
            end
        end
        muiData.widgetDict[name]["scrollview"].moved_object = true
    elseif ( phase == "ended" or phase == "cancelled") then
        muiData.widgetDict[name]["move_horizontal"] = false
        muiData.widgetDict[name]["move_vertical"] = false
        local hide = false
        if muiData.widgetDict[name]["scrollview"].muiMoved ~= nil then
            muiData.widgetDict[name]["scrollview"].muiMoved = nil
            local newX = 0
            local newXRight = 0
            if muiData.widgetDict[name]["scrollview"].origX ~= nil then
                newX = muiData.widgetDict[name]["scrollview"].origX + (muiData.widgetDict[name]["scrollview"].contentWidth * .3)
                newXRight = muiData.widgetDict[name]["scrollview"].origX - (muiData.widgetDict[name]["scrollview"].contentWidth * .35)
            end
            if muiData.widgetDict[name]["scrollview"].muiMove == "left" and muiData.widgetDict[name]["scrollview"].origX ~= nil and (muiData.widgetDict[name]["scrollview"].x+(muiData.widgetDict[name]["scrollview"].contentWidth * 0.5)) <= newX and muiData.widgetDict[name]["scrollview"].moved_object then
                M.hideSlidePanel(name)
                hide = true
            elseif muiData.widgetDict[name]["scrollview"].muiMove == "right" and muiData.widgetDict[name]["scrollview"].origX ~= nil and (muiData.widgetDict[name]["scrollview"].x + muiData.widgetDict[name]["scrollview"].contentWidth * .5) <= newXRight and muiData.widgetDict[name]["scrollview"].moved_object then
                M.hideSlidePanel(name)
                hide = true
            end
            muiData.widgetDict[name]["scrollview"]:setIsLocked(false, "vertical")
            muiData.widgetDict[name]["scrollview"].prevEventX = nil
            muiData.widgetDict[name]["scrollview"].prevEventY = nil
            muiData.widgetDict[name]["scrollview"].origX = nil
        elseif muiData.widgetDict[name]["scrollview"].origX == nil then
            -- did not move, so hide it
            M.hideSlidePanel(name)
            hide = true
        end
        if hide == false then
            transition.to( muiData.widgetDict[name]["scrollview"], { time=300, x=(muiData.widgetDict[name]["scrollview"].contentWidth * 0.5), transition=easing.linear } )
        end
        muiData.widgetDict[name]["scrollview"].moved_object = false
        -- M.debug( "Scroll view was released" )
    end

    -- In the event a scroll limit is reached...
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then M.debug( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then M.debug( "Reached top limit" )
        elseif ( event.direction == "left" ) then M.debug( "Reached right limit" )
        elseif ( event.direction == "right" ) then M.debug( "Reached left limit" )
        end
    end

end


function M.removeSlidePanel(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    -- remove the header if used
    if muiData.widgetDict[widgetName]["rect"] ~= nil then
        if muiData.widgetDict[widgetName]["header_image"] ~= nil then
            muiData.widgetDict[widgetName]["header_image"]:removeSelf()
            muiData.widgetDict[widgetName]["header_image"] = nil
        end
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

    if muiData.widgetDict[widgetName]["areaLeftInset"] ~= nil then
        muiData.widgetDict[widgetName]["areaLeftInset"]:removeSelf()
        muiData.widgetDict[widgetName]["areaLeftInset"] = nil
    end

    if muiData.widgetDict[widgetName]["areaRightInset"] ~= nil then
        muiData.widgetDict[widgetName]["areaRightInset"]:removeSelf()
        muiData.widgetDict[widgetName]["areaRightInset"] = nil
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
    muiData.slideOut = false
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
            if widgetDict[slidePanelName]["slidebar"][name]["myImage"] ~= nil then
                widgetDict[slidePanelName]["slidebar"][name]["myImage"]:removeSelf()
                widgetDict[slidePanelName]["slidebar"][name]["myImage"] = nil
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
