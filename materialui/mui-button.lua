--[[
A loosely based Material UI module

mui-button.lua : This is for creating buttons.

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

function M.activateImageTouch(options)
    if muiData.widgetDict[options.name] == nil then return end
    if options.state.image ~= nil and options.state.image.touchFadeAnimation ~= nil and options.state.image.touchFadeAnimation == false then
        return
    end
    if muiData.widgetDict[options.name]["imageTouch"] ~= nil and muiData.widgetDict[options.name]["imageTouchIndex"] ~= nil then
        muiData.widgetDict[options.name]["imageTouch"].alpha = 1
        muiData.widgetDict[options.name]["imageTouch"].isVisible = true
        muiData.widgetDict[options.name]["image"].isVisible = false
    end
end

function M.deactivateImageTouch(options)
    if muiData.widgetDict[options.name] == nil then return end
    if options.state.image ~= nil and options.state.image.touchFadeAnimation ~= nil and options.state.image.touchFadeAnimation == false then
        return
    end
    if muiData.widgetDict[options.name]["imageTouch"] ~= nil and muiData.widgetDict[options.name]["imageTouchIndex"] ~= nil then
        muiData.widgetDict[options.name]["image"].isVisible = true
        if muiData.widgetDict[options.name]["imageTouchFadeAnim"] == true then
            local speed = muiData.widgetDict[options.name]["imageTouchFadeAnimSpeed"]
            transition.fadeOut(muiData.widgetDict[options.name]["imageTouch"],{time=speed})
            transition.fadeIn(muiData.widgetDict[options.name]["image"],{time=50})
        else
            muiData.widgetDict[options.name]["imageTouch"].isVisible = false
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

    options.iconAlign = options.iconAlign or "left"

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

    if options.state == nil then options.state = {} end

    if options.state.image == nil and options.useShadow == true then
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
    if options.state.image == nil and options.gradientShadowColor1 ~= nil and options.gradientShadowColor2 ~= nil then
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
    local fillColor = { 0, 0.82, 1 }
    if options.state.image == nil then
        if paint ~= nil then
            muiData.widgetDict[options.name]["rrect2"].fill = paint
        else
            muiData.widgetDict[options.name]["rrect2"].isVisible = false
        end
        if options.state.off ~= nil and options.state.off.fillColor ~= nil and paint == nil then
            fillColor = options.state.off.fillColor
        end
    end
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect2"] )

    if options.strokeWidth == nil then
        options.strokeWidth = 0
    end

    muiData.widgetDict[options.name]["rrect"] = display.newRoundedRect( 0, 0, options.width, options.height, radius )
    if options.state.image == nil then
        if options.strokeWidth > 0 then
            muiData.widgetDict[options.name]["rrect"].strokeWidth = options.strokeWidth or 1
            muiData.widgetDict[options.name]["rrect"]:setStrokeColor( unpack(options.strokeColor) )
        end
        muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    end
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )
    muiData.widgetDict[options.name]["rrect"].dialogName = options.dialogName
    print("contentWidth for rrect "..muiData.widgetDict[options.name]["rrect"].contentWidth)

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
    if options.state.off ~= nil and options.state.off.textColor ~= nil then
        textColor = options.state.off.textColor
    end

    options.ignoreTap = options.ignoreTap or false

    -- create image buttons if exist
    M.createButtonsFromList({ name=options.name, image=options.state.image }, rrect, "container")

    muiData.widgetDict[options.name]["clickAnimation"] = options.clickAnimation

    muiData.widgetDict[options.name]["font"] = font
    muiData.widgetDict[options.name]["fontSize"] = fontSize
    muiData.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = fontSize * ( ( rrect.contentHeight - textMargin ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    local tw, th = textToMeasure.contentWidth, textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil

    if options.state.off ~= nil and options.state.off.svg ~= nil and type(options.state.off.svg) == "table" and options.state.image == nil then
       local params = {
            {
                name = "iconText",
                svgName = options.name.."SvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "iconTextOn",
                svgName = options.name.."SvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "iconTextDisabled",
                svgName = options.name.."SvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(params) do
            if options.state[v.state] ~= nil and options.state[v.state].svg ~= nil then
                muiData.widgetDict[options.name][v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.state[v.state].svg.path,
                        width = fontSize,
                        height = fontSize,
                        fillColor = options.state[v.state].svg.fillColor,
                        strokeWidth = options.state[v.state].svg.strokeWidth or 1,
                        strokeColor = options.state[v.state].svg.textColor or options.state[v.state].textColor,
                        y = 0,
                        x = 0,
                    })
                muiData.widgetDict[options.name][v.name].isVisible = v.isVisible
                muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name][v.name], false )
            end
        end
    elseif options.state.off ~= nil and options.state.off.iconImage ~= nil and options.state.image == nil then
        muiData.widgetDict[options.name]["iconText"] = display.newImageRect( options.state.off.iconImage, options.width, options.height )
        if muiData.widgetDict[options.name]["iconText"] ~= nil then
            muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["iconText"], false )
        end
        if options.state.on.iconImage ~= nil then
            muiData.widgetDict[options.name]["iconTextOn"] = display.newImageRect( options.state.on.iconImage, options.width, options.height )
            if muiData.widgetDict[options.name]["iconTextOn"] ~= nil then
                muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["iconTextOn"], false )
                muiData.widgetDict[options.name]["iconTextOn"].isVisible = false
            end
        end
    elseif options.iconText ~= nil and options.iconFont ~= nil and options.state.image == nil then
        if M.isMaterialFont(options.iconFont) == true then
            options.iconText = M.getMaterialFontCodePointByName(options.iconText)
        end
        muiData.widgetDict[options.name]["iconText"] = display.newText( options.iconText, 0, 0, options.iconFont, fontSize )
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["iconText"], false )

        if options.state.on ~= nil and options.state.on.iconImage ~= nil then
            muiData.widgetDict[options.name]["iconTextOn"] = display.newText( options.iconText, 0, 0, options.iconFont, fontSize )
            muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["iconTextOn"], false )
            muiData.widgetDict[options.name]["iconTextOn"].isVisible = false
        end
    end

    textXOffset = 0
    if muiData.widgetDict[options.name]["iconText"] ~= nil then
        if options.iconAlign == "left" then
            textXOffset = fontSize * 0.55
        else
            textXOffset = -(fontSize * 0.55)
        end
    end

    if options.state.image == nil then
        muiData.widgetDict[options.name]["text"] = display.newText( options.text, textXOffset, 0, font, fontSize )
        muiData.widgetDict[options.name]["text"]:setFillColor( unpack(textColor) )
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["text"], false )
    end

    if muiData.widgetDict[options.name]["iconText"] ~= nil and options.state.image == nil then
        local width = muiData.widgetDict[options.name]["text"].contentWidth * 0.55
        if options.iconAlign == "left" then
            muiData.widgetDict[options.name]["iconText"].x = -(width)
        else
            muiData.widgetDict[options.name]["iconText"].x = width
        end
        if muiData.widgetDict[options.name]["iconTextOn"] ~= nil then
            muiData.widgetDict[options.name]["iconTextOn"].x = muiData.widgetDict[options.name]["iconText"].x
        end
        if muiData.widgetDict[options.name]["iconTextDisabled"] ~= nil then
            muiData.widgetDict[options.name]["iconTextDisabled"].x = muiData.widgetDict[options.name]["iconText"].x
        end
    end

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end
    circleColor = {0.88,0.88,0.88,1}

    local maxWidth = muiData.widgetDict[options.name]["rrect"].path.width - (radius * 2)

    muiData.widgetDict[options.name]["circle"] = display.newCircle( options.height, options.height, options.height * 0.5)
    muiData.widgetDict[options.name]["circle"]:setFillColor( unpack(circleColor) )
    muiData.widgetDict[options.name]["circle"].isVisible = false
    muiData.widgetDict[options.name]["circle"].alpha = 0.3
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["circle"], true ) -- insert and center bkgd

    --if muiData.widgetDict[options.name]["image"] ~= nil then
    -- muiData.widgetDict[options.name]["rrect"].alpha = 0.01
    --end

    rrect.muiOptions = options
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.touchRRectButton )
    if options.ignoreTap then
        muiData.widgetDict[options.name]["rrect"]:addEventListener("tap", function() return true end)
    end

    if options.state.value == "off" then
        M.turnOffButton( options )
    elseif options.state.value == "on" then
        M.turnOnButton( options )
    elseif options.state.value == "disabled" then
        M.disableButton( options )
    end
