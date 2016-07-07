--[[
    A loosely based Material UI module

    mui-base.lua : The base module all other modules include.

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

--]]

-- corona
local composer = require( "composer" )
local widget = require( "widget" )

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = {} -- for module array/table

function M.init_base(data)
  muiData.M = M -- all modules need access to parent methods
  muiData.environment = system.getInfo("environment")
  muiData.value = data
  muiData.circleSceneSwitch = nil
  muiData.circleSceneSwitchComplete = false
  muiData.touching = false
  muiData.masterRatio = nil
  muiData.masterRemainder = nil
  muiData.tableCircle = nil
  muiData.widgetDict = {}
  muiData.progressbarDict = {}
  muiData.currentNativeFieldName = ""
  muiData.currentTargetName = ""
  muiData.lastTargetName = ""
  muiData.interceptEventHandler = nil
  muiData.interceptMoved = false
  muiData.dialogInUse = false
  muiData.dialogName = nil
  muiData.navbarHeight = 0
  muiData.navbarSupportedTypes = { "RRectButton", "RectButton", "IconButton", "Slider", "TextField", "Generic" }

  muiData.scene = composer.getScene(composer.getSceneName("current"))
  muiData.scene.name = composer.getSceneName("current")
  Runtime:addEventListener( "touch", M.eventSuperListner )
end

function M.eventSuperListner(event)
    if (event.phase == "ended" or event.phase == "cancelled") and muiData.currentTargetName ~= nil and muiData.currentTargetName ~= muiData.lastTargetName then
        muiData.lastTargetName = muiData.currentTargetName
        -- find name in list and type, if slider then force the end!
        for widget in pairs(muiData.widgetDict) do
            widgetType = muiData.widgetDict[widget]["type"]
            if widgetType == "Slider" and muiData.widgetDict[widget].name == muiData.currentTargetName then
                muiData.widgetDict[widget]["sliderrect"]:dispatchEvent(event)
                break
            elseif widgetType == "Selector" and muiData.widgetDict[widget].name == muiData.currentTargetName then
                if muiData.widgetDict[muiData.currentTargetName]["mygroup"] ~= nil then
                    muiData.currentTargetName = nil
                    muiData.lastTargetName = ""
                    M.removeWidgetSelector(widget, "listonly")
                end
                break
            elseif widgetType == "Selector" and muiData.widgetDict[widget] ~= nil then
                if muiData.widgetDict[widget]["mygroup"] ~= nil and muiData.widgetDict[widget]["mygroup"].isVisible == true then
                    M.removeWidgetSelector(widget, "listonly")
                end
            end
        end
    end
end

function M.updateEventHandler( event )
    if muiData.interceptEventHandler ~= nil then
        muiData.interceptEventHandler:touch(event)
    end
    if event.phase == "moved" then
        muiData.interceptMoved = true
    end
end

function M.updateUI(event, skipName)
    local widgetType = ""

    for widget in pairs(muiData.widgetDict) do
        if widget ~= skipName or skipName == nil then
            widgetType = muiData.widgetDict[widget]["type"]
            if (widgetType == "TextField" or widgetType == "TextBox") and muiData.widgetDict[widget]["textfield"].isVisible == true then
                -- hide the native field
                timer.performWithDelay(100, function() native.setKeyboardFocus(nil) end, 1)
                muiData.widgetDict[widget]["textfieldfake"].isVisible = true
                muiData.widgetDict[widget]["textfield"].isVisible = false
            elseif (widgetType == "TextField" or widgetType == "TextBox") and muiData.widgetDict[widget]["textfield"].isVisible == true then
               --  timer.performWithDelay(100, function() native.setKeyboardFocus(nil) end, 1)
            end
        end
    end
end

function M.addBaseEventParameters(event, options)
    if event == nil or options == nil or event.muiDict ~= nil then return end
    M.setEventParameter(event, "name", options.name)
    M.setEventParameter(event, "basename", options.basename)
    M.setEventParameter(event, "targetName", options.name)
    M.setEventParameter(event, "targetPrimary", event.target)
    M.setEventParameter(event, "callBackData", options.callBackData)
    muiData.currentTargetName = options.name
    muiData.lastTargetName = ""
end

function M.setEventParameter(event, key, value)
    if event == nil or key == nil then return end
    if event.muiDict == nil then event.muiDict = {} end
    event.muiDict[key] = value
end

function M.getEventParameter(event, key)
    if event ~= nil and event.muiDict ~= nil and key ~= nil then
        return event.muiDict[key]
    end
    return nil
