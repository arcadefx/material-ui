--[[
	A loosely based Material UI module

	mui-shapes.lua : This is for creating various shapes

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

local mathCOS = math.cos
local mathSIN = math.sin
local mathFLOOR = math.floor

local M = muiData.M -- {} -- for module array/table

function randomRGBColor()
	return (math.random() + math.random(1, 99)) / 100
end

-- https://gist.github.com/HoraceBury/9431861

-- rotates point around the centre by degrees
-- rounds the returned coordinates using math.round() if round == true
-- returns new coordinates object
local function rotateAboutPoint( point, degrees, centre )
	local pt = { x=point.x - centre.x, y=point.y - centre.y }
	pt = math.rotateTo( pt, degrees )
	pt.x, pt.y = pt.x + centre.x, pt.y + centre.y
	return pt
end
math.rotateAboutPoint = rotateAboutPoint

-- rotates a point around the (0,0) point by degrees
-- returns new point object
-- center: optional
local function rotateTo( point, degrees, center )
	if (center ~= nil) then
		return rotateAboutPoint( point, degrees, center )
	else
		local x, y = point.x, point.y

		local theta = math.rad( degrees )

		local pt = {
			x = x * math.cos(theta) - y * math.sin(theta),
			y = x * math.sin(theta) + y * math.cos(theta)
		}

		return pt
	end
end
math.rotateTo = rotateTo

--
--
-- based on M.newArcRenderTime(options)
-- render Arc without a timed based renderer
--
function M.newArc(options)
	if options == nil then return nil end
	options.range = options.angle
	return M.newArcByRenderTime(options)
end

--
-- original idea by horacebury and uses his mathliblua.
-- modified by arcadefx for mui
--
-- Needs refactoring to be more modular and pass in group
--
function M.newArcByRenderTime(options)
	if math.rotateAboutPoint == nil or math.rotateTo == nil then
		M.debug("mathliblua dependency not met. Be sure to enabled it.")
		return nil
	end 

	local renderFunc = nil
	local group = nil
	if options.group == nil then 
		group = display.newGroup()
		options.group = group
	else
		group = options.group
	end
	group.i = options.range -- range count, if you want 360 arc/circle, just pass "360" here
	group.name = options.name
	group.muiArcOptions = options -- retain user options
	group.transitionDone = false
	group.finished = false

	local function newCycle( parent, x, y, inner, outer, from, range )
		range = range or 1
		if (range < 1) then
			range = 1
		elseif (range > 360) then
			range = 360
		end
		local centre = {x=0,y=0}
		local pt = {x=0, y=-(inner+(outer-inner)/2)}
		pt = math.rotateTo( pt, from, centre )
		local path = {pt.x,pt.y}
		for i=1, range do
			pt = math.rotateTo( pt, 1, centre )
			path[#path+1] = pt.x
			path[#path+1] = pt.y
		end
		local newl = display.newLine( parent, unpack( path ) )
		 newl.strokeWidth = outer-inner
		newl.x, newl.y = x, y
		newl:setStrokeColor( unpack(group.muiArcOptions.strokeColor) )
		if group.muiArcOptions.callBackUpdate ~= nil then
			assert( group.muiArcOptions.callBackUpdate )(group, range)
		end
		if range >= group.muiArcOptions.angle or (group.muiArcOptions.toAngle ~= nil and range >= group.muiArcOptions.toAngle) then
			if group.finished == false then
				Runtime:removeEventListener( "enterFrame", renderFunc )
				group.finished = true
				if group.muiArcOptions.onCompleteInternal ~= nil then
					assert( group.muiArcOptions.onCompleteInternal)(group, range)
				end
				if group.muiArcOptions.onComplete ~= nil then
					assert( group.muiArcOptions.onComplete )(group, range)
				end
			end
		end
		return newl
	end

	local function render()

		line = newCycle(
			group,
			group.muiArcOptions.x,
			group.muiArcOptions.y,
			group.muiArcOptions.inner,
			group.muiArcOptions.outer,
			group.muiArcOptions.fromAngle,
			group.i
		)
	end
	renderFunc = render -- create reference for removeEventListener.

	local function onComplete()
		group.transitionDone = true
		Runtime:removeEventListener( "enterFrame", render )
	end

	local angle = group.muiArcOptions.angle
	if group.muiArcOptions.toAngle ~= nil then
		angle = group.muiArcOptions.toAngle
	end

	transition.to( group, { time=group.muiArcOptions.time, i=angle, onComplete=onComplete } )
	Runtime:addEventListener( "enterFrame", render )

	return group
end

function M.removeNewArcByRenderTime(group)
	if group == nil then return end
	for i=group.numChildren,1,-1 do
		local child = group[i]
		child:removeSelf()
		child = nil
	end
	group:removeSelf()
end

return M