end

function M.getRoundedRectButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["text"] -- button text
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rrect2"] -- button shadow
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["rrect"] -- button face
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["image"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["imageTouch"]
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

    if muiData.currentControl == nil then
        muiData.currentControl = options.name
        muiData.currentControlType = "mui-button"
    end

    if M.disableButton( options, event ) then
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
        return
    end

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

        M.turnOnButton( options )

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
                muiData.widgetDict[options.name]["circle"].x = event.x - muiData.widgetDict[options.name]["container"].x
                muiData.widgetDict[options.name]["circle"].y = event.y - muiData.widgetDict[options.name]["container"].y
            end
            muiData.widgetDict[options.name]["circle"].isVisible = true
            local scaleFactor = 0.1
            muiData.widgetDict[options.name].circleTrans = transition.from( muiData.widgetDict[options.name]["circle"], { time=500,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(muiData.widgetDict[options.name]["container"],{time=300, xScale=1.02, yScale=1.02, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then

        M.removeEventFromQueue( options.name ) -- cancel and remove from queue
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
        M.turnOffButton( options )
        muiData.interceptEventHandler = nil
        muiData.interceptOptions = nil
        muiData.interceptMoved = false
        muiData.touching = false
        M.processEventQueue()
    else
        M.addToEventQueue( options )
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

    options.iconAlign = options.iconAlign or "left"

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
    if options.state.off.fillColor ~= nil then
        fillColor = options.state.off.fillColor
    end

    local strokeWidth = 0
    if paint ~= nil then strokeWidth = 1 end

    if options.useShadow == true and options.state.image == nil then
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
    if options.state.image == nil then
        if paint ~= nil then
            muiData.widgetDict[options.name]["rrect"].fill = paint
        end
        if options.strokeWidth ~= nil and options.strokeWidth > 0 then
            muiData.widgetDict[options.name]["rrect"].strokeWidth = options.strokeWidth or 1
            muiData.widgetDict[options.name]["rrect"]:setStrokeColor( unpack(options.strokeColor) )
        end
        muiData.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    end
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rrect"] )
    local rrect = muiData.widgetDict[options.name]["rrect"]

    -- create image buttons if exist
    M.createButtonsFromList({ name=options.name, image=options.state.image }, rrect, "container")

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
    if options.state.off.textColor ~= nil then
        textColor = options.state.off.textColor
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

    if options.state.off.svg ~= nil and type(options.state.off.svg) == "table" and options.state.image == nil then
       local params = {
            {
                name = "iconText",
                svgName = options.name.."SvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "iconTextOn",
                svgName = options.name.."SvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "iconTextDisabled",
                svgName = options.name.."SvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(params) do
            if options.state[v.state] ~= nil and options.state[v.state].svg ~= nil then
                muiData.widgetDict[options.name][v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.state[v.state].svg.path,
                        width = fontSize,
                        height = fontSize,
                        fillColor = options.state[v.state].svg.fillColor,
                        strokeWidth = options.state[v.state].svg.strokeWidth or 1,
                        strokeColor = options.state[v.state].svg.textColor or options.state[v.state].textColor,
                        y = 0,
                        x = 0,
                    })
                muiData.widgetDict[options.name][v.name].isVisible = v.isVisible
                muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name][v.name], false )
            end
        end
    elseif options.state.off.iconImage ~= nil and options.state.image == nil then
        muiData.widgetDict[options.name]["iconText"] = display.newImageRect( options.state.off.iconImage, fontSize, fontSize )
        if muiData.widgetDict[options.name]["iconText"] ~= nil then
            muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["iconText"], false )
        end
        if options.state.on.iconImage ~= nil then
            muiData.widgetDict[options.name]["iconTextOn"] = display.newImageRect( options.state.on.iconImage, fontSize, fontSize )
            if muiData.widgetDict[options.name]["iconTextOn"] ~= nil then
                muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["iconTextOn"], false )
                muiData.widgetDict[options.name]["iconTextOn"].isVisible = false
            end
        end
    elseif options.state.off.iconText ~= nil and options.iconFont ~= nil and options.state.image == nil then
        if M.isMaterialFont(options.iconFont) == true then
            options.iconText = M.getMaterialFontCodePointByName(options.state.off.iconText)
        end
        muiData.widgetDict[options.name]["iconText"] = display.newText( options.state.off.iconText, 0, 0, options.iconFont, fontSize )
        if options.state.off.iconFontColor ~= nil then
            muiData.widgetDict[options.name]["iconText"]:setFillColor( unpack(options.state.off.iconFontColor) )
        end
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["iconText"], false )
    end

    textXOffset = 0
    if muiData.widgetDict[options.name]["iconText"] ~= nil then
        if options.iconAlign == "left" then
            textXOffset = fontSize * 0.55
        else
            textXOffset = -(fontSize * 0.55)
        end
    end

    if options.state.image == nil then
        muiData.widgetDict[options.name]["text"] = display.newText( options.text, textXOffset, 0, font, fontSize )
        muiData.widgetDict[options.name]["text"]:setFillColor( unpack(textColor) )
        muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["text"], false )
    end

    if muiData.widgetDict[options.name]["iconText"] ~= nil and options.state.image == nil then
        local width = muiData.widgetDict[options.name]["text"].contentWidth * 0.55
        if options.iconAlign == "left" then
            muiData.widgetDict[options.name]["iconText"].x = -(width)
        else
            muiData.widgetDict[options.name]["iconText"].x = width
        end
        if muiData.widgetDict[options.name]["iconTextOn"] ~= nil then
            muiData.widgetDict[options.name]["iconTextOn"].x = muiData.widgetDict[options.name]["iconText"].x
        end
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

    muiData.widgetDict[options.name]["circle"] = display.newCircle( options.height, options.height, maxWidth )
    muiData.widgetDict[options.name]["circle"]:setFillColor( unpack(circleColor) )
    muiData.widgetDict[options.name]["circle"].isVisible = false
    muiData.widgetDict[options.name]["circle"].alpha = 0.3
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["circle"], true ) -- insert and center bkgd

    rrect.muiOptions = options
    muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.touchRRectButton )
    options.ignoreTap = options.ignoreTap or false
    if options.ignoreTap then
        muiData.widgetDict[options.name]["rrect"]:addEventListener("tap", function() return true end)
    end

    if options.state.value == "off" then
        M.turnOffButton( options )
    elseif options.state.value == "on" then
        M.turnOnButton( options )
    elseif options.state.value == "disabled" then
        M.disableButton( options )
    end
end

