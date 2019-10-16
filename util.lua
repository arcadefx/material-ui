local memory = "Tex: "..mfloor(system.getInfo("textureMemoryUsed")/1048576).."mb   Lua:"..mfloor(collectgarbage("count")/1024).."mb"

if network.getConnectionStatus().isConnected then  <do work> end


----- @vlad developer, the flow of events and order of ----

local function myEnterFrame( )
	print( "my enter frame" )
end
Runtime:addEventListener( "enterFrame", myEnterFrame )
local t = transition.to( display.newRect( 1, 1, 2, 5 ), {x=5, time=20, onComplete = function( )
	timer.performWithDelay( 20, function( )
		Runtime:removeEventListener( "enterFrame", myEnterFrame )
	end )
end} )

-- DEBUG: +transition; Added transition event listener!
-- my enter frame
-- my enter frame
-- DEBUG: +timer; Added timer event listener!
-- DEBUG: -transition; Removed transition event listener!
-- my enter frame
-- my enter frame
-- DEBUG: -timer; Removed timer event listener!
