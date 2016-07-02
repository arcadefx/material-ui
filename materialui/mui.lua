--[[
    A loosely based Material UI module

    mui.lua

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
local M = {} -- for module array/table

local composer = require( "composer" )
local widget = require( "widget" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

function M.eventSuperListner(event)
    if (event.phase == "ended" or event.phase == "cancelled") and M.currentTargetName ~= nil and M.currentTargetName ~= M.lastTargetName then
        M.lastTargetName = M.currentTargetName
        -- find name in list and type, if slider then force the end!
        for widget in pairs(M.widgetDict) do
            widgetType = M.widgetDict[widget]["type"]
            if widgetType == "Slider" and M.widgetDict[widget].name == M.currentTargetName then
                M.widgetDict[widget]["sliderrect"]:dispatchEvent(event)
                break
            elseif widgetType == "Selector" and M.widgetDict[widget].name == M.currentTargetName then
                if M.widgetDict[M.currentTargetName]["mygroup"] ~= nil then
                    M.widgetDict[M.currentTargetName]["mygroup"].isVisible = false
                    M.currentTargetName = nil
                    M.lastTargetName = ""
                    M.removeWidgetSelector(widget, "listonly")
                end
                break
            elseif widgetType == "Selector" and M.widgetDict[widget] ~= nil then
                if M.widgetDict[widget]["mygroup"] ~= nil and M.widgetDict[widget]["mygroup"].isVisible == true then
                    M.widgetDict[widget]["mygroup"].isVisible = false
                    M.removeWidgetSelector(widget, "listonly")
                end
            end
        end
    end
end

function M.init(data)
  M.environment = system.getInfo("environment")
  M.value = data
  M.screenRatio = M.getSizeRatio()
  M.circleSceneSwitch = nil
  M.circleSceneSwitchComplete = false
  M.touching = false
  M.masterRatio = nil
  M.masterRemainder = nil
  M.tableCircle = nil
  M.widgetDict = {}
  M.progressbarDict = {}
  M.currentNativeFieldName = ""
  M.currentTargetName = ""
  M.lastTargetName = ""
  M.interceptEventHandler = nil
  M.interceptMoved = false
  M.dialogInUse = false
  M.dialogName = nil

  M.scene = composer.getScene(composer.getSceneName("current"))
  M.scene.name = composer.getSceneName("current")
  Runtime:addEventListener( "touch", M.eventSuperListner )
end

function M.updateEventHandler( event )
    if M.interceptEventHandler ~= nil then
        M.interceptEventHandler:touch(event)
    end
    if event.phase == "moved" then
        M.interceptMoved = true
    end
end

function M.updateUI(event, skipName)
    local widgetType = ""

    for widget in pairs(M.widgetDict) do
        if widget ~= skipName or skipName == nil then
            widgetType = M.widgetDict[widget]["type"]
            if (widgetType == "TextField" or widgetType == "TextBox") and M.widgetDict[widget]["textfield"].isVisible == true then
                -- hide the native field
                timer.performWithDelay(100, function() native.setKeyboardFocus(nil) end, 1)
                M.widgetDict[widget]["textfieldfake"].isVisible = true
                M.widgetDict[widget]["textfield"].isVisible = false
            elseif (widgetType == "TextField" or widgetType == "TextBox") and M.widgetDict[widget]["textfield"].isVisible == true then
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
    M.currentTargetName = options.name
    M.lastTargetName = ""
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
        return M.widgetDict[name]
    end
    return nil
end

function M.getWidgetBaseObject(name)
    local widgetData = nil

    if name ~= nil and string.len(name) > 1 then
        for widget in pairs(M.widgetDict) do
          local widgetType = M.widgetDict[widget]["type"]
          if widgetType ~= nil and widget == name then
            if widgetType == "RRectButton" then
               widgetData = M.widgetDict[widget]["container"]
            elseif widgetType == "RectButton" then
               widgetData = M.widgetDict[widget]["container"]
            elseif widgetType == "IconButton" then
               widgetData = M.widgetDict[widget]["mygroup"]
            elseif widgetType == "RadioButton" then
               widgetData = M.widgetDict[widget]["mygroup"]
            elseif widgetType == "Toolbar" then
               -- widgetData = M.widgetDict[widget]["container"]
               print("getWidgetForInsert: Toolbar not supported at this time.")
            elseif widgetType == "TableView" then
               widgetData = M.widgetDict[widget]["tableview"]
            elseif widgetType == "TextField" then
               widgetData = M.widgetDict[widget]["container"]
            elseif widgetType == "TextBox" then
               widgetData = M.widgetDict[widget]["container"]
            elseif widgetType == "ProgressBar" then
               widgetData = M.widgetDict[widget]["mygroup"]
            elseif widgetType == "ToggleSwitch" then
               widgetData = M.widgetDict[widget]["mygroup"]
            elseif widgetType == "Dialog" then
               widgetData = M.widgetDict[widget]["container"]
            elseif widgetType == "Slider" then
               widgetData = M.widgetDict[widget]["container"]
            elseif widgetType == "Toast" then
               widgetData = M.widgetDict[widget]["container"]
            end
          end
        end
    end
    return widgetData
end

function M.getWidgetValue(widgetName)
    if widgetName == nil then return end
    return M.widgetDict[widget]["value"]
end

function M.getScaleVal(n)
    if n == nil then n = 1 end
    return mathFloor(M.getSizeRatio() * n)
end

function M.getSizeRatio()
  if M.masterRatio ~= nil then
    return M.masterRatio
  end
  local divisor = 1
  if string.find(system.orientation, "portrait") ~= nil then
    divisor = 640
  elseif string.find(system.orientation, "landscape") ~= nil then
    divisor = 960
  end

  M.masterRatio = display.contentWidth / divisor
  M.masterRemainder = mathMod(display.contentWidth, divisor)
  return M.masterRatio
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
    M.touching = false
    if M.tableCircle ~= nil then
        M.tableCircle:toBack()
    end
end

function M.subtleRadius2(e)
    transition.fadeOut( e, { time=300, onComplete=M.subtleRadiusDone2 } )
end

function M.subtleRadiusDone2(e)
    e.isVisible = false
    transition.to( e, { time=0,alpha=0.3, xScale=1, yScale=1 } )
    M.touching = false
end

function M.subtleGlowRect( e )
    transition.to( e, { time=300,alpha=1 } )
end

function M.actionForButton( e )
    print("button action!")
end

--[[ switch scene action ]]

function M.actionSwitchScene( e )
    if M.circleSceneSwitchComplete == true then return end
    local circleColor = { 1, 0.58, 0 }
    M.hideNativeWidgets()

    if e.callBackData ~= nil and e.callBackData.sceneTransitionColor ~= nil then
        circleColor = e.callBackData.sceneTransitionColor
    end
    M.circleSceneSwitch = display.newCircle( 0, 0, display.contentWidth + (display.contentWidth * 0.25))
    M.circleSceneSwitch:setFillColor( unpack(circleColor) )
    M.circleSceneSwitch.alpha = 1
    M.circleSceneSwitch.callBackData = e.callBackData
    transition.to( M.circleSceneSwitch, { time=0, width=M.getScaleVal(100), height=M.getScaleVal(100), onComplete=M.postActionForSwitchScene }) --, onComplete=postActionForButton } )
end

function M.postActionForSwitchScene(e)
    -- enlarge circle
    if M.circleSceneSwitch == nil then return end
    transition.to( M.circleSceneSwitch, { time=900, xScale=2, yScale=2, onComplete=M.finalActionForSwitchScene } )
end

function M.finalActionForSwitchScene(e)
    -- switch to scene
    if M.circleSceneSwitch == nil then return end
    M.circleSceneSwitch.isVisible = false
    M.circleSceneSwitch:removeSelf()
    M.circleSceneSwitch = nil
    M.circleSceneSwitchComplete = true
    if e.callBackData ~= nil and e.callBackData.sceneDestination ~= nil then
        composer.removeScene( M.scene.name )
        composer.gotoScene( e.callBackData.sceneDestination )
    end
end
--[[ end switch scene action ]]

function M.actionForPlus( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = "add_circle"
         else
            muiTarget.isChecked = true
            muiTarget.text = "add_circle"
            if muiTargetValue ~= nil then
                print("checkbox value = "..muiTargetValue)
            end
        end
    end
end

function M.actionForCheckbox( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = "check_box_outline_blank"
         else
            muiTarget.isChecked = true
            muiTarget.text = "check_box"
            if muiTargetValue ~= nil then
                print("checkbox value = "..muiTargetValue)
            end
        end
    end
end

function M.actionForRadioButton( e )
    local muiTarget = M.getEventParameter(e, "muiTarget")
    local muiTargetValue = M.getEventParameter(e, "muiTargetValue")

    if muiTarget ~= nil then
        -- uncheck all then check the one that is checked
        local basename = M.getEventParameter(e, "basename")
        local foundName = false

        local list = M.widgetDict[basename]["radio"]
        for k, v in pairs(list) do
            v["myText"].isChecked = false
            v["myText"].text = "radio_button_unchecked"
        end

        if muiTarget.isChecked == true then
            muiTarget.isChecked = false
            muiTarget.text = "radio_button_unchecked"
         else
            muiTarget.isChecked = true
            muiTarget.text = "radio_button_checked"
        end
        if muiTargetValue ~= nil then
            print("radio button value = "..muiTargetValue)
        end
    end
end

function M.actionForToolbar( options, e )
    local target = M.getEventParameter(e, "muiTarget")
    local target2 = M.getEventParameter(e, "muiTarget2")
    if target ~= nil then
        -- uncheck all then check the one that is checked
        local basename = M.getEventParameter(e, "basename")
        local foundName = false
        local list = M.widgetDict[basename]["toolbar"]

        if target.isChecked == true then
            return
        end
        for k, v in pairs(list) do
            if v["myText"] ~= nil then
                v["myText"]:setFillColor( unpack(M.widgetDict[basename]["toolbar"]["labelColorOff"]) )
                if v["myText2"] ~= nil then
                    v["myText2"]:setFillColor( unpack(M.widgetDict[basename]["toolbar"]["labelColorOff"]) )
                end
                v["myText"].isChecked = false
            end
        end

        target:setFillColor( unpack(M.widgetDict[basename]["toolbar"]["labelColor"]) )
        if target2 ~= nil then
            target2:setFillColor( unpack(M.widgetDict[basename]["toolbar"]["labelColor"]) )
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

function M.onRowRender( event )

    -- Get reference to the row group
    local row = event.row

    -- need to use the colors passed in as params here.
 
    noLines = false
    lineHeight = M.getScaleVal(4)
    lineColor = { 0.9, 0.9, 0.9 }
    rowColor = { 1, 1, 1, 1 }
    textColor = { 0, 0, 0, 1 }
    font = native.systemFont

    if row.params ~= nil then
        if row.params.noLines ~= nil then noLines = row.params.noLines end

        if row.params.lineHeight ~= nil then
            lineHeight = row.params.lineHeight
            if lineHeight == 1 then lineHeight = 2 end
        end

        if row.params.lineColor ~= nil then lineColor = row.params.lineColor end

        if row.params.rowColor ~= nil then
            rowColor = row.params.rowColor
        end

        if row.params.textColor ~= nil then textColor = row.params.textColor end
        if row.params.font ~= nil then font = row.params.font end
    end

    if noLines == false and lineHeight > 0 then
        -- line underneath label
        row.bg1 = display.newRect( 0, 0, row.contentWidth, row.contentHeight - M.getScaleVal(1) )
        row.bg1.anchorX = 0
        row.bg1.anchorY = 0
        row.bg1:setFillColor( unpack( lineColor ) ) -- transparent
        row:insert( row.bg1 )

        -- the block above line
        row.bg2 = display.newRect( 0, 0, row.contentWidth, row.contentHeight - M.getScaleVal(lineHeight) )
        row.bg2.anchorX = 0
        row.bg2.anchorY = 0
        row.bg2:setFillColor( unpack( rowColor ) ) -- transparent
        row:insert( row.bg2 )
    else
        row.bg1 = display.newRect( 0, 0, row.contentWidth, row.contentHeight)
        row.bg1.anchorX = 0
        row.bg1.anchorY = 0
        row.bg1:setFillColor( unpack( rowColor ) ) -- transparent
        row:insert( row.bg1 )
    end

    function row:touch (event)
        if ( event.phase == "began" ) then
            row.miscEvent = {}
            row.miscEvent.name = row.params.name
            row.miscEvent.x = event.x
            row.miscEvent.y = event.y
            row.miscEvent.minRadius = M.getScaleVal(60) * 0.25
        end
    end
    row:addEventListener( "touch", row )

    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth

    local rowTitle = display.newText( row, row.params.text, 0, 0, font, M.getScaleVal(30) )
    rowTitle:setFillColor( unpack( textColor ) )

    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    rowTitle.x = 0
    rowTitle.y = rowHeight * 0.5
end

function M.onRowTouch( event )
    local phase = event.phase
 
    if M.dialogInUse == true then return end
    local row = event.row

    if "press" == phase and M.touching == false then
        M.touching = true
        M.updateUI(event)
        --print( "Touched row:", event.target.id )
        --print( "Touched row:", event.target.index )
    elseif "release" == phase then
        local row = event.row

        M.tableCircle:toFront()

        M.tableCircle.alpha = 0.55
        if row.miscEvent == nil then return end
        M.tableCircle.x = row.miscEvent.x
        M.tableCircle.y = row.miscEvent.y
        local scaleFactor = 2.5
        M.tableCircle.isVisible = true
        M.tableCircle.myCircleTrans = transition.to( M.tableCircle, { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
        row.myGlowTrans = transition.to( row, { time=300,delay=150,alpha=0.2, transition=easing.outCirc, onComplete=M.subtleGlowRect } )

        M.setEventParameter(event, "muiTarget", row)
        M.setEventParameter(event, "muiTargetIndex", event.target.index)
        if row.params ~= nil then
            M.setEventParameter(event, "muiTargetValue", row.params.value)
        end
        if row.params ~= nil and row.params.callBackTouch ~= nil then
            assert( row.params.callBackTouch )(event)
        end
    end
end

function M.onRowTouchDemo(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")
    local muiTargetIndex = M.getEventParameter(event, "muiTargetIndex")

    if muiTargetIndex ~= nil then
        print("row index: "..muiTargetIndex)
    end

    if muiTargetValue ~= nil then
        print("row value: "..muiTargetValue)
    end
end

function M.onRowTouchSelector(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")
    local muiTargetIndex = M.getEventParameter(event, "muiTargetIndex")

    if muiTargetIndex ~= nil then
        print("row index: "..muiTargetIndex)
    end

    if muiTargetValue ~= nil then
        print("row value: "..muiTargetValue)
    end

    if event.row.miscEvent ~= nil and event.row.miscEvent.name ~= nil then
        local parentName = string.gsub(event.row.miscEvent.name, "-List", "")

        M.widgetDict[parentName]["selectorfieldfake"].text = muiTargetValue
        timer.performWithDelay(500, function() M.finishSelector(parentName) end, 1)
    end
end

function M.finishSelector(parentName)
    M.widgetDict[parentName]["mygroup"].isVisible = false
    M.removeWidgetSelector(parentName, "listonly")
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

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    local nw = options.width + M.getScaleVal(20) --(options.width * 0.05)
    local nh = options.height + M.getScaleVal(20) -- (options.height * 0.05)

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["type"] = "RRectButton"
    M.widgetDict[options.name]["container"] = display.newContainer( nw, nh )
    M.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    M.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["container"] )
    end

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local nr = radius + M.getScaleVal(8) -- (options.height+M.getScaleVal(8)) * 0.2

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

    M.widgetDict[options.name]["rrect2"] = display.newRoundedRect( 0, 1, options.width+M.getScaleVal(8), options.height+M.getScaleVal(8), nr )
    if paint ~= nil then
        M.widgetDict[options.name]["rrect2"].fill = paint
    end
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["rrect2"] )

    local fillColor = { 0, 0.82, 1 }
    if options.fillColor ~= nil then
        fillColor = options.fillColor
    end

    if options.strokeWidth == nil then
        options.strokeWidth = 0
    end

    if options.strokeColor == nil then
        options.strokeColor = { 0.9, 0.9, 0.9, 1 }
    end

    M.widgetDict[options.name]["rrect"] = display.newRoundedRect( 0, 0, options.width, options.height, radius )
    if options.strokeWidth > 0 then
        M.widgetDict[options.name]["rrect"].strokeWidth = 1
        M.widgetDict[options.name]["rrect"]:setStrokeColor( unpack(options.setStrokeColor) )
    end
    M.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["rrect"] )
    M.widgetDict[options.name]["rrect"].dialogName = options.dialogName

    local rrect = M.widgetDict[options.name]["rrect"]

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

    M.widgetDict[options.name]["clickAnimation"] = options.clickAnimation

    M.widgetDict[options.name]["font"] = font
    M.widgetDict[options.name]["fontSize"] = fontSize
    M.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = fontSize * ( ( rrect.contentHeight - textMargin ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    textToMeasure:removeSelf()
    textToMeasure = nil

    M.widgetDict[options.name]["myText"] = display.newText( options.text, 0, 0, font, fontSize )
    M.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["myText"], true )

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    M.widgetDict[options.name]["myCircle"] = display.newCircle( options.height, options.height, radius )
    M.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )
    M.widgetDict[options.name]["myCircle"].isVisible = false
    M.widgetDict[options.name]["myCircle"].alpha = 0.3
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    local maxWidth = M.widgetDict[options.name]["rrect"].path.width - (radius * 2)
    local scaleFactor = (maxWidth / radius) * 0.5 -- (since this is a radius of circle)

    function rrect:touch (event)
        if M.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            --event.target:takeFocus(event)
            -- if scrollView then use the below
            M.interceptEventHandler = rrect
            M.updateUI(event)
            if M.touching == false then
                M.touching = true
                if options.clickAnimation ~= nil then
                    if options.clickAnimation["colorBackground"] ~= nil then
                        M.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.clickAnimation["colorBackground"]) )
                    end
                end
                if options.touchpoint ~= nil and options.touchpoint == true then
                    M.widgetDict[options.name]["myCircle"].x = event.x - M.widgetDict[options.name]["container"].x
                    M.widgetDict[options.name]["myCircle"].y = event.y - M.widgetDict[options.name]["container"].y
                end
                M.widgetDict[options.name]["myCircle"].isVisible = true
                M.widgetDict[options.name].myCircleTrans = transition.to( M.widgetDict[options.name]["myCircle"], { time=500,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(M.widgetDict[options.name]["container"],{time=300, xScale=1.02, yScale=1.02, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "moved" ) then
            if options.fillColor ~= nil then
                M.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                  event.phase = "offTarget"
                  -- print("Its out of the button area")
                  -- event.target:dispatchEvent(event)
            else
                event.phase = "onTarget"
                if M.interceptMoved == false then
                    if options.clickAnimation ~= nil then
                        if options.clickAnimation["time"] == nil then
                            options.clickAnimation["time"] = 400
                        end
                        transition.fadeOut(M.widgetDict[options.name]["rrect"],{time=options.clickAnimation["time"]})
                    end
                    event.target = M.widgetDict[options.name]["rrect"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", M.widgetDict[options.name]["rrect"])

                    assert( options.callBack )(event)
                end
            end
            M.interceptEventHandler = nil
            M.interceptMoved = false
            M.touching = false
        end
    end
    M.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.widgetDict[options.name]["rrect"] )
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

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["type"] = "RectButton"
    M.widgetDict[options.name]["container"] = display.newContainer( options.width+4, options.height+4 )
    M.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    M.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["container"] )
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

    M.widgetDict[options.name]["rrect"] = display.newRect( 0, 0, options.width, options.height )
    if paint ~= nil then
        M.widgetDict[options.name]["rrect"].fill = paint
    end
    M.widgetDict[options.name]["rrect"].strokeWidth = strokeWidth
    M.widgetDict[options.name]["rrect"]:setFillColor( unpack(fillColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["rrect"] )

    local rrect = M.widgetDict[options.name]["rrect"]

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

    M.widgetDict[options.name]["font"] = font
    M.widgetDict[options.name]["fontSize"] = fontSize
    M.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    fontSize = fontSize * ( ( rrect.contentHeight - textMargin ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    textToMeasure:removeSelf()
    textToMeasure = nil

    M.widgetDict[options.name]["myText"] = display.newText( options.text, 0, 0, font, fontSize )
    M.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["myText"], true )

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    local radius = options.height * 0.1
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    M.widgetDict[options.name]["myCircle"] = display.newCircle( options.height, options.height, radius )
    M.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )
    M.widgetDict[options.name]["myCircle"].isVisible = false
    M.widgetDict[options.name]["myCircle"].alpha = 0.3
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    local maxWidth = (M.widgetDict[options.name]["rrect"].path.width * 2) - (radius * 2)
    local scaleFactor = (maxWidth / radius) * 0.5 -- (since this is a radius of circle)

    function rrect:touch (event)
        if M.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            M.interceptEventHandler = rrect
            M.updateUI(event)
            if M.touching == false then
                M.touching = true
                if options.clickAnimation ~= nil then
                    if options.clickAnimation["colorBackground"] ~= nil then
                        M.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.clickAnimation["colorBackground"]) )
                    end
                end
                if options.touchpoint ~= nil and options.touchpoint == true then
                    M.widgetDict[options.name]["myCircle"].x = event.x - M.widgetDict[options.name]["container"].x
                    M.widgetDict[options.name]["myCircle"].y = event.y - M.widgetDict[options.name]["container"].y
                end
                M.widgetDict[options.name]["myCircle"].isVisible = true
                M.widgetDict[options.name].myCircleTrans = transition.to( M.widgetDict[options.name]["myCircle"], { time=500,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(M.widgetDict[options.name]["container"],{time=500, xScale=1.02, yScale=1.02, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "moved" ) then
            if options.fillColor ~= nil then
                M.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- print("Its out of the button area")
                -- event.target:dispatchEvent(event)
            else
              event.phase = "onTarget"
                if M.interceptMoved == false then
                    if options.clickAnimation ~= nil then
                        if options.clickAnimation["time"] == nil then
                            options.clickAnimation["time"] = 400
                        end
                        transition.fadeOut(M.widgetDict[options.name]["rrect"],{time=options.clickAnimation["time"]})
                    end
                    event.target = M.widgetDict[options.name]["rrect"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", M.widgetDict[options.name]["rrect"])

                    assert( options.callBack )(event)
                end
                M.interceptEventHandler = nil
                M.interceptMoved = false
                M.touching = false
            end
        end
    end
    M.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.widgetDict[options.name]["rrect"] )
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

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["type"] = "IconButton"
    M.widgetDict[options.name]["mygroup"] = display.newGroup()
    M.widgetDict[options.name]["mygroup"].x = x
    M.widgetDict[options.name]["mygroup"].y = y
    M.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["mygroup"] )
    end

    local radius = options.height * (0.2 * M.getSizeRatio())
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

    M.widgetDict[options.name]["font"] = font
    M.widgetDict[options.name]["fontSize"] = fontSize
    M.widgetDict[options.name]["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local checkbox = {contentHeight=options.height, contentWidth=options.width}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    local fontSize = fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight )
    local tw = textToMeasure.contentWidth
    local th = textToMeasure.contentHeight

    textToMeasure:removeSelf()
    textToMeasure = nil

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

    M.widgetDict[options.name]["myText"] = display.newText( options2 )
    M.widgetDict[options.name]["myText"]:setFillColor( unpack(textColor) )
    M.widgetDict[options.name]["myText"].isVisible = true
    if isChecked then
        M.widgetDict[options.name]["myText"].isChecked = isChecked
    end
    M.widgetDict[options.name]["value"] = isChecked

    M.widgetDict[options.name]["mygroup"]:insert( M.widgetDict[options.name]["myText"], true )

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    M.widgetDict[options.name]["myCircle"] = display.newCircle( 0, 0, radius )
    M.widgetDict[options.name]["myCircle"]:setFillColor( unpack(circleColor) )

    M.widgetDict[options.name]["myCircle"].isVisible = false
    M.widgetDict[options.name]["myCircle"].x = 0
    M.widgetDict[options.name]["myCircle"].y = 0
    M.widgetDict[options.name]["myCircle"].alpha = 0.3
    M.widgetDict[options.name]["mygroup"]:insert( M.widgetDict[options.name]["myCircle"], true ) -- insert and center bkgd

    checkbox = M.widgetDict[options.name]["myText"]

    local radiusOffset = 2.5
    if M.masterRatio > 1 then radiusOffset = 2.0 end
    local maxWidth = checkbox.contentWidth - (radius * radiusOffset)
    local scaleFactor = ((maxWidth * (1.3 * M.masterRatio)) / radius) -- (since this is a radius of circle)

    function checkbox:touch (event)
        if M.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            M.interceptEventHandler = checkbox
            M.updateUI(event)
            if M.touching == false then
                M.touching = true
                if options.touchpoint ~= nil and options.touchpoint == true then
                    M.widgetDict[options.name]["myCircle"].x = event.x - M.widgetDict[options.name]["mygroup"].x
                    M.widgetDict[options.name]["myCircle"].y = event.y - M.widgetDict[options.name]["mygroup"].y
                end
                M.widgetDict[options.name]["myCircle"].isVisible = true
                M.widgetDict[options.name].myCircleTrans = transition.to( M.widgetDict[options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(checkbox,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- event.target:dispatchEvent(event)
                -- print("Its out of the button area")
            else
              event.phase = "onTarget"
                if M.interceptMoved == false then
                    event.target = M.widgetDict[options.name]["checkbox"]
                    event.altTarget = M.widgetDict[options.name]["myText"]
                    event.myTargetName = options.name
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", M.widgetDict[options.name]["myText"])

                    assert( options.callBack )(event)
                end
                M.interceptEventHandler = nil
                M.interceptMoved = false
                M.touching = false
            end
        end
    end
    M.widgetDict[options.name]["myText"]:addEventListener( "touch", M.widgetDict[options.name]["myText"] )
end

function M.createCheckBox(options)
    M.createIconButton({
        name = options.name,
        text = "check_box_outline_blank",
        width = options.width,
        height = options.height,
        x = options.x,
        y = options.y,
        font = "MaterialIcons-Regular.ttf",
        textColor = options.textColor,
        textAlign = "center",
        callBack = M.actionForCheckbox
    })
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

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    M.widgetDict[options.basename]["radio"][options.name] = {}
    M.widgetDict[options.basename]["type"] = "RadioButton"

    local radioButton =  M.widgetDict[options.basename]["radio"][options.name]
    radioButton["mygroup"] = display.newGroup()
    radioButton["mygroup"].x = x
    radioButton["mygroup"].y = y
    radioButton["touching"] = false

    if options.scrollView ~= nil and M.widgetDict[options.name]["scrollView"] == nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["mygroup"] )
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

    radioButton["font"] = font
    radioButton["fontSize"] = fontSize
    radioButton["textMargin"] = textMargin

    -- scale font
    -- Calculate a font size that will best fit the given text field's height
    local checkbox = {contentHeight=options.height, contentWidth=options.width}
    local textToMeasure = display.newText( options.text, 0, 0, font, fontSize )
    local fontSize = fontSize * ( ( checkbox.contentHeight ) / textToMeasure.contentHeight )
    fontSize = mathFloor(tonumber(fontSize))
    local textWidth = textToMeasure.contentWidth
    local textHeight = textToMeasure.contentHeight
    textToMeasure:removeSelf()
    textToMeasure = nil

    local options2 = 
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        font = font,
        width = textWidth,
        fontSize = fontSize,
        align = "center"
    }

    radioButton["myText"] = display.newText( options2 )
    radioButton["myText"]:setFillColor( unpack(textColor) )
    radioButton["myText"].isVisible = true
    if isChecked then
        if options.textOn ~= nil then
            radioButton["myText"].text = options.textOn
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
    labelX = radioButton["myText"].x + (textWidth * 0.5) + labelSpacing    
    labelX = labelX + (labelWidth * 0.5)
    local options3 = 
    {
        --parent = M.widgetDict[options.name]["mygroup"],
        text = options.label,
        x = mathFloor(labelX),
        y = 0,
        width = labelWidth,
        font = labelFont,
        fontSize = fontSize
    }

    radioButton["myLabel"] = display.newText( options3 )
    radioButton["myLabel"]:setFillColor( unpack(labelColor) )
    radioButton["myLabel"]:setStrokeColor( 0 )
    radioButton["myLabel"].strokeWidth = 3
    radioButton["myLabel"].isVisible = true
    radioButton["mygroup"]:insert( radioButton["myLabel"], false )

    -- add the animated circle

    local circleColor = textColor
    if options.circleColor ~= nil then
        circleColor = options.circleColor
    end

    radioButton["myCircle"] = display.newCircle( options.height, options.height, radius )
    radioButton["myCircle"]:setFillColor( unpack(circleColor) )
    radioButton["myCircle"].isVisible = false
    radioButton["myCircle"].x = 0
    radioButton["myCircle"].y = 0
    radioButton["myCircle"].alpha = 0.3
    radioButton["mygroup"]:insert( radioButton["myCircle"], true ) -- insert and center bkgd

    local maxWidth = checkbox.contentWidth - (radius * 2.5)
    local scaleFactor = ((maxWidth * 1.3) / radius) -- (since this is a radius of circle)

    checkbox = radioButton["myText"]

    function checkbox:touch (event)
        if M.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            M.interceptEventHandler = checkbox
            M.updateUI(event)
            if M.touching == false then
                M.touching = true
                if options.touchpoint ~= nil and options.touchpoint == true then
                    M.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - M.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                    M.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - M.widgetDict[options.basename]["radio"][options.name]["mygroup"].y
                end
                M.widgetDict[options.basename]["radio"][options.name]["myCircle"].isVisible = true
                M.widgetDict[options.basename]["radio"][options.name].myCircleTrans = transition.to( M.widgetDict[options.basename]["radio"][options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                transition.to(checkbox,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- event.target:dispatchEvent(event)
                -- print("Its out of the button area")
            else
              event.phase = "onTarget"
                if M.interceptMoved == false then
                    --event.target = M.widgetDict[options.name]["rrect"]
                    event.myTargetName = options.name
                    event.myTargetBasename = options.basename
                    event.altTarget = M.widgetDict[options.basename]["radio"][options.name]["myText"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", M.widgetDict[options.basename]["radio"][options.name]["myText"])

                    assert( options.callBack )(event)
                end
                M.interceptEventHandler = nil
                M.interceptMoved = false
                M.touching = false
            end
        end
    end
    M.widgetDict[options.basename]["radio"][options.name]["myText"]:addEventListener( "touch", M.widgetDict[options.basename]["radio"][options.name]["myText"] )

end


function M.createRadioGroup(options)

    local x, y = options.x, options.y

    if options.isChecked == nil then
        options.isChecked = false
    end

    if options.spacing == nil then
        options.spacing = 10
    end

    if options.list ~= nil then
        local count = 0
        M.widgetDict[options.name] = {}
        M.widgetDict[options.name]["radio"] = {}
        M.widgetDict[options.name]["type"] = "RadioGroup"
        for i, v in ipairs(options.list) do            
            M.createRadioButton({
                name = options.name .. "_" .. i,
                basename = options.name,
                label = v.key,
                value = v.value,
                text = "radio_button_unchecked",
                textOn = "radio_button_checked",
                width = options.width,
                height = options.height,
                x = x,
                y = y,
                isChecked = v.isChecked,
                font = "MaterialIcons-Regular.ttf",
                labelFont = options.labelFont,
                textColor = { 1, 0, 0.4 },
                textAlign = "center",
                labelColor = options.labelColor,
                callBack = options.callBack
            })
            local radioButton = M.widgetDict[options.name]["radio"][options.name.."_"..i]
            if options.layout ~= nil and options.layout == "horizontal" then
                width = radioButton["myText"].contentWidth + radioButton["myLabel"].contentWidth + options.spacing
                x = x + width + (radioButton["myText"].contentWidth * 0.2)
            else
                y = y + radioButton["myText"].contentHeight + options.spacing
            end
            count = count + 1
        end
    end

end


function M.createToolbarButton( options )
    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    local barWidth = display.contentWidth
    if options.width ~= nil then
        barWidth = options.width
    end

    if options.index ~= nil and options.index == 1 then
        local rectBak = display.newRect( 0, 0, barWidth, options.buttonHeight )
        rectBak:setFillColor( unpack( options.backgroundColor ) )
        rectBak.x = options.x + barWidth * 0.5
        rectBak.y = y
        M.widgetDict[options.basename]["toolbar"]["rectBak"] = rectBak
        --button["mygroup"]:insert( rectBak, true ) -- insert and center bkgd
    end

    --M.widgetDict[options.name] = {}
    --M.widgetDict[options.name].basename = options.basename
    M.widgetDict[options.basename]["toolbar"][options.name] = {}
    M.widgetDict[options.basename]["toolbar"]["type"] = "ToolbarButton"

    local button =  M.widgetDict[options.basename]["toolbar"][options.name]
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
    M.widgetDict[options.basename]["toolbar"]["labelColorOff"] = options.labelColorOff
    M.widgetDict[options.basename]["toolbar"]["labelColor"] = options.labelColor

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

    button["myCircle"] = display.newCircle( options.height, options.height, radius )
    button["myCircle"]:setFillColor( unpack(circleColor) )
    button["myCircle"].isVisible = false
    button["myCircle"].x = 0
    button["myCircle"].y = 0
    button["myCircle"].alpha = 0.3
    button["mygroup"]:insert( button["myCircle"], true ) -- insert and center bkgd

    local maxWidth = field.contentWidth - (radius * 2.5)
    local scaleFactor = ((maxWidth * 1.3) / radius) -- (since this is a radius of circle)

    thebutton = button["rectangle"]
    field = button["myText"]
    thebutton.name = options.name
    field.name = options.name

    function thebutton:touch (event)
        if M.widgetDict[options.basename]["toolbar"][options.name]["myText"].isChecked == true then
            return
        end

        M.addBaseEventParameters(event, options)

        if M.dialogInUse == true and options.dialogName == nil then return end
        if ( event.phase == "began" ) then
            M.interceptEventHandler = thebutton
            M.updateUI(event)
            if M.touching == false then
                M.touching = true
                if options.touchpoint ~= nil and options.touchpoint == true then
                    M.widgetDict[options.basename]["toolbar"][options.name]["myCircle"].x = event.x - M.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                    M.widgetDict[options.basename]["toolbar"][options.name]["myCircle"].y = event.y - M.widgetDict[options.basename]["toolbar"][options.name]["mygroup"].y
                    M.widgetDict[options.basename]["toolbar"][options.name]["myCircle"].isVisible = true
                    M.widgetDict[options.basename]["toolbar"][options.name].myCircleTrans = transition.to( M.widgetDict[options.basename]["toolbar"][options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                end
                transition.to(field,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- event.target:dispatchEvent(event)
                -- print("Its out of the button area")
            else
                event.phase = "onTarget"
                if M.interceptMoved == false then
                    --event.target = M.widgetDict[options.name]["rrect"]
                    transition.to(M.widgetDict[options.basename]["toolbar"]["slider"],{time=350, x=button["mygroup"].x, transition=easing.inOutCubic})

                    event.myTargetName = options.name
                    event.myTargetBasename = options.basename
                    event.altTarget = M.widgetDict[options.basename]["toolbar"][options.name]["myText"]
                    event.altTarget2 = M.widgetDict[options.basename]["toolbar"][options.name]["myText2"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", M.widgetDict[options.basename]["toolbar"][options.name]["myText"])
                    M.setEventParameter(event, "muiTarget2", M.widgetDict[options.basename]["toolbar"][options.name]["myText2"])
                    M.actionForToolbar(options, event)
                end
                M.interceptEventHandler = nil
                M.interceptMoved = false
                M.touching = false
            end
        end
    end

    M.widgetDict[options.basename]["toolbar"][options.name]["rectangle"]:addEventListener( "touch", M.widgetDict[options.basename]["toolbar"][options.name]["rectangle"] )
end


function M.createToolbar( options )
    local x, y = options.x, options.y
    local buttonWidth = 1
    local buttonOffset = 0

    if options.isChecked == nil then
        options.isChecked = false
    end

    if options.sliderColor == nil then
        options.sliderColor = { 1, 1, 1 }
    end

    if options.list ~= nil then
        local count = #options.list
        M.widgetDict[options.name] = {}
        M.widgetDict[options.name]["toolbar"] = {}
        M.widgetDict[options.name]["type"] = "Toolbar"
        for i, v in ipairs(options.list) do            
            M.createToolbarButton({
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
                isChecked = v.isChecked,
                font = "MaterialIcons-Regular.ttf",
                labelText = v.labelText,
                labelFont = options.labelFont,
                labelFontSize = options.labelFontSize,
                textColor = options.labelColor,
                textColorOff = options.labelColorOff,
                textAlign = "center",
                labelColor = options.labelColor,
                backgroundColor = options.color,
                numberOfButtons = count,
                callBack = options.callBack,
                callBackData = options.callBackData
            })
            local button = M.widgetDict[options.name]["toolbar"][options.name.."_"..i]
            buttonWidth = button["buttonWidth"]
            if i == 1 then buttonOffset = button["buttonOffset"] end
            if options.layout ~= nil and options.layout == "horizontal" then
                x = x + button["buttonWidth"] + button["buttonOffset"]
            else
                y = y + button["buttonHeight"]
            end
        end

        -- slider highlight
        local sliderHeight = options.buttonHeight * 0.05
        M.widgetDict[options.name]["toolbar"]["slider"] = display.newRect( buttonOffset, display.contentHeight - (sliderHeight * 0.5), buttonWidth, sliderHeight )
        M.widgetDict[options.name]["toolbar"]["slider"]:setFillColor( unpack( options.sliderColor ) )
    end
end

function M.createTableView( options )
    local screenRatio = M.getSizeRatio()
    -- The "onRowRender" function may go here (see example under "Inserting Rows", above)

    if options.noLines == nil then
        options.noLines = false
    end

    if options.circleColor == nil then
        options.circleColor = { 0.4, 0.4, 0.4 }
    end

    if options.touchpointColor ~= nil then
        options.circleColor = options.touchpointColor
    end

    if options.font == nil then
        options.font = native.systemFont
    end

    if options.strokeWidth == nil then
        options.strokeWidth = 0
    end

    if options.strokeColor == nil then
        options.strokeColor = { 0.8, 0.8, 0.8, .4 }
    end

    M.tableCircle = display.newCircle( 0, 0, M.getScaleVal(20) )
    M.tableCircle:setFillColor( unpack(options.circleColor) )
    M.tableCircle.isVisible = false
    M.tableCircle.alpha = 0.55

    -- Create the widget
    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["tableview"] = {}
    M.widgetDict[options.name]["type"] = "TableView"

    local tableView = widget.newTableView(
        {
            left = options.left,
            top = options.top,
            height = options.height,
            width = options.width,
            noLines = options.noLines,
            onRowRender = options.callBackRender,
            onRowTouch = M.onRowTouch,
            listener = options.scrollListener,
        }
    )
    tableView.isVisible = false
    M.widgetDict[options.name]["tableview"] = tableView

    -- Insert the row data
    for i, v in ipairs(options.list) do

        local isCategory = false
        local rowHeight = options.rowHeight
        local rowColor = options.rowColor
        local lineColor = options.lineColor

        -- use categories
        if v.isCategory ~= nil and v.isCategory == true then
            isCategory = true
            rowHeight = M.getScaleVal(rowHeight + (rowHeight * 0.1))
            if options.categoryColor == nil then
                options.categoryColor = { default={0.8,0.8,0.8,0.8} }
            end
            if options.lineColor == nil then
                options.categoryLineColor = { 1, 1, 1, 0 }
            end

            rowColor = options.categoryColor
            lineColor = options.categoryLineColor
        end

        -- Insert a row into the tableView
        local optionList = {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowColor = rowColor,
            lineColor = lineColor,
            params = {
                basename = options.name,
                name = options.name,
                text = v.text,
                font = options.font,
                value = v.value,
                noLines = options.noLines,
                lineHeight = options.lineHeight,
                rowColor = v.backgroundColor,
                textColor = options.textColor,
                callBackData = options.callBackData,
                callBackTouch = options.callBackTouch
            }
        }
        if v.key ~= nil then
            optionList["id"] = v.key
        end
        tableView:insertRow( optionList )
    end
    tableView.isVisible = true

end

--
-- To-do: flow right or below based on parent text widget
--
function M.createTextField(options)

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

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["type"] = "TextField"
    M.widgetDict[options.name]["container"] = display.newContainer( options.width+4, options.height * 4)
    M.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    M.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["container"] )
    end

    if options.inactiveColor == nil then
        options.inactiveColor = { 0.4, 0.4, 0.4, 1 }
    end

    if options.activeColor == nil then
        options.activeColor = { 0.12, 0.67, 0.27, 1 }
    end

    M.widgetDict[options.name]["rect"] = display.newRect( 0, 0, options.width, options.height )
    M.widgetDict[options.name]["rect"].strokeWidth = 0
    M.widgetDict[options.name]["rect"]:setFillColor( 1, 1, 1 )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["rect"] )

    local rect = M.widgetDict[options.name]["rect"]
    M.widgetDict[options.name]["line"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
    M.widgetDict[options.name]["line"].strokeWidth = M.getScaleVal(4)
    M.widgetDict[options.name]["line"]:setStrokeColor( unpack(options.inactiveColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["line"] )

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
    M.widgetDict[options.name]["textlabel"] = display.newText( labelOptions )
    M.widgetDict[options.name]["textlabel"]:setFillColor( unpack(options.inactiveColor) )
    M.widgetDict[options.name]["textlabel"].inactiveColor = options.inactiveColor
    M.widgetDict[options.name]["textlabel"].activeColor = options.activeColor
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["textlabel"] )

    local scaleFontSize = 1
    if M.environment == "simulator" then
        scaleFontSize = 0.75
    end
    M.widgetDict[options.name]["isSecure"] = options.isSecure
    M.widgetDict[options.name]["textfield"] = native.newTextField( 0, 0, options.width, options.height * scaleFontSize )
    M.widgetDict[options.name]["textfield"].name = options.name
    M.widgetDict[options.name]["textfield"].hasBackground = false
    M.widgetDict[options.name]["textfield"].isVisible = false
    M.widgetDict[options.name]["textfield"].inputType = options.inputType
    M.widgetDict[options.name]["textfield"].isSecure = false
    M.widgetDict[options.name]["textfield"].text = options.text
    M.widgetDict[options.name]["textfield"]:setTextColor( unpack(M.widgetDict[options.name]["textlabel"].inactiveColor) )

    local textOptions =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        width = options.width,
        font = options.font,
        fontSize = options.height * 0.55,
        align = "left"  --new alignment parameter
    }
    M.widgetDict[options.name]["textfieldfake"] = display.newText( textOptions )
    M.widgetDict[options.name]["textfieldfake"]:setFillColor( unpack(M.widgetDict[options.name]["textlabel"].inactiveColor) )
    M.widgetDict[options.name]["textfieldfake"]:addEventListener("touch", M.showNativeInput)
    M.widgetDict[options.name]["textfieldfake"].name = options.name
    M.widgetDict[options.name]["textfieldfake"].dialogName = options.dialogName
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["textfieldfake"] )

    -- M.widgetDict[options.name]["textfield"].placeholder = "Subject"
    M.widgetDict[options.name]["textfield"].callBack = options.callBack
    M.widgetDict[options.name]["textfield"]:addEventListener( "userInput", M.textListener )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["textfield"] )
end

function M.showNativeInput(event)
    local name = event.target.name
    local dialogName = event.target.dialogName
    M.currentNativeFieldName = name

    if M.dialogInUse == true and dialogName == nil then return end
    if event.phase == "began" then

        local madeAdjustment = false
        if M.widgetDict[name]["scrollView"] ~= nil then
            madeAdjustment = M.adjustNativeInputIntoView(event)
        end

        M.widgetDict[name]["textfieldfake"].isVisible = false
        M.widgetDict[name]["textfield"].isVisible = true
        M.widgetDict[name]["textfield"].isSecure = M.widgetDict[name]["isSecure"]
        if madeAdjustment == false then
            timer.performWithDelay(100, function() native.setKeyboardFocus(M.widgetDict[name]["textfield"]) end, 1)
        end
    end
end

function M.adjustNativeInputIntoView(event)
    local name = event.target.name
    local height = M.widgetDict[name]["textfield"].contentHeight
    local scrollViewHeight = M.widgetDict[name]["scrollView"].contentHeight
    local topMargin = mathFloor(scrollViewHeight * 0.25)
    local bottomMargin = mathFloor(scrollViewHeight * 0.9)
    local x, y = M.widgetDict[name]["scrollView"]:getContentPosition()
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
        local widgetY = M.widgetDict[name]["container"].y
        local diffY = mathABS(widgetY) - mathABS(y)
        local scrollAmount = height - diffY
        destY = y + scrollAmount
        if M.widgetDict[name]["type"] == "TextField" then
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
        M.widgetDict[name]["scrollView"]:scrollToPosition(scrollOptions)
    end

    return madeAdjustment
end

function M.adjustScrollViewComplete(event)
    local name = M.currentNativeFieldName
    timer.performWithDelay(100, function() native.setKeyboardFocus(M.widgetDict[name]["textfield"]) end, 1)
end

function M.textfieldCallBack(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")

    if muiTargetValue ~= nil then
        print("TextField contains: "..muiTargetValue)
    end
end

function M.highlightTextField(widgetName, active)
    local name = widgetName
    if name == nil then
        return
    end

    if M.widgetDict[name]["textfield"] == nil then
        return
    end

    if active == nil then
        active = false
    end

    local widget = M.widgetDict[name]
    local color = nil
    if active then
        color = widget["textlabel"].activeColor
        widget["textfield"]:setTextColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        widget["textlabel"]:setFillColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        widget["line"]:setStrokeColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
    else
        color = widget["textlabel"].inactiveColor
        widget["textfield"]:setTextColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
        widget["textlabel"]:setFillColor( M.getColor(color, 1), M.getColor(color, 2), M.getColor(color, 3), M.getColor(color, 4) )
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
        M.currentNativeFieldName = name
        M.highlightTextField(name, true)
        if event.target.text ~= nil and string.len(event.target.text) > 0 then
            event.target.placeholder = ''
        end
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- do something with text
        -- print( event.target.text )
        M.widgetDict[name]["textfield"].isSecure = false
        M.highlightTextField(name, false)
        if event.target.callBack ~= nil then
            M.updateUI(event)
            if M.widgetDict[name]["textfieldfake"] ~= nil then
                local text = event.target.text
                if M.widgetDict[name]["isSecure"] == true then
                    local length = string.len(text)
                    text = ""
                    for i=1, length do
                        text = text .. "*"
                    end
                end
                M.widgetDict[name]["textfieldfake"].text = text
            end
            M.setEventParameter(event, "muiTarget", M.widgetDict[name]["textfieldfake"])
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

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["type"] = "TextBox"
    M.widgetDict[options.name]["container"] = display.newContainer( options.width+4, options.height * 4)
    M.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    M.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["container"] )
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

    M.widgetDict[options.name]["rect"] = display.newRect( 0, 0, options.width, options.height )
    M.widgetDict[options.name]["rect"].strokeWidth = 0
    M.widgetDict[options.name]["rect"]:setFillColor( 1, 1, 1 )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["rect"] )

    local rect = M.widgetDict[options.name]["rect"]
    M.widgetDict[options.name]["line"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
    M.widgetDict[options.name]["line"].strokeWidth = M.getScaleVal(4)
    M.widgetDict[options.name]["line"]:setStrokeColor( unpack(options.inactiveColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["line"] )

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
    M.widgetDict[options.name]["textlabel"] = display.newText( labelOptions )
    M.widgetDict[options.name]["textlabel"]:setFillColor( unpack(options.inactiveColor) )
    M.widgetDict[options.name]["textlabel"].inactiveColor = options.inactiveColor
    M.widgetDict[options.name]["textlabel"].activeColor = options.activeColor
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["textlabel"] )

    local scaleFontSize = 1
    if M.environment == "simulator" then
        scaleFontSize = 0.75
    end
    M.widgetDict[options.name]["textfield"] = native.newTextBox( 0, 0, options.width, options.height )
    M.widgetDict[options.name]["textfield"].name = options.name
    M.widgetDict[options.name]["textfield"].hasBackground = false
    M.widgetDict[options.name]["textfield"].isEditable = options.isEditable
    M.widgetDict[options.name]["textfield"].isVisible = false
    M.widgetDict[options.name]["textfield"].text = options.text
    M.widgetDict[options.name]["textfield"]:setTextColor( unpack(M.widgetDict[options.name]["textlabel"].inactiveColor) )

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
    M.widgetDict[options.name]["textfieldfake"] = display.newText( textOptions )
    M.widgetDict[options.name]["textfieldfake"]:setFillColor( unpack(M.widgetDict[options.name]["textlabel"].inactiveColor) )
    M.widgetDict[options.name]["textfieldfake"]:addEventListener("touch", M.showNativeInput)
    M.widgetDict[options.name]["textfieldfake"].name = options.name
    M.widgetDict[options.name]["textfieldfake"].dialogName = options.dialogName
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["textfieldfake"] )

    -- M.widgetDict[options.name]["textfield"].placeholder = "Subject"
    M.widgetDict[options.name]["textfield"].callBack = options.callBack
    M.widgetDict[options.name]["textfield"]:addEventListener( "userInput", M.textListener )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["textfield"] )
end

--
-- createProgressBar
--
--[[
  params:
    name = <name of widget>
    width = mui.getScaleVal(250),
    height = mui.getScaleVal(8),
    x = mui.getScaleVal(650),
    y = mui.getScaleVal(400),
    foregroundColor = { 0, 0.78, 1, 1 },
    backgroundColor = { 0.82, 0.95, 0.98, 0.8 },
    startPercent = 20,
    barType = "determinate",
    iterations = 1,
    labelText = "Determinate: progress bar",
    labelFont = native.systemFont,
    labelFontSize = mui.getScaleVal(24),
    labelColor = {  0.4, 0.4, 0.4, 1 },
    labelAlign = "center",
    callBack = mui.postProgressCallBack,
    --repeatCallBack = <your method here>,
    hideBackdropWhenDone = false
--]]--
function M.createProgressBar(options)
    if options == nil then return end

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    if options.width == nil then
        options.width = display.contentWidth * 0.70
    end

    if options.height == nil then
        options.height = M.getScaleVal(8)
    end

    if options.foregroundColor == nil then
        options.foregroundColor = { 0, 0, 1, 0, 1 }
    end

    if options.backgroundColor == nil then
        options.backgroundColor = { 0, 0, 1, 0, 0.8 }
    end

    if options.iterations == nil then
        options.iterations = 1
    end

    if options.barType == nil then
        -- options.type = "indeterminate"
        -- options.iterations = -1
    end

    if options.delay == nil then
        options.delay = 1500
    end

    local startPercent = 1
    if options.startPercent == nil then
        options.startPercent = 1
    else
        if options.startPercent < 1 then options.startPercent = 1 end
        if options.startPercent > 100 then options.startPercent = 100 end
    end
    startPercent = options.startPercent
    options.startPercent = options.startPercent / 100

    if options.hideBackdropWhenDone == nil then
        options.hideBackdropWhenDone = false
    end

    M.widgetDict[options.name] = {}

    M.widgetDict[options.name]["mygroup"] = display.newGroup()
    M.widgetDict[options.name]["mygroup"].x = x
    M.widgetDict[options.name]["mygroup"].y = y
    M.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["mygroup"] )
    end

    if options.labelText ~= nil and options.labelFontSize ~= nil then
        if options.labelAlign == nil then
            options.labelAlign = "center"
        end
        local textOptions =
        {
            text = options.labelText,
            x = options.width * 0.5,
            y = -(options.height + options.labelFontSize),
            width = options.width,
            font = options.labelFont,
            fontSize = options.labelFontSize,
            align = options.labelAlign  --new alignment parameter
        }
        M.widgetDict[options.name]["label"] = display.newText( textOptions )
        M.widgetDict[options.name]["label"]:setFillColor( unpack(options.labelColor) )
        M.widgetDict[options.name]["mygroup"]:insert( M.widgetDict[options.name]["label"] )
    end

    M.widgetDict[options.name]["busy"] = false
    M.widgetDict[options.name]["options"] = options
    M.widgetDict[options.name]["type"] = "ProgressBar"
    M.widgetDict[options.name]["progressbackdrop"] = display.newLine( 1, 0, 1+options.width, 0)
    M.widgetDict[options.name]["progressbackdrop"].strokeWidth = options.height
    M.widgetDict[options.name]["progressbackdrop"]:setStrokeColor( unpack(options.backgroundColor) )
    M.widgetDict[options.name]["progressbackdrop"].hideBackdropWhenDone = options.hideBackdropWhenDone
    M.widgetDict[options.name]["progressbar"] = display.newLine( 1, 0, 1+(options.width * 0.01), 0)
    M.widgetDict[options.name]["progressbar"].strokeWidth = options.height
    M.widgetDict[options.name]["progressbar"]:setStrokeColor( unpack(options.foregroundColor) )
    M.widgetDict[options.name]["progressbar"].name = options.name
    M.widgetDict[options.name]["progressbar"].percentComplete = 0
    if options.callBack ~= nil then
        M.widgetDict[options.name]["progressbar"].callBack = options.callBack
    end
    if options.repeatCallBack ~= nil then
        M.widgetDict[options.name]["progressbar"].repeatCallBack = options.repeatCallBack
    end
    M.widgetDict[options.name]["mygroup"]:insert(M.widgetDict[options.name]["progressbackdrop"])
    M.widgetDict[options.name]["mygroup"]:insert(M.widgetDict[options.name]["progressbar"])

    M.widgetDict[options.name]["progressbar"].percentComplete = 1
    M.increaseProgressBar( options.name, startPercent )
end

--
-- expects: widget name and percent to increase the progress bar by.
--
-- example: M.increaseProgressBar("foo", 20) -- increase progress bar widget named "foo" by 20%
--
-- note: queue any additional increases if already processing one
--
function M.increaseProgressBar( widgetName, percent, __forceprocess__ )
    if percent < 1 and __forceprocess__ == nil then return end
    if M.widgetDict[widgetName] == nil then return end

    local options = M.widgetDict[widgetName]["options"]

    if M.widgetDict[options.name]["transition"] ~= nil and options.iterations == -1 then
        return
    end

    if M.widgetDict[widgetName]["busy"] == true then
        -- queue the percent increase for later processing
        table.insert(M.progressbarDict, percent)
        return
    elseif #M.progressbarDict > 0 then
        percent = M.progressbarDict[1]
        table.remove(M.progressbarDict, 1)
    end

    M.widgetDict[widgetName]["busy"] = true

    M.widgetDict[widgetName]["progressbar"].percentComplete = M.widgetDict[widgetName]["progressbar"].percentComplete + percent

    M.widgetDict[options.name]["transition"] = transition.to( M.widgetDict[options.name]["progressbar"], {
        time = options.delay,
        xScale = M.widgetDict[widgetName]["progressbar"].percentComplete,
        transition = easing.linear,
        iterations = options.iterations,
        onComplete = M.completeProgressBarCallBack,
        onRepeat = M.repeatProgressBarCallBack
    } )

end

function M.repeatProgressBarCallBack( object )
    -- print("repeatProgressBarCallBack")
    if object.callBack ~= nil then
        assert(object.callBack)( object )
    end
end

function M.completeProgressBarCallBack( object )
    -- print("completeProgressBarCallBack")
    if object.name == nil then return end
    if M.widgetDict[object.name] == nil then return end

    M.widgetDict[object.name]["busy"] = false

    if object.noFinishAnimation == nil and object.percentComplete >= 99 then
        transition.to( M.widgetDict[object.name]["progressbar"], {
            time = 300,
            yScale = 0.01   ,
            transition = easing.linear,
            iterations = 1,
            onComplete = M.completeProgressBarFinalCallBack,
        } )
        if M.widgetDict[object.name]["progressbackdrop"].hideme ~= nil then
            transition.to( M.widgetDict[object.name]["progressbackdrop"], {
                time = 300,
                yScale = 0.01,
                transition = easing.linear,
                iterations = 1
            } )
        end
    elseif #M.progressbarDict > 0 then
        M.increaseProgressBar( object.name, 1, "__forceprocess__")
    end
end

function M.completeProgressBarFinalCallBack(object)
    if object.name ~= nil then
        if M.widgetDict[object.name] == nil then return end
        M.widgetDict[object.name]["progressbar"].isVisible = false
        if object.callBack ~= nil then
            assert(object.callBack)( object )
        end
    end
end

function M.postProgressCallBack( object )
    print("postProgressCallBack")
end

function M.createToggleSwitch(options)
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

    local textColorOff = { 1, 1, 1 }
    if options.textColorOff ~= nil then
        textColorOff = options.textColorOff
    end

    local textColor = { 1, 1, 1 }
    if options.textColor ~= nil then
        textColor = options.textColor
    end

    if options.foregroundColor == nil then
        options.foregroundColor = { 0, 0, 1, 0, 1 }
    end

    if options.backgroundColor == nil then
        options.backgroundColor = { 0, 0, 1, 0, 0.8 }
    end

    local isChecked = false
    if options.isChecked ~= nil then
        isChecked = options.isChecked
    end

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["options"] = options
    M.widgetDict[options.name]["isChecked"] = isChecked
    M.widgetDict[options.name].name = options.name
    M.widgetDict[options.name]["type"] = "ToggleSwitch"
    M.widgetDict[options.name]["mygroup"] = display.newGroup()
    M.widgetDict[options.name]["mygroup"].x = x
    M.widgetDict[options.name]["mygroup"].y = y
    M.widgetDict[options.name]["touching"] = false

    if options.callBack ~= nil then
        M.widgetDict[options.name]["callBack"] = options.callBack
    end

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["mygroup"] )
    end

    local radius = options.height

    x = 0
    y = 0
    M.widgetDict[options.name]["mygroup"]["rectmaster"] = display.newRect( x, y, options.width * 1.3, (options.height * 0.75))
    M.widgetDict[options.name]["mygroup"]["rectmaster"].strokeWidth = 0
    M.widgetDict[options.name]["mygroup"]["rectmaster"]:setStrokeColor( unpack({1, 0, 0, 1}) )

    M.widgetDict[options.name]["mygroup"]["rect"] = display.newRect( x, y, options.width * 0.5, (options.height * 0.50))
    M.widgetDict[options.name]["mygroup"]["rect"].strokeWidth = 0
    M.widgetDict[options.name]["mygroup"]["rect"]:setFillColor( unpack(options.backgroundColorOff) )

    M.widgetDict[options.name]["mygroup"]["circle1"] = display.newCircle( x - (radius * 0.20), y, radius * 0.25 )
    M.widgetDict[options.name]["mygroup"]["circle1"]:setFillColor( unpack(options.backgroundColorOff) )

    M.widgetDict[options.name]["mygroup"]["circle2"] = display.newCircle( x + (radius * 0.20), y, radius * 0.25 )
    M.widgetDict[options.name]["mygroup"]["circle2"]:setFillColor( unpack(options.backgroundColorOff) )

    M.widgetDict[options.name]["mygroup"]["circle"] = display.newCircle( x - (radius * 0.25), y, radius * 0.30 )
    M.widgetDict[options.name]["mygroup"]["circle"]:setFillColor( unpack(options.textColorOff) )

    M.widgetDict[options.name]["mygroup"]:insert(M.widgetDict[options.name]["mygroup"]["rectmaster"])
    M.widgetDict[options.name]["mygroup"]:insert(M.widgetDict[options.name]["mygroup"]["rect"])
    M.widgetDict[options.name]["mygroup"]:insert(M.widgetDict[options.name]["mygroup"]["circle1"])
    M.widgetDict[options.name]["mygroup"]:insert(M.widgetDict[options.name]["mygroup"]["circle2"])
    M.widgetDict[options.name]["mygroup"]:insert(M.widgetDict[options.name]["mygroup"]["circle"])

    M.widgetDict[options.name]["mygroup"]["circle"].name = options.name

    M.flipSwitch(options.name, 0)

    local rect = M.widgetDict[options.name]["mygroup"]["rectmaster"]

    function rect:touch (event)
        if M.dialogInUse == true and options.dialogName ~= nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            M.interceptEventHandler = rect
            M.updateUI(event)
            if M.touching == false and false then
                M.touching = true
                if options.touchpoint ~= nil and options.touchpoint == true then
                    M.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - M.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                    M.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - M.widgetDict[options.basename]["radio"][options.name]["mygroup"].y
                end
                transition.to(rect,{time=500, xScale=1.03, yScale=1.03, transition=easing.continuousLoop})
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                event.phase = "offTarget"
                -- event.target:dispatchEvent(event)
                -- print("Its out of the button area")
            else
              event.phase = "onTarget"
                if M.interceptMoved == false then
                    event.target = M.widgetDict[options.name]["rect"]
                    if M.widgetDict[options.name]["isChecked"] == true then
                        M.widgetDict[options.name]["isChecked"] = false
                        M.setEventParameter(event, "muiTargetValue", nil)
                    else
                        M.widgetDict[options.name]["isChecked"] = true
                        M.setEventParameter(event, "muiTargetValue", options.value)
                    end
                    M.setEventParameter(event, "muiTargetChecked", M.widgetDict[options.name]["isChecked"])
                    M.flipSwitch(options.name, nil)
                    M.setEventParameter(event, "muiTarget", M.widgetDict[options.name]["rect"])
                    event.callBackData = options.callBackData
                    assert( options.callBack )(event)
                end
                M.interceptEventHandler = nil
                M.interceptMoved = false
                M.touching = false
            end
        end
    end

    M.widgetDict[options.name]["mygroup"]["rectmaster"]:addEventListener( "touch", M.widgetDict[options.name]["mygroup"]["rectmaster"] )
end

function M.flipSwitch(widgetName, delay)
    if widgetName == nil then return end
    if delay == nil then delay = 250 end

    local isChecked = M.widgetDict[widgetName]["isChecked"]
    local xR = M.widgetDict[widgetName]["mygroup"]["rect"].contentWidth * 0.75
    local x = xR
    if isChecked == false then
        x = x - (xR * 2)
    end
    if isChecked == true then
        transition.to( M.widgetDict[widgetName]["mygroup"]["circle"], { time=delay, x=x, onComplete=M.turnOnSwitch } )
    else
        transition.to( M.widgetDict[widgetName]["mygroup"]["circle"], { time=delay, x=x, onComplete=M.turnOffSwitch } )
    end
end

function M.turnOnSwitch(e)
    local options = M.widgetDict[e.name].options
    e:setFillColor( unpack(options.textColor) )
    M.widgetDict[e.name]["mygroup"]["rect"]:setFillColor( unpack(options.backgroundColor) )
    M.widgetDict[e.name]["mygroup"]["circle1"]:setFillColor( unpack(options.backgroundColor) )
    M.widgetDict[e.name]["mygroup"]["circle2"]:setFillColor( unpack(options.backgroundColor) )
    M.widgetDict[e.name]["isChecked"] = true
end

function M.turnOffSwitch(e)
    local options = M.widgetDict[e.name].options
    e:setFillColor( unpack(options.textColorOff) )
    M.widgetDict[e.name]["mygroup"]["rect"]:setFillColor( unpack(options.backgroundColorOff) )
    M.widgetDict[e.name]["mygroup"]["circle1"]:setFillColor( unpack(options.backgroundColorOff) )
    M.widgetDict[e.name]["mygroup"]["circle2"]:setFillColor( unpack(options.backgroundColorOff) )
    M.widgetDict[e.name]["isChecked"] = false
end

function M.actionForSwitch(event)
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")
    local muiTargetChecked = M.getEventParameter(event, "muiTargetChecked")

    if muiTargetValue ~= nil then
        print("toggle switch value: " .. muiTargetValue)
    end

    if muiTargetChecked == nil then muiTargetChecked = false end
    if muiTargetChecked == true then
        print("toggle switch on")
    else
        print("toggle switch off")
    end
end

function M.createDialog(options)
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

    if options.backgroundColor == nil then
        options.backgroundColor = { 1, 1, 1, 1 }
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
    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["rectbackdrop"] = display.newRect( display.contentWidth * 0.5, display.contentHeight * 0.5, display.contentWidth, display.contentHeight)
    M.widgetDict[options.name]["rectbackdrop"].strokeWidth = 0
    M.widgetDict[options.name]["rectbackdrop"]:setFillColor( unpack( {0.4, 0.4, 0.4, 0.3} ) )
    M.widgetDict[options.name]["rectbackdrop"].isVisible = true

    -- now for the rest of the dialog
    local centerX = (display.contentWidth * 0.5)
    local centerY = (display.contentHeight * 0.5)

    M.widgetDict[options.name]["options"] = options
    M.dialogName = options.name
    M.widgetDict[options.name].name = options.name
    M.widgetDict[options.name]["type"] = "Dialog"
    M.widgetDict[options.name]["container"] = display.newContainer( options.width+20, options.height+20 )
    M.widgetDict[options.name]["container"]:translate( centerX, centerY ) -- center the container
    M.widgetDict[options.name]["touching"] = false
    M.widgetDict[options.name]["container"].y = display.contentHeight * 2

    M.dialogInUse = true

    if options.callBackCancel ~= nil then
        M.widgetDict[options.name]["callBackCancel"] = options.callBackCancel
    end

    local radius = options.height

    x = 0
    y = 0
    local width = options.width * 0.98
    local height = options.height * 0.98
    local nr = width * 0.02

    M.widgetDict[options.name]["container"]["rrect2"] = display.newRoundedRect( x, y, options.width, options.height, nr )
    if paint ~= nil then
        local object = M.widgetDict[options.name]["container"]["rrect2"]
       object.fill = paint

        object.fill.effect = "filter.vignetteMask"
        object.fill.effect.innerRadius = 1
        object.fill.effect.outerRadius = 0.1
        M.widgetDict[options.name]["container"]:insert( object )
    end

    M.widgetDict[options.name]["container"]["rrect"] = display.newRoundedRect( x, y, width, height, nr)
    M.widgetDict[options.name]["container"]["rrect"].strokeWidth = 0
    M.widgetDict[options.name]["container"]["rrect"]:setFillColor( unpack( options.backgroundColor ) )
    M.widgetDict[options.name]["container"]["rrect"].name = options.name
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["container"]["rrect"] )

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
            options.fontSize = M.getScaleVal(24)
        end
        local outerWidth = M.widgetDict[options.name]["container"]["rrect"].contentWidth
        local outerHeight = M.widgetDict[options.name]["container"]["rrect"].contentHeight
        M.widgetDict[options.name]["container2"] = display.newContainer( outerWidth, outerHeight - M.getScaleVal(90) )
        M.widgetDict[options.name]["container2"]:translate( 0, M.getScaleVal(-30) ) -- center the container
        M.widgetDict[options.name]["myText"] = display.newText( options.text, options.textX, options.textY, options.font, options.fontSize)
        M.widgetDict[options.name]["myText"]:setFillColor( unpack( options.textColor ) )
        M.widgetDict[options.name]["container2"]:insert( M.widgetDict[options.name]["myText"] )
        M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["container2"] )
    end

    ---[[--
    local bx = 0
    local by = (M.widgetDict[options.name]["container"]["rrect"].contentHeight * 0.5) - M.getScaleVal(50)
    if options.buttons ~= nil and options.buttons.okayButton ~= nil and options.buttons.cancelButton ~= nil then
        bx = (M.widgetDict[options.name]["container"]["rrect"].contentWidth * 0.5) - M.getScaleVal(100)
    else
        bx = 0
    end

    if options.buttons ~= nil and options.buttons["okayButton"] ~= nil then
        if options.buttons["okayButton"].callBackOkay ~= nil then
            M.widgetDict[options.name]["callBackOkay"] = options.buttons["okayButton"].callBackOkay
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
        M.createRectButton({
            name = "okay_dialog_button",
            text = options.buttons["okayButton"].text,
            width = M.getScaleVal(100),
            height = M.getScaleVal(50),
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
        M.widgetDict[options.name]["container"]:insert( M.getWidgetBaseObject("okay_dialog_button") )
    end

    ---[[--
    if options.buttons ~= nil and options.buttons["cancelButton"] ~= nil then
        if options.buttons["cancelButton"].callBackOkay ~= nil then
            M.widgetDict[options.name]["callBackCancel"] = options.buttons["cancelButton"].callBackCancel
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
        if bx > 0 then
            bx = (bx - (bx * 0.1)) - M.getScaleVal(100)
        end
        M.createRectButton({
            name = "cancel_dialog_button",
            text = options.buttons["cancelButton"].text,
            width = M.getScaleVal(100),
            height = M.getScaleVal(50),
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
        M.widgetDict[options.name]["container"]:insert( M.getWidgetBaseObject("cancel_dialog_button") )
    end
    --]]--
    M.widgetDict[options.name]["rectbackdrop"].isVisible = true
    transition.fadeIn( M.widgetDict[options.name]["rectbackdrop"], { time=1500 } )
    transition.to( M.widgetDict[options.name]["container"], { time=800, y = centerY, transition=options.easing } )
end

function M.dialogOkayCallback(e)
    if M.dialogName == nil then return end
    if M.widgetDict[M.dialogName]["callBackOkay"] ~= nil then
       assert( M.widgetDict[M.dialogName]["callBackOkay"] )(e)
    end
    M.closeDialog(e)
end

function M.actionForOkayDialog(e)
    print("actionForOkayDialog called")
end

function M.dialogCancelCallback(e)
    if M.widgetDict[M.dialogName]["callBackCancel"] ~= nil then
       assert( M.widgetDict[M.dialogName]["callBackCancel"] )(e)
    end
    M.closeDialog(e)
end

function M.closeDialog(e)
    -- fade out and destroy it
    if M.dialogName ~= nil then
        transition.fadeIn( M.widgetDict[M.dialogName]["rectbackdrop"], { time=500 } )
        transition.to( M.widgetDict[M.dialogName]["container"], { time=1100, y = display.contentHeight * 2, onComplete=M.removeWidgetDialog, transition=easing.inOutCubic } )
    end
end

function M.dialogClose(e)
    -- fade out and destroy it
    M.closeDialog(e)
end

function M.createSlider(options)
    if options == nil then return end

    local x,y = 160, 240
    if options.x ~= nil then
        x = options.x
    end
    if options.y ~= nil then
        y = options.y
    end

    if options.width == nil then
        options.width = M.getScaleVal(200)
    end

    if options.height == nil then
        options.height = M.getScaleVal(4)
    end

    if options.position == nil then
        options.position = "horizontal"
    end

    if options.radius == nil then
        options.radius = M.getScaleVal(15)
    end

    if options.color == nil then
        options.color = { 1, 0, 0, 1 }
    end

    if options.colorOff == nil then
        options.colorOff = { 1, 1, 1, 1 }
    end

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name].name = options.name
    M.widgetDict[options.name]["type"] = "Slider"
    M.widgetDict[options.name]["touching"] = false

    local circleWidth = options.radius * 2.5

    -- fix x to be correct
    x = x - options.width * 0.5

    if options.position == "horizontal" then
        M.widgetDict[options.name]["sliderrect"] = display.newRect( x + options.width * 0.5, y, options.width, circleWidth)
    else
        M.widgetDict[options.name]["sliderrect"] = display.newRect( 0, 0, circleWidth, options.height + (circleWidth + (circleWidth * 0.5)))
    end
    M.widgetDict[options.name]["sliderrect"]:setStrokeColor( unpack(options.color) )
    M.widgetDict[options.name]["sliderrect"].strokeWidth = 0
    M.widgetDict[options.name]["sliderrect"].name = options.name

    M.widgetDict[options.name]["circleWidth"] = circleWidth
    M.widgetDict[options.name]["circleRadius"] = options.radius
    M.widgetDict[options.name]["container"] = display.newGroup()
    M.widgetDict[options.name]["container"].x = x
    M.widgetDict[options.name]["container"].y = y
    --M.widgetDict[options.name]["container"]:translate( x, y ) -- center the container

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["container"] )
    end

    -- the bar
    if options.position == "horizontal" then
        M.widgetDict[options.name]["sliderbar"] = display.newLine( 0, 0, options.width, 0 )
    else
        M.widgetDict[options.name]["sliderbar"] = display.newLine( 0, 0, 0, options.height )
    end
    M.widgetDict[options.name]["sliderbar"]:setStrokeColor( unpack(options.color) )
    M.widgetDict[options.name]["sliderbar"].strokeWidth = options.height
    M.widgetDict[options.name]["sliderbar"].isVisible = true

    -- the circle which line goes thru center (vertical|horizontal)
    M.widgetDict[options.name]["slidercircle"] = display.newCircle( 0, options.height * 0.5, options.radius )
    M.widgetDict[options.name]["slidercircle"]:setStrokeColor( unpack(options.color) )
    M.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )

    if options.position == "horizontal" then
        M.widgetDict[options.name]["slidercircle"].strokeWidth = options.height
    else
        M.widgetDict[options.name]["slidercircle"].strokeWidth = options.width
    end
    --M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["sliderrect"] )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["sliderbar"] )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["slidercircle"] )

    M.widgetDict[options.name]["value"] = 0

    if options.startPercent ~= nil and options.startPercent > -1 then
        local event = {}
        local percent = options.startPercent / 100
        local diffX = M.widgetDict[options.name]["container"].x - M.widgetDict[options.name]["container"].contentWidth
        event.x = x + mathABS(diffX * percent)
        M.widgetDict[options.name]["value"] = percent
        M.sliderPercentComplete(event, options)
    end

    local sliderrect = M.widgetDict[options.name]["sliderrect"]

    function sliderrect:touch (event)
        if M.dialogInUse == true and options.dialogName ~= nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            -- set touch focus
            display.getCurrentStage():setFocus( self )
            self.isFocus = true
            event.target.isFocus = true
            M.interceptEventHandler = sliderrect
            M.updateUI(event)
            if M.touching == false then
                M.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.color) )
                M.touching = true
                if options.touchpoint ~= nil and options.touchpoint == true and false then
                    M.widgetDict[options.basename]["radio"][options.name]["myCircle"].x = event.x - M.widgetDict[options.basename]["radio"][options.name]["mygroup"].x
                    M.widgetDict[options.basename]["radio"][options.name]["myCircle"].y = event.y - M.widgetDict[options.basename]["radio"][options.name]["mygroup"].y
                    --M.widgetDict[options.basename]["radio"][options.name]["myCircle"].isVisible = true
                    --M.widgetDict[options.basename]["radio"][options.name].myCircleTrans = transition.to( M.widgetDict[options.basename]["radio"][options.name]["myCircle"], { time=300,alpha=0.2, xScale=scaleFactor, yScale=scaleFactor, transition=easing.inOutCirc, onComplete=M.subtleRadius } )
                end
            end
            transition.to(M.widgetDict[options.name]["slidercircle"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
        elseif ( event.phase == "moved" ) then

            if M.widgetDict[options.name]["slidercircle"].xScale == 1 then
                transition.to(M.widgetDict[options.name]["slidercircle"],{time=300, xScale=1.5, yScale=1.5, transition=easing.inOutCubic})
            end

            -- update bar with color (up/down/left/right)
            M.sliderPercentComplete(event, options)

            -- call user-defined move method
            if options.callBackMove ~= nil then
                event.target.name = options.name
                assert( options.callBackMove )(event)
            end

        elseif ( event.phase == "ended" ) then
            M.currentTargetName = nil
            transition.to(M.widgetDict[options.name]["slidercircle"],{time=300, xScale=1, yScale=1, transition=easing.inOutCubic})
            if M.interceptMoved == false then
                event.target = M.widgetDict[options.name]["slidercircle"]
                event.callBackData = options.callBackData
                if options.callBack ~= nil then
                    event.target.name = options.name
                    assert( options.callBack )(event)
                end
            end
            M.interceptEventHandler = nil
            M.interceptMoved = false
            M.touching = false
            -- reset focus
            display.getCurrentStage():setFocus( nil )
            self.isFocus = false
            event.target.isFocus = false
            M.sliderPercentComplete(event, options)
        end
    end

    sliderrect:addEventListener( "touch", sliderrect )
end

function M.sliderPercentComplete(event, options)
    if event == nil or options == nil then return end

    local circleRadius = M.widgetDict[options.name]["circleRadius"]
    if options.position == "horizontal" then
        local dx = event.x - M.widgetDict[options.name]["container"].x
        if dx > circleRadius and dx <= (M.widgetDict[options.name]["sliderbar"].contentWidth - circleRadius) then
            -- get percent
            local percentComplete = dx / (M.widgetDict[options.name]["sliderbar"].contentWidth - circleRadius)
            if percentComplete > -1 and percentComplete < 2 then
                if percentComplete >= 0 and percentComplete <= 1 then
                    M.widgetDict[options.name]["slidercircle"].x = dx
                end
                if percentComplete >= 1 then percentComplete = 1 end
                if percentComplete < 0 then percentComplete = 0 end
                M.widgetDict[options.name]["value"] = percentComplete
                if percentComplete == 0 then
                    M.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )
                else
                    M.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.color) )
                end
            end
        else
            if dx < circleRadius then
                M.widgetDict[options.name]["slidercircle"].x = circleRadius
                M.widgetDict[options.name]["slidercircle"]:setFillColor( unpack(options.colorOff) )
                M.widgetDict[options.name]["value"] = 0
            else
                M.widgetDict[options.name]["slidercircle"].x = M.widgetDict[options.name]["sliderbar"].contentWidth - circleRadius
                M.widgetDict[options.name]["value"] = 1
            end
        end
        M.setEventParameter(event, "muiTargetValue", M.widgetDict[options.name]["value"])
        M.setEventParameter(event, "muiTarget", M.widgetDict[options.name]["slidercircle"])
    end
end

function M.sliderCallBackMove( event )
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")

    if event.target ~= nil then
        print("sliderCallBackMove is: "..muiTargetValue)
    end
end

function M.sliderCallBack( event )
    local muiTarget = M.getEventParameter(event, "muiTarget")
    local muiTargetValue = M.getEventParameter(event, "muiTargetValue")

    if muiTarget ~= nil then
        print("percentComplete is: "..muiTargetValue)
    end
end

function M.createToast( options )
    if options == nil then return end

    if M.widgetDict[options.name] ~= nil then return end

    if options.width == nil then
        options.width = M.getScaleVal(200)
    end

    if options.height == nil then
        options.height = M.getScaleVal(4)
    end

    if options.radius == nil then
        options.radius = M.getScaleVal(15)
    end

    local left,top = (display.contentWidth-options.width) * 0.5, display.contentHeight * 0.5
    if options.left ~= nil then
        left = options.left
    end

    if options.textColor == nil then
        options.textColor = { 1, 1, 1, 1 }
    end

    if options.fillColor == nil then
        options.fillColor = { 0.06, 0.56, 0.15, 1 }
    end

    if options.font == nil then
        options.font = native.systemFont
    end

    if options.top == nil then
        options.top = M.getScaleVal(80)
    end

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name]["type"] = "Toast"

    M.widgetDict[options.name]["container"] = widget.newScrollView(
        {
            top = -options.height,
            left = left,
            width = options.width + (options.width * 0.10),
            height = options.height + (options.height * 0.10),
            scrollWidth = options.width,
            scrollHeight = options.height,
            hideBackground = true,
            hideScrollBar = true,
            isLocked = true
        }
    )

    M.widgetDict[options.name]["touching"] = false

    local radius = options.height * 0.2
    if options.radius ~= nil and options.radius < options.height and options.radius > 1 then
        radius = options.radius
    end

    local newX = M.widgetDict[options.name]["container"].contentWidth * 0.5
    local newY = M.widgetDict[options.name]["container"].contentHeight * 0.5

    M.widgetDict[options.name]["rrect"] = display.newRoundedRect( newX, newY, options.width, options.height, radius )
    M.widgetDict[options.name]["rrect"]:setFillColor( unpack(options.fillColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["rrect"] )

    local rrect = M.widgetDict[options.name]["rrect"]

    local fontSize = 24
    if options.fontSize ~= nil then
        fontSize = options.fontSize
    end

    local font = native.systemFont
    if options.font ~= nil then
        font = options.font
    end

    M.widgetDict[options.name]["font"] = font
    M.widgetDict[options.name]["fontSize"] = fontSize

    M.widgetDict[options.name]["myText"] = display.newText( options.text, newX, newY, font, fontSize )
    M.widgetDict[options.name]["myText"]:setFillColor( unpack(options.textColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["myText"], true )

    function rrect:touch (event)
        if M.dialogInUse == true and options.dialogName == nil then return end

        M.addBaseEventParameters(event, options)

        if ( event.phase == "began" ) then
            --event.target:takeFocus(event)
            -- if scrollView then use the below
            M.interceptEventHandler = rrect
            M.updateUI(event)
            if M.touching == false then
                M.touching = true
            end
        elseif ( event.phase == "ended" ) then
            if M.isTouchPointOutOfRange( event ) then
                  event.phase = "offTarget"
                  -- print("Its out of the button area")
                  -- event.target:dispatchEvent(event)
            else
                event.phase = "onTarget"
                if M.interceptMoved == false then
                    if options.easingOut == nil then
                        options.easingOut = 500
                    end
                    M.widgetDict[options.name]["container"].name = options.name
                    transition.to(M.widgetDict[options.name]["container"],{time=options.easingOut, y=-(options.top), transition=easing.inOutCubic, onComplete=M.removeToast})
                    event.target = M.widgetDict[options.name]["rrect"]
                    event.callBackData = options.callBackData

                    M.setEventParameter(event, "muiTargetValue", options.value)
                    M.setEventParameter(event, "muiTarget", M.widgetDict[options.name]["rrect"])

                    assert( options.callBack )(event)
                end
            end
            M.interceptEventHandler = nil
            M.interceptMoved = false
            M.touching = false
        end
    end
    M.widgetDict[options.name]["rrect"]:addEventListener( "touch", M.widgetDict[options.name]["rrect"] )

    if options.easingIn == nil then
        options.easingIn = 500
    end
    transition.to(M.widgetDict[options.name]["container"],{time=options.easingIn, y=options.top, transition=easing.inOutCubic})
end

function M.removeToast(event)
    local muiName = event.name
    if muiName ~= nil then
        M.removeWidgetToast(muiName)
    end
end

function M.createDropDown(options)
    M.createSelector(options)
end

function M.createSelect(options)

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

    if options.fieldBackgroundColor == nil then
        options.fieldBackgroundColor = { 1, 1, 1, 1 }
    end

    M.widgetDict[options.name] = {}
    M.widgetDict[options.name].name = options.name
    M.widgetDict[options.name]["type"] = "Selector"

    M.widgetDict[options.name]["container"] = display.newContainer(options.width+4, options.height + options.listHeight)
    M.widgetDict[options.name]["container"]:translate( x, y ) -- center the container
    M.widgetDict[options.name]["touching"] = false

    if options.scrollView ~= nil then
        M.widgetDict[options.name]["scrollView"] = options.scrollView
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["container"] )
        M.widgetDict[options.name]["scrollView"]:insert( M.widgetDict[options.name]["mygroup"] )
    end

    if options.inactiveColor == nil then
        options.inactiveColor = { 0.4, 0.4, 0.4, 1 }
    end

    if options.activeColor == nil then
        options.activeColor = { 0.12, 0.67, 0.27, 1 }
    end

    if options.strokeWidth == nil then
        options.strokeWidth = M.getScaleVal(1)
    end

    if options.strokeColor == nil then
        options.strokeColor = { 0.4, 0.4, 0.4, 1 }
    end

    M.widgetDict[options.name]["rect"] = display.newRect( 0, 0, options.width, options.height )
    M.widgetDict[options.name]["rect"]:setFillColor( unpack( options.fieldBackgroundColor ) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["rect"] )

    local rect = M.widgetDict[options.name]["rect"]
    M.widgetDict[options.name]["line"] = display.newLine( -(rect.contentWidth * 0.9), rect.contentHeight / 2, (rect.contentWidth * 0.5), rect.contentHeight / 2)
    M.widgetDict[options.name]["line"].strokeWidth = M.getScaleVal(4)
    M.widgetDict[options.name]["line"]:setStrokeColor( unpack(options.inactiveColor) )
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["line"] )

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
    M.widgetDict[options.name]["textlabel"] = display.newText( labelOptions )
    M.widgetDict[options.name]["textlabel"]:setFillColor( unpack(options.inactiveColor) )
    M.widgetDict[options.name]["textlabel"].inactiveColor = options.inactiveColor
    M.widgetDict[options.name]["textlabel"].activeColor = options.activeColor
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["textlabel"] )

    local scaleFontSize = 1
    if M.environment == "simulator" then
        scaleFontSize = 0.75
    end

    local textOptions =
    {
        --parent = textGroup,
        text = options.text,
        x = 0,
        y = 0,
        width = options.width,
        font = options.font,
        fontSize = options.height * 0.55,
        align = "left"  --new alignment parameter
    }
    M.widgetDict[options.name]["selectorfieldfake"] = display.newText( textOptions )
    M.widgetDict[options.name]["selectorfieldfake"]:setFillColor( unpack(M.widgetDict[options.name]["textlabel"].inactiveColor) )
    M.widgetDict[options.name]["selectorfieldfake"]:addEventListener("touch", M.selectorListener)
    M.widgetDict[options.name]["selectorfieldfake"].name = options.name
    M.widgetDict[options.name]["selectorfieldfake"].dialogName = options.dialogName
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["selectorfieldfake"] )

    -- use codepoints like keyboard_arrow_down
    textOptions =
    {
        --parent = textGroup,
        text = "keyboard_arrow_down",
        x = 0,
        y = 0,
        width = options.width,
        font = "MaterialIcons-Regular.ttf",
        fontSize = options.height * 0.55,
        align = "right"  --new alignment parameter
    }
    M.widgetDict[options.name]["selectorfieldarrow"] = display.newText( textOptions )
    M.widgetDict[options.name]["selectorfieldarrow"]:setFillColor( unpack(M.widgetDict[options.name]["textlabel"].inactiveColor) )
    M.widgetDict[options.name]["selectorfieldarrow"].name = options.name
    M.widgetDict[options.name]["selectorfieldarrow"].dialogName = options.dialogName
    M.widgetDict[options.name]["container"]:insert( M.widgetDict[options.name]["selectorfieldarrow"] )

    if options.listHeight > display.contentHeight then
        options.listHeight = display.contentHeight * 0.75
    end

    M.widgetDict[options.name]["options"] = options