end

function M.getWidgetByName(name)
    if name ~= nil and string.len(name) > 1 then
        return muiData.widgetDict[name]
    end
    return nil
end

function M.getWidgetBaseObject(name)
    local widgetData = nil

    if name ~= nil and string.len(name) > 1 then
        for widget in pairs(muiData.widgetDict) do
          local widgetType = muiData.widgetDict[widget]["type"]
          if widgetType ~= nil and widget == name then
            if widgetType == "RRectButton" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "RectButton" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "IconButton" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "RadioButton" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "Toolbar" then
               -- widgetData = muiData.widgetDict[widget]["container"]
               print("getWidgetForInsert: Toolbar not supported at this time.")
            elseif widgetType == "TableView" then
               widgetData = muiData.widgetDict[widget]["tableview"]
            elseif widgetType == "TextField" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "TextBox" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "ProgressBar" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "ToggleSwitch" then
               widgetData = muiData.widgetDict[widget]["mygroup"]
            elseif widgetType == "Dialog" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "Slider" then
               widgetData = muiData.widgetDict[widget]["container"]
            elseif widgetType == "Toast" then
               widgetData = muiData.widgetDict[widget]["container"]
            end
          end
        end
    end
    return widgetData
end

function M.getWidgetValue(widgetName)
    if widgetName == nil then return end
    return muiData.widgetDict[widget]["value"]
end

function M.getScaleVal(n)
    if n == nil then n = 1 end
    return mathFloor(M.getSizeRatio() * n)
end

function M.getSizeRatio()
  if muiData.masterRatio ~= nil then
    return muiData.masterRatio
  end
  local divisor = 1
  if string.find(system.orientation, "portrait") ~= nil then
    divisor = 640
  elseif string.find(system.orientation, "landscape") ~= nil then
    divisor = 960
  end

  muiData.masterRatio = display.contentWidth / divisor
  muiData.masterRemainder = mathMod(display.contentWidth, divisor)
  return muiData.masterRatio
end

function M.tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function M.getColor(colorArray, index)
  local color = 1
  if colorArray == nil or index == nil then return end

  if colorArray[index] ~= nil then
    color = colorArray[index]
  end

  return color
end

function M.subtleRadius(e)
    transition.fadeOut( e, { time=500, onComplete=M.subtleRadiusDone } )
end

function M.subtleRadiusDone(e)
    e.isVisible = false
    transition.to( e, { time=0,alpha=0.3, xScale=1, yScale=1 } )
    muiData.touching = false
    if muiData.tableCircle ~= nil then
        muiData.tableCircle:toBack()
    end
end

function M.subtleRadius2(e)
    transition.fadeOut( e, { time=300, onComplete=M.subtleRadiusDone2 } )
end

function M.subtleRadiusDone2(e)
    e.isVisible = false
    transition.to( e, { time=0,alpha=0.3, xScale=1, yScale=1 } )
    muiData.touching = false
end

function M.subtleGlowRect( e )
    transition.to( e, { time=300,alpha=1 } )
end

--[[ switch scene action ]]

function M.actionSwitchScene( e )
    print("actionSwitchScene 1")
    if muiData.circleSceneSwitchComplete == true then return end
    print("actionSwitchScene 2")
    local circleColor = { 1, 0.58, 0 }
    M.hideNativeWidgets()

    if e.callBackData ~= nil and e.callBackData.sceneTransitionColor ~= nil then
        circleColor = e.callBackData.sceneTransitionColor
    end
    muiData.circleSceneSwitch = display.newCircle( 0, 0, display.contentWidth + (display.contentWidth * 0.25))
    muiData.circleSceneSwitch:setFillColor( unpack(circleColor) )
    muiData.circleSceneSwitch.alpha = 1
    muiData.circleSceneSwitch.callBackData = e.callBackData
    transition.to( muiData.circleSceneSwitch, { time=0, width=M.getScaleVal(100), height=M.getScaleVal(100), onComplete=M.postActionForSwitchScene }) --, onComplete=postActionForButton } )
end

function M.postActionForSwitchScene(e)
    -- enlarge circle
    if muiData.circleSceneSwitch == nil then return end
    transition.to( muiData.circleSceneSwitch, { time=900, xScale=2, yScale=2, onComplete=M.finalActionForSwitchScene } )
end

