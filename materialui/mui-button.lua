--[[
    A loosely based Material UI module

    mui-button.lua : This is for creating buttons.

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

function M.activateImageTouch(options)
    if muiData.widgetDict[options.name] == nil then return end
    if muiData.widgetDict[options.name]["myImageTouch"] ~= nil and muiData.widgetDict[options.name]["myImageTouchIndex"] ~= nil then
        muiData.widgetDict[options.name]["myImageTouch"].alpha = 1
        muiData.widgetDict[options.name]["myImageTouch"].isVisible = true
        muiData.widgetDict[options.name]["myImage"].isVisible = false
    end
end

function M.deactivateImageTouch(options)
    if muiData.widgetDict[options.name] == nil then return end
    if muiData.widgetDict[options.name]["myImageTouch"] ~= nil and muiData.widgetDict[options.name]["myImageTouchIndex"] ~= nil then
        muiData.widgetDict[options.name]["myImage"].isVisible = true
        if muiData.widgetDict[options.name]["myImageTouchFadeAnim"] == true then
            local speed = muiData.widgetDict[options.name]["myImageTouchFadeAnimSpeed"]
            transition.fadeOut(muiData.widgetDict[options.name]["myImageTouch"],{time=speed})
            transition.fadeIn(muiData.widgetDict[options.name]["myImage"],{time=50})
        else
            muiData.widgetDict[options.name]["myImageTouch"].isVisible = false
        end
    end
end

--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize:
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createRRectButton(options)
    M.newRoundedRectButton(options)
end

function M.newRoundedRectButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    local nw = options.width + 20 --(options.width * 0.05)
    local nh = options.height + 20 -- (options.height * 0.05)

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "RRectButton"
    -- muiData.widgetDict[options.name]["container"] = display.newGroup() --display.newContainer( nw, nh )

    local padding = 0
    if options.useShadow == true then padding = 50 end

    muiData.widgetDict[options.name]["container"] = display.newContainer( nw+padding, nh+padding )

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

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    if options.useShadow == true then
        local size = options.shadowSize or 20
        local opacity = options.shadowOpacity or 0.3
        local shadow = M.newShadowShape("rounded_rect", {
            name = options.name,
            width = options.width,
            height = options.height,
            size = size,
            opacity = opacity,
            cornerRadius = radius,
        })
        muiData.widgetDict[options.name]["shadow"] = shadow
        muiData.widgetDict[options.name]["container"]:insert( shadow )
    end

    local nr = radius + 8 -- (options.height+M.getScaleVal(8)) * 0.2

    -- paint normal or use gradient?
    local paint = nil
    if options.gradientShadowColor1 ~= nil and options.gradientShadowColor2 ~= nil then
        if options.gradientDirection == nil then
            options.gradientDirection = "up"
        end
        paint = {
            type = "gradient",
            color1 = options.gradientShadowColor1,
            color2 = options.gradientShadowColor2,
            direction = options.gradientDirection
        }
    end

    muiData.widgetDict[options.name]["rrect2"] = display.newRoundedRect( 0, 1, options.width+8, options.height+8, nr )
    if paint ~= nil then
        muiData.widgetDict[options.name]["rrect2"].fill = paint
    else
        muiData.widgetDict[options.name]["rrect2"].isVisible = false
    end
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect2"] )

    local fillColor = { 0, 0.82, 1 }
    if options.fillColor ~= nil then
        fillColor = options.fillColor
    end

    if options.strokeWidth == nil then
        options.strokeWidth = 0
    end

    muiData.widgetDict[options.name]["rrect"] = display.newRoundedRect( 0, 0, options.width, options.height, radius )
    if options.strokeWidth > 0 then
        muiData.widgetDict[options.name]["rrect"].strokeWidth = options.strokeWidth or 1
        muiData.widgetDict[options.name]["rrect"]:setStrokeColor( unpack(options.strokeColor) )
    end
    muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )
    muiData.widgetDict[options.name]["rrect"].dialogName = options.dialogName

    local rrect = muiData.widgetDict[options.name]["rrect"]

    local fontSize = 10
    local textMargin = options.height * 0.4
    if options.textMargin ~= nil and options.textMargin > 0 then
        textMargin = options.textMargin
    end

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local textColor = { 1, 1, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    if options.transitionStartColor == nil then

    end

    options.ignoreTap = options.ignoreTap or false

    -- create image buttons if exist
    M.createButtonsFromList(options, rrect, "container")

    muiData.widgetDict[options.name]["clickAnimation"] = options.clickAnimation

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = fontSize * ( ( rrect.contentHeight - textMargin ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    textToMeasure:removeSelf()
    textToMeasure = nil

    if options.iconText ~= nil and options.iconFont ~= nil and options.iconImage == nil then

        if M.isMaterialFont(options.iconFont) == true then
            options.iconText = M.getMaterialFontCodePointByName(options.iconText)
        end
        muiData.widgetDict[options.name]["myIconText"] = display.newText( options.iconText, 0, 0, options.iconFont, fontSize )
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myIconText"], false )
    elseif options.iconImage ~= nil then
        muiData.widgetDict[options.name]["myIconText"] = display.newImageRect( options.iconImage, options.width, options.height )
        if muiData.widgetDict[options.name]["myIconText"] ~= nil then
            muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myIconText"], false )
        end
    end

    textXOffset = 0
    if muiData.widgetDict[options.name]["myIconText"] ~= nil then
        textXOffset = fontSize * 0.55
    end

    muiData.widgetDict[options.name]["myText"] = display.newText( options.text, textXOffset, 0, font, fontSize )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myText"], false )

    if muiData.widgetDict[options.name]["myIconText"] ~= nil then
        local width = muiData.widgetDict[options.name]["myText"].contentWidth * 0.55
        muiData.widgetDict[options.name]["myIconText"].x = -(width)
    end

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end
    circleColor = {0.88,0.88,0.88,1}

    local maxWidth = muiData.widgetDict[options.name]["rrect"].path.width - (radius * 2)

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( options.height, options.height, options.height * 0.5)
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )
    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    if muiData.widgetDict[options.name]["myImage"] ~= nil then
        muiData.widgetDict[options.name]["rrect"].alpha = 0.01
        muiData.widgetDict[options.name]["rrect2"].isVisible = false
        muiData.widgetDict[options.name]["myText"].isVisible = false
    end

    rrect.muiOptions = options
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.touchRRectButton )
    if options.ignoreTap then
        muiData.widgetDict[options.name]["rrect"]:addEventListener("tap", function() return true end)
    end
end

function M.getRoundedRectButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["myText"] -- button text
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rrect2"] -- button shadow
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["rrect"] -- button face
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["myImage"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["myImageTouch"]
    elseif propertyName == "shadow" then
        data = muiData.widgetDict[widgetName]["shadow"]
    end
    return data
end

function M.touchRRectButton (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if muiData.dialogInUse == true and options.dialogName == nil then return end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        --event.target:takeFocus(event)
        -- if scrollView then use the below
        muiData.interceptEventHandler = M.touchRRectButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        -- muiData.interceptEventHandler = event.target
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
            M.activateImageTouch( options )
            if options.clickAnimation ~= nil then
                if options.clickAnimation["backgroundColor"] ~= nil then
                    options.clickAnimation["fillColor"] = options.clickAnimation["backgroundColor"]
                end
                if options.clickAnimation["fillColor"] ~= nil then
                    muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.clickAnimation["fillColor"]) )
                end
            end

            local TransFunc = function()
                M.transitionColor(
                    muiData.widgetDict[options.name]["rrect"],
                    {
                        startColor = options.animation.transitionStartColor,
                        endColor = options.animation.transitionEndColor or options.fillColor,
                        transition = options.animation.transition or easing.inOutExpo,
                        time = options.animation.time or 1000,
                    }
                )
            end

            if options.animation ~= nil and options.animation.animationType == "colorTransition" and options.animation.transitionStartColor ~= nil then
                timer.performWithDelay(1, TransFunc, 1)
            end

            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.name]["myCircle"].x = event.x - muiData.widgetDict[options.name]["container"].x
                muiData.widgetDict[options.name]["myCircle"].y = event.y - muiData.widgetDict[options.name]["container"].y
            end
            muiData.widgetDict[options.name]["myCircle"].isVisible = true
            local scaleFactor = 0.1
            muiData.widgetDict[options.name].myCircleTrans = transition.from( muiData.widgetDict[options.name]["myCircle"], { time=500,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(muiData.widgetDict[options.name]["container"],{time=300, xScale=1.02, yScale=1.02, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "moved" ) then
        if options.fillColor ~= nil then
            muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
        end
    elseif ( event.phase == "ended" ) then

        M.deactivateImageTouch( options )

        if M.isTouchPointOutOfRange( event ) then
              event.phase = "offTarget"
              -- M.debug("Its out of the button area")
              -- event.target:dispatchEvent(event)
        else
            event.phase = "onTarget"
            if muiData.interceptMoved == false then
                if options.clickAnimation ~= nil then
                    if options.clickAnimation["time"] == nil then
                        options.clickAnimation["time"] = 400
                    end
                    transition.fadeOut(muiData.widgetDict[options.name]["rrect"],{time=options.clickAnimation["time"]})
                end
                event.target = muiData.widgetDict[options.name]["rrect"]
                --event.callBackData = options.callBackData

                muiData.widgetDict[options.name]["value"] = options.value
                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["rrect"])
                M.setEventParameter(event, "muiTargetCallBackData", options.callBackData)

                if options.callBack ~= nil then
                    assert( options.callBack )(event)
                end
            end
        end
        muiData.interceptEventHandler = nil
        muiData.interceptOptions = nil
        muiData.interceptMoved = false
        muiData.touching = false
    end
    muiData.touched = true
    return true
end

--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize:
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createRectButton(options)
    M.newRectButton(options)
end

function M.newRectButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    local padding = 4
    if options.useShadow == true then padding = 50 end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "RectButton"
    muiData.widgetDict[options.name]["container"] = display.newContainer( options.width+padding, options.height+padding )
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

    -- paint normal or use gradient?
    local paint = nil
    if options.gradientColor1 ~= nil and options.gradientColor2 ~= nil then
        if options.gradientDirection == nil then
            options.gradientDirection = "up"
        end
        paint = {
            type = "gradient",
            color1 = options.gradientColor1,
            color2 = options.gradientColor2,
            direction = options.gradientDirection
        }
    end

    local fillColor = { 0, 0.82, 1 }
    if options.fillColor ~= nil then
        fillColor = options.fillColor
    end

    local strokeWidth = 0
    if paint ~= nil then strokeWidth = 1 end

    if options.useShadow == true then
        local size = options.shadowSize or 20
        local opacity = options.shadowOpacity or 0.3
        local shadow = M.newShadowShape("rect", {
            name = options.name,
            width = options.width,
            height = options.height,
            size = size,
            opacity = opacity,
        })
        muiData.widgetDict[options.name]["shadow"] = shadow
        muiData.widgetDict[options.name]["container"]:insert( shadow )
    end

    muiData.widgetDict[options.name]["rrect"] = display.newRect( 0, 0, options.width, options.height )
    if paint ~= nil then
        muiData.widgetDict[options.name]["rrect"].fill = paint
    end
    if options.strokeWidth ~= nil and options.strokeWidth > 0 then
        muiData.widgetDict[options.name]["rrect"].strokeWidth = options.strokeWidth or 1
        muiData.widgetDict[options.name]["rrect"]:setStrokeColor( unpack(options.strokeColor) )
    end
    muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )

    local rrect = muiData.widgetDict[options.name]["rrect"]

    -- create image buttons if exist
    M.createButtonsFromList(options, rrect, "container")

    local fontSize = 10
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end

    local textMargin = options.height * 0.4
    if options.textMargin ~= nil and options.textMargin > 0 then
        textMargin = options.textMargin
    end

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    local textColor = { 1, 1, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    if options.fontSize == nil then
        local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
        fontSize = fontSize * ( ( rrect.contentHeight - textMargin ) / textToMeasure.contentHeight )
        fontSize = mathFloor(tonumber(fontSize))
        textToMeasure:removeSelf()
        textToMeasure = nil
    end

    if options.iconText ~= nil and options.iconFont ~= nil and options.iconImage == nil then
        if M.isMaterialFont(options.iconFont) == true then
            options.iconText = M.getMaterialFontCodePointByName(options.iconText)
        end
        muiData.widgetDict[options.name]["myIconText"] = display.newText( options.iconText, 0, 0, options.iconFont, fontSize )
        if options.iconFontColor ~= nil then
            muiData.widgetDict[options.name]["myIconText"]:setFillColor( unpack(options.iconFontColor) )
        end
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myIconText"], false )
    elseif options.iconImage ~= nil then
        muiData.widgetDict[options.name]["myIconText"] = display.newImageRect( options.iconImage, fontSize, fontSize )
        if muiData.widgetDict[options.name]["myIconText"] ~= nil then
            muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myIconText"], false )
        end
    end

    textXOffset = 0
    if muiData.widgetDict[options.name]["myIconText"] ~= nil then
        textXOffset = fontSize * 0.55
    end
    muiData.widgetDict[options.name]["myText"] = display.newText( options.text, textXOffset, 0, font, fontSize )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myText"], false )

    if muiData.widgetDict[options.name]["myIconText"] ~= nil then
        local width = muiData.widgetDict[options.name]["myText"].contentWidth * 0.55
        muiData.widgetDict[options.name]["myIconText"].x = -(width)
    end

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    local radius = options.height * 0.1
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local maxWidth = muiData.widgetDict[options.name]["rrect"].width - (radius * 2)

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( options.height, options.height, maxWidth )
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )
    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd


    rrect.muiOptions = options
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.touchRRectButton )
    options.ignoreTap = options.ignoreTap or false
    if options.ignoreTap then
        muiData.widgetDict[options.name]["rrect"]:addEventListener("tap", function() return true end)
    end
end

function M.getRectButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["myText"] -- button text
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rrect"] -- button face
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["myImage"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["myImageTouch"]
    elseif propertyName == "shadow" then
        data = muiData.widgetDict[widgetName]["shadow"]
    end
    return data
end

--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize:
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createIconButton(options)
    M.newIconButton(options)
end

function M.newIconButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "IconButton"
    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"].x = x
    muiData.widgetDict[options.name]["mygroup"].y = y
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    local radius = options.height -- * (0.2 * M.getSizeRatio())
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

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end

    if options.isFontIcon == nil then
        options.isFontIcon = false
        -- backwards compatiblity
        if M.isMaterialFont(options.font) == true then
            options.isFontIcon = true
        end
    end

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local checkbox = {contentHeight=options.height, contentWidth=options.width}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    local fontSize = mathFloor(fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight ))
    local tw = textToMeasure.contentWidth
    local th = textToMeasure.contentHeight

    if options.isFontIcon == true then
        tw = fontSize
        if M.isMaterialFont(options.font) == true then
            options.text = M.getMaterialFontCodePointByName(options.text)
        end
    elseif string.len(options.text) < 2 then
        tw = fontSize
    end

    textToMeasure:removeSelf()
    textToMeasure = nil

    local options2 =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        font = font,
        width = tw * 1.5,
        fontSize = fontSize,
        align = "center"
    }

    muiData.widgetDict[options.name]["myText"] = display.newText( options2 )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    muiData.widgetDict[options.name]["myText"].isVisible = true
    if isChecked then
        muiData.widgetDict[options.name]["myText"].isChecked = isChecked
    end
    muiData.widgetDict[options.name]["value"] = isChecked

    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["myText"], true )

    checkbox = muiData.widgetDict[options.name]["myText"]

    local radiusOffset = 2.5
    if muiData.masterRatio > 1 then radiusOffset = 2.0 end
    local maxWidth = checkbox.contentWidth * 0.6 -- - (radius * radiusOffset)

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( 0, 0, maxWidth + 5)
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )

    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].x = 0
    muiData.widgetDict[options.name]["myCircle"].y = 0
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    checkbox.muiOptions = options
    muiData.widgetDict[options.name]["myText"]:addEventListener( "touch", M.touchIconButton )
    options.ignoreTap = options.ignoreTap or false
    if options.ignoreTap then
        muiData.widgetDict[options.name]["myText"]:addEventListener("tap", function() return true end)
    end
