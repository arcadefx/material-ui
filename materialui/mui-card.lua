--[[
    A loosely based Material UI module

    mui-card.lua : This is for creating cardsa and attaching objects (mui and non-mui).

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

function M.newCard(options)

    if options == nil then return end

    x = options.x or 0
    y = options.y or 0

    x, y = M.getSafeXY(options, x, y)

    options.width = options.width or muiData.contentWidth * .5
    options.height = options.height or muiData.contentHeight * .5
    options.strokeWidth = options.strokeWidth or 0
    options.useShadow = options.useShadow or false
    options.useContainer = options.useContainer or false
    options.shadowSize = options.shadowSize or 20
    options.shadowOpacity = options.shadowOpacity or 0.3


    muiData.widgetDict[options.name] = {}

    muiData.widgetDict[options.name]["options"] = options
    muiData.widgetDict[options.name].name = options.name
    muiData.widgetDict[options.name]["type"] = "Card"
    if options.useContainer == false then
        muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    else
        local sizeOffset = 0
        if options.useShadow == true then
            sizeOffset = options.shadowSize
        end
        muiData.widgetDict[options.name]["mygroup"] = display.newGroup() -- display.newContainer(options.width + sizeOffset, options.height + sizeOffset)        
        muiData.widgetDict[options.name]["mycontainer"] = display.newContainer(options.width - (options.strokeWidth + 1), options.height - (options.strokeWidth + 1))
    end
    muiData.widgetDict[options.name]["mygroup"]:translate( x, y )

    if options.scrollView ~= nil then
        muiData.widgetDict[options.name]["scrollView"] = options.scrollView
        muiData.widgetDict[options.name]["scrollView"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["mygroup"] )
    end

    local radius = options.height * 0.2
    local nr = radius + 4
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
        nr = radius
    end

    if options.radius == nil then
        muiData.widgetDict[options.name]["rect"] = display.newRect( 0, 0, options.width, options.height)
        if options.useShadow == true then
            local shadow = M.newShadowShape("rect", {
                name = options.name,
                width = options.width + options.shadowSize * .2,
                height = options.height + options.shadowSize * .2,
                size = options.shadowSize,
                opacity = options.shadowOpacity
            })
            muiData.widgetDict[options.name]["shadow"] = shadow
            muiData.widgetDict[options.name]["mygroup"]:insert( shadow )
        end
    else
        muiData.widgetDict[options.name]["rect"] = display.newRoundedRect( 0, 0, options.width, options.height, nr)
        if options.useShadow == true then
            local shadow = M.newShadowShape("rounded_rect", {
                name = options.name,
                width = options.width, -- + options.shadowSize,
                height = options.height, -- + options.shadowSize,
                size = options.shadowSize,
                opacity = options.shadowOpacity,
                cornerRadius = nr,
            })
            muiData.widgetDict[options.name]["shadow"] = shadow
            muiData.widgetDict[options.name]["mygroup"]:insert( shadow )
            print("shadow???")
        end
    end

    if options.strokeWidth ~= nil and options.strokeWidth > 0 then
        muiData.widgetDict[options.name]["rect"].strokeWidth = options.strokeWidth or 0
    end
    if options.strokeColor ~= nil then
        muiData.widgetDict[options.name]["rect"]:setStrokeColor( unpack( options.strokeColor ) )
    end

    if options.fillColor ~= nil then
        muiData.widgetDict[options.name]["rect"]:setFillColor( unpack( options.fillColor ) )
    end

    muiData.widgetDict[options.name]["rect"].isVisible = true
    if muiData.widgetDict[options.name]["mycontainer"] ~= nil then
        muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["rect"] )
    else
        muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["rect"] )
    end

    if muiData.widgetDict[options.name]["mycontainer"] ~= nil then
        muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["mycontainer"] )
    end

    muiData.widgetDict[options.name]["touching"] = false

end

