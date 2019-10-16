--[[
A loosely based Material UI module

mui-toolbar.lua : This is for creating horizontal toolbars.

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

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.createToolbarButton( options )
    M.newToolbarButton( options )
end

function M.newToolbarButton( options )
    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    local barWidth = muiData.safeAreaWidth
    if options.width ~= nil then
        barWidth = options.width -- - (muiData.safeAreaInsets.leftInset + muiData.safeAreaInsets.rightInset)
    end

    if options.index ~= nil and options.index == 1 then
        local rectBak = display.newRect( 0, 0, barWidth, options.buttonHeight )
        rectBak:setFillColor( unpack( options.backgroundColor ) )
        rectBak.x = x + barWidth * 0.5
        rectBak.y = y
        muiData.widgetDict[options.basename]["toolbar"]["rectBak"] = rectBak
        --button["group"]:insert( rectBak, true ) -- insert and center bkgd
    end

    options.state.value = options.state.value or "off"

    --muiData.widgetDict[options.name] = {}
    --muiData.widgetDict[options.name].basename = options.basename
    muiData.widgetDict[options.basename]["toolbar"][options.name] = {}
    muiData.widgetDict[options.basename]["toolbar"]["type"] = "ToolbarButton"

    local button = muiData.widgetDict[options.basename]["toolbar"][options.name]
    button["group"] = display.newGroup()
    button["group"].x = x
    button["group"].y = y
    button["touching"] = false

    if options.parent ~= nil and false then
        button["parent"] = options.parent
        button["parent"]:insert( button["group"] )
    end

    if options.background ~= nil and options.index ~= nil and options.index == 1 then
        muiData.widgetDict[options.basename]["background"] = display.newImageRect(button["group"], options.background, barWidth, options.buttonHeight)
    end

    -- label colors
    if options.labelColorOff == nil then
        options.labelColorOff = { 0, 0, 0 }
    end
    if options.labelColor == nil then
        options.labelColor = { 1, 1, 1 }
    end

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local fontSize = options.height
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end
    fontSize = mathFloor(tonumber(fontSize))

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local iconColor = { 0, 0.82, 1 }
    if options.iconColor ~= nil then
        iconColor = options.iconColor
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
        M.debug("font is "..font)
        if M.isMaterialFont(font) == true then
            options.isFontIcon = true
            M.debug("isMaterialFont!")
        end
    end

    button["font"] = font
    button["fontSize"] = fontSize
    button["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given field's height
    local textPercent = .6
    if useBothIconAndText == false then textPercent = .7 end
    local field = {contentHeight=options.buttonHeight * textPercent, contentWidth=options.buttonHeight * textPercent}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    local fontSize = fontSize * ( ( field.contentHeight ) / textToMeasure.contentHeight )
    local textWidth = textToMeasure.contentWidth
    textToMeasure:removeSelf()
    textToMeasure = nil

    local numberOfButtons = 1
    if options.numberOfButtons ~= nil then
        numberOfButtons = options.numberOfButtons
    end

    local buttonWidth = barWidth / numberOfButtons
    local rectangle = display.newRect( (buttonWidth / 2), 0, buttonWidth + 1, options.buttonHeight )
    -- rectangle:setFillColor( unpack(options.backgroundColor) )
    rectangle:setFillColor( unpack({1,1,1,.01}) )
    button["rectangle"] = rectangle
    button["rectangle"].value = options.value

    if muiData.widgetDict[options.basename]["background"] ~= nil then
        muiData.widgetDict[options.basename]["background"].x = button["rectangle"].x + rectangle.contentWidth
        muiData.widgetDict[options.basename]["background"].y = button["rectangle"].y        
    end
    button["buttonWidth"] = rectangle.contentWidth
    button["buttonHeight"] = rectangle.contentHeight
    button["buttonOffset"] = rectangle.contentWidth / 2
    button["group"]:insert( rectangle, true ) -- insert and center bkgd

    if options.index ~= nil and options.index == 1 and x < button["buttonWidth"] then
        button["group"].x = (rectangle.contentWidth / 2) + muiData.safeAreaInsets.leftInset
    elseif options.index ~= nil and options.index > 1 then
        button["buttonOffset"] = 0
    end

    local textY = 0
    local textSize = fontSize
    if useBothIconAndText == true and false then
        textY = -rectangle.contentHeight * 0.18
        textSize = fontSize * 0.9
    end

    if options.isFontIcon == true then
        tw = textSize
        if M.isMaterialFont(font) == true then
            options.text = M.getMaterialFontCodePointByName(options.text)
        end
    elseif string.len(options.text) < 2 then
        tw = textSize
    end

    textSize = mathFloor(textSize)
    local options2 =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = textY,
        font = font,
        width = textSize,
        fontSize = textSize,
        align = "center"
    }

    -- create image buttons if exist, TO-DO
    M.createButtonsFromList({ name = options.basename..options.name, image=options.state.image }, button["rectangle"], button["group"])

    if options.state.off.svg ~= nil and type(options.state.off.svg) == "table" and options.state.image == nil then
       local params = {
            {
                name = "text",
                svgName = options.basename..options.name.."SvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "textOn",
                svgName = options.basename..options.name.."SvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "textDisabled",
                svgName = options.basename..options.name.."SvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(params) do
            if options.state[v.state] ~= nil and options.state[v.state].svg ~= nil then
                button[v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.state[v.state].svg.path,
                        width = fontSize,
                        height = fontSize,
                        fillColor = options.state[v.state].textColor,
                        strokeWidth = options.state[v.state].strokeWidth or 1,
                        strokeColor = options.state[v.state].strokeColor or options.state[v.state].textColor,
                        y = textY,
                    })
                button[v.name].isVisible = v.isVisible
                button["group"]:insert( button[v.name], false )
            end
        end
    elseif options.state.image == nil then
        button["text"] = display.newText( options2 )
        button["text"].isImage = false
    elseif options.state.image ~= nil then
        button["text"] = nil
    end

    if muiData.widgetDict[options.basename..options.name] ~= nil and muiData.widgetDict[options.basename..options.name]["image"] ~= nil then
        button["text"] = muiData.widgetDict[options.basename..options.name]["image"]
    end

    if isChecked then
        button["text"].isChecked = isChecked
    else
        button["text"].isChecked = false
    end
    button["group"]:insert( button["text"], false )

    local maxWidth = field.contentWidth * 2.5 -- (radius * 2.5)

    if useBothIconAndText == true and false then
        local options3 =
        {
            --parent = textGroup,
            text = options.labelText,
            x = 0,
            y = rectangle.contentHeight * 0.25,
            font = options.labelFont,
            fontSize = fontSize * 0.45,
            align = "center"
        }
        button["text2"] = display.newText( options3 )
        button["text2"]:setFillColor( unpack(options.state.off.labelColor) )
        button["text2"].isVisible = true
        if isChecked then
            button["text2"]:setFillColor( unpack(options.state.on.labelColor) )
            button["text2"].isChecked = isChecked
        else
            button["text2"]:setFillColor( unpack(options.state.off.labelColor) )
            button["text2"].isChecked = false
        end
        button["group"]:insert( button["text2"], false )
    end

    -- add the animated circle

    local circleColor = iconColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    button["circle"] = display.newCircle( options.height, options.height, maxWidth + 5 )
    button["circle"]:setFillColor( unpack(circleColor) )
    button["circle"].isVisible = false
    button["circle"].x = 0
    button["circle"].y = 0
    button["circle"].alpha = 0.3
    button["group"]:insert( button["circle"], true ) -- insert and center bkgd

    thebutton = button["rectangle"]
    field = button["text"]
    thebutton.name = options.name
    field.name = options.name

    thebutton.muiOptions = options
    thebutton.muiButton = button
    muiData.widgetDict[options.basename]["toolbar"][options.name]["rectangle"]:addEventListener( "touch", M.toolBarButton )

    if options.state.value == "off" then
        M.turnOffToolbarButton( options )
    elseif options.state.value == "on" then
        M.turnOnToolbarButton( options )
    elseif options.state.value == "disabled" then
        M.disableToolbarButton( options )
    end

end

function M.getToolBarButtonProperty(widgetParentName, propertyName, index)
    local data = nil

    if widgetParentName == nil or propertyName == nil then return data end

    if index < 1 then index = 1 end
    local widgetName = widgetParentName .. "_" .. index

    if muiData.widgetDict[widgetParentName]["toolbar"][widgetName] == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["group"] -- x,y movement
    elseif propertyName == "buttonHeight" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["buttonHeight"]
    elseif propertyName == "buttonWidth" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["buttonWidth"]
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["rectangle"] -- button background
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["text"] -- icon/text
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["text2"] -- text for icon
    end
    return data
end

function M.toolBarButton (event)
    local options = nil
    local button = nil
    if event.target ~= nil then
        options = event.target.muiOptions
        button = event.target.muiButton
    end

    if muiData.widgetDict[options.basename]["toolbar"][options.name]["text"].isChecked == true then
        return
    end

    if muiData.dialogInUse == true and options.dialogName == nil then
        return
    end

    if muiData.currentControl == nil then
        muiData.currentControl = options.basename
        muiData.currentControlSubName = options.name
        muiData.currentControlType = "mui-toolbar"
    end

    if M.disableToolbarButton( options, event ) then
        if options.state.disabled.callBackData ~= nil and event.phase == "ended" then
            M.setEventParameter(event, "muiTargetCallBackData", options.state.disabled.callBackData)
            assert( options.state.disabled.callBack )(event)
        end
        return
    end

    if muiData.currentControl ~= nil and muiData.currentControl ~= options.name then
        if event.phase == "ended" then
            M.turnOffControlHandler()
        end
        -- return , this is not needed for toolbar button
    end

    M.addBaseEventParameters(event, options)

    if muiData.dialogInUse == true and options.dialogName == nil then return end
    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.toolBarButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end

        M.turnOnToolbarButton( options )

        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.basename]["toolbar"][options.name]["circle"].x = 0 --muiData.widgetDict[options.basename]["toolbar"][options.name]["group"].x
                muiData.widgetDict[options.basename]["toolbar"][options.name]["circle"].y = 0 --muiData.widgetDict[options.basename]["toolbar"][options.name]["group"].y
                muiData.widgetDict[options.basename]["toolbar"][options.name]["circle"].isVisible = true
                local scaleFactor = 0.1
                muiData.widgetDict[options.basename]["toolbar"][options.name].circleTrans = transition.from( muiData.widgetDict[options.basename]["toolbar"][options.name]["circle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            end
            -- transition.to(event.target,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
        else
            event.phase = "onTarget"
            if muiData.interceptMoved == false then
                --event.target = muiData.widgetDict[options.name]["rrect"]
                transition.to(muiData.widgetDict[options.basename]["toolbar"]["slider"],{time=350, x=button["group"].x, transition=easing.inOutCubic})

                event.myTargetName = options.name
                event.myTargetBasename = options.basename
                event.altTarget = muiData.widgetDict[options.basename]["toolbar"][options.name]["text"]
                event.altTarget2 = muiData.widgetDict[options.basename]["toolbar"][options.name]["text2"]
                event.callBackData = options.callBackData

                muiData.widgetDict[options.basename]["value"] = options.value
                --M.setEventParameter(event, "muiLabelColor", options.state.on.textColor)
                --M.setEventParameter(event, "muiIconColor", options.state.on.fillColor)
                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.basename]["toolbar"][options.name]["text"])
                M.setEventParameter(event, "muiTarget2", muiData.widgetDict[options.basename]["toolbar"][options.name]["text2"])
                M.actionForToolbar(options, event)
                if event.target.isChecked ~= nil and event.target.isChecked == false then
                    M.turnOffToolbarButton( options )
                else
                    M.turnOnToolbarButton( options )
                end
            end
            muiData.interceptEventHandler = nil
            muiData.interceptOptions = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
        if event.target.isChecked ~= nil and event.target.isChecked == false then
            M.turnOffToolbarButton( options )
        end
        M.processEventQueue()
    else
        M.addToEventQueue( options )
    end
    return true -- prevent propagation to other controls
end

function M.createToolbar( options )
    M.newToolbar( options )
end

function M.newToolbar( options )
    local x, y = options.x, options.y
    local buttonWidth = 1
    local buttonOffset = 0
    local activeX = 0

    if options.isChecked == nil then
        options.isChecked = false
    end

    if options.sliderColor == nil then
        options.sliderColor = { 1, 1, 1 }
    end

    x, y = M.getSafeXY(options, x, y)

    if options.list ~= nil then
        local count = #options.list
        muiData.widgetDict[options.name] = {}
        muiData.widgetDict[options.name]["toolbar"] = {}
        muiData.widgetDict[options.name]["type"] = "Toolbar"
        muiData.widgetDict[options.name]["layout"] = options.layout
        if muiData.widgetDict[options.name]["layout"] == "horizontal" then
            muiData.widgetDict[options.name]["y_position"] = y
        end
        for i, v in ipairs(options.list) do
            M.newToolbarButton({
                    parent = options.parent,
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
                    x = x,
                    y = y,
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
                    backgroundColor = options.color or options.fillColor,
                    background = options.background,
                    iconImage = v.iconImage,
                    state = v.state,
                    numberOfButtons = count,
                    callBack = options.callBack,
                    callBackData = options.callBackData
                })
            local button = muiData.widgetDict[options.name]["toolbar"][options.name.."_"..i]
            buttonWidth = button["buttonWidth"]
            if i == 1 then buttonOffset = button["buttonOffset"] end
            if options.layout ~= nil and options.layout == "horizontal" then
                x = x + button["buttonWidth"] + button["buttonOffset"]
            else
                y = y + button["buttonHeight"]
            end
            if v.isChecked == true or v.isActive == true then
                activeX = button["group"].x
            end
        end

        -- slider highlight
        local sliderHeight = options.buttonHeight * 0.05
        muiData.widgetDict[options.name]["toolbar"]["slider"] = display.newRect( buttonOffset, muiData.safeAreaHeight - (sliderHeight * 0.5), buttonWidth, sliderHeight )
        muiData.widgetDict[options.name]["toolbar"]["slider"]:setFillColor( unpack( options.sliderColor ) )
        transition.to(muiData.widgetDict[options.name]["toolbar"]["slider"],{time=0, x=activeX, transition=easing.inOutCubic})
    end
end

function M.getToolBarProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["group"] -- x,y movement
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- toolbar value
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["toolbar"]["rectBak"] -- toolbar background
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["toolbar"]["slider"] -- bar slider
    end
    return data
end

function M.getOptionsForToolbarButton( name, basename )
    if name == nil then return end
    local options = nil

    if muiData.widgetDict[basename] ~= nil and muiData.widgetDict[basename]["toolbar"] ~= nil then
        options = muiData.widgetDict[basename]["toolbar"][name]["rectangle"].muiOptions
    end

    return options
end

function M.actionForToolbar( options, e )
    local target = M.getEventParameter(e, "muiTarget")
    local target2 = M.getEventParameter(e, "muiTarget2")
    if target ~= nil then
        -- uncheck all then check the one that is checked
        local basename = M.getEventParameter(e, "basename")
        local foundName = false
        local list = muiData.widgetDict[basename]["toolbar"]

        if target.isChecked == true then
            -- return
        end

        for k, v in pairs(list) do
            if v["text"] ~= nil then
                local subOpts = v["rectangle"].muiOptions
                if v["text"].isImage == false and options.state.svg == nil and  subOpts.state.value ~= "disabled" then
                    v["text"]:setFillColor( unpack(options.state.off.textColor) )
                elseif subOpts.state.off.svg ~= nil and subOpts.state.value ~= "disabled" then
                    M.turnOffToolbarButton( subOpts )
                end
                if v["text2"] ~= nil and v["rectangle"].muiOptions ~= nil and v["rectangle"].muiOptions.state.value ~= "disabled" then
                    v["text2"]:setFillColor( unpack(options.state.off.labelColor) )
                end
                if muiData.widgetDict[subOpts.basename..subOpts.name] ~= nil and muiData.widgetDict[subOpts.basename..subOpts.name]["image"] ~= nil then
                    M.turnOffToolbarButton( subOpts )
                end
                v["text"].isChecked = false
            end
        end

        local muiIconColor = options.state.on.textColor
        local muiLabelColor = options.state.on.labelColor

        if target.isImage == false and options.state.svg == nil then
            target:setFillColor( unpack( muiIconColor ) )
        end
        if target2 ~= nil then
            target2:setFillColor( unpack( muiLabelColor ) )
        end

        target.isChecked = true
        assert( options.callBack )(e)
    end
end

function M.actionForToolbarDemo( event )
    -- note:
    -- event.<original attribute> remain untouched.
    -- event.muiDict will be the only added variable (less conflicting)
    --
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")

    if muiTarget ~= nil and muiTarget.text ~= nil then
        M.debug("Toolbar button text: " .. muiTarget.text)
    end
    if muiTargetValue ~= nil then
        M.debug("Toolbar button value: " .. muiTargetValue)
    end
end

function M.disableToolbarButton( options, event )
    M.debug("M.disableToolbarButton()")
    local val = false
    if options == nil then return val end
    if options.state.value ~= "disabled" then return val end

    val = true

    if muiData.widgetDict[options.basename] ~= nil and muiData.widgetDict[options.basename]["type"] == "Toolbar" then
        -- change color
        if options.state.image == nil and options.state.disabled.textColor ~= nil then
            if options.state.svg == nil then
                M.setGroupObjectFillColor(options.basename, "toolbar", options.name, "text", options.state.disabled.textColor)
            end
            M.setGroupObjectFillColor(options.basename, "toolbar", options.name, "text2", options.state.disabled.labelColor)
        end

        -- change icon
        if options.state.disabled.svg ~= nil and muiData.widgetDict[options.basename]["toolbar"][options.name].textDisabled ~= nil then
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "text", false)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "textOn", false)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "textDisabled", true)
        end

        -- change icon
        if muiData.widgetDict[options.basename]["toolbar"][options.name].iconTextDisabled ~= nil then
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "iconText", false)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "iconTextOn", false)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "iconTextDisabled", true)
        end

        -- change image
        if muiData.widgetDict[options.basename..options.name] ~= nil and muiData.widgetDict[options.basename..options.name]["imageDisabled"] ~= nil then
            M.setObjectVisible(options.basename..options.name, "image", false)
            M.setObjectVisible(options.basename..options.name, "imageTouch", false)
            M.setObjectVisible(options.basename..options.name, "imageDisabled", true)
        end
        muiData.widgetDict[options.basename].disabled = true
        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    end

    if muiData.currentControl == options.name then
        M.resetCurrentControlVars()
    end

    return val
