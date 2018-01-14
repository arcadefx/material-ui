--[[
    A loosely based Material UI module

    mui-svg.lua : The base svg methods for all other modules.

    The MIT License (MIT)

    Copyright (C) 2016-2018 Anedix Technologies, Inc.  All Rights Reserved.

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

-- mui
local muiData = require( "materialui.mui-data" )
local nanosvg = nil

local M = muiData.M -- {} -- for module array/table

if muiData.useSvg ~= nil and muiData.useSvg then
    nanosvg = require( "plugin.nanosvg" )
end

M.svg = {}
M.svg["path"] = "materialui/material-design-icons/"

function M.newSvgImage( options )
	if nanosvg == nil or options == nil then return nil end

	M.svg["basedir"] = options.basedir or system.ResourceDirectory
	options.x = options.x or display.contentCenterX
	options.y = options.y or display.contentCenterY
	options.width = options.width or 150
	options.height = options.height or 150

	path = options.path or M.svg["path"]
	if options.category ~= nil then
		path = path .. "/" .. options.category
	end
	muiData.widgetDict[options.name] = {}
	muiData.widgetDict[options.name]["type"] = "ImageSvg"

	if M.stringEnds(path, "/") == false then
		path = path .. "/"
	end
	muiData.widgetDict[options.name]["image_svg"] = nanosvg.newImage({
	    baseDir = M.svg["basedir"],
	    filename = path .. options.filename,
	    x = options.x,
	    y = options.y,
	    width = options.width,
	    height = options.height
	})
    return muiData.widgetDict[options.name]["image_svg"]
end

function M.getImageSvgProperty(widgetName, propertyName)
	local property = nil
    if widgetName ~= nil and muiData.widgetDict[widgetName] ~= nil then
    	property = muiData.widgetDict[widgetName]["image_svg"]
    end
    return property
end

function M.removeImageSvg(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if muiData.widgetDict[widgetName]["image_svg"] ~= nil then
	    muiData.widgetDict[widgetName]["image_svg"]:removeSelf()
	    muiData.widgetDict[widgetName]["image_svg"] = nil
	    muiData.widgetDict[widgetName] = nil
	end
end

function M.newSvgImageWithStyle( options )
    if options == nil then return nil end
    if muiData.widgetDict[options.name] == nil then
        muiData.widgetDict[options.name] = {}
        muiData.widgetDict[options.name]["type"] = "ImageSvgStyle"
    end
    options.width = options.width or 50
    options.height = options.height or 50
    options.fillColor = M.colorToHex(options.fillColor) or "red"
    options.strokeColor = M.colorToHex(options.strokeColor) or "white"
    options.strokeWidth = options.strokeWidth or 0
    options.hasRawContent = muiData.widgetDict[options.name]["svgContentRaw"] or nil
    local path = system.pathForFile( options.path, system.ResourceDirectory )
    local file = nil
    if not options.hasRawContent then
        file = assert(io.open( path, "r" ))
    else
        file = true
    end
    local data = ""
    local newImage = nil
    if file then
        local content = ""
        if not options.hasRawContent then
            content = file:read("*all")
            file:close()
        else
            content = muiData.widgetDict[options.name]["svgContentRaw"]
        end
        str = " style=\"fill:"..options.fillColor.."; stroke: "..options.strokeColor.."; stroke-width: "..options.strokeWidth.."\""
        data = string.gsub(content, "/>",str.."/>", 1)
        muiData.widgetDict[options.name]["svgContentRaw"] = content
        muiData.widgetDict[options.name]["svgContent"] = data
    end

    if string.len(data) > 0 then
        newImage = nanosvg.newImage(
        {
            data = data,
            width = options.width,
            height = options.height,
            x = options.x or 0,
            y = options.y or 0,
        })
    end
    muiData.widgetDict[options.name]["image_svg"] = newImage
    return newImage
end

function M.removeImageSvgStyle(widgetName)
    if widgetName == nil then
        return
    end

    if muiData.widgetDict[widgetName] == nil then return end

    if muiData.widgetDict[widgetName]["svgContentRaw"] ~= nil then
        muiData.widgetDict[widgetName]["svgContentRaw"] = nil
	end
    if muiData.widgetDict[widgetName]["image_svg"] ~= nil then
        muiData.widgetDict[widgetName]["image_svg"]:removeSelf()
        muiData.widgetDict[widgetName]["image_svg"] = nil
    end
    muiData.widgetDict[widgetName] = nil
end

return M