function M.getRectButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["text"] -- button text
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rrect"] -- button face
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["image"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["imageTouch"]
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
    muiData.widgetDict[options.name]["group"] = display.newGroup()
    muiData.widgetDict[options.name]["group"].x = x
    muiData.widgetDict[options.name]["group"].y = y
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["group"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["group"] )
    end

    local radius = options.height
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
    if options.state.off.textColor ~= nil then
        textColor = options.state.off.textColor
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

    if options.svg ~= nil or options.state.image ~= nil then
        tw = textToMeasure.contentWidth
        th = textToMeasure.contentHeight
    end

    textToMeasure:removeSelf()
    textToMeasure = nil

    -- create image buttons if exist
    if options.state.image ~= nil then
        muiData.widgetDict[options.name]["rrect"] = display.newRect( 0, 0, options.width, options.height )
        muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["rrect"] )
        options.image = options.state.image
        M.createButtonsFromList(options, muiData.widgetDict[options.name]["rrect"], "group")
    end

    if options.state.off.svg == nil and options.state.image == nil then
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

        muiData.widgetDict[options.name]["text"] = display.newText( options2 )
        muiData.widgetDict[options.name]["text"]:setFillColor( unpack(options.state.off.textColor) )
        muiData.widgetDict[options.name]["text"].isVisible = true

        if isChecked then
            muiData.widgetDict[options.name]["text"].isChecked = isChecked
        end
    elseif options.state.off.svg ~= nil and type(options.state.off.svg) == "table" and options.state.image == nil then
       local params = {
            {
                name = "text",
                svgName = options.name.."SvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "textOn",
                svgName = options.name.."SvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "textDisabled",
                svgName = options.name.."SvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(params) do
            if options.state[v.state] ~= nil and options.state[v.state].svg ~= nil then
                muiData.widgetDict[options.name][v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.state[v.state].svg.path,
                        width = tw,
                        height = th,
                        fillColor = options.state[v.state].svg.fillColor,
                        strokeWidth = options.state[v.state].svg.strokeWidth or 1,
                        strokeColor = options.state[v.state].svg.textColor or options.state[v.state].textColor,
                        x = 0,
                        y = 0,
                    })
                muiData.widgetDict[options.name][v.name].isVisible = v.isVisible
                muiData.widgetDict[options.name].isChecked = isChecked
                if isChecked and v.state == "on" then
                    muiData.widgetDict[options.name]["text"].isVisible = false
                    muiData.widgetDict[options.name]["textOn"].isVisible = true
                end
            end
        end
    end
    muiData.widgetDict[options.name]["value"] = isChecked

    if options.state.image == nil then
        muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["text"], true )
        if muiData.widgetDict[options.name]["textOn"] ~= nil then
            muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["textOn"], true )
        end
        if muiData.widgetDict[options.name]["textDisabled"] ~= nil then
            muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["textDisabled"], true )
        end

        checkbox = muiData.widgetDict[options.name]["text"]
        checkbox.muiOptions = options
    end

    local radiusOffset = 2.5
    if muiData.masterRatio > 1 then radiusOffset = 2.0 end
    local maxWidth = tw * 0.6

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    muiData.widgetDict[options.name]["circle"] = display.newCircle( 0, 0, maxWidth + 5)
    muiData.widgetDict[options.name]["circle"]:setFillColor( unpack(circleColor) )

    muiData.widgetDict[options.name]["circle"].isVisible = false
    muiData.widgetDict[options.name]["circle"].x = 0
    muiData.widgetDict[options.name]["circle"].y = 0
    muiData.widgetDict[options.name]["circle"].alpha = 0.3
    muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["circle"], true ) -- insert and center bkgd

    if options.state.image == nil then
        muiData.widgetDict[options.name]["text"]:addEventListener( "touch", M.touchIconButton )
        if muiData.widgetDict[options.name]["textOn"] ~= nil then
            muiData.widgetDict[options.name]["textOn"]:addEventListener( "touch", M.touchIconButton )
            muiData.widgetDict[options.name]["textOn"].muiOptions = options
        end
        if muiData.widgetDict[options.name]["textDisabled"] ~= nil then
            muiData.widgetDict[options.name]["textDisabled"]:addEventListener( "touch", M.touchIconButton )
            muiData.widgetDict[options.name]["textDisabled"].muiOptions = options
        end
        options.ignoreTap = options.ignoreTap or false
        if options.ignoreTap then
            muiData.widgetDict[options.name]["text"]:addEventListener("tap", function() return true end)
            if muiData.widgetDict[options.name]["textOn"] ~= nil then
                muiData.widgetDict[options.name]["textOn"]:addEventListener("tap", function() return true end)
            end
            if muiData.widgetDict[options.name]["textDisabled"] ~= nil then
                muiData.widgetDict[options.name]["textDisabled"]:addEventListener("tap", function() return true end)
            end
        end
    elseif options.state.image ~= nil then
        muiData.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.touchIconButton )
        options.ignoreTap = options.ignoreTap or false
        if options.ignoreTap then
            muiData.widgetDict[options.name]["rrect"]:addEventListener("tap", function() return true end)
        end
        muiData.widgetDict[options.name]["rrect"].muiOptions = options
    end
    if options.state.value == "off" then
        M.turnOffButton( options )
    elseif options.state.value == "on" then
        M.turnOnButton( options )
    elseif options.state.value == "disabled" then
        M.disableButton( options )
    end
end

function M.resizeIconButton(options)
    if options == nil then return end
    local obj = muiData.widgetDict[options.name]["text"]
    obj.size = options.size
end