function M.finalActionForSwitchScene(e)
    -- switch to scene
    if muiData.circleSceneSwitch == nil then return end
    muiData.circleSceneSwitch.isVisible = false
    muiData.circleSceneSwitch:removeSelf()
    muiData.circleSceneSwitch = nil
    muiData.circleSceneSwitchComplete = true
    if e.callBackData ~= nil and e.callBackData.sceneDestination ~= nil then
        composer.removeScene( muiData.scene.name )
        composer.gotoScene( e.callBackData.sceneDestination )
    end
end
--[[ end switch scene action ]]

function M.isTouchPointOutOfRange( event )
    local success = false

    if event ~= nil then
        if event.x < event.target.contentBounds.xMin or
           event.x > event.target.contentBounds.xMax or
           event.y < event.target.contentBounds.yMin or
           event.y > event.target.contentBounds.yMax then
           success = true
        end
    end

    return success
end

function M.scrollListener( event )
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
    --[[--
    if ( event.limitReached ) then
        if ( event.direction == "up" ) then print( "Reached bottom limit" )
        elseif ( event.direction == "down" ) then print( "Reached top limit" )
        elseif ( event.direction == "left" ) then print( "Reached right limit" )
        elseif ( event.direction == "right" ) then print( "Reached left limit" )
        end
    end
    --]]--

    return true
end

function M.showNativeInput(event)
    local name = event.target.name
    local dialogName = event.target.dialogName
    muiData.currentNativeFieldName = name

    if muiData.dialogInUse == true and dialogName == nil then return end
    if event.phase == "began" then

        local madeAdjustment = false
        if muiData.widgetDict[name]["scrollView"] ~= nil then
            madeAdjustment = M.adjustNativeInputIntoView(event)
        end

        muiData.widgetDict[name]["textfieldfake"].isVisible = false
        muiData.widgetDict[name]["textfield"].isVisible = true
        muiData.widgetDict[name]["textfield"].isSecure = muiData.widgetDict[name]["isSecure"]
        if madeAdjustment == false then
            timer.performWithDelay(100, function() native.setKeyboardFocus(muiData.widgetDict[name]["textfield"]) end, 1)
        end
    end
end

function M.adjustNativeInputIntoView(event)
    local name = event.target.name
    local height = muiData.widgetDict[name]["textfield"].contentHeight
    local scrollViewHeight = muiData.widgetDict[name]["scrollView"].contentHeight
    local topMargin = mathFloor(scrollViewHeight * 0.25)
    local bottomMargin = mathFloor(scrollViewHeight * 0.9)
    local x, y = muiData.widgetDict[name]["scrollView"]:getContentPosition()
    local scrollDuration = 500
    local destY = nil
    local scrollOptions = nil
    local madeAdjustment = false


    if event.y > bottomMargin then
        destY = y - height
        scrollOptions = {
            y = destY
        }
    elseif event.y < topMargin then
        local offset = 0
        local widgetY = muiData.widgetDict[name]["container"].y
        local diffY = mathABS(widgetY) - mathABS(y)
        local scrollAmount = height - diffY
        destY = y + scrollAmount
        if muiData.widgetDict[name]["type"] == "TextField" then
            offset = height
        end
        scrollOptions = {
            y = destY + offset
        }
    end
    if destY ~= nil then
        scrollOptions.time = scrollDuration
        scrollOptions.onComplete = M.adjustScrollViewComplete
        madeAdjustment = true
        muiData.widgetDict[name]["scrollView"]:scrollToPosition(scrollOptions)
    end

    return madeAdjustment
end

function M.adjustScrollViewComplete(event)
    local name = muiData.currentNativeFieldName
    timer.performWithDelay(100, function() native.setKeyboardFocus(muiData.widgetDict[name]["textfield"]) end, 1)
end

function M.hideWidget(widgetName, options)
  if showWidget == nil then showWidget = false end
  for widget in pairs(muiData.widgetDict) do
      local widgetType = muiData.widgetDict[widget]["type"]
      if widgetType ~= nil then
        if widgetType == "RRectButton" or widgetType == "RectButton" then
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        elseif widgetType == "IconButton" or widgetType == "RadioButton" then
            muiData.widgetDict[widget]["mygroup"].isVisible = showWidget
        elseif widgetType == "Toolbar" then
            -- not yet supported
        elseif widgetType == "TableView" then
            muiData.widgetDict[widget]["tableview"].isVisible = showWidget
        elseif widgetType == "TextField" or widgetType == "TextBox" then
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        elseif widgetType == "ProgressBar" or widgetType == "ToggleSwitch" then
            muiData.widgetDict[widget]["mygroup"].isVisible = showWidget
        elseif widgetType == "Slider" then
            muiData.widgetDict[widget]["sliderrect"].isVisible = showWidget
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        elseif widgetType == "Toast" or widgetType == "Selector" then
            muiData.widgetDict[widget]["container"].isVisible = showWidget
        end
      end
  end
