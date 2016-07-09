--
-- mui-text template module, extend mui
--

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

-- define methods here
function M.createBasicText(options)
	if options == nil then return end

    muiData.widgetDict[options.name] = {}
    muiData.widgetDict[options.name]["type"] = "BasicText"
    muiData.widgetDict[options.name]["options"] = options

    muiData.widgetDict[options.name]["text"] = display.newText( options )
    muiData.widgetDict[options.name]["text"]:setFillColor( unpack(options.fillColor) )
end

function M.removeWidgetBasicText(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    muiData.widgetDict[widgetName]["text"]:removeSelf()
    muiData.widgetDict[widgetName]["text"] = nil
    muiData.widgetDict[widgetName] = nil
end


return M
