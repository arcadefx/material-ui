--
-- mui-example template module, extend mui
--

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.createParentOnBoard( options )
	if options == nil then return end

	if muiData.onBoardData == nil then muiData.onBoardData = {} end
	muiData.onBoardData[options.name] = {}
	muiData.onBoardData[options.name]["object"] = options.object

	return options.object
end

function M.addChildOnBoard( options )
	if options == nil then return end

	if muiData.onBoardData == nil then muiData.onBoardData = {} end
	muiData.onBoardData[options.parent][options.name] = options.object

	return options.object
end

function M.prepareSlidesForOnBoarding( slideConfig )
    if slideConfig == nil then return end
    if slideConfig.slides == nil then return end

    local x = 0
    local y = 0
    local screenW = display.contentWidth
    muiData.currentSlide = 1

    if slideConfig.transition ~= nil and slideConfig.transition == "to" then
        -- if slideConfig.
    else
        slideConfig.transition = "fade"
        x = 0
        y = 0
    end

    for i, slide in pairs(slideConfig.slides) do
        if slideConfig.transition == "to" then
            if slideConfig.direction == "left" then
                if i > 1 then
                    slide.x = screenW
                else
                    slide.x = 0
                end
            end
        elseif slideConfig.transition == "fade" then
            slide.x = x
            slide.y = y
            if i > 1 then
                slide.alpha = 0
            else
                slide.alpha = 1
            end
        end
    end
end

--
--  switch the slide
--
function M.switchSlideForOnBoard( event )
    if event.callBackData == nil then return end
    local callBackData = event.callBackData

    if callBackData ~= nil then
        local slideCount = #callBackData.slides
        for i, slide in pairs(callBackData.slides) do
            if i >= muiData.currentSlide and muiData.currentSlide ~= slideCount then
                M.transitionSlideForOnBoard( i, slide, callBackData )
                if i > muiData.currentSlide then
                    muiData.currentSlide = i
                    break
                end
            elseif muiData.currentSlide == slideCount then
                M.goToScene( callBackData )
                break
            end
        end
    end
end

function M.transitionSlideForOnBoard(i, obj, slideConfig)
    if obj ~= nil and slideConfig ~= nil then
        if slideConfig.easing == nil then
            slideConfig.easing = easing.outExpo
        end
        if slideConfig.time == nil then
            slideConfig.time = 2000
        end
        if slideConfig.transition == nil then
            slideConfig.transition = "fade"
        end
        local optionsTo = { time = slideConfig.time, x = x, y = y, transition = slideConfig.easing }
        if slideConfig.transition == "to" and slideConfig.direction == "left" then
            optionsTo.x = 0
            transition.to( obj, optionsTo )
        elseif slideConfig.transition == "fade" then
            if i == muiData.currentSlide then
                transition.to( obj, { time = slideConfig.time, alpha=0 } )
            else
                transition.to( obj, { time = slideConfig.time, alpha=1 } )
            end
        end
    end
end

return M
