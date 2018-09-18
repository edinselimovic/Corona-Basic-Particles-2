-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
  
-- Require the PEX module and load the particle PEX file
local pex = require( "com.ponywolf.pex" )
local particleData1 = pex.load("emitters/rocket_exhaust.pex", "emitters/texture.png")
local particleData2 = pex.load("emitters/rocket_ignite.pex", "emitters/texture.png")
 
display.setStatusBar(display.HiddenStatusBar)  -- Hide the status bar at the top
 
-- Start off by localising some common helper variables 
local contWidth = display.contentWidth
local contHeight = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY
 
local function emitterCleanUp(obj)
 
	obj:stop()
	display.remove(obj)
	obj = nil
 
end
 
local function rocketCleanUp(obj)
 
	--print( "Transition completed on object: " .. tostring( obj ) )
	display.remove(obj)
	obj = nil
 
end
 
-- Tap Event Listener function to handle each Rocket object tap event
local function rocketTapped(event)
 
	--print("You tapped the rocket!")
 
	local obj = event.target
	local obj_touch_x = event.target.x
	local obj_touch_y = event.target.y
 
	-- Remove the current transition.to
	transition.cancel( obj.trans )
	-- Delete the Touch event listener
	obj:removeEventListener( "tap", rocketTapped )
 
    -- Rotate the rocket to its launch position
    obj.rotation = math.random( 10, 60 )
    local alpha_angle = 90 - obj.rotation
 
    -- Create the rocket exhaust particle effect
	local myEmitter1 = display.newEmitter( particleData1)
	myEmitter1.angle = obj.rotation+90 -- orientate the exhaust angle as per the launch angle
	myEmitter1:stop()
 
	local myEmitter2 = display.newEmitter(particleData2) -- create the rocket igniter particle effect
	myEmitter2:stop()
 
	-- Position the new Particle Effects at the same location at the tap location
	myEmitter1.x = obj_touch_x
	myEmitter1.y = obj_touch_y
	myEmitter2.x = obj_touch_x
	myEmitter2.y = obj_touch_y	
 
	-- Ensure rocket image is on top layer
	obj:toFront()	
 
    -- Set the desired rocket blast off speed in pixels/millisecond
    local rocket_speed = 960/2000 -- half the content area in 2 seconds
 
    -- Find x distance to right edge, then multiply by 2 for rocket end trajectory distance and end point
    local delta_x = contWidth - obj_touch_x
    local adj_dist = 3*delta_x
 
    local end_xpos = obj_touch_x + adj_dist 
 
    -- Find y trajectory distance  and end  point
    local opp_dist = adj_dist * math.tan(alpha_angle * math.pi / 180)
 
    local end_ypos = obj_touch_y - opp_dist
 
    -- Find the length of the trajectory
    local hyponen = math.sqrt( adj_dist*adj_dist + opp_dist*opp_dist)
 
    -- For rocket constant speed, find trajectory transition time
    local delta_t = hyponen / rocket_speed
 
 	local function doNextParticles()
 
    	myEmitter2:stop( ) -- stop the igniter
    	myEmitter1:start( ) -- start the rocket exhaust effect
 
    	-- Start the transitions
    	transition.to( obj, { time = delta_t, x = end_xpos, y = end_ypos , transition=easing.linear, onComplete=rocketCleanUp} )
    	transition.to( myEmitter1, { time = delta_t, delay = 100, x = end_xpos, y = end_ypos , transition=easing.linear, onComplete=emitterCleanUp} )
    	transition.to( myEmitter2, { time = delta_t, delay = 100, onComplete=emitterCleanUp} ) -- dummy transition for cleanup
 		
 	end
 
	myEmitter2:start() -- start the rocket igniter
	timer.performWithDelay(100, doNextParticles, 1) -- after 100ms delay start the launch
 
end
 
local function createNewRocket()
 
	-- Render the rocket image
	local newRocket = display.newImageRect( "rocket_orange.png", 140 , 160 )
 
	-- Add a Tap Event listener to each newRocket object
	newRocket:addEventListener( "tap", rocketTapped )
 
	-- Place the rocket image in the center of the screen and rotate it for left-to-right flight
	newRocket.x = -200
	newRocket.y = math.random(200, contHeight-200) 
	newRocket.rotation = 90
 
	newRocket.trans = transition.to( newRocket, { time = 4000, x = contWidth+200, transition=easing.linear, onComplete=rocketCleanUp} )
 
end
 
createNewRocket()
timer.performWithDelay( 2000, createNewRocket, 0 )