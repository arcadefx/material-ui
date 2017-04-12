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
-- local muiData = require( "mui-data" )

local mathFloor = math.floor
local mathMod = math.fmod
local mathABS = math.abs

local M = {} -- for module array/table

local cache_mt = {}
local parents = {}

M.muiReferences = {}

local muiPath = "materialui."
if _muiPlugin ~= nil and _muiPlugin == true then
  muiPath = "plugin." .. muiPath
end

local modules = {
  "mui-button",
  "mui-card",
  "mui-datetime",
  "mui-dialog",
  "mui-image",
  "mui-navbar",
  "mui-onboarding",
  "mui-popover",
  "mui-progressbar",
  "mui-progresscircle",
  "mui-progressarc",
  "mui-select",
  "mui-shapes",
  "mui-slider",
  "mui-slidepanel",
  "mui-snackbar",
  "mui-switch",
  "mui-tableview",
  "mui-textinput",
  "mui-text",
  "mui-tile",
  "mui-toast",
  "mui-toolbar"
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

function M.isPlugin()
  return _muiPlugin or false
end

function M.init(mui_modules, options)
    local baseModules = {
      "mui-base",
    }
    for i=1, #baseModules do
        local t = require(muiPath .. baseModules[i])
        table.insert(parents, t)
        if M.isPlugin() then
          for k,v in pairs(t) do
              M.muiReferences[k] = v
          end
        end
    end
    M.loadModule(M, parents)
    M.init_base(options)
    if mui_modules ~= nil then modules = mui_modules end
    for i=1, #modules do
        if string.find(modules[i], "materialui.") ~= nil then
          modules[i] = string.gsub(modules[i], "materialui.", "")
        end
        local t = require(muiPath .. modules[i])
        table.insert(parents, t)
        if M.isPlugin() then
          for k,v in pairs(t) do
              M.muiReferences[k] = v
          end
        end
    end
    M.loadModule(M, parents)
    M.init_calls()
    return
end

return M
