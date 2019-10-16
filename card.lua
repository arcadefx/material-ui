-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local sqlite3 = require("sqlite3")

transition = require("transition2")
local mui = require("materialui.mui")
local database = require("database")

-- mui
local muiData = require("materialui.mui-data")

local scene = composer.newScene()
local background = nil

local leftSide = display.screenOriginX;
local rightSide = display.contentWidth-display.screenOriginX;
local topSide = display.screenOriginY;
local bottomSide = display.contentHeight-display.screenOriginY;

local totalWidth = display.contentWidth-(display.screenOriginX*2);
local totalHeight = display.contentHeight-(display.screenOriginY*2);
local centerX = display.contentCenterX;
local centerY = display.contentCenterY;

--[[
print("display.contentScaleX "..display.contentScaleX)
print("display.contentScaleY "..display.contentScaleY)
print("totalWidth "..totalWidth)
print("totalHeight "..totalHeight)
--]]
print("centerX "..centerX)
print("centerY "..centerY)

local shadow = nil
local rrect = nil
local shadowPrefs = {}
local busyShadow = false

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------

-- "scene:create()"
function scene:create(event)

    local sceneGroup = self.view

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

    --Hide status bar from the beginning
    display.setStatusBar(display.HiddenStatusBar)
    display.setDefault("background", 0.23, 0.23, 0.23)

    -- Gather insets (function returns these in the order of top, left, bottom, right)
    local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

    mui.init(nil, {parent = self.view, useSvg = true})

    -- Create a vector rectangle sized exactly to the "safe area"
    local background = display.newRect(
        display.screenOriginX + leftInset,
        display.screenOriginY + topInset,
        display.contentWidth - (leftInset + rightInset),
        display.contentHeight - (topInset + bottomInset))
    background:setFillColor(unpack({0.88,.88,0.88,1}))
    background:translate(background.width * 0.5, background.height * 0.5)
    sceneGroup:insert(background)

    local buttonMessage = function(event)
        local callBackData = mui.getEventParameter(event, "muiTargetCallBackData")
        if callBackData ~= nil then
            print("Button message: "..callBackData.message)
        end
    end

    local w, h = 150, 150

    shadowPrefs.card = {}
    shadowPrefs.card.resting = {
        size = 10,
        cornerRadius = 5,
        xOffset = 0,
        yOffset = 2,
        opacity = .2,
    }
    shadowPrefs.card.raised = {
        size = 20,
        cornerRadius = 5,
        xOffset = 0,
        yOffset = 4,
        opacity = .4,
    }
    -- local cardBegin, cardEnd = "resting", "raised"
    local cardBegin, cardEnd = "resting", "raised"

    local groupTest = display.newGroup()

    local function createShadowTest(prefs)
        -- body
        if shadow ~= nil then 
            shadow:removeSelf()
            shadow = nil
        end
        if rrect ~= nil and false then 
            rrect:removeSelf()
            rrect = nil
        end
        shadow = mui.newShadowShapev2({
            name = "shadow_test", 
            -- shape = "rounded_rect",
            shape = "rect",
            width = w,
            height = h,
            prefs = prefs
        })
        groupTest:insert(shadow)

        -- rrect = display.newRoundedRect( 0, 0, w, h, 5 )
        if rrect == nil then
            print("rrect created!")
            rrect = display.newRect( 0, 0, w, h )
            rrect:setFillColor(unpack({.69,.89,1,1}))
            groupTest:insert(rrect)
        end
        shadow:toBack()
    end

    local length = 350
    local duration = length -- * 1000
    local startTime = system.getTimer()
    local increment = shadowPrefs.card[cardBegin].size
    local incrementOpacity = shadowPrefs.card[cardBegin].opacity
    local incrementOffsetY = shadowPrefs.card[cardBegin].yOffset

    local function shadowFunc( e )
        local runTime = system.getTimer()
        local tm = startTime + length
        local percentInc = (runTime - startTime) / duration
        if(startTime + length > runTime) then
            local cardStop = false
            if cardBegin == "resting" then
                increment = increment + percentInc
                incrementOpacity = incrementOpacity + ((shadowPrefs.card[cardEnd].opacity - incrementOpacity) * percentInc)
                incrementOffsetY = incrementOffsetY + ((shadowPrefs.card[cardEnd].yOffset - incrementOffsetY) * percentInc)
                if increment > shadowPrefs.card[cardEnd].size then
                    cardStop = true
                end
            elseif cardBegin == "raised" then
                increment = increment - percentInc
                incrementOpacity = incrementOpacity - ((incrementOpacity - shadowPrefs.card[cardEnd].opacity) * percentInc)
                incrementOffsetY = incrementOffsetY - ((incrementOffsetY - shadowPrefs.card[cardEnd].yOffset) * percentInc)
                if increment < shadowPrefs.card[cardEnd].size then
                    cardStop = true
                end
            end
            if cardStop then
                increment = shadowPrefs.card[cardEnd].size
                incrementOpacity = shadowPrefs.card[cardEnd].opacity
                incrementOffsetY = shadowPrefs.card[cardEnd].yOffset
                Runtime:removeEventListener("enterFrame", shadowFunc)
                -- print("B finished shadowFunc "..os.time())
                cardStop = false
                busyShadow = false
            end
            prefs = {
                size = increment,
                cornerRadius = 5,
                xOffset = 0,
                yOffset = incrementOffsetY,
                opacity = incrementOpacity
            }
            createShadowTest(prefs)
        else
            -- do it one last time to make sure we have the final size
            -- print("A finished shadowFunc "..os.time())
            Runtime:removeEventListener("enterFrame", shadowFunc)
            busyShadow = false
        end
    end

    createShadowTest(shadowPrefs.card[cardBegin])
    groupTest.x = centerX
    groupTest.y = centerY
    sceneGroup:insert(groupTest)
    Runtime:addEventListener("enterFrame", shadowFunc)
    -- transition.from(groupTest, {time=1500, y=-(groupTest.contentHeight), transition=easing.outBounce})

    -- mui-logo-2017.png
    --[[
    mui.newImageRect({
        name = "logo",
        image = "mui-logo-2017.png",
        width = 144, -- * mui.getScaleFactor(),
        height = 93, -- * mui.getScaleFactor()
    })
    local logo = mui.getImageRectProperty("logo")
    if logo ~= nil then
        logo.x = centerX
        logo.y = centerY
    else
        print("nope")
    end
    sceneGroup:insert( logo )
    --]]

    -- dialog box example
    -- use mui.getWidgetBaseObject("dialog_demo") to get surface to add more content
    local showDialog = function(e)
        local muiTargetValue = mui.getEventParameter(e, "muiTargetValue")
        local muiTargetCallBackData = mui.getEventParameter(e, "muiTargetCallBackData")
        -- mui.debug("data passed: "..muiTargetCallBackData.food)
            mui.newDialog({
            name = "dialog_demo",
            width = 350,
            height = 200,
            text = "Do you want to continue?",
            textX = 0,
            textY = 0,
            textColor = { 0, 0, 0, 1 },
            font = native.systemFont,
            fontSize = 18,
            fillColor = { 1, 1, 1, 1 },
            background = "TextBackground.jpg",
            gradientBorderShadowColor1 = { 1, 1, 1, 0.4 },
            gradientBorderShadowColor2 = { 0, 0, 0, 0.4 },
            easing = easing.inOutCubic, -- this is default if omitted
            buttons = {
                font = native.systemFont,
                okayButton = {
                    text = "Okay",
                    textColor = { 0, 0, 0 },
                    fillColor = { 1, 1, 1 },
                    width = 100,
                    height = 35,
                    callBackOkay = mui.actionForOkayDialog,
                    clickAnimation = {
                        fillColor = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                },
                cancelButton = {
                    text = "Cancel",
                    textColor = { 0, 0, 0 },
                    fillColor = { 1, 1, 1 },
                    width = 100,
                    height = 35,
                    clickAnimation = {
                        fillColor = { 0.4, 0.4, 0.4, 0.4 },
                        time = 400
                    }
                }
            }
        })
    end

    local w = 130 - (130 * display.contentScaleX)
    local h = 35 - (35 * display.contentScaleX)

    --[[
    mui.newRoundedRectButton({
            parent = mui.getParent(),
            name = "newDialog",
            text = "Open Dialog",
            width = w,-- * mui.getScaleFactor(),
            height = h,-- * mui.getScaleFactor(),
            x = (150*.5)+10,
            y = (40*.5)+10,
            radius = 10,
            font = native.systemFont,
            iconAlign = "left",
            state = {
                value = "off",
                off = {
                    textColor = {1, 1, 1},
                    fillColor = {0, 0.81, 1}
                    --svg = {path = "ic_view_list_48px.svg"}
                },
                on = {
                    textColor = {1, 1, 1},
                    fillColor = {0, 0.61, 1}
                    --svg = {path = "ic_help_48px.svg"}
                },
                disabled = {
                    textColor = {1, 1, 1},
                    fillColor = {.3, .3, .3}
                    --svg = {path = "ic_help_48px.svg"}
                }
            },
            gradientShadowColor1 = {0.9, 0.9, 0.9, 255},
            gradientShadowColor2 = {0.9, 0.9, 0.9, 0},
            gradientDirection = "up",
            callBack = showDialog,
            callBackData = {message = "newDialog callBack called"}, -- demo passing data to an event
        })

    local o = mui.getWidgetBaseObject("newDialog")
    print("o.contentWidth "..o.contentWidth)
    local x,y = mui.getSafeXY({}, 0, 0) -- is 10 due to shadow being 20 or 10 pixels around rect. so 0,0 is true 10,10
    o.x = x + (o.contentWidth *.5)
    o.y = y + (o.contentHeight *.5)
    --]]--

    local card = "resting"
    local shadowPress = function(e)
        if busyShadow then return end
        busyShadow = true

        if cardBegin == "resting" then
            cardBegin = "raised"
            cardEnd = "resting"
        else
            cardBegin = "resting"
            cardEnd = "raised"
        end
        if shadowPrefs.card[card] ~= nil then
            startTime = system.getTimer()
            increment = shadowPrefs.card[cardBegin].size
            incrementOpacity = shadowPrefs.card[cardBegin].opacity
            incrementOffsetY = shadowPrefs.card[cardBegin].yOffset
            createShadowTest(shadowPrefs.card[cardBegin])
            Runtime:addEventListener("enterFrame", shadowFunc)
        end
    end

    mui.newRoundedRectButton({
            parent = mui.getParent(),
            name = "shadowTestButton",
            text = "Card Shadow",
            width = 100,-- * mui.getScaleFactor(),
            height = 25,-- * mui.getScaleFactor(),
            x = (150*.5)+10,
            y = (20)+10,
            radius = 10,
            font = native.systemFont,
            iconAlign = "left",
            state = {
                value = "off",
                off = {
                    textColor = {1, 1, 1},
                    fillColor = {0, 0.61, 1}
                    --svg = {path = "ic_view_list_48px.svg"}
                },
                on = {
                    textColor = {1, 1, 1},
                    fillColor = {0, 0.61, 1}
                    --svg = {path = "ic_help_48px.svg"}
                },
                disabled = {
                    textColor = {1, 1, 1},
                    fillColor = {.3, .3, .3}
                    --svg = {path = "ic_help_48px.svg"}
                }
            },
            --gradientShadowColor1 = {0.9, 0.9, 0.9, 255},
            --gradientShadowColor2 = {0.9, 0.9, 0.9, 0},
            --gradientDirection = "up",
            callBack = shadowPress,
            callBackData = {message = "newDialog callBack called"}, -- demo passing data to an event
        })
    local o2 = mui.getWidgetBaseObject("shadowTestButton")
    print("o2.contentWidth "..o2.contentWidth)
    local x,y = mui.getSafeXY({}, 0, (40*.5)+10 + 20) -- is 10 due to shadow being 20 or 10 pixels around rect. so 0,0 is true 10,10
    o2.x = x + (o2.contentWidth *.5)
    o2.y = y + (o2.contentHeight *.5)


    --
    -- Set up the card
    --
    local topHeight = 100
    local bottomHeight = 120
    mui.newCard({
        name = "demo-card",
        x = centerX * 0.7,
        y = centerY,
        title = "Hello Card",
        topHeight = topHeight,
        bottomHeight = bottomHeight,
        width = display.contentWidth * 0.5,
        height = topHeight + bottomHeight,
        fillColor = {1, 1, 1, 1},
        fillColorBottom = {0.22, 0.55, 0.23},
        --strokeWidth = 1,
        --strokeColor = {0.2, 0.2, 0.2},
        useShadow = true,
        --radius = 5,
    })

    -- access card group.
    -- local demoCard = mui.getWidgetBaseObject( "demo-card" )

    mui.newTextField({
        name = "textfield_demo4",
        labelText = "My Topic",
        text = "Hello, World!",
        font = native.systemFont,
        width = 200,
        height = 30,
        x = 130,
        y = 190,
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        inputType = "phone",
        callBack = mui.textfieldCallBack
    })
end

-- "scene:show()"
function scene:show(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif (phase == "did") then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.

    end
end

-- "scene:hide()"
function scene:hide(event)

    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.

    elseif (phase == "did") then
        -- Called immediately after scene goes off screen
    end
end

-- "scene:destroy()"
function scene:destroy(event)

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
    mui.destroy()
    if background ~= nil then
        background:removeSelf()
        background = nil
    end
    sceneGroup:removeSelf()
    sceneGroup = nil

end

-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- -------------------------------------------------------------------------------

return scene