end

function M.getIconButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "icon" then
        data = muiData.widgetDict[widgetName]["myText"] -- button
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["myImage"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["myImageTouch"]
    end
    return data
end

function M.touchIconButton (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if muiData.dialogInUse == true and options.dialogName == nil then return end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.touchIconButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
            M.activateImageTouch( options )
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.name]["myCircle"].x = event.x - muiData.widgetDict[options.name]["mygroup"].x
                muiData.widgetDict[options.name]["myCircle"].y = event.y - muiData.widgetDict[options.name]["mygroup"].y
            end
            muiData.widgetDict[options.name]["myCircle"].isVisible = true
            local scaleFactor = 0.1
            muiData.widgetDict[options.name].myCircleTrans = transition.from( muiData.widgetDict[options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(event.target,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
        else
          event.phase = "onTarget"
            if muiData.interceptMoved == false then
                event.target = muiData.widgetDict[options.name]["checkbox"]
                event.altTarget = muiData.widgetDict[options.name]["myText"]
                event.myTargetName = options.name

                muiData.widgetDict[options.name]["value"] = options.value
                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["myText"])
                M.setEventParameter(event, "muiTargetCallBackData", options.callBackData)

                if options.callBack ~= nil then
                    assert( options.callBack )(event)
                end
            end
            muiData.interceptEventHandler = nil
            muiData.interceptOptions = nil
            muiData.interceptMoved = false
            muiData.touching = false
            M.deactivateImageTouch( options )
        end
    end
    muiData.touched = true
    return true
end

function M.createCheckBox(options)
    M.newCheckBox(options)
end

function M.newCheckBox(options)
    M.newIconButton(options)
end

function M.createCircleButton(options)
    M.newCircleButton(options)
end

function M.newCircleButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "CircleButton"
    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"].x = x
    muiData.widgetDict[options.name]["mygroup"].y = y
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    if options.radius == nil then
        radius = 46 * 0.60
    else
        radius = options.radius * 0.60
    end

    local fontSize = options.radius
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

    local fillColor = { 0, 0, 0 }
    if options.fillColor ~= nil then
        fillColor = options.fillColor
    end

    if options.isFontIcon == nil then
        options.isFontIcon = false
        -- backwards compatiblity
        if M.isMaterialFont(options.font) == true then
            options.isFontIcon = true
        end
    end

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    if options.useShadow == true then
        local size = options.shadowSize or options.radius * 0.55
        local opacity = options.shadowOpacity or 0.4
        local shadow = M.newShadowShape("circle", {
            name = options.name,
            width = options.radius,
            height = options.radius,
            size = size,
            opacity = opacity,
        })
        muiData.widgetDict[options.name]["shadow"] = shadow
        muiData.widgetDict[options.name]["mygroup"]:insert( shadow )
    end

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local tempSize = {contentHeight=options.radius, contentWidth=options.radius}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = mathFloor(fontSize * ( tempSize.contentHeight / textToMeasure.contentHeight ))
    fontSize = mathFloor(tonumber(fontSize))

    local tw = textToMeasure.contentWidth
    local th = textToMeasure.contentHeight

    if options.isFontIcon == true then
        tw = fontSize
        if M.isMaterialFont(options.font) == true then
            options.text = M.getMaterialFontCodePointByName(options.text)
        end
    elseif string.len(options.text) < 2 then
        tw = fontSize
    end

    textToMeasure:removeSelf()
    textToMeasure = nil

    local options2 =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        font = font,
        width = tw * 1.5,
        fontSize = fontSize,
        align = "center"
    }

    muiData.widgetDict[options.name]["circlemain"] = display.newCircle( 0, 0, radius )
    muiData.widgetDict[options.name]["circlemain"]:setFillColor( unpack(fillColor) )
    muiData.widgetDict[options.name]["circlemain"].isVisible = true
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["circlemain"], true )

    muiData.widgetDict[options.name]["myText"] = display.newText( options2 )
    muiData.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    muiData.widgetDict[options.name]["myText"].isVisible = true

    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["myText"], false )

    local circle = muiData.widgetDict[options.name]["circlemain"]

    local radiusOffset = 2.5
    if muiData.masterRatio > 1 then radiusOffset = 2.0 end
    local maxWidth = circle.contentWidth - (radius * radiusOffset)

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( 0, 0, maxWidth + 5)
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )

    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].x = 0
    muiData.widgetDict[options.name]["myCircle"].y = 0
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    muiData.widgetDict[options.name]["circlemain"].muiOptions = options
    muiData.widgetDict[options.name]["circlemain"]:addEventListener( "touch", M.touchCircleButton )
    options.ignoreTap = options.ignoreTap or false
    if options.ignoreTap then
        muiData.widgetDict[options.name]["circlemain"]:addEventListener("tap", function() return true end)
    end
