--[[
    A loosely based Material UI module

    mui-textinput.lua : This is for creating text input widgets.

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
-- To-do: flow right or below based on parent text widget
--
function M.createTextField(options)
    M.newTextField(options)
end

function M.newTextField(options)

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

    if options.isSecure == nil then
        options.isSecure = false
    end

    if options.inputType == nil then
        options.inputType = "default"
    end

    if options.fillColor == nil then
        options.fillColor = { 1, 1, 1, 0.1}
    end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "TextField"
    muiData.widgetDict[options.name]["container"] = display.newContainer( options.width+4, options.height * 4)
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

    muiData.widgetDict[options.name]["options"] = options

    muiData.widgetDict[options.name]["rect"] = display.newRect( 0, 0, options.width, options.height )
    muiData.widgetDict[options.name]["rect"].strokeWidth = 0
    muiData.widgetDict[options.name]["rect"]:setFillColor( unpack(options.fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rect"] )

    local rect = muiData.widgetDict[options.name]["rect"]
    muiData.widgetDict[options.name]["line"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
    muiData.widgetDict[options.name]["line"].strokeWidth = M.getScaleVal(4)
    muiData.widgetDict[options.name]["line"]:setStrokeColor( unpack(options.inactiveColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["line"] )

    muiData.widgetDict[options.name]["lineanim"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
    muiData.widgetDict[options.name]["lineanim"].strokeWidth = M.getScaleVal(4)
    muiData.widgetDict[options.name]["lineanim"]:setStrokeColor( unpack(options.inactiveColor) )
    muiData.widgetDict[options.name]["lineanim"].isVisible = false
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["lineanim"] )

    local labelOptions =
    {
        --parent = textGroup,
        text = options.labelText,
        x = -(rect.contentWidth * 0.25),
        y = -(rect.contentHeight * 0.95),
        width = rect.contentWidth * 0.5,     --required for multi-line and alignment
        font = options.font,
        fontSize = options.height * 0.55,
        align = "left"  --new alignment parameter
    }
    if options.labelText ~= nil then
        muiData.widgetDict[options.name]["textlabel"] = display.newText( labelOptions )
        muiData.widgetDict[options.name]["textlabel"]:setFillColor( unpack(options.inactiveColor) )
        muiData.widgetDict[options.name]["textlabel"].inactiveColor = options.inactiveColor
        muiData.widgetDict[options.name]["textlabel"].activeColor = options.activeColor
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["textlabel"] )
    end

    local scaleFontSize = 1
    if muiData.environment == "simulator" then
        scaleFontSize = 0.75
    end
    muiData.widgetDict[options.name]["isSecure"] = options.isSecure
    muiData.widgetDict[options.name]["textfield"] = native.newTextField( 0, 0, options.width, options.height * scaleFontSize )
    muiData.widgetDict[options.name]["textfield"].name = options.name
    if options.placeholder ~= nil then
       muiData.widgetDict[options.name]["textfield"].placeholder = options.placeholder 
    end
    muiData.widgetDict[options.name]["textfield"].hasBackground = false
    muiData.widgetDict[options.name]["textfield"].isVisible = false
    muiData.widgetDict[options.name]["textfield"].inputType = options.inputType
    muiData.widgetDict[options.name]["textfield"].isSecure = false
    muiData.widgetDict[options.name]["textfield"].text = options.text
    muiData.widgetDict[options.name]["textfield"]:setTextColor( unpack(options.inactiveColor) )

    local fadeText = options.text
    if options.placeholder ~= nil and options.text ~= nil and string.len(options.text) < 1 then
       fadeText = options.placeholder
    end

    if muiData.widgetDict[options.name]["isSecure"] == true then
        local length = string.len(fadeText)
        text = ""
        for i=1, length do
            text = text .. "*"
        end
        fadeText = text
    end

    local textOptions =
    {
        --parent = textGroup,
        text = fadeText,
        x = 0,
        y = 0,
        width = options.width,
        font = options.font,
        fontSize = options.height * 0.55,
        align = "left"  --new alignment parameter
    }
    muiData.widgetDict[options.name]["textfieldfake"] = display.newText( textOptions )
    muiData.widgetDict[options.name]["textfieldfake"]:setFillColor( unpack(options.inactiveColor) )
    muiData.widgetDict[options.name]["textfieldfake"]:addEventListener("touch", M.showNativeInput)
    muiData.widgetDict[options.name]["textfieldfake"].name = options.name
    muiData.widgetDict[options.name]["textfieldfake"].dialogName = options.dialogName
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["textfieldfake"] )

    -- muiData.widgetDict[options.name]["textfield"].placeholder = "Subject"
    muiData.widgetDict[options.name]["textfield"].callBack = options.callBack
    muiData.widgetDict[options.name]["textfield"]:addEventListener( "userInput", M.textListener )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["textfield"] )
end

function M.getTextFieldProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "label" then
        data = muiData.widgetDict[widgetName]["textlabel"] -- label
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rect"] -- clickable area
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["textfield"] -- native text field
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["textfield"].text -- native text field value
    elseif propertyName == "layer_3" then
        data = muiData.widgetDict[widgetName]["textfieldfake"] -- fake text field
    elseif propertyName == "layer_4" then
        data = muiData.widgetDict[widgetName]["line"] -- line beneath control
    elseif propertyName == "layer_5" then
        data = muiData.widgetDict[widgetName]["lineanim"] -- line animated with fade
    end
    return data
end

function M.highlightTextField(widgetName, active)
    local name = widgetName
    if name == nil then
        return
    end

    if muiData.widgetDict[name]["textfield"] == nil then
        return
    end

    if active == nil then
        active = false
    end

    local widget = muiData.widgetDict[name]
    local color = nil
    local options = muiData.widgetDict[name]["options"]
    if active then
        color = options.activeColor
        if widget["textlabel"] ~= nil then
            widget["textlabel"]:setFillColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        end
        widget["textfield"]:setTextColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )

        widget["lineanim"]:setStrokeColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        transition.to(widget["lineanim"],{time=0, alpha=0.01})
        widget["lineanim"].isVisible = true
        transition.from(widget["lineanim"],{time=800, alpha=0.01})
    else
        muiData.widgetDict[options.name]["lineanim"].isVisible = false
        color = options.inactiveColor
        if widget["textlabel"] ~= nil then
            widget["textlabel"]:setFillColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        end
        widget["textfield"]:setTextColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        widget["line"]:setStrokeColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        if widget["textfieldfake"] ~= nil then
            widget["textfieldfake"]:setFillColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        end
    end

end

function M.textListener(event)
    local name = event.target.name

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        -- user begins editing defaultField
        M.updateUI(event, name)
        muiData.currentNativeFieldName = name
        M.highlightTextField(name, true)
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- do something with text
        -- print( event.target.text )
        muiData.widgetDict[name]["textfield"].isSecure = false
        M.highlightTextField(name, false)
        if event.target.callBack ~= nil then
            M.updateUI(event)
            if muiData.widgetDict[name]["textfieldfake"] ~= nil then
                local text = event.target.text
                if muiData.widgetDict[name]["isSecure"] == true then
                    local length = string.len(text)
                    text = ""
                    for i=1, length do
                        text = text .. "*"
                    end
                end
                if text ~= nil and string.len(text) > 0 then
                    muiData.widgetDict[name]["textfieldfake"].text = text
                else
                    muiData.widgetDict[name]["textfieldfake"].text = muiData.widgetDict[name]["textfield"].placeholder
                end
            end
            M.setEventParameter(event, "muiTarget", muiData.widgetDict[name]["textfieldfake"])
            M.setEventParameter(event, "muiTargetValue", event.target.text)
            M.setEventParameter(event, "muiTargetNewCharacters", event.newCharacters)
            M.setEventParameter(event, "muiTargetOldText", event.oldText)
            assert( event.target.callBack )(event)
        end

    elseif ( event.phase == "editing" ) then
        M.highlightTextField(name, true)
        -- print( event.newCharacters )
        -- print( event.oldText )
        -- print( event.startPosition )
        -- print( event.text )
    end
end

--
-- To-do: flow right or below based on parent text widget
--
function M.createTextBox(options)
    M.newTextBox(options)
end

function M.newTextBox(options)

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

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "TextBox"
    muiData.widgetDict[options.name]["container"] = display.newContainer( options.width+4, options.height * 4)
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

    if options.isEditable == nil then
        options.isEditable = false
    end

    muiData.widgetDict[options.name]["options"] = options

    muiData.widgetDict[options.name]["rect"] = display.newRect( 0, 0, options.width, options.height )
    muiData.widgetDict[options.name]["rect"].strokeWidth = 0
    muiData.widgetDict[options.name]["rect"]:setFillColor( 1, 1, 1 )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rect"] )

    local rect = muiData.widgetDict[options.name]["rect"]
    muiData.widgetDict[options.name]["line"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
    muiData.widgetDict[options.name]["line"].strokeWidth = M.getScaleVal(4)
    muiData.widgetDict[options.name]["line"]:setStrokeColor( unpack(options.inactiveColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["line"] )

    muiData.widgetDict[options.name]["lineanim"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
    muiData.widgetDict[options.name]["lineanim"].strokeWidth = M.getScaleVal(4)
    muiData.widgetDict[options.name]["lineanim"]:setStrokeColor( unpack(options.inactiveColor) )
    muiData.widgetDict[options.name]["lineanim"].isVisible = false
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["lineanim"] )

    local labelOptions =
    {
        --parent = textGroup,
        text = options.labelText,
        x = -(rect.contentWidth * 0.25),
        y = -(rect.contentHeight * 0.6),
        width = rect.contentWidth * 0.5,     --required for multi-line and alignment
        font = options.font,
        fontSize = options.fontSize * 0.55,
        align = "left"  --new alignment parameter
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
    muiData.widgetDict[options.name]["textfield"] = native.newTextBox( 0, 0, options.width, options.height )
    muiData.widgetDict[options.name]["textfield"].name = options.name
    muiData.widgetDict[options.name]["textfield"].hasBackground = false
    muiData.widgetDict[options.name]["textfield"].isEditable = options.isEditable
    muiData.widgetDict[options.name]["textfield"].isVisible = false
    muiData.widgetDict[options.name]["textfield"].text = options.text
    muiData.widgetDict[options.name]["textfield"]:setTextColor( unpack(muiData.widgetDict[options.name]["textlabel"].inactiveColor) )

    local textOptions =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        width = options.width,
        font = options.font,
        fontSize = options.fontSize * 0.55,
        align = "left"  --new alignment parameter
    }
    muiData.widgetDict[options.name]["textfieldfake"] = display.newText( textOptions )
    muiData.widgetDict[options.name]["textfieldfake"]:setFillColor( unpack(muiData.widgetDict[options.name]["textlabel"].inactiveColor) )
    muiData.widgetDict[options.name]["textfieldfake"]:addEventListener("touch", M.showNativeInput)
    muiData.widgetDict[options.name]["textfieldfake"].name = options.name
    muiData.widgetDict[options.name]["textfieldfake"].dialogName = options.dialogName
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["textfieldfake"] )

    -- muiData.widgetDict[options.name]["textfield"].placeholder = "Subject"
    muiData.widgetDict[options.name]["textfield"].callBack = options.callBack
    muiData.widgetDict[options.name]["textfield"]:addEventListener( "userInput", M.textListener )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["textfield"] )
end

function M.textfieldCallBack(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")

    if muiTargetValue ~= nil then
        print("TextField contains: "..muiTargetValue)
    end
end

function M.removeWidgetTextField(widgetName)
    M.removeTextField(widgetName)
end

function M.removeTextField(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["textfieldfake"].isVisible = false
    muiData.widgetDict[widgetName]["textfieldfake"]:removeSelf()
    muiData.widgetDict[widgetName]["textfield"].isVisible = false
    muiData.widgetDict[widgetName]["textfield"]:removeSelf()
    muiData.widgetDict[widgetName]["textfield"] = nil
    if muiData.widgetDict[widgetName]["textlabel"] ~= nil then
        muiData.widgetDict[widgetName]["textlabel"]:removeSelf()
        muiData.widgetDict[widgetName]["textlabel"] = nil
    end
    muiData.widgetDict[widgetName]["lineanim"]:removeSelf()
    muiData.widgetDict[widgetName]["lineanim"] = nil
    muiData.widgetDict[widgetName]["line"]:removeSelf()
    muiData.widgetDict[widgetName]["line"] = nil
    muiData.widgetDict[widgetName]["rect"]:removeEventListener("touch", muiData.widgetDict[widgetName]["rect"])
    muiData.widgetDict[widgetName]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["rect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetTextBox(widgetName)
    M.removeTextBox(widgetName)
end

function M.removeTextBox(widgetName)
    M.removeTextField(widgetName)
end

return M