function M.getIconButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["group"] -- x,y movement
    elseif propertyName == "icon" then
        data = muiData.widgetDict[widgetName]["text"] -- button
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["image"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["imageTouch"]
    end
    return data
end

function M.touchIconButton (event)
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if muiData.currentControl == nil then
        muiData.currentControl = options.name
        muiData.currentControlType = "mui-button"
    end

    if M.disableButton( options, event ) then
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
        return
    end

    if muiData.currentControl ~= nil and muiData.currentControl ~= options.name then
        return
    end
    if muiData.dialogInUse == true and options.dialogName == nil then return end

    M.addBaseEventParameters(event, options)

    if event.phase == "began" or event.phase == "ended" then
        M.setEventParameter(event, "muiTargetName", options.name)
        M.setEventParameter(event, "muiTargetValue", options.value)
        M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.name]["text"])
        M.setEventParameter(event, "muiTargetCallBackData", options.state["off"].callBackData)
    end

    if ( event.phase == "began" ) then
        muiData.currentControl = options.name
        muiData.interceptEventHandler = M.touchIconButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)

        M.turnOnButton( options, event )

        if muiData.touching == false then
            muiData.touching = true
            M.activateImageTouch( options )
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.name]["circle"].x = event.x - muiData.widgetDict[options.name]["group"].x
                muiData.widgetDict[options.name]["circle"].y = event.y - muiData.widgetDict[options.name]["group"].y
            end
            muiData.widgetDict[options.name]["circle"].isVisible = true
            local scaleFactor = 0.1
            muiData.widgetDict[options.name].circleTrans = transition.from( muiData.widgetDict[options.name]["circle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(event.target,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then
        M.removeEventFromQueue( options.name ) -- cancel and remove from queue
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- M.debug("Its out of the button area")
        else
            event.phase = "onTarget"
            if muiData.interceptMoved == false then
                event.target = muiData.widgetDict[options.name]["checkbox"]
                event.altTarget = muiData.widgetDict[options.name]["text"]
                event.myTargetName = options.name

                muiData.widgetDict[options.name]["value"] = options.value

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
        M.turnOffButton( options, event )

        if options.isCheckBox ~= nil and options.isCheckBox == true then
            if muiData.widgetDict[options.name].isChecked ~= nil and muiData.widgetDict[options.name].isChecked == true then
                M.turnOnButton( options, event )
            elseif muiData.widgetDict[options.name].isChecked == nil and options.state.value == "on" then
                M.turnOnButton( options, event )
            end
        end

        muiData.currentControl = nil
        M.processEventQueue()
    else
        M.addToEventQueue( options )
    end
    muiData.touched = true
    return true
end

function M.getOptionsForButton( name, basename )
    if name == nil then return end
    local options = nil

    if muiData.widgetDict[basename] ~= nil and muiData.widgetDict[basename]["radio"] ~= nil then
        options = muiData.widgetDict[basename]["radio"][name]["text"].muiOptions
    elseif muiData.widgetDict[name] ~= nil and muiData.widgetDict[name]["type"] == "IconButton" then
        if muiData.widgetDict[name]["text"] ~= nil then
            options = muiData.widgetDict[name]["text"].muiOptions
        elseif muiData.widgetDict[name]["rrect"] ~= nil then
            options = muiData.widgetDict[name]["rrect"].muiOptions
        end
    elseif muiData.widgetDict[name] ~= nil and (muiData.widgetDict[name]["type"] == "RRectButton" or muiData.widgetDict[name]["type"] == "RectButton") then
        options = muiData.widgetDict[name]["rrect"].muiOptions
    elseif muiData.widgetDict[name] ~= nil and muiData.widgetDict[name]["type"] == "CircleButton" then
        options = muiData.widgetDict[name]["circlemain"].muiOptions
    end

    return options
end

function M.disableButton( options, event )
    M.debug("M.disableButton()")
    local val = false
    if options == nil then return val end
    if options.state.value ~= "disabled" then return val end

    if options.state.image ~= nil and options.state.image.touchFadeAnimation == true then
        return
    end

    val = true

    if muiData.widgetDict[options.basename] ~= nil and muiData.widgetDict[options.basename]["type"] == "RadioButton" then
        -- change color
        if options.state.image == nil and options.state.disabled.labelColor ~= nil and options.state.disabled.textColor ~= nil then
            M.setGroupObjectFillColor(options.basename, "radio", options.name, "text", options.state.disabled.textColor)
            M.setGroupObjectFillColor(options.basename, "radio", options.name, "label", options.state.disabled.labelColor)
        end

        -- change icon
        if muiData.widgetDict[options.basename]["radio"][options.name].iconTextDisabled ~= nil then
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconText", false)
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconTextOn", false)
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconTextDisabled", true)
        end

        -- change image
        if muiData.widgetDict[options.basename]["image"] ~= nil and muiData.widgetDict[options.basename]["imageTouch"] ~= nil then
            M.setObjectVisible(options.basename, "image", false)
            M.setObjectVisible(options.basename, "imageTouch", false)
            M.setObjectVisible(options.basename, "imageDisabled", true)
        end
        muiData.widgetDict[options.basename].disabled = true
        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    end

    if muiData.widgetDict[options.name] == nil then return val end

    muiData.widgetDict[options.name].disabled = true

    if muiData.widgetDict[options.name]["type"] == "IconButton" then
        -- change color
        if options.state.image == nil and options.state.off.svg == nil and options.state.disabled.textColor ~= nil then
            M.setObjectFillColor(options.name, "text", options.state.disabled.textColor)
        end

        -- change icon
        if muiData.widgetDict[options.name].textDisabled ~= nil then
            M.setObjectVisible(options.name, "text", false)
            M.setObjectVisible(options.name, "textOn", false)
            M.setObjectVisible(options.name, "textDisabled", true)
            M.setObjectFillColor(options.name, "text", options.state.disabled.textColor)
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", false)
            M.setObjectVisible(options.name, "imageTouch", false)
            M.setObjectVisible(options.name, "imageDisabled", true)
        end

    elseif muiData.widgetDict[options.name]["type"] == "RRectButton" or muiData.widgetDict[options.name]["type"] == "RectButton" then
        -- change color
        if options.state.image == nil and options.state.disabled.fillColor ~= nil and options.state.disabled.textColor ~= nil then
            M.setObjectFillColor(options.name, "rrect", options.state.disabled.fillColor)
            M.setObjectFillColor(options.name, "text", options.state.disabled.textColor)
            M.setObjectFillColor(options.name, "iconText", options.state.disabled.iconFontColor)
        end

        -- change icon
        if muiData.widgetDict[options.name].iconTextDisabled ~= nil then
            M.setObjectVisible(options.name, "iconText", false)
            M.setObjectVisible(options.name, "iconTextOn", false)
            M.setObjectVisible(options.name, "iconTextDisabled", true)
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", false)
            M.setObjectVisible(options.name, "imageTouch", false)
            M.setObjectVisible(options.name, "imageDisabled", true)
        end

    elseif muiData.widgetDict[options.name]["type"] == "CircleButton" then
        -- change color
        if options.state.image == nil and options.state.disabled.fillColor ~= nil and options.state.disabled.textColor ~= nil then
            M.setObjectFillColor(options.name, "circlemain", options.state.disabled.fillColor)
            M.setObjectFillColor(options.name, "text", options.state.disabled.textColor)
        end

        -- change icon
        if muiData.widgetDict[options.name].textDisabled ~= nil and options.state.image == nil then
            M.setObjectVisible(options.name, "text", false)
            M.setObjectVisible(options.name, "textOn", false)
            M.setObjectVisible(options.name, "textDisabled", true)
            M.setObjectFillColor(options.name, "circlemain", options.state.disabled.svg.fillColor)
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", false)
            M.setObjectVisible(options.name, "imageTouch", false)
            M.setObjectVisible(options.name, "imageDisabled", true)
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
function M.turnOnButtonByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForButton(name, basename)

    if options ~= nil then
        M.turnOnButton( options )
    end
end

function M.turnOnButton( options, event )
    -- body
    M.debug("M.turnOnButton()")

    if options.state.image ~= nil and options.state.image.touchFadeAnimation == true then
        return
    end

    options.state.value = "on"
    if event ~= nil then
        if options.state.on.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.state.on.callBackData)
            assert( options.state.on.callBack )(event)
        end
    end

    if muiData.widgetDict[options.basename] ~= nil and muiData.widgetDict[options.basename]["type"] == "RadioButton" then
        -- change color
        if options.state.image == nil and options.state.on.labelColor ~= nil and options.state.on.textColor ~= nil then
            M.setGroupObjectFillColor(options.basename, "radio", options.name, "text", options.state.on.textColor)
            M.setGroupObjectFillColor(options.basename, "radio", options.name, "label", options.state.on.labelColor)
        end

        -- change icon
        if muiData.widgetDict[options.basename]["radio"][options.name].iconTextOn ~= nil then
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconText", false)
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconTextOn", true)
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconTextDisabled", false)
        end

        -- change image
        if muiData.widgetDict[options.basename]["image"] ~= nil and muiData.widgetDict[options.basename]["imageTouch"] ~= nil then
            M.setObjectVisible(options.basename, "image", false)
            M.setObjectVisible(options.basename, "imageDisabled", false)
            M.setObjectVisible(options.basename, "imageTouch", true)
        end
    end

    if muiData.widgetDict[options.name] == nil then return end

    if muiData.widgetDict[options.name]["type"] == "IconButton" then

        -- change color
        if options.state.image == nil and options.state.off.svg == nil and options.state.on.textColor ~= nil then
            M.setObjectFillColor(options.name, "text", options.state.on.textColor)
        end

        -- change icon
        if muiData.widgetDict[options.name].textOn ~= nil then
            muiData.widgetDict[options.name].text.isVisible = false
            muiData.widgetDict[options.name].textOn.isVisible = true
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", false)
            M.setObjectVisible(options.name, "imageDisabled", false)
            M.setObjectVisible(options.name, "imageTouch", true)
        end

    elseif muiData.widgetDict[options.name]["type"] == "RRectButton" or muiData.widgetDict[options.name]["type"] == "RectButton" then
        -- change color
        if options.state.image == nil and options.state.on.fillColor ~= nil and options.state.on.textColor ~= nil then
            M.setObjectFillColor(options.name, "rrect", options.state.on.fillColor)
            M.setObjectFillColor(options.name, "text", options.state.on.textColor)
            M.setObjectFillColor(options.name, "iconText", options.state.on.iconFontColor)
        end

        -- change icon
        if muiData.widgetDict[options.name].iconTextOn ~= nil then
            muiData.widgetDict[options.name].iconText.isVisible = false
            muiData.widgetDict[options.name].iconTextOn.isVisible = true
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", false)
            M.setObjectVisible(options.name, "imageDisabled", false)
            M.setObjectVisible(options.name, "imageTouch", true)
        end
    elseif muiData.widgetDict[options.name]["type"] == "CircleButton" then
        -- change color
        if muiData.widgetDict[options.name].textOn == nil and options.state.image == nil and options.state.on.fillColor ~= nil and options.state.on.textColor ~= nil then
            M.setObjectFillColor(options.name, "circlemain", options.state.on.fillColor)
            M.setObjectFillColor(options.name, "text", options.state.on.textColor)
        end

        -- change icon
        if muiData.widgetDict[options.name].textOn ~= nil then
            muiData.widgetDict[options.name].text.isVisible = false
            muiData.widgetDict[options.name].textOn.isVisible = true
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", false)
            M.setObjectVisible(options.name, "imageDisabled", false)
            M.setObjectVisible(options.name, "imageTouch", true)
        end
    end
end

-- params...
-- name: name of button
-- basename: only required if RadioButton
function M.turnOffButtonByName( name, basename )
    if name == nil then return end
    local options = M.getOptionsForButton(name, basename)

    if options ~= nil then
        print("final???")
        M.turnOffButton( options )
    end
end

function M.turnOffButton( options, event )
    -- body
    M.debug("M.turnOffButton()")

    if options.state.image ~= nil and options.state.image.touchFadeAnimation == true then
        return
    end

    options.state.value = "off"
    if event ~= nil then
        if options.state.off.callBack ~= nil then
            M.setEventParameter(event, "muiTargetCallBackData", options.state.off.callBackData)
            assert( options.state.off.callBack )(event)
        end
    end

    if muiData.widgetDict[options.basename] ~= nil and muiData.widgetDict[options.basename]["type"] == "RadioButton" then
        -- change color
        if options.state.image == nil and options.state.on.labelColor ~= nil and options.state.on.textColor ~= nil then
            M.setGroupObjectFillColor(options.basename, "radio", options.name, "text", options.state.off.textColor)
            M.setGroupObjectFillColor(options.basename, "radio", options.name, "label", options.state.off.labelColor)
        end

        -- change icon
        if muiData.widgetDict[options.basename]["radio"][options.name].iconTextOn ~= nil then
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconText", true)
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconTextOn", false)
            M.setGroupObjectVisible(options.basename, "radio", options.name, "iconTextDisabled", false)
        end

        -- change image
        if muiData.widgetDict[options.basename]["image"] ~= nil and muiData.widgetDict[options.basename]["imageTouch"] ~= nil then
            M.setObjectVisible(options.basename, "image", true)
            M.setObjectVisible(options.basename, "imageDisabled", false)
            M.setObjectVisible(options.basename, "imageTouch", false)
        end

        if muiData.currentControl == options.basename then
            M.resetCurrentControlVars()
        end
    end

    if muiData.widgetDict[options.name] == nil then return end

    if muiData.widgetDict[options.name]["type"] == "IconButton" then
        -- revert to normal color
        if options.state.image == nil and options.state.off.svg == nil and options.state.off.textColor ~= nil then
            M.setObjectFillColor(options.name, "text", options.state.off.textColor)
        end

        -- revert to normal icon
        if muiData.widgetDict[options.name].textOn ~= nil then
            muiData.widgetDict[options.name].text.isVisible = true
            muiData.widgetDict[options.name].textOn.isVisible = false
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", true)
            M.setObjectVisible(options.name, "imageDisabled", false)
            M.setObjectVisible(options.name, "imageTouch", false)
        end

        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    elseif muiData.widgetDict[options.name]["type"] == "RRectButton" or muiData.widgetDict[options.name]["type"] == "RectButton" then
        -- revert to normal color
        if options.state.image == nil and options.state.off.fillColor ~= nil and options.state.off.textColor ~= nil then
            M.setObjectFillColor(options.name, "rrect", options.state.off.fillColor)
            M.setObjectFillColor(options.name, "text", options.state.off.textColor)
            M.setObjectFillColor(options.name, "iconText", options.state.off.iconFontColor)
        end

        -- revert to normal icon
        if muiData.widgetDict[options.name].iconTextOn ~= nil then
            muiData.widgetDict[options.name].iconText.isVisible = true
            muiData.widgetDict[options.name].iconTextOn.isVisible = false
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", true)
            M.setObjectVisible(options.name, "imageDisabled", false)
            M.setObjectVisible(options.name, "imageTouch", false)
        end

        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    elseif muiData.widgetDict[options.name]["type"] == "CircleButton" then
        -- change color
        if options.state.image == nil and options.state.on.fillColor ~= nil and options.state.on.textColor ~= nil then
            M.setObjectFillColor(options.name, "circlemain", options.state.off.fillColor)
            M.setObjectFillColor(options.name, "text", options.state.off.textColor)
        end

        -- change icon
        if muiData.widgetDict[options.name].textOn ~= nil then
            muiData.widgetDict[options.name].text.isVisible = true
            muiData.widgetDict[options.name].textOn.isVisible = false
        end

        -- change image
        if muiData.widgetDict[options.name]["image"] ~= nil and muiData.widgetDict[options.name]["imageTouch"] ~= nil then
            M.setObjectVisible(options.name, "image", true)
            M.setObjectVisible(options.name, "imageDisabled", false)
            M.setObjectVisible(options.name, "imageTouch", false)
        end

        if muiData.currentControl == options.name then
            M.resetCurrentControlVars()
        end
    end
end

function M.createCheckBox(options)
    M.newCheckBox(options)
end

function M.newCheckBox(options)
    options.isCheckBox = true
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
    muiData.widgetDict[options.name]["group"] = display.newGroup()
    muiData.widgetDict[options.name]["group"].x = x
    muiData.widgetDict[options.name]["group"].y = y
    muiData.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["group"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["group"] )
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
    if options.state.off.textColor ~= nil then
        textColor = options.state.off.textColor
    end

    local fillColor = { 0, 0, 0 }
    if options.state.off.fillColor ~= nil then
        fillColor = options.state.off.fillColor
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
        muiData.widgetDict[options.name]["group"]:insert( shadow )
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
    muiData.widgetDict[options.name]["circlemain"]:setFillColor( unpack(options.state.off.fillColor) )
    muiData.widgetDict[options.name]["circlemain"].isVisible = true
    muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["circlemain"], true )

    -- create image buttons if exist
    M.createButtonsFromList({ name = options.name, image=options.state.image }, muiData.widgetDict[options.name]["circlemain"], "group")

    if options.state.off.svg ~= nil and type(options.state.off.svg) == "table" and options.state.image == nil then
       local params = {
            {
                name = "text",
                svgName = options.name.."SvgOff",
                state = "off",
                isVisible = true
            },
            {
                name = "textOn",
                svgName = options.name.."SvgOn",
                state = "on",
                isVisible = false
            },
            {
                name = "textDisabled",
                svgName = options.name.."SvgDisabled",
                state = "disabled",
                isVisible = false
            }
        }
        for k, v in pairs(params) do
            if options.state[v.state] ~= nil and options.state[v.state].svg ~= nil then
                muiData.widgetDict[options.name][v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.state[v.state].svg.path,
                        width = fontSize,
                        height = fontSize,
                        fillColor = options.state[v.state].svg.fillColor,
                        strokeWidth = options.state[v.state].svg.strokeWidth or 1,
                        strokeColor = options.state[v.state].svg.textColor or options.state[v.state].textColor,
                        y = 0,
                    })
                muiData.widgetDict[options.name][v.name].isVisible = v.isVisible
                muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name][v.name], false )
            end
        end
    elseif options.state.image == nil then
        muiData.widgetDict[options.name]["text"] = display.newText( options2 )
        muiData.widgetDict[options.name]["text"]:setFillColor( unpack(options.state.off.textColor) )
        muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["text"], false )
        muiData.widgetDict[options.name]["text"].isVisible = true
    end

    local circle = muiData.widgetDict[options.name]["circlemain"]

    local radiusOffset = 2.5
    if muiData.masterRatio > 1 then radiusOffset = 2.0 end
    local maxWidth = circle.contentWidth - (radius * radiusOffset)

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    muiData.widgetDict[options.name]["circle"] = display.newCircle( 0, 0, maxWidth + 5)
    muiData.widgetDict[options.name]["circle"]:setFillColor( unpack(circleColor) )

    muiData.widgetDict[options.name]["circle"].isVisible = false
    muiData.widgetDict[options.name]["circle"].x = 0
    muiData.widgetDict[options.name]["circle"].y = 0
    muiData.widgetDict[options.name]["circle"].alpha = 0.3
    muiData.widgetDict[options.name]["group"]:insert( muiData.widgetDict[options.name]["circle"], true ) -- insert and center bkgd

    muiData.widgetDict[options.name]["circlemain"].muiOptions = options
    muiData.widgetDict[options.name]["circlemain"]:addEventListener( "touch", M.touchCircleButton )
    options.ignoreTap = options.ignoreTap or false
    if options.ignoreTap then
        muiData.widgetDict[options.name]["circlemain"]:addEventListener("tap", function() return true end)
    end

    if options.state.value == "off" then
        M.turnOffButton( options )
    elseif options.state.value == "on" then
        M.turnOnButton( options )
    elseif options.state.value == "disabled" then
        M.disableButton( options )
    end