end

-- params...
-- name: name of button
-- basename: only required if RadioButton or grouped element
function M.turnOnToolbarButtonByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForToolbarButton(name, basename)

    if options ~= nil then
        M.turnOnToolbarButton( options )
    end
end

function M.turnOnToolbarButton( options, event )
    -- body
    M.debug("M.turnOnToolbarButton()")

    options.state.value = "on"
    if event ~= nil then
        if options.state.on.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.state.on.callBackData)
            assert( options.state.on.callBack )(event)
        end
    end

    if muiData.widgetDict[options.basename] ~= nil and muiData.widgetDict[options.basename]["type"] == "Toolbar" then
        -- change color
        if options.state.image == nil and options.state.on.textColor ~= nil then

            if options.state.svg == nil then
                M.setGroupObjectFillColor(options.basename, "toolbar", options.name, "text", options.state.on.textColor)
            end
            M.setGroupObjectFillColor(options.basename, "toolbar", options.name, "text2", options.state.on.labelColor)
        end

        -- change icon
        if options.state.on.svg ~= nil and muiData.widgetDict[options.basename]["toolbar"][options.name].textOn ~= nil then
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "text", false)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "textOn", true)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "textDisabled", false)
        end

        -- change image
        if muiData.widgetDict[options.basename..options.name] ~= nil and muiData.widgetDict[options.basename..options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.basename..options.name, "image", false)
            M.setObjectVisible(options.basename..options.name, "imageDisabled", false)
            M.setObjectVisible(options.basename..options.name, "imageTouch", true)
        end
    end
