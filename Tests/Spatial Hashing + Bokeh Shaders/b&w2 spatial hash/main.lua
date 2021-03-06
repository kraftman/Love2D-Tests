

local scwidth, scheight = 800, 800
local lg = love.graphics
local lt = love.timer
local floor = math.floor


local balls = {} -- table containing all of the balls
local mb = {}

local bwidth = 4 --width of the screen in buckets
local cellsize = scwidth/bwidth
local bnum = bwidth *bwidth

local buckets = {}

for i = 0, bnum,1 do
	buckets[i] = {}
end


function love.load()
	balls = {}
	scwidth = love.graphics.getWidth()
	scheight = love.graphics.getHeight()
end



function mb:update(dt) --movement pass
	
	local newx, newy
	newx = self.x + self.vx*dt
	newy = self.y + self.vy *dt
	

	if newx-self.r < 0 then
		newx = -(newx-self.r) +self.r
		self.vx = -self.vx
	elseif newx+self.r > scwidth then
		newx = scwidth - (newx-scwidth+self.r) -self.r
		self.vx = -self.vx
	end

	if newy-self.r < 0 then
		newy = -(newy-self.r) +self.r
		self.vy = -self.vy
	elseif newy+self.r > scheight then
		newy = scheight - (newy-scheight+self.r) -self.r
		self.vy = -self.vy
	end
	
	self.x = newx
	self.y = newy
	
	--self:collide()
end


function mb:collide()
	local ball
	local pen
	self.col = false
	for i = 1, #balls do
		if i ~= self.index then
			ball = balls[i]
			if (self.x - ball.x)^2 + (self.y - ball.y)^2 < (ball.r + self.r)^2 then
				self.col = true
			end
		end
	end
end




function mb:new()
	local b = {}
	local x, y = love.mouse.getPosition()
	b.x = math.random(20, scwidth-20)
	b.y = math.random(20,scheight-20)
	b.vx = math.random(-50,50)
	b.vy = math.random(-50,50)
	b.r = math.random(2,7)
	b.update = mb.update
	b.draw = mb.draw
	b.collide = mb.collide
	b.loc = {}
	table.insert(balls, b)
	b.index = #balls

end


function mb:draw()
	if self.col then
		lg.setColor(255,0,0,255)
	else
		lg.setColor(255,255,255,255)
	end
	lg.circle("fill", self.x, self.y, self.r, 16)
end

--======= standard callbacks

function love.mousepressed()
	for i = 1, 20 do
		mb:new()
	end
end



local function SortAndAssign()
	local b
	local loc
	
	for i = 0, bnum,1 do
		buckets[i] = {} --clear the buckets
	end
	
	for i = 1, #balls do
		b = balls[i]
		b.col = false
		for x = b.x-b.r, b.x+b.r, b.r*2 do
			for y= b.y-b.r, b.y+b.r, b.r*2 do
				 loc = floor(x/cellsize) + floor(y/cellsize)*bwidth
				 --print(x, y, loc)
				 buckets[loc][b] = b
			end
		end
	end
	
	for i = 0, bnum,1 do
		for b in pairs(buckets[i]) do --for each ball
			for bc in pairs(buckets[i]) do --check each other ball
				if b~=bc then
					if (b.x - bc.x)^2 + (b.y - bc.y)^2 < (b.r + bc.r)^2 then
						b.col = true
					end
				end
			end
		end
	end
end


function love.update(dt)
	for i = 1, #balls do
		balls[i]:update(dt) --just updates their positions and bounces them off walls
	end
	
	SortAndAssign()
end

function love.draw()
	for i = 1, #balls do
		balls[i]:draw()
	end

	lg.print("FPS: "..lt.getFPS(), 10 ,10)
	lg.print("Balls: "..#balls, 10 , 30)
end




