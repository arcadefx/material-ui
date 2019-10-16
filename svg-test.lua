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

local imageSuffix = display.imageSuffix
print( imageSuffix )

    local aspectRatio = display.pixelHeight / display.pixelWidth
    print("aspectRatio "..aspectRatio)

    -- Gather insets (function returns these in the order of top, left, bottom, right)
    local topInset, leftInset, bottomInset, rightInset = display.getSafeAreaInsets()

    mui.init(nil, {parent = self.view, useSvg = true})

    local imageSuffix = mui.getImageSuffixName("Icon-60.png")
    print( imageSuffix )

    --[[--
    -- Create a vector rectangle sized exactly to the "safe area"
    print("display.screenOriginX ", display.screenOriginX )
    print("display.screenOriginY ", display.screenOriginY )
    print("topInset "..topInset)
    local background = display.newRect(
        display.screenOriginX + leftInset,
        display.screenOriginY + topInset,
        display.actualContentWidth - (leftInset + rightInset),
        display.actualContentHeight - (topInset + bottomInset))
    print("background.width "..background.width)
    print("background.height "..background.height)
    background:setFillColor(1)
    background:translate(background.width * 0.5, background.width * 0.5)
    --background:translate(0, 0)
    --background.x = background.width * 0.5 -- display.contentWidth * 0.5
    --background.y = background.width * 0.5 -- display.contentHeight * 0.5
    sceneGroup:insert(background)
    --]]--

local safeArea = display.newRect(
    display.safeScreenOriginX,
    display.safeScreenOriginY,
    display.safeActualContentWidth,
    display.safeActualContentHeight
)
safeArea:translate( safeArea.width*0.5, safeArea.height*0.5 )
sceneGroup:insert(safeArea)

    local b = display.newRect(
        display.safeScreenOriginX,
        display.safeScreenOriginY,
        100,
        100
    )
    b:setFillColor(1, 0.2, 0.2)
    b:translate(b.width * 0.5, b.width * 0.5)
    sceneGroup:insert(b)

    print(" display.contentWidth"..display.contentWidth)

    local buttonMessage = function(event)
        local callBackData = mui.getEventParameter(event, "muiTargetCallBackData")
        if callBackData ~= nil then
            print("Button message: "..callBackData.message)
        end
    end

    -- mui-logo-2017.png
    -- set controls to use 1x, 2x, 4x too! like choose a min size, middle and large!
    mui.newImageRect({
        name = "logo",
        image = "image.jpg",
        width = 200,
        height = 160
    })
    local logo = mui.getImageRectProperty("logo")
    ---[[--
    print("logo width "..logo.width)
    print("logo height "..logo.height)
    print("logo contentWidth "..logo.contentWidth)
    print("logo contentHeight "..logo.contentHeight)
    logo.x = display.safeScreenOriginX + display.safeActualContentWidth / 2
    logo.y = display.safeScreenOriginY + display.safeActualContentHeight / 2
    --]]--
    --logo.width = logo.width * muiData.masterRatio
    --logo.height = logo.height * muiData.masterRatio

    -- make this a default for all methods, so you don't have scalePos on user-side
    function scaleRatio( x, y, type )
        -- body
        local sx, sy
        if muiData.isPhone then
            sx = 1
            sy = 1
        else
            sx = muiData.masterRatio
            sy = muiData.masterRatio
        end
        return { x = sx, y = sy }
    end

    local scale = scaleRatio(150, 30, 'match')

    mui.newTextField({
        name = "textfield_demo4",
        labelText = "My Topic",
        text = "Hello, World!",
        font = native.systemFont,
        width = 150 * scale.x,
        height = 30 * scale.y,
        x = display.contentWidth * 0.75,
        y = display.contentHeight * 0.25,
        activeColor = { 0.12, 0.67, 0.27, 1 },
        inactiveColor = { 0.4, 0.4, 0.4, 1 },
        callBack = mui.textfieldCallBack,
        state = {
            value = "off",
            disabled = {
                fieldBackgroundColor = { .7,.7,.7,1 },
                callBack = buttonMessage,
                callBackData = {message = "button is disabled"}
            }
        },
        backgroundFake = {
            off = {
                image = "TextBackground.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            },
            disabled = {
                image = "TextBackground-disabled.jpg",
                xsvg = {
                    path = "jigsaw.svg"
                }
            }
        },  
        background = {
            image = "TextBackground.jpg",
            xsvg = {
                path = "jigsaw.svg"
            }
        }
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

