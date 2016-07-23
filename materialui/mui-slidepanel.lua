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

    if muiData.widgetDict[options.name] ~= nil then
        M.touchSlidePanelBarrier({target={muiOptions=options}})
        return
    end

    muiData.dialogName = options.name
    muiData.dialogInUse = true
    muiData.slidePanelName = options.name
    muiData.slidePanelInUse = true

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "SlidePanel"
    muiData.widgetDict[options.name]["options"] = options

    local width = display.contentWidth * 0.25
    muiData.widgetDict[options.name]["width"] = width

    -- place on main display
    muiData.widgetDict[options.name]["rectbackdrop"] = display.newRect( display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight)
    muiData.widgetDict[options.name]["rectbackdrop"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectbackdrop"]:setFillColor( unpack( {0.4, 0.4, 0.4, 0.3} ) )
    muiData.widgetDict[options.name]["rectbackdrop"].isVisible = true

    muiData.widgetDict[options.name]["mygroup"] = display.newGroup()
    muiData.widgetDict[options.name]["mygroup"].x = -(width * 0.5)
    muiData.widgetDict[options.name]["mygroup"].y = display.contentHeight * 0.5
    muiData.widgetDict[options.name]["mygroup"].muiOptions = options

    muiData.widgetDict[options.name]["rectclick"] = display.newRect( display.contentWidth * 0.5, 0, display.contentWidth * 0.75, display.contentHeight)
    muiData.widgetDict[options.name]["rectclick"].strokeWidth = 0
    muiData.widgetDict[options.name]["rectclick"]:setFillColor( unpack( { 1, 1, 1, 0.01 } ) )
    muiData.widgetDict[options.name]["rectclick"].isVisible = true
    muiData.widgetDict[options.name]["rectclick"]:addEventListener( "touch", M.touchSlidePanelBarrier )
    muiData.widgetDict[options.name]["rectclick"].muiOptions = options
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["rectclick"] )

    muiData.widgetDict[options.name]["rect"] = display.newRect( 0, 0, display.contentWidth * 0.25, display.contentHeight )
    muiData.widgetDict[options.name]["rect"]:setFillColor( unpack(options.fillColor) )
    muiData.widgetDict[options.name]["mygroup"]:insert( muiData.widgetDict[options.name]["rect"] )

    textOptions = {
        y = 0,
        name = options.name .. "header-text",
        text = (options.title or "Hello!"),
        align = (options.titleAlign or "center"),
        font = (options.titleFont or native.systemFontBold),
        fontSize = (options.titleFontSize or M.getScaleVal(30)),
        fillColor = (options.titleFontColor or { 1, 1, 1, 1 }),
    }
    M.newBasicText(textOptions)
    muiData.widgetDict[options.name]["mygroup"]:insert( M.getWidgetBaseObject(options.name .. "header-text") )

    transition.fadeIn(muiData.widgetDict[options.name]["rectbackdrop"],{time=300})
    transition.to( muiData.widgetDict[options.name]["mygroup"], { time=300, x=(width * 0.5), transition=easing.linear } )
end

function M.touchSlidePanelBarrier( event )
    local options = nil
    if event.target ~= nil then
        options = event.target.muiOptions
    end

    if ( event.phase == "began" ) then

        muiData.widgetDict[options.name]["interceptEventHandler"] = M.touchSlidePanelBarrier
        --muiData.interceptEventHandler = M.touchSlidePanelBarrier -- event.target
        M.updateUI(event)
        if muiData.touching == false then
            muiData.touching = true
        end
    elseif ( event.phase == "ended" ) then
        local width = muiData.widgetDict[options.name]["width"]

        transition.fadeOut(muiData.widgetDict[options.name]["rectbackdrop"],{time=300})
        transition.to( muiData.widgetDict[options.name]["mygroup"], { time=300, x=-(width * 0.5), transition=easing.linear, onComplete=M.sliderPanelFinish } )
        muiData.touching = false
        muiData.interceptEventHandler = nil
    end
end

function M.sliderPanelFinish( event )
  if event ~= nil and event.muiOptions ~= nil then
    M.removeSlidePanel(event.muiOptions.name)
  end
end

function M.removeSlidePanel(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["rectclick"]:removeSelf()
    muiData.widgetDict[widgetName]["rectclick"] = nil
    muiData.widgetDict[widgetName]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["rect"] = nil
    muiData.widgetDict[widgetName]["rectbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["rectbackdrop"] = nil
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil

    muiData.dialogName = nil
    muiData.dialogInUse = false
    muiData.slidePanelName = nil
    muiData.slidePanelInUse = false
end

return M