end

function M.hideNativeWidgets()
  for widget in pairs(muiData.widgetDict) do
      local widgetType = muiData.widgetDict[widget]["type"]
      if widgetType ~= nil then
        if widgetType == "TextField" or widgetType == "TextBox" then
            muiData.widgetDict[widget]["textfield"].isVisible = false
        end
      end
  end
end

function M.removeWidgets()
  print("Removing widgets")
  for widget in pairs(muiData.widgetDict) do
      local widgetType = muiData.widgetDict[widget]["type"]
      if widgetType ~= nil and muiData.widgetDict[widget] ~= nil then
        if widgetType == "RRectButton" then
            M.removeWidgetRRectButton(widget)
        elseif widgetType == "RectButton" then
            M.removeWidgetRectButton(widget)
        elseif widgetType == "IconButton" then
            M.removeWidgetIconButton(widget)
        elseif widgetType == "RadioButton" then
            M.removeWidgetRadioButton(widget)
        elseif widgetType == "Toolbar" then
            M.removeWidgetToolbar(widget)
        elseif widgetType == "TableView" then
            M.removeWidgetTableView(widget)
        elseif widgetType == "TextField" then
            M.removeWidgetTextField(widget)
        elseif widgetType == "TextBox" then
            M.removeWidgetTextBox(widget)
        elseif widgetType == "ProgressBar" then
            M.removeWidgetProgressBar(widget)
        elseif widgetType == "ToggleSwitch" then
            M.removeWidgetToggleSwitch(widget)
        elseif widgetType == "Slider" then
            M.removeWidgetSlider(widget)
        elseif widgetType == "Toast" then
            M.removeWidgetToast(widget)
        elseif widgetType == "Selector" then
            M.removeWidgetSelector(widget)
        elseif widgetType == "Navbar" then
            M.removeNavbar(widget)
        end
      end
  end
  Runtime:removeEventListener( "touch", M.eventSuperListner )

end


