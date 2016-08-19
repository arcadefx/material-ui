--[[
    A loosely based Material UI module

    mui-toolbar.lua : This is for creating horizontal toolbars.

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

    local barWidth = muiData.contentWidth
    if options.width ~= nil then
        barWidth = options.width
    end

    if options.index ~= nil and options.index == 1 then
        local rectBak = display.newRect( 0, 0, barWidth, options.buttonHeight )
        rectBak:setFillColor( unpack( options.backgroundColor ) )
        rectBak.x = options.x + barWidth * 0.5
        rectBak.y = y
        muiData.widgetDict[options.basename]["toolbar"]["rectBak"] = rectBak
        --button["mygroup"]:insert( rectBak, true ) -- insert and center bkgd
    end

    --muiData.widgetDict[options.name] = {}
    --muiData.widgetDict[options.name].basename = options.basename
    muiData.widgetDict[options.basename]["toolbar"][options.name] = {}
    muiData.widgetDict[options.basename]["toolbar"]["type"] = "ToolbarButton"

    local button =  muiData.widgetDict[options.basename]["toolbar"][options.name]
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
    muiData.widgetDict[options.basename]["toolbar"]["labelColorOff"] = options.labelColorOff
    muiData.widgetDict[options.basename]["toolbar"]["labelColor"] = options.labelColor

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

    local textColor = { 0, 0.82, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
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
    local field = {contentHeight=options.buttonHeight * 0.60, contentWidth=options.buttonHeight * 0.60}
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
    local rectangle = display.newRect( buttonWidth / 2, 0, buttonWidth, options.buttonHeight )
    rectangle:setFillColor( unpack(options.backgroundColor) )
    button["rectangle"] = rectangle
    button["rectangle"].value = options.value
    button["buttonWidth"] = rectangle.contentWidth
    button["buttonHeight"] = rectangle.contentHeight
    button["buttonOffset"] = rectangle.contentWidth / 2
    button["mygroup"]:insert( rectangle, true ) -- insert and center bkgd

    if options.index ~= nil and options.index == 1 and x < button["buttonWidth"] then
        button["mygroup"].x = rectangle.contentWidth / 2
    elseif options.index ~= nil and options.index > 1 then
        button["buttonOffset"] = 0
    end

    local textY = 0
    local textSize = fontSize
    if useBothIconAndText == true then
        textY = -rectangle.contentHeight * 0.18
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
        align = "center"
    }

    button["myText"] = display.newText( options2 )
    button["myText"]:setFillColor( unpack(textColor) )
    button["myText"].isVisible = true
    if isChecked then
        button["myText"]:setFillColor( unpack(options.labelColor) )
        button["myText"].isChecked = isChecked
    else
        button["myText"]:setFillColor( unpack(options.labelColorOff) )
        button["myText"].isChecked = false
    end
    button["mygroup"]:insert( button["myText"], false )

    local maxWidth = field.contentWidth * 2.5 -- (radius * 2.5)

    if useBothIconAndText == true then
        local options3 =
        {
            --parent = textGroup,
            text = options.labelText,
            x = 0,
            y = rectangle.contentHeight * 0.2,
            font = options.labelFont,
            fontSize = fontSize * 0.45,
            align = "center"
        }
        button["myText2"] = display.newText( options3 )
        button["myText2"]:setFillColor( unpack(textColor) )
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

    -- add the animated circle

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    button["myCircle"] = display.newCircle( options.height, options.height, maxWidth + M.getScaleVal(5) )
    button["myCircle"]:setFillColor( unpack(circleColor) )
    button["myCircle"].isVisible = false
    button["myCircle"].x = 0
    button["myCircle"].y = 0
    button["myCircle"].alpha = 0.3
    button["mygroup"]:insert( button["myCircle"], true ) -- insert and center bkgd

    thebutton = button["rectangle"]
    field = button["myText"]
    thebutton.name = options.name
    field.name = options.name

    thebutton.muiOptions = options
    thebutton.muiButton = button
    muiData.widgetDict[options.basename]["toolbar"][options.name]["rectangle"]:addEventListener( "touch", M.toolBarButton )
end

function M.getToolBarButtonProperty(widgetParentName, propertyName, index)
    local data = nil

    if widgetParentName == nil or propertyName == nil then return data end

    if index < 1 then index = 1 end
    local widgetName = widgetParentName .. "_" .. index

    if muiData.widgetDict[widgetParentName]["toolbar"][widgetName] == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["rectangle"] -- button background
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["myText"] -- icon/text
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetParentName]["toolbar"][widgetName]["myText2"] -- text for icon
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

    if muiData.widgetDict[options.basename]["toolbar"][options.name]["myText"].isChecked == true then
        return
    end

    M.addBaseEventParameters(event, options)

    if muiData.dialogInUse == true and options.dialogName == nil then return end
    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.toolBarButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.basename]["toolbar"][options.name]["myCircle"].x = 0 --muiData.widgetDict[options.basename]["toolbar"][options.name]["mygroup"].x
                muiData.widgetDict[options.basename]["toolbar"][options.name]["myCircle"].y = 0 --muiData.widgetDict[options.basename]["toolbar"][options.name]["mygroup"].y
                muiData.widgetDict[options.basename]["toolbar"][options.name]["myCircle"].isVisible = true
                local scaleFactor = 0.1
                muiData.widgetDict[options.basename]["toolbar"][options.name].myCircleTrans = transition.from( muiData.widgetDict[options.basename]["toolbar"][options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            end
            -- transition.to(event.target,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- print("Its out of the button area")
        else
            event.phase = "onTarget"
            if muiData.interceptMoved == false then
                --event.target = muiData.widgetDict[options.name]["rrect"]
                transition.to(muiData.widgetDict[options.basename]["toolbar"]["slider"],{time=350, x=button["mygroup"].x, transition=easing.inOutCubic})

                event.myTargetName = options.name
                event.myTargetBasename = options.basename
                event.altTarget = muiData.widgetDict[options.basename]["toolbar"][options.name]["myText"]
                event.altTarget2 = muiData.widgetDict[options.basename]["toolbar"][options.name]["myText2"]
                event.callBackData = options.callBackData

                muiData.widgetDict[options.basename]["value"] = options.value
                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.basename]["toolbar"][options.name]["myText"])
                M.setEventParameter(event, "muiTarget2", muiData.widgetDict[options.basename]["toolbar"][options.name]["myText2"])
                M.actionForToolbar(options, event)
            end
            muiData.interceptEventHandler = nil
            muiData.interceptOptions = nil
            muiData.interceptMoved = false
            muiData.touching = false
        end
    end
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

    if options.list ~= nil then
        local count = #options.list
        muiData.widgetDict[options.name] = {}
        muiData.widgetDict[options.name]["toolbar"] = {}
        muiData.widgetDict[options.name]["type"] = "Toolbar"
        for i, v in ipairs(options.list) do            
            M.newToolbarButton({
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
                font = "MaterialIcons-Regular.ttf",
                labelText = v.labelText,
                labelFont = options.labelFont,
                labelFontSize = options.labelFontSize,
                textColor = options.labelColor,
                textColorOff = options.labelColorOff,
                textAlign = "center",
                labelColor = options.labelColor,
                backgroundColor = options.color or options.fillColor,
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
                activeX = button["mygroup"].x
            end
        end

        -- slider highlight
        local sliderHeight = options.buttonHeight * 0.05
        muiData.widgetDict[options.name]["toolbar"]["slider"] = display.newRect( buttonOffset, muiData.contentHeight - (sliderHeight * 0.5), buttonWidth, sliderHeight )
        muiData.widgetDict[options.name]["toolbar"]["slider"]:setFillColor( unpack( options.sliderColor ) )
        transition.to(muiData.widgetDict[options.name]["toolbar"]["slider"],{time=0, x=activeX, transition=easing.inOutCubic})
    end
end

function M.getToolBarProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- toolbar value
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["toolbar"]["rectBak"] -- toolbar background
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["toolbar"]["slider"] -- bar slider 
    end
    return data
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
            return
        end
        for k, v in pairs(list) do
            if v["myText"] ~= nil then
                v["myText"]:setFillColor( unpack(muiData.widgetDict[basename]["toolbar"]["labelColorOff"]) )
                if v["myText2"] ~= nil then
                    v["myText2"]:setFillColor( unpack(muiData.widgetDict[basename]["toolbar"]["labelColorOff"]) )
                end
                v["myText"].isChecked = false
            end
        end

        target:setFillColor( unpack(muiData.widgetDict[basename]["toolbar"]["labelColor"]) )
        if target2 ~= nil then
            target2:setFillColor( unpack(muiData.widgetDict[basename]["toolbar"]["labelColor"]) )
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

    if muiTarget ~= nil then
        print("Toolbar button text: " .. muiTarget.text)
    end
    if muiTargetValue ~= nil then
        print("Toolbar button value: " .. muiTargetValue)
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
    if muiData.widgetDict[widgetName]["toolbar"]["rectBak"] ~= nil then
        muiData.widgetDict[widgetName]["toolbar"]["rectBak"]:removeSelf()
        muiData.widgetDict[widgetName]["toolbar"]["rectBak"] = nil
    end
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
            widgetDict[toolbarName]["toolbar"][name]["myText"]:removeSelf()
            widgetDict[toolbarName]["toolbar"][name]["myText"] = nil
            if widgetDict[toolbarName]["toolbar"][name]["myText2"] ~= nil then
                widgetDict[toolbarName]["toolbar"][name]["myText2"]:removeSelf()
                widgetDict[toolbarName]["toolbar"][name]["myText2"] = nil
            end
            widgetDict[toolbarName]["toolbar"][name]["myCircle"]:removeSelf()
            widgetDict[toolbarName]["toolbar"][name]["myCircle"] = nil
            widgetDict[toolbarName]["toolbar"][name]["mygroup"]:removeSelf()
            widgetDict[toolbarName]["toolbar"][name]["mygroup"] = nil
            widgetDict[toolbarName]["toolbar"][name] = nil
        end
    end
end

return M
