--[[
    A loosely based Material UI module

    mui-navbar.lua : This is for creating navigation bars.

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

local M = muiData.M -- {} -- for module array/table

function M.getNavbarSupportedTypes()
    return muiData.navbarSupportedTypes
end

function M.createNavbar( options )
    M.newNavBar(options)
end

function M.newNavbar( options )
    M.newNavBar(options)
end

function M.newNavBar( options )
    if options == nil then return end

    if muiData.widgetDict[options.name] ~= nil then return end

    if options.width == nil then
        options.width = muiData.contentWidth - (muiData.safeAreaInsets.leftInset + muiData.safeAreaInsets.rightInset)
    end

    if options.height == nil then
        options.height = 4
    end

    local left,top = (muiData.contentWidth-options.width) * 0.5, 0
    if options.left ~= nil then
        left = options.left
    end

    if options.fillColor == nil then
        options.fillColor = { 0.06, 0.56, 0.15, 1 }
    end

    if options.top == nil then
        options.top = 80
    end

    if options.padding == nil then
        options.padding = 10
    end

    if options.top > muiData.contentHeight * 0.5 then
        muiData.navbarHeight = options.height
    end

    left, top = M.getSafeXY(options, left, top)

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "NavBar"
    muiData.widgetDict[options.name]["list"] = {}
    muiData.widgetDict[options.name]["lastWidgetLeftX"] = 0
    muiData.widgetDict[options.name]["lastWidgetRightX"] = 0
    muiData.widgetDict[options.name]["padding"] = options.padding

    muiData.widgetDict[options.name]["container"] = widget.newScrollView(
        {
            top = top,
            left = left,
            width = options.width,
            height = options.height,
            scrollWidth = options.width,
            scrollHeight = options.height,
            hideBackground = true,
            hideScrollBar = true,
            isLocked = true
        }
    )

    if options.parent ~= nil then
        muiData.widgetDict[options.name]["parent"] = options.parent
        muiData.widgetDict[options.name]["parent"]:insert( muiData.widgetDict[options.name]["container"] )
    end   

    local newX = muiData.widgetDict[options.name]["container"].contentWidth * 0.5
    local newY = muiData.widgetDict[options.name]["container"].contentHeight * 0.5

    muiData.widgetDict[options.name]["rect"] = display.newRect( newX, newY, options.width, options.height )
    muiData.widgetDict[options.name]["rect"]:setFillColor( unpack(options.fillColor) )
    muiData.widgetDict[options.name]["container"]:insert( muiData.widgetDict[options.name]["rect"] )

end

function M.getNavBarProperty(widgetName, propertyName)
    local data = nil

    if widgetName == nil or propertyName == nil then return data end

    if propertyName == "object" then
        data = muiData.widgetDict[widgetName]["container"] -- x,y movement
    elseif propertyName == "layer_1" then
        data = muiData.widgetDict[widgetName]["rect"] -- navbar background
    end
    return data
end

function M.attachToNavBar(navbar_name, options )
    if navbar_name == nil or options == nil or options.widgetName == nil then return end
    local newX = 0
    local newY = 0 
    local widget = nil
    local widgetName = options.widgetName
    local nh = muiData.widgetDict[navbar_name]["container"].contentHeight
    local nw = muiData.widgetDict[navbar_name]["container"].contentWidth

    local isTypeSupported = false
    for i, widgetType in ipairs(muiData.navbarSupportedTypes) do
        if widgetType == options.widgetType then
            isTypeSupported = true
            break
        end
    end

    if isTypeSupported == false then
        if options.widgetType == nil then options.widgetType = "unknown widget" end
        M.debug("Warning: attachToNavBar does not support type of "..options.widgetType)
        return
    end

    if options.widgetObject == nil then
        widget = M.getWidgetBaseObject(widgetName)
    else
        widget = options.widgetObject
    end
    newY = (nh - widget.contentHeight) * 0.5

    -- keep tabs on the toolbar objects
    muiData.widgetDict[navbar_name]["list"][widgetName] = options.widgetType
    if muiData.widgetDict[navbar_name]["destroy"] == nil then
        muiData.widgetDict[navbar_name]["destroy"] = {}
        muiData.widgetDict[navbar_name]["destroy_object"] = {}
    end
    muiData.widgetDict[navbar_name]["destroy"][widgetName] = options.destroyCallBack
    muiData.widgetDict[navbar_name]["destroy_object"][widgetName] = widget    

    if options.align == nil then
        options.align = "left"
    end

    if options.padding == nil then
        options.padding = muiData.widgetDict[navbar_name]["padding"]
    end

    if options.align == "left" then
        if muiData.widgetDict[navbar_name]["lastWidgetLeftX"] > 0 then
            newX = newX + options.padding
        end
        newX = newX + muiData.widgetDict[navbar_name]["lastWidgetLeftX"]
        widget.x = widget.contentWidth * 0.5 + newX
        widget.y = widget.contentHeight * 0.5 + newY
        muiData.widgetDict[navbar_name]["lastWidgetLeftX"] = widget.x + widget.contentWidth * 0.5
    else
        newX = nw
        if muiData.widgetDict[navbar_name]["lastWidgetRightX"] > 0 then
            newX = newX - options.padding
        end
        newX = newX - muiData.widgetDict[navbar_name]["lastWidgetRightX"]
        widget.x = newX - widget.contentWidth * 0.5
        widget.y = widget.contentHeight * 0.5 + newY
        muiData.widgetDict[navbar_name]["lastWidgetRightX"] = options.padding + muiData.widgetDict[navbar_name]["lastWidgetRightX"] + widget.contentWidth * 0.5
    end
    muiData.widgetDict[navbar_name]["container"]:insert( widget, true )
end

function M.removeNavbar(widgetName)
    M.removeNavBar(widgetName)
end

function M.removeNavBar(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end
    if muiData.widgetDict[widgetName]["list"] == nil then return end

    -- remove objects from the bar
    -- muiData.navbarSupportedTypes = { "RRectButton", "RectButton", "IconButton", "Slider", "TextField", "Generic" }
    for name, widgetType in pairs(muiData.widgetDict[widgetName]["list"]) do
        if muiData.widgetDict[widgetName]["list"][name] ~= nil then
            if widgetType == "RRectButton" then
                M.removeRoundedRectButton(name)
            elseif widgetType == "RectButton" then
                M.removeRectButton(name)
            elseif widgetType == "CircleButton" then
                M.removeCircleButton(name)
            elseif widgetType == "IconButton" then
                M.removeIconButton(name)
            elseif widgetType == "RectButton" then
                M.removeSlider(name)
            elseif widgetType == "RectButton" then
                M.removeTextField(name)
            elseif widgetType == "Generic" then
              if muiData.widgetDict[widgetName]["destroy"] ~= nil and muiData.widgetDict[widgetName]["destroy"][name] ~= nil then
                assert( muiData.widgetDict[widgetName]["destroy"][name] )( muiData.widgetDict[widgetName]["destroy_object"][name] )
              end
            end
        end
    end

    if muiData.widgetDict[widgetName]["rect"] ~= nil then
        muiData.widgetDict[widgetName]["rect"]:removeSelf()
        muiData.widgetDict[widgetName]["rect"] = nil
    end
    if muiData.widgetDict[widgetName]["container"] ~= nil then
        muiData.widgetDict[widgetName]["container"]:removeSelf()
        muiData.widgetDict[widgetName]["container"] = nil
    end
end

return M
