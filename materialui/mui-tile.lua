--[[
    A loosely based Material UI module

    mui-tile.lua : This is for creating grid based touch tiles.

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

function M.newTileGrid(options)

    if options == nil then return end
    if options.list == nil then return end

    local x,y = 0, 0
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    options.width = options.width or muiData.contentWidth
    options.height = options.height or muiData.contentHeight
    options.tileWidth = options.tileWidth or options.width * 0.5
    options.tileHeight = options.tileHeight or options.width * 0.5
    options.textColor = options.textColor or {1, 1, 1, 1}
    options.fillColor = options.fillColor or {1, 1, 1, 1}

    if options.backgroundColor ~= nil then
        options.fillColor = options.backgroundColor
    end

    -- place on scrollview???
    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["rectbackdrop"] = display.newRect( muiData.contentWidth * 0.5, muiData.contentHeight * 0.5, muiData.contentWidth, muiData.contentHeight)
    muiData.widgetDict[options.name]["rectbackdrop"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectbackdrop"]:setFillColor( unpack( options.fillColor ) )
    muiData.widgetDict[options.name]["rectbackdrop"].isVisible = true

    -- put menu on a scrollview
    local scrollWidth = muiData.contentWidth * 0.5
    scrollView = widget.newScrollView(
        {
            top = 0,
            left = 0,
            width = options.width,
            height = muiData.contentHeight,
            scrollWidth = scrollWidth,
            scrollHeight = muiData.contentHeight,
            hideBackground = false,
            isBounceEnabled = false,
            backgroundColor = options.fillColor,
            listener = M.tileScrollListener
        }
    )

    scrollView.muiOptions = options
    muiData.widgetDict[options.name]["scrollview"] = scrollView

    -- now for the rest of the dialog
    local centerX = (muiData.contentWidth * 0.5)
    local centerY = (muiData.contentHeight * 0.5)

    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "TileGrid"
    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"]:translate( 0, 0 )
    muiData.widgetDict[options.name]["scrollview"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    muiData.widgetDict[options.name]["touching"] = false

    local highlightColor = { 0, 0, 0.3, 1}
    local highlightColorAlpha = 0.5
    local animTime = 200
    if options.clickAnimation ~= nil then
    	highlightColor = options.clickAnimation.highlightColor
    	highlightColorAlpha = options.clickAnimation.highlightColorAlpha
    	animTime = mathFloor(options.clickAnimation.time / 2)
    end

    options.tilesPerRow = options.tilesPerRow or 4
    options.tileWidth = options.width / options.tilesPerRow
    local count = 0
    local perRow = mathFloor(options.width / options.tileWidth)
    for i, v in ipairs(options.list) do
        local tileWidth = options.tileWidth
        if v.size ~= nil and v.size == "2x" then
            tileWidth = tileWidth * 2
        end
    	M.newTile({
    		name = options.name .. "-tile-" .. i,
    		basename = options.name,
    		width = tileWidth,
    		height = options.tileHeight,
    		x = x,
    		y = y,
    		value = v.value,
            textColor = options.textColor,
            labelText = v.labelText,
            align = v.align,
            padding = v.padding,
            image = v.image,
            icon = v.icon,
            iconFont = options.iconFont,
            labelFont = options.labelFont,
    		tileFillColor = v.tileFillColor or options.tileFillColor,
    		highlightColor = v.tileHighlightColor or highlightColor,
    		highlightColorAlpha = v.tileHighlightColorAlpha or highlightColorAlpha,
    		animTime = animTime,
            touchpoint = options.touchpoint,
    		callBack = options.callBack,
    		callBackData = options.callBackData,
    	})
    	x = x + options.tileWidth
    	count = count + 1
        if v.size ~= nil and v.size == "2x" then
            x = x + options.tileWidth
            count = count + 1
        end
    	if (count >= perRow) then
    		x = 0
    		count = 0
	    	y = y + options.tileHeight
	    end
    end

    -- add the animated circle
    local maxWidth = options.tileWidth * 0.75 -- * 2.5
    local circleColor = { 0.8, 0.8, 0.8 }
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    muiData.widgetDict[options.name]["myCircle"] = display.newCircle( options.height, options.height, maxWidth + M.getScaleVal(5) )
    muiData.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )
    muiData.widgetDict[options.name]["myCircle"].isVisible = false
    muiData.widgetDict[options.name]["myCircle"].x = 0
    muiData.widgetDict[options.name]["myCircle"].y = 0
    muiData.widgetDict[options.name]["myCircle"].alpha = 0.3
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

end

function M.newTile(options)
	if options == nil then return end

	if muiData.widgetDict[options.basename]["tile"] == nil then
		muiData.widgetDict[options.basename]["tile"] = {}
    muiData.widgetDict[options.basename]["tile"]["type"] = "TileGridButton"
	end
	muiData.widgetDict[options.basename]["tile"][options.name] = {}
	local tile = muiData.widgetDict[options.basename]["tile"][options.name]
    tile["mygroup"] = display.newGroup()
    tile["mygroup"]:translate( options.x, options.y ) -- set x,y

    options.padding = options.padding or 0
    tile["rect"] = display.newRect( options.width * 0.5, options.height * 0.5, options.width, options.height)
    tile["rect"].strokeWidth = options.strokeWidth or 1
    tile["rect"]:setFillColor( unpack( options.tileFillColor ) )
    tile["rect"]:addEventListener( "touch", M.tileTouchEventHandler )
    tile["rect"].muiOptions = options
    tile["mygroup"]:insert( tile["rect"] )
    muiData.widgetDict[options.basename]["mygroup"]:insert( tile["mygroup"] )

    -- place image if present
    if options.image ~= nil then
        local myImage = display.newImage( options.image )
        M.fitImage(myImage, tile["rect"].contentWidth, tile["rect"].contentHeight, true)
        myImage:translate(tile["rect"].contentWidth * 0.5, tile["rect"].contentHeight * 0.5)
        tile["myImage"] = myImage
        tile["mygroup"]:insert( tile["myImage"] )
        tile["rect"].alpha = 1
    end
    -- place the icon and text (could be an updatable widget?)

    local fontSize = options.height
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end
    fontSize = mathFloor(tonumber(fontSize))

    -- Calculate a font size that will best fit the given field's height
    local field = nil
    local fontSize = 10
    local text = nil
    local boxTextCount = 0
    if options.labelText ~= nil then
        text = options.labelText
    elseif options.icon ~= nil then
        text = options.icon
    end
    if options.labelFont ~= nil then
        font = options.labelFont
    elseif options.iconFont ~= nil then
        font = options.iconFont
    end
    local field = {contentHeight=options.height * 0.60, contentWidth=options.height * 0.60}
    local textToMeasure = display.newText( text, 0, 0, font, fontSize )
    local fontSize = fontSize * ( ( field.contentHeight ) / textToMeasure.contentHeight )
    local textWidth = textToMeasure.contentWidth
    textToMeasure:removeSelf()
    textToMeasure = nil

    local textY = 0
    local textSize = fontSize

    if options.icon ~= nil then boxTextCount = boxTextCount + 1 end
    if options.labelText ~= nil then boxTextCount = boxTextCount + 1 end

    local iconOffset = 0.5
    if boxTextCount > 1 then
        iconOffset = 0.35
    end

    if options.icon ~= nil then
        local options2 = 
        {
            --parent = textGroup,
            text = options.icon,
            x = options.width * 0.5,
            y = options.height * iconOffset,
            width = options.width - options.padding,
            font = options.iconFont,
            fontSize = textSize,
            align = options.align or "center",
        }
        tile["icon"] = display.newText( options2 )
        tile["icon"]:setFillColor( unpack(options.textColor) )
        tile["mygroup"]:insert( tile["icon"] )
    end

    local textY = options.height * 0.5
    if boxTextCount > 1 then
        textY = tile["icon"].y + textSize * 0.80
    end

    if options.labelText ~= nil then
        local options3 =
        {
            --parent = textGroup,
            text = options.labelText,
            x = options.width * 0.5,
            y = textY,
            width = options.width - options.padding,
            font = options.labelFont,
            fontSize = fontSize * 0.35,
            align = options.align or "center",
        }
        tile["text"] = display.newText( options3 )
        tile["text"]:setFillColor( unpack(options.textColor) )
        tile["mygroup"]:insert( tile["text"], false )
    end
end

function M.getTileProperty( widgetName, propertyName )
    local data = nil
    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["scrollview"] -- the scrollview layer
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["rectbackdrop"] -- the background layer
    end

    return data
end

function M.getTileButtonProperty( widgetParentName, propertyName, index )
    local data = nil
    if widgetParentName == nil or propertyName == nil then return data end

    if index < 1 then index = 1 end
    local widgetName = widgetParentName .. "-tile-" .. index

    if muiData.widgetDict[widgetParentName]["tile"][widgetName] == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetParentName]["tile"][widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "icon" then
        data = muiData.widgetDict[widgetParentName]["tile"][widgetName]["icon"] -- button
    elseif propertyName == "text" then
        data = muiData.widgetDict[widgetParentName]["tile"][widgetName]["text"] -- the base
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetParentName]["tile"][widgetName]["rect"] -- the base
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetParentName]["tile"][widgetName]["myImage"] -- the base
    end

    return data
end

function M.tileTouchEventHandler( event )
    local options = nil
    local button = nil
    if event.target ~= nil then
        options = event.target.muiOptions
        button = event.target.muiButton
    end

    M.addBaseEventParameters(event, options)

    if ( event.phase == "began" ) then
        muiData.interceptEventHandler = M.tileTouchEventHandler
        if muiData.interceptOptions == nil then
            muiData.interceptOptions = options
        end
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
            if options.touchpoint ~= nil and options.touchpoint == true then
                local x = muiData.widgetDict[options.basename]["tile"][options.name]["mygroup"].x
                local y = muiData.widgetDict[options.basename]["tile"][options.name]["mygroup"].y                
                muiData.widgetDict[options.basename]["myCircle"].x = x + muiData.widgetDict[options.basename]["tile"][options.name]["rect"].contentWidth * 0.5
                muiData.widgetDict[options.basename]["myCircle"].y = y + muiData.widgetDict[options.basename]["tile"][options.name]["rect"].contentHeight * 0.5
                muiData.widgetDict[options.basename]["myCircle"].isVisible = true
                local scaleFactor = 0.1
                muiData.widgetDict[options.basename].myCircleTrans = transition.from( muiData.widgetDict[options.basename]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
            end
        end
    elseif ( event.phase == "cancelled" or event.phase == "moved" ) then
        M.tileResetColor( muiData.widgetDict[options.basename]["tile"][options.name]["rect"] )
    elseif ( event.phase == "ended" ) then
        if M.isTouchPointOutOfRange( event ) then
            event.phase = "offTarget"
            -- event.target:dispatchEvent(event)
            -- print("Its out of the button area")
        else
            event.phase = "onTarget"
            if muiData.interceptMoved == false then
                transition.to(muiData.widgetDict[options.basename]["tile"][options.name]["rect"],{time=options.animTime, alpha=options.highlightColorAlpha, onComplete=M.tileHighlightAnimFinish})

                event.myTargetName = options.name
                event.myTargetBasename = options.basename
                event.callBackData = options.callBackData

                M.setEventParameter(event, "muiTargetValue", options.value)
                M.setEventParameter(event, "muiTarget", muiData.widgetDict[options.basename]["tile"][options.name]["rect"]) -- rect or icon and text
                M.setEventParameter(event, "muiTargetCallBackData", options.callBackData)
                if options.callBack ~= nil then
                    assert( options.callBack ) (options, event)
                else
                    M.tileCallBack(options, event)
                end
            else
                M.tileResetColor( muiData.widgetDict[options.basename]["tile"][options.name]["rect"] )
            end
        end
        muiData.interceptEventHandler = nil
        muiData.interceptOptions = nil
        muiData.interceptMoved = false
        muiData.touching = false
    end
end

function M.tileHighlightAnimFinish( e )
    transition.to(e,{time=e.muiOptions.animTime, alpha=1, onComplete=M.tileResetColor})
end

function M.tileResetColor( e )
    e:setFillColor( unpack(e.muiOptions.tileFillColor) )
    e.alpha = 1
end

function M.tileCallBack( options, e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetName = M.getEventParameter(e, "muiTargetName")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")
    local muiTargetCallBackData = M.getEventParameter(e, "muiTargetCallBackData")

    if muiTargetName == "grid_demo-tile-1" then
        e.muiDict["muiTargetCallBackData"] = {
            sceneDestination = "menu",
            sceneTransitionColor = { 1, 0.6, 0.19, 1 }
        }
        M.actionSwitchScene(e)
    end
    if muiTargetValue ~= nil then
        print("tile value: "..muiTargetValue)
        muiData.widgetDict[options.basename]["value"] = muiTargetValue
        local w = M.getTileButtonProperty("grid_demo", "layer_1", 1)
        if w ~= nil then
            -- w.x = w.x + 50  -- demo getting the tile layer_1 only and moving it.
        end
    end
    if muiTargetCallBackData ~= nil then
        print("Item from callBackData: "..muiTargetCallBackData.item)
    end
end

function M.tileScrollListener( event )

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

function M.removeTileGrid(widgetName)
	if widgetName == nil then return end

    -- remove the list of tiles
    for name in pairs(muiData.widgetDict[widgetName]["tile"]) do
        M.removeTile(widgetName, name)
        if name ~= "slider" and name ~= "rectBak" then
            muiData.widgetDict[widgetName]["tile"][name] = nil
        end
    end

    if muiData.widgetDict[widgetName]["myCircle"] ~= nil then
        muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
        muiData.widgetDict[widgetName]["myCircle"] = nil
    end

    muiData.widgetDict[widgetName]["rectbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["rectbackdrop"] = nil
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    if muiData.widgetDict[widgetName]["scrollview"] ~= nil then
        muiData.widgetDict[widgetName]["scrollview"]:removeSelf()
        muiData.widgetDict[widgetName]["scrollview"] = nil
    end
    muiData.widgetDict[widgetName] = nil

end

function M.removeTile(basename, name)
	if basename == nil or name == nil then return end

    if muiData.widgetDict[basename]["tile"][name] == nil then
        return
    end
    if type(muiData.widgetDict[basename]["tile"][name]) == "table" then
        muiData.widgetDict[basename]["tile"][name]["rect"]:removeEventListener( "touch", M.tileTouchEventHandler )
        muiData.widgetDict[basename]["tile"][name]["rect"]:removeSelf()
        muiData.widgetDict[basename]["tile"][name]["rect"] = nil
        if muiData.widgetDict[basename]["tile"][name]["icon"] ~= nil then
            muiData.widgetDict[basename]["tile"][name]["icon"]:removeSelf()
            muiData.widgetDict[basename]["tile"][name]["icon"] = nil
        end
        if muiData.widgetDict[basename]["tile"][name]["text"] ~= nil then
            muiData.widgetDict[basename]["tile"][name]["text"]:removeSelf()
            muiData.widgetDict[basename]["tile"][name]["text"] = nil
        end
        if muiData.widgetDict[basename]["tile"][name]["myImage"] ~= nil then
            muiData.widgetDict[basename]["tile"][name]["myImage"]:removeSelf()
            muiData.widgetDict[basename]["tile"][name]["myImage"] = nil
        end
        muiData.widgetDict[basename]["tile"][name]["mygroup"]:removeSelf()
        muiData.widgetDict[basename]["tile"][name]["mygroup"] = nil
    end

end

return M
