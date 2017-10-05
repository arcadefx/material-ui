--[[
    A loosely based Material UI module

    mui-dialog.lua : This is for creating modal dialog popups.

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

function M.createDialog(options)
    M.newDialog(options)
end

function M.newDialog(options)

    if options == nil then return end

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    if options.width == nil then
        options.width = options.size
    end

    if options.height == nil then
        options.height = options.size
    end

    local textColor = { 1, 1, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    if options.fillColor == nil then
        options.fillColor = { 1, 1, 1, 1 }
    end

    -- deprecated if-then and option
    if options.backgroundColor ~= nil then
        options.fillColor = options.backgroundColor
    end

    if options.easing == nil then
        options.easing = easing.inOutCubic
    end

    -- paint normal or use gradient?
    local paint = nil
    if options.gradientBorderShadowColor1 ~= nil and options.gradientBorderShadowColor2 ~= nil then
        if options.gradientDirection == nil then
            options.gradientDirection = "down"
        end
        paint = {
            type = "gradient",
            color1 = options.gradientBorderShadowColor1,
            color2 = options.gradientBorderShadowColor2,
            direction = options.gradientDirection
        }
    end

    -- place on main display
    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["rectbackdrop"] = display.newRect( display.contentWidth * .5, display.contentHeight * .5, display.contentWidth, display.contentHeight )
    muiData.widgetDict[options.name]["rectbackdrop"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectbackdrop"]:setFillColor( unpack( {0.4, 0.4, 0.4, 0.3} ) )
    muiData.widgetDict[options.name]["rectbackdrop"].isVisible = true

    -- now for the rest of the dialog
    local centerX = (muiData.contentWidth * 0.5)
    local centerY = (muiData.contentHeight * 0.5)

    muiData.widgetDict[options.name]["options"] = options
    muiData.dialogName = options.name
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "Dialog"
    muiData.widgetDict[options.name]["container"] = display.newContainer( options.width+20, options.height+20 )
    muiData.widgetDict[options.name]["container"]:translate( centerX, centerY ) -- center the container
    muiData.widgetDict[options.name]["touching"] = false
    local half = muiData.widgetDict[options.name]["container"].contentWidth * .5
    muiData.widgetDict[options.name]["container"].x = centerX
    muiData.widgetDict[options.name]["container"].y = muiData.contentHeight

    muiData.dialogInUse = true

    if options.callBackCancel ~= nil then
        muiData.widgetDict[options.name]["callBackCancel"] = options.callBackCancel
    end

    local radius = options.height

    x = 0
    y = 0
    local width = options.width * 0.98
    local height = options.height * 0.98
    local nr = width * 0.02

    muiData.widgetDict[options.name]["container"]["rrect2"] = display.newRoundedRect( x, y, options.width, options.height, nr )
    if paint ~= nil then
        local object = muiData.widgetDict[options.name]["container"]["rrect2"]
       object.fill = paint

        object.fill.effect = "filter.vignetteMask"
        object.fill.effect.innerRadius = 1
        object.fill.effect.outerRadius = 0.1
        muiData.widgetDict[options.name]["container"]:insert( object )
    end

    muiData.widgetDict[options.name]["container"]["rrect"] = display.newRoundedRect( x, y, width, height, nr)
    muiData.widgetDict[options.name]["container"]["rrect"].strokeWidth = 0
    muiData.widgetDict[options.name]["container"]["rrect"]:setFillColor( unpack( options.fillColor ) )
    muiData.widgetDict[options.name]["container"]["rrect"].name = options.name
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["container"]["rrect"] )

    -- add text
    if options.text ~= nil then
        if options.textX == nil then
            options.textX = 0
        end
        if options.textY == nil then
            options.textY = 0
        end
        if options.font == nil then
            options.font = systemFont
        end
        if options.fontSize == nil then
            options.fontSize = 18
        end
        local outerWidth = muiData.widgetDict[options.name]["container"]["rrect"].contentWidth
        local outerHeight = muiData.widgetDict[options.name]["container"]["rrect"].contentHeight
        muiData.widgetDict[options.name]["container2"] = display.newContainer( outerWidth, outerHeight - 90 )
        muiData.widgetDict[options.name]["container2"]:translate( 0, -30 ) -- center the container
        muiData.widgetDict[options.name]["myText"] = display.newText( options.text, options.textX, options.textY, options.font, options.fontSize)
        muiData.widgetDict[options.name]["myText"]:setFillColor( unpack( options.textColor ) )
        muiData.widgetDict[options.name]["container2"]:insert( muiData.widgetDict[options.name]["myText"] )
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["container2"] )
    end

    ---[[--
    local bx = 0
    local by = 0
    if options.buttons ~= nil and options.buttons["okayButton"] ~= nil then
        if options.buttons["okayButton"].callBackOkay ~= nil then
            muiData.widgetDict[options.name]["callBackOkay"] = options.buttons["okayButton"].callBackOkay
        end
        if options.buttons["okayButton"].fillColor == nil then
            options.buttons["okayButton"].fillColor = { 1, 0, 0 }
        end
        if options.buttons["okayButton"].textColor == nil then
            options.buttons["okayButton"].textColor = { 1, 0, 0 }
        end
        if options.buttons["okayButton"].text == nil then
            options.buttons["okayButton"].text = "Okay"
        end
        if options.buttons["okayButton"].width == nil then
            options.buttons["okayButton"].width = 100
        end
        if options.buttons["okayButton"].height == nil then
            options.buttons["okayButton"].height = 50
        end

        by = (muiData.widgetDict[options.name]["container"]["rrect"].contentHeight * 0.5) - options.buttons["okayButton"].height
        if options.buttons ~= nil and options.buttons.okayButton ~= nil and options.buttons.cancelButton ~= nil then
            bx = (muiData.widgetDict[options.name]["container"]["rrect"].contentWidth - options.buttons["okayButton"].width) * .5 - 15
        else
            bx = 0
        end
        M.newRectButton({
            name = "okay_dialog_button",
            text = options.buttons["okayButton"].text,
            width = options.buttons["okayButton"].width,
            height = options.buttons["okayButton"].height,
            ignoreInsets = true,
            x = bx,
            y = by,
            font = native.systemFont,
            fillColor = options.buttons["okayButton"].fillColor,
            textColor = options.buttons["okayButton"].textColor,
            touchpoint = true,
            callBack = M.dialogOkayCallback,
            callBackData = options.buttons["okayButton"].callBackData,
            clickAnimation = options.buttons["okayButton"].clickAnimation,
            dialogName = options.name
        })
        muiData.widgetDict[options.name]["container"]:insert( M.getWidgetBaseObject("okay_dialog_button") )
    end

    ---[[--
    if options.buttons ~= nil and options.buttons["cancelButton"] ~= nil then
        if options.buttons["cancelButton"].callBackCancel ~= nil then
            muiData.widgetDict[options.name]["callBackCancel"] = options.buttons["cancelButton"].callBackCancel
        end
        if options.buttons["cancelButton"].fillColor == nil then
            options.buttons["cancelButton"].fillColor = { 1, 0, 0 }
        end
        if options.buttons["cancelButton"].textColor == nil then
            options.buttons["cancelButton"].textColor = { 1, 0, 0 }
        end
        if options.buttons["cancelButton"].text == nil then
            options.buttons["cancelButton"].text = "Okay"
        end
        if options.buttons["cancelButton"].width == nil then
            options.buttons["cancelButton"].width = 100
        end
        if options.buttons["cancelButton"].height == nil then
            options.buttons["cancelButton"].height = 50
        end
        if bx > 0 then
            bx = (bx - options.buttons["cancelButton"].width) * .5 - 20
        end
        M.newRectButton({
            name = "cancel_dialog_button",
            text = options.buttons["cancelButton"].text,
            width = options.buttons["cancelButton"].width,
            height = options.buttons["cancelButton"].height,
            ignoreInsets = true,
            x = bx,
            y = by,
            font = native.systemFont,
            fillColor = options.buttons["cancelButton"].fillColor,
            textColor = options.buttons["cancelButton"].textColor,
            touchpoint = true,
            clickAnimation = options.buttons["cancelButton"].clickAnimation,
            callBack = M.dialogCancelCallback,
            callBackData = options.buttons["cancelButton"].callBackData,
            dialogName = options.name
        })
        muiData.widgetDict[options.name]["container"]:insert( M.getWidgetBaseObject("cancel_dialog_button") )
    end
    --]]--
    muiData.widgetDict[options.name]["rectbackdrop"].isVisible = true
    transition.fadeIn( muiData.widgetDict[options.name]["rectbackdrop"], { time=1500 } )
    centerY = (display.contentHeight * .5) - muiData.safeAreaInsets.bottomInset
    transition.to( muiData.widgetDict[options.name]["container"], { time=800, y = centerY, transition=options.easing } )
end

--[[--

 For the buttons on the Dialog use the following to get their properties
 M.getRectButtonProperty("okay_dialog_button", <property name>)
 M.getRectButtonProperty("cancel_dialog_button", <property name>)

--]]--
function M.getDialogProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- move x,y
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rectbackdrop"] -- darken area
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["container"]["rect2"] -- shadow border area
    elseif propertyName == "layer_3" then
        data = muiData.widgetDict[widgetName]["container"]["rrect"] -- the base background
    elseif propertyName == "layer_4" then
        data = muiData.widgetDict[widgetName]["container2"] -- text object, move x,y
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["myText"] -- text in dialog
    end
    return data
end

function M.dialogOkayCallback(e)
    if muiData.dialogName == nil then return end
    if muiData.widgetDict[muiData.dialogName]["callBackOkay"] ~= nil then
       assert( muiData.widgetDict[muiData.dialogName]["callBackOkay"] )(e)
    end
    M.closeDialog(e)
end

function M.actionForOkayDialog(e)
    M.debug("actionForOkayDialog called")
end

function M.dialogCancelCallback(e)
    if muiData.widgetDict[muiData.dialogName]["callBackCancel"] ~= nil then
       assert( muiData.widgetDict[muiData.dialogName]["callBackCancel"] )(e)
    end
    M.closeDialog(e)
end

function M.closeDialog(e)
    -- fade out and destroy it
    if muiData.dialogName ~= nil then
        transition.fadeOut( muiData.widgetDict[muiData.dialogName]["rectbackdrop"], { time=500 } )
        transition.to( muiData.widgetDict[muiData.dialogName]["container"], { time=1100, y = muiData.contentHeight * 2, onComplete=M.removeDialog, transition=easing.inOutCubic } )
    end
end

function M.dialogClose(e)
    -- fade out and destroy it
    M.closeDialog(e)
end

function M.removeWidgetDialog()
    M.removeDialog()
end

function M.removeDialog()
    if muiData.dialogName == nil then
        return
    end
    local widgetName = muiData.dialogName

    if muiData.widgetDict[widgetName] == nil then return end

    -- remove buttons
    M.removeRectButton("okay_dialog_button")
    M.removeRectButton("cancel_dialog_button")

    -- remove the rest
    -- muiData.widgetDict[widgetName]["container"]["myText"]:removeSelf()
    -- muiData.widgetDict[widgetName]["container"]["myText"] = nil
    muiData.widgetDict[widgetName]["rectbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["rectbackdrop"] = nil
    muiData.widgetDict[widgetName]["container"]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["container"]["rrect"] = nil
    muiData.widgetDict[widgetName]["container"]["rrect2"]:removeSelf()
    muiData.widgetDict[widgetName]["container"]["rrect2"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
    muiData.dialogName = nil
    muiData.dialogInUse = false
end

return M