end

-- params...
-- name: name of button
-- basename: only required if RadioButton
function M.turnOffToolbarButtonByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForToolbarButton(name, basename)

    if options ~= nil then
        M.turnOffToolbarButton( options )
    end
end

function M.turnOffToolbarButton( options, event )
    -- body
    M.debug("M.turnOffToolbarButton()")

    options.state.value = "off"
    if event ~= nil then
        if options.state.off.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.state.off.callBackData)
            assert( options.state.off.callBack )(event)
        end
    end

    if muiData.widgetDict[options.basename] ~= nil and muiData.widgetDict[options.basename]["type"] == "Toolbar" then
        -- change color
        if options.state.image == nil and options.state.off.textColor ~= nil then
            if options.state.svg == nil then
                M.setGroupObjectFillColor(options.basename, "toolbar", options.name, "text", options.state.off.textColor)
            end
            M.setGroupObjectFillColor(options.basename, "toolbar", options.name, "text2", options.state.off.labelColor)
        end

        -- change icon
        if options.state.off.svg ~= nil and muiData.widgetDict[options.basename]["toolbar"][options.name].text ~= nil then
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "text", true)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "textOn", false)
            M.setGroupObjectVisible(options.basename, "toolbar", options.name, "textDisabled", false)
        end

        -- change image
        if muiData.widgetDict[options.basename..options.name] ~= nil and muiData.widgetDict[options.basename..options.name]["image"] ~= nil then
            M.setObjectVisible(options.basename..options.name, "image", true)
            M.setObjectVisible(options.basename..options.name, "imageDisabled", false)
            M.setObjectVisible(options.basename..options.name, "imageTouch", false)
        end

        if muiData.currentControl == options.basename then
            M.resetCurrentControlVars()
        end
    end
