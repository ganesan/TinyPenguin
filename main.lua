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
-- physics.setDrawMode("hybrid")

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
local birdRadius = 18
local birdFixedCoordX = display.contentWidth / 5
local minBirdHorzVel = 350--display.contentWidth / 10
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
	physics.addBody(bird, "dynamic", {friction=0, bounce=0.1, radius=birdRadius})
	mainGroup:insert(bird)	
	bird.isFixedRotation = false
	
	local onScreenTouch = function(event)
		if(event.phase == "began") then
			fingerDown = true
		end
		
		if(event.phase == "ended" or event.phase == "cancelled") then
			fingerDown = false
		end
	end
	
	bird.x1 = false
	bird.x2 = false
	bird.y1 = false
	bird.y2 = false
	bird.colName = false

	bird.isHit = function( x1 , x2 , y1 , y2 , colName )
	
		bird.x1 = x1
		bird.x2 = x2
		bird.y1 = y1
		bird.y2 = y2
		bird.colName = colName
	
	end
	
	bird.endHit = function( colName )
	
		if colName == bird.colName then
			bird.x1 = false
			bird.x2 = false
			bird.y1 = false
			bird.y2 = false
			bird.colName = false
		end
	
	end

	
	-- Makes the bird move at a min rate horizontally 
	local moveBirdHorz = function(event)
		
		-- Touching Ground
		if bird.x1 ~= false then
		
			-- Matt - First Get Current Velocity
			local xVel, yVel = bird:getLinearVelocity()
			local vel = math.sqrt ( ( xVel * xVel ) + ( yVel * yVel ) )
			
			-- Calculate Slope Of Ground
			local birdAngle = -( math.atan2( bird.y1 - bird.y2 , bird.x1 - bird.x2 ) * ( 180 / math.pi ) )
			
			-- Rotate Bird
			bird.rotation = birdAngle
			
			--if ( vel < minBirdHorzVel ) then
				-- Matt - Calculate X Velocity Based On Bird Direction
				local newXVel = ( math.sin( ( birdAngle - 5 ) * math.pi / 180 ) * minBirdHorzVel )
				local newYVel = ( math.cos( ( birdAngle - 5 ) * math.pi / 180 ) * minBirdHorzVel )
				-- Matt - Apply New Velocity To Bird
				bird:setLinearVelocity( newYVel , newXVel )
				
			--end
		
		else
		
			-- Matt - First Get Current Velocity
			local xVel, yVel = bird:getLinearVelocity()

			-- Matt - Calculate Angle Of Travel
			local birdAngle = math.atan2( yVel , xVel ) * ( 180 / math.pi )
			
			-- Rotate Bird
			bird.rotation = birdAngle
			
			-- Matt - Calculate Velocity of Travel
			local vel = math.sqrt ( ( xVel * xVel ) + ( yVel * yVel ) )
			--print ( vel )
		
			-- Matt - Check Min Velocity Against Actual Velocity
			if ( vel < minBirdHorzVel ) then
			
				-- Matt - Calculate X Velocity Based On Bird Direction
				local newXVel = ( math.sin( birdAngle * math.pi / 180 ) * minBirdHorzVel )
				local newYVel = ( math.cos( birdAngle * math.pi / 180 ) * minBirdHorzVel )
			
				-- Matt - Apply New Velocity To Bird
				--bird:setLinearVelocity( newYVel , newXVel )

			end
		
		end
		
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
	
	local angleStep = 20
		
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
			
			
			-- Matt - Capturing values
			local startX = x2
			local startY = hillYPosition - h_height + y1
			local endX = x1
			local endY = hillYPosition - h_height + y2
			
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
			
			physics.addBody(rect, "static", {w=0, bounce=0.0, shape=points})
			mainGroup:insert(rect)
			table.insert(objects, rect)
			
			rect.xPos = x2
			
			rect.name = "col_"..x1
			-- Collision Handler
			rect.collision = function( self , event )
		
				-- On Collision
				if ( event.phase == "began" ) then
			
					event.other.isHit( startX , endX , startY , endY, rect.name )
	
				end
				
				if ( event.phase == "ended" ) then
			
					event.other.endHit(rect.name)
	
				end
	
			end
			rect:addEventListener( "collision" , rect )

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