end

function M.revealTableViewForSelector(name, options)
    -- table view to hold pick list keyboard_arrow_down
    M.widgetDict[options.name]["mygroup"] = display.newGroup() -- options.width+4, options.height + options.listHeight)

    local x = options.x
    local y = options.y
    if M.widgetDict[options.name]["calculated"] ~= nil and M.widgetDict[options.name]["calculated"].y ~= nil then
        x = M.widgetDict[options.name]["calculated"].x
        y = M.widgetDict[options.name]["calculated"].y
    end

    M.widgetDict[options.name]["mygroup"].x = x
    M.widgetDict[options.name]["mygroup"].y = y

    M.createTableView({
        name = options.name.."-List",
        width = options.width - M.getScaleVal(5),
        height = options.listHeight,
        font = options.font,
        top = M.getScaleVal(40),
        left = 0,
        textColor = options.textColor,
        strokeColor = options.inactiveColor,
        strokeWidth = 1,
        lineHeight = 0,
        noLines = true,
        rowColor = options.rowColor,
        rowHeight = options.height,
        callBackTouch = options.callBackTouch,
        callBackRender = options.callBackRender,
        scrollListener = options.listener,
        categoryColor = options.categoryColor,
        categoryLineColor = options.categoryLineColor,
        touchpointColor = options.touchpointColor,
        list = options.list
    })

    M.widgetDict[options.name]["rect2"] = display.newRect( options.width * 0.5, (options.listHeight * 0.45) + options.height, options.width, options.listHeight + (options.height * 0.5))
    M.widgetDict[options.name]["rect2"].strokeWidth = options.strokeWidth
    M.widgetDict[options.name]["rect2"]:setStrokeColor( unpack( options.strokeColor ) )
    M.widgetDict[options.name]["mygroup"]:insert( M.widgetDict[options.name]["rect2"] )

    if M.widgetDict[options.name]["calculated"] == nil then
        M.widgetDict[options.name]["calculated"] = {}
        M.widgetDict[options.name]["mygroup"].x = M.widgetDict[options.name]["mygroup"].x - options.width * 0.5

        local dy = mathABS(M.widgetDict[options.name.."-List"]["tableview"].contentHeight - M.widgetDict[options.name]["mygroup"].y)
        local h = M.widgetDict[options.name.."-List"]["tableview"].contentHeight + M.widgetDict[options.name]["mygroup"].y

        if h > display.contentHeight then
            local hd = mathABS(display.contentHeight - h)
            if options.scrollView ~= nil then
                hd = mathABS(options.scrollView.contentHeight - h)
            end
            dy = M.widgetDict[options.name]["mygroup"].y - (hd + options.height)
            M.widgetDict[options.name]["mygroup"].y = dy
        else
            dy = M.widgetDict[options.name]["mygroup"].y - options.height
        end
        M.widgetDict[options.name]["mygroup"].y = dy
        M.widgetDict[options.name]["calculated"].x = M.widgetDict[options.name]["mygroup"].x
        M.widgetDict[options.name]["calculated"].y = M.widgetDict[options.name]["mygroup"].y
    end
    M.widgetDict[options.name]["mygroup"]:insert( M.widgetDict[options.name.."-List"]["tableview"] )
    M.widgetDict[options.name]["mygroup"].isVisible = false
