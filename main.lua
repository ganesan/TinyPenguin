-- 
-- Abstract: Tiny Penguin - aka Tiny Wings -
-- 
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010-2011 ANSCA Inc. All Rights Reserved.

-- Demonstrates how to use create draggable objects with multitouch. Also shows how to move
-- an object to the front of the display hierarchy.

require ("physics")



physics.start()
physics.setGravity(0,9.8)
physics.setDrawMode("hybrid")

local mainGroup = display.newGroup()

local clouds = {}
table.insert(clouds, "cloud_1.png");table.insert(clouds, "cloud_2.png")
table.insert(clouds, "cloud_3.png");table.insert(clouds, "cloud_4.png")

local cloudVelocityX = -40
local hillToCloudRatio = 5
local cloudInterval = 1

local hillYPosition = display.contentHeight  - display.contentHeight / 4 -- The y position of the bottom of the hill

local sideBuffer = display.contentWidth

-- The offset (where the bottom of a hill will be place)
-- We want the offset to be a big negative so there is are hills to the left of the screen
local hillOffSet =  -sideBuffer

local bird
local birdRadius = 10
local birdFixedCoordX = display.contentWidth / 5
local minBirdHorzVel = 150--display.contentWidth / 10
local birdAppliedForce = 0.15

local hillHeight = 40
local hillAmpMinValue = .5
local hillAmpRange = .7
local isFingerDown = false

-- We need to put everything into a group so we can move it such that the bird is always in the same x coordinate (birdFixedCoordX)
local imagesGroup = display.newGroup()
local mainGroup = display.newGroup()

local bird = display.newRect( 0, 0, 0, 0 )

function main()
	display.setStatusBar( display.HiddenStatusBar )	
	
	initBackground()
	
	initHills()
	initBird()
	
	startGame()
	
end

function initBackground()
	
	local img = display.newImage( "background.png", true)
	imagesGroup:insert(img)
	
end

function initBird()
	bird = display.newImage( "penguin.png", birdFixedCoordX, 300)
	physics.addBody(bird, "dynamic", {friction=0, bounce=0.0, radius=birdRadius})
	mainGroup:insert(bird)	
	
	local onScreenTouch = function(event)
		if(event.phase == "began") then
			fingerDown = true
		end
		
		if(event.phase == "ended" or event.phase == "cancelled") then
			fingerDown = false
		end
	end

	
	-- Makes the bird move at a min rate horizontally 
	local moveBirdHorz = function(event)
		local xVel, yVel = bird:getLinearVelocity()

	
		if(xVel < minBirdHorzVel) then
			bird:setLinearVelocity(minBirdHorzVel,yVel)	
		end
		
		if(fingerDown == true) then
			bird:applyForce( 0, birdAppliedForce, bird.x, bird.y )
		end
		
		local birdAngle = math.atan2((yVel) , (xVel) ) * (180 / math.pi)
		bird.rotation = birdAngle
			-- transition.to(bird, {rotation = 720, time = 1500})
			
		print ("bird.rotation = ", bird.rotation)
	end
	
	Runtime:addEventListener("touch", onScreenTouch)
	Runtime:addEventListener("enterFrame", moveBirdHorz)


end


-- Moves the main group such that the bird is always in a fixed x coord
function startGame()

	local moveMainGroup = function(event) 
		local birdContentCoordX, notNeeded = bird:localToContent(0,0)
		local diff = birdContentCoordX - birdFixedCoordX
		
		mainGroup.x = mainGroup.x - diff
	end
	
	
	Runtime:addEventListener("enterFrame", moveMainGroup)

	local increaseDifficulty = function(event)
	
	end
end

