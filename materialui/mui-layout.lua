--[[
A loosely based Material UI module

mui-layout.lua : The layout methods for all other modules.

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

--[[
small screen, portrait: single pane, with logo
small screen, landscape: single pane, with logo
7" tablet, portrait: single pane, with action bar
7" tablet, landscape: dual pane, wide, with action bar
10" tablet, portrait: dual pane, narrow, with action bar
10" tablet, landscape: dual pane, wide, with action bar
TV, landscape: dual pane, wide, with action bar
--]]

--[[
<block align=>
    <group></group>
</block>
--]]

muiData.layout = {}
muiData.block = {}

function M.layoutInit(tab)
end

--[[
{
    name = name of block
    display: relative, absolute (if absolute, align=false)
    align = left, right, center
    ..padding around block..
    padding = 25 50 75 100  (top, right, bottom, left)
    padding_top, padding_right, padding_bottom, padding_left =
    ..margin within block..
    margin = 25 50 75 100  (top, right, bottom, left)
    margin_top, margin_right, margin_bottom, margin_left =
    x, y position (opt)
}
--]]
function M.newBlock(options)
    muiData.block[#muiData.block+1] = display.newGroup()
end

function M.addBlockElement(options)

end

return M