end


function M.removeWidgetToolbar(widgetName)
    M.removeToolbar(widgetName)
end

function M.removeToolbar(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    for name in pairs(muiData.widgetDict[widgetName]["toolbar"]) do
        M.removeToolbarButton(muiData.widgetDict, widgetName, name)
        if name ~= "slider" and name ~= "rectBak" then
            muiData.widgetDict[widgetName]["toolbar"][name] = nil
        end
    end
    if muiData.widgetDict[widgetName]["toolbar"]["slider"] ~= nil then
        muiData.widgetDict[widgetName]["toolbar"]["slider"]:removeSelf()
        muiData.widgetDict[widgetName]["toolbar"]["slider"] = nil
    end
    if muiData.widgetDict[widgetName]["toolbar"]["background"] ~= nil then
        muiData.widgetDict[widgetName]["toolbar"]["background"]:removeSelf()
        muiData.widgetDict[widgetName]["toolbar"]["background"] = nil
    end
    if muiData.widgetDict[widgetName]["toolbar"]["rectBak"] ~= nil then
        muiData.widgetDict[widgetName]["toolbar"]["rectBak"]:removeSelf()
        muiData.widgetDict[widgetName]["toolbar"]["rectBak"] = nil
    end
    M.resetCurrentControlVars()
end

function M.removeWidgetToolbarButton(widgetDict, toolbarName, name)
    M.removeToolbarButton(widgetDict, toolbarName, name)
end

function M.removeToolbarButton(widgetDict, toolbarName, name)
    if toolbarName == nil then
        return
    end
    if name == nil then
        return
    end
    if widgetDict[toolbarName]["toolbar"][name] == nil then
        return
    end
    if type(widgetDict[toolbarName]["toolbar"][name]) == "table" then
        if widgetDict[toolbarName]["toolbar"][name]["rectangle"] ~= nil then
            widgetDict[toolbarName]["toolbar"][name]["rectangle"]:removeEventListener( "touch", M.toolBarButton )
            widgetDict[toolbarName]["toolbar"][name]["rectangle"]:removeSelf()
            widgetDict[toolbarName]["toolbar"][name]["rectangle"] = nil
            widgetDict[toolbarName]["toolbar"][name]["text"]:removeSelf()
            widgetDict[toolbarName]["toolbar"][name]["text"] = nil
            if widgetDict[toolbarName]["toolbar"][name]["text2"] ~= nil then
                widgetDict[toolbarName]["toolbar"][name]["text2"]:removeSelf()
                widgetDict[toolbarName]["toolbar"][name]["text2"] = nil
            end

            if widgetDict[toolbarName]["toolbar"][toolbarName..name.."SvgOff"] ~= nil then
                M.removeImageSvgStyle(toolbarName..name.."SvgOff")
            end
            if widgetDict[toolbarName]["toolbar"][toolbarName..name.."SvgOn"] ~= nil then
                M.removeImageSvgStyle(toolbarName..name.."SvgOn")
            end
            if widgetDict[toolbarName]["toolbar"][toolbarName..name.."SvgDisabled"] ~= nil then
                M.removeImageSvgStyle(toolbarName..name.."SvgDisabled")
            end

            if widgetDict[toolbarName]["toolbar"][toolbarName..name.."image"] ~= nil then
                widgetDict[toolbarName]["toolbar"][toolbarName..name.."image"]:removeSelf()
                widgetDict[toolbarName]["toolbar"][toolbarName..name.."image"] = nil
            end

            if widgetDict[toolbarName]["toolbar"][toolbarName..name.."imageTouch"] ~= nil then
                widgetDict[toolbarName]["toolbar"][toolbarName..name.."imageTouch"]:removeSelf()
                widgetDict[toolbarName]["toolbar"][toolbarName..name.."imageTouch"] = nil
            end

            if widgetDict[toolbarName]["toolbar"][toolbarName..name.."imageDisabled"] ~= nil then
                widgetDict[toolbarName]["toolbar"][toolbarName..name.."imageDisabled"]:removeSelf()
                widgetDict[toolbarName]["toolbar"][toolbarName..name.."imageDisabled"] = nil
            end

            widgetDict[toolbarName]["toolbar"][name]["circle"]:removeSelf()
            widgetDict[toolbarName]["toolbar"][name]["circle"] = nil
            widgetDict[toolbarName]["toolbar"][name]["group"]:removeSelf()
            widgetDict[toolbarName]["toolbar"][name]["group"] = nil
            widgetDict[toolbarName]["toolbar"][name] = nil
        end
    end
    M.resetCurrentControlVars()
end

return M