function createCloud()
	
	local cloud = display.newImage(clouds[math.random(1, #clouds)])
	cloud.y = hillYPosition * math.random()
	cloud.x = display.contentWidth + cloud.width / 2 + cloud.width * 2 * math.random()
	
	physics.addBody(cloud, "kinematic", {isSensor = true})
	cloud:setLinearVelocity(cloudVelocityX, 0)

	imagesGroup:insert(cloud)

	return clould
end


function initHills()
	
	while(hillOffSet < display.contentWidth + sideBuffer) do			
		createHill()
	end
end

-- Creates one hill
-- Code borrowed from: http://www.cocos2d-iphone.org/forum/topic/14136/page/3
-- Thanks to  dmanrj and my email: pietro.galassi@gmail.com for the code 
function createHill()
	
	local physicsBodyHeight = 30

	local x1 = hillOffSet
	local yStaringPosition = display.contentHeight  - display.contentHeight / 4
	
	local h_height = hillHeight + math.random(hillHeight) 
		
	-- Hill amplitude scale
	local h_amp = hillAmpMinValue  + math.random() * hillAmpRange

	local y1 = h_height
	
	local objects = {}	
		
	if(cloudInterval % hillToCloudRatio == 0) then 
		local cloud = createCloud()
		table.insert(objects, cloud)
	end
	cloudInterval = cloudInterval + 1
	
	local lineGroup = display.newGroup()
	mainGroup:insert(lineGroup, 0)
	
	local angleStep = 20 -- magic number ! multiple of 360 otherwise tons of chopiness 
		
	local angle
	for angle = angleStep, 360, angleStep do
			
			local points = {}
			
			local x2 = hillOffSet + angle/h_amp
			local y2 = h_height * math.cos(math.rad(angle))

			local rect = display.newRect(0,0,1,1)
			-- rect.isVisible = false
			
			-- Going to make a rectangle for each line segment 
			table.insert(points, x2) 
			table.insert(points, hillYPosition - h_height + y2 + physicsBodyHeight)
				
			table.insert(points, x1)
			table.insert(points, hillYPosition - h_height + y1 +physicsBodyHeight)
				
			table.insert(points, x1)
			table.insert(points, hillYPosition - h_height + y1)
			
			table.insert(points, x2)
			table.insert(points, hillYPosition - h_height + y2)
			
			local fillAngle
			local fillX1, fillY2
			local fillX2, fillX2
			fillX2 = x2
			
			-- Fils in the hill with a color
			for fillAngle = angle - angleStep, angle do

				local fillX = hillOffSet + fillAngle/h_amp
				local fillY = h_height * math.cos(math.rad(fillAngle))
				
				local line = display.newLine(fillX, hillYPosition - h_height + fillY, fillX - 100, display.contentHeight)
				line:setColor(hsv(fillAngle % 360 == 0 and 1 or fillAngle,.4,.8))
				
				line.width = 3
				mainGroup:insert(line)
				table.insert(objects, line)
				
			end
			
			physics.addBody(rect, "static", {w=0, bounce=.0, shape=points})
			mainGroup:insert(rect)
			table.insert(objects, rect)
			
			rect.xPos = x2

			x1 = x2
			y1 = y2	
			
			if(angle == 360) then

				local onRectEnterFrame
				onRectEnterFrame = function(event)

					local rectContentCoordX, notNeeded = rect:localToContent(rect.xPos,0)
					if(rectContentCoordX < 0) then 

						Runtime:removeEventListener("enterFrame", onRectEnterFrame)
						
						for key,body in pairs(objects) do
							body:removeSelf()
						end
						
						createHill()
					end
				end
				Runtime:addEventListener("enterFrame", onRectEnterFrame)
			end
		end
		
		hillOffSet = x1	
		
		
	mainGroup:insert(bird) -- Keep the bird on the top display levels
end

-- Helps us make pretty colors by converting hsv to rgb
-- From http://pastebin.com/pqXgvyCs
function hsv(h,s,v,a)
        local c, h_ = v*s, (h%360)/60
        local x = c*(1-(h_%2-1))
        local c_, m = ({{c,x,0},{x,c,0},{0,c,x},{0,x,c},{x,0,c},{c,0,x}})[math.ceil(h_)], v-c
        
		return (c_[1]+m)*255,(c_[2]+m)*255,(c_[3]+m)*255,a or 255
end

main()