end

function M.getCircleButtonProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["group"] -- x,y movement
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetName]["text"] -- button
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value of button
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["circlemain"] -- the base
    elseif propertyName == "image" then
        data = muiData.widgetDict[widgetName]["image"]
    elseif propertyName == "image_touch" then
        data = muiData.widgetDict[widgetName]["imageTouch"]
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

    if muiData.currentControl == nil then
        muiData.currentControl = options.name
        muiData.currentControlType = "mui-button"
    end

    if M.disableButton( options, event ) then
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
        return
    end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.touchCircleButton
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)

        M.turnOnButton( options )

        if muiData.touching == false then
            muiData.touching = true
            M.activateImageTouch( options )
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.name]["circle"].x = event.x - muiData.widgetDict[options.name]["group"].x
                muiData.widgetDict[options.name]["circle"].y = event.y - muiData.widgetDict[options.name]["group"].y
            end
            muiData.widgetDict[options.name]["circle"].isVisible = true
            local scaleFactor = 4.1
            muiData.widgetDict[options.name].circleTrans = transition.from( muiData.widgetDict[options.name]["circle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(event.target,{time=500, xScale=1.1, yScale=1.1, transition=easing.continuousLoop})
        end
    elseif ( event.phase == "ended" ) then

        M.removeEventFromQueue( options.name ) -- cancel and remove from queue

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
                M.turnOffButton( options )
            end
            muiData.interceptEventHandler = nil
            muiData.interceptOptions = nil
            muiData.interceptMoved = false
            muiData.touching = false
            M.deactivateImageTouch( options )
        end
        M.turnOffButton( options )
        M.processEventQueue()
    else
        M.addToEventQueue( options )
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

    local radioButton = muiData.widgetDict[options.basename]["radio"][options.name]
    radioButton["group"] = display.newGroup()
    radioButton["group"].x = x
    radioButton["group"].y = y
    radioButton["touching"] = false

    if options.scrollView ~= nil and muiData.widgetDict[options.name]["scrollView"] == nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["group"] )
    end

    if options.parent ~= nil then
        radioButton["parent"] = options.parent
        radioButton["parent"]:insert( radioButton["group"] )
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
    if options.state.off.textColor ~= nil then
        textColor = options.state.off.textColor
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
    if options.state.off.labelColor ~= nil then
        labelColor = options.state.off.labelColor
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
                radioButton[v.name] = M.newSvgImageWithStyle({
                        name = v.svgName,
                        path = options.state[v.state].svg.path,
                        width = fontSize,
                        height = fontSize,
                        fillColor = options.state[v.state].svg.fillColor,
                        strokeWidth = options.state[v.state].svg.strokeWidth or 1,
                        strokeColor = options.state[v.state].svg.textColor or options.state[v.state].textColor,
                        y = 0,
                    })
                radioButton[v.name].isVisible = v.isVisible
            end
        end
        if isChecked then
            radioButton.isChecked = isChecked
            if options.state.on.svg ~= nil then
                radioButton["text"].isVisible = false
                radioButton["textDisabled"].isVisible = false
                radioButton["textOn"].isVisible = true
                if options.state.value == "disabled" then
                    radioButton["textOn"]:setFillColor( unpack(options.state.disabled.textColor) )
                end
            end
        end
    elseif options.state.image == nil then
        radioButton["text"] = display.newText( options2 )
        radioButton["text"]:setFillColor( unpack(options.state.off.textColor) )
        if isChecked then
            if options.textOn ~= nil then
                radioButton["text"].text = M.getMaterialFontCodePointByName(options.textOn)
            end
            radioButton.isChecked = isChecked
        end
    end
    radioButton["text"].isVisible = true
    radioButton["text"].value = options.value
    radioButton["group"]:insert( radioButton["text"], true )
    if radioButton["textOn"] ~= nil then
        radioButton["group"]:insert( radioButton["textOn"], true )
    end
    if radioButton["textDisabled"] ~= nil then
        radioButton["group"]:insert( radioButton["textDisabled"], true )
    end

    -- add the label

    local textToMeasure2 = display.newText( options.label, 0, 0, options.labelFont, fontSize )
    local labelWidth = textToMeasure2.contentWidth
    textToMeasure2:removeSelf()
    textToMeasure2 = nil

    local labelX = radioButton["group"].x
    -- x,y of both text and label is centered so divide by half
    local labelSpacing = fontSize * 0.1
    labelX = radioButton["text"].x + (fontSize * 0.5) + labelSpacing
    labelX = labelX + (labelWidth * 0.5)
    local options3 =
    {
        --parent = muiData.widgetDict[options.name]["group"],
        text = options.label,
        x = mathFloor(labelX),
        y = 0,
        width = labelWidth,
        font = labelFont,
        fontSize = fontSize *.75
    }

    radioButton["label"] = display.newText( options3 )
    radioButton["label"]:setFillColor( unpack(options.state.off.labelColor) )
    radioButton["label"]:setStrokeColor( 0 )
    radioButton["label"].strokeWidth = 3
    radioButton["label"].isVisible = true
    radioButton["label"].touchTarget = radioButton["text"]
    radioButton["label"].options = options
    radioButton["group"]:insert( radioButton["label"], false )

    local maxWidth = checkbox.contentWidth - (radius * 2)

    -- add the animated circle

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    radioButton["circle"] = display.newCircle( options.height, options.height, maxWidth + 5 )
    radioButton["circle"]:setFillColor( unpack(circleColor) )
    radioButton["circle"].isVisible = false
    radioButton["circle"].x = 0
    radioButton["circle"].y = 0
    radioButton["circle"].alpha = 0.3
    radioButton["group"]:insert( radioButton["circle"], true ) -- insert and center bkgd

    checkbox = radioButton["text"]
    local label = radioButton["label"]
    checkbox.muiOptions = options
    label.muiOptions = options
    muiData.widgetDict[options.basename]["radio"][options.name]["text"]:addEventListener( "touch", M.touchCheckbox )
    muiData.widgetDict[options.basename]["radio"][options.name]["label"]:addEventListener( "touch", M.touchCheckboxLabel )
    options.ignoreTap = options.ignoreTap or false
    if options.ignoreTap then
        muiData.widgetDict[options.name]["radio"][options.name]["text"]:addEventListener("tap", function() return true end)
        muiData.widgetDict[options.name]["radio"][options.name]["label"]:addEventListener("tap", function() return true end)
    end

    if options.state.value == "off" then
        M.turnOffButton( options )
    elseif options.state.value == "on" then
        M.turnOnButton( options )
    elseif options.state.value == "disabled" then
        M.disableButton( options )
    end
end

function M.getRadioButtonProperty(parentWidgetName, propertyName, index)
    local data = nil

    if parentWidgetName == nil or widgetName == nil or propertyName == nil then return data end

    local widgetName = parentWidgetName .. "_" .. index
    if muiData.widgetDict[widgetParentName]["toolbar"][widgetName] == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[parentWidgetName]["radio"][widgetName]["group"] -- x,y movement
    elseif propertyName == "icon" then
        data = muiData.widgetDict[parentWidgetName]["radio"][widgetName]["text"] -- button
    elseif propertyName == "label" then
        data = muiData.widgetDict[parentWidgetName]["radio"][widgetName]["label"] -- the base
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

    if M.disableButton( options, event ) then
        if options.state.disabled.callBackData ~= nil and event.phase == "ended" then
            M.setEventParameter(event, "muiTargetCallBackData", options.state.disabled.callBackData)
            assert( options.state.disabled.callBack )(event)
        end
        return
    end

    if muiData.currentControl == nil then
        muiData.currentControl = options.basename
        muiData.currentControlSubName = options.name
        muiData.currentControlType = "mui-button"
    end

    if muiData.currentControl ~= nil and muiData.currentControl ~= options.basename then
        if event.phase == "offTarget" or event.phase == "onTarget" then
            M.turnOffControlHandler()
        end
        return
    end

    if event.phase == "began" then
        M.turnOnButton( options )
        if muiData.touching == false then
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true then
                muiData.widgetDict[options.basename]["radio"][options.name]["circle"].x = event.x - muiData.widgetDict[options.basename]["radio"][options.name]["group"].x
                muiData.widgetDict[options.basename]["radio"][options.name]["circle"].y = event.y - muiData.widgetDict[options.basename]["radio"][options.name]["group"].y
            end
            muiData.widgetDict[options.basename]["radio"][options.name]["circle"].isVisible = true
            local scaleFactor = 0.1
            muiData.widgetDict[options.basename]["radio"][options.name].circleTrans = transition.from( muiData.widgetDict[options.basename]["radio"][options.name]["circle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            transition.to(event.target,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
        end
    elseif event.phase == "offTarget" then
        M.removeEventFromQueue( options.name ) -- cancel and remove from queue
    elseif event.phase == "onTarget" then
        M.removeEventFromQueue( options.name ) -- cancel and remove from queue
        if muiData.interceptMoved == false then
            --event.target = muiData.widgetDict[options.name]["rrect"]
            event.myTargetName = options.name
            event.myTargetBasename = options.basename
            event.altTarget = muiData.widgetDict[options.basename]["radio"][options.name]["text"]

            muiData.widgetDict[options.basename]["value"] = options.value
            M.setEventParameter(event, "muiTargetValue", options.value)
            M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.basename]["radio"][options.name]["text"])
            M.setEventParameter(event, "muiTargetCallBackData", options.callBackData)

            if options.callBack ~= nil then
                assert( options.callBack )(event)
            end
            M.turnOffButton( options )
        end
        M.turnOffButton( options )
        M.processEventQueue()
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
    else
        M.addToEventQueue( options )
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
    else
        M.addToEventQueue( options )
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
        local isFontIcon = true
        muiData.widgetDict[options.name] = {}
        muiData.widgetDict[options.name]["radio"] = {}
        muiData.widgetDict[options.name]["type"] = "RadioGroup"
        if options.isSvgIcon ~= nil and options.isSvgIcon == true then
            isFontIcon = false
        end
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
                    isFontIcon = isFontIcon,
                    state = options.state,
                    font = muiData.materialFont,
                    labelFont = options.labelFont,
                    textColor = options.state.off.textColor,
                    textAlign = "center",
                    labelColor = options.state.off.labelColor,
                    callBack = options.callBack
                })
            local radioButton = muiData.widgetDict[options.name]["radio"][options.name.."_"..i]
            if options.layout ~= nil and options.layout == "horizontal" then
                width = radioButton["text"].contentWidth + radioButton["label"].contentWidth + options.spacing
                x = x + width * .8 -- + (radioButton["text"].contentWidth *.25)
            else
                y = y + radioButton["text"].contentHeight + options.spacing
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
        if muiTarget.muiOptions.disabled ~= nil and muiTarget.muiOptions.disabled == true then
            return
        end
        local name = muiTarget.muiOptions.name
        if muiData.widgetDict[name].isChecked == true then
            muiData.widgetDict[name].isChecked = false
            if muiTarget.muiOptions.state.off.svg == nil then
                muiTarget.text = M.getMaterialFontCodePointByName("check_box_outline_blank")
            end
        else
            muiData.widgetDict[name].isChecked = true
            if muiTarget.muiOptions.state.on.svg == nil then
                muiTarget.text = M.getMaterialFontCodePointByName("check_box")
            end
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
        -- textOn = SvgIcon and handle below, create above and delete down in remove
        local basename = M.getEventParameter(e, "basename")
        local foundName = false

        local list = muiData.widgetDict[basename]["radio"]
        for k, v in pairs(list) do
            muiData.widgetDict[basename]["radio"][k].isChecked = false
            if v.text.muiOptions.state.off.svg == nil then
                v["text"].text = M.getMaterialFontCodePointByName("radio_button_unchecked")
            end
        end

        if muiData.widgetDict[basename]["radio"][muiTarget.muiOptions.name].isChecked == true then
            muiData.widgetDict[basename]["radio"][muiTarget.muiOptions.name].isChecked = false
            if muiTarget.muiOptions.state.off.svg == nil then
                muiTarget.text = M.getMaterialFontCodePointByName("radio_button_unchecked")
            end
        else
            muiData.widgetDict[basename]["radio"][muiTarget.muiOptions.name].isChecked = true
            if muiTarget.muiOptions.state.off.svg == nil then
                muiTarget.text = M.getMaterialFontCodePointByName("radio_button_checked")
            end
        end
        if muiTargetValue ~= nil then
            muiData.widgetDict[basename]["value"] = muiTargetValue
            print("value is "..muiTargetValue)
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
    muiData.widgetDict[widgetName]["circle"]:removeSelf()
    muiData.widgetDict[widgetName]["circle"] = nil
    muiData.widgetDict[widgetName]["text"]:removeSelf()
    muiData.widgetDict[widgetName]["text"] = nil

    if muiData.widgetDict[widgetName]["textOn"] ~= nil then
        muiData.widgetDict[widgetName]["textOn"]:removeSelf()
        muiData.widgetDict[widgetName]["textOn"] = nil
    end

    if muiData.widgetDict[widgetName]["iconText"] ~= nil then
        muiData.widgetDict[widgetName]["iconText"]:removeSelf()
        muiData.widgetDict[widgetName]["iconText"] = nil
    end

    if muiData.widgetDict[widgetName]["iconTextOn"] ~= nil then
        muiData.widgetDict[widgetName]["iconTextOn"]:removeSelf()
        muiData.widgetDict[widgetName]["iconTextOn"] = nil
    end

    if muiData.widgetDict[widgetName]["textDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("touch", M.touchIconButton)
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("tap", M.touchIconButton)
    end

    if muiData.widgetDict[widgetName.."SvgOff"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOff")
    end
    if muiData.widgetDict[widgetName.."SvgOn"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOn")
    end
    if muiData.widgetDict[widgetName.."SvgDisabled"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgDisabled")
    end

    if muiData.widgetDict[widgetName]["image"] ~= nil then
        muiData.widgetDict[widgetName]["image"]:removeSelf()
        muiData.widgetDict[widgetName]["image"] = nil
    end

    if muiData.widgetDict[widgetName]["imageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["imageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["imageTouch"] = nil
    end

    if muiData.widgetDict[widgetName]["imageDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["imageDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["imageDisabled"] = nil
    end

    if muiData.widgetDict[widgetName]["imageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["imageSheet"] = nil
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
    M.resetCurrentControlVars()
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
    muiData.widgetDict[widgetName]["circle"]:removeSelf()
    muiData.widgetDict[widgetName]["circle"] = nil
    if muiData.widgetDict[widgetName]["iconText"] ~= nil then
        muiData.widgetDict[widgetName]["iconText"]:removeSelf()
        muiData.widgetDict[widgetName]["iconText"] = nil
    end
    if muiData.widgetDict[widgetName]["iconTextOn"] ~= nil then
        muiData.widgetDict[widgetName]["iconTextOn"]:removeSelf()
        muiData.widgetDict[widgetName]["iconTextOn"] = nil
    end
    muiData.widgetDict[widgetName]["text"]:removeSelf()
    muiData.widgetDict[widgetName]["text"] = nil

    if muiData.widgetDict[widgetName]["textOn"] ~= nil then
        muiData.widgetDict[widgetName]["textOn"]:removeSelf()
        muiData.widgetDict[widgetName]["textOn"] = nil
    end

    if muiData.widgetDict[widgetName]["textDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("touch", M.touchIconButton)
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("tap", M.touchIconButton)
    end

    if muiData.widgetDict[widgetName.."SvgOff"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOff")
    end
    if muiData.widgetDict[widgetName.."SvgOn"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOn")
    end
    if muiData.widgetDict[widgetName.."SvgDisabled"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgDisabled")
    end

    if muiData.widgetDict[widgetName]["image"] ~= nil then
        muiData.widgetDict[widgetName]["image"]:removeSelf()
        muiData.widgetDict[widgetName]["image"] = nil
    end

    if muiData.widgetDict[widgetName]["imageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["imageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["imageTouch"] = nil
    end

    if muiData.widgetDict[widgetName]["imageDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["imageDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["imageDisabled"] = nil
    end

    if muiData.widgetDict[widgetName]["imageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["imageSheet"] = nil
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
    M.resetCurrentControlVars()
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
    muiData.widgetDict[widgetName]["circlemain"]:removeEventListener("tap", M.touchCircleButton)
    muiData.widgetDict[widgetName]["circle"]:removeSelf()
    muiData.widgetDict[widgetName]["circle"] = nil
    muiData.widgetDict[widgetName]["text"]:removeSelf()
    muiData.widgetDict[widgetName]["text"] = nil
    if muiData.widgetDict[widgetName]["textOn"] ~= nil then
        muiData.widgetDict[widgetName]["textOn"]:removeSelf()
        muiData.widgetDict[widgetName]["textOn"] = nil
    end

    if muiData.widgetDict[widgetName]["textDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("touch", M.touchIconButton)
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("tap", M.touchIconButton)
    end

    if muiData.widgetDict[widgetName.."SvgOff"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOff")
    end
    if muiData.widgetDict[widgetName.."SvgOn"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOn")
    end
    if muiData.widgetDict[widgetName.."SvgDisabled"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgDisabled")
    end
    if muiData.widgetDict[widgetName]["image"] ~= nil then
        muiData.widgetDict[widgetName]["image"]:removeSelf()
        muiData.widgetDict[widgetName]["image"] = nil
    end

    if muiData.widgetDict[widgetName]["imageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["imageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["imageTouch"] = nil
    end

    if muiData.widgetDict[widgetName]["imageDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["imageDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["imageDisabled"] = nil
    end

    if muiData.widgetDict[widgetName]["imageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["imageSheet"] = nil
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
    muiData.widgetDict[widgetName]["group"]:removeSelf()
    muiData.widgetDict[widgetName]["group"] = nil
    muiData.widgetDict[widgetName] = nil
    M.resetCurrentControlVars()
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

    muiData.widgetDict[widgetName]["text"]:removeEventListener("touch", M.touchIconButton)
    muiData.widgetDict[widgetName]["text"]:removeEventListener("tap", M.touchIconButton)
    if muiData.widgetDict[widgetName]["textOn"] ~= nil then
        muiData.widgetDict[widgetName]["textOn"]:removeEventListener("touch", M.touchIconButton)
        muiData.widgetDict[widgetName]["textOn"]:removeEventListener("tap", M.touchIconButton)
        muiData.widgetDict[widgetName]["textOn"]:removeSelf()
        muiData.widgetDict[widgetName]["textOn"] = nil
    end

    if muiData.widgetDict[widgetName]["textDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("touch", M.touchIconButton)
        muiData.widgetDict[widgetName]["textDisabled"]:removeEventListener("tap", M.touchIconButton)
    end

    if muiData.widgetDict[widgetName.."SvgOff"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOff")
    end
    if muiData.widgetDict[widgetName.."SvgOn"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgOn")
    end
    if muiData.widgetDict[widgetName.."SvgDisabled"] ~= nil then
        M.removeImageSvgStyle(widgetName.."SvgDisabled")
    end

    if muiData.widgetDict[widgetName]["image"] ~= nil then
        muiData.widgetDict[widgetName]["image"]:removeSelf()
        muiData.widgetDict[widgetName]["image"] = nil
        if muiData.widgetDict[widgetName]["rrect"] ~= nil then
            muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", M.touchIconButton)
            muiData.widgetDict[widgetName]["rrect"]:removeEventListener("tap", M.touchIconButton)
            muiData.widgetDict[widgetName]["rrect"]:removeSelf()
        end
        muiData.widgetDict[widgetName]["rrect"] = nil
    end
    muiData.widgetDict[widgetName]["circle"]:removeSelf()
    muiData.widgetDict[widgetName]["circle"] = nil
    muiData.widgetDict[widgetName]["text"]:removeSelf()
    muiData.widgetDict[widgetName]["text"] = nil
    if muiData.widgetDict[widgetName]["image"] ~= nil then
        muiData.widgetDict[widgetName]["image"]:removeSelf()
        muiData.widgetDict[widgetName]["image"] = nil
    end

    if muiData.widgetDict[widgetName]["imageTouch"] ~= nil then
        muiData.widgetDict[widgetName]["imageTouch"]:removeSelf()
        muiData.widgetDict[widgetName]["imageTouch"] = nil
    end
    if muiData.widgetDict[widgetName]["imageDisabled"] ~= nil then
        muiData.widgetDict[widgetName]["imageDisabled"]:removeSelf()
        muiData.widgetDict[widgetName]["imageDisabled"] = nil
    end

    if muiData.widgetDict[widgetName]["imageSheet"] ~= nil then
        muiData.widgetDict[widgetName]["imageSheet"] = nil
    end
    muiData.widgetDict[widgetName]["group"]:removeSelf()
    muiData.widgetDict[widgetName]["group"] = nil
    muiData.widgetDict[widgetName] = nil
    M.resetCurrentControlVars()
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
        muiData.widgetDict[widgetName]["radio"][name]["text"]:removeEventListener( "touch", M.touchCheckbox )
        if muiData.widgetDict[widgetName]["radio"][name]["textOn"] ~= nil then
            muiData.widgetDict[widgetName]["radio"][name]["textOn"]:removeEventListener( "touch", M.touchCheckbox )
            muiData.widgetDict[widgetName]["radio"][name]["textOn"]:removeEventListener( "tap", M.touchCheckbox )
            muiData.widgetDict[widgetName]["radio"][name]["textOn"]:removeSelf()
            muiData.widgetDict[widgetName]["radio"][name]["textOn"] = nil
        end

        if muiData.widgetDict[widgetName..name.."SvgOff"] ~= nil then
            M.removeImageSvgStyle(widgetName..name.."SvgOff")
        end
        if muiData.widgetDict[widgetName..name.."SvgOn"] ~= nil then
            M.removeImageSvgStyle(widgetName..name.."SvgOn")
        end
        if muiData.widgetDict[widgetName..name.."SvgDisabled"] ~= nil then
            M.removeImageSvgStyle(widgetName..name.."SvgDisabled")
        end

        muiData.widgetDict[widgetName]["radio"][name]["label"]:removeEventListener( "touch", M.touchCheckbox )
        muiData.widgetDict[widgetName]["radio"][name]["text"]:removeEventListener( "tap", M.touchCheckbox )
        muiData.widgetDict[widgetName]["radio"][name]["label"]:removeEventListener( "tap", M.touchCheckbox )
        muiData.widgetDict[widgetName]["radio"][name]["circle"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["circle"] = nil
        muiData.widgetDict[widgetName]["radio"][name]["text"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["text"] = nil
        muiData.widgetDict[widgetName]["radio"][name]["label"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["label"] = nil
        muiData.widgetDict[widgetName]["radio"][name]["group"]:removeSelf()
        muiData.widgetDict[widgetName]["radio"][name]["group"] = nil
        muiData.widgetDict[widgetName]["radio"][name] = nil
    end
    M.resetCurrentControlVars()
end

return M
