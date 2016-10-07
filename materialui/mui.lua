--[[
    A loosely based Material UI module

    mui.lua : This is the parent module to require/load child modules.

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

--]]--

-- mui
local muiData = require( "materialui.mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = {} -- for module array/table

local cache_mt = {}
local parents = {}

local modules = {
  "materialui.mui-button",
  "materialui.mui-card",
  "materialui.mui-datetime",
  "materialui.mui-dialog",
  "materialui.mui-image",
  "materialui.mui-navbar",
  "materialui.mui-onboarding",
  "materialui.mui-popover",
  "materialui.mui-progressbar",
  "materialui.mui-progresscircle",
  "materialui.mui-progressarc",
  "materialui.mui-select",
  "materialui.mui-shapes",
  "materialui.mui-slider",
  "materialui.mui-slidepanel",
  "materialui.mui-switch",
  "materialui.mui-tableview",
  "materialui.mui-textinput",
  "materialui.mui-text",
  "materialui.mui-tile",
  "materialui.mui-toast",
  "materialui.mui-toolbar"
}

function M.loadModule(mui, parents)
  local rawset   = rawset
  function cache_mt:__index(key)
    for i = 1, #parents do
      local parent = parents[i]

      local value = parent[key]
      if value ~= nil then
        rawset(self, key, value)
        return value
      end
    end
  end

  local cache = setmetatable({}, cache_mt)
  setmetatable(M, { __index = cache })
end

function M.init(mui_modules, options)
    local baseModules = {
      "materialui.mui-base",
    }
    for i=1, #baseModules do
        table.insert(parents, require(baseModules[i]))
    end
    M.loadModule(M, parents)
    M.init_base(options)
    if mui_modules ~= nil then modules = mui_modules end
    for i=1, #modules do
        table.insert(parents, require(modules[i]))
    end
    M.loadModule(M, parents)
end

return M