end

function M.getCircleButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["myText"] -- button
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["circlemain"] -- the base
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["myImage"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["myImageTouch"]
    elseif propertyName == "shadow" then
        data = muiData.widgetDict[widgetName]["shadow"]
    end
    return data
end

function M.touchCircleButton (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end
    if muiData.dialogInUse == true and options.dialogName == nil then
         return
    end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.touchCircleButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
            M.activateImageTouch( options )
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.name]["myCircle"].x = event.x - muiData.widgetDict[options.name]["mygroup"].x
                muiData.widgetDict[options.name]["myCircle"].y = event.y - muiData.widgetDict[options.name]["mygroup"].y
            end
            muiData.widgetDict[options.name]["myCircle"].isVisible = true
            local scaleFactor = 4.1
            muiData.widgetDict[options.name].myCircleTrans = transition.from( muiData.widgetDict[options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(event.target,{time=500, xScale=1.1, yScale=1.1, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
        else
          event.phase = "onTarget"
            if muiData.interceptMoved == false then
                event.target = muiData.widgetDict[options.name]["circlemain"]
                event.myTargetName = options.name

                muiData.widgetDict[options.name]["value"] = options.value
                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["circlemain"])
                M.setEventParameter(event, "muiTargetCallBackData", options.callBackData)

                if options.callBack ~= nil then
                    assert( options.callBack )(event)
                end
            end
            muiData.interceptEventHandler = nil
            muiData.interceptOptions = nil
            muiData.interceptMoved = false
            muiData.touching = false
            M.deactivateImageTouch( options )
        end
    end
    muiData.touched = true
    return true
end

--[[
 options..
    name: name of button
    width: width
    height: height
    radius: radius of the corners
    strokeColor: {r, g, b}
    fillColor: {r, g, b}
    x: x
    y: y
    text: text for button
    textColor: {r, g, b}
    font: font to use
    fontSize:
    textMargin: used to pad around button and determine font size,
    circleColor: {r, g, b} (optional, defaults to textColor)
    touchpoint: boolean, if true circle touch point is user based else centered
    callBack: method to call passing the "e" to it

]]
function M.createRadioButton(options)
    M.newRadioButton(options)
end

function M.newRadioButton(options)

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    x, y = M.getSafeXY(options, x, y)

    muiData.widgetDict[options.basename]["radio"][options.name] = {}
    muiData.widgetDict[options.basename]["type"] = "RadioButton"

    local radioButton =  muiData.widgetDict[options.basename]["radio"][options.name]
    radioButton["mygroup"] = display.newGroup()
    radioButton["mygroup"].x = x
    radioButton["mygroup"].y = y
    radioButton["touching"] = false

    if options.scrollView ~= nil and muiData.widgetDict[options.name]["scrollView"] == nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    if options.parent ~= nil then
        radioButton["parent"] = options.parent
        radioButton["parent"]:insert( radioButton["mygroup"] )
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

    local textColor = { 0, 0.82, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    local labelFont = native.systemFont
    if options.labelFont ~= nil then
        labelFont = options.labelFont
    end

    local label = "???"
    if options.label ~= nil then
        label = options.label
    end

    local labelColor = { 0, 0, 0 }
    if options.labelColor ~= nil then
        labelColor = options.labelColor
    end

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end

    if options.isFontIcon == nil then
        options.isFontIcon = false
        -- backwards compatiblity
        if M.isMaterialFont(font) == true then
            options.isFontIcon = true
        end
    end

    radioButton["font"] = font
    radioButton["fontSize"] = fontSize
    radioButton["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local checkbox = {contentHeight=options.height, contentWidth=options.width}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    local textWidth = textToMeasure.contentWidth
    local textHeight = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil

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
        x = 0,
        y = 0,
        font = font,
        width = tw,
        fontSize = fontSize,
        align = "center"
    }

    radioButton["myText"] = display.newText( options2 )
    radioButton["myText"]:setFillColor( unpack(textColor) )
    radioButton["myText"].isVisible = true
    if isChecked then
        if options.textOn ~= nil then
            radioButton["myText"].text = M.getMaterialFontCodePointByName(options.textOn)
        end
        radioButton["myText"].isChecked = isChecked
    end
    radioButton["myText"].value = options.value
    radioButton["mygroup"]:insert( radioButton["myText"], true )

    -- add the label

    local textToMeasure2 = display.newText( options.label, 0, 0, options.labelFont, fontSize )
    local labelWidth = textToMeasure2.contentWidth
    textToMeasure2:removeSelf()
    textToMeasure2 = nil

    local labelX = radioButton["mygroup"].x
    -- x,y of both myText and label is centered so divide by half
    local labelSpacing = fontSize * 0.1
    labelX = radioButton["myText"].x + (fontSize * 0.5) + labelSpacing
    labelX = labelX + (labelWidth * 0.5)
    local options3 =
    {
        --parent = muiData.widgetDict[options.name]["mygroup"],
        text = options.label,
        x = mathFloor(labelX),
        y = 0,
        width = labelWidth,
        font = labelFont,
        fontSize = fontSize *.75
    }

    radioButton["myLabel"] = display.newText( options3 )
    radioButton["myLabel"]:setFillColor( unpack(labelColor) )
    radioButton["myLabel"]:setStrokeColor( 0 )
    radioButton["myLabel"].strokeWidth = 3
    radioButton["myLabel"].isVisible = true
    radioButton["myLabel"].touchTarget = radioButton["myText"]
    radioButton["myLabel"].options = options
    radioButton["mygroup"]:insert( radioButton["myLabel"], false )

    local maxWidth = checkbox.contentWidth - (radius * 2)

    -- add the animated circle

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    radioButton["myCircle"] = display.newCircle( options.height, options.height, maxWidth + 5 )
    radioButton["myCircle"]:setFillColor( unpack(circleColor) )
    radioButton["myCircle"].isVisible = false
    radioButton["myCircle"].x = 0
    radioButton["myCircle"].y = 0
    radioButton["myCircle"].alpha = 0.3
    radioButton["mygroup"]:insert( radioButton["myCircle"], true ) -- insert and center bkgd

    checkbox = radioButton["myText"]
    local label = radioButton["myLabel"]
    checkbox.muiOptions = options
    label.muiOptions = options
    muiData.widgetDict[options.basename]["radio"][options.name]["myText"]:addEventListener( "touch", M.touchCheckbox )
    muiData.widgetDict[options.basename]["radio"][options.name]["myLabel"]:addEventListener( "touch", M.touchCheckboxLabel )
    options.ignoreTap = options.ignoreTap or false
    if options.ignoreTap then
        muiData.widgetDict[options.name]["radio"][options.name]["myText"]:addEventListener("tap", function() return true end)
        muiData.widgetDict[options.name]["radio"][options.name]["myLabel"]:addEventListener("tap", function() return true end)
    end
end

function M.getRadioButtonProperty(parentWidgetName, propertyName, index)
    local data = nil

    if parentWidgetName == nil or widgetName == nil or propertyName == nil then return data end

    local widgetName = parentWidgetName .. "_" .. index
    if muiData.widgetDict[widgetParentName]["toolbar"][widgetName] == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[parentWidgetName]["radio"][widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "icon" then
        data = muiData.widgetDict[parentWidgetName]["radio"][widgetName]["myText"] -- button
    elseif propertyName == "label" then
        data = muiData.widgetDict[parentWidgetName]["radio"][widgetName]["myLabel"] -- the base
    elseif propertyName == "value" then
        data = muiData.widgetDict[parentWidgetName]["value"] -- value of button
    end
    return data
end

function M.touchCheckboxHandler(event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end
    if event.phase == "began" then
        if muiData.touching == false then
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - muiData.widgetDict[options.basename]["radio"][options.name]["mygroup"].y
            end
            muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"].isVisible = true
            local scaleFactor = 0.1
            muiData.widgetDict[options.basename]["radio"][options.name].myCircleTrans = transition.from( muiData.widgetDict[options.basename]["radio"][options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(event.target,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
        end
    else
        if muiData.interceptMoved == false then
            --event.target = muiData.widgetDict[options.name]["rrect"]
            event.myTargetName = options.name
            event.myTargetBasename = options.basename
            event.altTarget = muiData.widgetDict[options.basename]["radio"][options.name]["myText"]

            muiData.widgetDict[options.basename]["value"] = options.value
            M.setEventParameter(event, "muiTargetValue", options.value)
            M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.basename]["radio"][options.name]["myText"])
            M.setEventParameter(event, "muiTargetCallBackData", options.callBackData)

            if options.callBack ~= nil then
                assert( options.callBack )(event)
            end
        end
        muiData.interceptEventHandler = nil
        muiData.interceptOptions = nil
        muiData.interceptMoved = false
        muiData.touching = false
    end
    muiData.touched = true
    return true
end

function M.touchCheckboxLabel (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end
    if muiData.dialogInUse == true and options.dialogName == nil then return end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.touchCheckbox
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        M.touchCheckboxHandler( event )
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
        else
          event.phase = "onTarget"
          M.touchCheckboxHandler( event )
        end
    end
    muiData.touched = true
    return true
end

function M.touchCheckbox (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end
    if muiData.dialogInUse == true and options.dialogName == nil then return end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.touchCheckbox
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        M.touchCheckboxHandler( event )
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
        else
          event.phase = "onTarget"
          M.touchCheckboxHandler( event )
        end
    end
    muiData.touched = true
    return true
end

function M.createRadioGroup(options)
    M.newRadioGroup(options)
end

function M.newRadioGroup(options)

    local x, y = options.x, options.y

    if options.isChecked == nil then
        options.isChecked = false
    end

    if options.spacing == nil then
        options.spacing = 10
    end

    x, y = M.getSafeXY(options, x, y)

    if options.list ~= nil then
        local count = 0
        muiData.widgetDict[options.name] = {}
        muiData.widgetDict[options.name]["radio"] = {}
        muiData.widgetDict[options.name]["type"] = "RadioGroup"
        for i, v in ipairs(options.list) do
            M.newRadioButton({
                parent = options.parent,
                name = options.name .. "_" .. i,
                basename = options.name,
                label = v.key,
                value = v.value,
                text = "radio_button_unchecked",
                textOn = "radio_button_checked",
                width = options.width,
                height = options.height,
                ignoreInsets = true,
                x = x,
                y = y,
                isChecked = v.isChecked,
                isFontIcon = true,
                font = muiData.materialFont,
                labelFont = options.labelFont,
                textColor = options.textColor,
                textAlign = "center",
                labelColor = options.labelColor,
                callBack = options.callBack
            })
            local radioButton = muiData.widgetDict[options.name]["radio"][options.name.."_"..i]
            if options.layout ~= nil and options.layout == "horizontal" then
                width = radioButton["myText"].contentWidth + radioButton["myLabel"].contentWidth + options.spacing
                x = x + width * .8 -- + (radioButton["myText"].contentWidth *.25)
            else
                y = y + radioButton["myText"].contentHeight + options.spacing
            end
            count = count + 1
        end
    end

end

function M.actionForPlus( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")
    local muiTargetCallBackData = M.getEventParameter(e, "muiTargetCallBackData")

    if muiTarget ~= nil then
        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = M.getMaterialFontCodePointByName("add_circle")
         else
            muiTarget.isChecked = true
            muiTarget.text = M.getMaterialFontCodePointByName("add_circle")
            if muiTargetValue ~= nil then
                M.debug("checkbox value = "..muiTargetValue)
            end
        end
    end
    return true
end

function M.actionForCheckbox( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = M.getMaterialFontCodePointByName("check_box_outline_blank")
         else
            muiTarget.isChecked = true
            muiTarget.text = M.getMaterialFontCodePointByName("check_box")
            if muiTargetValue ~= nil then
                M.debug("checkbox value = "..muiTargetValue)
            end
        end
    end
    return true
end

function M.actionForRadioButton( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        -- uncheck all then check the one that is checked
        local basename = M.getEventParameter(e, "basename")
        local foundName = false

        local list = muiData.widgetDict[basename]["radio"]
        for k, v in pairs(list) do
            v["myText"].isChecked = false
            v["myText"].text = M.getMaterialFontCodePointByName("radio_button_unchecked")
        end

        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = M.getMaterialFontCodePointByName("radio_button_unchecked")
         else
            muiTarget.isChecked = true
            muiTarget.text = M.getMaterialFontCodePointByName("radio_button_checked")
        end
        if muiTargetValue ~= nil then
            muiData.widgetDict[basename]["value"] = muiTargetValue
            M.debug("radio button value = "..muiTargetValue)
        end
    end
    return true
end

function M.actionForButton( e )
    M.debug("button action!")
    return true
end

function M.removeWidgetRRectButton(widgetName)
    M.removeRoundedRectButton(widgetName)
end

function M.removeRoundedRectButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", M.touchRRectButton)
    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("tap", M.touchRRectButton)
    muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
    muiData.widgetDict[widgetName]["myCircle"] = nil
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil

    if muiData.widgetDict[widgetName]["myIconText"] ~= nil then
        muiData.widgetDict[widgetName]["myIconText"]:removeSelf()
        muiData.widgetDict[widgetName]["myIconText"] = nil
    end

    if muiData.widgetDict[widgetName]["myImage"] ~= nil then
        muiData.widgetDict[widgetName]["myImage"]:removeSelf()
        muiData.widgetDict[widgetName]["myImage"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["myImageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["myImageTouch"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["myImageSheet"] = nil
    end

    if muiData.widgetDict[widgetName]["shadow"] ~= nil then
        if muiData.shadowShapeDict[widgetName] ~= nil then
            muiData.shadowShapeDict[widgetName]["snapshot"]:removeSelf()
            muiData.shadowShapeDict[widgetName]["snapshot"] = nil
            muiData.shadowShapeDict[widgetName] = nil
        end
        muiData.widgetDict[widgetName]["shadow"]:removeSelf()
        muiData.widgetDict[widgetName]["shadow"] = nil
    end

    muiData.widgetDict[widgetName]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect"] = nil
    muiData.widgetDict[widgetName]["rrect2"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect2"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetRectButton(widgetName)
    M.removeRectButton(widgetName)
end

function M.removeRectButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", M.touchRRectButton)
    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("tap", M.touchRRectButton)
    muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
    muiData.widgetDict[widgetName]["myCircle"] = nil
    if muiData.widgetDict[widgetName]["myIconText"] ~= nil then
        muiData.widgetDict[widgetName]["myIconText"]:removeSelf()
        muiData.widgetDict[widgetName]["myIconText"] = nil
    end
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    if muiData.widgetDict[widgetName]["myImage"] ~= nil then
        muiData.widgetDict[widgetName]["myImage"]:removeSelf()
        muiData.widgetDict[widgetName]["myImage"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["myImageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["myImageTouch"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["myImageSheet"] = nil
    end

    if muiData.widgetDict[widgetName]["shadow"] ~= nil then
        if muiData.shadowShapeDict[widgetName] ~= nil then
            muiData.shadowShapeDict[widgetName]["snapshot"]:removeSelf()
            muiData.shadowShapeDict[widgetName]["snapshot"] = nil
            muiData.shadowShapeDict[widgetName] = nil
        end
        muiData.widgetDict[widgetName]["shadow"]:removeSelf()
        muiData.widgetDict[widgetName]["shadow"] = nil
    end

    muiData.widgetDict[widgetName]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetCircleButton(widgetName)
    M.removeCircleButton(widgetName)
end

function M.removeCircleButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["circlemain"]:removeEventListener("touch", M.touchCircleButton)
    muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
    muiData.widgetDict[widgetName]["myCircle"] = nil
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    if muiData.widgetDict[widgetName]["myImage"] ~= nil then
        muiData.widgetDict[widgetName]["myImage"]:removeSelf()
        muiData.widgetDict[widgetName]["myImage"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["myImageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["myImageTouch"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["myImageSheet"] = nil
    end

    if muiData.widgetDict[widgetName]["shadow"] ~= nil then
        if muiData.shadowShapeDict[widgetName] ~= nil then
            muiData.shadowShapeDict[widgetName]["snapshot"]:removeSelf()
            muiData.shadowShapeDict[widgetName]["snapshot"] = nil
            muiData.shadowShapeDict[widgetName] = nil
        end
        muiData.widgetDict[widgetName]["shadow"]:removeSelf()
        muiData.widgetDict[widgetName]["shadow"] = nil
    end

    muiData.widgetDict[widgetName]["circlemain"]:removeSelf()
    muiData.widgetDict[widgetName]["circlemain"] = nil
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetIconButton(widgetName)
    M.removeIconButton(widgetName)
end

function M.removeCheckBox(widgetName)
    M.removeIconButton(widgetName)
end

function M.removeIconButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["myText"]:removeEventListener("touch", M.touchIconButton)
    muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
    muiData.widgetDict[widgetName]["myCircle"] = nil
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    if muiData.widgetDict[widgetName]["myImage"] ~= nil then
        muiData.widgetDict[widgetName]["myImage"]:removeSelf()
        muiData.widgetDict[widgetName]["myImage"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["myImageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["myImageTouch"] = nil
    end

    if muiData.widgetDict[widgetName]["myImageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["myImageSheet"] = nil
    end
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetRadioButton(widgetName)
    M.removeRadioButton(widgetName)
end

function M.removeRadioButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    for name in pairs(muiData.widgetDict[widgetName]["radio"]) do
        muiData.widgetDict[widgetName]["radio"][name]["myText"]:removeEventListener( "touch", M.touchCheckbox )
        muiData.widgetDict[widgetName]["radio"][name]["myLabel"]:removeEventListener( "touch", M.touchCheckbox )
        muiData.widgetDict[widgetName]["radio"][name]["myText"]:removeEventListener( "tap", M.touchCheckbox )
        muiData.widgetDict[widgetName]["radio"][name]["myLabel"]:removeEventListener( "tap", M.touchCheckbox )
        muiData.widgetDict[widgetName]["radio"][name]["myCircle"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["myCircle"] = nil
        muiData.widgetDict[widgetName]["radio"][name]["myText"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["myText"] = nil
        muiData.widgetDict[widgetName]["radio"][name]["myLabel"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["myLabel"] = nil
        muiData.widgetDict[widgetName]["radio"][name]["mygroup"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["mygroup"] = nil
        muiData.widgetDict[widgetName]["radio"][name] = nil
    end
end

return M