end

function M.selectorListener( event )
    if event.phase == "began" then
        local name = event.target.name
        M.currentTargetName = name
        M.revealTableViewForSelector(name, M.widgetDict[name]["options"])
        M.widgetDict[name]["mygroup"].isVisible = true
    end
end

function M.hideNativeWidgets()
  for widget in pairs(M.widgetDict) do
      local widgetType = M.widgetDict[widget]["type"]
      if widgetType ~= nil then
        if widgetType == "TextField" or widgetType == "TextBox" then
            M.widgetDict[widget]["textfield"].isVisible = false
        end
      end
  end
end

function M.removeWidgets()
  print("Removing widgets")
  for widget in pairs(M.widgetDict) do
      local widgetType = M.widgetDict[widget]["type"]
      if widgetType ~= nil then
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
        end
      end
  end
  Runtime:removeEventListener( "touch", M.eventSuperListner )

end


function M.removeWidgetRRectButton(widgetName)
    if widgetName == nil then
        return
    end

    if M.widgetDict[widgetName]["rrect"] == nil then return end

    M.widgetDict[widgetName]["rrect"]:removeEventListener("touch", M.widgetDict[widgetName]["rrect"])
    M.widgetDict[widgetName]["myCircle"]:removeSelf()
    M.widgetDict[widgetName]["myCircle"] = nil
    M.widgetDict[widgetName]["myText"]:removeSelf()
    M.widgetDict[widgetName]["myText"] = nil
    M.widgetDict[widgetName]["rrect"]:removeSelf()
    M.widgetDict[widgetName]["rrect"] = nil
    M.widgetDict[widgetName]["rrect2"]:removeSelf()
    M.widgetDict[widgetName]["rrect2"] = nil
    M.widgetDict[widgetName]["container"]:removeSelf()
    M.widgetDict[widgetName]["container"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetRectButton(widgetName)
    if widgetName == nil then
        return
    end

    if M.widgetDict[widgetName]["rrect"] == nil then return end

    M.widgetDict[widgetName]["rrect"]:removeEventListener("touch", M.widgetDict[widgetName]["rrect"])
    M.widgetDict[widgetName]["myCircle"]:removeSelf()
    M.widgetDict[widgetName]["myCircle"] = nil
    M.widgetDict[widgetName]["myText"]:removeSelf()
    M.widgetDict[widgetName]["myText"] = nil
    M.widgetDict[widgetName]["rrect"]:removeSelf()
    M.widgetDict[widgetName]["rrect"] = nil
    M.widgetDict[widgetName]["container"]:removeSelf()
    M.widgetDict[widgetName]["container"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetIconButton(widgetName)
    if widgetName == nil then
        return
    end

    if M.widgetDict[widgetName]["myText"] == nil then return end

    M.widgetDict[widgetName]["myText"]:removeEventListener("touch", M.widgetDict[widgetName]["myText"])
    M.widgetDict[widgetName]["myCircle"]:removeSelf()
    M.widgetDict[widgetName]["myCircle"] = nil
    M.widgetDict[widgetName]["myText"]:removeSelf()
    M.widgetDict[widgetName]["myText"] = nil
    M.widgetDict[widgetName]["mygroup"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetRadioButton(widgetName)
    if widgetName == nil then
        return
    end
    for name in pairs(M.widgetDict[widgetName]["radio"]) do
        M.widgetDict[widgetName]["radio"][name]["myText"]:removeEventListener( "touch", M.widgetDict[widgetName]["radio"][name]["myText"] )
        M.widgetDict[widgetName]["radio"][name]["myCircle"]:removeSelf()
        M.widgetDict[widgetName]["radio"][name]["myCircle"] = nil
        M.widgetDict[widgetName]["radio"][name]["myText"]:removeSelf()
        M.widgetDict[widgetName]["radio"][name]["myText"] = nil
        M.widgetDict[widgetName]["radio"][name]["myLabel"]:removeSelf()
        M.widgetDict[widgetName]["radio"][name]["myLabel"] = nil
        M.widgetDict[widgetName]["radio"][name]["mygroup"]:removeSelf()
        M.widgetDict[widgetName]["radio"][name]["mygroup"] = nil
        M.widgetDict[widgetName]["radio"][name] = nil
    end
end

function M.removeWidgetToolbar(widgetName)
    if widgetName == nil then
        return
    end
    for name in pairs(M.widgetDict[widgetName]["toolbar"]) do
        M.removeWidgetToolbarButton(M.widgetDict, widgetName, name)
        if name ~= "slider" and name ~= "rectBak" then
            M.widgetDict[widgetName]["toolbar"][name] = nil
        end
    end
    if M.widgetDict[widgetName]["toolbar"]["slider"] ~= nil then
        M.widgetDict[widgetName]["toolbar"]["slider"]:removeSelf()
        M.widgetDict[widgetName]["toolbar"]["slider"] = nil
    end
    if M.widgetDict[widgetName]["toolbar"]["rectBak"] ~= nil then
        M.widgetDict[widgetName]["toolbar"]["rectBak"]:removeSelf()
        M.widgetDict[widgetName]["toolbar"]["rectBak"] = nil
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
            widgetDict[toolbarName]["toolbar"][name]["rectangle"]:removeEventListener( "touch", M.widgetDict[toolbarName]["toolbar"][name]["rectangle"] )
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
    if M.widgetDict[widgetName] == nil then return end
    
    if M.widgetDict[widgetName]["tableview"] == nil then
        return
    end
    M.widgetDict[widgetName]["tableview"]:deleteAllRows()
    M.widgetDict[widgetName]["tableview"]:removeSelf()
    M.widgetDict[widgetName]["tableview"] = nil
end

function M.removeWidgetTextField(widgetName)
    if widgetName == nil then
        return
    end
    if M.widgetDict[widgetName]["textfieldfake"] == nil then
        return
    end

    M.widgetDict[widgetName]["textfieldfake"].isVisible = false
    M.widgetDict[widgetName]["textfieldfake"]:removeSelf()
    M.widgetDict[widgetName]["textfield"].isVisible = false
    M.widgetDict[widgetName]["textfield"]:removeSelf()
    M.widgetDict[widgetName]["textfield"] = nil
    M.widgetDict[widgetName]["textlabel"]:removeSelf()
    M.widgetDict[widgetName]["textlabel"] = nil
    M.widgetDict[widgetName]["line"]:removeSelf()
    M.widgetDict[widgetName]["line"] = nil
    M.widgetDict[widgetName]["rect"]:removeEventListener("touch", M.widgetDict[widgetName]["rect"])
    M.widgetDict[widgetName]["rect"]:removeSelf()
    M.widgetDict[widgetName]["rect"] = nil
    M.widgetDict[widgetName]["container"]:removeSelf()
    M.widgetDict[widgetName]["container"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetTextBox(widgetName)
    M.removeWidgetTextField(widgetName)
end

function M.removeWidgetProgressBar(widgetName)
    if widgetName == nil then
        return
    end
    if M.widgetDict[widgetName]["progressbackdrop"] == nil then
        return
    end

    M.widgetDict[widgetName]["progressbackdrop"]:removeSelf()
    M.widgetDict[widgetName]["progressbackdrop"] = nil
    M.widgetDict[widgetName]["progressbar"]:removeSelf()
    M.widgetDict[widgetName]["progressbar"] = nil
    if M.widgetDict[widgetName]["label"] ~= nil then
        M.widgetDict[widgetName]["label"]:removeSelf()
        M.widgetDict[widgetName]["label"] = nil
    end
    M.widgetDict[widgetName]["mygroup"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetToggleSwitch(widgetName)
    if widgetName == nil then
        return
    end
    if M.widgetDict[widgetName]["mygroup"] == nil then
        return
    end
    M.widgetDict[widgetName]["mygroup"]["circle"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"]["circle"] = nil
    M.widgetDict[widgetName]["mygroup"]["circle2"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"]["circle2"] = nil
    M.widgetDict[widgetName]["mygroup"]["circle1"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"]["circle1"] = nil
    M.widgetDict[widgetName]["mygroup"]["rect"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"]["rect"] = nil
    M.widgetDict[widgetName]["mygroup"]["rectmaster"]:removeEventListener("touch", M.widgetDict[widgetName]["rectmaster"])
    M.widgetDict[widgetName]["mygroup"]["rectmaster"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"]["rectmaster"] = nil
    M.widgetDict[widgetName]["mygroup"]:removeSelf()
    M.widgetDict[widgetName]["mygroup"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetDialog()
    if M.dialogName == nil then
        return
    end
    local widgetName = M.dialogName

    if M.widgetDict[widgetName]["rectbackdrop"] == nil then
        return
    end

    -- remove buttons
    M.removeWidgetRectButton("okay_dialog_button")
    M.removeWidgetRectButton("cancel_dialog_button")

    -- remove the rest
    -- M.widgetDict[widgetName]["container"]["myText"]:removeSelf()
    -- M.widgetDict[widgetName]["container"]["myText"] = nil
    M.widgetDict[widgetName]["rectbackdrop"]:removeSelf()
    M.widgetDict[widgetName]["rectbackdrop"] = nil
    M.widgetDict[widgetName]["container"]["rrect"]:removeSelf()
    M.widgetDict[widgetName]["container"]["rrect"] = nil
    M.widgetDict[widgetName]["container"]["rrect2"]:removeSelf()
    M.widgetDict[widgetName]["container"]["rrect2"] = nil
    M.widgetDict[widgetName]["container"]:removeSelf()
    M.widgetDict[widgetName]["container"] = nil
    M.widgetDict[widgetName] = nil
    M.dialogName = nil
    M.dialogInUse = false
end

function M.removeWidgetSlider(widgetName)
    if widgetName == nil then
        return
    end

    M.widgetDict[widgetName]["sliderrect"]:removeEventListener("touch", M.widgetDict[widgetName]["sliderrect"])
    M.widgetDict[widgetName]["slidercircle"]:removeSelf()
    M.widgetDict[widgetName]["slidercircle"] = nil
    M.widgetDict[widgetName]["sliderbar"]:removeSelf()
    M.widgetDict[widgetName]["sliderbar"] = nil
    M.widgetDict[widgetName]["sliderrect"]:removeSelf()
    M.widgetDict[widgetName]["sliderrect"] = nil
    M.widgetDict[widgetName]["container"]:removeSelf()
    M.widgetDict[widgetName]["container"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetToast(widgetName)
    if widgetName == nil then
        return
    end

    M.widgetDict[widgetName]["rrect"]:removeEventListener("touch", M.widgetDict[widgetName]["sliderrect"])
    M.widgetDict[widgetName]["myText"]:removeSelf()
    M.widgetDict[widgetName]["myText"] = nil
    M.widgetDict[widgetName]["rrect"]:removeSelf()
    M.widgetDict[widgetName]["rrect"] = nil
    M.widgetDict[widgetName]["container"]:removeSelf()
    M.widgetDict[widgetName]["container"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeWidgetSelector(widgetName, listonly)
    if widgetName == nil then
        return
    end

    if listonly ~= nil then
        M.removeWidgetTableView(widgetName .. "-List")
        M.removeSelectorGroup(widgetName)
        return
    else
        M.removeWidgetTableView(widgetName .. "-List")
    end
    M.widgetDict[widgetName]["selectorfieldfake"]:removeEventListener("touch", M.selectorListener)

    M.widgetDict[widgetName]["selectorfieldarrow"]:removeSelf()
    M.widgetDict[widgetName]["selectorfieldarrow"] = nil
    M.widgetDict[widgetName]["selectorfieldfake"]:removeSelf()
    M.widgetDict[widgetName]["selectorfieldfake"] = nil
    M.widgetDict[widgetName]["textlabel"]:removeSelf()
    M.widgetDict[widgetName]["textlabel"] = nil
    M.widgetDict[widgetName]["rect"]:removeSelf()
    M.widgetDict[widgetName]["rect"] = nil
    M.widgetDict[widgetName]["line"]:removeSelf()
    M.widgetDict[widgetName]["line"] = nil
    M.removeSelectorGroup(widgetName)
    M.widgetDict[widgetName]["container"]:removeSelf()
    M.widgetDict[widgetName]["container"] = nil
    M.widgetDict[widgetName] = nil
end

function M.removeSelectorGroup(widgetName)
    if widgetName == nil then
        return
    end

    if M.widgetDict[widgetName]["rect2"] ~= nil then
        M.widgetDict[widgetName]["rect2"]:removeSelf()
        M.widgetDict[widgetName]["rect2"] = nil
    end
    if M.widgetDict[widgetName]["mygroup"] ~= nil then
        M.widgetDict[widgetName]["mygroup"]:removeSelf()
        M.widgetDict[widgetName]["mygroup"] = nil
    end
end

return M
