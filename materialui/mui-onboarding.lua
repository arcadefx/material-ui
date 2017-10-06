--
-- mui-example template module, extend mui
--

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs
local screenW = muiData.contentWidth
local screenH = muiData.contentHeight

local M = muiData.M -- {} -- for module array/table

function M.createParentOnBoard( options )
    return M.newParentOnBoard(options)
end

function M.newOnBoard( options )
    return M.newParentOnBoard(options)
end

function M.newParentOnBoard( options )
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
					M.updateSlideIndicator()
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

function M.createElipsesForProgress( options )
    M.newElipsesForProgress( options )
end

function M.newElipsesForProgress( options )
	if options == nil then return end
	if options.parent == nil or options.group == nil then return end
	if options.slides ~= nil and options.slides < 2 then return end

	if muiData.slideData ~= nil then muiData.slideData = nil end
	muiData.slideData = {}

	if options.shape == nil then options.shape = "rect" end

	local size = options.size or 10
	local spacing = 0
	local width = 0
	if options.shape == "rect" then
		spacing = size * 0.5
		width = (size * options.slides) + (spacing * (options.slides - 1))
	elseif options.shape == "circle" then
		size = size * 0.5
		spacing = size
		width = ((size * 2) * options.slides) + (spacing * (options.slides - 1))
	end
	local x = (screenW - width) * 0.5


	if muiData.onBoardData == nil then muiData.onBoardData = {} end

	if options.y == nil then options.y = screenH - size end
	if options.fillColor == nil then
		options.fillColor = { 0, 0, 0 }
	end

	-- M.addChildOnBoard
	muiData.slideData.slideIndicator = options.parent
	muiData.slideData.slideCount = options.slides
	muiData.slideData.fillColor = options.fillColor
	for i=1, options.slides, 1 do
		local object = nil
		if options.shape == "rect" then
			object = display.newRect( x, options.y, size, size )
		else
			spacing = size + (size * 0.5)
			object = display.newCircle( x, options.y, size )
		end
		-- create a backdrop for the top
	    local block = M.addChildOnBoard({
	        parent = options.parent,
	        name = "block-"..i,
	        object = object
	    })
	    block.anchorX = 0
	    block.anchorY = 0
	    block.strokeWidth = 2
	    block:setStrokeColor( unpack( options.fillColor ) )
		if i == 1 then
            block:setFillColor( unpack( {1,0,0,0} ) )
		else
            block:setFillColor( unpack( options.fillColor ) )
		end
	    options.group:insert( block )
	    if options.shape == "rect" then
		    x = x + ( i * size ) + spacing
		else
		    x = x + ( i * (size * 2) ) + spacing
		end
	end
end

function M.updateSlideIndicator()

	if muiData.onBoardData == nil or muiData.slideData == nil then return end
	if muiData.slideData.slideCount < 2 or muiData.onBoardData[muiData.slideData.slideIndicator] == nil then return end

	local slideIndicator = nil
	for i = 1, muiData.slideData.slideCount, 1 do
		slideIndicator = muiData.onBoardData[muiData.slideData.slideIndicator]["block-"..i]
		if slideIndicator ~= nil then
			if i == muiData.currentSlide then
                slideIndicator:setFillColor( unpack( { 1, 0, 0, 0 } ) )
			else
                slideIndicator:setFillColor( unpack( muiData.slideData.fillColor ) )
			end
	    end
    end
end

function M.removeWidgetOnBoarding()
    M.removeOnBoarding()
end

function M.removeOnBoarding()
    if muiData.onBoardData == nil then return end

    for i, groups in pairs(muiData.onBoardData) do
        if groups ~= nil then
            for j, group in pairs(groups) do
                if group ~= nil then
                    group:removeSelf()
                    group = nil
                end
            end
            groups = nil
        end
    end
    muiData.onBoardData = nil
end

return M