function M.removeWidgetRRectButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", muiData.widgetDict[widgetName]["rrect"])
    muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
    muiData.widgetDict[widgetName]["myCircle"] = nil
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    muiData.widgetDict[widgetName]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect"] = nil
    muiData.widgetDict[widgetName]["rrect2"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect2"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetRectButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", muiData.widgetDict[widgetName]["rrect"])
    muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
    muiData.widgetDict[widgetName]["myCircle"] = nil
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    muiData.widgetDict[widgetName]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetIconButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["myText"]:removeEventListener("touch", muiData.widgetDict[widgetName]["myText"])
    muiData.widgetDict[widgetName]["myCircle"]:removeSelf()
    muiData.widgetDict[widgetName]["myCircle"] = nil
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetRadioButton(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    for name in pairs(muiData.widgetDict[widgetName]["radio"]) do
        muiData.widgetDict[widgetName]["radio"][name]["myText"]:removeEventListener( "touch", muiData.widgetDict[widgetName]["radio"][name]["myText"] )
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

function M.removeWidgetToolbar(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    for name in pairs(muiData.widgetDict[widgetName]["toolbar"]) do
        M.removeWidgetToolbarButton(muiData.widgetDict, widgetName, name)
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
            widgetDict[toolbarName]["toolbar"][name]["rectangle"]:removeEventListener( "touch", muiData.widgetDict[toolbarName]["toolbar"][name]["rectangle"] )
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

function M.removeWidgetTableView(widgetName)
    if widgetName == nil then
        return
    end
    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["tableview"]:deleteAllRows()
    muiData.widgetDict[widgetName]["tableview"]:removeSelf()
    muiData.widgetDict[widgetName]["tableview"] = nil
end

function M.removeWidgetTextField(widgetName)
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
    M.removeWidgetTextField(widgetName)
end

function M.removeWidgetProgressBar(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["progressbackdrop"]:removeSelf()
    muiData.widgetDict[widgetName]["progressbackdrop"] = nil
    muiData.widgetDict[widgetName]["progressbar"]:removeSelf()
    muiData.widgetDict[widgetName]["progressbar"] = nil
    if muiData.widgetDict[widgetName]["label"] ~= nil then
        muiData.widgetDict[widgetName]["label"]:removeSelf()
        muiData.widgetDict[widgetName]["label"] = nil
    end
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetToggleSwitch(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["mygroup"]["circle"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["circle"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["circle2"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["circle2"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["circle1"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["circle1"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["rect"] = nil
    muiData.widgetDict[widgetName]["mygroup"]["rectmaster"]:removeEventListener("touch", muiData.widgetDict[widgetName]["rectmaster"])
    muiData.widgetDict[widgetName]["mygroup"]["rectmaster"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"]["rectmaster"] = nil
    muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
    muiData.widgetDict[widgetName]["mygroup"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetDialog()
    if muiData.dialogName == nil then
        return
    end
    local widgetName = muiData.dialogName

    if muiData.widgetDict[widgetName] == nil then return end

    -- remove buttons
    M.removeWidgetRectButton("okay_dialog_button")
    M.removeWidgetRectButton("cancel_dialog_button")

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

function M.removeWidgetSlider(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["sliderrect"]:removeEventListener("touch", muiData.widgetDict[widgetName]["sliderrect"])
    muiData.widgetDict[widgetName]["slidercircle"]:removeSelf()
    muiData.widgetDict[widgetName]["slidercircle"] = nil
    muiData.widgetDict[widgetName]["sliderbar"]:removeSelf()
    muiData.widgetDict[widgetName]["sliderbar"] = nil
    muiData.widgetDict[widgetName]["sliderrect"]:removeSelf()
    muiData.widgetDict[widgetName]["sliderrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetToast(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["rrect"]:removeEventListener("touch", muiData.widgetDict[widgetName]["sliderrect"])
    muiData.widgetDict[widgetName]["myText"]:removeSelf()
    muiData.widgetDict[widgetName]["myText"] = nil
    muiData.widgetDict[widgetName]["rrect"]:removeSelf()
    muiData.widgetDict[widgetName]["rrect"] = nil
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeWidgetSelector(widgetName, listonly)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if listonly ~= nil then
        M.removeWidgetTableView(widgetName .. "-List")
        M.removeSelectorGroup(widgetName)
        return
    else
        M.removeWidgetTableView(widgetName .. "-List")
    end

    muiData.widgetDict[widgetName]["selectorfieldfake"]:removeEventListener("touch", M.selectorListener)

    muiData.widgetDict[widgetName]["selectorfieldarrow"]:removeSelf()
    muiData.widgetDict[widgetName]["selectorfieldarrow"] = nil
    muiData.widgetDict[widgetName]["selectorfieldfake"]:removeSelf()
    muiData.widgetDict[widgetName]["selectorfieldfake"] = nil
    muiData.widgetDict[widgetName]["textlabel"]:removeSelf()
    muiData.widgetDict[widgetName]["textlabel"] = nil
    muiData.widgetDict[widgetName]["rect"]:removeSelf()
    muiData.widgetDict[widgetName]["rect"] = nil
    muiData.widgetDict[widgetName]["line"]:removeSelf()
    muiData.widgetDict[widgetName]["line"] = nil
    M.removeSelectorGroup(widgetName)
    muiData.widgetDict[widgetName]["container"]:removeSelf()
    muiData.widgetDict[widgetName]["container"] = nil
    muiData.widgetDict[widgetName] = nil
end

function M.removeSelectorGroup(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if muiData.widgetDict[widgetName]["rect2"] ~= nil then
        muiData.widgetDict[widgetName]["rect2"]:removeSelf()
        muiData.widgetDict[widgetName]["rect2"] = nil
    end
    if muiData.widgetDict[widgetName]["mygroup"] ~= nil then
        muiData.widgetDict[widgetName]["mygroup"]:removeSelf()
        muiData.widgetDict[widgetName]["mygroup"] = nil
    end
end

function M.removeNavbar(widgetName)
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
                M.removeWidgetRRectButton(name)
            elseif widgetType == "RectButton" then
                M.removeWidgetRectButton(name)
            elseif widgetType == "IconButton" then
                M.removeWidgetIconButton(name)
            elseif widgetType == "RectButton" then
                M.removeWidgetSlider(name)
            elseif widgetType == "RectButton" then
                M.removeWidgetTextField(name)
            elseif widgetType == "Generic" then
              if muiData.widgetDict[widgetName]["destroy"] ~= nil and muiData.widgetDict[widgetName]["destroy"][name] ~= nil then
                assert( muiData.widgetDict[widgetName]["destroy"][name] )(event)
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