function M.newCardObject(options)
	if options == nil then return end

    local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

    if options.muiObject == nil then options.muiObject = true end

	if muiData.widgetDict[options.cardname]["objects"] == nil then
        muiData.widgetDict[options.cardname]["objects"] = {}
    end

    if muiData.widgetDict[options.cardname]["objects_ext"] == nil then
        muiData.widgetDict[options.cardname]["objects_ext"] = {}
    end

    if options.muiObject == true then
        table.insert(muiData.widgetDict[options.cardname]["objects"], options.name)
        local sourceObj = M.getWidgetBaseObject( options.cardname )
        local destObj = M.getWidgetBaseObject( options.name )
        if sourceObj ~= nil and destObj ~= nil then
            if leftInset > 0 then
                destObj.x = destObj.x - leftInset
            end
            if topInset > 0 then
                destObj.y = destObj.y - topInset
            end
            sourceObj:insert( destObj )
        end
    else
        muiData.widgetDict[options.cardname]["objects_ext"][options.name] = {}
        muiData.widgetDict[options.cardname]["objects_ext"][options.name]["name"] = options.name
        muiData.widgetDict[options.cardname]["objects_ext"][options.name]["object"] = options.object
        muiData.widgetDict[options.cardname]["objects_ext"][options.name]["destroy"] = options.destroy
        local sourceObj = M.getWidgetBaseObject( options.cardname )
        if sourceObj ~= nil then
            sourceObj:insert( options.object )
        end
    end
end

function M.getCardProperty( widgetName, propertyName )
    local data = nil
    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["mygroup"] -- x,y movement
    elseif propertyName == "value" then
        data = muiData.widgetDict[widgetName]["value"] -- value
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["scrollview"] -- the scrollview layer
    elseif propertyName == "layer_2" then
        data = muiData.widgetDict[widgetName]["rect"] -- the background layer
    elseif propertyName == "layer_3" then
        data = muiData.widgetDict[widgetName]["rectTop"] -- the background layer
    elseif propertyName == "layer_4" then
        data = muiData.widgetDict[widgetName]["rectTopRound"] -- the background layer
    elseif propertyName == "objects" then
        data = muiData.widgetDict[widgetName]["objects"] -- mui card objects
    elseif propertyName == "objects_ext" then
        -- can be any corona object for display
        data = muiData.widgetDict[widgetName]["objects_ext"] -- non-mui card objects
    end

    return data
end

function M.removeCardObjectByName(cardName, widgetName)
    if cardName == nil or widgetName == nil then return end
    for i, name in pairs(muiData.widgetDict[cardName]["objects"]) do
        if name == widgetName then
            M.removeWidgetByName(name)
            break
        end
    end
end

function M.removeCardObjectExtByName(cardName, widgetName)
    if cardName == nil or widgetName == nil then return end
    for i, entry in pairs(muiData.widgetDict[cardName]["objects_ext"]) do
        if entry.name == widgetName and entry.destroy ~= nil then
            assert( entry.destroy )(entry)
            break
        end
    end
end

function M.removeCard(widgetName)
	if widgetName == nil then return end

    -- remove user defined card objects
    if muiData.widgetDict[widgetName]["objects"] ~= nil then
        for i, name in pairs(muiData.widgetDict[widgetName]["objects"]) do
            M.removeWidgetByName(name)
        end
    end

    -- remove user defined card objects that are not mui objects and they use
    -- their own detroy method
    if muiData.widgetDict[widgetName]["objects_ext"] ~= nil then
        for i, entry in pairs(muiData.widgetDict[widgetName]["objects_ext"]) do
            if entry.destroy ~= nil then
                assert( entry.destroy )(entry)
            end
        end
    end

    if muiData.widgetDict[widgetName]["rectTopRound"] ~= nil then
        muiData.widgetDict[widgetName]["rectTopRound"]:removeSelf()
        muiData.widgetDict[widgetName]["rectTopRound"] = nil
    end
    if muiData.widgetDict[widgetName]["rectTop"] ~= nil then
        muiData.widgetDict[widgetName]["rectTop"]:removeSelf()
        muiData.widgetDict[widgetName]["rectTop"] = nil
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
    if muiData.widgetDict[widgetName]["rect"] ~= nil then
        muiData.widgetDict[widgetName]["rect"]:removeSelf()
        muiData.widgetDict[widgetName]["rect"] = nil
    end
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil

    muiData.widgetDict[widgetName] = nil

end

return M
