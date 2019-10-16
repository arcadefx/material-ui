--[[
A loosely based Material UI module

mui-scale.lua : The scaling methods for all other modules.

The MIT License (MIT)

Copyright (C) 2016-2018 Anedix Technologies, Inc. All Rights Reserved.

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

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = muiData.M -- {} -- for module array/table

function M.scaleTableInit(tab)
    if tab == nil then
        muiData.scaleTable = {}
    else
        muiData.scaleTable = tab
    end
end

function M.setScaleForWidget( options )
    if options == nil then return end
    if options.scaleFactorX ~= nil then
        muiData.scaleTable[options.name].scaleFactorX = options.scaleFactorX
    end
    if options.scaleFactorY ~= nil then
        muiData.scaleTable[options.name].scaleFactorY = options.scaleFactorY
    end
end

function M.scaleContentDownX(percent)
    if percent == nil then return muiData.scaleFactorX end
    return muiData.scaleFactorX - (muiData.scaleFactorX * percent)
end

function M.scaleContentDownY(percent)
    if percent == nil then return muiData.scaleFactorY end
    return muiData.scaleFactorY - (muiData.scaleFactorY * percent)
end

function M.scaleContentUpX(percent)
    if percent == nil then return muiData.scaleFactorX end
    return muiData.scaleFactorX + (muiData.scaleFactorX * percent)
end

function M.scaleContentUpY(percent)
    if percent == nil then return muiData.scaleFactorY end
    return muiData.scaleFactorY + (muiData.scaleFactorY * percent)
end

function M.getScaleY(n)
    if n == nil then n = 1 end
    return mathFloor(M.getScaleFactorY() * n)
end

function M.getScaleX(n)
    if n == nil then n = 1 end
    return mathFloor(M.getScaleFactorX() * n)
end

function M.scaleFactorInit()
    M.getScaleFactorX()
    M.getScaleFactorY()
end

function M.getScaleFactor()
    if system.getInfo( "environment" ) ~= "simulator" and muiData.scaleFactorX ~= nil then
        return muiData.scaleFactorX
    end
    local divisor = 1

    if M.getOrientation() == "portrait" then
        divisor = muiData.minPixelScaleWidthForPortrait
    else
        divisor = muiData.minPixelScaleWidthForLandscape
    end

    local totalWidth = display.contentWidth-(display.screenOriginX*2);

    print("totalWidth "..totalWidth)
    print("divisor "..divisor)
    muiData.masterRatio = totalWidth / divisor
    muiData.scaleFactorX = muiData.masterRatio

    -- muiData.masterRatio = muiData.contentWidth / divisor
    return muiData.scaleFactorX
end

function M.getScaleFactorX()
    if not muiData.autoScale then return 1 end
    return M.getScaleFactor()
end

function M.getScaleFactorY()
    if not muiData.autoScale then return 1 end
    if system.getInfo( "environment" ) ~= "simulator" and muiData.scaleFactorY ~= nil then
        return muiData.scaleFactorY
    end
    local divisor = 1
    if M.getOrientation() == "portrait" then
        divisor = muiData.minPixelScaleHeightForPortrait
    else
        divisor = muiData.minPixelScaleHeightForLandscape
    end

    local totalHeight = display.contentHeight-(display.screenOriginY*2);

    muiData.scaleFactorY = totalHeight / divisor
    -- muiData.masterRemainder = mathMod(muiData.contentHeight, divisor)
    return muiData.scaleFactorY
end

--[[
    depreciated, compatiblity kept for now
--]]
function M.getScaleVal(n)
    if n == nil then n = 1 end
    return mathFloor(M.getScaleFactorX() * n)
end

return M
